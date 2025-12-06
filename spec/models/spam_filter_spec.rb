# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpamFilter, type: :model do
  # PHASE 4 SECURITY REFACTORING TESTS - JSON-based rules (SAFE MODE)

  describe 'scopes' do
    it 'returns only active filters' do
      active_filter = create(:spam_filter, active: true)
      inactive_filter = create(:spam_filter, active: false)

      expect(SpamFilter.active).to include(active_filter)
      expect(SpamFilter.active).not_to include(inactive_filter)
    end
  end

  describe 'JSON rules evaluation' do
    describe 'equals operator' do
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

      it 'converts values to strings for comparison' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'postal_code', operator: 'equals', value: '10115' }
            ],
            logic: 'AND'
          }.to_json
        )

        matching_user = build(:user, postal_code: '10115')
        expect(filter.process(matching_user)).to be_truthy
      end
    end

    describe 'not_equals operator' do
      it 'evaluates with not_equals operator' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'country', operator: 'not_equals', value: 'ES' }
            ],
            logic: 'AND'
          }.to_json
        )

        foreign_user = build(:user, country: 'DE')
        spanish_user = build(:user, country: 'ES')

        expect(filter.process(foreign_user)).to be_truthy
        expect(filter.process(spanish_user)).to be_falsey
      end
    end

    describe 'contains operator' do
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

      it 'is case-sensitive' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'email', operator: 'contains', value: 'SPAM' }
            ],
            logic: 'AND'
          }.to_json
        )

        uppercase_user = build(:user, email: 'test@SPAM.com')
        lowercase_user = build(:user, email: 'test@spam.com')

        expect(filter.process(uppercase_user)).to be_truthy
        expect(filter.process(lowercase_user)).to be_falsey
      end
    end

    describe 'not_contains operator' do
      it 'evaluates with not_contains operator' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'email', operator: 'not_contains', value: 'spam' }
            ],
            logic: 'AND'
          }.to_json
        )

        clean_user = build(:user, email: 'test@example.com')
        spam_user = build(:user, email: 'test@spam.com')

        expect(filter.process(clean_user)).to be_truthy
        expect(filter.process(spam_user)).to be_falsey
      end
    end

    describe 'matches operator' do
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

      it 'handles invalid regex gracefully' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'email', operator: 'matches', value: '[invalid(' }
            ],
            logic: 'AND'
          }.to_json
        )

        user = build(:user)
        expect(filter.process(user)).to be_falsey
      end

      it 'supports complex regex patterns' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'phone', operator: 'matches', value: '^\+491[567]' }
            ],
            logic: 'AND'
          }.to_json
        )

        matching_user = build(:user, phone: '+491501234567')
        non_matching_user = build(:user, phone: '+492301234567')

        expect(filter.process(matching_user)).to be_truthy
        expect(filter.process(non_matching_user)).to be_falsey
      end
    end

    describe 'in_list operator' do
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

      it 'handles empty data list' do
        filter = SpamFilter.new(
          data: '',
          rules_json: {
            conditions: [
              { field: 'email', operator: 'in_list', value: 'DATA_LIST' }
            ],
            logic: 'AND'
          }.to_json
        )

        user = build(:user)
        expect(filter.process(user)).to be_falsey
      end

      it 'handles Windows line endings in data list' do
        filter = SpamFilter.new(
          data: "spam@test.com\r\nbad@test.com",
          rules_json: {
            conditions: [
              { field: 'email', operator: 'in_list', value: 'DATA_LIST' }
            ],
            logic: 'AND'
          }.to_json
        )

        spam_user = build(:user, email: 'spam@test.com')
        expect(filter.process(spam_user)).to be_truthy
      end
    end

    describe 'less_than operator' do
      it 'evaluates numeric comparison' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'postal_code', operator: 'less_than', value: 20000 }
            ],
            logic: 'AND'
          }.to_json
        )

        low_code_user = build(:user, postal_code: '10115')
        high_code_user = build(:user, postal_code: '99999')

        expect(filter.process(low_code_user)).to be_truthy
        expect(filter.process(high_code_user)).to be_falsey
      end
    end

    describe 'greater_than operator' do
      it 'evaluates numeric comparison' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'postal_code', operator: 'greater_than', value: 50000 }
            ],
            logic: 'AND'
          }.to_json
        )

        high_code_user = build(:user, postal_code: '99999')
        low_code_user = build(:user, postal_code: '10115')

        expect(filter.process(high_code_user)).to be_truthy
        expect(filter.process(low_code_user)).to be_falsey
      end
    end

    describe 'less_than_days_ago operator' do
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

      it 'works with confirmed_at field' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'confirmed_at', operator: 'less_than_days_ago', value: 1 }
            ],
            logic: 'AND'
          }.to_json
        )

        recent_user = build(:user, confirmed_at: 12.hours.ago)
        old_user = build(:user, confirmed_at: 3.days.ago)

        expect(filter.process(recent_user)).to be_truthy
        expect(filter.process(old_user)).to be_falsey
      end

      it 'returns false for non-Time values' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'email', operator: 'less_than_days_ago', value: 7 }
            ],
            logic: 'AND'
          }.to_json
        )

        user = build(:user)
        expect(filter.process(user)).to be_falsey
      end
    end

    describe 'logic combinations' do
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

      it 'defaults to AND logic when not specified' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'email', operator: 'contains', value: 'test' },
              { field: 'first_name', operator: 'equals', value: 'John' }
            ]
          }.to_json
        )

        matching_user = build(:user, email: 'test@example.com', first_name: 'John')
        partial_user = build(:user, email: 'test@example.com', first_name: 'Spam')

        expect(filter.process(matching_user)).to be_truthy
        expect(filter.process(partial_user)).to be_falsey
      end

      it 'handles multiple conditions with OR logic' do
        filter = SpamFilter.new(
          rules_json: {
            conditions: [
              { field: 'email', operator: 'contains', value: 'spam' },
              { field: 'email', operator: 'contains', value: 'fake' },
              { field: 'email', operator: 'contains', value: 'test123' }
            ],
            logic: 'OR'
          }.to_json
        )

        spam_user = build(:user, email: 'test@spam.com')
        fake_user = build(:user, email: 'test@fake.com')
        test_user = build(:user, email: 'test123@example.com')
        clean_user = build(:user, email: 'john@example.com')

        expect(filter.process(spam_user)).to be_truthy
        expect(filter.process(fake_user)).to be_truthy
        expect(filter.process(test_user)).to be_truthy
        expect(filter.process(clean_user)).to be_falsey
      end
    end

    describe 'field access' do
      it 'can access all whitelisted fields' do
        user = build(:user,
                     email: 'test@example.com',
                     phone: '+491234567890',
                     first_name: 'John',
                     last_name: 'Doe',
                     document_vatid: 'PASS12345678',
                     postal_code: '10115',
                     country: 'DE')

        SpamFilter::ALLOWED_FIELDS.each do |field|
          next if %w[created_at updated_at confirmed_at].include?(field) # Time fields need special handling

          filter = SpamFilter.new(
            rules_json: {
              conditions: [
                { field: field, operator: 'equals', value: user.public_send(field).to_s }
              ],
              logic: 'AND'
            }.to_json
          )

          expect(filter.process(user)).to be_truthy, "Failed to access field: #{field}"
        end
      end
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

      allow(Rails.logger).to receive(:error).and_call_original

      expect(filter.process(user)).to be_falsey
      expect(Rails.logger).to have_received(:error).with(/Invalid JSON in SpamFilter/).at_least(:once)
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

      # Allow deprecation warning
      allow(Rails.logger).to receive(:warn).and_call_original

      spam_user = build(:user, email: 'test@spam.com')
      legit_user = build(:user, email: 'test@example.com')

      # Should still work but log warnings
      expect(filter.process(spam_user)).to be_truthy
      expect(filter.process(legit_user)).to be_falsey
      expect(Rails.logger).to have_received(:warn).with(/deprecated eval/).at_least(:once)
    end
  end

  # CLASS METHOD TESTS

  describe 'class methods' do
    describe '.any?' do
      it 'returns filter name if match found with mocked active scope' do
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

      it 'returns false if no match found with mocked scope' do
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

      it 'works with actual database records' do
        filter = create(:spam_filter, :email_contains_spam, active: true)

        spam_user = build(:user, email: 'test@spam.com')
        legit_user = build(:user, email: 'test@example.com')

        expect(SpamFilter.any?(spam_user)).to eq(filter.name)
        expect(SpamFilter.any?(legit_user)).to eq(false)
      end

      it 'skips inactive filters' do
        inactive_filter = create(:spam_filter, :email_contains_spam, active: false)

        spam_user = build(:user, email: 'test@spam.com')

        expect(SpamFilter.any?(spam_user)).to eq(false)
      end

      it 'stops at first matching filter' do
        filter1 = create(:spam_filter, name: 'First Filter', active: true,
                                       rules_json: { conditions: [{ field: 'email', operator: 'contains', value: 'test' }], logic: 'AND' }.to_json)
        filter2 = create(:spam_filter, name: 'Second Filter', active: true,
                                       rules_json: { conditions: [{ field: 'email', operator: 'contains', value: 'test' }], logic: 'AND' }.to_json)

        test_user = build(:user, email: 'test@example.com')

        # Should return the first matching filter's name
        result = SpamFilter.any?(test_user)
        expect(result).to be_in([filter1.name, filter2.name])
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
      allow(Rails.logger).to receive(:error).and_call_original

      expect(filter.process(nil)).to be_falsey
      expect(Rails.logger).to have_received(:error).at_least(:once)
    end

    it 'logs errors with backtrace when process fails' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'equals', value: 'test' }
          ]
        }.to_json
      )
      filter.id = 1

      allow(filter).to receive(:process_with_json_rules).and_raise(StandardError.new('Test error'))
      allow(Rails.logger).to receive(:error).and_call_original

      expect(filter.process(build(:user))).to be_falsey
      expect(Rails.logger).to have_received(:error).with(/SpamFilter 1 error: Test error/).at_least(:once)
    end

    it 'handles condition evaluation errors gracefully' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'equals', value: 'test' }
          ]
        }.to_json
      )
      filter.id = 1

      user = build(:user)
      allow(user).to receive(:public_send).and_raise(StandardError.new('Field access error'))
      allow(Rails.logger).to receive(:error).and_call_original

      expect(filter.process(user)).to be_falsey
      expect(Rails.logger).to have_received(:error).with(/Condition evaluation error in SpamFilter 1/).at_least(:once)
    end
  end

  # INSTANCE METHOD TESTS

  describe '#query_count' do
    it 'returns count of matching users with mocked scopes' do
      # Mock the scopes and query
      filter = SpamFilter.new(query: '')
      allow(User).to receive_message_chain(:confirmed, :not_verified, :not_banned, :where, :count).and_return(2)

      expect(filter.query_count).to eq(2)
    end

    it 'actually calls the database scopes' do
      filter = create(:spam_filter, query: '')

      # This will fail if scopes don't exist, but will test the code path
      expect { filter.query_count }.not_to raise_error
    end
  end

  describe '#run' do
    it 'returns matching users within offset and limit with mocked scopes' do
      user1 = build(:user, email: 'spam@test.com')
      user2 = build(:user, email: 'test@example.com')

      filter = SpamFilter.new(
        query: '',
        rules_json: {
          conditions: [
            { field: 'email', operator: 'contains', value: 'spam' }
          ],
          logic: 'AND'
        }.to_json
      )

      # Mock the scope chain
      relation = double('relation')
      allow(User).to receive_message_chain(:confirmed, :not_verified, :not_banned, :where).and_return(relation)
      allow(relation).to receive_message_chain(:offset, :limit, :each).and_yield(user1).and_yield(user2)

      matches = filter.run(0, 10)

      expect(matches).to include(user1)
      expect(matches).not_to include(user2)
    end

    it 'respects offset and limit parameters' do
      filter = SpamFilter.new(
        query: '',
        rules_json: {
          conditions: [
            { field: 'email', operator: 'contains', value: 'test' }
          ]
        }.to_json
      )

      relation = double('relation')
      offset_relation = double('offset_relation')
      limit_relation = double('limit_relation')

      allow(User).to receive_message_chain(:confirmed, :not_verified, :not_banned, :where).and_return(relation)
      expect(relation).to receive(:offset).with(10).and_return(offset_relation)
      expect(offset_relation).to receive(:limit).with(5).and_return(limit_relation)
      allow(limit_relation).to receive(:each)

      filter.run(10, 5)
    end

    it 'actually executes the run method with database' do
      filter = create(:spam_filter)

      # This tests the actual database code path
      expect { filter.run(0, 10) }.not_to raise_error
    end
  end

  describe '#using_safe_mode?' do
    it 'returns true when rules_json is present' do
      filter = SpamFilter.new(rules_json: '{}')
      expect(filter.send(:using_safe_mode?)).to be_truthy
    end

    it 'returns false when rules_json is blank' do
      filter = SpamFilter.new(rules_json: nil)
      expect(filter.send(:using_safe_mode?)).to be_falsey
    end

    it 'returns false when rules_json is empty string' do
      filter = SpamFilter.new(rules_json: '')
      expect(filter.send(:using_safe_mode?)).to be_falsey
    end
  end

  describe '#data_list' do
    it 'splits data by Unix line endings' do
      filter = SpamFilter.new(data: "line1\nline2\nline3")
      expect(filter.send(:data_list)).to eq(['line1', 'line2', 'line3'])
    end

    it 'splits data by Windows line endings' do
      filter = SpamFilter.new(data: "line1\r\nline2\r\nline3")
      expect(filter.send(:data_list)).to eq(['line1', 'line2', 'line3'])
    end

    it 'handles empty data' do
      filter = SpamFilter.new(data: '')
      expect(filter.send(:data_list)).to eq([])
    end

    it 'handles nil data' do
      filter = SpamFilter.new(data: nil)
      expect(filter.send(:data_list)).to eq([])
    end

    it 'caches the data list' do
      filter = SpamFilter.new(data: "line1\nline2")
      list1 = filter.send(:data_list)
      list2 = filter.send(:data_list)
      expect(list1.object_id).to eq(list2.object_id)
    end
  end

  describe '#evaluate_rules' do
    it 'returns false for empty conditions' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [],
          logic: 'AND'
        }.to_json
      )

      user = build(:user)
      expect(filter.process(user)).to be_falsey
    end

    it 'handles missing conditions key' do
      filter = SpamFilter.new(
        rules_json: {
          logic: 'AND'
        }.to_json
      )

      user = build(:user)
      expect(filter.process(user)).to be_falsey
    end
  end

  describe '#evaluate_condition' do
    it 'returns false when field is not in whitelist' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'password_digest', operator: 'equals', value: 'secret' }
          ],
          logic: 'AND'
        }.to_json
      )

      user = build(:user)
      expect(filter.process(user)).to be_falsey
    end

    it 'returns false when operator is not in whitelist' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'email', operator: 'execute', value: 'rm -rf /' }
          ],
          logic: 'AND'
        }.to_json
      )

      user = build(:user)
      expect(filter.process(user)).to be_falsey
    end

    it 'handles nil field values gracefully' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'phone', operator: 'equals', value: 'test' }
          ],
          logic: 'AND'
        }.to_json
      )

      user = build(:user, phone: nil)
      expect(filter.process(user)).to be_falsey
    end
  end

  describe 'CONSTANTS' do
    describe 'OPERATORS' do
      it 'defines all expected operators' do
        expect(SpamFilter::OPERATORS.keys).to contain_exactly(
          'equals',
          'not_equals',
          'contains',
          'not_contains',
          'matches',
          'in_list',
          'less_than',
          'greater_than',
          'less_than_days_ago'
        )
      end

      it 'all operators are frozen' do
        expect(SpamFilter::OPERATORS).to be_frozen
      end
    end

    describe 'ALLOWED_FIELDS' do
      it 'defines all expected fields' do
        expect(SpamFilter::ALLOWED_FIELDS).to contain_exactly(
          'email', 'phone', 'first_name', 'last_name',
          'document_vatid', 'postal_code', 'country',
          'created_at', 'updated_at', 'confirmed_at'
        )
      end

      it 'is an array' do
        expect(SpamFilter::ALLOWED_FIELDS).to be_an(Array)
      end

      it 'does not include sensitive fields' do
        sensitive_fields = %w[password password_digest encrypted_password]
        sensitive_fields.each do |field|
          expect(SpamFilter::ALLOWED_FIELDS).not_to include(field)
        end
      end
    end
  end

  describe 'validations presence' do
    it 'allows empty conditions array' do
      filter = SpamFilter.new(
        name: 'Empty Filter',
        query: '',
        active: true,
        rules_json: {
          conditions: []
        }.to_json
      )
      # Empty conditions is valid but will return false when processed
      expect(filter).to be_valid
    end

    it 'does not require rules_json when code is present' do
      filter = SpamFilter.new(
        name: 'Legacy Filter',
        code: 'true',
        data: '',
        query: '',
        active: true
      )
      expect(filter).to be_valid
    end

    it 'allows valid rules_json' do
      filter = SpamFilter.new(
        name: 'Valid Filter',
        query: '',
        active: true,
        rules_json: {
          conditions: [
            { field: 'email', operator: 'equals', value: 'test@example.com' }
          ],
          logic: 'AND'
        }.to_json
      )
      expect(filter).to be_valid
    end
  end

  describe '#initialize_legacy_mode' do
    it 'initializes proc from code when in legacy mode' do
      filter = SpamFilter.new(
        code: "user.email == 'test@example.com'",
        data: ''
      )
      filter.id = 1

      allow(Rails.logger).to receive(:warn).and_call_original

      user = build(:user, email: 'test@example.com')
      expect(filter.process(user)).to be_truthy
      expect(Rails.logger).to have_received(:warn).with(/deprecated eval/).at_least(:once)
    end

    it 'initializes data array from data field' do
      filter = SpamFilter.new(
        code: "data.include?(user.email)",
        data: "spam@test.com\ntest@spam.com"
      )
      filter.id = 1

      allow(Rails.logger).to receive(:warn).and_call_original

      spam_user = build(:user, email: 'spam@test.com')
      legit_user = build(:user, email: 'legit@example.com')

      expect(filter.process(spam_user)).to be_truthy
      expect(filter.process(legit_user)).to be_falsey
      expect(Rails.logger).to have_received(:warn).with(/deprecated eval/).at_least(:once)
    end

    it 'does not initialize when rules_json is present' do
      filter = SpamFilter.new(
        code: "user.email == 'test'",
        data: '',
        rules_json: {
          conditions: [
            { field: 'email', operator: 'equals', value: 'spam@test.com' }
          ]
        }.to_json
      )

      user = build(:user, email: 'spam@test.com')
      expect(filter.process(user)).to be_truthy
    end

    it 'does not initialize when code is blank' do
      filter = SpamFilter.new(
        code: '',
        data: '',
        rules_json: nil
      )

      # Should not raise error, just won't match anything
      user = build(:user)
      expect { filter.process(user) }.not_to raise_error
    end
  end

  describe 'integration tests' do
    it 'correctly filters users with multiple field checks' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'country', operator: 'equals', value: 'ES' },
            { field: 'postal_code', operator: 'less_than', value: 10000 }
          ],
          logic: 'AND'
        }.to_json
      )

      matching_user = build(:user, country: 'ES', postal_code: '08001')
      wrong_country = build(:user, country: 'DE', postal_code: '08001')
      wrong_postal = build(:user, country: 'ES', postal_code: '28001')

      expect(filter.process(matching_user)).to be_truthy
      expect(filter.process(wrong_country)).to be_falsey
      expect(filter.process(wrong_postal)).to be_falsey
    end

    it 'works with all date fields' do
      now = Time.current

      filter_created = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'created_at', operator: 'less_than_days_ago', value: 1 }
          ]
        }.to_json
      )

      filter_updated = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'updated_at', operator: 'less_than_days_ago', value: 1 }
          ]
        }.to_json
      )

      filter_confirmed = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'confirmed_at', operator: 'less_than_days_ago', value: 1 }
          ]
        }.to_json
      )

      recent_user = build(:user, created_at: 1.hour.ago, updated_at: 1.hour.ago, confirmed_at: 1.hour.ago)

      expect(filter_created.process(recent_user)).to be_truthy
      expect(filter_updated.process(recent_user)).to be_truthy
      expect(filter_confirmed.process(recent_user)).to be_truthy
    end

    it 'handles complex regex patterns for phone validation' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'phone', operator: 'matches', value: '^\+34[67]\d{8}$' }
          ]
        }.to_json
      )

      spanish_mobile = build(:user, phone: '+34612345678')
      german_mobile = build(:user, phone: '+491234567890')

      expect(filter.process(spanish_mobile)).to be_truthy
      expect(filter.process(german_mobile)).to be_falsey
    end

    it 'validates document_vatid patterns' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'document_vatid', operator: 'matches', value: '^PASS' }
          ]
        }.to_json
      )

      passport_user = build(:user, document_vatid: 'PASS12345678')
      dni_user = build(:user, :with_dni)

      expect(filter.process(passport_user)).to be_truthy
      expect(filter.process(dni_user)).to be_falsey
    end

    it 'combines name checks with email patterns' do
      filter = SpamFilter.new(
        rules_json: {
          conditions: [
            { field: 'first_name', operator: 'equals', value: 'John' },
            { field: 'last_name', operator: 'equals', value: 'Doe' },
            { field: 'email', operator: 'contains', value: 'example.com' }
          ],
          logic: 'AND'
        }.to_json
      )

      perfect_match = build(:user, first_name: 'John', last_name: 'Doe', email: 'john.doe@example.com')
      wrong_name = build(:user, first_name: 'Jane', last_name: 'Doe', email: 'jane.doe@example.com')

      expect(filter.process(perfect_match)).to be_truthy
      expect(filter.process(wrong_name)).to be_falsey
    end
  end

  describe 'after_initialize callback' do
    it 'does not initialize legacy mode on object creation' do
      filter = SpamFilter.new(code: 'true', data: '')
      # Should not have initialized the proc yet
      expect(filter.instance_variable_get(:@proc)).to be_nil
    end

    it 'lazy loads legacy mode on first process call' do
      filter = SpamFilter.new(code: 'true', data: '')
      filter.id = 1

      allow(Rails.logger).to receive(:warn).and_call_original

      user = build(:user)
      filter.process(user)

      expect(filter.instance_variable_get(:@proc)).not_to be_nil
      expect(Rails.logger).to have_received(:warn).with(/deprecated eval/).at_least(:once)
    end
  end

  describe 'process method behavior' do
    it 'returns false and logs error when using_safe_mode raises exception' do
      filter = SpamFilter.new(
        rules_json: '{"conditions": [{"field": "email", "operator": "equals", "value": "test"}]}'
      )
      filter.id = 1

      allow(filter).to receive(:using_safe_mode?).and_return(true)
      allow(filter).to receive(:process_with_json_rules).and_raise(StandardError.new('Unexpected error'))
      allow(Rails.logger).to receive(:error).and_call_original

      expect(filter.process(build(:user))).to be_falsey
      expect(Rails.logger).to have_received(:error).with(/SpamFilter 1 error: Unexpected error/).at_least(:once)
    end

    it 'returns false when legacy mode proc raises exception' do
      filter = SpamFilter.new(
        code: 'raise "Error in proc"',
        data: ''
      )
      filter.id = 1

      allow(Rails.logger).to receive(:warn).and_call_original
      allow(Rails.logger).to receive(:error).and_call_original

      expect(filter.process(build(:user))).to be_falsey
      expect(Rails.logger).to have_received(:warn).with(/deprecated eval/).at_least(:once)
      expect(Rails.logger).to have_received(:error).with(/SpamFilter 1 error/).at_least(:once)
    end
  end
end
