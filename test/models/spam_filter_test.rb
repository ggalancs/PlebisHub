require "test_helper"

class SpamFilterTest < ActiveSupport::TestCase
  # PHASE 4 SECURITY REFACTORING TESTS - JSON-based rules (SAFE MODE)

  test "should evaluate JSON rules with equals operator" do
    filter = SpamFilter.new(
      name: "Test Filter",
      active: true,
      query: "",
      rules_json: {
        conditions: [
          { field: 'email', operator: 'equals', value: 'spam@test.com' }
        ],
        logic: 'AND'
      }.to_json
    )

    spam_user = build(:user, email: 'spam@test.com')
    legit_user = build(:user, email: 'test@example.com')

    assert filter.process(spam_user)
    assert_not filter.process(legit_user)
  end

  test "should evaluate JSON rules with contains operator" do
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

    assert filter.process(spam_user)
    assert_not filter.process(legit_user)
  end

  test "should evaluate JSON rules with matches (regex) operator" do
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

    assert filter.process(spam_user)
    assert_not filter.process(legit_user)
  end

  test "should evaluate JSON rules with in_list operator" do
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

    assert filter.process(spam_user)
    assert_not filter.process(legit_user)
  end

  test "should evaluate JSON rules with AND logic" do
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

    assert filter.process(spam_user)
    assert_not filter.process(partial_user)
    assert_not filter.process(legit_user)
  end

  test "should evaluate JSON rules with OR logic" do
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

    assert filter.process(spam_email_user)
    assert filter.process(spam_name_user)
    assert_not filter.process(legit_user)
  end

  test "should evaluate JSON rules with less_than_days_ago operator" do
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

    assert filter.process(new_user)
    assert_not filter.process(old_user)
  end

  # SECURITY TESTS

  test "should not allow arbitrary code execution through rules_json" do
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
    assert_nothing_raised { filter.process(user) }
    assert_not filter.process(user)
  end

  test "should not allow access to non-whitelisted fields" do
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
    assert_not filter.process(user)
  end

  test "should not allow non-whitelisted operators" do
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
    assert_not filter.process(user)
  end

  test "should handle invalid JSON gracefully" do
    filter = SpamFilter.new(
      rules_json: "invalid json{{{",
      name: "Test"
    )

    user = build(:user)

    Rails.logger.expects(:error).with(regexp_matches(/Invalid JSON in SpamFilter/))

    assert_not filter.process(user)
  end

  test "should handle missing conditions gracefully" do
    filter = SpamFilter.new(
      rules_json: { logic: 'AND' }.to_json
    )

    user = build(:user)

    # Should not raise, should handle empty conditions
    assert_not filter.process(user)
  end

  # VALIDATION TESTS

  test "should validate rules_json structure with invalid field" do
    filter = SpamFilter.new(
      rules_json: {
        conditions: [
          { field: 'invalid_field', operator: 'equals', value: 'test' }
        ]
      }.to_json
    )

    assert_not filter.valid?
    assert_includes filter.errors[:rules_json], "field 'invalid_field' not allowed"
  end

  test "should validate rules_json structure with invalid operator" do
    filter = SpamFilter.new(
      rules_json: {
        conditions: [
          { field: 'email', operator: 'invalid_op', value: 'test' }
        ]
      }.to_json
    )

    assert_not filter.valid?
    assert_includes filter.errors[:rules_json], "operator 'invalid_op' not allowed"
  end

  test "should validate rules_json must have conditions array" do
    filter = SpamFilter.new(
      rules_json: { logic: 'AND' }.to_json
    )

    assert_not filter.valid?
    assert_includes filter.errors[:rules_json], "must have 'conditions' array"
  end

  test "should validate rules_json must be valid JSON" do
    filter = SpamFilter.new(
      rules_json: "not json"
    )

    assert_not filter.valid?
    assert_includes filter.errors[:rules_json], "must be valid JSON"
  end

  # LEGACY MODE TESTS (eval() backward compatibility)

  test "should still work with legacy eval() mode (deprecated)" do
    filter = SpamFilter.new(
      code: "user.email.include?('spam')",
      data: ""
    )
    filter.id = 1 # Simulate persisted record

    # Expect deprecation warning
    Rails.logger.expects(:warn).with(regexp_matches(/deprecated eval/)).at_least_once

    spam_user = build(:user, email: 'test@spam.com')
    legit_user = build(:user, email: 'test@example.com')

    # Should still work but log warnings
    assert filter.process(spam_user)
    assert_not filter.process(legit_user)
  end

  # CLASS METHOD TESTS

  test "self.any? should return filter name if match found" do
    filter1 = SpamFilter.new(
      name: "Spam Filter",
      active: true,
      query: "",
      rules_json: {
        conditions: [
          { field: 'email', operator: 'contains', value: 'spam' }
        ],
        logic: 'AND'
      }.to_json
    )

    SpamFilter.expects(:active).returns([filter1])

    spam_user = build(:user, email: 'test@spam.com')

    assert_equal "Spam Filter", SpamFilter.any?(spam_user)
  end

  test "self.any? should return false if no match found" do
    filter1 = SpamFilter.new(
      name: "Spam Filter",
      active: true,
      query: "",
      rules_json: {
        conditions: [
          { field: 'email', operator: 'contains', value: 'spam' }
        ],
        logic: 'AND'
      }.to_json
    )

    SpamFilter.expects(:active).returns([filter1])

    legit_user = build(:user, email: 'test@example.com')

    assert_equal false, SpamFilter.any?(legit_user)
  end

  # ERROR HANDLING TESTS

  test "should handle exception in process gracefully" do
    filter = SpamFilter.new(
      rules_json: {
        conditions: [
          { field: 'email', operator: 'equals', value: 'test' }
        ]
      }.to_json
    )

    # Simulate error by passing nil user
    Rails.logger.expects(:error).at_least_once

    assert_not filter.process(nil)
  end
end
