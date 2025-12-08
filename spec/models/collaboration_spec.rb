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

  # ====================
  # NONUSER CLASS TESTS
  # ====================

  describe 'NonUser class' do
    it 'creates NonUser with attributes' do
      non_user = Collaboration::NonUser.new(
        full_name: 'Test User',
        document_vatid: '12345678Z',
        email: 'test@example.com',
        address: '123 Test St',
        town_name: 'Madrid',
        postal_code: '28001',
        country: 'ES'
      )

      expect(non_user.full_name).to eq('Test User')
      expect(non_user.document_vatid).to eq('12345678Z')
      expect(non_user.email).to eq('test@example.com')
    end

    it 'implements to_s method' do
      non_user = Collaboration::NonUser.new(
        full_name: 'Test User',
        document_vatid: '12345678Z',
        email: 'test@example.com'
      )

      expect(non_user.to_s).to eq('Test User (12345678Z - test@example.com)')
    end

    it 'returns false for still_militant?' do
      non_user = Collaboration::NonUser.new(full_name: 'Test')
      expect(non_user.still_militant?).to be false
    end

    it 'returns nil for vote_circle_id' do
      non_user = Collaboration::NonUser.new(full_name: 'Test')
      expect(non_user.vote_circle_id).to be_nil
    end
  end

  # ====================
  # NON_USER DATA METHODS
  # ====================

  describe 'non_user data methods' do
    describe '#parse_non_user' do
      it 'parses non_user_data from YAML' do
        collaboration = create(:collaboration, :non_user)
        expect(collaboration.get_non_user).to be_a(Collaboration::NonUser)
        expect(collaboration.get_non_user.email).not_to be_nil
      end
    end

    describe '#format_non_user' do
      it 'formats non_user data to YAML' do
        collaboration = build(:collaboration, user: nil)
        non_user_data = {
          full_name: 'Test User',
          document_vatid: '12345678Z',
          email: 'test@example.com',
          address: '123 Test St',
          town_name: 'Madrid',
          postal_code: '28001',
          country: 'ES',
          ine_town: 'm_28_079_6'
        }
        collaboration.set_non_user(non_user_data)

        expect(collaboration.non_user_data).not_to be_nil
        expect(collaboration.non_user_email).to eq('test@example.com')
        expect(collaboration.non_user_document_vatid).to eq('12345678Z')
      end
    end

    describe '#set_non_user' do
      it 'sets non_user from hash' do
        collaboration = create(:collaboration, :non_user)
        new_data = {
          full_name: 'New User',
          document_vatid: '87654321A',
          email: 'new@example.com',
          address: '456 New St',
          town_name: 'Barcelona',
          postal_code: '08001',
          country: 'ES',
          ine_town: 'm_08_019_3'
        }
        collaboration.set_non_user(new_data)

        expect(collaboration.get_non_user.full_name).to eq('New User')
        expect(collaboration.non_user_email).to eq('new@example.com')
      end

      it 'clears non_user when passed nil' do
        collaboration = create(:collaboration, :non_user)
        collaboration.set_non_user(nil)

        expect(collaboration.get_non_user).to be_nil
        expect(collaboration.non_user_email).to be_nil
        expect(collaboration.non_user_document_vatid).to be_nil
      end
    end

    describe '#get_non_user' do
      it 'returns non_user instance' do
        collaboration = create(:collaboration, :non_user)
        non_user = collaboration.get_non_user

        expect(non_user).to be_a(Collaboration::NonUser)
        expect(non_user.email).not_to be_nil
      end
    end
  end

  # ====================
  # URL HELPER TESTS
  # ====================

  describe 'URL helpers' do
    describe '#ok_url' do
      it 'returns ok URL' do
        collaboration = create(:collaboration)
        expect(collaboration.ok_url.downcase).to include('ok')
      end
    end

    describe '#ko_url' do
      it 'returns ko URL' do
        collaboration = create(:collaboration)
        expect(collaboration.ko_url.downcase).to include('ko')
      end
    end

    describe '#admin_permalink' do
      it 'returns admin path' do
        collaboration = create(:collaboration)
        expect(collaboration.admin_permalink).to include('/admin')
        expect(collaboration.admin_permalink).to include(collaboration.id.to_s)
      end
    end

    describe '#default_url_options' do
      it 'returns URL options' do
        collaboration = create(:collaboration)
        expect(collaboration.default_url_options).to be_a(Hash)
        expect(collaboration.default_url_options).to have_key(:host)
      end
    end
  end

  # ====================
  # RECURRENCE TESTS
  # ====================

  describe '#is_recurrent?' do
    it 'always returns true' do
      collaboration = create(:collaboration, :single)
      expect(collaboration.is_recurrent?).to be true
    end
  end

  describe '#only_have_single_collaborations?' do
    it 'returns true for single frequency' do
      collaboration = create(:collaboration, :single)
      expect(collaboration.only_have_single_collaborations?).to be true
    end

    it 'returns falsey for recurring frequency' do
      collaboration = build(:collaboration)
      collaboration.frequency = 1
      # The method returns `frequency&.zero? || skip_queries_validations`
      # When frequency is 1, this returns false || nil which is nil (falsey)
      expect(collaboration.only_have_single_collaborations?).to be_falsey
    end

    it 'returns true when skip_queries_validations is set' do
      collaboration = build(:collaboration, frequency: 1, skip_queries_validations: true)
      expect(collaboration.only_have_single_collaborations?).to be true
    end

    it 'returns true when frequency is nil' do
      collaboration = build(:collaboration, frequency: nil)
      # When frequency is nil, frequency&.zero? returns nil, which is falsey
      # so the method returns skip_queries_validations (which is falsey by default)
      expect(collaboration.only_have_single_collaborations?).to be_falsey
    end
  end

  # ====================
  # IS_PAYABLE TESTS
  # ====================

  describe '#is_payable?' do
    it 'returns true for unconfirmed status' do
      collaboration = create(:collaboration, :unconfirmed)
      collaboration.reload
      expect(collaboration.is_payable?).to be true
    end

    it 'returns true for active status' do
      collaboration = create(:collaboration, :active)
      collaboration.reload
      expect(collaboration.is_payable?).to be true
    end

    it 'returns false for deleted collaboration' do
      collaboration = create(:collaboration, :active)
      collaboration.destroy
      expect(collaboration.is_payable?).to be false
    end

    it 'returns false for user deleted' do
      collaboration = create(:collaboration, :active)
      collaboration.user.destroy
      expect(collaboration.is_payable?).to be false
    end
  end

  # ====================
  # FIX_STATUS TESTS
  # ====================

  describe '#fix_status!' do
    it 'marks invalid collaboration as error' do
      collaboration = create(:collaboration)
      collaboration.amount = nil # Make invalid
      result = collaboration.fix_status!

      expect(result).to be true
      expect(collaboration.reload.status).to eq(1)
    end

    it 'returns false for valid collaboration' do
      collaboration = create(:collaboration, :active)
      result = collaboration.fix_status!

      expect(result).to be false
    end

    it 'does not change status of already errored collaboration' do
      collaboration = create(:collaboration, :error)
      collaboration.reload
      old_status = collaboration.status
      collaboration.fix_status!

      expect(collaboration.reload.status).to eq(old_status)
    end
  end

  # ====================
  # ADDITIONAL SCOPE TESTS
  # ====================

  describe 'additional scopes' do
    describe '.frequency_quarterly' do
      it 'returns quarterly collaborations' do
        quarterly = create(:collaboration, :quarterly)
        monthly = create(:collaboration, frequency: 1)

        results = Collaboration.frequency_quarterly

        expect(results).to include(quarterly)
        expect(results).not_to include(monthly)
      end
    end

    describe '.frequency_anual' do
      it 'returns annual collaborations' do
        annual = create(:collaboration, :annual)
        monthly = create(:collaboration, frequency: 1)

        results = Collaboration.frequency_anual

        expect(results).to include(annual)
        expect(results).not_to include(monthly)
      end
    end

    describe '.amount_1' do
      it 'returns collaborations with amount < 1000' do
        small = create(:collaboration, amount: 500)
        large = create(:collaboration, amount: 2000)

        results = Collaboration.amount_1

        expect(results).to include(small)
        expect(results).not_to include(large)
      end
    end

    describe '.amount_2' do
      it 'returns collaborations with amount between 1000 and 2000' do
        medium = create(:collaboration, amount: 1500)
        small = create(:collaboration, amount: 500)
        large = create(:collaboration, amount: 3000)

        results = Collaboration.amount_2

        expect(results).to include(medium)
        expect(results).not_to include(small)
        expect(results).not_to include(large)
      end
    end

    describe '.amount_3' do
      it 'returns collaborations with amount > 2000' do
        large = create(:collaboration, amount: 3000)
        small = create(:collaboration, amount: 1000)

        results = Collaboration.amount_3

        expect(results).to include(large)
        expect(results).not_to include(small)
      end
    end

    describe '.unconfirmed' do
      it 'returns unconfirmed collaborations' do
        unconfirmed = create(:collaboration, :unconfirmed)
        active = create(:collaboration, :active)

        results = Collaboration.unconfirmed

        expect(results).to include(unconfirmed)
        expect(results).not_to include(active)
      end
    end

    describe '.legacy' do
      it 'returns collaborations with non_user_data' do
        legacy = create(:collaboration, :non_user)
        regular = create(:collaboration)

        results = Collaboration.legacy

        expect(results).to include(legacy)
        expect(results).not_to include(regular)
      end
    end

    describe '.non_user' do
      it 'returns collaborations without user_id' do
        non_user_collab = create(:collaboration, :non_user)
        user_collab = create(:collaboration)

        results = Collaboration.non_user

        expect(results).to include(non_user_collab)
        expect(results).not_to include(user_collab)
      end
    end

    describe '.autonomy_cc' do
      it 'returns autonomy collaborations' do
        autonomy = create(:collaboration, :for_autonomy)
        town = create(:collaboration, :for_town)

        results = Collaboration.autonomy_cc

        expect(results).to include(autonomy)
        expect(results).not_to include(town)
      end
    end

    describe '.town_cc' do
      it 'returns town collaborations' do
        town = create(:collaboration, :for_town)
        autonomy = create(:collaboration, :for_autonomy)

        results = Collaboration.town_cc

        expect(results).to include(town)
        expect(results).not_to include(autonomy)
      end
    end

    describe '.island_cc' do
      it 'returns island collaborations' do
        island = create(:collaboration, :for_island)
        town = create(:collaboration, :for_town)

        results = Collaboration.island_cc

        expect(results).to include(island)
        expect(results).not_to include(town)
      end
    end

    describe '.bank_nationals' do
      it 'returns national bank collaborations' do
        national = create(:collaboration, :with_spanish_iban)
        international = create(:collaboration, :with_international_iban)

        results = Collaboration.bank_nationals

        expect(results).to include(national)
        expect(results).not_to include(international)
      end
    end

    describe '.bank_internationals' do
      it 'returns international bank collaborations' do
        international = create(:collaboration, :with_international_iban)
        national = create(:collaboration, :with_spanish_iban)

        results = Collaboration.bank_internationals

        expect(results).to include(international)
        expect(results).not_to include(national)
      end
    end

    describe '.full_view' do
      it 'includes deleted and eager loads orders' do
        active = create(:collaboration)
        deleted = create(:collaboration, :deleted)

        results = Collaboration.full_view

        expect(results.to_a).to include(active)
        expect(results.to_a).to include(deleted)
      end
    end

    describe '.deleted' do
      it 'returns only deleted collaborations' do
        active = create(:collaboration)
        deleted = create(:collaboration, :deleted)

        results = Collaboration.deleted

        expect(results).to include(deleted)
        expect(results).not_to include(active)
      end
    end
  end

  # ====================
  # CONSTANTS TESTS
  # ====================

  describe 'constants' do
    it 'defines AMOUNTS' do
      expect(Collaboration::AMOUNTS).to be_a(Hash)
      expect(Collaboration::AMOUNTS['10 €']).to eq(1000)
    end

    it 'defines FREQUENCIES' do
      expect(Collaboration::FREQUENCIES).to be_a(Hash)
      expect(Collaboration::FREQUENCIES['Mensual']).to eq(1)
      expect(Collaboration::FREQUENCIES['Puntual']).to eq(0)
    end

    it 'defines STATUS' do
      expect(Collaboration::STATUS).to be_a(Hash)
      expect(Collaboration::STATUS['OK']).to eq(3)
      expect(Collaboration::STATUS['Error']).to eq(1)
    end
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  describe 'class methods' do
    describe '.available_payment_types' do
      it 'returns payment types for collaboration' do
        collaboration = create(:collaboration)
        types = Collaboration.available_payment_types(collaboration)

        expect(types).to be_an(Array)
        expect(types.map(&:last)).to include(3, collaboration.payment_type)
      end
    end

    describe '.available_frequencies_for_user' do
      it 'returns all frequencies normally' do
        user = create(:user)
        user.save(validate: false)
        frequencies = Collaboration.available_frequencies_for_user(user)

        expect(frequencies).to be_an(Array)
        expect(frequencies).to include(['Puntual', 0])
        expect(frequencies).to include(['Mensual', 1])
      end

      it 'handles force_single flag' do
        user = create(:user)
        user.save(validate: false)
        # force_single returns only single/puntual frequency
        result = Collaboration.available_frequencies_for_user(user, force_single: true)
        expect(result).to eq([['Puntual', 0]])
      end

      it 'handles only_recurrent flag' do
        user = create(:user)
        user.save(validate: false)
        # only_recurrent returns all recurrent frequencies (excludes single)
        result = Collaboration.available_frequencies_for_user(user, only_recurrent: true)
        expect(result).to include(['Mensual', 1])
        expect(result).to include(['Trimestral', 3])
        expect(result).to include(['Anual', 12])
        expect(result).not_to include(['Puntual', 0])
      end
    end

    describe '.bank_filename' do
      it 'returns full path by default' do
        date = Time.zone.today
        filename = Collaboration.bank_filename(date)

        expect(filename).to include('db/plebisbrand')
        expect(filename).to include(date.year.to_s)
        expect(filename).to include(date.month.to_s)
        expect(filename).to end_with('.csv')
      end

      it 'returns filename only when full_path is false' do
        date = Time.zone.today
        filename = Collaboration.bank_filename(date, false)

        expect(filename).not_to include('/')
        expect(filename).to start_with('plebisbrand.orders')
      end
    end

    describe '.bank_file_lock' do
      after do
        Collaboration.bank_file_lock(false) # Clean up
      end

      it 'creates lock file when status is true' do
        Collaboration.bank_file_lock(true)
        expect(File.exist?(Collaboration::BANK_FILE_LOCK)).to be true
      end

      it 'removes lock file when status is false' do
        Collaboration.bank_file_lock(true)
        Collaboration.bank_file_lock(false)
        expect(File.exist?(Collaboration::BANK_FILE_LOCK)).to be false
      end
    end

    describe '.has_bank_file?' do
      it 'returns array with lock and file existence' do
        date = Time.zone.today
        result = Collaboration.has_bank_file?(date)

        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
        expect([true, false]).to include(result[0])
        expect([true, false]).to include(result[1])
      end
    end
  end

  # ====================
  # TERRITORIAL GETTERS TESTS
  # ====================

  describe 'territorial getters' do
    describe '#vote_town' do
      it 'returns symbol' do
        collaboration = create(:collaboration)
        expect(collaboration.vote_town).to eq(:ine_town)
      end
    end

    describe '#town_name' do
      it 'returns symbol' do
        collaboration = create(:collaboration)
        expect(collaboration.town_name).to eq(:town_name)
      end
    end

    describe '#province_name' do
      it 'returns symbol' do
        collaboration = create(:collaboration)
        expect(collaboration.province_name).to eq(:province_name)
      end
    end

    describe '#autonomy_name' do
      it 'returns symbol' do
        collaboration = create(:collaboration)
        expect(collaboration.autonomy_name).to eq(:autonomy_name)
      end
    end

    describe '#island_name' do
      it 'returns symbol' do
        collaboration = create(:collaboration)
        expect(collaboration.island_name).to eq(:island_name)
      end
    end
  end

  # ====================
  # PAYMENT METHODS CONCERN TESTS
  # ====================

  describe 'payment methods concern' do
    describe '#payment_type_name' do
      it 'returns name for credit card' do
        collaboration = create(:collaboration, payment_type: 1)
        expect(collaboration.payment_type_name).not_to be_nil
      end

      it 'returns name for bank payment' do
        collaboration = create(:collaboration, :with_iban)
        expect(collaboration.payment_type_name).not_to be_nil
      end
    end

    describe '#pretty_ccc_full' do
      it 'returns formatted CCC with spaces' do
        collaboration = create(:collaboration, :with_ccc)
        expect(collaboration.pretty_ccc_full).to match(/\d{4} \d{4} \d{2} \d{10}/)
      end

      it 'returns nil without CCC' do
        collaboration = create(:collaboration, payment_type: 1)
        expect(collaboration.pretty_ccc_full).to be_nil
      end
    end

    describe '#calculate_iban' do
      it 'calculates IBAN from CCC' do
        collaboration = create(:collaboration, :with_ccc)
        iban = collaboration.calculate_iban

        expect(iban).to start_with('ES')
        expect(iban.length).to eq(24)
      end

      it 'returns IBAN account when present' do
        collaboration = create(:collaboration, :with_iban)
        iban = collaboration.calculate_iban

        expect(iban).to eq(collaboration.iban_account.gsub(' ', ''))
      end
    end

    describe '#calculate_bic' do
      it 'returns BIC for IBAN' do
        collaboration = create(:collaboration, :with_iban)
        bic = collaboration.calculate_bic

        expect(bic).not_to be_nil
      end
    end

    describe '#iban_valid?' do
      it 'returns true for valid IBAN' do
        collaboration = build(:collaboration, :with_iban)
        expect(collaboration.iban_valid?).to be true
      end

      it 'returns false for invalid IBAN' do
        collaboration = build(:collaboration, payment_type: 3, iban_account: 'INVALID')
        expect(collaboration.iban_valid?).to be false
      end

      it 'returns false for nil IBAN' do
        collaboration = build(:collaboration, payment_type: 3, iban_account: nil)
        expect(collaboration.iban_valid?).to be false
      end
    end
  end

  # ====================
  # CALCULATE_DATE_RANGE_AND_ORDERS
  # ====================

  describe '#calculate_date_range_and_orders' do
    it 'returns hash with date range and orders' do
      collaboration = create(:collaboration, :active)
      result = collaboration.calculate_date_range_and_orders

      expect(result).to be_a(Hash)
      expect(result).to have_key(:start_date)
      expect(result).to have_key(:max_element)
      expect(result).to have_key(:orders)
    end

    it 'limits start date to 6 months ago' do
      collaboration = create(:collaboration, :active)
      collaboration.update_column(:created_at, 2.years.ago)
      result = collaboration.calculate_date_range_and_orders

      expect(result[:start_date]).to be >= (Time.zone.today - 6.months)
    end
  end
end
