# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collaboration, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates collaboration from factory' do
      collaboration = create(:collaboration)
      expect(collaboration).to be_persisted
      expect(collaboration.user).not_to be_nil
      expect(collaboration.payment_type).to eq(1)
    end

    it 'creates collaboration with CCC' do
      collaboration = create(:collaboration, :with_ccc)
      expect(collaboration.payment_type).to eq(2)
      expect(collaboration.ccc_entity).not_to be_nil
    end

    it 'creates collaboration with IBAN' do
      collaboration = create(:collaboration, :with_iban)
      expect(collaboration.payment_type).to eq(3)
      expect(collaboration.iban_account).not_to be_nil
    end

    it 'creates non-user collaboration' do
      collaboration = create(:collaboration, :non_user)
      expect(collaboration.user_id).to be_nil
      expect(collaboration.non_user_email).not_to be_nil
      expect(collaboration.non_user_document_vatid).not_to be_nil
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'requires payment_type' do
      collaboration = build(:collaboration, payment_type: nil)
      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:payment_type]).to include('no puede estar en blanco')
    end

    it 'requires amount' do
      collaboration = build(:collaboration, amount: nil)
      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:amount]).to include('no puede estar en blanco')
    end

    it 'requires frequency' do
      collaboration = build(:collaboration, frequency: nil)
      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:frequency]).to include('no puede estar en blanco')
    end

    it 'requires terms_of_service acceptance' do
      collaboration = build(:collaboration, terms_of_service: false)
      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:terms_of_service]).to include('debe ser aceptado')
    end

    it 'requires minimal_year_old acceptance' do
      collaboration = build(:collaboration, minimal_year_old: false)
      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:minimal_year_old]).to include('debe ser aceptado')
    end

    it 'validates user_id uniqueness for recurring collaborations' do
      # Create user with DNI (not passport) to pass Collaboration validations
      dni_letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
      number = rand(10_000_000..99_999_999)
      letter = dni_letters[number % 23]
      user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}")
      user.save(validate: false)

      create(:collaboration, user: user, frequency: 1)

      duplicate = build(:collaboration, user: user, frequency: 1)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include('ya está en uso')
    end

    it 'allows multiple single collaborations for same user' do
      # Create user with DNI (not passport) to pass Collaboration validations
      dni_letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
      number = rand(10_000_000..99_999_999)
      letter = dni_letters[number % 23]
      user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}")
      user.save(validate: false)

      create(:collaboration, :single, user: user)

      duplicate = build(:collaboration, :single, user: user)
      expect(duplicate).to be_valid
    end

    it 'validates CCC fields when payment_type is CCC' do
      collaboration = build(:collaboration, payment_type: 2, ccc_entity: nil)
      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:ccc_entity]).to include('no puede estar en blanco')
    end

    it 'validates IBAN presence when payment_type is IBAN' do
      collaboration = build(:collaboration, payment_type: 3, iban_account: nil, iban_bic: nil)
      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:iban_account]).to include('no puede estar en blanco')
    end

    it 'rejects passport users' do
      passport_user = build(:user, document_type: 3)
      passport_user.save(validate: false) # Skip User validations
      collaboration = build(:collaboration, user: passport_user)

      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:user]).to include('No puedes colaborar si no dispones de DNI o NIE.')
    end

    it 'rejects underage users' do
      # Create user with DNI format
      dni_letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
      number = rand(10_000_000..99_999_999)
      letter = dni_letters[number % 23]

      young_user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}", born_at: 10.years.ago)
      young_user.save(validate: false) # Skip User validations
      collaboration = build(:collaboration, user: young_user)

      expect(collaboration).not_to be_valid
      expect(collaboration.errors[:user]).to include('No puedes colaborar si eres menor de edad.')
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates collaboration' do
      expect { create(:collaboration) }.to change(Collaboration, :count).by(1)
    end

    it 'reads collaboration' do
      collaboration = create(:collaboration)
      found = Collaboration.find(collaboration.id)

      expect(found.id).to eq(collaboration.id)
      expect(found.amount).to eq(collaboration.amount)
    end

    it 'updates collaboration' do
      collaboration = create(:collaboration, amount: 1000)
      collaboration.update(amount: 2000)

      expect(collaboration.reload.amount).to eq(2000)
    end

    it 'soft deletes collaboration' do
      collaboration = create(:collaboration)

      expect { collaboration.destroy }.to change(Collaboration, :count).by(-1)

      expect(collaboration.reload.deleted_at).not_to be_nil
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.live' do
      it 'excludes deleted collaborations' do
        active = create(:collaboration)
        deleted = create(:collaboration, :deleted)

        results = Collaboration.live

        expect(results).to include(active)
        expect(results).not_to include(deleted)
      end
    end

    describe '.credit_cards' do
      it 'returns only credit card collaborations' do
        cc = create(:collaboration, payment_type: 1)
        bank = create(:collaboration, :with_iban)

        results = Collaboration.credit_cards

        expect(results).to include(cc)
        expect(results).not_to include(bank)
      end
    end

    describe '.banks' do
      it 'returns only bank collaborations' do
        cc = create(:collaboration, payment_type: 1)
        bank = create(:collaboration, :with_iban)

        results = Collaboration.banks

        expect(results).to include(bank)
        expect(results).not_to include(cc)
      end
    end

    describe '.frequency_single' do
      it 'returns single frequency collaborations' do
        single = create(:collaboration, :single)
        monthly = create(:collaboration, frequency: 1)

        results = Collaboration.frequency_single

        expect(results).to include(single)
        expect(results).not_to include(monthly)
      end
    end

    describe '.frequency_month' do
      it 'returns monthly frequency collaborations' do
        monthly = create(:collaboration, frequency: 1)
        quarterly = create(:collaboration, :quarterly)

        results = Collaboration.frequency_month

        expect(results).to include(monthly)
        expect(results).not_to include(quarterly)
      end
    end

    describe '.incomplete' do
      it 'returns incomplete collaborations' do
        incomplete = create(:collaboration, :incomplete)
        active = create(:collaboration, :active)

        results = Collaboration.incomplete

        expect(results).to include(incomplete)
        expect(results).not_to include(active)
      end
    end

    describe '.active' do
      it 'returns active collaborations' do
        active = create(:collaboration, :active)
        incomplete = create(:collaboration, :incomplete)

        results = Collaboration.active

        expect(results).to include(active)
        expect(results).not_to include(incomplete)
      end
    end

    describe '.warnings' do
      it 'returns warning status collaborations' do
        warning = create(:collaboration, :warning)
        active = create(:collaboration, :active)

        results = Collaboration.warnings

        expect(results).to include(warning)
        expect(results).not_to include(active)
      end
    end

    describe '.errors' do
      it 'returns error status collaborations' do
        error = create(:collaboration, :error)
        active = create(:collaboration, :active)

        results = Collaboration.errors

        expect(results).to include(error)
        expect(results).not_to include(active)
      end
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to user' do
      collaboration = create(:collaboration)
      expect(collaboration).to respond_to(:user)
      expect(collaboration.user).to be_an_instance_of(User)
    end

    it 'has many orders' do
      collaboration = create(:collaboration)
      expect(collaboration).to respond_to(:order)
    end

    it 'allows nil user for non-user collaborations' do
      collaboration = create(:collaboration, :non_user)
      expect(collaboration.user).to be_nil
      expect(collaboration.get_user).not_to be_nil
    end
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  describe 'callbacks' do
    it 'sets initial status after create' do
      collaboration = build(:collaboration)
      collaboration.save

      expect(collaboration.status).to eq(0)
    end

    it 'upcases IBAN before save' do
      collaboration = create(:collaboration, :with_iban, iban_account: 'es9121000418450200051332')

      expect(collaboration.iban_account).to eq('ES9121000418450200051332')
    end

    it 'clears redsys fields for bank payments' do
      collaboration = create(:collaboration, payment_type: 1, redsys_identifier: 'ABC123')
      collaboration.update(payment_type: 3, iban_account: 'ES9121000418450200051332', iban_bic: 'CAIXESBBXXX')

      expect(collaboration.reload.redsys_identifier).to be_nil
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#is_credit_card?' do
      it 'returns true for credit card payments' do
        collaboration = create(:collaboration, payment_type: 1)
        expect(collaboration.is_credit_card?).to be true
      end
    end

    describe '#is_bank?' do
      it 'returns true for bank payments' do
        collaboration = create(:collaboration, :with_iban)
        expect(collaboration.is_bank?).to be true
      end
    end

    describe '#is_bank_national?' do
      it 'returns true for Spanish IBAN' do
        collaboration = create(:collaboration, :with_spanish_iban)
        expect(collaboration.is_bank_national?).to be true
      end
    end

    describe '#is_bank_international?' do
      it 'returns true for non-Spanish IBAN' do
        collaboration = create(:collaboration, :with_international_iban)
        expect(collaboration.is_bank_international?).to be true
      end
    end

    describe '#has_ccc_account?' do
      it 'returns true when payment_type is 2' do
        collaboration = create(:collaboration, :with_ccc)
        expect(collaboration.has_ccc_account?).to be true
      end
    end

    describe '#has_iban_account?' do
      it 'returns true when payment_type is 3' do
        collaboration = create(:collaboration, :with_iban)
        expect(collaboration.has_iban_account?).to be true
      end
    end

    describe '#frequency_name' do
      it 'returns correct name' do
        collaboration = create(:collaboration, frequency: 1)
        expect(collaboration.frequency_name).to eq('Mensual')
      end
    end

    describe '#status_name' do
      it 'returns correct name' do
        collaboration = create(:collaboration, :active)
        collaboration.reload # Reload to ensure status was set by after(:create) callback
        expect(collaboration.status).to eq(3)
        expect(collaboration.status_name).to eq('OK')
      end
    end

    describe '#ccc_full' do
      it 'returns formatted CCC' do
        collaboration = create(:collaboration, :with_ccc)
        expected = '21001234561234567890'

        expect(collaboration.ccc_full).to eq(expected)
      end
    end

    describe '#has_payment?' do
      it 'returns true when status > 0' do
        collaboration = create(:collaboration, :active)
        collaboration.reload
        expect(collaboration.has_payment?).to be true
      end
    end

    describe '#is_active?' do
      it 'returns true for active status' do
        collaboration = create(:collaboration, :active)
        collaboration.reload
        expect(collaboration.is_active?).to be true
      end
    end

    describe '#has_confirmed_payment?' do
      it 'returns true when status > 2' do
        collaboration = create(:collaboration, :active)
        collaboration.reload
        expect(collaboration.has_confirmed_payment?).to be true
      end
    end

    describe '#has_warnings?' do
      it 'returns true for warning status' do
        collaboration = create(:collaboration, :warning)
        collaboration.reload
        expect(collaboration.has_warnings?).to be true
      end
    end

    describe '#has_errors?' do
      it 'returns true for error status' do
        collaboration = create(:collaboration, :error)
        collaboration.reload
        expect(collaboration.has_errors?).to be true
      end
    end
  end

  # ====================
  # STATUS METHOD TESTS
  # ====================

  describe 'status methods' do
    describe '#set_error!' do
      it 'changes status to error' do
        collaboration = create(:collaboration, :active)
        collaboration.set_error!('Test error')

        expect(collaboration.reload.status).to eq(1)
      end
    end

    describe '#set_ok!' do
      it 'changes status to OK' do
        collaboration = create(:collaboration, :unconfirmed)
        collaboration.set_ok!

        expect(collaboration.reload.status).to eq(3)
      end
    end

    describe '#set_warning!' do
      it 'changes status to warning' do
        collaboration = create(:collaboration, :active)
        collaboration.set_warning!('Test warning')

        expect(collaboration.reload.status).to eq(4)
      end
    end

    describe '#set_active!' do
      it 'changes status to active if lower' do
        collaboration = create(:collaboration, :incomplete)
        collaboration.set_active!

        expect(collaboration.reload.status).to eq(2)
      end
    end
  end

  # ====================
  # TERRITORIAL ASSIGNMENT TESTS
  # ====================

  describe 'territorial assignment' do
    describe '#territorial_assignment' do
      it 'returns correct symbol' do
        collaboration = create(:collaboration, :for_town)
        expect(collaboration.territorial_assignment).to eq(:town)
      end
    end

    describe '#territorial_assignment= :town' do
      it 'sets correct flags for town' do
        collaboration = create(:collaboration)
        collaboration.territorial_assignment = :town

        expect(collaboration.for_town_cc).to be true
        expect(collaboration.for_autonomy_cc).to be false
        expect(collaboration.for_island_cc).to be false
      end
    end

    describe '#territorial_assignment= :autonomy' do
      it 'sets correct flags for autonomy' do
        collaboration = create(:collaboration)
        collaboration.territorial_assignment = :autonomy

        expect(collaboration.for_autonomy_cc).to be true
        expect(collaboration.for_town_cc).to be false
        expect(collaboration.for_island_cc).to be false
      end
    end

    describe '#territorial_assignment= :island' do
      it 'sets correct flags for island' do
        collaboration = create(:collaboration)
        collaboration.territorial_assignment = :island

        expect(collaboration.for_island_cc).to be true
        expect(collaboration.for_town_cc).to be false
        expect(collaboration.for_autonomy_cc).to be false
      end
    end
  end

  # ====================
  # SOFT DELETE (PARANOIA) TESTS
  # ====================

  describe 'soft delete' do
    it 'excludes soft deleted from default scope' do
      active = create(:collaboration)
      deleted = create(:collaboration, :deleted)

      results = Collaboration.all

      expect(results).to include(active)
      expect(results).not_to include(deleted)
    end

    it 'includes soft deleted with with_deleted scope' do
      active = create(:collaboration)
      deleted = create(:collaboration, :deleted)

      results = Collaboration.with_deleted

      expect(results).to include(active)
      expect(results).to include(deleted)
    end

    it 'restores soft deleted collaboration' do
      collaboration = create(:collaboration)
      collaboration.destroy

      expect(collaboration.deleted_at).not_to be_nil

      collaboration.restore

      expect(collaboration.reload.deleted_at).to be_nil
      expect(Collaboration.all).to include(collaboration)
    end
  end

  # ====================
  # PAYMENT IDENTIFIER TESTS
  # ====================

  describe '#payment_identifier' do
    it 'returns redsys_identifier for credit cards' do
      collaboration = create(:collaboration, payment_type: 1, redsys_identifier: 'ABC123')
      expect(collaboration.payment_identifier).to eq('ABC123')
    end

    it 'returns IBAN/BIC for IBAN payments' do
      collaboration = create(:collaboration, :with_iban)
      expect(collaboration.payment_identifier).to include(collaboration.iban_account)
      expect(collaboration.payment_identifier).to include(collaboration.iban_bic)
    end
  end

  # ====================
  # GET_USER TESTS
  # ====================

  describe '#get_user' do
    it 'returns user when user exists' do
      collaboration = create(:collaboration)
      expect(collaboration.get_user).to eq(collaboration.user)
    end

    it 'returns non_user when user is nil' do
      collaboration = create(:collaboration, :non_user, non_user_email: 'nonuser@example.com')
      non_user = collaboration.get_user

      expect(non_user).not_to be_nil
      expect(non_user.email).to eq('nonuser@example.com')
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles collaboration without user' do
      collaboration = create(:collaboration, :non_user)
      expect(collaboration.user).to be_nil
      expect(collaboration).to be_persisted
    end

    it 'allows same email for deleted non-user collaborations' do
      create(:collaboration, :non_user, :deleted, non_user_email: 'test@example.com')
      duplicate = build(:collaboration, :non_user, non_user_email: 'test@example.com')

      expect(duplicate).to be_valid
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'completes credit card collaboration workflow' do
      # Create user with DNI (not passport) to pass Collaboration validations
      dni_letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
      number = rand(10_000_000..99_999_999)
      letter = dni_letters[number % 23]
      user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}")
      user.save(validate: false)

      collaboration = nil
      expect do
        collaboration = create(:collaboration,
                               user: user,
                               payment_type: 1,
                               amount: 1000,
                               frequency: 1)
      end.to change(Collaboration, :count).by(1)

      expect(collaboration.is_credit_card?).to be true
      expect(collaboration.is_bank?).to be false
      expect(collaboration.frequency_name).to eq('Mensual')
      expect(collaboration.get_user).to eq(user)
    end

    it 'completes bank collaboration workflow' do
      # Create user with DNI (not passport) to pass Collaboration validations
      dni_letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
      number = rand(10_000_000..99_999_999)
      letter = dni_letters[number % 23]
      user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}")
      user.save(validate: false)

      collaboration = create(:collaboration, :with_iban, :active,
                             user: user,
                             amount: 2000,
                             frequency: 3)

      # with_iban uses German IBAN by default (international)
      expect(collaboration.is_bank?).to be true
      expect(collaboration.is_bank_international?).to be true
      expect(collaboration.is_credit_card?).to be false
      expect(collaboration.frequency_name).to eq('Trimestral')
      collaboration.reload
      expect(collaboration.status_name).to eq('OK')
    end

    it 'follows status change workflow' do
      collaboration = create(:collaboration, :incomplete)
      expect(collaboration.status).to eq(0)

      collaboration.set_active!
      expect(collaboration.reload.status).to eq(2)

      collaboration.set_ok!
      expect(collaboration.reload.status).to eq(3)

      collaboration.set_warning!('Test')
      expect(collaboration.reload.status).to eq(4)

      collaboration.set_error!('Test')
      expect(collaboration.reload.status).to eq(1)
    end
  end
end
