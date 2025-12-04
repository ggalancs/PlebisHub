# frozen_string_literal: true

FactoryBot.define do
  factory :vote do
    # Use create strategy for associations to ensure they have IDs
    # before vote validation runs (voter_id generation needs user_id and election_id)
    user { create(:user) }
    election { create(:election) }
    paper_authority { create(:user) }

    # voter_id and agora_id are generated automatically by before_validation callback

    # Ensure election has at least one election_location
    after(:build) do |vote|
      create(:election_location, election: vote.election) if vote.election && vote.election.election_locations.empty?
    end

    trait :deleted do
      deleted_at { 1.day.ago }
    end
  end
end
