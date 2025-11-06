# frozen_string_literal: true

FactoryBot.define do
  factory :election_location do
    association :election
    location { "00" }
    agora_version { 0 }
    new_agora_version { 0 }

    # Optional voting info fields (not required by default)
    title { nil }
    layout { nil }
    theme { nil }
    description { nil }
    share_text { nil }

    trait :with_voting_info do
      title { "Voting Information" }
      layout { "simple" }
      theme { "default" }
      description { "Election description" }
      share_text { "Share this election" }
    end

    trait :municipal do
      location { "280790" } # Example municipal code
    end

    trait :circles do
      location { "1" } # Vote circle ID
    end
  end
end
