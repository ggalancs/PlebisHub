# frozen_string_literal: true

FactoryBot.define do
  factory :militant_record do
    association :user
    begin_verified { 1.year.ago }
    end_verified { nil }
    begin_payment { 1.year.ago }
    end_payment { nil }
    payment_type { 1 }
    amount { 1000 }
    is_militant { true }

    trait :ended do
      end_verified { 1.day.ago }
      end_payment { 1.day.ago }
      is_militant { false }
    end

    trait :no_payment do
      payment_type { 0 }
      amount { 0 }
    end
  end
end
