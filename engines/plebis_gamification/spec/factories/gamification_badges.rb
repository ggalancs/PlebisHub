# frozen_string_literal: true

FactoryBot.define do
  factory :gamification_badge, class: 'Gamification::Badge' do
    sequence(:key) { |n| "badge_key_#{n}" }
    sequence(:name) { |n| "Badge Name #{n}" }
    icon { '🏆' }
    description { 'Test badge description' }
    category { 'test' }
    tier { 'bronze' }
    points_reward { 100 }
    criteria { { test: { gte: 1 } } }
  end
end
