# frozen_string_literal: true

FactoryBot.define do
  factory :election_location_question do
    association :election_location

    sequence(:title) { |n| "Question #{n}" }
    description { 'Select your preferred options' }
    voting_system { 'plurality-at-large' }
    totals { 'over-total-valid-votes' }
    random_order { true }
    winners { 1 }
    minimum { 0 }
    maximum { 1 }

    # Set options_headers as tab-separated string directly to avoid setter issues
    # Must be set before options to avoid calling getter with nil
    after(:build) do |question|
      question[:options_headers] = "Text\tImage URL\tURL\tDescription"
      question[:options] = "Option 1\thttp://example.com/img1.jpg\thttp://example.com/1\tDescription 1\nOption 2\thttp://example.com/img2.jpg\thttp://example.com/2\tDescription 2"
    end

    trait :pairwise do
      voting_system { 'pairwise-beta' }
      minimum { 1 }
      maximum { 3 }
      winners { 3 }
    end

    trait :multiple_winners do
      winners { 3 }
      maximum { 3 }
    end

    trait :simple_options do
      after(:build) do |question|
        question[:options_headers] = 'Text'
        question[:options] = "Yes\nNo\nAbstain"
      end
    end
  end
end
