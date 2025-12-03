FactoryBot.define do
  factory :impulsa_project, class: 'ImpulsaProject' do
    association :impulsa_edition_category
    association :user
    association :evaluator1, factory: :user
    association :evaluator2, factory: :user
    sequence(:name) { |n| "Project #{n}" }
    status { 0 }
    # Rails 7.2: Acceptance validations require string "1" instead of boolean true
    terms_of_service { "1" }
    data_truthfulness { "1" }
    content_rights { "1" }
  end
end
