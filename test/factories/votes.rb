# frozen_string_literal: true

FactoryBot.define do
  factory :vote do
    association :user
    association :election
    association :paper_authority, factory: :user

    # voter_id and agora_id are generated automatically by before_validation callback

    # Ensure election has at least one election_location
    after(:build) do |vote|
      if vote.election && vote.election.election_locations.empty?
        create(:election_location, election: vote.election)
      end
    end

    trait :deleted do
      deleted_at { 1.day.ago }
    end
  end
end
