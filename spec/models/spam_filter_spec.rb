# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpamFilter, type: :model do
  # PHASE 4 SECURITY REFACTORING TESTS - JSON-based rules (SAFE MODE)

  describe 'JSON rules evaluation' do
    it 'evaluates with equals operator' do
      filter = SpamFilter.new(
        name: 'Test Filter',
        active: true,
        query: '',
        rules_json: {
          conditions: [
            { field: 'email', operator: 'equals', value: 'spam@test.com' }
          ],
          logic: 'AND'
        }.to_json
      )

      spam_user = build(:user, email: 'spam@test.com')
      legit_user = build(:user, email: 'test@example.com')

      expect(filter.process(spam_user)).to be_truthy
      expect(filter.process(legit_user)).to be_falsey
    end

    it 'evaluates with contains operator' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'contains', value: 'spam' }
          ],
          logic: 'AND'
        }.to_json
      )

      spam_user = build(:user, email: 'test@spam.com')
      legit_user = build(:user, email: 'test@example.com')

      expect(filter.process(spam_user)).to be_truthy
      expect(filter.process(legit_user)).to be_falsey
    end

    it 'evaluates with matches (regex) operator' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'matches', value: '@spam\.com$' }
          ],
          logic: 'AND'
        }.to_json
      )

      spam_user = build(:user, email: 'test@spam.com')
      legit_user = build(:user, email: 'test@example.com')

      expect(filter.process(spam_user)).to be_truthy
      expect(filter.process(legit_user)).to be_falsey
    end

    it 'evaluates with in_list operator' do
      filter = SpamFilter.new(
        data: "spam@test.com\nbad@test.com",
        rules_json: {
          conditions: [
            { field: 'email', operator: 'in_list', value: 'DATA_LIST' }
          ],
          logic: 'AND'
        }.to_json
      )

      spam_user = build(:user, email: 'spam@test.com')
      legit_user = build(:user, email: 'good@example.com')

      expect(filter.process(spam_user)).to be_truthy
      expect(filter.process(legit_user)).to be_falsey
    end

    it 'evaluates with AND logic' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'contains', value: 'test' },
            { field: 'first_name', operator: 'equals', value: 'Spam' }
          ],
          logic: 'AND'
        }.to_json
      )

      spam_user = build(:user, email: 'test@example.com', first_name: 'Spam')
      partial_user = build(:user, email: 'test@example.com', first_name: 'John')
      legit_user = build(:user, email: 'john@example.com', first_name: 'John')

      expect(filter.process(spam_user)).to be_truthy
      expect(filter.process(partial_user)).to be_falsey
      expect(filter.process(legit_user)).to be_falsey
    end

    it 'evaluates with OR logic' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'contains', value: 'spam' },
            { field: 'first_name', operator: 'equals', value: 'Spammer' }
          ],
          logic: 'OR'
        }.to_json
      )

      spam_email_user = build(:user, email: 'test@spam.com', first_name: 'John')
      spam_name_user = build(:user, email: 'test@example.com', first_name: 'Spammer')
      legit_user = build(:user, email: 'test@example.com', first_name: 'John')

      expect(filter.process(spam_email_user)).to be_truthy
      expect(filter.process(spam_name_user)).to be_truthy
      expect(filter.process(legit_user)).to be_falsey
    end

    it 'evaluates with less_than_days_ago operator' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'created_at', operator: 'less_than_days_ago', value: 7 }
          ],
          logic: 'AND'
        }.to_json
      )

      new_user = build(:user, created_at: 3.days.ago)
      old_user = build(:user, created_at: 10.days.ago)

      expect(filter.process(new_user)).to be_truthy
      expect(filter.process(old_user)).to be_falsey
    end
  end

  # SECURITY TESTS

  describe 'security' do
    it 'does not allow arbitrary code execution through rules_json' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'system', value: 'rm -rf /' }
          ],
          logic: 'AND'
        }.to_json
      )

      user = build(:user)

      # Should not raise exception, should just return false
      expect { filter.process(user) }.not_to raise_error
      expect(filter.process(user)).to be_falsey
    end

    it 'does not allow access to non-whitelisted fields' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'password', operator: 'equals', value: 'secret' }
          ],
          logic: 'AND'
        }.to_json
      )

      user = build(:user)

      # Should return false for non-whitelisted field
      expect(filter.process(user)).to be_falsey
    end

    it 'does not allow non-whitelisted operators' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'eval', value: '1+1' }
          ],
          logic: 'AND'
        }.to_json
      )

      user = build(:user)

      # Should return false for non-whitelisted operator
      expect(filter.process(user)).to be_falsey
    end

    it 'handles invalid JSON gracefully' do
      filter = SpamFilter.new(
        rules_json: 'invalid json{{{',
        name: 'Test'
      )

      user = build(:user)

      expect(Rails.logger).to receive(:error).with(/Invalid JSON in SpamFilter/)

      expect(filter.process(user)).to be_falsey
    end

    it 'handles missing conditions gracefully' do
      filter = SpamFilter.new(
        rules_json: { logic: 'AND' }.to_json
      )

      user = build(:user)

      # Should not raise, should handle empty conditions
      expect(filter.process(user)).to be_falsey
    end
  end

  # VALIDATION TESTS

  describe 'validations' do
    it 'validates rules_json structure with invalid field' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'invalid_field', operator: 'equals', value: 'test' }
          ]
        }.to_json
      )

      expect(filter).not_to be_valid
      expect(filter.errors[:rules_json]).to include("field 'invalid_field' not allowed")
    end

    it 'validates rules_json structure with invalid operator' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'invalid_op', value: 'test' }
          ]
        }.to_json
      )

      expect(filter).not_to be_valid
      expect(filter.errors[:rules_json]).to include("operator 'invalid_op' not allowed")
    end

    it 'validates rules_json must have conditions array' do
      filter = SpamFilter.new(
        rules_json: { logic: 'AND' }.to_json
      )

      expect(filter).not_to be_valid
      expect(filter.errors[:rules_json]).to include("must have 'conditions' array")
    end

    it 'validates rules_json must be valid JSON' do
      filter = SpamFilter.new(
        rules_json: 'not json'
      )

      expect(filter).not_to be_valid
      expect(filter.errors[:rules_json]).to include('must be valid JSON')
    end
  end

  # LEGACY MODE TESTS (eval() backward compatibility)

  describe 'legacy mode' do
    it 'still works with legacy eval() mode (deprecated)' do
      filter = SpamFilter.new(
        code: "user.email.include?('spam')",
        data: ''
      )
      filter.id = 1 # Simulate persisted record

      # Expect deprecation warning
      expect(Rails.logger).to receive(:warn).with(/deprecated eval/).at_least(:once)

      spam_user = build(:user, email: 'test@spam.com')
      legit_user = build(:user, email: 'test@example.com')

      # Should still work but log warnings
      expect(filter.process(spam_user)).to be_truthy
      expect(filter.process(legit_user)).to be_falsey
    end
  end

  # CLASS METHOD TESTS

  describe 'class methods' do
    describe '.any?' do
      it 'returns filter name if match found' do
        filter1 = SpamFilter.new(
          name: 'Spam Filter',
          active: true,
          query: '',
          rules_json: {
            conditions: [
              { field: 'email', operator: 'contains', value: 'spam' }
            ],
            logic: 'AND'
          }.to_json
        )

        expect(SpamFilter).to receive(:active).and_return([filter1])

        spam_user = build(:user, email: 'test@spam.com')

        expect(SpamFilter.any?(spam_user)).to eq('Spam Filter')
      end

      it 'returns false if no match found' do
        filter1 = SpamFilter.new(
          name: 'Spam Filter',
          active: true,
          query: '',
          rules_json: {
            conditions: [
              { field: 'email', operator: 'contains', value: 'spam' }
            ],
            logic: 'AND'
          }.to_json
        )

        expect(SpamFilter).to receive(:active).and_return([filter1])

        legit_user = build(:user, email: 'test@example.com')

        expect(SpamFilter.any?(legit_user)).to eq(false)
      end
    end
  end

  # ERROR HANDLING TESTS

  describe 'error handling' do
    it 'handles exception in process gracefully' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'equals', value: 'test' }
          ]
        }.to_json
      )

      # Simulate error by passing nil user
      expect(Rails.logger).to receive(:error).at_least(:once)

      expect(filter.process(nil)).to be_falsey
    end
  end
end
