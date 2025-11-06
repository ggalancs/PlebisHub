FactoryBot.define do
  factory :user_verification do
    association :user
    status { :pending }
    terms_of_service { true }
    wants_card { false }

    # Skip validations for tests since we can't easily create actual image files
    to_create { |instance| instance.save(validate: false) }

    trait :accepted do
      status { :accepted }
      processed_at { 1.day.ago }
    end

    trait :rejected do
      status { :rejected }
      processed_at { 1.day.ago }
      comment { "Verification rejected" }
    end

    trait :with_card do
      wants_card { true }
      born_at { 25.years.ago }
    end
  end
end
