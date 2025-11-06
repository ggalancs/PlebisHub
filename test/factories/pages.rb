FactoryBot.define do
  factory :page do
    sequence(:title) { |n| "Page Title #{n}" }
    sequence(:id_form) { |n| n }
    sequence(:slug) { |n| "page-slug-#{n}" }

    # Default values
    require_login { false }
    promoted { false }
    priority { 0 }

    # Optional fields
    link { nil }
    meta_description { nil }
    meta_image { nil }
    text_button { nil }

    # Traits for different page types
    trait :promoted do
      promoted { true }
      priority { 10 }
    end

    trait :with_high_priority do
      priority { 100 }
    end

    trait :requires_login do
      require_login { true }
    end

    trait :with_external_link do
      link { "https://forms.plebisbrand.info/some-form/" }
    end

    trait :with_meta_data do
      meta_description { "A comprehensive description for SEO purposes" }
      meta_image { "https://example.com/image.jpg" }
    end

    trait :with_text_button do
      text_button { "Click here to participate" }
    end

    trait :deleted do
      deleted_at { Time.current }
    end
  end
end
