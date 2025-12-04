# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    sequence(:query) { |n| "SELECT * FROM users WHERE id = #{n} LIMIT 10" }

    # Set groups to empty array serialized as YAML to avoid TypeError in ReportGroup.unserialize
    # ReportGroup.unserialize expects a string, not nil
    groups { [].to_yaml }

    # Optional fields
    main_group { nil }
    results { nil }
    version_at { nil }

    trait :with_main_group do
      main_group { { field: 'email', width: 50 }.to_yaml }
    end

    trait :with_groups do
      groups { [{ field: 'document_type', width: 10 }].to_yaml }
    end

    trait :with_results do
      results { { data: {}, errors: {} }.to_yaml }
    end

    trait :with_version do
      version_at { 1.day.ago }
    end

    trait :users_query do
      query { 'SELECT * FROM users LIMIT 100' }
    end

    trait :collaborations_query do
      query { 'SELECT * FROM collaborations LIMIT 100' }
    end

    trait :orders_query do
      query { 'SELECT * FROM orders LIMIT 100' }
    end
  end
end
