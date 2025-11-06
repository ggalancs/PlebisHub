FactoryBot.define do
  factory :notice do
    sequence(:title) { |n| "Notice Title #{n}" }
    sequence(:body) { |n| "This is the body content for notice #{n}. It contains important information for users." }

    # Optional fields
    link { nil }
    final_valid_at { nil }
    sent_at { nil }

    # Traits for different notice states
    trait :with_link do
      link { "https://example.com/notice" }
    end

    trait :sent do
      sent_at { 1.hour.ago }
    end

    trait :pending do
      sent_at { nil }
    end

    trait :active do
      final_valid_at { 1.week.from_now }
    end

    trait :expired do
      final_valid_at { 1.day.ago }
    end

    trait :without_expiration do
      final_valid_at { nil }
    end

    trait :recently_created do
      created_at { 1.hour.ago }
      updated_at { 1.hour.ago }
    end

    trait :old do
      created_at { 1.month.ago }
      updated_at { 1.month.ago }
    end

    # Combined traits for common scenarios
    trait :sent_active do
      sent
      active
    end

    trait :pending_active do
      pending
      active
    end

    trait :sent_expired do
      sent
      expired
    end
  end
end
