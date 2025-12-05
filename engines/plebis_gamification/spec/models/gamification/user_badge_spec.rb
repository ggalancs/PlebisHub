# frozen_string_literal: true

require 'rails_helper'

module Gamification
  RSpec.describe UserBadge, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:user) }
      it { is_expected.to belong_to(:badge).class_name('Gamification::Badge') }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:earned_at) }
      
      describe 'uniqueness' do
        subject { create(:gamification_user_badge) }
        it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:badge_id) }
      end
    end

    describe 'scopes' do
      describe '.recent' do
        it 'orders by earned_at descending' do
          old_badge = create(:gamification_user_badge, earned_at: 2.days.ago)
          new_badge = create(:gamification_user_badge, earned_at: 1.hour.ago)

          result = UserBadge.recent.pluck(:id)
          expect(result.first).to eq(new_badge.id)
        end
      end
    end

    describe 'table name' do
      it 'uses gamification_user_badges table' do
        expect(UserBadge.table_name).to eq('gamification_user_badges')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        user_badge = build(:gamification_user_badge)
        expect(user_badge).to be_valid
      end

      it 'creates a user badge with all required attributes' do
        user_badge = create(:gamification_user_badge)
        expect(user_badge).to be_persisted
        expect(user_badge.earned_at).to be_present
      end
    end
  end
end
