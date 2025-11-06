FactoryBot.define do
  factory :microcredit_option do
    association :microcredit
    sequence(:name) { |n| "Option #{n}" }

    trait :with_parent do
      association :parent, factory: :microcredit_option
    end

    trait :root do
      parent { nil }
    end
  end
end
