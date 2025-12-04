# frozen_string_literal: true

require 'rails_helper'
require_relative '../../lib/diff'

RSpec.describe ActiveRecord::Diff do
  # Create a test model class
  let(:test_model_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'users'
      include ActiveRecord::Diff

      def self.name
        'TestModel'
      end
    end
  end

  let(:user) { User.create!(email: 'test@example.com', password: 'password123', first_name: 'John', last_name: 'Doe') }

  describe '.diff' do
    it 'sets the diff_attrs class attribute' do
      test_model_class.diff(:email, :first_name)
      expect(test_model_class.diff_attrs).to eq([:email, :first_name])
    end

    it 'can be called with multiple attributes' do
      test_model_class.diff(:email, :first_name, :last_name)
      expect(test_model_class.diff_attrs).to eq([:email, :first_name, :last_name])
    end

    it 'can be called with a single attribute' do
      test_model_class.diff(:email)
      expect(test_model_class.diff_attrs).to eq([:email])
    end

    it 'can be called with no attributes' do
      test_model_class.diff
      expect(test_model_class.diff_attrs).to be_nil
    end
  end

  describe '#diff?' do
    before do
      User.class_eval do
        include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
        diff :email, :first_name
      end
    end

    it 'returns true when there are differences' do
      user.first_name = 'Jane'
      expect(user.diff?).to be true
    end

    it 'returns false when there are no differences' do
      user.reload
      expect(user.diff?).to be false
    end

    it 'returns true when comparing with another record with differences' do
      other_user = User.new(email: 'other@example.com', first_name: 'Jane')
      expect(user.diff?(other_user)).to be true
    end

    it 'returns false when comparing with another record without differences' do
      other_user = user.dup
      other_user.email = user.email
      other_user.first_name = user.first_name
      expect(user.diff?(other_user)).to be false
    end
  end

  describe '#diff' do
    before do
      User.class_eval do
        include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
        diff :email, :first_name
      end
    end

    context 'when comparing with database version' do
      it 'returns empty hash when no changes' do
        user.reload
        expect(user.diff).to be_empty
      end

      it 'returns hash with changed attributes' do
        user.first_name = 'Jane'
        diff = user.diff
        expect(diff).to have_key(:first_name)
        expect(diff[:first_name]).to eq(['John', 'Jane'])
      end

      it 'includes multiple changed attributes' do
        user.email = 'new@example.com'
        user.first_name = 'Jane'
        diff = user.diff
        expect(diff).to have_key(:email)
        expect(diff).to have_key(:first_name)
      end

      it 'does not include unchanged attributes' do
        user.first_name = 'Jane'
        diff = user.diff
        expect(diff).not_to have_key(:email)
        expect(diff).not_to have_key(:last_name)
      end
    end

    context 'when comparing with another record' do
      let(:other_user) { User.new(email: 'other@example.com', first_name: 'Jane', last_name: 'Smith') }

      it 'returns differences between two records' do
        diff = user.diff(other_user)
        expect(diff).to have_key(:email)
        expect(diff).to have_key(:first_name)
      end

      it 'returns empty hash when records are identical' do
        other_user.email = user.email
        other_user.first_name = user.first_name
        diff = user.diff(other_user)
        expect(diff).to be_empty
      end

      it 'shows correct old and new values' do
        diff = user.diff(other_user)
        expect(diff[:email]).to eq([user.email, other_user.email])
        expect(diff[:first_name]).to eq([user.first_name, other_user.first_name])
      end
    end

    context 'when comparing with a hash' do
      it 'returns differences between record and hash' do
        hash = { email: 'new@example.com', first_name: 'Jane' }
        diff = user.diff(hash)
        expect(diff).to have_key(:email)
        expect(diff).to have_key(:first_name)
      end

      it 'handles unchanged values' do
        hash = { email: user.email, first_name: 'Jane' }
        diff = user.diff(hash)
        expect(diff).not_to have_key(:email)
        expect(diff).to have_key(:first_name)
      end

      it 'shows correct old and new values' do
        hash = { first_name: 'Jane' }
        diff = user.diff(hash)
        expect(diff[:first_name]).to eq(['John', 'Jane'])
      end
    end

    context 'when diff_attrs is not set' do
      before do
        User.class_eval do
          include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
          self.diff_attrs = nil
        end
      end

      it 'uses all content columns' do
        user.first_name = 'Jane'
        diff = user.diff
        expect(diff).to have_key(:first_name)
      end
    end

    context 'when using include/exclude options' do
      before do
        User.class_eval do
          include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
          diff include: [:custom_field], exclude: [:created_at, :updated_at]
        end
      end

      it 'includes specified attributes' do
        user.define_singleton_method(:custom_field) { 'custom' }
        allow(user).to receive(:custom_field).and_return('custom')
        user.first_name = 'Jane'
        diff = user.diff
        expect(diff.keys).to include(:first_name)
      end

      it 'excludes specified attributes' do
        user.created_at = 1.day.ago
        diff = user.diff
        expect(diff.keys).not_to include(:created_at)
        expect(diff.keys).not_to include(:updated_at)
      end
    end
  end

  describe '#diff_each' do
    before do
      User.class_eval do
        include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
      end
    end

    it 'iterates through attributes and yields differences' do
      enum = [:email, :first_name]
      result = user.diff_each(enum) do |attr|
        [attr, 'old_value', 'new_value']
      end

      expect(result).to have_key(:email)
      expect(result).to have_key(:first_name)
    end

    it 'only includes changed values' do
      enum = [:email, :first_name]
      result = user.diff_each(enum) do |attr|
        if attr == :email
          [attr, 'old', 'new']
        else
          [attr, 'same', 'same']
        end
      end

      expect(result).to have_key(:email)
      expect(result).not_to have_key(:first_name)
    end

    it 'uses strict equality for comparison' do
      enum = [:email]
      result = user.diff_each(enum) do |_attr|
        [:email, 1, 1.0]
      end

      expect(result).to have_key(:email)
      expect(result[:email]).to eq([1, 1.0])
    end

    it 'returns empty hash when no differences' do
      enum = [:email]
      result = user.diff_each(enum) do |attr|
        [attr, 'same', 'same']
      end

      expect(result).to be_empty
    end
  end

  describe 'Diff constant' do
    it 'is defined as ActiveRecord::Diff' do
      expect(Diff).to eq(ActiveRecord::Diff)
    end

    it 'is available globally' do
      expect(defined?(Diff)).to eq('constant')
    end
  end

  describe 'inclusion in ActiveRecord' do
    it 'extends ClassMethod when included' do
      test_class = Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        include ActiveRecord::Diff
      end

      expect(test_class).to respond_to(:diff)
    end

    it 'adds class_attribute for diff_attrs' do
      test_class = Class.new(ActiveRecord::Base) do
        self.table_name = 'users'
        include ActiveRecord::Diff
      end

      expect(test_class).to respond_to(:diff_attrs)
      expect(test_class).to respond_to(:diff_attrs=)
    end
  end

  describe 'edge cases' do
    before do
      User.class_eval do
        include ActiveRecord::Diff unless ancestors.include?(ActiveRecord::Diff)
        diff :email, :first_name
      end
    end

    it 'handles nil values' do
      user.first_name = nil
      diff = user.diff
      expect(diff[:first_name][1]).to be_nil
    end

    it 'handles empty strings' do
      user.first_name = ''
      diff = user.diff
      expect(diff[:first_name][1]).to eq('')
    end

    it 'handles numeric values' do
      User.class_eval { diff :id }
      original_id = user.id
      user.instance_variable_set(:@attributes, user.attributes.merge('id' => 999))
      diff = user.diff
      expect(diff[:id]).to eq([original_id, 999])
    end
  end
end
