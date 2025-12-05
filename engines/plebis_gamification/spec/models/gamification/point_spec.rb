# frozen_string_literal: true

require 'rails_helper'

module Gamification
  RSpec.describe Point, type: :model do
    describe 'associations' do
      it 'belongs to user' do
        expect(Point.reflect_on_association(:user).macro).to eq(:belongs_to)
      end

      it 'belongs to source' do
        expect(Point.reflect_on_association(:source).macro).to eq(:belongs_to)
        expect(Point.reflect_on_association(:source).options[:optional]).to be true
      end
    end

    describe 'validations' do
      it 'validates presence of amount' do
        point = build(:gamification_point, amount: nil)
        expect(point).not_to be_valid
        expect(point.errors[:amount]).to be_present
      end

      it 'validates presence of reason' do
        point = build(:gamification_point, reason: nil)
        expect(point).not_to be_valid
        expect(point.errors[:reason]).to be_present
      end

      it 'validates numericality of amount greater than 0' do
        point = build(:gamification_point, amount: 0)
        expect(point).not_to be_valid
        expect(point.errors[:amount]).to be_present

        point.amount = -5
        expect(point).not_to be_valid

        point.amount = 1
        expect(point).to be_valid
      end
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

      describe '.by_date_range' do
        it 'filters points by date range' do
          old_point = create(:gamification_point, created_at: 5.days.ago)
          recent_point = create(:gamification_point, created_at: 2.days.ago)
          new_point = create(:gamification_point, created_at: 1.hour.ago)

          result = Point.by_date_range(3.days.ago, 1.day.ago)
          expect(result).to include(recent_point)
          expect(result).not_to include(old_point)
          expect(result).not_to include(new_point)
        end
      end
    end

    describe 'table name' do
      it 'uses gamification_points table' do
        expect(Point.table_name).to eq('gamification_points')
      end
    end

    describe '.history_for' do
      let(:user) { create(:user) }
      let!(:point1) { create(:gamification_point, user: user, amount: 10, reason: 'first', created_at: 3.days.ago) }
      let!(:point2) { create(:gamification_point, user: user, amount: 20, reason: 'second', created_at: 2.days.ago) }

      it 'returns point history for user' do
        result = Point.history_for(user)
        expect(result).to be_an(Array)
      end

      it 'orders points by created_at descending' do
        result = Point.history_for(user)
        expect(result.first[:id]).to eq(point2.id)
      end

      it 'limits results to specified limit' do
        result = Point.history_for(user, limit: 1)
        expect(result.length).to eq(1)
      end

      it 'includes point details as JSON' do
        result = Point.history_for(user)
        first_item = result.first
        expect(first_item).to have_key(:id)
        expect(first_item).to have_key(:amount)
        expect(first_item).to have_key(:reason)
        expect(first_item).to have_key(:earned_at)
      end
    end

    describe '#as_json_detailed' do
      let(:user) { create(:user) }
      let(:point) { create(:gamification_point, user: user, amount: 50, reason: 'test_reason') }

      it 'returns a hash with point details' do
        result = point.as_json_detailed
        expect(result).to be_a(Hash)
        expect(result[:id]).to eq(point.id)
        expect(result[:amount]).to eq(50)
        expect(result[:reason]).to eq('test_reason')
      end

      it 'includes earned_at as ISO8601 timestamp' do
        result = point.as_json_detailed
        expect(result[:earned_at]).to be_present
        expect { Time.iso8601(result[:earned_at]) }.not_to raise_error
      end

      it 'includes source when present' do
        source_obj = create(:proposal)
        point_with_source = create(:gamification_point, user: user, source: source_obj)
        result = point_with_source.as_json_detailed
        expect(result[:source]).to be_a(Hash)
      end

      it 'has nil source when not present' do
        result = point.as_json_detailed
        expect(result[:source]).to be_nil
      end
    end

    describe '#source_summary' do
      let(:user) { create(:user) }

      context 'when point has no source' do
        let(:point) { create(:gamification_point, user: user, source: nil) }

        it 'returns nil' do
          result = point.send(:source_summary)
          expect(result).to be_nil
        end
      end

      context 'when point has source with title' do
        let(:source) { create(:proposal, title: 'Test Proposal') }
        let(:point) { create(:gamification_point, user: user, source: source) }

        it 'returns source summary hash' do
          result = point.send(:source_summary)
          expect(result).to be_a(Hash)
          expect(result[:type]).to eq('PlebisProposals::Proposal')
          expect(result[:id]).to eq(source.id)
          expect(result[:name]).to eq('Test Proposal')
        end
      end

      context 'when point has source without title' do
        let(:source) { create(:user) }
        let(:point) { create(:gamification_point, user: user, source: source) }

        it 'falls back to to_s for name' do
          result = point.send(:source_summary)
          expect(result[:name]).to be_present
        end
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

    describe 'polymorphic source' do
      let(:user) { create(:user) }

      it 'accepts Proposal as source' do
        proposal = create(:proposal)
        point = create(:gamification_point, user: user, source: proposal)
        expect(point.source).to eq(proposal)
        expect(point.source_type).to eq('PlebisProposals::Proposal')
      end

      it 'allows nil source' do
        point = create(:gamification_point, user: user, source: nil)
        expect(point.source).to be_nil
      end
    end
  end
end
