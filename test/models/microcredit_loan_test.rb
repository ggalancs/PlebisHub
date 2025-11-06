require "test_helper"

class MicrocreditLoanTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid microcredit_loan with user" do
    loan = build(:microcredit_loan)
    assert loan.valid?, "Factory should create a valid microcredit_loan. Errors: #{loan.errors.full_messages.join(', ')}"
  end

  test "factory creates valid microcredit_loan without user" do
    loan = build(:microcredit_loan, :without_user)
    assert loan.valid?, "Factory should create a valid microcredit_loan without user. Errors: #{loan.errors.full_messages.join(', ')}"
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should belong to microcredit" do
    loan = create(:microcredit_loan)
    assert_respond_to loan, :microcredit
    assert_kind_of Microcredit, loan.microcredit
  end

  test "should belong to user" do
    loan = create(:microcredit_loan)
    assert_respond_to loan, :user
    assert_kind_of User, loan.user
  end

  test "should belong to microcredit_option" do
    loan = create(:microcredit_loan)
    assert_respond_to loan, :microcredit_option
    assert_kind_of MicrocreditOption, loan.microcredit_option
  end

  test "should belong to transferred_to" do
    loan1 = create(:microcredit_loan)
    loan2 = create(:microcredit_loan, transferred_to: loan1)
    assert_equal loan1, loan2.transferred_to
  end

  test "should have many original_loans" do
    loan1 = create(:microcredit_loan)
    loan2 = create(:microcredit_loan, transferred_to: loan1)
    assert_includes loan1.original_loans, loan2
  end

  test "should load user with soft delete" do
    loan = create(:microcredit_loan)
    user = loan.user
    user.destroy

    loan.reload
    assert_not_nil loan.user
    assert user.deleted?
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should require amount" do
    loan = build(:microcredit_loan, amount: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:amount], "no puede estar en blanco"
  end

  test "should require terms_of_service acceptance" do
    loan = build(:microcredit_loan, terms_of_service: false)
    assert_not loan.valid?
    assert_includes loan.errors[:terms_of_service], "debe ser aceptado"
  end

  test "should require minimal_year_old acceptance" do
    loan = build(:microcredit_loan, minimal_year_old: false)
    assert_not loan.valid?
    assert_includes loan.errors[:minimal_year_old], "debe ser aceptado"
  end

  test "should require iban_account on create" do
    loan = build(:microcredit_loan, iban_account: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:iban_account], "no puede estar en blanco"
  end

  test "should require iban_bic on create if international" do
    loan = build(:microcredit_loan, :international_iban, iban_bic: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:iban_bic], "no puede estar en blanco"
  end

  test "should not require iban_bic for Spanish IBAN" do
    loan = build(:microcredit_loan, iban_account: "ES9121000418450200051332", iban_bic: nil)
    # BIC is calculated automatically for Spanish IBANs
    assert loan.valid?, "Spanish IBAN should be valid without explicit BIC. Errors: #{loan.errors.full_messages.join(', ')}"
  end

  # Validations for loans without user
  test "should require document_vatid if no user" do
    loan = build(:microcredit_loan, :without_user, document_vatid: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:document_vatid], "no es un formato válido"
  end

  test "should validate Spanish ID format for document_vatid if no user" do
    loan = build(:microcredit_loan, :without_user, document_vatid: "12345678A")
    assert_not loan.valid?, "Invalid DNI check digit should be rejected"
  end

  test "should accept valid Spanish DNI if no user" do
    loan = build(:microcredit_loan, :without_user, document_vatid: "12345678Z")
    assert loan.valid?, "Valid DNI should be accepted. Errors: #{loan.errors.full_messages.join(', ')}"
  end

  test "should require first_name if no user" do
    loan = build(:microcredit_loan, :without_user, first_name: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:first_name], "no puede estar en blanco"
  end

  test "should require last_name if no user" do
    loan = build(:microcredit_loan, :without_user, last_name: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:last_name], "no puede estar en blanco"
  end

  test "should require email if no user" do
    loan = build(:microcredit_loan, :without_user, email: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:email], "no puede estar en blanco"
  end

  test "should validate email format if no user" do
    loan = build(:microcredit_loan, :without_user, email: "invalid")
    assert_not loan.valid?
    assert_includes loan.errors[:email], "no es un correo válido"
  end

  test "should require address if no user" do
    loan = build(:microcredit_loan, :without_user, address: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:address], "no puede estar en blanco"
  end

  test "should require postal_code if no user" do
    loan = build(:microcredit_loan, :without_user, postal_code: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:postal_code], "no puede estar en blanco"
  end

  test "should require town if no user" do
    loan = build(:microcredit_loan, :without_user, town: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:town], "no puede estar en blanco"
  end

  test "should require province if no user" do
    loan = build(:microcredit_loan, :without_user, province: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:province], "no puede estar en blanco"
  end

  test "should require country if no user" do
    loan = build(:microcredit_loan, :without_user, country: nil)
    assert_not loan.valid?
    assert_includes loan.errors[:country], "no puede estar en blanco"
  end

  # Custom validations
  test "should not accept passport users" do
    user = create(:user, document_type: 3) # Passport
    loan = build(:microcredit_loan, user: user)
    assert_not loan.valid?
    assert_includes loan.errors[:user], "No puedes suscribir un microcrédito si no dispones de DNI o NIE."
  end

  test "should not accept users under 18" do
    user = create(:user, born_at: 17.years.ago)
    loan = build(:microcredit_loan, user: user)
    assert_not loan.valid?
    assert_includes loan.errors[:user], "No puedes suscribir un microcrédito si eres menor de edad."
  end

  test "should accept users 18 or older" do
    user = create(:user, document_type: 1, born_at: 18.years.ago)
    loan = build(:microcredit_loan, user: user)
    assert loan.valid?, "User 18 or older should be valid. Errors: #{loan.errors.full_messages.join(', ')}"
  end

  test "should validate IBAN format" do
    loan = build(:microcredit_loan, :invalid_iban)
    assert_not loan.valid?
    assert_includes loan.errors[:iban_account], "Cuenta corriente inválida. Dígito de control erroneo. Por favor revísala."
  end

  test "should not accept brand's own account number" do
    microcredit = create(:microcredit, account_number: "ES9121000418450200051332")
    loan = build(:microcredit_loan, microcredit: microcredit, iban_account: "ES9121000418450200051332")
    assert_not loan.valid?
    assert_match(/no la de/, loan.errors[:iban_account].first)
  end

  test "should accept different account number from brand" do
    microcredit = create(:microcredit, account_number: "ES1234567890123456789012")
    loan = build(:microcredit_loan, microcredit: microcredit, iban_account: "ES9121000418450200051332")
    assert loan.valid?, "Different account should be valid. Errors: #{loan.errors.full_messages.join(', ')}"
  end

  test "should reject loan if amount not available" do
    microcredit = create(:microcredit, :active, limits: "100€: 1")
    # Create first loan to fill the limit
    create(:microcredit_loan, microcredit: microcredit, amount: 100, confirmed_at: Time.current)

    # Try to create second loan
    loan = build(:microcredit_loan, microcredit: microcredit, amount: 100)
    assert_not loan.valid?
    assert_includes loan.errors[:amount], "Lamentablemente, ya no quedan préstamos por esa cantidad."
  end

  test "should reject loan if microcredit is not active" do
    microcredit = create(:microcredit, :finished)
    loan = build(:microcredit_loan, microcredit: microcredit)
    assert_not loan.valid?
    assert_includes loan.errors[:microcredit], "La campaña de microcréditos no está activa en este momento."
  end

  test "should reject if exceeds max loans per IP" do
    microcredit = create(:microcredit, :active)
    ip = "192.168.1.100"

    # Create max loans for this IP
    51.times do |i|
      user = create(:user, document_type: 1)
      create(:microcredit_loan, microcredit: microcredit, user: user, ip: ip, confirmed_at: Time.current)
    end

    # Try to create one more
    loan = build(:microcredit_loan, microcredit: microcredit, ip: ip)
    assert_not loan.valid?
    assert_includes loan.errors[:user], "Lamentablemente, no es posible suscribir este microcrédito."
  end

  test "should reject if exceeds max loans per user" do
    microcredit = create(:microcredit, :active)
    loan = build(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "12345678Z")

    # Create max loans for this document
    31.times do
      create(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "12345678Z", confirmed_at: Time.current)
    end

    # Try to create one more
    assert_not loan.valid?
    assert_includes loan.errors[:user], "Lamentablemente, no es posible suscribir este microcrédito."
  end

  test "should reject if loan amount sum exceeds max" do
    microcredit = create(:microcredit, :active, limits: "5000€: 10")

    # Create loans totaling 9000
    2.times do
      create(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "12345678Z", amount: 5000, confirmed_at: Time.current)
    end

    # Try to create loan for 2000 (would exceed 10000 limit)
    loan = build(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "12345678Z", amount: 2000)
    assert_not loan.valid?
    assert_includes loan.errors[:user], "Lamentablemente, no es posible suscribir este microcrédito."
  end

  test "should validate microcredit_option is leaf node" do
    parent_option = create(:microcredit_option)
    child_option = create(:microcredit_option, parent: parent_option, microcredit: parent_option.microcredit)

    loan = build(:microcredit_loan, microcredit: parent_option.microcredit, microcredit_option: parent_option)
    assert_not loan.valid?
    assert_includes loan.errors[:microcredit_option_id], "Debes elegir algún elemento"
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "not_counted scope should return loans without counted_at" do
    counted = create(:microcredit_loan, :counted)
    not_counted = create(:microcredit_loan)

    result = MicrocreditLoan.not_counted
    assert_includes result, not_counted
    assert_not_includes result, counted
  end

  test "counted scope should return loans with counted_at" do
    counted = create(:microcredit_loan, :counted)
    not_counted = create(:microcredit_loan)

    result = MicrocreditLoan.counted
    assert_includes result, counted
    assert_not_includes result, not_counted
  end

  test "not_confirmed scope should return loans without confirmed_at" do
    confirmed = create(:microcredit_loan, :confirmed)
    not_confirmed = create(:microcredit_loan)

    result = MicrocreditLoan.not_confirmed
    assert_includes result, not_confirmed
    assert_not_includes result, confirmed
  end

  test "confirmed scope should return loans with confirmed_at" do
    confirmed = create(:microcredit_loan, :confirmed)
    not_confirmed = create(:microcredit_loan)

    result = MicrocreditLoan.confirmed
    assert_includes result, confirmed
    assert_not_includes result, not_confirmed
  end

  test "not_discarded scope should return loans without discarded_at" do
    discarded = create(:microcredit_loan, :discarded)
    not_discarded = create(:microcredit_loan)

    result = MicrocreditLoan.not_discarded
    assert_includes result, not_discarded
    assert_not_includes result, discarded
  end

  test "discarded scope should return loans with discarded_at" do
    discarded = create(:microcredit_loan, :discarded)
    not_discarded = create(:microcredit_loan)

    result = MicrocreditLoan.discarded
    assert_includes result, discarded
    assert_not_includes result, not_discarded
  end

  test "not_returned scope should return confirmed loans without returned_at" do
    returned = create(:microcredit_loan, :returned)
    not_returned = create(:microcredit_loan, :confirmed)
    unconfirmed = create(:microcredit_loan)

    result = MicrocreditLoan.not_returned
    assert_includes result, not_returned
    assert_not_includes result, returned
    assert_not_includes result, unconfirmed
  end

  test "returned scope should return loans with returned_at" do
    returned = create(:microcredit_loan, :returned)
    not_returned = create(:microcredit_loan, :confirmed)

    result = MicrocreditLoan.returned
    assert_includes result, returned
    assert_not_includes result, not_returned
  end

  test "transferred scope should return loans with transferred_to_id" do
    loan1 = create(:microcredit_loan, :confirmed)
    loan2 = create(:microcredit_loan, :confirmed, transferred_to: loan1)

    result = MicrocreditLoan.transferred
    assert_includes result, loan2
    assert_not_includes result, loan1
  end

  test "ignore_discarded scope should return non-discarded or counted loans" do
    discarded_not_counted = create(:microcredit_loan, :discarded)
    discarded_counted = create(:microcredit_loan, :discarded, :counted)
    not_discarded = create(:microcredit_loan)

    result = MicrocreditLoan.ignore_discarded
    assert_includes result, not_discarded
    assert_includes result, discarded_counted
    assert_not_includes result, discarded_not_counted
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  test "should set user data from user on initialization" do
    user = create(:user, first_name: "John", last_name: "Doe")
    loan = MicrocreditLoan.new(user: user)

    assert_equal "John", loan.first_name
    assert_equal "Doe", loan.last_name
    assert_equal user.email, loan.email
    assert_equal user.document_vatid, loan.document_vatid
  end

  test "should set country to ES by default if no user" do
    loan = MicrocreditLoan.new
    assert_equal "ES", loan.country
  end

  test "should upcase iban_account before save" do
    loan = create(:microcredit_loan, iban_account: "es9121000418450200051332")
    assert_equal "ES9121000418450200051332", loan.iban_account
  end

  test "should save user_data as YAML when no user" do
    loan = create(:microcredit_loan, :without_user, first_name: "Juan", last_name: "García")

    assert_not_nil loan.user_data
    data = YAML.unsafe_load(loan.user_data, aliases: true)
    assert_equal "Juan", data[:first_name]
    assert_equal "García", data[:last_name]
  end

  test "should set user_data to nil when user exists" do
    loan = create(:microcredit_loan)
    assert_nil loan.user_data
  end

  test "should upcase and strip document_vatid before save" do
    loan = create(:microcredit_loan, :without_user, document_vatid: " 12345678z ")
    assert_equal "12345678Z", loan.document_vatid
  end

  test "should calculate BIC for Spanish IBAN before save" do
    loan = create(:microcredit_loan, iban_account: "ES9121000418450200051332", iban_bic: nil)
    assert_not_nil loan.iban_bic
    assert_equal "CAIXESBBXXX", loan.iban_bic
  end

  # ====================
  # PARANOIA (SOFT DELETE) TESTS
  # ====================

  test "should soft delete loan" do
    loan = create(:microcredit_loan)
    loan.destroy

    assert_not_nil loan.deleted_at
    assert_not MicrocreditLoan.exists?(loan.id)
    assert MicrocreditLoan.with_deleted.exists?(loan.id)
  end

  test "should restore soft deleted loan" do
    loan = create(:microcredit_loan)
    loan.destroy
    loan.restore

    assert_nil loan.deleted_at
    assert MicrocreditLoan.exists?(loan.id)
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  test "set_user_data should set virtual attributes from hash" do
    loan = MicrocreditLoan.new
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

    assert_equal "Maria", loan.first_name
    assert_equal "Lopez", loan.last_name
    assert_equal "maria@example.com", loan.email
    assert_equal "Calle Test 1", loan.address
  end

  test "country_name should return country name from Carmen" do
    loan = build(:microcredit_loan, :without_user, country: "ES")
    assert_equal "Spain", loan.country_name
  end

  test "country_name should return country code if not found" do
    loan = build(:microcredit_loan, :without_user, country: "XX")
    assert_equal "XX", loan.country_name
  end

  test "province_name should return province name from Carmen" do
    loan = build(:microcredit_loan, :without_user, country: "ES", province: "M")
    assert_equal "Comunidad de Madrid", loan.province_name
  end

  test "province_name should return province code if not found" do
    loan = build(:microcredit_loan, :without_user, province: "XX")
    assert_equal "XX", loan.province_name
  end

  test "town_name should return town code as fallback" do
    loan = build(:microcredit_loan, :without_user, town: "Madrid")
    assert_equal "Madrid", loan.town_name
  end

  test "has_not_user? should return true when no user" do
    loan = build(:microcredit_loan, :without_user)
    assert loan.has_not_user?
  end

  test "has_not_user? should return false when user exists" do
    loan = build(:microcredit_loan)
    assert_not loan.has_not_user?
  end

  test "is_bank_international? should return true for non-Spanish IBAN" do
    loan = build(:microcredit_loan, :international_iban)
    assert loan.is_bank_international?
  end

  test "is_bank_international? should return false for Spanish IBAN" do
    loan = build(:microcredit_loan, iban_account: "ES9121000418450200051332")
    assert_not loan.is_bank_international?
  end

  test "iban_valid? should validate correct Spanish IBAN" do
    loan = build(:microcredit_loan, iban_account: "ES9121000418450200051332")
    assert loan.iban_valid?
  end

  test "iban_valid? should reject incorrect IBAN" do
    loan = build(:microcredit_loan, iban_account: "ES9999999999999999999999")
    assert_not loan.iban_valid?
  end

  test "calculate_bic should return BIC for Spanish bank code" do
    loan = build(:microcredit_loan, iban_account: "ES9121000418450200051332")
    bic = loan.calculate_bic
    assert_not_nil bic
    assert_equal "CAIXESBBXXX", bic
  end

  test "possible_user should find user by document_vatid" do
    user = create(:user, document_type: 1, document_vatid: "12345678Z")
    loan = build(:microcredit_loan, :without_user, document_vatid: "12345678Z")

    assert_equal user, loan.possible_user
  end

  test "possible_user should return nil if no matching user" do
    loan = build(:microcredit_loan, :without_user, document_vatid: "87654321X")
    assert_nil loan.possible_user
  end

  test "unique_hash should generate consistent hash" do
    loan = create(:microcredit_loan, :without_user, document_vatid: "12345678Z")
    hash1 = loan.unique_hash
    hash2 = loan.unique_hash

    assert_equal hash1, hash2
    assert_equal 40, hash1.length # SHA1 hex digest length
  end

  test "renewable? should return true for confirmed non-returned loan with renewable microcredit" do
    microcredit = create(:microcredit, :active)
    # Mock renewable? method
    microcredit.define_singleton_method(:renewable?) { true }

    loan = create(:microcredit_loan, microcredit: microcredit, confirmed_at: Time.current, returned_at: nil)
    assert loan.renewable?
  end

  test "renewable? should return false if not confirmed" do
    microcredit = create(:microcredit, :active)
    loan = create(:microcredit_loan, microcredit: microcredit, confirmed_at: nil)

    assert_not loan.renewable?
  end

  test "renewable? should return false if already returned" do
    microcredit = create(:microcredit, :active)
    loan = create(:microcredit_loan, :returned, microcredit: microcredit)

    assert_not loan.renewable?
  end

  test "confirm! should set confirmed_at and clear discarded_at" do
    loan = create(:microcredit_loan, confirmed_at: nil, discarded_at: Time.current)

    result = loan.confirm!
    assert result
    assert_not_nil loan.confirmed_at
    assert_nil loan.discarded_at
  end

  test "confirm! should return false if already confirmed" do
    loan = create(:microcredit_loan, :confirmed)

    result = loan.confirm!
    assert_not result
  end

  test "unconfirm! should clear confirmed_at" do
    loan = create(:microcredit_loan, :confirmed)

    result = loan.unconfirm!
    assert result
    assert_nil loan.confirmed_at
  end

  test "unconfirm! should return false if not confirmed" do
    loan = create(:microcredit_loan, confirmed_at: nil)

    result = loan.unconfirm!
    assert_not result
  end

  test "discard! should set discarded_at and clear confirmed_at" do
    loan = create(:microcredit_loan, :confirmed)

    result = loan.discard!
    assert result
    assert_not_nil loan.discarded_at
    assert_nil loan.confirmed_at
  end

  test "discard! should return false if already discarded" do
    loan = create(:microcredit_loan, :discarded)

    result = loan.discard!
    assert_not result
  end

  test "return! should set returned_at for confirmed loan" do
    loan = create(:microcredit_loan, :confirmed, returned_at: nil)

    result = loan.return!
    assert result
    assert_not_nil loan.returned_at
  end

  test "return! should return false if not confirmed" do
    loan = create(:microcredit_loan, confirmed_at: nil)

    result = loan.return!
    assert_not result
  end

  test "return! should return false if already returned" do
    loan = create(:microcredit_loan, :returned)

    result = loan.return!
    assert_not result
  end

  test "renew! should create new loan and mark original as returned" do
    old_microcredit = create(:microcredit, :finished)
    new_microcredit = create(:microcredit, :active)
    loan = create(:microcredit_loan, :confirmed, microcredit: old_microcredit)

    loan.renew!(new_microcredit)
    loan.reload

    assert_not_nil loan.returned_at
    assert_not_nil loan.transferred_to
    assert_equal new_microcredit, loan.transferred_to.microcredit
    assert_not_nil loan.transferred_to.counted_at
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  test "get_loans_stats should return correct statistics" do
    microcredit = create(:microcredit)

    # Create various loans
    create(:microcredit_loan, microcredit: microcredit, amount: 100)
    create(:microcredit_loan, microcredit: microcredit, amount: 200, confirmed_at: Time.current)
    create(:microcredit_loan, microcredit: microcredit, amount: 300, confirmed_at: Time.current, counted_at: Time.current)
    create(:microcredit_loan, microcredit: microcredit, amount: 400, discarded_at: Time.current)

    stats = MicrocreditLoan.get_loans_stats([microcredit.id])

    assert_equal 3, stats[:count] # ignores discarded
    assert_equal 2, stats[:count_confirmed]
    assert_equal 1, stats[:count_counted]
    assert_equal 1, stats[:count_discarded]

    assert_equal 600, stats[:amount] # 100 + 200 + 300
    assert_equal 500, stats[:amount_confirmed] # 200 + 300
    assert_equal 300, stats[:amount_counted]
    assert_equal 400, stats[:amount_discarded]
  end

  test "get_loans_stats should count unique document_vatids" do
    microcredit = create(:microcredit)

    # Same user making multiple loans
    create(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "12345678Z", amount: 100)
    create(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "12345678Z", amount: 200, confirmed_at: Time.current)
    create(:microcredit_loan, :without_user, microcredit: microcredit, document_vatid: "87654321X", amount: 300, confirmed_at: Time.current)

    stats = MicrocreditLoan.get_loans_stats([microcredit.id])

    assert_equal 2, stats[:unique]
    assert_equal 2, stats[:unique_confirmed]
  end

  # ====================
  # CAPTCHA TESTS
  # ====================

  test "should apply simple captcha" do
    loan = MicrocreditLoan.new
    assert_respond_to loan, :captcha
    assert_respond_to loan, :captcha_key
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "should handle complete loan lifecycle" do
    microcredit = create(:microcredit, :active)
    loan = create(:microcredit_loan, microcredit: microcredit)

    # Initial state
    assert_nil loan.confirmed_at
    assert_nil loan.counted_at
    assert_nil loan.returned_at

    # Confirm
    loan.confirm!
    assert_not_nil loan.confirmed_at

    # Return
    loan.return!
    assert_not_nil loan.returned_at
  end

  test "should handle loan with full user data without user object" do
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
    assert_not_nil loan.user_data

    data = YAML.unsafe_load(loan.user_data, aliases: true)
    assert_equal "Test", data[:first_name]
    assert_equal "test@example.com", data[:email]
  end
end
