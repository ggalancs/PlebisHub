FactoryBot.define do
  factory :impulsa_edition_category, class: 'PlebisImpulsa::ImpulsaEditionCategory' do
    association :impulsa_edition
    sequence(:name) { |n| "Category #{n}" }
    category_type { 1 } # state
    winners { 3 }
    prize { 5000 }
    only_authors { false }

    trait :internal do
      category_type { 0 }
    end

    trait :state do
      category_type { 1 }
    end

    trait :territorial do
      category_type { 2 }
      after(:build) do |category|
        category[:territories] = "a_01|a_02"
      end
    end

    trait :only_authors do
      only_authors { true }
    end

    trait :with_votings do
      flags { 1 } # has_votings flag
    end

    trait :with_coofficial_language do
      coofficial_language { "ca" }
    end
  end
end
