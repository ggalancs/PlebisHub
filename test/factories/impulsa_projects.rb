FactoryBot.define do
  factory :impulsa_project do
    association :impulsa_edition_category
    association :user
    sequence(:name) { |n| "Project #{n}" }
    status { 0 }
    terms_of_service { true }
    data_truthfulness { true }
    content_rights { true }
  end
end
