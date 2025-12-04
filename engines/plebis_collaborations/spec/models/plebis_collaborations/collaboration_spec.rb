# frozen_string_literal: true

require 'rails_helper'

# Note: The actual model class is Collaboration in app/models, not PlebisCollaborations::Collaboration
# The engine's model file defines the same Collaboration class
RSpec.describe Collaboration, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to have_many(:orders) }
  end

  describe 'validations' do
    let(:user) do
      dni_letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
      number = rand(10_000_000..99_999_999)
      letter = dni_letters[number % 23]
      u = build(:user, document_type: 1, document_vatid: "#{number}#{letter}", born_at: 25.years.ago)
      u.save(validate: false)
      u
    end

    context 'presence validations' do
      it 'validates presence of payment_type' do
        collaboration = build(:collaboration, user: user, payment_type: nil)
        expect(collaboration).not_to be_valid
        expect(collaboration.errors[:payment_type]).to be_present
      end

      it 'validates presence of amount' do
        collaboration = build(:collaboration, user: user, amount: nil)
        expect(collaboration).not_to be_valid
        expect(collaboration.errors[:amount]).to be_present
      end

      it 'validates presence of frequency' do
        collaboration = build(:collaboration, user: user, frequency: nil)
        expect(collaboration).not_to be_valid
        expect(collaboration.errors[:frequency]).to be_present
      end
    end

    context 'acceptance validations' do
      it 'validates terms_of_service acceptance' do
        collaboration = build(:collaboration, user: user, terms_of_service: false)
        expect(collaboration).not_to be_valid
        expect(collaboration.errors[:terms_of_service]).to be_present
      end

      it 'validates minimal_year_old acceptance' do
        collaboration = build(:collaboration, user: user, minimal_year_old: false)
        expect(collaboration).not_to be_valid
        expect(collaboration.errors[:minimal_year_old]).to be_present
      end
    end

    context 'uniqueness validations' do
      it 'validates user_id uniqueness for recurrent collaborations' do
        create(:collaboration, user: user, frequency: 1)
        duplicate = build(:collaboration, user: user, frequency: 1)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:user_id]).to include('has already been taken')
      end

      it 'allows multiple single collaborations per user' do
        create(:collaboration, user: user, frequency: 0)
        duplicate = build(:collaboration, user: user, frequency: 0)
        expect(duplicate).to be_valid
      end

      it 'validates non_user_email uniqueness' do
        collab1 = build(:collaboration, :non_user)
        collab1.save(validate: false)

        collab2 = build(:collaboration, :non_user)
        collab2.non_user_email = collab1.non_user_email
        collab2.skip_queries_validations = false

        expect(collab2).not_to be_valid
        expect(collab2.errors[:non_user_email]).to be_present
      end

      it 'validates non_user_document_vatid uniqueness' do
        collab1 = build(:collaboration, :non_user)
        collab1.save(validate: false)

        collab2 = build(:collaboration, :non_user)
        collab2.non_user_document_vatid = collab1.non_user_document_vatid
        collab2.skip_queries_validations = false

        expect(collab2).not_to be_valid
        expect(collab2.errors[:non_user_document_vatid]).to be_present
      end
    end

    context 'non-user validations' do
      it 'requires non_user fields when user is nil' do
        collaboration = build(:collaboration, user: nil, non_user_email: nil,
                             non_user_document_vatid: nil, non_user_data: nil)
        expect(collaboration).not_to be_valid
        expect(collaboration.errors[:non_user_email]).to be_present
        expect(collaboration.errors[:non_user_document_vatid]).to be_present
        expect(collaboration.errors[:non_user_data]).to be_present
      end

      it 'does not require non_user fields when user is present' do
        collaboration = build(:collaboration, user: user)
        collaboration.non_user_email = nil
        collaboration.non_user_document_vatid = nil
        collaboration.non_user_data = nil
        expect(collaboration).to be_valid
      end
    end

    context 'custom validations' do
      it 'rejects passport users' do
        passport_user = build(:user, document_type: 3, document_vatid: 'AAA123456', born_at: 25.years.ago)
        passport_user.save(validate: false)
        collaboration = build(:collaboration, user: passport_user)
        expect(collaboration).not_to be_valid
        expect(collaboration.errors[:user]).to include('No puedes colaborar si no dispones de DNI o NIE.')
      end

      it 'rejects underage users' do
        dni_letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
        number = rand(10_000_000..99_999_999)
        letter = dni_letters[number % 23]
        young_user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}", born_at: 15.years.ago)
        young_user.save(validate: false)
        collaboration = build(:collaboration, user: young_user)
        expect(collaboration).not_to be_valid
        expect(collaboration.errors[:user]).to include('No puedes colaborar si eres menor de edad.')
      end

      it 'accepts users 18 or older' do
        dni_letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
        number = rand(10_000_000..99_999_999)
        letter = dni_letters[number % 23]
        adult_user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}", born_at: 18.years.ago)
        adult_user.save(validate: false)
        collaboration = build(:collaboration, user: adult_user)
        expect(collaboration).to be_valid
      end

      it 'validates CCC account' do
        collaboration = build(:collaboration, :with_ccc, user: user,
                             ccc_entity: 2100, ccc_office: 1234,
                             ccc_dc: 99, ccc_account: 1234567890)
        expect(collaboration).not_to be_valid
        expect(collaboration.errors[:ccc_dc]).to be_present
      end

      it 'validates IBAN account' do
        collaboration = build(:collaboration, :with_iban, user: user, iban_account: 'INVALID')
        expect(collaboration).not_to be_valid
        expect(collaboration.errors[:iban_account]).to be_present
      end

      it 'accepts valid IBAN account' do
        collaboration = build(:collaboration, :with_iban, user: user)
        expect(collaboration).to be_valid
      end
    end
  end

  describe 'scopes' do
    before do
      @live_cc = create(:collaboration, :active, payment_type: 1, frequency: 1)
      @live_bank = create(:collaboration, :with_iban, :active, frequency: 1)
      @deleted = create(:collaboration, :active, payment_type: 1, frequency: 1, deleted_at: 1.day.ago)
      @single = create(:collaboration, :active, frequency: 0)
      @monthly = create(:collaboration, :active, frequency: 1)
      @quarterly = create(:collaboration, :active, frequency: 3)
      @annual = create(:collaboration, :active, frequency: 12)
      @incomplete = create(:collaboration, :incomplete)
      @error = create(:collaboration, :error)
      @unconfirmed = create(:collaboration, :unconfirmed)
      @warning = create(:collaboration, :warning)
    end

    it '.live returns non-deleted collaborations' do
      expect(described_class.live).to include(@live_cc, @live_bank)
      expect(described_class.live).not_to include(@deleted)
    end

    it '.credit_cards returns credit card collaborations' do
      expect(described_class.credit_cards).to include(@live_cc)
      expect(described_class.credit_cards).not_to include(@live_bank)
    end

    it '.banks returns bank collaborations' do
      expect(described_class.banks).to include(@live_bank)
      expect(described_class.banks).not_to include(@live_cc)
    end

    it '.frequency_single returns single collaborations' do
      expect(described_class.frequency_single).to include(@single)
      expect(described_class.frequency_single).not_to include(@monthly)
    end

    it '.frequency_month returns monthly collaborations' do
      expect(described_class.frequency_month).to include(@monthly)
      expect(described_class.frequency_month).not_to include(@quarterly)
    end

    it '.frequency_quarterly returns quarterly collaborations' do
      expect(described_class.frequency_quarterly).to include(@quarterly)
      expect(described_class.frequency_quarterly).not_to include(@monthly)
    end

    it '.frequency_anual returns annual collaborations' do
      expect(described_class.frequency_anual).to include(@annual)
      expect(described_class.frequency_anual).not_to include(@monthly)
    end

    it '.incomplete returns incomplete collaborations' do
      expect(described_class.incomplete).to include(@incomplete)
      expect(described_class.incomplete).not_to include(@live_cc)
    end

    it '.unconfirmed returns unconfirmed collaborations' do
      expect(described_class.unconfirmed).to include(@unconfirmed)
      expect(described_class.unconfirmed).not_to include(@live_cc)
    end

    it '.active returns active collaborations' do
      expect(described_class.active).to include(@live_cc)
      expect(described_class.active).not_to include(@incomplete)
    end

    it '.warnings returns warning collaborations' do
      expect(described_class.warnings).to include(@warning)
      expect(described_class.warnings).not_to include(@live_cc)
    end

    it '.errors returns error collaborations' do
      expect(described_class.errors).to include(@error)
      expect(described_class.errors).not_to include(@live_cc)
    end
  end

  describe 'callbacks' do
    it 'sets initial status to 0 after creation' do
      collaboration = create(:collaboration)
      expect(collaboration.status).to eq(0)
    end

    it 'uppercases IBAN account before save' do
      collaboration = build(:collaboration, :with_iban, iban_account: 'de89370400440532013000')
      collaboration.save
      expect(collaboration.iban_account).to eq('DE89370400440532013000')
    end

    it 'clears redsys fields for bank payments' do
      collaboration = create(:collaboration, payment_type: 1,
                            redsys_identifier: '123', redsys_expiration: 1.year.from_now)
      collaboration.update(payment_type: 3, iban_account: 'DE89370400440532013000', iban_bic: 'COBADEFFXXX')
      expect(collaboration.redsys_identifier).to be_nil
      expect(collaboration.redsys_expiration).to be_nil
    end
  end

  describe 'payment type methods' do
    let(:cc_collaboration) { create(:collaboration, payment_type: 1) }
    let(:ccc_collaboration) { create(:collaboration, :with_ccc) }
    let(:iban_collaboration) { create(:collaboration, :with_iban) }
    let(:spanish_iban) { create(:collaboration, :with_spanish_iban) }

    describe '#is_credit_card?' do
      it 'returns true for credit card payments' do
        expect(cc_collaboration.is_credit_card?).to be true
      end

      it 'returns false for bank payments' do
        expect(iban_collaboration.is_credit_card?).to be false
      end
    end

    describe '#is_bank?' do
      it 'returns true for bank payments' do
        expect(iban_collaboration.is_bank?).to be true
      end

      it 'returns false for credit card payments' do
        expect(cc_collaboration.is_bank?).to be false
      end
    end

    describe '#is_bank_national?' do
      it 'returns true for Spanish IBAN' do
        expect(spanish_iban.is_bank_national?).to be true
      end

      it 'returns false for international IBAN' do
        expect(iban_collaboration.is_bank_national?).to be false
      end
    end

    describe '#is_bank_international?' do
      it 'returns true for international IBAN' do
        expect(iban_collaboration.is_bank_international?).to be true
      end

      it 'returns false for Spanish IBAN' do
        expect(spanish_iban.is_bank_international?).to be false
      end
    end

    describe '#has_ccc_account?' do
      it 'returns true for CCC payment type' do
        expect(ccc_collaboration.has_ccc_account?).to be true
      end

      it 'returns false for IBAN payment type' do
        expect(iban_collaboration.has_ccc_account?).to be false
      end
    end

    describe '#has_iban_account?' do
      it 'returns true for IBAN payment type' do
        expect(iban_collaboration.has_iban_account?).to be true
      end

      it 'returns false for CCC payment type' do
        expect(ccc_collaboration.has_iban_account?).to be false
      end
    end
  end

  describe 'status methods' do
    describe '#has_payment?' do
      it 'returns true when status is positive' do
        collaboration = create(:collaboration, :active)
        expect(collaboration.has_payment?).to be true
      end

      it 'returns false when status is 0' do
        collaboration = create(:collaboration, :incomplete)
        expect(collaboration.has_payment?).to be false
      end
    end

    describe '#is_payable?' do
      it 'returns true for status 2 (unconfirmed)' do
        collaboration = create(:collaboration, :unconfirmed)
        expect(collaboration.is_payable?).to be true
      end

      it 'returns true for status 3 (OK)' do
        collaboration = create(:collaboration, :active)
        expect(collaboration.is_payable?).to be true
      end

      it 'returns false for status 1 (error)' do
        collaboration = create(:collaboration, :error)
        expect(collaboration.is_payable?).to be false
      end

      it 'returns false for deleted collaborations' do
        collaboration = create(:collaboration, :active, deleted_at: 1.day.ago)
        expect(collaboration.is_payable?).to be false
      end
    end

    describe '#is_active?' do
      it 'returns true for active status' do
        collaboration = create(:collaboration, :active)
        expect(collaboration.is_active?).to be true
      end

      it 'returns false for incomplete status' do
        collaboration = create(:collaboration, :incomplete)
        expect(collaboration.is_active?).to be false
      end

      it 'returns false for deleted collaborations' do
        collaboration = create(:collaboration, :active, deleted_at: 1.day.ago)
        expect(collaboration.is_active?).to be false
      end
    end

    describe '#has_confirmed_payment?' do
      it 'returns true for status 3 (OK)' do
        collaboration = create(:collaboration, :active)
        expect(collaboration.has_confirmed_payment?).to be true
      end

      it 'returns false for status 2 (unconfirmed)' do
        collaboration = create(:collaboration, :unconfirmed)
        expect(collaboration.has_confirmed_payment?).to be false
      end
    end

    describe '#has_warnings?' do
      it 'returns true for warning status' do
        collaboration = create(:collaboration, :warning)
        expect(collaboration.has_warnings?).to be true
      end

      it 'returns false for active status' do
        collaboration = create(:collaboration, :active)
        expect(collaboration.has_warnings?).to be false
      end
    end

    describe '#has_errors?' do
      it 'returns true for error status' do
        collaboration = create(:collaboration, :error)
        expect(collaboration.has_errors?).to be true
      end

      it 'returns false for active status' do
        collaboration = create(:collaboration, :active)
        expect(collaboration.has_errors?).to be false
      end
    end
  end

  describe 'status setters' do
    let(:collaboration) { create(:collaboration, :incomplete) }

    describe '#set_error!' do
      it 'sets status to 1 (error)' do
        collaboration.set_error!('Test error')
        expect(collaboration.reload.status).to eq(1)
      end
    end

    describe '#set_active!' do
      it 'sets status to 2 (unconfirmed) when status < 2' do
        collaboration.set_active!
        expect(collaboration.reload.status).to eq(2)
      end

      it 'does not change status when status >= 2' do
        active_collab = create(:collaboration, :active)
        active_collab.set_active!
        expect(active_collab.reload.status).to eq(3)
      end
    end

    describe '#set_ok!' do
      it 'sets status to 3 (OK)' do
        collaboration.set_ok!
        expect(collaboration.reload.status).to eq(3)
      end
    end

    describe '#set_warning!' do
      it 'sets status to 4 (warning)' do
        collaboration.set_warning!('Test warning')
        expect(collaboration.reload.status).to eq(4)
      end
    end
  end

  describe 'territorial assignment' do
    let(:collaboration) { create(:collaboration) }

    describe '#territorial_assignment=' do
      it 'sets for_town_cc for :town' do
        collaboration.territorial_assignment = :town
        expect(collaboration.for_town_cc).to be true
        expect(collaboration.for_island_cc).to be false
        expect(collaboration.for_autonomy_cc).to be false
      end

      it 'sets for_island_cc for :island' do
        collaboration.territorial_assignment = :island
        expect(collaboration.for_island_cc).to be true
        expect(collaboration.for_town_cc).to be false
        expect(collaboration.for_autonomy_cc).to be false
      end

      it 'sets for_autonomy_cc for :autonomy' do
        collaboration.territorial_assignment = :autonomy
        expect(collaboration.for_autonomy_cc).to be true
        expect(collaboration.for_town_cc).to be false
        expect(collaboration.for_island_cc).to be false
      end
    end

    describe '#territorial_assignment' do
      it 'returns :town when for_town_cc is true' do
        collaboration.update_columns(for_town_cc: true)
        expect(collaboration.territorial_assignment).to eq(:town)
      end

      it 'returns :island when for_island_cc is true' do
        collaboration.update_columns(for_island_cc: true)
        expect(collaboration.territorial_assignment).to eq(:island)
      end

      it 'returns :autonomy when for_autonomy_cc is true' do
        collaboration.update_columns(for_autonomy_cc: true)
        expect(collaboration.territorial_assignment).to eq(:autonomy)
      end

      it 'returns :country when no flags are set' do
        collaboration.update_columns(for_town_cc: false, for_island_cc: false, for_autonomy_cc: false)
        expect(collaboration.territorial_assignment).to eq(:country)
      end
    end
  end

  describe 'name methods' do
    let(:collaboration) { create(:collaboration, :active, frequency: 1) }

    describe '#frequency_name' do
      it 'returns frequency name' do
        expect(collaboration.frequency_name).to eq('Mensual')
      end
    end

    describe '#status_name' do
      it 'returns status name' do
        expect(collaboration.status_name).to eq('OK')
      end
    end
  end

  describe 'CCC methods' do
    let(:collaboration) { create(:collaboration, :with_ccc) }

    describe '#ccc_full' do
      it 'returns formatted CCC' do
        # Factory creates: entity=2100, office=1234, dc=56, account=1234567890
        expect(collaboration.ccc_full).to eq('21001234561234567890')
      end

      it 'returns nil when CCC fields are missing' do
        collaboration.ccc_entity = nil
        expect(collaboration.ccc_full).to be_nil
      end
    end

    describe '#pretty_ccc_full' do
      it 'returns formatted CCC with spaces' do
        expect(collaboration.pretty_ccc_full).to eq('2100 1234 56 1234567890')
      end
    end
  end

  describe 'IBAN methods' do
    let(:ccc_collaboration) { create(:collaboration, :with_ccc) }
    let(:iban_collaboration) { create(:collaboration, :with_iban) }

    describe '#calculate_iban' do
      it 'calculates IBAN from CCC' do
        iban = ccc_collaboration.calculate_iban
        expect(iban).to start_with('ES')
        expect(iban.length).to eq(24)
      end

      it 'returns cleaned IBAN when iban_account is present' do
        iban = iban_collaboration.calculate_iban
        expect(iban).to eq('DE89370400440532013000')
      end
    end

    describe '#iban_valid?' do
      it 'returns true for valid IBAN' do
        expect(iban_collaboration.iban_valid?).to be true
      end

      it 'returns false for invalid IBAN' do
        iban_collaboration.iban_account = 'INVALID'
        expect(iban_collaboration.iban_valid?).to be false
      end

      it 'returns false when iban_account is nil' do
        iban_collaboration.iban_account = nil
        expect(iban_collaboration.iban_valid?).to be false
      end
    end
  end

  describe 'NonUser class' do
    describe '#initialize' do
      it 'sets instance variables from args' do
        non_user = described_class::NonUser.new(
          full_name: 'Test User',
          document_vatid: '12345678Z',
          email: 'test@example.com'
        )
        expect(non_user.full_name).to eq('Test User')
        expect(non_user.document_vatid).to eq('12345678Z')
        expect(non_user.email).to eq('test@example.com')
      end
    end

    describe '#to_s' do
      it 'returns formatted string' do
        non_user = described_class::NonUser.new(
          full_name: 'Test User',
          document_vatid: '12345678Z',
          email: 'test@example.com'
        )
        expect(non_user.to_s).to eq('Test User (12345678Z - test@example.com)')
      end
    end

    describe '#still_militant?' do
      it 'returns false' do
        non_user = described_class::NonUser.new(full_name: 'Test')
        expect(non_user.still_militant?).to be false
      end
    end
  end

  describe 'non-user methods' do
    let(:collaboration) { build(:collaboration, :non_user) }

    describe '#parse_non_user' do
      it 'parses non_user_data YAML' do
        collaboration.save(validate: false)
        collaboration.send(:parse_non_user)
        # Note: NonUser class is defined in main Collaboration model, not namespaced
        expect(collaboration.instance_variable_get(:@non_user)).to be_a(Collaboration::NonUser)
      end
    end

    describe '#format_non_user' do
      it 'serializes @non_user to YAML' do
        collaboration.save(validate: false)
        expect(collaboration.non_user_data).to be_present
        expect(collaboration.non_user_email).to be_present
        expect(collaboration.non_user_document_vatid).to be_present
      end
    end

    describe '#set_non_user' do
      it 'creates NonUser object and formats it' do
        info = {
          full_name: 'Test User',
          document_vatid: '12345678Z',
          email: 'test@example.com'
        }
        collaboration.set_non_user(info)
        expect(collaboration.get_non_user).to be_a(Collaboration::NonUser)
        expect(collaboration.non_user_email).to eq('test@example.com')
      end

      it 'clears non_user when nil is passed' do
        collaboration.save(validate: false)
        collaboration.set_non_user(nil)
        expect(collaboration.get_non_user).to be_nil
        expect(collaboration.non_user_data).to be_nil
      end
    end

    describe '#get_user' do
      it 'returns user when present' do
        user_collab = create(:collaboration)
        expect(user_collab.get_user).to eq(user_collab.user)
      end

      it 'returns @non_user when user is nil' do
        collaboration.save(validate: false)
        expect(collaboration.get_user).to be_a(Collaboration::NonUser)
      end
    end
  end

  describe '#payment_identifier' do
    it 'returns redsys_identifier for credit cards' do
      collaboration = create(:collaboration, payment_type: 1, redsys_identifier: '123456')
      expect(collaboration.payment_identifier).to eq('123456')
    end

    it 'returns IBAN/BIC for IBAN accounts' do
      collaboration = create(:collaboration, :with_iban)
      expect(collaboration.payment_identifier).to include('/')
    end

    it 'returns calculated IBAN/BIC for CCC accounts' do
      collaboration = create(:collaboration, :with_ccc)
      identifier = collaboration.payment_identifier
      expect(identifier).to include('/')
      expect(identifier).to start_with('ES')
    end
  end

  describe '#payment_processed!' do
    let(:collaboration) { create(:collaboration, :unconfirmed) }
    let(:order) { instance_double('Order') }

    context 'when order is paid' do
      before do
        allow(order).to receive(:is_paid?).and_return(true)
        allow(order).to receive(:has_warnings?).and_return(false)
        allow(order).to receive(:first).and_return(false)
      end

      it 'sets status to OK' do
        collaboration.payment_processed!(order)
        expect(collaboration.reload.status).to eq(3)
      end

      context 'with warnings' do
        before do
          allow(order).to receive(:has_warnings?).and_return(true)
        end

        it 'sets status to warning' do
          collaboration.payment_processed!(order)
          expect(collaboration.reload.status).to eq(4)
        end
      end

      context 'first credit card order' do
        before do
          collaboration.update(payment_type: 1)
          allow(order).to receive(:first).and_return(true)
          allow(order).to receive(:payment_identifier).and_return('NEW_ID')
          allow(order).to receive(:redsys_expiration).and_return(1.year.from_now)
        end

        it 'updates redsys credentials' do
          collaboration.payment_processed!(order)
          expect(collaboration.reload.redsys_identifier).to eq('NEW_ID')
        end
      end
    end

    context 'when order is not paid and has payment' do
      before do
        allow(order).to receive(:is_paid?).and_return(false)
        collaboration.update_column(:status, 2)
      end

      it 'sets status to error' do
        collaboration.payment_processed!(order)
        expect(collaboration.reload.status).to eq(1)
      end
    end
  end

  describe '#processed_order!' do
    let(:collaboration) { create(:collaboration, :unconfirmed) }

    before do
      collaboration.update_column(:status, 2)
    end

    context 'with error flag' do
      it 'sets status to error' do
        # Mock the mailer to avoid missing secrets
        allow(PlebisCollaborations::CollaborationsMailer).to receive(:order_returned_user)
          .and_return(double(deliver_now: true))

        collaboration.processed_order!(true, false, false)
        expect(collaboration.reload.status).to eq(1)
      end
    end

    context 'with warning flag' do
      it 'sets status to warning' do
        # Mock the mailer to avoid missing secrets
        allow(PlebisCollaborations::CollaborationsMailer).to receive(:order_returned_user)
          .and_return(double(deliver_now: true))

        collaboration.processed_order!(false, true, false)
        expect(collaboration.reload.status).to eq(4)
      end
    end

    context 'with MAX_RETURNED_ORDERS' do
      before do
        # Create returned orders
        described_class::MAX_RETURNED_ORDERS.times do
          create(:order, :devuelta, parent: collaboration, user: collaboration.user)
        end
      end

      it 'sends suspended email for non-militant' do
        allow(collaboration).to receive(:get_user).and_return(collaboration.user)
        allow(collaboration.user).to receive(:militant?).and_return(false)

        expect(PlebisCollaborations::CollaborationsMailer).to receive(:collaboration_suspended_user)
          .with(collaboration).and_return(double(deliver_now: true))

        collaboration.processed_order!(false, false, false)
      end
    end
  end

  describe '#must_have_order?' do
    let(:collaboration) { create(:collaboration, :active, frequency: 1) }

    context 'with no first order' do
      it 'returns true for current month' do
        expect(collaboration.must_have_order?(Time.zone.today)).to be true
      end

      it 'returns false for past months' do
        expect(collaboration.must_have_order?(2.months.ago)).to be false
      end
    end

    context 'with single collaboration' do
      let(:single_collaboration) { create(:collaboration, :active, frequency: 0) }

      it 'returns true for first order month' do
        expect(single_collaboration.must_have_order?(Time.zone.today)).to be true
      end

      it 'returns false for subsequent months' do
        create(:order, :paid, :first_order, parent: single_collaboration, user: single_collaboration.user)
        expect(single_collaboration.must_have_order?(1.month.from_now)).to be false
      end
    end

    context 'with recurrent collaboration' do
      before do
        create(:order, :paid, :first_order, parent: collaboration, user: collaboration.user,
               payable_at: 2.months.ago)
      end

      it 'returns true for months matching frequency' do
        expect(collaboration.must_have_order?(Time.zone.today)).to be true
      end
    end
  end

  describe '#create_order' do
    let(:collaboration) { create(:collaboration, :active, amount: 1000, frequency: 1) }

    it 'creates an order with correct attributes' do
      order = collaboration.create_order(Time.zone.today, false, false)
      expect(order).to be_a(Order)
      expect(order.amount).to eq(1000)
      expect(order.parent).to eq(collaboration)
    end

    it 'sets first flag when maybe_first is true and no confirmed payment and no first order' do
      collaboration.update_column(:status, 0) # Ensure no confirmed payment
      order = collaboration.create_order(Time.zone.today, true, false)
      expect(order.first).to be true
    end

    it 'calculates amount based on frequency' do
      quarterly = create(:collaboration, :active, amount: 1000, frequency: 3)
      order = quarterly.create_order(Time.zone.today, false, false)
      expect(order.amount).to eq(3000)
    end

    it 'sets payable_at to payment_day for non-first bank orders' do
      # Stub the payment_day method
      allow(Order).to receive(:payment_day).and_return(15)
      collaboration.update(payment_type: 3) # Bank payment
      order = collaboration.create_order(Time.zone.today, false, false)
      expect(order.payable_at.day).to eq(15)
    end

    it 'generates reference text' do
      order = collaboration.create_order(Time.zone.today, false, false)
      expect(order.reference).to be_present
      expect(order.reference).to include('Colaboración')
    end
  end

  describe '#get_orders' do
    let(:collaboration) { create(:collaboration, :active, frequency: 1) }

    before do
      create(:order, parent: collaboration, user: collaboration.user,
             payable_at: 1.month.ago, status: 2, payed_at: 1.month.ago)
    end

    it 'returns existing orders for date range' do
      orders = collaboration.get_orders(2.months.ago, Time.zone.today, false)
      expect(orders).not_to be_empty
    end

    it 'creates new orders when create_orders is true' do
      orders = collaboration.get_orders(Time.zone.today, 2.months.from_now, true)
      expect(orders.flatten.any? { |o| o.new_record? }).to be true
    end

    it 'excludes orders with errors' do
      create(:order, :error, parent: collaboration, user: collaboration.user, payable_at: Time.zone.today)
      orders = collaboration.get_orders(Time.zone.today, Time.zone.today, false)
      expect(orders.flatten.any?(&:has_errors?)).to be false
    end
  end

  describe '#charge!' do
    let(:collaboration) { create(:collaboration, :active) }

    it 'returns nil when not payable' do
      collaboration.update_column(:status, 0)
      expect(collaboration.charge!).to be_nil
    end

    context 'with credit card' do
      before do
        collaboration.update(payment_type: 1)
      end

      it 'sends redsys request for chargeable order' do
        allow(collaboration).to receive(:get_orders).and_return([[double(is_chargeable?: true, redsys_send_request: true)]])
        expect { collaboration.charge! }.not_to raise_error
      end
    end
  end

  describe '#fix_status!' do
    let(:collaboration) { create(:collaboration, :active) }

    it 'sets error status when invalid' do
      collaboration.payment_type = nil
      result = collaboration.fix_status!
      expect(result).to be true
      expect(collaboration.reload.status).to eq(1)
    end

    it 'returns false when valid' do
      result = collaboration.fix_status!
      expect(result).to be false
    end
  end

  describe 'class methods' do
    describe '.bank_filename' do
      it 'returns filename with date' do
        date = Date.new(2024, 1, 1)
        filename = described_class.bank_filename(date, false)
        expect(filename).to eq('plebisbrand.orders.2024.1')
      end

      it 'returns full path when requested' do
        date = Date.new(2024, 1, 1)
        filename = described_class.bank_filename(date, true)
        expect(filename).to include('db/plebisbrand')
      end
    end

    describe '.available_payment_types' do
      let(:collaboration) { create(:collaboration, :with_iban) }

      it 'returns available payment types' do
        types = described_class.available_payment_types(collaboration)
        expect(types.map(&:last)).to include(3)
      end
    end

    describe '.available_frequencies_for_user' do
      let(:user) { create(:user) }

      it 'returns only single when force_single is true' do
        freqs = described_class.available_frequencies_for_user(user, force_single: true)
        expect(freqs).to be_an(Array)
        expect(freqs.map(&:last)).to eq([0])
      end

      it 'excludes single when user has recurrent collaboration' do
        allow(user).to receive(:recurrent_collaboration).and_return(true)
        freqs = described_class.available_frequencies_for_user(user)
        expect(freqs.map(&:last)).not_to include(0)
      end

      it 'returns all frequencies for new users' do
        freqs = described_class.available_frequencies_for_user(user)
        expect(freqs.map(&:last)).to include(0, 1, 3, 12)
      end
    end
  end

  describe '#calculate_date_range_and_orders' do
    let(:collaboration) { create(:collaboration, :active, frequency: 1, created_at: 1.year.ago) }

    it 'returns hash with start_date, max_element, and orders' do
      result = collaboration.calculate_date_range_and_orders
      expect(result).to have_key(:start_date)
      expect(result).to have_key(:max_element)
      expect(result).to have_key(:orders)
    end

    it 'limits start_date to 6 months ago' do
      result = collaboration.calculate_date_range_and_orders
      expect(result[:start_date]).to be >= (Time.zone.today - 6.months)
    end
  end

  describe 'constants' do
    it 'has AMOUNTS constant' do
      expect(described_class::AMOUNTS).to be_a(Hash)
      expect(described_class::AMOUNTS['10 €']).to eq(1000)
    end

    it 'has FREQUENCIES constant' do
      expect(described_class::FREQUENCIES).to be_a(Hash)
      expect(described_class::FREQUENCIES['Mensual']).to eq(1)
    end

    it 'has STATUS constant' do
      expect(described_class::STATUS).to be_a(Hash)
      expect(described_class::STATUS['OK']).to eq(3)
    end
  end
end
