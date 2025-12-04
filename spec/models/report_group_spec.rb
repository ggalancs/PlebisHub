# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportGroup, type: :model do
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

  describe 'JSON transformations' do
    it 'processes with upcase' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'name', transformations: ['upcase'], output: 'NAME' },
            { source: 'email', transformations: [], output: 'EMAIL' }
          ]
        }.to_json,
        width: 20
      )

      row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.zone.now)

      result = group.process(row)

      expect(result.size).to eq(2)
      expect(result[0]).to eq(%w[NAME JOHN])
      expect(result[1]).to eq(['EMAIL', 'john@test.com'])
    end

    it 'processes with multiple transforms' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'name', transformations: %w[upcase strip], output: 'NAME' }
          ]
        }.to_json,
        width: 20
      )

      row = MockRow.new(name: '  john  ', email: 'john@test.com', amount: 100, created_at: Time.zone.now)

      result = group.process(row)

      expect(result[0]).to eq(%w[NAME JOHN])
    end

    it 'processes with format' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'amount', transformations: ['to_s'], format: 'currency', output: 'AMOUNT' }
          ]
        }.to_json,
        width: 20
      )

      row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100.50, created_at: Time.zone.now)

      result = group.process(row)

      expect(result[0]).to eq(['AMOUNT', '100.50'])
    end

    it 'processes with date format' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'created_at', transformations: [], format: 'date', output: 'DATE' }
          ]
        }.to_json,
        width: 20
      )

      date = Time.zone.parse('2025-01-15')
      row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: date)

      result = group.process(row)

      expect(result[0]).to eq(%w[DATE 2025-01-15])
    end

    it 'processes with truncate' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'name', transformations: ['truncate'], output: 'NAME' }
          ]
        }.to_json,
        width: 20
      )

      long_name = 'a' * 100
      row = MockRow.new(name: long_name, email: 'john@test.com', amount: 100, created_at: Time.zone.now)

      result = group.process(row)

      # truncate defaults to 50 chars with "..."
      expect(result[0][1].length).to be <= 53 # 50 + "..."
      expect(result[0][1]).to include('...')
    end

    it 'processes with integer format' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'amount', transformations: [], format: 'integer', output: 'AMOUNT' }
          ]
        }.to_json,
        width: 20
      )

      row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100.99, created_at: Time.zone.now)

      result = group.process(row)

      expect(result[0]).to eq(%w[AMOUNT 100])
    end
  end

  # SECURITY TESTS

  describe 'security' do
    it 'does not allow arbitrary code execution through transformation_rules' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'name', transformations: ['system'], output: 'NAME' }
          ]
        }.to_json,
        width: 20
      )

      row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.zone.now)

      # Should not raise exception, transformation should be ignored
      result = group.process(row)

      # Should still return data, just without the invalid transformation
      expect(result.size).to eq(1)
      expect(result[0]).to eq(%w[NAME john])
    end

    it 'does not allow non-whitelisted transformations' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'name', transformations: ['eval'], output: 'NAME' }
          ]
        }.to_json,
        width: 20
      )

      row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.zone.now)

      # Transformation should be ignored since 'eval' is not whitelisted
      result = group.process(row)

      expect(result[0]).to eq(%w[NAME john])
    end

    it 'handles invalid JSON gracefully' do
      group = ReportGroup.new(
        transformation_rules: 'invalid json{{{',
        width: 20
      )
      group.id = 1 # Simulate persisted

      row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.zone.now)

      expect(Rails.logger).to receive(:error).with(/Invalid JSON in ReportGroup/)

      result = group.process(row)

      expect(result).to eq([%w[ERROR ERROR]])
    end

    it 'handles missing source field gracefully' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'non_existent_field', transformations: [], output: 'FIELD' }
          ]
        }.to_json,
        width: 20
      )

      row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.zone.now)

      expect(Rails.logger).to receive(:error).with(/Failed to extract/)

      result = group.process(row)

      # Should return nil for non-existent field
      expect(result[0]).to eq(['FIELD', ''])
    end
  end

  # VALIDATION TESTS

  describe 'validations' do
    it 'validates transformation_rules must have columns array' do
      group = ReportGroup.new(
        transformation_rules: { invalid: 'structure' }.to_json
      )

      expect(group).not_to be_valid
      expect(group.errors[:transformation_rules]).to include("must have 'columns' array")
    end

    it 'validates each column must have source' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { transformations: [], output: 'NAME' }
          ]
        }.to_json
      )

      expect(group).not_to be_valid
      expect(group.errors[:transformation_rules]).to include("each column must have 'source'")
    end

    it 'validates each column must have output' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'name', transformations: [] }
          ]
        }.to_json
      )

      expect(group).not_to be_valid
      expect(group.errors[:transformation_rules]).to include("each column must have 'output'")
    end

    it 'validates transformations are whitelisted' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'name', transformations: ['invalid_transform'], output: 'NAME' }
          ]
        }.to_json
      )

      expect(group).not_to be_valid
      expect(group.errors[:transformation_rules]).to include("transformation 'invalid_transform' not allowed")
    end

    it 'validates formats are whitelisted' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'name', transformations: [], format: 'invalid_format', output: 'NAME' }
          ]
        }.to_json
      )

      expect(group).not_to be_valid
      expect(group.errors[:transformation_rules]).to include("format 'invalid_format' not allowed")
    end

    it 'validates transformation_rules must be valid JSON' do
      group = ReportGroup.new(
        transformation_rules: 'not json'
      )

      expect(group).not_to be_valid
      expect(group.errors[:transformation_rules]).to include('must be valid JSON')
    end
  end

  # LEGACY MODE TESTS (eval() backward compatibility)

  describe 'legacy mode' do
    it 'still works with legacy eval() mode (deprecated)' do
      group = ReportGroup.new(
        proc: '[[row.name.upcase, row.email]]',
        width: 20
      )
      group.id = 1 # Simulate persisted

      # Expect deprecation warning
      expect(Rails.logger).to receive(:warn).with(/deprecated eval/).at_least(:once)

      row = MockRow.new(name: 'john', email: 'john@test.com', amount: 100, created_at: Time.zone.now)

      # Should still work but log warnings
      result = group.process(row)

      expect(result).to eq([['JOHN', 'john@test.com']])
    end
  end

  # HELPER METHOD TESTS

  describe 'helper methods' do
    describe '#format_group_name' do
      it 'pads and truncates correctly' do
        group = ReportGroup.new(width: 10)

        expect(group.format_group_name('short')).to eq('short     ')
        expect(group.format_group_name('verylongname')).to eq('verylongna')
        expect(group.format_group_name('1234567890')).to eq('1234567890')
      end
    end

    describe '#get_whitelist' do
      it 'splits lines correctly' do
        group = ReportGroup.new(whitelist: "item1\r\nitem2\r\nitem3")

        expect(group.get_whitelist).to eq(%w[item1 item2 item3])
      end
    end

    describe '#get_blacklist' do
      it 'splits lines correctly' do
        group = ReportGroup.new(blacklist: "bad1\r\nbad2")

        expect(group.get_blacklist).to eq(%w[bad1 bad2])
      end
    end

    describe '#whitelist?' do
      it 'checks if value is whitelisted' do
        group = ReportGroup.new(whitelist: "allowed1\r\nallowed2")

        expect(group.whitelist?('allowed1')).to be_truthy
        expect(group.whitelist?('notallowed')).to be_falsey
      end
    end

    describe '#blacklist?' do
      it 'checks if value is blacklisted' do
        group = ReportGroup.new(blacklist: "blocked1\r\nblocked2")

        expect(group.blacklist?('blocked1')).to be_truthy
        expect(group.blacklist?('okay')).to be_falsey
      end
    end
  end

  # SERIALIZE/UNSERIALIZE TESTS

  describe 'serialize/unserialize' do
    describe '.serialize' do
      it 'serializes single group' do
        group = ReportGroup.new(width: 10, minimum: 5)
        serialized = ReportGroup.serialize(group)

        expect(serialized).to be_a(String)
        expect(serialized).to include('width: 10')
      end

      it 'serializes array of groups' do
        group1 = ReportGroup.new(width: 10)
        group2 = ReportGroup.new(width: 20)
        serialized = ReportGroup.serialize([group1, group2])

        expect(serialized).to be_a(String)
      end
    end

    describe '.unserialize' do
      it 'unserializes single group' do
        group = ReportGroup.new(width: 10, minimum: 5)
        serialized = ReportGroup.serialize(group)
        unserialized = ReportGroup.unserialize(serialized)

        expect(unserialized).to be_a(ReportGroup)
        expect(unserialized.width).to eq(10)
        expect(unserialized.minimum).to eq(5)
      end

      it 'unserializes array of groups' do
        group1 = ReportGroup.new(width: 10)
        group2 = ReportGroup.new(width: 20)
        serialized = ReportGroup.serialize([group1, group2])
        unserialized = ReportGroup.unserialize(serialized)

        expect(unserialized).to be_an(Array)
        expect(unserialized.size).to eq(2)
        expect(unserialized[0]).to be_a(ReportGroup)
        expect(unserialized[1]).to be_a(ReportGroup)
      end
    end
  end

  # ERROR HANDLING TESTS

  describe 'error handling' do
    it 'handles exception in process gracefully' do
      group = ReportGroup.new(
        transformation_rules: {
          columns: [
            { source: 'name', transformations: [], output: 'NAME' }
          ]
        }.to_json,
        width: 20
      )
      group.id = 1

      # Passing nil row should log error and return empty string
      expect(Rails.logger).to receive(:error).at_least(:once)

      result = group.process(nil)

      # Returns empty string when field extraction fails on nil row
      expect(result).to eq([['NAME', '']])
    end
  end
end
