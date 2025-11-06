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
    status { 2 } # Unconfirmed by default

    # Acceptance attributes
    terms_of_service { true }
    minimal_year_old { true }

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
    end

    trait :with_iban do
      payment_type { 3 } # IBAN
      iban_account { "ES9121000418450200051332" } # Valid Spanish IBAN
      iban_bic { "CAIXESBBXXX" }
      redsys_identifier { nil }
      redsys_expiration { nil }
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

    trait :quarterly do
      frequency { 3 }
    end

    trait :annual do
      frequency { 12 }
    end

    trait :incomplete do
      status { 0 }
    end

    trait :error do
      status { 1 }
    end

    trait :unconfirmed do
      status { 2 }
    end

    trait :active do
      status { 3 }
    end

    trait :warning do
      status { 4 }
    end

    trait :migration do
      status { 9 }
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
      sequence(:non_user_email) { |n| "nonuser#{n}@example.com" }
      sequence(:non_user_document_vatid) { |n| "1234567#{n}Z" }
      non_user_data do
        YAML.dump(Collaboration::NonUser.new(
          full_name: "Non User Name",
          document_vatid: non_user_document_vatid || "12345678Z",
          email: non_user_email || "nonuser@example.com",
          address: "Test Address",
          town_name: "Madrid",
          postal_code: "28001",
          country: "ES",
          ine_town: "m_28_079_6"
        ))
      end

      # Skip user validations for non-user collaborations
      skip_queries_validations { true }
    end

    # Skip validations for complex scenarios
    trait :skip_validations do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
