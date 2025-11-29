FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    email_confirmation { email }
    password { "password123" }
    password_confirmation { "password123" }

    sequence(:first_name) { |n| "First#{n}" }
    sequence(:last_name) { |n| "Last#{n}" }

    # Document information
    document_type { 3 } # Passport/Other (avoids Spanish DNI/NIE validation)
    sequence(:document_vatid) { |n| "PASS#{12345678 + n}" }

    # Address information (using a non-Spanish country to avoid complex postal code validation)
    address { "123 Main Street" }
    town { "Berlin" }
    province { "BE" }
    postal_code { "10115" }
    country { "DE" } # Germany - avoids Spanish postal code validation

    # Age verification
    born_at { 25.years.ago }

    # Phone confirmation (German phone for consistency)
    sequence(:phone) { |n| "+4915#{n.to_s.rjust(9, '0')}" }

    # Devise confirmations
    confirmed_at { 1.day.ago }
    sms_confirmed_at { 1.day.ago }

    # Required acceptances
    terms_of_service { true }
    over_18 { true }
    checked_vote_circle { true }

    # Association
    association :vote_circle

    trait :unconfirmed do
      confirmed_at { nil }
      sms_confirmed_at { nil }
    end

    trait :confirmed do
      confirmed_at { 1.day.ago }
      sms_confirmed_at { 1.day.ago }
    end

    trait :email_confirmed_only do
      confirmed_at { 1.day.ago }
      sms_confirmed_at { nil }
    end

    trait :phone_confirmed_only do
      confirmed_at { nil }
      sms_confirmed_at { 1.day.ago }
    end

    trait :barcelona do
      town { "Barcelona" }
      province { "08" }
      postal_code { "08001" }
    end

    # RAILS 7.2 FIX: Add :admin trait for vote_controller specs
    trait :admin do
      after(:create) do |user|
        user.update_column(:flags, user.flags | 1) # admin flag
      end
    end

    trait :superadmin do
      after(:create) do |user|
        user.update_column(:flags, user.flags | 2) # superadmin flag
      end
    end

    trait :with_dni do
      document_type { 1 } # DNI
      sequence(:document_vatid) do |n|
        letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
        number = 12345670 + (n % 99)
        checksum = letters[number % 23]
        "#{number}#{checksum}"
      end
      country { "ES" }
      province { "08" } # Barcelona
      postal_code { "08001" }
      town { "Barcelona" }
    end

    trait :with_nie do
      document_type { 2 } # NIE
      sequence(:document_vatid) do |n|
        letters = 'TRWAGMYFPDXBNJZSQVHLCKE'
        prefix = 'X'
        number_str = (n % 9999999).to_s.rjust(7, '0')
        # For NIE, replace X with 0, Y with 1, Z with 2 for checksum calculation
        calc_number = "0#{number_str}".to_i
        checksum = letters[calc_number % 23]
        "#{prefix}#{number_str}#{checksum}"
      end
      country { "ES" }
      province { "08" } # Barcelona
      postal_code { "08001" }
      town { "Barcelona" }
    end
  end
end
