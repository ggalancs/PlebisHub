# frozen_string_literal: true

FactoryBot.define do
  factory :microcredit_loan, class: 'PlebisMicrocredit::MicrocreditLoan' do
    association :microcredit
    association :user, :with_dni
    association :microcredit_option

    amount { 100 }
    iban_account { 'ES9121000418450200051332' }
    iban_bic { 'CAIXESBBXXX' }
    # RAILS 7.2 FIX: Use sequence for unique IPs to avoid check_user_limits validation failures
    sequence(:ip) { |n| "192.168.1.#{(n % 254) + 1}" }

    # Terms acceptance - Rails 7.2 requires "1" format for acceptance validation
    terms_of_service { '1' }
    minimal_year_old { '1' }

    # RAILS 7.2 FIX: Explicitly set document_vatid from user to ensure it's available
    # The after_initialize callback in the model may not run at the right time with FactoryBot
    after(:build) do |loan|
      if loan.user && loan.document_vatid.blank?
        loan.document_vatid = loan.user.document_vatid
      end
    end

    # When creating with user, these virtual attrs are set automatically from user
    # When creating without user, they need to be set manually (see :without_user trait)

    trait :without_user do
      user { nil }

      # Spanish DNI format: 8 digits + check letter
      transient do
        dni_number { rand(10_000_000..99_999_999) }
      end

      document_vatid do
        dni_letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
        letter = dni_letters[dni_number % 23]
        "#{dni_number}#{letter}"
      end

      # Virtual attributes that are validated when user is nil
      first_name { 'Juan' }
      last_name { 'García' }
      sequence(:email) { |n| "loan_user_#{n}@example.com" }
      address { 'Calle Mayor 1' }
      postal_code { '28001' }
      town { 'Madrid' }
      province { 'Madrid' }
      country { 'ES' }
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
      iban_account { 'GB82WEST12345698765432' }
      iban_bic { 'WESTGB12XXX' }
    end

    trait :invalid_iban do
      iban_account { 'ES9999999999999999999999' }
    end
  end
end
