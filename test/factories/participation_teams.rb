FactoryBot.define do
  factory :participation_team, class: 'PlebisParticipation::ParticipationTeam' do
    sequence(:name) { |n| "Team #{n}" }
    description { "Team description" }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :with_users do
      transient do
        users_count { 3 }
      end

      after(:create) do |team, evaluator|
        create_list(:user, evaluator.users_count, participation_teams: [team])
      end
    end
  end
end
