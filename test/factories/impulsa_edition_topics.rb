FactoryBot.define do
  factory :impulsa_edition_topic, class: 'PlebisImpulsa::ImpulsaEditionTopic' do
    association :impulsa_edition
    sequence(:name) { |n| "Topic #{n}" }

  end
end
