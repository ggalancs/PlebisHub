require "test_helper"

class ReportGroupTest < ActiveSupport::TestCase
  # PHASE 4 SECURITY REFACTORING TESTS - JSON-based transformations (SAFE MODE)

  # Mock row object for testing
  class MockRow
    attr_accessor :name, :email, :amount, :created_at

    def initialize(name:, email:, amount:, created_at:)
      @name = name
      @email = email
      @amount = amount
      @created_at = created_at
    end
  end

  test "should process JSON transformations with upcase" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'name', transformations: ['upcase'], output: 'NAME' },
          { source: 'email', transformations: [], output: 'EMAIL' }
        ]
      }.to_json,
      width: 20
    )

    row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.now)

    result = group.process(row)

    assert_equal 2, result.size
    assert_equal ['NAME', 'JOHN'], result[0]
    assert_equal ['EMAIL', 'john@test.com'], result[1]
  end

  test "should process JSON transformations with multiple transforms" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'name', transformations: ['upcase', 'strip'], output: 'NAME' }
        ]
      }.to_json,
      width: 20
    )

    row = MockRow.new(name: '  john  ', email: 'john@test.com', amount: 100, created_at: Time.now)

    result = group.process(row)

    assert_equal ['NAME', 'JOHN'], result[0]
  end

  test "should process JSON transformations with format" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'amount', transformations: ['to_s'], format: 'currency', output: 'AMOUNT' }
        ]
      }.to_json,
      width: 20
    )

    row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100.50, created_at: Time.now)

    result = group.process(row)

    assert_equal ['AMOUNT', '100.50'], result[0]
  end

  test "should process JSON transformations with date format" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'created_at', transformations: [], format: 'date', output: 'DATE' }
        ]
      }.to_json,
      width: 20
    )

    date = Time.parse('2025-01-15')
    row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: date)

    result = group.process(row)

    assert_equal ['DATE', '2025-01-15'], result[0]
  end

  test "should process JSON transformations with truncate" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'name', transformations: ['truncate'], output: 'NAME' }
        ]
      }.to_json,
      width: 20
    )

    long_name = 'a' * 100
    row = MockRow.new(name: long_name, email: 'john@test.com', amount: 100, created_at: Time.now)

    result = group.process(row)

    # truncate defaults to 50 chars with "..."
    assert result[0][1].length <= 53 # 50 + "..."
    assert_includes result[0][1], '...'
  end

  test "should process JSON transformations with integer format" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'amount', transformations: [], format: 'integer', output: 'AMOUNT' }
        ]
      }.to_json,
      width: 20
    )

    row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100.99, created_at: Time.now)

    result = group.process(row)

    assert_equal ['AMOUNT', '100'], result[0]
  end

  # SECURITY TESTS

  test "should not allow arbitrary code execution through transformation_rules" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'name', transformations: ['system'], output: 'NAME' }
        ]
      }.to_json,
      width: 20
    )

    row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.now)

    # Should not raise exception, transformation should be ignored
    result = group.process(row)

    # Should still return data, just without the invalid transformation
    assert_equal 1, result.size
    assert_equal ['NAME', 'john'], result[0]
  end

  test "should not allow non-whitelisted transformations" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'name', transformations: ['eval'], output: 'NAME' }
        ]
      }.to_json,
      width: 20
    )

    row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.now)

    # Transformation should be ignored since 'eval' is not whitelisted
    result = group.process(row)

    assert_equal ['NAME', 'john'], result[0]
  end

  test "should handle invalid JSON gracefully" do
    group = ReportGroup.new(
      transformation_rules: "invalid json{{{",
      width: 20
    )
    group.id = 1 # Simulate persisted

    row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.now)

    Rails.logger.expects(:error).with(regexp_matches(/Invalid JSON in ReportGroup/))

    result = group.process(row)

    assert_equal [["ERROR", "ERROR"]], result
  end

  test "should handle missing source field gracefully" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'non_existent_field', transformations: [], output: 'FIELD' }
        ]
      }.to_json,
      width: 20
    )

    row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.now)

    Rails.logger.expects(:error).with(regexp_matches(/Failed to extract/))

    result = group.process(row)

    # Should return nil for non-existent field
    assert_equal ['FIELD', ''], result[0]
  end

  # VALIDATION TESTS

  test "should validate transformation_rules must have columns array" do
    group = ReportGroup.new(
      transformation_rules: { invalid: 'structure' }.to_json
    )

    assert_not group.valid?
    assert_includes group.errors[:transformation_rules], "must have 'columns' array"
  end

  test "should validate each column must have source" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { transformations: [], output: 'NAME' }
        ]
      }.to_json
    )

    assert_not group.valid?
    assert_includes group.errors[:transformation_rules], "each column must have 'source'"
  end

  test "should validate each column must have output" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'name', transformations: [] }
        ]
      }.to_json
    )

    assert_not group.valid?
    assert_includes group.errors[:transformation_rules], "each column must have 'output'"
  end

  test "should validate transformations are whitelisted" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'name', transformations: ['invalid_transform'], output: 'NAME' }
        ]
      }.to_json
    )

    assert_not group.valid?
    assert_includes group.errors[:transformation_rules], "transformation 'invalid_transform' not allowed"
  end

  test "should validate formats are whitelisted" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'name', transformations: [], format: 'invalid_format', output: 'NAME' }
        ]
      }.to_json
    )

    assert_not group.valid?
    assert_includes group.errors[:transformation_rules], "format 'invalid_format' not allowed"
  end

  test "should validate transformation_rules must be valid JSON" do
    group = ReportGroup.new(
      transformation_rules: "not json"
    )

    assert_not group.valid?
    assert_includes group.errors[:transformation_rules], "must be valid JSON"
  end

  # LEGACY MODE TESTS (eval() backward compatibility)

  test "should still work with legacy eval() mode (deprecated)" do
    group = ReportGroup.new(
      proc: "[[row.name.upcase, row.email]]",
      width: 20
    )
    group.id = 1 # Simulate persisted

    # Expect deprecation warning
    Rails.logger.expects(:warn).with(regexp_matches(/deprecated eval/)).at_least_once

    row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.now)

    # Should still work but log warnings
    result = group.process(row)

    assert_equal [['JOHN', 'john@test.com']], result
  end

  # HELPER METHOD TESTS

  test "format_group_name should pad and truncate correctly" do
    group = ReportGroup.new(width: 10)

    assert_equal 'short     ', group.format_group_name('short')
    assert_equal 'verylongna', group.format_group_name('verylongname')
    assert_equal '1234567890', group.format_group_name('1234567890')
  end

  test "get_whitelist should split lines correctly" do
    group = ReportGroup.new(whitelist: "item1\r\nitem2\r\nitem3")

    assert_equal ['item1', 'item2', 'item3'], group.get_whitelist
  end

  test "get_blacklist should split lines correctly" do
    group = ReportGroup.new(blacklist: "bad1\r\nbad2")

    assert_equal ['bad1', 'bad2'], group.get_blacklist
  end

  test "whitelist? should check if value is whitelisted" do
    group = ReportGroup.new(whitelist: "allowed1\r\nallowed2")

    assert group.whitelist?('allowed1')
    assert_not group.whitelist?('notallowed')
  end

  test "blacklist? should check if value is blacklisted" do
    group = ReportGroup.new(blacklist: "blocked1\r\nblocked2")

    assert group.blacklist?('blocked1')
    assert_not group.blacklist?('okay')
  end

  # SERIALIZE/UNSERIALIZE TESTS

  test "self.serialize should serialize single group" do
    group = ReportGroup.new(width: 10, minimum: 5)
    serialized = ReportGroup.serialize(group)

    assert_kind_of String, serialized
    assert_includes serialized, 'width: 10'
  end

  test "self.serialize should serialize array of groups" do
    group1 = ReportGroup.new(width: 10)
    group2 = ReportGroup.new(width: 20)
    serialized = ReportGroup.serialize([group1, group2])

    assert_kind_of String, serialized
  end

  test "self.unserialize should unserialize single group" do
    group = ReportGroup.new(width: 10, minimum: 5)
    serialized = ReportGroup.serialize(group)
    unserialized = ReportGroup.unserialize(serialized)

    assert_kind_of ReportGroup, unserialized
    assert_equal 10, unserialized.width
    assert_equal 5, unserialized.minimum
  end

  test "self.unserialize should unserialize array of groups" do
    group1 = ReportGroup.new(width: 10)
    group2 = ReportGroup.new(width: 20)
    serialized = ReportGroup.serialize([group1, group2])
    unserialized = ReportGroup.unserialize(serialized)

    assert_kind_of Array, unserialized
    assert_equal 2, unserialized.size
    assert_kind_of ReportGroup, unserialized[0]
    assert_kind_of ReportGroup, unserialized[1]
  end

  # ERROR HANDLING TESTS

  test "should handle exception in process gracefully" do
    group = ReportGroup.new(
      transformation_rules: {
        columns: [
          { source: 'name', transformations: [], output: 'NAME' }
        ]
      }.to_json,
      width: 20
    )
    group.id = 1

    # Simulate error by passing nil row
    Rails.logger.expects(:error).at_least_once

    result = group.process(nil)

    assert_equal [["ERROR", "ERROR"]], result
  end
end
