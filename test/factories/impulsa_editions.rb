FactoryBot.define do
  factory :impulsa_edition, class: 'ImpulsaEdition' do
    sequence(:name) { |n| "Impulsa Edition #{n}" }
    sequence(:email) { |n| "impulsa#{n}@example.com" }
    start_at { 2.months.ago }
    new_projects_until { 1.month.ago }
    review_projects_until { 3.weeks.ago }
    validation_projects_until { 2.weeks.ago }
    votings_start_at { 1.week.ago }
    ends_at { 1.week.from_now }
    publish_results_at { 2.weeks.from_now }

    # RAILS 7.2 FIX: Add :current trait alias for :active
    # Tests use :current but factory only had :active
    trait :current do
      start_at { 1.month.ago }
      new_projects_until { 3.weeks.ago }
      review_projects_until { 2.weeks.ago }
      validation_projects_until { 1.week.ago }
      votings_start_at { 1.day.ago }
      ends_at { 1.month.from_now }
      publish_results_at { 2.months.from_now }
    end

    trait :active do
      start_at { 1.month.ago }
      new_projects_until { 3.weeks.ago }
      review_projects_until { 2.weeks.ago }
      validation_projects_until { 1.week.ago }
      votings_start_at { 1.day.ago }
      ends_at { 1.month.from_now }
      publish_results_at { 2.months.from_now }
    end

    trait :upcoming do
      start_at { 1.month.from_now }
      ends_at { 3.months.from_now }
    end

    trait :previous do
      start_at { 3.months.ago }
      new_projects_until { 10.weeks.ago }
      review_projects_until { 9.weeks.ago }
      validation_projects_until { 8.weeks.ago }
      votings_start_at { 6.weeks.ago }
      ends_at { 5.weeks.ago }
      publish_results_at { 1.month.ago }
    end
  end
end
