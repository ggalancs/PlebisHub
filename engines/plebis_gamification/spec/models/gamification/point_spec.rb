# frozen_string_literal: true

require 'rails_helper'

module Gamification
  RSpec.describe Point, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:user) }
      it { is_expected.to belong_to(:source).optional }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:amount) }
      it { is_expected.to validate_presence_of(:reason) }
      it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
    end

    describe 'scopes' do
      describe '.recent' do
        it 'orders by created_at descending' do
          old_point = create(:gamification_point, created_at: 2.days.ago)
          new_point = create(:gamification_point, created_at: 1.hour.ago)

          result = Point.recent.pluck(:id)
          expect(result.first).to eq(new_point.id)
        end
      end

      describe '.for_reason' do
        it 'filters by reason' do
          vote_point = create(:gamification_point, reason: 'vote')
          comment_point = create(:gamification_point, reason: 'comment')

          result = Point.for_reason('vote')
          expect(result).to include(vote_point)
          expect(result).not_to include(comment_point)
        end
      end
    end

    describe 'table name' do
      it 'uses gamification_points table' do
        expect(Point.table_name).to eq('gamification_points')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        point = build(:gamification_point)
        expect(point).to be_valid
      end

      it 'creates a point with all required attributes' do
        point = create(:gamification_point)
        expect(point).to be_persisted
        expect(point.amount).to be > 0
        expect(point.reason).to be_present
      end
    end
  end
end
