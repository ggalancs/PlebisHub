FactoryBot.define do
  factory :impulsa_edition do
    sequence(:name) { |n| "Impulsa Edition #{n}" }
    sequence(:email) { |n| "impulsa#{n}@example.com" }
    start_at { 1.month.ago }
    ends_at { 1.month.from_now }

    trait :active do
      start_at { 1.month.ago }
      ends_at { 1.month.from_now }
    end

    trait :upcoming do
      start_at { 1.month.from_now }
      ends_at { 3.months.from_now }
    end

    trait :previous do
      start_at { 3.months.ago }
      ends_at { 1.month.ago }
    end
  end
end
