# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gamification::Badge, type: :model do
  #==================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid badge' do
      badge = build(:gamification_badge)
      expect(badge).to be_valid
    end

    it 'creates valid badge with different traits' do
      expect(build(:gamification_badge, :first_proposal)).to be_valid
      expect(build(:gamification_badge, :active_voter)).to be_valid
      expect(build(:gamification_badge, :level_10)).to be_valid
      expect(build(:gamification_badge, :gold_tier)).to be_valid
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'has many user_badges' do
      badge = create(:gamification_badge)
      expect(badge).to respond_to(:user_badges)
    end

    it 'has many users through user_badges' do
      badge = create(:gamification_badge)
      expect(badge).to respond_to(:users)
    end

    it 'can access users who earned the badge' do
      badge = create(:gamification_badge)
      user = create(:user)
      create(:gamification_user_badge, user: user, badge: badge)

      expect(badge.users).to include(user)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'validates presence of key' do
      badge = build(:gamification_badge, key: nil)
      expect(badge).not_to be_valid
      expect(badge.errors[:key]).to be_present
    end

    it 'validates presence of name' do
      badge = build(:gamification_badge, name: nil)
      expect(badge).not_to be_valid
      expect(badge.errors[:name]).to be_present
    end

    it 'validates presence of icon' do
      badge = build(:gamification_badge, icon: nil)
      expect(badge).not_to be_valid
      expect(badge.errors[:icon]).to be_present
    end

    it 'validates uniqueness of key' do
      create(:gamification_badge, key: 'unique_key')
      duplicate = build(:gamification_badge, key: 'unique_key')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:key]).to be_present
    end

    describe 'tier validation' do
      it 'allows valid tiers' do
        %w[bronze silver gold platinum diamond].each do |tier|
          badge = build(:gamification_badge, tier: tier)
          expect(badge).to be_valid
        end
      end

      it 'allows nil tier' do
        badge = build(:gamification_badge, tier: nil)
        expect(badge).to be_valid
      end

      it 'rejects invalid tiers' do
        badge = build(:gamification_badge, tier: 'invalid')
        expect(badge).not_to be_valid
        expect(badge.errors[:tier]).to include('is not included in the list')
      end
    end
  end

  # ====================
  # CRITERIA_MET? TESTS
  # ====================

  describe '#criteria_met?' do
    let(:user) { create(:user) }
    let!(:stats) { Gamification::UserStats.for_user(user) }

    context 'with proposals_created criteria' do
      let(:badge) { create(:gamification_badge, criteria: { proposals_created: { gte: 5 } }) }

      it 'returns true when user has enough proposals' do
        allow(user.proposals).to receive(:count).and_return(5)
        expect(badge.criteria_met?(user)).to be true
      end

      it 'returns false when user does not have enough proposals' do
        allow(user.proposals).to receive(:count).and_return(3)
        expect(badge.criteria_met?(user)).to be false
      end
    end

    context 'with votes_cast criteria' do
      let(:badge) { create(:gamification_badge, criteria: { votes_cast: { gte: 10 } }) }

      it 'returns true when user has cast enough votes' do
        allow(user.votes).to receive(:count).and_return(15)
        expect(badge.criteria_met?(user)).to be true
      end

      it 'returns false when user has not cast enough votes' do
        allow(user.votes).to receive(:count).and_return(5)
        expect(badge.criteria_met?(user)).to be false
      end
    end

    context 'with comments_posted criteria' do
      let(:badge) { create(:gamification_badge, criteria: { comments_posted: { gte: 50 } }) }

      it 'returns true when user has posted enough comments' do
        allow(user.comments).to receive(:count).and_return(60)
        expect(badge.criteria_met?(user)).to be true
      end

      it 'returns false when user has not posted enough comments' do
        allow(user.comments).to receive(:count).and_return(30)
        expect(badge.criteria_met?(user)).to be false
      end
    end

    context 'with streak_days criteria' do
      let(:badge) { create(:gamification_badge, criteria: { streak_days: { gte: 7 } }) }

      it 'returns true when user has sufficient streak' do
        stats.update(current_streak: 10)
        expect(badge.criteria_met?(user)).to be true
      end

      it 'returns false when user does not have sufficient streak' do
        stats.update(current_streak: 3)
        expect(badge.criteria_met?(user)).to be false
      end
    end

    context 'with level criteria' do
      let(:badge) { create(:gamification_badge, criteria: { level: { gte: 10 } }) }

      it 'returns true when user has reached the level' do
        stats.update(level: 10)
        expect(badge.criteria_met?(user)).to be true
      end

      it 'returns false when user has not reached the level' do
        stats.update(level: 5)
        expect(badge.criteria_met?(user)).to be false
      end
    end

    context 'with registered_before criteria (date string)' do
      let(:badge) { create(:gamification_badge, criteria: { registered_before: '2024-02-01' }) }

      it 'returns true when user registered before the date' do
        allow(user).to receive(:created_at).and_return(DateTime.parse('2024-01-15'))
        expect(badge.criteria_met?(user)).to be true
      end

      it 'returns false when user registered after the date' do
        allow(user).to receive(:created_at).and_return(DateTime.parse('2024-03-15'))
        expect(badge.criteria_met?(user)).to be false
      end
    end

    context 'with multiple criteria' do
      let(:badge) do
        create(:gamification_badge, criteria: {
                 proposals_created: { gte: 5 },
                 votes_cast: { gte: 10 }
               })
      end

      it 'returns true when all criteria are met' do
        allow(user.proposals).to receive(:count).and_return(5)
        allow(user.votes).to receive(:count).and_return(10)
        expect(badge.criteria_met?(user)).to be true
      end

      it 'returns false when only some criteria are met' do
        allow(user.proposals).to receive(:count).and_return(5)
        allow(user.votes).to receive(:count).and_return(5)
        expect(badge.criteria_met?(user)).to be false
      end

      it 'returns false when no criteria are met' do
        allow(user.proposals).to receive(:count).and_return(1)
        allow(user.votes).to receive(:count).and_return(1)
        expect(badge.criteria_met?(user)).to be false
      end
    end

    context 'with empty criteria' do
      let(:badge) { create(:gamification_badge, criteria: {}) }

      it 'returns true (all conditions met vacuously)' do
        expect(badge.criteria_met?(user)).to be true
      end
    end
  end

  # ====================
  # TABLE NAME
  # ====================

  describe 'table name' do
    it 'uses correct table name' do
      expect(described_class.table_name).to eq('gamification_badges')
    end
  end

  # ====================
  # CATEGORY AND TIER FILTERING
  # ====================

  describe 'filtering' do
    let!(:proposal_badge) { create(:gamification_badge, category: 'proposals', tier: 'bronze') }
    let!(:voting_badge) { create(:gamification_badge, category: 'voting', tier: 'silver') }
    let!(:level_badge) { create(:gamification_badge, category: 'levels', tier: 'gold') }

    it 'can filter by category' do
      result = described_class.where(category: 'proposals')
      expect(result).to include(proposal_badge)
      expect(result).not_to include(voting_badge)
    end

    it 'can filter by tier' do
      result = described_class.where(tier: 'silver')
      expect(result).to include(voting_badge)
      expect(result).not_to include(proposal_badge)
    end
  end

  # ====================
  # EDGE CASES
  # ====================

  describe 'edge cases' do
    it 'handles very large point rewards' do
      badge = build(:gamification_badge, points_reward: 1_000_000)
      expect(badge).to be_valid
    end

    it 'handles zero point rewards' do
      badge = build(:gamification_badge, points_reward: 0)
      expect(badge).to be_valid
    end

    it 'handles special characters in description' do
      badge = build(:gamification_badge, description: "Test with 'quotes' and \"double quotes\"")
      expect(badge).to be_valid
    end

    it 'stores criteria as JSONB' do
      badge = create(:gamification_badge, criteria: { test: { gte: 10 }, other: 'value' })
      expect(badge.criteria['test']['gte']).to eq(10)
      expect(badge.criteria['other']).to eq('value')
    end
  end
end
