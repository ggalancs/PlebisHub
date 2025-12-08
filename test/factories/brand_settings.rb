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

    # Use WCAG AA compliant colors (≥4.5:1 contrast ratio against white)
    trait :with_custom_colors do
      primary_color { '#2F4F4F' }        # Dark slate gray - 8.9:1 contrast
      primary_light_color { '#4F6F6F' }  # Lighter shade
      primary_dark_color { '#1F3F3F' }   # Darker shade
      secondary_color { '#000080' }      # Navy blue - 10.9:1 contrast
      secondary_light_color { '#4040A0' }
      secondary_dark_color { '#000060' }
    end

    trait :with_partial_custom_colors do
      primary_color { '#2F4F4F' }  # WCAG AA compliant
    end

    trait :with_invalid_color do
      primary_color { 'not-a-color' }
    end

    trait :with_low_contrast_color do
      primary_color { '#ffff00' } # Yellow has low contrast with white
    end
  end
end
