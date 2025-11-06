# frozen_string_literal: true

require 'test_helper'

class CollaborationTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "should create collaboration from factory" do
    collaboration = create(:collaboration)
    assert collaboration.persisted?
    assert_not_nil collaboration.user
    assert_equal 1, collaboration.payment_type
  end

  test "should create collaboration with CCC" do
    collaboration = create(:collaboration, :with_ccc)
    assert_equal 2, collaboration.payment_type
    assert_not_nil collaboration.ccc_entity
  end

  test "should create collaboration with IBAN" do
    collaboration = create(:collaboration, :with_iban)
    assert_equal 3, collaboration.payment_type
    assert_not_nil collaboration.iban_account
  end

  test "should create non-user collaboration" do
    collaboration = create(:collaboration, :non_user)
    assert_nil collaboration.user_id
    assert_not_nil collaboration.non_user_email
    assert_not_nil collaboration.non_user_document_vatid
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should require payment_type" do
    collaboration = build(:collaboration, payment_type: nil)
    assert_not collaboration.valid?
    assert_includes collaboration.errors[:payment_type], "can't be blank"
  end

  test "should require amount" do
    collaboration = build(:collaboration, amount: nil)
    assert_not collaboration.valid?
    assert_includes collaboration.errors[:amount], "can't be blank"
  end

  test "should require frequency" do
    collaboration = build(:collaboration, frequency: nil)
    assert_not collaboration.valid?
    assert_includes collaboration.errors[:frequency], "can't be blank"
  end

  test "should require terms_of_service acceptance" do
    collaboration = build(:collaboration, terms_of_service: false)
    assert_not collaboration.valid?
    assert_includes collaboration.errors[:terms_of_service], "must be accepted"
  end

  test "should require minimal_year_old acceptance" do
    collaboration = build(:collaboration, minimal_year_old: false)
    assert_not collaboration.valid?
    assert_includes collaboration.errors[:minimal_year_old], "must be accepted"
  end

  test "should validate user_id uniqueness for recurring collaborations" do
    # Create user with DNI (not passport) to pass Collaboration validations
    dni_letters = "TRWAGMYFPDXBNJZSQVHLCKE"
    number = rand(10000000..99999999)
    letter = dni_letters[number % 23]
    user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}")
    user.save(validate: false)

    create(:collaboration, user: user, frequency: 1)

    duplicate = build(:collaboration, user: user, frequency: 1)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "should allow multiple single collaborations for same user" do
    # Create user with DNI (not passport) to pass Collaboration validations
    dni_letters = "TRWAGMYFPDXBNJZSQVHLCKE"
    number = rand(10000000..99999999)
    letter = dni_letters[number % 23]
    user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}")
    user.save(validate: false)

    create(:collaboration, :single, user: user)

    duplicate = build(:collaboration, :single, user: user)
    assert duplicate.valid?
  end

  test "should validate CCC fields when payment_type is CCC" do
    collaboration = build(:collaboration, payment_type: 2, ccc_entity: nil)
    assert_not collaboration.valid?
    assert_includes collaboration.errors[:ccc_entity], "can't be blank"
  end

  test "should validate IBAN presence when payment_type is IBAN" do
    collaboration = build(:collaboration, payment_type: 3, iban_account: nil, iban_bic: nil)
    assert_not collaboration.valid?
    assert_includes collaboration.errors[:iban_account], "can't be blank"
  end

  test "should reject passport users" do
    passport_user = build(:user, document_type: 3)
    passport_user.save(validate: false) # Skip User validations
    collaboration = build(:collaboration, user: passport_user)

    assert_not collaboration.valid?
    assert_includes collaboration.errors[:user], "No puedes colaborar si no dispones de DNI o NIE."
  end

  test "should reject underage users" do
    # Create user with DNI format
    dni_letters = "TRWAGMYFPDXBNJZSQVHLCKE"
    number = rand(10000000..99999999)
    letter = dni_letters[number % 23]

    young_user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}", born_at: 10.years.ago)
    young_user.save(validate: false) # Skip User validations
    collaboration = build(:collaboration, user: young_user)

    assert_not collaboration.valid?
    assert_includes collaboration.errors[:user], "No puedes colaborar si eres menor de edad."
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create collaboration" do
    assert_difference('Collaboration.count', 1) do
      create(:collaboration)
    end
  end

  test "should read collaboration" do
    collaboration = create(:collaboration)
    found = Collaboration.find(collaboration.id)

    assert_equal collaboration.id, found.id
    assert_equal collaboration.amount, found.amount
  end

  test "should update collaboration" do
    collaboration = create(:collaboration, amount: 1000)
    collaboration.update(amount: 2000)

    assert_equal 2000, collaboration.reload.amount
  end

  test "should soft delete collaboration" do
    collaboration = create(:collaboration)

    assert_difference('Collaboration.count', -1) do
      collaboration.destroy
    end

    assert_not_nil collaboration.reload.deleted_at
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "live scope should exclude deleted collaborations" do
    active = create(:collaboration)
    deleted = create(:collaboration, :deleted)

    results = Collaboration.live

    assert_includes results, active
    assert_not_includes results, deleted
  end

  test "credit_cards scope should return only credit card collaborations" do
    cc = create(:collaboration, payment_type: 1)
    bank = create(:collaboration, :with_iban)

    results = Collaboration.credit_cards

    assert_includes results, cc
    assert_not_includes results, bank
  end

  test "banks scope should return only bank collaborations" do
    cc = create(:collaboration, payment_type: 1)
    bank = create(:collaboration, :with_iban)

    results = Collaboration.banks

    assert_includes results, bank
    assert_not_includes results, cc
  end

  test "frequency_single scope" do
    single = create(:collaboration, :single)
    monthly = create(:collaboration, frequency: 1)

    results = Collaboration.frequency_single

    assert_includes results, single
    assert_not_includes results, monthly
  end

  test "frequency_month scope" do
    monthly = create(:collaboration, frequency: 1)
    quarterly = create(:collaboration, :quarterly)

    results = Collaboration.frequency_month

    assert_includes results, monthly
    assert_not_includes results, quarterly
  end

  test "incomplete scope" do
    incomplete = create(:collaboration, :incomplete)
    active = create(:collaboration, :active)

    results = Collaboration.incomplete

    assert_includes results, incomplete
    assert_not_includes results, active
  end

  test "active scope" do
    active = create(:collaboration, :active)
    incomplete = create(:collaboration, :incomplete)

    results = Collaboration.active

    assert_includes results, active
    assert_not_includes results, incomplete
  end

  test "warnings scope" do
    warning = create(:collaboration, :warning)
    active = create(:collaboration, :active)

    results = Collaboration.warnings

    assert_includes results, warning
    assert_not_includes results, active
  end

  test "errors scope" do
    error = create(:collaboration, :error)
    active = create(:collaboration, :active)

    results = Collaboration.errors

    assert_includes results, error
    assert_not_includes results, active
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should belong to user" do
    collaboration = create(:collaboration)
    assert_respond_to collaboration, :user
    assert_instance_of User, collaboration.user
  end

  test "should have many orders" do
    collaboration = create(:collaboration)
    assert_respond_to collaboration, :order
  end

  test "should allow nil user for non-user collaborations" do
    collaboration = create(:collaboration, :non_user)
    assert_nil collaboration.user
    assert_not_nil collaboration.get_user
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  test "should set initial status after create" do
    collaboration = build(:collaboration)
    collaboration.save

    assert_equal 0, collaboration.status
  end

  test "should upcase IBAN before save" do
    collaboration = create(:collaboration, :with_iban, iban_account: "es9121000418450200051332")

    assert_equal "ES9121000418450200051332", collaboration.iban_account
  end

  test "should clear redsys fields for bank payments" do
    collaboration = create(:collaboration, payment_type: 1, redsys_identifier: "ABC123")
    collaboration.update(payment_type: 3, iban_account: "ES9121000418450200051332", iban_bic: "CAIXESBBXXX")

    assert_nil collaboration.reload.redsys_identifier
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  test "is_credit_card? should return true for credit card payments" do
    collaboration = create(:collaboration, payment_type: 1)
    assert collaboration.is_credit_card?
  end

  test "is_bank? should return true for bank payments" do
    collaboration = create(:collaboration, :with_iban)
    assert collaboration.is_bank?
  end

  test "is_bank_national? should return true for Spanish IBAN" do
    collaboration = create(:collaboration, :with_iban)
    assert collaboration.is_bank_national?
  end

  test "is_bank_international? should return true for non-Spanish IBAN" do
    collaboration = create(:collaboration, :with_international_iban)
    assert collaboration.is_bank_international?
  end

  test "has_ccc_account? should return true when payment_type is 2" do
    collaboration = create(:collaboration, :with_ccc)
    assert collaboration.has_ccc_account?
  end

  test "has_iban_account? should return true when payment_type is 3" do
    collaboration = create(:collaboration, :with_iban)
    assert collaboration.has_iban_account?
  end

  test "frequency_name should return correct name" do
    collaboration = create(:collaboration, frequency: 1)
    assert_equal "Mensual", collaboration.frequency_name
  end

  test "status_name should return correct name" do
    collaboration = create(:collaboration, :active)
    collaboration.reload # Reload to ensure status was set by after(:create) callback
    assert_equal 3, collaboration.status
    assert_equal "OK", collaboration.status_name
  end

  test "ccc_full should return formatted CCC" do
    collaboration = create(:collaboration, :with_ccc)
    expected = "21001234561234567890"

    assert_equal expected, collaboration.ccc_full
  end

  test "has_payment? should return true when status > 0" do
    collaboration = create(:collaboration, :active)
    collaboration.reload
    assert collaboration.has_payment?
  end

  test "is_active? should return true for active status" do
    collaboration = create(:collaboration, :active)
    collaboration.reload
    assert collaboration.is_active?
  end

  test "has_confirmed_payment? should return true when status > 2" do
    collaboration = create(:collaboration, :active)
    collaboration.reload
    assert collaboration.has_confirmed_payment?
  end

  test "has_warnings? should return true for warning status" do
    collaboration = create(:collaboration, :warning)
    collaboration.reload
    assert collaboration.has_warnings?
  end

  test "has_errors? should return true for error status" do
    collaboration = create(:collaboration, :error)
    collaboration.reload
    assert collaboration.has_errors?
  end

  # ====================
  # STATUS METHOD TESTS
  # ====================

  test "set_error! should change status to error" do
    collaboration = create(:collaboration, :active)
    collaboration.set_error!("Test error")

    assert_equal 1, collaboration.reload.status
  end

  test "set_ok! should change status to OK" do
    collaboration = create(:collaboration, :unconfirmed)
    collaboration.set_ok!

    assert_equal 3, collaboration.reload.status
  end

  test "set_warning! should change status to warning" do
    collaboration = create(:collaboration, :active)
    collaboration.set_warning!("Test warning")

    assert_equal 4, collaboration.reload.status
  end

  test "set_active! should change status to active if lower" do
    collaboration = create(:collaboration, :incomplete)
    collaboration.set_active!

    assert_equal 2, collaboration.reload.status
  end

  # ====================
  # TERRITORIAL ASSIGNMENT TESTS
  # ====================

  test "territorial_assignment should return correct symbol" do
    collaboration = create(:collaboration, :for_town)
    assert_equal :town, collaboration.territorial_assignment
  end

  test "territorial_assignment= should set correct flags for town" do
    collaboration = create(:collaboration)
    collaboration.territorial_assignment = :town

    assert collaboration.for_town_cc
    assert_not collaboration.for_autonomy_cc
    assert_not collaboration.for_island_cc
  end

  test "territorial_assignment= should set correct flags for autonomy" do
    collaboration = create(:collaboration)
    collaboration.territorial_assignment = :autonomy

    assert collaboration.for_autonomy_cc
    assert_not collaboration.for_town_cc
    assert_not collaboration.for_island_cc
  end

  test "territorial_assignment= should set correct flags for island" do
    collaboration = create(:collaboration)
    collaboration.territorial_assignment = :island

    assert collaboration.for_island_cc
    assert_not collaboration.for_town_cc
    assert_not collaboration.for_autonomy_cc
  end

  # ====================
  # SOFT DELETE (PARANOIA) TESTS
  # ====================

  test "should exclude soft deleted from default scope" do
    active = create(:collaboration)
    deleted = create(:collaboration, :deleted)

    results = Collaboration.all

    assert_includes results, active
    assert_not_includes results, deleted
  end

  test "should include soft deleted with with_deleted scope" do
    active = create(:collaboration)
    deleted = create(:collaboration, :deleted)

    results = Collaboration.with_deleted

    assert_includes results, active
    assert_includes results, deleted
  end

  test "should restore soft deleted collaboration" do
    collaboration = create(:collaboration)
    collaboration.destroy

    assert_not_nil collaboration.deleted_at

    collaboration.restore

    assert_nil collaboration.reload.deleted_at
    assert_includes Collaboration.all, collaboration
  end

  # ====================
  # PAYMENT IDENTIFIER TESTS
  # ====================

  test "payment_identifier should return redsys_identifier for credit cards" do
    collaboration = create(:collaboration, payment_type: 1, redsys_identifier: "ABC123")
    assert_equal "ABC123", collaboration.payment_identifier
  end

  test "payment_identifier should return IBAN/BIC for IBAN payments" do
    collaboration = create(:collaboration, :with_iban)
    assert_includes collaboration.payment_identifier, collaboration.iban_account
    assert_includes collaboration.payment_identifier, collaboration.iban_bic
  end

  # ====================
  # GET_USER TESTS
  # ====================

  test "get_user should return user when user exists" do
    collaboration = create(:collaboration)
    assert_equal collaboration.user, collaboration.get_user
  end

  test "get_user should return non_user when user is nil" do
    collaboration = create(:collaboration, :non_user)
    non_user = collaboration.get_user

    assert_not_nil non_user
    assert_equal "nonuser@example.com", non_user.email
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle collaboration without user" do
    collaboration = create(:collaboration, :non_user)
    assert_nil collaboration.user
    assert collaboration.persisted?
  end

  test "should allow same email for deleted non-user collaborations" do
    create(:collaboration, :non_user, :deleted, non_user_email: "test@example.com")
    duplicate = build(:collaboration, :non_user, non_user_email: "test@example.com")

    assert duplicate.valid?
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "complete credit card collaboration workflow" do
    # Create user with DNI (not passport) to pass Collaboration validations
    dni_letters = "TRWAGMYFPDXBNJZSQVHLCKE"
    number = rand(10000000..99999999)
    letter = dni_letters[number % 23]
    user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}")
    user.save(validate: false)

    collaboration = nil
    assert_difference('Collaboration.count', 1) do
      collaboration = create(:collaboration,
        user: user,
        payment_type: 1,
        amount: 1000,
        frequency: 1
      )
    end

    assert collaboration.is_credit_card?
    assert_not collaboration.is_bank?
    assert_equal "Mensual", collaboration.frequency_name
    assert_equal user, collaboration.get_user
  end

  test "complete bank collaboration workflow" do
    # Create user with DNI (not passport) to pass Collaboration validations
    dni_letters = "TRWAGMYFPDXBNJZSQVHLCKE"
    number = rand(10000000..99999999)
    letter = dni_letters[number % 23]
    user = build(:user, document_type: 1, document_vatid: "#{number}#{letter}")
    user.save(validate: false)

    collaboration = create(:collaboration, :with_iban, :active,
      user: user,
      amount: 2000,
      frequency: 3
    )

    # with_iban uses German IBAN by default (international)
    assert collaboration.is_bank?
    assert collaboration.is_bank_international?
    assert_not collaboration.is_credit_card?
    assert_equal "Trimestral", collaboration.frequency_name
    collaboration.reload
    assert_equal "OK", collaboration.status_name
  end

  test "status change workflow" do
    collaboration = create(:collaboration, :incomplete)
    assert_equal 0, collaboration.status

    collaboration.set_active!
    assert_equal 2, collaboration.reload.status

    collaboration.set_ok!
    assert_equal 3, collaboration.reload.status

    collaboration.set_warning!("Test")
    assert_equal 4, collaboration.reload.status

    collaboration.set_error!("Test")
    assert_equal 1, collaboration.reload.status
  end
end
