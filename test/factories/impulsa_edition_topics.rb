# frozen_string_literal: true

FactoryBot.define do
  factory :impulsa_edition_topic, class: 'ImpulsaEditionTopic' do
    association :impulsa_edition
    sequence(:name) { |n| "Topic #{n}" }
  end
end
