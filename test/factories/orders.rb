# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    # Create collaboration and use its user to ensure consistency
    # Note: Using save(validate: false) because Collaboration has complex validations
    # that will be addressed when we revisit Collaboration tests with more context
    transient do
      collaboration do
        collab = build(:collaboration, :active)
        collab.save(validate: false)
        collab
      end
    end

    user { collaboration.user }
    parent { collaboration }

    payment_type { 1 } # Credit card by default
    amount { 1000 } # 10 EUR in cents
    payable_at { Date.today }
    reference { "Test Order Reference" }
    first { false }
    status { 0 } # Nueva (new)

    # Save without validation to avoid complex Collaboration validation issues
    to_create { |instance| instance.save(validate: false) }

    trait :credit_card do
      payment_type { 1 }
      payment_identifier { "999999999R" }
    end

    trait :ccc do
      payment_type { 2 }
      payment_identifier { "ES9121000418450200051332/CAIXESBBXXX" }
    end

    trait :iban do
      payment_type { 3 }
      payment_identifier { "ES9121000418450200051332/CAIXESBBXXX" }
    end

    trait :international_iban do
      payment_type { 3 }
      payment_identifier { "DE89370400440532013000/COBADEFFXXX" }
    end

    trait :first_order do
      first { true }
    end

    trait :nueva do
      status { 0 }
      payed_at { nil }
    end

    trait :sin_confirmar do
      status { 1 }
      payed_at { nil }
    end

    trait :ok do
      status { 2 }
      payed_at { Time.now }
    end

    trait :alerta do
      status { 3 }
      payed_at { Time.now }
    end

    trait :error do
      status { 4 }
      payed_at { nil }
    end

    trait :devuelta do
      status { 5 }
      payed_at { nil }
      payment_response { "MS03" }
    end

    trait :paid do
      status { 2 }
      payed_at { 1.day.ago }
    end

    trait :deleted do
      deleted_at { 1.day.ago }
    end

    trait :with_territory do
      autonomy_code { "c_01" }
      town_code { "m_28_079_6" }
      island_code { nil }
    end
  end
end
