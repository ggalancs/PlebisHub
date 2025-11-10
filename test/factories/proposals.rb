 FactoryBot.define do
  factory :proposal, class: 'PlebisProposals::Proposal' do
    sequence(:title) { |n| "Proposal #{n}" }
    sequence(:description) { |n| "Description for proposal #{n}. This is a detailed explanation of what this proposal aims to achieve." }

    votes { 0 }
    # Note: supports_count is a counter_cache AND has an overridden getter method
    # Don't set it here, let Rails handle it
    hotness { 0 }
    reddit_threshold { false }
    created_at { Time.current }

    # Traits for different proposal states
    trait :active do
      created_at { 2.months.ago }
    end

    trait :finished do
      created_at { 4.months.ago }
    end

    trait :just_finished do
      created_at { 3.months.ago }
    end

    trait :reddit_threshold do
      reddit_threshold { true }
      votes { 100 }
    end

    trait :with_supports do
      after(:create) do |proposal|
        create_list(:support, 3, proposal: proposal)
      end
    end

    trait :with_many_supports do
      after(:create) do |proposal|
        create_list(:support, 50, proposal: proposal)
      end
    end

    trait :popular do
      votes { 500 }
      # supports_count will be set via counter_cache when supports are created
      after(:create) do |proposal|
        # Manually set for testing purposes
        proposal.update_column(:supports_count, 500)
      end
    end

    trait :hot do
      votes { 100 }
      created_at { 1.week.ago }
      after(:create) do |proposal|
        proposal.update_column(:supports_count, 100)
      end
    end

    trait :old do
      created_at { 2.years.ago }
    end

    trait :with_high_votes do
      votes { 1000 }
    end

    trait :discarded do
      created_at { 4.months.ago }
      # supports_count defaults to 0
    end
  end
end
