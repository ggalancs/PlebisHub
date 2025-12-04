# frozen_string_literal: true

FactoryBot.define do
  factory :impulsa_project_topic, class: 'ImpulsaProjectTopic' do
    association :impulsa_project
    association :impulsa_edition_topic
  end
end
