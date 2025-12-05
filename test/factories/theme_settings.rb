# frozen_string_literal: true

FactoryBot.define do
  factory :theme_setting do
    sequence(:name) { |n| "Theme #{n}" }
    primary_color { '#612d62' }
    secondary_color { '#269283' }
    accent_color { '#954e99' }
    font_primary { 'Inter' }
    font_display { 'Montserrat' }
    logo_url { 'https://example.com/logo.png' }
    favicon_url { 'https://example.com/favicon.ico' }
    custom_css { nil }
    is_active { false }

    trait :active do
      is_active { true }
    end

    trait :with_custom_css do
      custom_css { '.button { color: red; }' }
    end

    trait :ocean_theme do
      name { 'Ocean Blue' }
      primary_color { '#0EA5E9' }
      secondary_color { '#06B6D4' }
      accent_color { '#3B82F6' }
    end

    trait :forest_theme do
      name { 'Forest Green' }
      primary_color { '#22C55E' }
      secondary_color { '#10B981' }
      accent_color { '#84CC16' }
    end

    trait :minimal do
      logo_url { nil }
      favicon_url { nil }
      custom_css { nil }
      font_primary { nil }
      font_display { nil }
      accent_color { nil }
    end
  end
end
