# frozen_string_literal: true

require 'rails_helper'

# Test the Gamification module namespace
RSpec.describe Gamification, type: :model do
  describe 'module definition' do
    it 'is defined as a module' do
      expect(defined?(Gamification)).to eq('constant')
      expect(Gamification).to be_a(Module)
    end
  end

  describe 'nested classes' do
    it 'has Badge class defined' do
      expect(defined?(Gamification::Badge)).to eq('constant')
      expect(Gamification::Badge).to be < ApplicationRecord
    end

    it 'has Point class defined' do
      expect(defined?(Gamification::Point)).to eq('constant')
      expect(Gamification::Point).to be < ApplicationRecord
    end

    it 'has UserBadge class defined' do
      expect(defined?(Gamification::UserBadge)).to eq('constant')
      expect(Gamification::UserBadge).to be < ApplicationRecord
    end

    it 'has UserStats class defined' do
      expect(defined?(Gamification::UserStats)).to eq('constant')
      expect(Gamification::UserStats).to be < ApplicationRecord
    end
  end

  describe 'engine integration' do
    it 'classes are properly namespaced under Gamification' do
      expect(Gamification::Badge.name).to eq('Gamification::Badge')
      expect(Gamification::Point.name).to eq('Gamification::Point')
      expect(Gamification::UserBadge.name).to eq('Gamification::UserBadge')
      expect(Gamification::UserStats.name).to eq('Gamification::UserStats')
    end

    it 'models have proper table names' do
      expect(Gamification::Badge.table_name).to eq('gamification_badges')
      expect(Gamification::Point.table_name).to eq('gamification_points')
      expect(Gamification::UserBadge.table_name).to eq('gamification_user_badges')
      expect(Gamification::UserStats.table_name).to eq('gamification_user_stats')
    end
  end
end
