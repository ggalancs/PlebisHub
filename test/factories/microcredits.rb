FactoryBot.define do
  factory :microcredit, class: 'PlebisMicrocredit::Microcredit' do
    sequence(:title) { |n| "Microcredit #{n}" }
    starts_at { 1.month.ago }
    ends_at { 1.month.from_now }
    limits { "100€: 10\n500€: 5\n1000€: 2" }
    account_number { "ES6621000418401234567891" }

    trait :active do
      starts_at { 1.week.ago }
      ends_at { 1.week.from_now }
    end

    trait :upcoming do
      starts_at { 1.day.from_now }
      ends_at { 1.month.from_now }
    end

    trait :finished do
      starts_at { 2.months.ago }
      ends_at { 1.month.ago }
    end

    trait :with_mailing do
      mailing { true }
    end
  end
end
