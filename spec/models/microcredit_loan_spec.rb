# frozen_string_literal: true

require 'rails_helper'

# RAILS 7.2 FIX: Use namespaced class to match factory and model class
RSpec.describe PlebisMicrocredit::MicrocreditLoan, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid microcredit_loan with user' do
      loan = build(:microcredit_loan)
      expect(loan).to be_valid, "Factory should create a valid microcredit_loan. Errors: #{loan.errors.full_messages.join(', ')}"
    end

    it 'creates valid microcredit_loan without user' do
      loan = build(:microcredit_loan, :without_user)
      expect(loan).to be_valid, "Factory should create a valid microcredit_loan without user. Errors: #{loan.errors.full_messages.join(', ')}"
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to microcredit' do
      loan = create(:microcredit_loan)
      expect(loan).to respond_to(:microcredit)
      # RAILS 7.2 FIX: Use namespaced class since engines models don't inherit from aliases
      # Microcredit < PlebisMicrocredit::Microcredit (not the reverse)
      expect(loan.microcredit).to be_a(PlebisMicrocredit::Microcredit)
    end

    it 'belongs to user' do
      loan = create(:microcredit_loan)
      expect(loan).to respond_to(:user)
      expect(loan.user).to be_a(User)
    end

    it 'belongs to microcredit_option' do
      loan = create(:microcredit_loan)
      expect(loan).to respond_to(:microcredit_option)
      # RAILS 7.2 FIX: Use namespaced class
      expect(loan.microcredit_option).to be_a(PlebisMicrocredit::MicrocreditOption)
    end

    it 'belongs to transferred_to' do
      loan1 = create(:microcredit_loan)
      loan2 = create(:microcredit_loan, transferred_to: loan1)
      expect(loan2.transferred_to).to eq(loan1)
    end

    it 'has many original_loans' do
      loan1 = create(:microcredit_loan)
      loan2 = create(:microcredit_loan, transferred_to: loan1)
      expect(loan1.original_loans).to include(loan2)
    end

    it 'loads user with soft delete' do
      loan = create(:microcredit_loan)
      user = loan.user
      user.destroy

      loan.reload
      expect(loan.user).not_to be_nil
      expect(user.deleted?).to be true
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    context 'required fields' do
      it 'requires amount' do
        loan = build(:microcredit_loan, amount: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:amount]).to include("no puede estar en blanco")
      end

      it 'requires terms_of_service acceptance' do
        loan = build(:microcredit_loan, terms_of_service: false)
        expect(loan).not_to be_valid
        expect(loan.errors[:terms_of_service]).to include("debe ser aceptado")
      end

      it 'requires minimal_year_old acceptance' do
        loan = build(:microcredit_loan, minimal_year_old: false)
        expect(loan).not_to be_valid
        expect(loan.errors[:minimal_year_old]).to include("debe ser aceptado")
      end

      it 'requires iban_account on create' do
        loan = build(:microcredit_loan, iban_account: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:iban_account]).to include("no puede estar en blanco")
      end

      it 'requires iban_bic on create if international' do
        loan = build(:microcredit_loan, :international_iban, iban_bic: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:iban_bic]).to include("no puede estar en blanco")
      end

      it 'does not require iban_bic for Spanish IBAN' do
        loan = build(:microcredit_loan, iban_account: "ES9121000418450200051332", iban_bic: nil)
        # BIC is calculated automatically for Spanish IBANs
        expect(loan).to be_valid, "Spanish IBAN should be valid without explicit BIC. Errors: #{loan.errors.full_messages.join(', ')}"
      end
    end

    context 'loans without user' do
      it 'requires document_vatid if no user' do
        loan = build(:microcredit_loan, :without_user, document_vatid: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:document_vatid]).to include("is invalid")
      end

      it 'validates Spanish ID format for document_vatid if no user' do
        loan = build(:microcredit_loan, :without_user, document_vatid: "12345678A")
        expect(loan).not_to be_valid, "Invalid DNI check digit should be rejected"
      end

      it 'accepts valid Spanish DNI if no user' do
        loan = build(:microcredit_loan, :without_user, document_vatid: "12345678Z")
        expect(loan).to be_valid, "Valid DNI should be accepted. Errors: #{loan.errors.full_messages.join(', ')}"
      end

      it 'requires first_name if no user' do
        loan = build(:microcredit_loan, :without_user, first_name: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:first_name]).to include("no puede estar en blanco")
      end

      it 'requires last_name if no user' do
        loan = build(:microcredit_loan, :without_user, last_name: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:last_name]).to include("no puede estar en blanco")
      end

      it 'requires email if no user' do
        loan = build(:microcredit_loan, :without_user, email: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:email]).to include("no puede estar en blanco")
      end

      it 'validates email format if no user' do
        microcredit = create(:microcredit, :active)
        microcredit_option = create(:microcredit_option, microcredit: microcredit)
        loan = build(:microcredit_loan, :without_user, microcredit: microcredit, microcredit_option: microcredit_option, email: "test@")
        expect(loan).not_to be_valid
        expect(loan.errors[:email]).to include("debe acabar con una letra")
      end

      it 'requires address if no user' do
        loan = build(:microcredit_loan, :without_user, address: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:address]).to include("no puede estar en blanco")
      end

      it 'requires postal_code if no user' do
        loan = build(:microcredit_loan, :without_user, postal_code: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:postal_code]).to include("no puede estar en blanco")
      end

      it 'requires town if no user' do
        loan = build(:microcredit_loan, :without_user, town: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:town]).to include("no puede estar en blanco")
      end

      it 'requires province if no user' do
        loan = build(:microcredit_loan, :without_user, province: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:province]).to include("no puede estar en blanco")
      end

      it 'requires country if no user' do
        loan = build(:microcredit_loan, :without_user, country: nil)
        expect(loan).not_to be_valid
        expect(loan.errors[:country]).to include("no puede estar en blanco")
      end
    end

    context 'custom validations' do
      it 'does not accept passport users' do
        user = create(:user, document_type: 3) # Passport
        loan = build(:microcredit_loan, user: user)
        expect(loan).not_to be_valid
        expect(loan.errors[:user]).to include("No puedes suscribir un microcrédito si no dispones de DNI o NIE.")
      end

      it 'does not accept users under 18' do
        user = create(:user, :with_dni)
        user.update_column(:born_at, 17.years.ago)
        loan = build(:microcredit_loan, user: user)
        expect(loan).not_to be_valid
        expect(loan.errors[:user]).to include("No puedes suscribir un microcrédito si eres menor de edad.")
      end

      it 'accepts users 18 or older' do
        user = create(:user, :with_dni, born_at: 18.years.ago)
        loan = build(:microcredit_loan, user: user)
        expect(loan).to be_valid, "User 18 or older should be valid. Errors: #{loan.errors.full_messages.join(', ')}"
      end

      it 'validates IBAN format' do
        loan = build(:microcredit_loan, :invalid_iban)
        expect(loan).not_to be_valid
        expect(loan.errors[:iban_account]).to include("Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala.")
      end

      it 'does not accept brand\'s own account number' do
        microcredit = create(:microcredit, account_number: "ES9121000418450200051332")
        loan = build(:microcredit_loan, microcredit: microcredit, iban_account: "ES9121000418450200051332")
        expect(loan).not_to be_valid
        expect(loan.errors[:iban_account].first).to match(/no la de/)
      end

      it 'accepts different account number from brand' do
        microcredit = create(:microcredit, account_number: "ES1234567890123456789012")
        loan = build(:microcredit_loan, microcredit: microcredit, iban_account: "ES9121000418450200051332")
        expect(loan).to be_valid, "Different account should be valid. Errors: #{loan.errors.full_messages.join(', ')}"
      end

      it 'rejects loan if amount not available' do
        microcredit = create(:microcredit, :active, limits: "100€: 1")
        microcredit_option = create(:microcredit_option, microcredit: microcredit)

        # Create first loan to fill the limit
        first_loan = create(:microcredit_loan, :without_user, microcredit: microcredit, microcredit_option: microcredit_option, amount: 100)
        first_loan.update_columns(confirmed_at: Time.current, counted_at: Time.current)

        # Clear cache to pick up the new loan
        microcredit.clear_cache

        # Try to create second loan
        loan = build(:microcredit_loan, :without_user, microcredit: microcredit, microcredit_option: microcredit_option, amount: 100)
        expect(loan).not_to be_valid
        expect(loan.errors[:amount]).to include("Lamentablemente, ya no quedan préstamos por esa cantidad.")
      end

      it 'rejects loan if microcredit is not active' do
        microcredit = create(:microcredit, :finished)
        loan = build(:microcredit_loan, microcredit: microcredit)
        expect(loan).not_to be_valid
        expect(loan.errors[:microcredit]).to include("La campaña de microcréditos no está activa en este momento.")
      end

      it 'rejects if exceeds max loans per IP' do
        microcredit = create(:microcredit, :active)
        microcredit_option = create(:microcredit_option, microcredit: microcredit)
        test_ip = "192.168.1.100"

        # Create max loans for this IP using build + save(validate: false) + update_columns
        51.times do |i|
          user = create(:user, :with_dni)
          loan = build(:microcredit_loan, microcredit: microcredit, microcredit_option: microcredit_option, user: user, ip: nil)
          loan.save(validate: false)
          loan.update_columns(ip: test_ip, confirmed_at: Time.current)
        end

        # Try to create one more
        loan = build(:microcredit_loan, microcredit: microcredit, microcredit_option: microcredit_option, ip: test_ip)
        expect(loan).not_to be_valid
        expect(loan.errors[:user]).to include("Lamentablemente, no es posible suscribir este microcrédito.")
      end

      it 'rejects if exceeds max loans per user' do
        microcredit = create(:microcredit, :active)
        test_document = "12345678Z"

        # Create max loans for this document using update_columns to bypass validations
        31.times do
          created_loan = create(:microcredit_loan, :without_user, microcredit: microcredit)
          created_loan.update_columns(document_vatid: test_document, confirmed_at: Time.current)
        end

        # Try to create one more
        loan = build(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: test_document)
        expect(loan).not_to be_valid
        expect(loan.errors[:user]).to include("Lamentablemente, no es posible suscribir este microcrédito.")
      end

      it 'rejects if loan amount sum exceeds max' do
        microcredit = create(:microcredit, :active, limits: "5000€: 10")

        # Create loans totaling 9000
        2.times do
          create(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "12345678Z", amount: 5000, confirmed_at: Time.current)
        end

        # Try to create loan for 2000 (would exceed 10000 limit)
        loan = build(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "12345678Z", amount: 2000)
        expect(loan).not_to be_valid
        expect(loan.errors[:user]).to include("Lamentablemente, no es posible suscribir este microcrédito.")
      end

      it 'validates microcredit_option is leaf node' do
        parent_option = create(:microcredit_option)
        child_option = create(:microcredit_option, parent: parent_option, microcredit: parent_option.microcredit)

        loan = build(:microcredit_loan, microcredit: parent_option.microcredit, microcredit_option: parent_option)
        expect(loan).not_to be_valid
        expect(loan.errors[:microcredit_option_id]).to include("Debes elegir algún elemento")
      end
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.not_counted' do
      it 'returns loans without counted_at' do
        counted = create(:microcredit_loan, :counted)
        not_counted = create(:microcredit_loan)

        result = described_class.not_counted
        expect(result).to include(not_counted)
        expect(result).not_to include(counted)
      end
    end

    describe '.counted' do
      it 'returns loans with counted_at' do
        counted = create(:microcredit_loan, :counted)
        not_counted = create(:microcredit_loan)

        result = described_class.counted
        expect(result).to include(counted)
        expect(result).not_to include(not_counted)
      end
    end

    describe '.not_confirmed' do
      it 'returns loans without confirmed_at' do
        confirmed = create(:microcredit_loan, :confirmed)
        not_confirmed = create(:microcredit_loan)

        result = described_class.not_confirmed
        expect(result).to include(not_confirmed)
        expect(result).not_to include(confirmed)
      end
    end

    describe '.confirmed' do
      it 'returns loans with confirmed_at' do
        confirmed = create(:microcredit_loan, :confirmed)
        not_confirmed = create(:microcredit_loan)

        result = described_class.confirmed
        expect(result).to include(confirmed)
        expect(result).not_to include(not_confirmed)
      end
    end

    describe '.not_discarded' do
      it 'returns loans without discarded_at' do
        discarded = create(:microcredit_loan, :discarded)
        not_discarded = create(:microcredit_loan)

        result = described_class.not_discarded
        expect(result).to include(not_discarded)
        expect(result).not_to include(discarded)
      end
    end

    describe '.discarded' do
      it 'returns loans with discarded_at' do
        discarded = create(:microcredit_loan, :discarded)
        not_discarded = create(:microcredit_loan)

        result = described_class.discarded
        expect(result).to include(discarded)
        expect(result).not_to include(not_discarded)
      end
    end

    describe '.not_returned' do
      it 'returns confirmed loans without returned_at' do
        returned = create(:microcredit_loan, :returned)
        not_returned = create(:microcredit_loan, :confirmed)
        unconfirmed = create(:microcredit_loan)

        result = described_class.not_returned
        expect(result).to include(not_returned)
        expect(result).not_to include(returned)
        expect(result).not_to include(unconfirmed)
      end
    end

    describe '.returned' do
      it 'returns loans with returned_at' do
        returned = create(:microcredit_loan, :returned)
        not_returned = create(:microcredit_loan, :confirmed)

        result = described_class.returned
        expect(result).to include(returned)
        expect(result).not_to include(not_returned)
      end
    end

    describe '.transferred' do
      it 'returns loans with transferred_to_id' do
        loan1 = create(:microcredit_loan, :confirmed)
        loan2 = create(:microcredit_loan, :confirmed, transferred_to: loan1)

        result = described_class.transferred
        expect(result).to include(loan2)
        expect(result).not_to include(loan1)
      end
    end

    describe '.ignore_discarded' do
      it 'returns non-discarded or counted loans' do
        discarded_not_counted = create(:microcredit_loan, :discarded)
        discarded_counted = create(:microcredit_loan, :discarded, :counted)
        not_discarded = create(:microcredit_loan)

        result = described_class.ignore_discarded
        expect(result).to include(not_discarded)
        expect(result).to include(discarded_counted)
        expect(result).not_to include(discarded_not_counted)
      end
    end
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  describe 'callbacks' do
    it 'sets user data from user on initialization' do
      user = create(:user, first_name: "John", last_name: "Doe")
      loan = described_class.new(user: user)

      expect(loan.first_name).to eq("John")
      expect(loan.last_name).to eq("Doe")
      expect(loan.email).to eq(user.email)
      expect(loan.document_vatid).to eq(user.document_vatid)
    end

    it 'sets country to ES by default if no user' do
      loan = described_class.new
      expect(loan.country).to eq("ES")
    end

    it 'upcases iban_account before save' do
      loan = create(:microcredit_loan, iban_account: "es9121000418450200051332")
      expect(loan.iban_account).to eq("ES9121000418450200051332")
    end

    it 'saves user_data as YAML when no user' do
      loan = create(:microcredit_loan, :without_user, first_name: "Juan", last_name: "García")

      expect(loan.user_data).not_to be_nil
      data = YAML.unsafe_load(loan.user_data)
      expect(data[:first_name]).to eq("Juan")
      expect(data[:last_name]).to eq("García")
    end

    it 'sets user_data to nil when user exists' do
      loan = create(:microcredit_loan)
      expect(loan.user_data).to be_nil
    end

    it 'upcases and strips document_vatid before save' do
      loan = create(:microcredit_loan, :without_user, document_vatid: "12345678z")
      expect(loan.document_vatid).to eq("12345678Z")
    end

    it 'calculates BIC for Spanish IBAN before save' do
      loan = create(:microcredit_loan, iban_account: "ES9121000418450200051332", iban_bic: nil)
      expect(loan.iban_bic).not_to be_nil
      expect(loan.iban_bic).to eq("CAIXESBBXXX")
    end
  end

  # ====================
  # PARANOIA (SOFT DELETE) TESTS
  # ====================

  describe 'soft delete (paranoia)' do
    it 'soft deletes loan' do
      loan = create(:microcredit_loan)
      loan.destroy

      expect(loan.deleted_at).not_to be_nil
      expect(described_class.exists?(loan.id)).to be false
      expect(described_class.with_deleted.exists?(loan.id)).to be true
    end

    it 'restores soft deleted loan' do
      loan = create(:microcredit_loan)
      loan.destroy
      loan.restore

      expect(loan.deleted_at).to be_nil
      expect(described_class.exists?(loan.id)).to be true
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#set_user_data' do
      it 'sets virtual attributes from hash' do
        loan = described_class.new
        user_data = {
          first_name: "Maria",
          last_name: "Lopez",
          email: "maria@example.com",
          address: "Calle Test 1",
          postal_code: "28001",
          town: "Madrid",
          province: "Madrid",
          country: "ES"
        }

        loan.set_user_data(user_data)

        expect(loan.first_name).to eq("Maria")
        expect(loan.last_name).to eq("Lopez")
        expect(loan.email).to eq("maria@example.com")
        expect(loan.address).to eq("Calle Test 1")
      end
    end

    describe '#country_name' do
      it 'returns country name from Carmen' do
        loan = build(:microcredit_loan, :without_user, country: "ES")
        expect(loan.country_name).to eq("España")
      end

      it 'returns country code if not found' do
        loan = build(:microcredit_loan, :without_user, country: "XX")
        expect(loan.country_name).to eq("XX")
      end
    end

    describe '#province_name' do
      it 'returns province name from Carmen' do
        loan = build(:microcredit_loan, :without_user, country: "ES", province: "M")
        expect(loan.province_name).to eq("Madrid")
      end

      it 'returns province code if not found' do
        loan = build(:microcredit_loan, :without_user, province: "XX")
        expect(loan.province_name).to eq("XX")
      end
    end

    describe '#town_name' do
      it 'returns town code as fallback' do
        loan = build(:microcredit_loan, :without_user, town: "Madrid")
        expect(loan.town_name).to eq("Madrid")
      end
    end

    describe '#has_not_user?' do
      it 'returns true when no user' do
        loan = build(:microcredit_loan, :without_user)
        expect(loan.has_not_user?).to be true
      end

      it 'returns false when user exists' do
        loan = build(:microcredit_loan)
        expect(loan.has_not_user?).to be false
      end
    end

    describe '#is_bank_international?' do
      it 'returns true for non-Spanish IBAN' do
        loan = build(:microcredit_loan, :international_iban)
        expect(loan.is_bank_international?).to be true
      end

      it 'returns false for Spanish IBAN' do
        loan = build(:microcredit_loan, iban_account: "ES9121000418450200051332")
        expect(loan.is_bank_international?).to be false
      end
    end

    describe '#iban_valid?' do
      it 'validates correct Spanish IBAN' do
        loan = build(:microcredit_loan, iban_account: "ES9121000418450200051332")
        expect(loan.iban_valid?).to be true
      end

      it 'rejects incorrect IBAN' do
        loan = build(:microcredit_loan, iban_account: "ES9999999999999999999999")
        expect(loan.iban_valid?).to be false
      end
    end

    describe '#calculate_bic' do
      it 'returns BIC for Spanish bank code' do
        loan = build(:microcredit_loan, iban_account: "ES9121000418450200051332")
        bic = loan.calculate_bic
        expect(bic).not_to be_nil
        expect(bic).to eq("CAIXESBBXXX")
      end
    end

    describe '#possible_user' do
      it 'finds user by document_vatid' do
        user = create(:user, document_type: 1, document_vatid: "12345678Z")
        loan = build(:microcredit_loan, :without_user, document_vatid: "12345678Z")

        expect(loan.possible_user).to eq(user)
      end

      it 'returns nil if no matching user' do
        loan = build(:microcredit_loan, :without_user, document_vatid: "87654321X")
        expect(loan.possible_user).to be_nil
      end
    end

    describe '#unique_hash' do
      it 'generates consistent hash' do
        loan = create(:microcredit_loan, :without_user, document_vatid: "12345678Z")
        hash1 = loan.unique_hash
        hash2 = loan.unique_hash

        expect(hash1).to eq(hash2)
        expect(hash1.length).to eq(64) # SHA256 hex digest length
      end
    end

    describe '#renewable?' do
      it 'returns true for confirmed non-returned loan with renewable microcredit' do
        microcredit = create(:microcredit, :active)
        # Mock renewable? method
        microcredit.define_singleton_method(:renewable?) { true }

        loan = create(:microcredit_loan, microcredit: microcredit, confirmed_at: Time.current, returned_at: nil)
        expect(loan.renewable?).to be true
      end

      it 'returns false if not confirmed' do
        microcredit = create(:microcredit, :active)
        loan = create(:microcredit_loan, microcredit: microcredit, confirmed_at: nil)

        expect(loan.renewable?).to be false
      end

      it 'returns false if already returned' do
        microcredit = create(:microcredit, :active)
        loan = create(:microcredit_loan, :returned, microcredit: microcredit)

        expect(loan.renewable?).to be false
      end
    end

    describe '#confirm!' do
      it 'sets confirmed_at and clears discarded_at' do
        loan = create(:microcredit_loan, confirmed_at: nil, discarded_at: Time.current)

        result = loan.confirm!
        expect(result).to be true
        expect(loan.confirmed_at).not_to be_nil
        expect(loan.discarded_at).to be_nil
      end

      it 'returns false if already confirmed' do
        loan = create(:microcredit_loan, :confirmed)

        result = loan.confirm!
        expect(result).to be false
      end
    end

    describe '#unconfirm!' do
      it 'clears confirmed_at' do
        loan = create(:microcredit_loan, :confirmed)

        result = loan.unconfirm!
        expect(result).to be true
        expect(loan.confirmed_at).to be_nil
      end

      it 'returns false if not confirmed' do
        loan = create(:microcredit_loan, confirmed_at: nil)

        result = loan.unconfirm!
        expect(result).to be false
      end
    end

    describe '#discard!' do
      it 'sets discarded_at and clears confirmed_at' do
        loan = create(:microcredit_loan, :confirmed)

        result = loan.discard!
        expect(result).to be true
        expect(loan.discarded_at).not_to be_nil
        expect(loan.confirmed_at).to be_nil
      end

      it 'returns false if already discarded' do
        loan = create(:microcredit_loan, :discarded)

        result = loan.discard!
        expect(result).to be false
      end
    end

    describe '#return!' do
      it 'sets returned_at for confirmed loan' do
        loan = create(:microcredit_loan, :confirmed, returned_at: nil)

        result = loan.return!
        expect(result).to be true
        expect(loan.returned_at).not_to be_nil
      end

      it 'returns false if not confirmed' do
        loan = create(:microcredit_loan, confirmed_at: nil)

        result = loan.return!
        expect(result).to be false
      end

      it 'returns false if already returned' do
        loan = create(:microcredit_loan, :returned)

        result = loan.return!
        expect(result).to be false
      end
    end

    describe '#renew!' do
      it 'creates new loan and marks original as returned' do
        old_microcredit = create(:microcredit, :finished)
        new_microcredit = create(:microcredit, :active)
        loan = create(:microcredit_loan, :confirmed, microcredit: old_microcredit)

        loan.renew!(new_microcredit)
        loan.reload

        expect(loan.returned_at).not_to be_nil
        expect(loan.transferred_to).not_to be_nil
        expect(loan.transferred_to.microcredit.id).to eq(new_microcredit.id)
        expect(loan.transferred_to.counted_at).not_to be_nil
      end
    end
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  describe 'class methods' do
    describe '.get_loans_stats' do
      it 'returns correct statistics' do
        microcredit = create(:microcredit, :active, limits: "100€: 10\n200€: 10\n300€: 10\n400€: 10")

        # Create various loans
        create(:microcredit_loan, microcredit: microcredit, amount: 100)
        create(:microcredit_loan, microcredit: microcredit, amount: 200, confirmed_at: Time.current)
        create(:microcredit_loan, microcredit: microcredit, amount: 300, confirmed_at: Time.current, counted_at: Time.current)
        discarded_loan = create(:microcredit_loan, microcredit: microcredit, amount: 400, confirmed_at: nil)
        discarded_loan.update_column(:discarded_at, Time.current)

        stats = described_class.get_loans_stats([microcredit.id])

        expect(stats[:count]).to eq(3) # ignores discarded
        expect(stats[:count_confirmed]).to eq(2)
        expect(stats[:count_counted]).to eq(1)
        expect(stats[:count_discarded]).to eq(1)

        expect(stats[:amount]).to eq(600) # 100 + 200 + 300
        expect(stats[:amount_confirmed]).to eq(500) # 200 + 300
        expect(stats[:amount_counted]).to eq(300)
        expect(stats[:amount_discarded]).to eq(400)
      end

      it 'counts unique document_vatids' do
        microcredit = create(:microcredit)

        # Same user making multiple loans
        create(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "12345678Z", amount: 100)
        create(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "12345678Z", amount: 200, confirmed_at: Time.current)
        create(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "87654321X", amount: 300, confirmed_at: Time.current)

        stats = described_class.get_loans_stats([microcredit.id])

        expect(stats[:unique]).to eq(2)
        expect(stats[:unique_confirmed]).to eq(2)
      end
    end
  end

  # ====================
  # CAPTCHA TESTS
  # ====================

  describe 'captcha' do
    it 'applies simple captcha' do
      loan = described_class.new
      expect(loan).to respond_to(:captcha)
      expect(loan).to respond_to(:captcha_key)
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'handles complete loan lifecycle' do
      microcredit = create(:microcredit, :active)
      loan = create(:microcredit_loan, microcredit: microcredit)

      # Initial state
      expect(loan.confirmed_at).to be_nil
      expect(loan.counted_at).to be_nil
      expect(loan.returned_at).to be_nil

      # Confirm
      loan.confirm!
      expect(loan.confirmed_at).not_to be_nil

      # Return
      loan.return!
      expect(loan.returned_at).not_to be_nil
    end

    it 'handles loan with full user data without user object' do
      loan = create(:microcredit_loan, :without_user,
        first_name: "Test",
        last_name: "User",
        email: "test@example.com",
        address: "Test St 1",
        postal_code: "28001",
        town: "Madrid",
        province: "Madrid",
        country: "ES",
        document_vatid: "12345678Z"
      )

      loan.reload
      expect(loan.user_data).not_to be_nil

      data = YAML.unsafe_load(loan.user_data)
      expect(data[:first_name]).to eq("Test")
      expect(data[:email]).to eq("test@example.com")
    end
  end
end
