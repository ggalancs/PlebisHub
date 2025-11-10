FactoryBot.define do
  factory :microcredit_loan do
    association :microcredit
    association :user, :with_dni
    association :microcredit_option

    amount { 100 }
    iban_account { "ES9121000418450200051332" }
    iban_bic { "CAIXESBBXXX" }
    ip { "192.168.1.1" }

    # Terms acceptance
    terms_of_service { true }
    minimal_year_old { true }

    # When creating with user, these virtual attrs are set automatically from user
    # When creating without user, they need to be set manually (see :without_user trait)

    trait :without_user do
      user { nil }

      # Spanish DNI format: 8 digits + check letter
      transient do
        dni_number { rand(10000000..99999999) }
      end

      document_vatid do
        dni_letters = "TRWAGMYFPDXBNJZSQVHLCKE"
        letter = dni_letters[dni_number % 23]
        "#{dni_number}#{letter}"
      end

      # Virtual attributes that are validated when user is nil
      first_name { "Juan" }
      last_name { "García" }
      sequence(:email) { |n| "loan_user_#{n}@example.com" }
      address { "Calle Mayor 1" }
      postal_code { "28001" }
      town { "Madrid" }
      province { "Madrid" }
      country { "ES" }
    end

    trait :confirmed do
      confirmed_at { 1.day.ago }
    end

    trait :counted do
      counted_at { 1.day.ago }
      confirmed_at { 2.days.ago }
    end

    trait :discarded do
      discarded_at { 1.day.ago }
    end

    trait :returned do
      returned_at { 1.day.ago }
      confirmed_at { 1.month.ago }
    end

    trait :with_transfer do
      association :transferred_to, factory: :microcredit_loan
    end

    trait :international_iban do
      iban_account { "GB82WEST12345698765432" }
      iban_bic { "WESTGB12XXX" }
    end

    trait :invalid_iban do
      iban_account { "ES9999999999999999999999" }
    end
  end
end
