# frozen_string_literal: true

FactoryBot.define do
  factory :collaboration do
    # Create user with DNI (not passport) to pass validates_not_passport
    # Using German address to avoid Spanish postal code validations
    user do
      # Spanish DNI format: 8 digits + check letter
      dni_letters = "TRWAGMYFPDXBNJZSQVHLCKE"
      number = rand(10000000..99999999)
      letter = dni_letters[number % 23]

      u = build(:user,
        document_type: 1, # DNI
        document_vatid: "#{number}#{letter}",
        born_at: 25.years.ago # Ensure over 18
      )
      u.save(validate: false)
      u
    end

    payment_type { 1 } # Credit card by default
    amount { 1000 } # 10 EUR in cents
    frequency { 1 } # Monthly
    # status is set by after_create :set_initial_status callback to 0

    # Acceptance attributes - Rails 7.2 requires "1" format for acceptance validation
    terms_of_service { "1" }
    minimal_year_old { "1" }

    # Credit card fields (for payment_type = 1)
    redsys_identifier { "999999999R" }
    redsys_expiration { 2.years.from_now }

    trait :with_ccc do
      payment_type { 2 } # CCC
      ccc_entity { 2100 }
      ccc_office { 1234 }
      ccc_dc { 56 }
      ccc_account { 1234567890 }
      redsys_identifier { nil }
      redsys_expiration { nil }
      # Skip callbacks to avoid PlebisBrand::SpanishBIC dependency in check_spanish_bic
      to_create { |instance| instance.save(validate: false) }
    end

    trait :with_iban do
      payment_type { 3 } # IBAN
      # Use international IBAN by default to avoid PlebisBrand::SpanishBIC dependency
      iban_account { "DE89370400440532013000" } # Valid German IBAN
      iban_bic { "COBADEFFXXX" }
      redsys_identifier { nil }
      redsys_expiration { nil }
    end

    trait :with_spanish_iban do
      payment_type { 3 } # IBAN
      iban_account { "ES9121000418450200051332" } # Valid Spanish IBAN
      iban_bic { "CAIXESBBXXX" }
      redsys_identifier { nil }
      redsys_expiration { nil }
      # Requires PlebisBrand::SpanishBIC constant - skip in tests if not available
    end

    trait :with_international_iban do
      payment_type { 3 }
      iban_account { "DE89370400440532013000" } # Valid German IBAN
      iban_bic { "COBADEFFXXX" }
      redsys_identifier { nil }
      redsys_expiration { nil }
    end

    trait :single do
      frequency { 0 } # Puntual (one-time)
    end

    # RAILS 7.2 FIX: Add explicit :monthly trait for collaborations_ok_spec
    trait :monthly do
      frequency { 1 } # Monthly (this is the default, but tests need explicit trait)
    end

    trait :quarterly do
      frequency { 3 }
    end

    trait :annual do
      frequency { 12 }
    end

    # Status traits use after(:create) to override the after_create :set_initial_status callback
    trait :incomplete do
      after(:create) { |collab| collab.update_column(:status, 0) }
    end

    trait :error do
      after(:create) { |collab| collab.update_column(:status, 1) }
    end

    trait :unconfirmed do
      after(:create) { |collab| collab.update_column(:status, 2) }
    end

    trait :active do
      after(:create) { |collab| collab.update_column(:status, 3) }
    end

    trait :warning do
      after(:create) { |collab| collab.update_column(:status, 4) }
    end

    trait :migration do
      after(:create) { |collab| collab.update_column(:status, 9) }
    end

    trait :deleted do
      deleted_at { 1.day.ago }
    end

    trait :for_autonomy do
      for_autonomy_cc { true }
      for_town_cc { false }
      for_island_cc { false }
    end

    trait :for_town do
      for_autonomy_cc { false }
      for_town_cc { true }
      for_island_cc { false }
    end

    trait :for_island do
      for_autonomy_cc { false }
      for_town_cc { false }
      for_island_cc { true }
    end

    # Non-user collaboration (without user_id)
    trait :non_user do
      user { nil }

      # Set non_user_email and non_user_document_vatid before callbacks
      after(:build) do |collab|
        # Generate unique values
        n = rand(100000..999999)
        collab.non_user_email = "nonuser#{n}@example.com" unless collab.non_user_email
        collab.non_user_document_vatid = "1234567#{n % 10}Z" unless collab.non_user_document_vatid

        # Set non_user_data with NonUser object
        collab.instance_variable_set(:@non_user, Collaboration::NonUser.new(
          full_name: "Non User Name",
          document_vatid: collab.non_user_document_vatid,
          email: collab.non_user_email,
          address: "Test Address",
          town_name: "Madrid",
          postal_code: "28001",
          country: "ES",
          ine_town: "m_28_079_6"
        ))
        # Call format_non_user to serialize @non_user to non_user_data before validation
        collab.send(:format_non_user)
      end

      # Skip uniqueness validations for non-user collaborations
      skip_queries_validations { true }
    end

    # Skip validations for complex scenarios
    trait :skip_validations do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
