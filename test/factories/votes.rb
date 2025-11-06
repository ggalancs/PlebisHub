# frozen_string_literal: true

FactoryBot.define do
  factory :vote do
    association :user
    association :election
    association :paper_authority, factory: :user

    # voter_id and agora_id are generated automatically by before_validation callback

    trait :deleted do
      deleted_at { 1.day.ago }
    end
  end
end
