FactoryBot.define do
  factory :impulsa_project_topic do
    association :impulsa_project
    association :impulsa_edition_topic
  end
end
