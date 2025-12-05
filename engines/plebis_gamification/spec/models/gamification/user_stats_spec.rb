# frozen_string_literal: true

require 'rails_helper'

module Gamification
  RSpec.describe UserStats, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:user) }
      it { is_expected.to have_many(:points).class_name('Gamification::Point') }
      it { is_expected.to have_many(:user_badges).class_name('Gamification::UserBadge') }
      it { is_expected.to have_many(:badges).through(:user_badges) }
    end

    describe 'validations' do
      describe 'uniqueness' do
        subject { create(:gamification_user_stats) }
        it { is_expected.to validate_uniqueness_of(:user_id) }
      end

      it { is_expected.to validate_numericality_of(:total_points).is_greater_than_or_equal_to(0) }
      it { is_expected.to validate_numericality_of(:level).is_greater_than_or_equal_to(0) }
      it { is_expected.to validate_numericality_of(:xp).is_greater_than_or_equal_to(0) }
      it { is_expected.to validate_numericality_of(:current_streak).is_greater_than_or_equal_to(0) }
      it { is_expected.to validate_numericality_of(:longest_streak).is_greater_than_or_equal_to(0) }
    end

    describe 'table name' do
      it 'uses gamification_user_stats table' do
        expect(UserStats.table_name).to eq('gamification_user_stats')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        stats = build(:gamification_user_stats)
        expect(stats).to be_valid
      end

      it 'creates user stats with all required attributes' do
        stats = create(:gamification_user_stats)
        expect(stats).to be_persisted
        expect(stats.total_points).to be >= 0
        expect(stats.level).to be >= 0
      end
    end
  end
end
