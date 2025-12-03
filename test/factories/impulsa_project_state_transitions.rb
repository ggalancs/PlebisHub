FactoryBot.define do
  factory :impulsa_project_state_transition, class: 'ImpulsaProjectStateTransition' do
    association :impulsa_project
    namespace { "impulsa_project" }
    event { "submit" }
    from { "draft" }
    to { "submitted" }
  end
end
