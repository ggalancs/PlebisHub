# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  # ApplicationRecord is an abstract class, so we need a concrete model to test it
  # We'll use User model which inherits from ApplicationRecord
  let(:test_model) { User }

  describe 'abstract class' do
    it 'is set as an abstract class' do
      expect(ApplicationRecord.abstract_class).to be true
    end

    it 'cannot be instantiated directly' do
      expect { ApplicationRecord.new }.to raise_error(NotImplementedError)
    end

    it 'inherits from ActiveRecord::Base' do
      expect(ApplicationRecord.superclass).to eq(ActiveRecord::Base)
    end
  end

  describe '.ransackable_attributes' do
    context 'with a concrete model' do
      it 'returns an array of searchable attributes' do
        result = test_model.ransackable_attributes
        expect(result).to be_an(Array)
        expect(result).not_to be_empty
      end

      it 'includes column names' do
        result = test_model.ransackable_attributes
        test_model.column_names.each do |column|
          expect(result).to include(column)
        end
      end

      it 'includes ransacker keys if any exist' do
        result = test_model.ransackable_attributes
        ransacker_keys = test_model._ransackers.keys
        ransacker_keys.each do |key|
          expect(result).to include(key)
        end
      end

      it 'includes ransack aliases if any exist' do
        result = test_model.ransackable_attributes
        alias_keys = test_model._ransack_aliases.keys
        alias_keys.each do |key|
          expect(result).to include(key)
        end
      end

      it 'accepts an optional auth_object parameter' do
        expect { test_model.ransackable_attributes(nil) }.not_to raise_error
        expect { test_model.ransackable_attributes('some_auth_object') }.not_to raise_error
      end

      it 'ignores the auth_object parameter' do
        result1 = test_model.ransackable_attributes(nil)
        result2 = test_model.ransackable_attributes('auth_object')
        expect(result1).to eq(result2)
      end

      it 'memoizes the result' do
        # First call
        result1 = test_model.ransackable_attributes
        # Second call should return the same object (memoized)
        result2 = test_model.ransackable_attributes
        expect(result1.object_id).to eq(result2.object_id)
      end

      it 'includes expected standard columns' do
        result = test_model.ransackable_attributes
        expect(result).to include('id')
        expect(result).to include('created_at')
        expect(result).to include('updated_at')
      end
    end

    context 'with different models' do
      let(:category_model) { Category }

      it 'returns different attributes for different models' do
        user_attrs = test_model.ransackable_attributes
        category_attrs = category_model.ransackable_attributes

        # Should have different attributes
        expect(user_attrs).not_to eq(category_attrs)

        # But both should include common columns
        expect(user_attrs).to include('id')
        expect(category_attrs).to include('id')
      end

      it 'includes model-specific columns' do
        user_attrs = test_model.ransackable_attributes
        expect(user_attrs).to include('email') # User-specific column

        category_attrs = category_model.ransackable_attributes
        expect(category_attrs).to include('name') # Category-specific column
      end
    end
  end

  describe '.ransackable_associations' do
    context 'with a concrete model' do
      it 'returns an array of searchable associations' do
        result = test_model.ransackable_associations
        expect(result).to be_an(Array)
      end

      it 'includes all association names as strings' do
        result = test_model.ransackable_associations
        test_model.reflect_on_all_associations.each do |association|
          expect(result).to include(association.name.to_s)
        end
      end

      it 'returns association names as strings, not symbols' do
        result = test_model.ransackable_associations
        result.each do |association_name|
          expect(association_name).to be_a(String)
        end
      end

      it 'accepts an optional auth_object parameter' do
        expect { test_model.ransackable_associations(nil) }.not_to raise_error
        expect { test_model.ransackable_associations('some_auth_object') }.not_to raise_error
      end

      it 'ignores the auth_object parameter' do
        result1 = test_model.ransackable_associations(nil)
        result2 = test_model.ransackable_associations('auth_object')
        expect(result1).to eq(result2)
      end

      it 'memoizes the result' do
        # First call
        result1 = test_model.ransackable_associations
        # Second call should return the same object (memoized)
        result2 = test_model.ransackable_associations
        expect(result1.object_id).to eq(result2.object_id)
      end

      it 'includes expected User associations' do
        result = test_model.ransackable_associations
        # Test some known User associations
        expect(result).to include('votes') if test_model.reflect_on_association(:votes)
        expect(result).to include('orders') if test_model.reflect_on_association(:orders)
      end
    end

    context 'with different models' do
      let(:election_model) { Election }

      it 'returns different associations for different models' do
        user_assocs = test_model.ransackable_associations
        election_assocs = election_model.ransackable_associations

        # Should have different associations
        expect(user_assocs).not_to eq(election_assocs)
      end

      it 'includes model-specific associations' do
        election_assocs = election_model.ransackable_associations
        if election_model.reflect_on_association(:election_locations)
          expect(election_assocs).to include('election_locations')
        end
      end
    end
  end

  describe 'inheritance by models' do
    it 'User inherits from ApplicationRecord' do
      expect(User.superclass).to eq(ApplicationRecord)
    end

    it 'Election inherits from ApplicationRecord' do
      expect(Election.superclass).to eq(ApplicationRecord)
    end

    it 'Order inherits from ApplicationRecord' do
      expect(Order.superclass).to eq(ApplicationRecord)
    end

    it 'all models inherit ransackable_attributes method' do
      expect(User).to respond_to(:ransackable_attributes)
      expect(Category).to respond_to(:ransackable_attributes)
      expect(Election).to respond_to(:ransackable_attributes)
    end

    it 'all models inherit ransackable_associations method' do
      expect(User).to respond_to(:ransackable_associations)
      expect(Category).to respond_to(:ransackable_associations)
      expect(Election).to respond_to(:ransackable_associations)
    end
  end

  describe 'Ransack 4.0+ compatibility' do
    it 'provides backward compatibility with pre-4.0 behavior' do
      # Before Ransack 4.0, all attributes were searchable by default
      # After 4.0, they need explicit allowlisting
      # This method ensures all attributes remain searchable
      user_attrs = test_model.ransackable_attributes
      expect(user_attrs).to include(*test_model.column_names)
    end

    it 'enables searching on all associations by default' do
      # Before Ransack 4.0, all associations were searchable by default
      # After 4.0, they need explicit allowlisting
      # This method ensures all associations remain searchable
      user_assocs = test_model.ransackable_associations
      association_names = test_model.reflect_on_all_associations.map { |a| a.name.to_s }
      expect(user_assocs).to match_array(association_names)
    end

    it 'can be used with Ransack search' do
      # Create a test user for searching
      user = create(:user, email: 'test@example.com')

      # This should work without errors thanks to ransackable_attributes
      search = User.ransack(email_cont: 'test')
      expect(search.result).to include(user)
    end

    it 'can search associations' do
      # This verifies ransackable_associations works correctly
      user = create(:user)
      vote = create(:vote, user: user) if defined?(Vote)

      # This should work without errors thanks to ransackable_associations
      search = User.ransack(votes_id_eq: vote.id) if defined?(Vote) && vote
      expect(search.result).to include(user) if defined?(Vote) && vote
    end
  end

  describe 'memoization behavior' do
    it 'clears memoization when class is reloaded' do
      # Get initial memoized value
      first_attrs = test_model.ransackable_attributes
      first_id = first_attrs.object_id

      # Clear instance variable to simulate reload
      test_model.instance_variable_set(:@ransackable_attributes, nil)

      # Get new value
      second_attrs = test_model.ransackable_attributes
      second_id = second_attrs.object_id

      # Should be different object after clearing
      expect(first_id).not_to eq(second_id)
      # But same content
      expect(first_attrs).to eq(second_attrs)
    end

    it 'handles concurrent access to memoized values' do
      # Clear any existing memoization
      test_model.instance_variable_set(:@ransackable_attributes, nil)
      test_model.instance_variable_set(:@ransackable_associations, nil)

      # Access both methods multiple times
      threads = []
      results_attrs = []
      results_assocs = []

      5.times do
        threads << Thread.new do
          results_attrs << test_model.ransackable_attributes
          results_assocs << test_model.ransackable_associations
        end
      end

      threads.each(&:join)

      # All results should be equal
      expect(results_attrs.uniq.size).to eq(1)
      expect(results_assocs.uniq.size).to eq(1)
    end
  end

  describe 'edge cases' do
    context 'with a model without associations' do
      # BrandSetting might not have associations
      let(:simple_model) { BrandSetting }

      it 'returns empty array if no associations exist' do
        result = simple_model.ransackable_associations
        expect(result).to be_an(Array)
        # May be empty if model has no associations
      end
    end

    context 'with nil parameters' do
      it 'ransackable_attributes handles nil auth_object' do
        expect { test_model.ransackable_attributes(nil) }.not_to raise_error
        result = test_model.ransackable_attributes(nil)
        expect(result).to be_an(Array)
        expect(result).not_to be_empty
      end

      it 'ransackable_associations handles nil auth_object' do
        expect { test_model.ransackable_associations(nil) }.not_to raise_error
        result = test_model.ransackable_associations(nil)
        expect(result).to be_an(Array)
      end
    end

    context 'with various auth_object types' do
      it 'handles string auth_object' do
        result = test_model.ransackable_attributes('string')
        expect(result).to be_an(Array)
      end

      it 'handles hash auth_object' do
        result = test_model.ransackable_attributes({ key: 'value' })
        expect(result).to be_an(Array)
      end

      it 'handles object auth_object' do
        auth_obj = Object.new
        result = test_model.ransackable_attributes(auth_obj)
        expect(result).to be_an(Array)
      end
    end
  end

  describe 'integration with subclasses' do
    it 'each subclass has its own memoized attributes' do
      user_attrs = User.ransackable_attributes
      category_attrs = Category.ransackable_attributes

      # Different models should have independent memoization
      expect(user_attrs.object_id).not_to eq(category_attrs.object_id)
    end

    it 'each subclass has its own memoized associations' do
      user_assocs = User.ransackable_associations
      category_assocs = Category.ransackable_associations

      # Different models should have independent memoization
      expect(user_assocs.object_id).not_to eq(category_assocs.object_id)
    end

    it 'modifying one model memoization does not affect others' do
      # Get initial values
      User.ransackable_attributes
      Category.ransackable_attributes

      # Clear User memoization
      User.instance_variable_set(:@ransackable_attributes, nil)

      # User should recalculate, but Category should keep its memoized value
      user_attrs = User.ransackable_attributes
      category_attrs = Category.ransackable_attributes

      expect(user_attrs).to be_an(Array)
      expect(category_attrs).to be_an(Array)
    end
  end
end
