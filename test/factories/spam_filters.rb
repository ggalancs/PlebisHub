# frozen_string_literal: true

FactoryBot.define do
  factory :spam_filter do
    sequence(:name) { |n| "Spam Filter #{n}" }
    active { true }
    query { '' }
    data { '' }

    # Default to safe mode with JSON rules
    rules_json do
      {
        conditions: [
          { field: 'email', operator: 'contains', value: 'spam' }
        ],
        logic: 'AND'
      }.to_json
    end

    trait :inactive do
      active { false }
    end

    trait :legacy_mode do
      rules_json { nil }
      code { "user.email.include?('spam')" }
      data { '' }
    end

    trait :with_data_list do
      data { "spam@test.com\nbad@test.com\nfake@test.com" }
      rules_json do
        {
          conditions: [
            { field: 'email', operator: 'in_list', value: 'DATA_LIST' }
          ],
          logic: 'AND'
        }.to_json
      end
    end

    trait :email_contains_spam do
      rules_json do
        {
          conditions: [
            { field: 'email', operator: 'contains', value: 'spam' }
          ],
          logic: 'AND'
        }.to_json
      end
    end

    trait :multiple_conditions do
      rules_json do
        {
          conditions: [
            { field: 'email', operator: 'contains', value: 'test' },
            { field: 'country', operator: 'equals', value: 'ES' }
          ],
          logic: 'AND'
        }.to_json
      end
    end

    trait :or_logic do
      rules_json do
        {
          conditions: [
            { field: 'email', operator: 'contains', value: 'spam' },
            { field: 'first_name', operator: 'equals', value: 'Spammer' }
          ],
          logic: 'OR'
        }.to_json
      end
    end
  end
end
