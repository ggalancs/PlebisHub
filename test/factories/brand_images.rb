# frozen_string_literal: true

FactoryBot.define do
  factory :brand_image do
    name { 'Main Logo' }
    key { 'logo_main' }
    category { 'logo' }
    description { 'Primary logo for header' }
    active { true }
    position { 0 }
    metadata { {} }
    brand_setting { nil }
    organization { nil }

    trait :with_image do
      after(:build) do |brand_image|
        brand_image.image.attach(
          io: StringIO.new('fake image content'),
          filename: 'test_logo.png',
          content_type: 'image/png'
        )
      end
    end

    trait :favicon do
      name { 'Favicon' }
      key { 'favicon' }
      category { 'favicon' }
      description { 'Browser tab icon' }
    end

    trait :social do
      name { 'Facebook Icon' }
      key { 'social_facebook' }
      category { 'social' }
      description { 'Facebook social icon' }
    end

    trait :banner do
      name { 'Home Banner' }
      key { 'banner_home' }
      category { 'banner' }
      description { 'Main landing page banner' }
    end

    trait :inactive do
      active { false }
    end

    trait :global do
      brand_setting { nil }
      organization { nil }
    end

    trait :for_brand_setting do
      brand_setting { association(:brand_setting) }
    end
  end
end
