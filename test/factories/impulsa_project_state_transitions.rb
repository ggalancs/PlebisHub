FactoryBot.define do
  factory :impulsa_project_state_transition do
    association :impulsa_project
    namespace { "impulsa_project" }
    event { "submit" }
    from { "draft" }
    to { "submitted" }
  end
end
