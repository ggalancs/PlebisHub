FactoryBot.define do
  factory :impulsa_edition_topic do
    association :impulsa_edition
    sequence(:name) { |n| "Topic #{n}" }

  end
end
