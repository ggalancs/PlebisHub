FactoryBot.define do
  factory :post, class: 'Post' do
    sequence(:title) { |n| "Post Title #{n}" }
    sequence(:content) { |n| "This is the content for post #{n}." }
    status { 1 } # Published by default

    # Traits for different states
    trait :draft do
      status { 0 }
    end

    trait :published do
      status { 1 }
    end

    trait :with_categories do
      after(:create) do |post|
        create_list(:category, 2, posts: [post])
      end
    end

    trait :deleted do
      deleted_at { 1.day.ago }
    end
  end
end
