 FactoryBot.define do
  factory :support, class: 'Support' do
    association :user
    association :proposal

    trait :old do
      created_at { 2.years.ago }
    end

    trait :recent do
      created_at { 1.day.ago }
    end

    trait :for_active_proposal do
      association :proposal, factory: [:proposal, :active]
    end

    trait :for_finished_proposal do
      association :proposal, factory: [:proposal, :finished]
    end
  end
end
