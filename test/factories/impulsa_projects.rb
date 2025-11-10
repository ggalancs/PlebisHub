FactoryBot.define do
  factory :impulsa_project, class: 'PlebisImpulsa::ImpulsaProject' do
    association :impulsa_edition_category
    association :user
    association :evaluator1, factory: :user
    association :evaluator2, factory: :user
    sequence(:name) { |n| "Project #{n}" }
    status { 0 }
    terms_of_service { true }
    data_truthfulness { true }
    content_rights { true }
  end
end
