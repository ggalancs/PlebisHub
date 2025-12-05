# frozen_string_literal: true

FactoryBot.define do
  factory :brand_setting do
    sequence(:name) { |n| "Brand Setting #{n}" }
    description { 'Test brand setting' }
    scope { 'global' }
    theme_id { 'default' }
    active { true }
    version { 1 }
    metadata { {} }

    trait :global do
      scope { 'global' }
      organization { nil }
    end

    trait :organization_scoped do
      scope { 'organization' }
      association :organization
    end

    trait :inactive do
      active { false }
    end

    trait :with_ocean_theme do
      theme_id { 'ocean' }
    end

    trait :with_forest_theme do
      theme_id { 'forest' }
    end

    trait :with_custom_colors do
      primary_color { '#ff0000' }
      primary_light_color { '#ff6666' }
      primary_dark_color { '#cc0000' }
      secondary_color { '#00ff00' }
      secondary_light_color { '#66ff66' }
      secondary_dark_color { '#00cc00' }
    end

    trait :with_partial_custom_colors do
      primary_color { '#ff0000' }
    end

    trait :with_invalid_color do
      primary_color { 'not-a-color' }
    end

    trait :with_low_contrast_color do
      primary_color { '#ffff00' } # Yellow has low contrast with white
    end
  end
end
