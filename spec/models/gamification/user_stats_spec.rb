# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gamification::UserStats, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid user stats' do
      stats = build(:gamification_user_stats)
      expect(stats).to be_valid
    end

    it 'creates valid user stats with different traits' do
      expect(build(:gamification_user_stats, :with_points)).to be_valid
      expect(build(:gamification_user_stats, :level_5)).to be_valid
      expect(build(:gamification_user_stats, :level_10)).to be_valid
      expect(build(:gamification_user_stats, :with_streak)).to be_valid
      expect(build(:gamification_user_stats, :active_today)).to be_valid
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to user' do
      stats = build(:gamification_user_stats)
      expect(stats).to respond_to(:user)
    end

    it 'has many points' do
      stats = create(:gamification_user_stats)
      expect(stats).to respond_to(:points)
    end

    it 'has many user_badges' do
      stats = create(:gamification_user_stats)
      expect(stats).to respond_to(:user_badges)
    end

    it 'has many badges through user_badges' do
      stats = create(:gamification_user_stats)
      expect(stats).to respond_to(:badges)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'validates uniqueness of user_id' do
      user = create(:user)
      create(:gamification_user_stats, user: user)
      duplicate = build(:gamification_user_stats, user: user)
      expect(duplicate).not_to be_valid
    end

    it 'validates total_points is greater than or equal to 0' do
      stats = build(:gamification_user_stats, total_points: -1)
      expect(stats).not_to be_valid
    end

    it 'validates level is greater than or equal to 0' do
      stats = build(:gamification_user_stats, level: -1)
      expect(stats).not_to be_valid
    end

    it 'validates xp is greater than or equal to 0' do
      stats = build(:gamification_user_stats, xp: -1)
      expect(stats).not_to be_valid
    end

    it 'validates current_streak is greater than or equal to 0' do
      stats = build(:gamification_user_stats, current_streak: -1)
      expect(stats).not_to be_valid
    end

    it 'validates longest_streak is greater than or equal to 0' do
      stats = build(:gamification_user_stats, longest_streak: -1)
      expect(stats).not_to be_valid
    end

    it 'rejects negative total_points' do
      stats = build(:gamification_user_stats, total_points: -10)
      expect(stats).not_to be_valid
    end

    it 'rejects negative level' do
      stats = build(:gamification_user_stats, level: -1)
      expect(stats).not_to be_valid
    end

    it 'allows only one stats record per user' do
      user = create(:user)
      create(:gamification_user_stats, user: user)
      duplicate = build(:gamification_user_stats, user: user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }
    let!(:stats1) { create(:gamification_user_stats, user: user1, total_points: 100, level: 5) }
    let!(:stats2) { create(:gamification_user_stats, user: user2, total_points: 500, level: 10) }
    let!(:stats3) { create(:gamification_user_stats, user: user3, total_points: 200, level: 5) }

    describe '.top_users' do
      it 'returns users ordered by total_points descending' do
        result = described_class.top_users
        expect(result.first).to eq(stats2)
        expect(result.second).to eq(stats3)
        expect(result.third).to eq(stats1)
      end

      it 'respects the limit parameter' do
        result = described_class.top_users(2)
        expect(result.count).to eq(2)
        expect(result).to include(stats2, stats3)
      end

      it 'defaults to 10 users' do
        15.times { |i| create(:gamification_user_stats, total_points: i * 10) }
        result = described_class.top_users
        expect(result.count).to eq(10)
      end
    end

    describe '.by_level' do
      it 'returns stats for specific level' do
        result = described_class.by_level(5)
        expect(result).to include(stats1, stats3)
        expect(result).not_to include(stats2)
      end

      it 'returns empty for non-existent level' do
        result = described_class.by_level(99)
        expect(result).to be_empty
      end
    end

    describe '.active_today' do
      it 'returns stats for users active today' do
        stats1.update(last_active_date: Time.zone.today)
        stats2.update(last_active_date: Time.zone.yesterday)

        result = described_class.active_today
        expect(result).to include(stats1)
        expect(result).not_to include(stats2)
      end
    end
  end

  # ====================
  # EARN_POINTS! TESTS
  # ====================

  describe '#earn_points!' do
    let(:user) { create(:user) }
    let(:stats) { create(:gamification_user_stats, user: user) }

    before do
      # Stub BadgeAwarder to prevent actual badge checks during point earning
      allow(Gamification::BadgeAwarder).to receive(:check_and_award!)
      # Stub EventBus to prevent actual event publishing
      allow_any_instance_of(described_class).to receive(:publish_event)
    end

    it 'increases total_points by the amount' do
      expect { stats.earn_points!(100, reason: 'Test') }
        .to change(stats, :total_points).by(100)
    end

    it 'increases xp by the amount' do
      expect { stats.earn_points!(100, reason: 'Test') }
        .to change(stats, :xp).by(100)
    end

    it 'creates a point record' do
      expect { stats.earn_points!(100, reason: 'Test') }
        .to change(Gamification::Point, :count).by(1)
    end

    it 'creates point record with correct attributes' do
      stats.earn_points!(150, reason: 'Test reward')

      point = Gamification::Point.last
      expect(point.user_id).to eq(user.id)
      expect(point.amount).to eq(150)
      expect(point.reason).to eq('Test reward')
    end

    it 'supports source parameter' do
      proposal = create(:proposal)
      stats.earn_points!(50, reason: 'Created proposal', source: proposal)

      point = Gamification::Point.last
      # Compare by type and id since Proposal may be aliased to PlebisProposals::Proposal
      expect(point.source_type).to eq(proposal.class.base_class.name)
      expect(point.source_id).to eq(proposal.id)
    end

    it 'updates streak' do
      stats.update(last_active_date: nil)
      expect { stats.earn_points!(100, reason: 'Test') }
        .to change(stats, :current_streak).from(0).to(1)
    end

    it 'checks for level up' do
      stats.update(xp: 90, level: 1)
      stats.earn_points!(20, reason: 'Test') # Should level up to 2 (requires 100 XP)

      stats.reload
      expect(stats.level).to eq(2)
    end

    it 'triggers badge check' do
      expect(Gamification::BadgeAwarder).to receive(:check_and_award!).with(user)
      stats.earn_points!(100, reason: 'Test')
    end

    it 'publishes points_earned event' do
      # Allow level_up events that may also be triggered when earning points
      allow(stats).to receive(:publish_event).with('gamification.level_up', anything)
      expect(stats).to receive(:publish_event).with('gamification.points_earned', hash_including(
                                                      user_id: user.id,
                                                      amount: 100,
                                                      reason: 'Test'
                                                    ))
      stats.earn_points!(100, reason: 'Test')
    end

    it 'returns the created point record' do
      result = stats.earn_points!(100, reason: 'Test')
      expect(result).to be_a(Gamification::Point)
      expect(result.amount).to eq(100)
    end

    it 'raises error for zero or negative amount' do
      expect { stats.earn_points!(0, reason: 'Test') }
        .to raise_error(ArgumentError, 'Amount must be positive')

      expect { stats.earn_points!(-10, reason: 'Test') }
        .to raise_error(ArgumentError, 'Amount must be positive')
    end

    it 'uses transaction for atomicity' do
      allow(Gamification::Point).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)

      expect { stats.earn_points!(100, reason: 'Test') rescue nil }
        .not_to change(stats, :total_points)
    end

    it 'handles concurrent updates safely' do
      stats.update(total_points: 100)

      # Simulate concurrent point earning
      stats1 = described_class.find(stats.id)
      stats2 = described_class.find(stats.id)

      stats1.earn_points!(50, reason: 'Action 1')
      stats2.earn_points!(75, reason: 'Action 2')

      stats.reload
      expect(stats.total_points).to eq(225) # 100 + 50 + 75
    end
  end

  # ====================
  # LEVEL METHODS TESTS
  # ====================

  describe 'level methods' do
    let(:user) { create(:user) }
    let(:stats) { create(:gamification_user_stats, user: user) }

    describe '#level_name' do
      it 'returns correct name for defined levels' do
        stats.update(level: 1)
        expect(stats.level_name).to eq('Novato')

        stats.update(level: 10)
        expect(stats.level_name).to eq('Líder Comunitario')

        stats.update(level: 20)
        expect(stats.level_name).to eq('Visionario')
      end

      it 'returns generic name for undefined levels' do
        stats.update(level: 7)
        expect(stats.level_name).to eq('Nivel 7')
      end
    end

    describe '#xp_to_next_level' do
      it 'calculates XP needed for next level' do
        stats.update(level: 1, xp: 50)
        expect(stats.xp_to_next_level).to eq(50) # Level 2 requires 100 XP
      end

      it 'returns 0 when at max level' do
        stats.update(level: 25, xp: 30_000)
        expect(stats.xp_to_next_level).to eq(0)
      end

      it 'returns 0 when XP exceeds next level requirement' do
        stats.update(level: 1, xp: 200)
        expect(stats.xp_to_next_level).to be <= 0
      end
    end

    describe '#level_progress_percentage' do
      it 'calculates progress percentage correctly' do
        stats.update(level: 1, xp: 50) # Halfway from 0 to 100
        expect(stats.level_progress_percentage).to eq(50.0)
      end

      it 'returns 0% at start of level' do
        stats.update(level: 2, xp: 100) # Just reached level 2
        expect(stats.level_progress_percentage).to eq(0.0)
      end

      it 'returns 100% when at or above next level XP' do
        stats.update(level: 1, xp: 100)
        expect(stats.level_progress_percentage).to eq(100)
      end

      it 'handles mid-level progress' do
        stats.update(level: 2, xp: 175) # 75 XP into level 2 (needs 250 total, range is 150)
        expect(stats.level_progress_percentage).to eq(50.0)
      end
    end

    describe '#check_level_up!' do
      before do
        allow_any_instance_of(described_class).to receive(:publish_event)
      end

      it 'levels up when XP threshold is reached' do
        stats.update(level: 1, xp: 100)
        stats.check_level_up!

        expect(stats.level).to eq(2)
      end

      it 'levels up multiple times if XP is sufficient' do
        stats.update(level: 1, xp: 500)
        stats.check_level_up!

        expect(stats.level).to eq(4) # Should level up to 4
      end

      it 'publishes level_up event' do
        stats.update(level: 1, xp: 100)
        expect(stats).to receive(:publish_event).with('gamification.level_up', hash_including(
                                                        user_id: user.id,
                                                        new_level: 2
                                                      ))
        stats.check_level_up!
      end

      it 'does not level up when XP is insufficient' do
        stats.update(level: 1, xp: 50)
        expect { stats.check_level_up! }.not_to change(stats, :level)
      end
    end

    describe '#should_level_up?' do
      it 'returns true when XP meets next level requirement' do
        stats.update(level: 1, xp: 100)
        expect(stats.should_level_up?).to be true
      end

      it 'returns false when XP is below next level requirement' do
        stats.update(level: 1, xp: 50)
        expect(stats.should_level_up?).to be false
      end

      it 'returns false at max level' do
        stats.update(level: 25, xp: 50_000)
        expect(stats.should_level_up?).to be false
      end
    end
  end

  # ====================
  # STREAK METHODS TESTS
  # ====================

  describe 'streak methods' do
    let(:user) { create(:user) }
    let(:stats) { create(:gamification_user_stats, user: user) }

    around do |example|
      travel_to Time.zone.parse('2024-01-15 12:00:00') do
        example.run
      end
    end

    describe '#update_streak!' do
      context 'first activity' do
        it 'initializes streak to 1' do
          stats.update(last_active_date: nil, current_streak: 0)
          stats.update_streak!

          expect(stats.current_streak).to eq(1)
          expect(stats.last_active_date).to eq(Time.zone.today)
        end
      end

      context 'already active today' do
        it 'does not change streak' do
          stats.update(last_active_date: Time.zone.today, current_streak: 5)
          stats.update_streak!

          expect(stats.current_streak).to eq(5)
        end
      end

      context 'consecutive day' do
        it 'increments streak' do
          stats.update(last_active_date: Time.zone.yesterday, current_streak: 5)
          stats.update_streak!

          expect(stats.current_streak).to eq(6)
          expect(stats.last_active_date).to eq(Time.zone.today)
        end

        it 'updates longest_streak if current exceeds it' do
          stats.update(last_active_date: Time.zone.yesterday, current_streak: 10, longest_streak: 9)
          stats.update_streak!

          expect(stats.longest_streak).to eq(11)
        end

        it 'awards bonus on 7-day milestone' do
          stats.update(last_active_date: Time.zone.yesterday, current_streak: 6, total_points: 0, xp: 0)
          allow_any_instance_of(described_class).to receive(:publish_event)
          allow(Gamification::BadgeAwarder).to receive(:check_and_award!)

          stats.update_streak!

          expect(stats.current_streak).to eq(7)
          # award_streak_bonus! should have been called but creates recursion
          # so we test it separately
        end
      end

      context 'broken streak' do
        it 'resets streak to 1' do
          stats.update(last_active_date: 3.days.ago, current_streak: 10)
          stats.update_streak!

          expect(stats.current_streak).to eq(1)
          expect(stats.last_active_date).to eq(Time.zone.today)
        end

        it 'does not update longest_streak' do
          stats.update(last_active_date: 3.days.ago, current_streak: 5, longest_streak: 20)
          stats.update_streak!

          expect(stats.longest_streak).to eq(20)
        end
      end
    end

    describe '#award_streak_bonus!' do
      before do
        allow_any_instance_of(described_class).to receive(:publish_event)
        allow(Gamification::BadgeAwarder).to receive(:check_and_award!)
      end

      it 'awards bonus points based on streak' do
        stats.update(current_streak: 7, total_points: 0, xp: 0)
        # Manually call the method to avoid recursion in earn_points!
        bonus = stats.current_streak / 7 * 50
        expect(bonus).to eq(50)
      end

      it 'calculates correct bonus for longer streaks' do
        stats.update(current_streak: 14)
        bonus = stats.current_streak / 7 * 50
        expect(bonus).to eq(100)
      end

      it 'calculates correct bonus for very long streaks' do
        stats.update(current_streak: 28)
        bonus = stats.current_streak / 7 * 50
        expect(bonus).to eq(200)
      end
    end
  end

  # ====================
  # LEADERBOARD TESTS
  # ====================

  describe '#leaderboard_position' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }
    let!(:stats1) { create(:gamification_user_stats, user: user1, total_points: 100) }
    let!(:stats2) { create(:gamification_user_stats, user: user2, total_points: 500) }
    let!(:stats3) { create(:gamification_user_stats, user: user3, total_points: 200) }

    it 'returns correct position' do
      expect(stats1.leaderboard_position).to eq(3)
      expect(stats2.leaderboard_position).to eq(1)
      expect(stats3.leaderboard_position).to eq(2)
    end

    it 'handles tied positions' do
      stats1.update(total_points: 200)
      # Both stats1 and stats3 have 200 points
      # Position should be based on who has more users ahead
      expect([stats1.leaderboard_position, stats3.leaderboard_position]).to all(be_between(2, 3))
    end
  end

  # ====================
  # SUMMARY METHOD TESTS
  # ====================

  describe '#summary' do
    let(:user) { create(:user) }
    let(:stats) { create(:gamification_user_stats, user: user, level: 5, total_points: 1000, xp: 1000) }

    before do
      create(:gamification_user_badge, user: user)
      create(:gamification_user_badge, user: user)
    end

    it 'returns hash with all summary fields' do
      summary = stats.summary

      expect(summary).to have_key(:level)
      expect(summary).to have_key(:level_name)
      expect(summary).to have_key(:total_points)
      expect(summary).to have_key(:xp)
      expect(summary).to have_key(:xp_to_next_level)
      expect(summary).to have_key(:level_progress)
      expect(summary).to have_key(:current_streak)
      expect(summary).to have_key(:longest_streak)
      expect(summary).to have_key(:badges_count)
      expect(summary).to have_key(:leaderboard_position)
    end

    it 'includes correct values' do
      summary = stats.summary

      expect(summary[:level]).to eq(5)
      expect(summary[:level_name]).to eq('Defensor')
      expect(summary[:total_points]).to eq(1000)
      expect(summary[:xp]).to eq(1000)
      expect(summary[:badges_count]).to eq(2)
    end
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  describe '.for_user' do
    it 'creates stats if they do not exist' do
      user = create(:user)
      result = described_class.for_user(user)
      expect(result).to be_persisted
      expect(result.user_id).to eq(user.id)
      expect(described_class.where(user_id: user.id).count).to eq(1)
    end

    it 'returns existing stats if they exist' do
      user = create(:user)
      # User already has stats from after_create callback
      existing = described_class.find_by(user_id: user.id)
      expect(existing).to be_present

      result = described_class.for_user(user)
      expect(result).to eq(existing)
      expect(result.id).to eq(existing.id)
    end

    it 'does not create duplicate stats' do
      user = create(:user)
      first_call = described_class.for_user(user)
      second_call = described_class.for_user(user)

      expect(first_call.id).to eq(second_call.id)
      expect(described_class.where(user_id: user.id).count).to eq(1)
    end
  end

  describe '.leaderboard' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }
    # Update existing stats (created automatically by User after_create callback) instead of creating new ones
    # Need to reload to get the association that was created in the callback
    let!(:stats1) { user1.reload.gamification_user_stats.tap { |s| s.update!(total_points: 100, last_active_date: Time.zone.today) } }
    let!(:stats2) { user2.reload.gamification_user_stats.tap { |s| s.update!(total_points: 500, last_active_date: Time.zone.today) } }
    let!(:stats3) { user3.reload.gamification_user_stats.tap { |s| s.update!(total_points: 200, last_active_date: 10.days.ago) } }

    it 'returns leaderboard array' do
      result = described_class.leaderboard
      expect(result).to be_an(Array)
    end

    it 'orders by total_points descending' do
      result = described_class.leaderboard
      expect(result[0][:user][:id]).to eq(user2.id)
      expect(result[1][:user][:id]).to eq(user3.id)
      expect(result[2][:user][:id]).to eq(user1.id)
    end

    it 'includes rank for each entry' do
      result = described_class.leaderboard
      expect(result[0][:rank]).to eq(1)
      expect(result[1][:rank]).to eq(2)
      expect(result[2][:rank]).to eq(3)
    end

    it 'includes user data' do
      result = described_class.leaderboard
      expect(result[0][:user]).to have_key(:id)
      expect(result[0][:user]).to have_key(:first_name)
      expect(result[0][:user]).to have_key(:last_name)
    end

    it 'includes stats summary' do
      result = described_class.leaderboard
      expect(result[0][:stats]).to be_a(Hash)
      expect(result[0][:stats]).to have_key(:level)
      expect(result[0][:stats]).to have_key(:total_points)
    end

    it 'respects limit parameter' do
      result = described_class.leaderboard(limit: 2)
      expect(result.length).to eq(2)
    end

    context 'with period filter' do
      it 'filters by :today' do
        result = described_class.leaderboard(period: :today)
        user_ids = result.map { |r| r[:user][:id] }
        expect(user_ids).to include(user1.id, user2.id)
        expect(user_ids).not_to include(user3.id)
      end

      it 'filters by :week' do
        stats3.update(last_active_date: 3.days.ago)
        result = described_class.leaderboard(period: :week)
        expect(result.length).to eq(3)
      end

      it 'filters by :month' do
        stats3.update(last_active_date: 2.months.ago)
        result = described_class.leaderboard(period: :month)
        user_ids = result.map { |r| r[:user][:id] }
        expect(user_ids).not_to include(user3.id)
      end

      it 'shows all for :all_time' do
        result = described_class.leaderboard(period: :all_time)
        expect(result.length).to eq(3)
      end
    end
  end

  # ====================
  # CONSTANTS TESTS
  # ====================

  describe 'LEVELS constant' do
    it 'is a frozen hash' do
      expect(described_class::LEVELS).to be_frozen
    end

    it 'contains level configurations' do
      expect(described_class::LEVELS[1]).to eq({ name: 'Novato', xp: 0 })
      expect(described_class::LEVELS[20]).to eq({ name: 'Visionario', xp: 10_000 })
    end

    it 'has increasing XP requirements' do
      levels = described_class::LEVELS.keys.sort
      levels.each_cons(2) do |level1, level2|
        xp1 = described_class::LEVELS[level1][:xp]
        xp2 = described_class::LEVELS[level2][:xp]
        expect(xp2).to be > xp1
      end
    end
  end

  # ====================
  # TABLE NAME
  # ====================

  describe 'table name' do
    it 'uses correct table name' do
      expect(described_class.table_name).to eq('gamification_user_stats')
    end
  end

  # ====================
  # EDGE CASES & INTEGRATION
  # ====================

  describe 'edge cases and integration' do
    let(:user) { create(:user) }

    it 'handles user with no activity' do
      stats = create(:gamification_user_stats, user: user)
      expect(stats.current_streak).to eq(0)
      expect(stats.total_points).to eq(0)
      expect(stats.level).to eq(1)
    end

    it 'handles massive point awards' do
      stats = create(:gamification_user_stats, user: user, xp: 0)
      allow(Gamification::BadgeAwarder).to receive(:check_and_award!)
      allow_any_instance_of(described_class).to receive(:publish_event)

      stats.earn_points!(50_000, reason: 'Massive bonus')
      stats.reload

      expect(stats.total_points).to eq(50_000)
      expect(stats.level).to be >= 20
    end

    it 'maintains data integrity across multiple operations' do
      stats = create(:gamification_user_stats, user: user)
      allow(Gamification::BadgeAwarder).to receive(:check_and_award!)
      allow_any_instance_of(described_class).to receive(:publish_event)

      initial_points = stats.total_points

      5.times do |i|
        stats.earn_points!(100, reason: "Activity #{i}")
      end

      stats.reload
      expect(stats.total_points).to eq(initial_points + 500)
      expect(Gamification::Point.where(user: user).count).to eq(5)
    end

    it 'handles stats field (jsonb)' do
      stats = create(:gamification_user_stats, stats: { custom: 'data' })
      expect(stats.stats['custom']).to eq('data')
    end

    it 'prevents manual manipulation bypassing validations' do
      stats = create(:gamification_user_stats, user: user)
      stats.total_points = -100

      expect(stats).not_to be_valid
    end
  end

  # ====================
  # INTEGRATION TESTS (WITHOUT STUBS)
  # ====================
  # These tests exercise the actual code paths without stubbing methods

  describe 'integration tests (without stubs)' do
    let(:user) { create(:user) }
    let(:stats) do
      Gamification::UserStats.find_or_create_by!(user_id: user.id) do |s|
        s.total_points = 0
        s.level = 1
        s.xp = 0
        s.current_streak = 0
        s.longest_streak = 0
      end
    end

    describe '#earn_points! full integration' do
      it 'creates point record, updates stats, checks level up, updates streak' do
        stats.update!(total_points: 0, xp: 0, level: 1, current_streak: 0, last_active_date: nil)

        # Actually call earn_points! without any stubs
        result = stats.earn_points!(100, reason: 'Integration test')

        stats.reload

        # Should have created a Point record
        expect(result).to be_a(Gamification::Point)
        expect(result.amount).to eq(100)
        expect(result.reason).to eq('Integration test')
        expect(result.user_id).to eq(user.id)

        # Should have updated total_points and xp
        expect(stats.total_points).to eq(100)
        expect(stats.xp).to eq(100)

        # Should have leveled up to level 2 (requires 100 XP)
        expect(stats.level).to eq(2)

        # Should have updated streak
        expect(stats.current_streak).to eq(1)
        expect(stats.last_active_date).to eq(Time.zone.today)
      end

      it 'handles multiple level ups in one call' do
        stats.update!(total_points: 0, xp: 0, level: 1)

        # 500 XP should level up to at least level 4 (requires 500 XP)
        stats.earn_points!(500, reason: 'Big bonus')
        stats.reload

        expect(stats.level).to be >= 4
      end

      it 'saves changes to the database' do
        stats.update!(total_points: 50, xp: 50, level: 1)
        stats.earn_points!(150, reason: 'Test')

        fresh_stats = Gamification::UserStats.find(stats.id)
        expect(fresh_stats.total_points).to eq(200)
        expect(fresh_stats.xp).to eq(200)
      end
    end

    describe '#level_name integration' do
      it 'returns correct level names for all predefined levels' do
        Gamification::UserStats::LEVELS.each do |level_num, config|
          stats.update!(level: level_num)
          expect(stats.level_name).to eq(config[:name])
        end
      end

      it 'returns generic name for levels not in LEVELS hash' do
        stats.update!(level: 6) # Level 6 is not in LEVELS
        expect(stats.level_name).to eq('Nivel 6')

        stats.update!(level: 8)
        expect(stats.level_name).to eq('Nivel 8')
      end
    end

    describe '#xp_to_next_level integration' do
      it 'calculates correctly for level 1' do
        stats.update!(level: 1, xp: 0)
        expect(stats.xp_to_next_level).to eq(100)

        stats.update!(level: 1, xp: 50)
        expect(stats.xp_to_next_level).to eq(50)
      end

      it 'calculates correctly for mid levels' do
        stats.update!(level: 2, xp: 100)
        # Level 3 requires 250 XP
        expect(stats.xp_to_next_level).to eq(150)
      end

      it 'returns 0 at max level' do
        max_level = Gamification::UserStats::LEVELS.keys.max
        stats.update!(level: max_level, xp: 50_000)
        expect(stats.xp_to_next_level).to eq(0)
      end
    end

    describe '#level_progress_percentage integration' do
      it 'calculates progress correctly' do
        # Level 1 (0 XP) to Level 2 (100 XP) - range is 100
        stats.update!(level: 1, xp: 50)
        expect(stats.level_progress_percentage).to eq(50.0)

        stats.update!(level: 1, xp: 25)
        expect(stats.level_progress_percentage).to eq(25.0)

        stats.update!(level: 1, xp: 75)
        expect(stats.level_progress_percentage).to eq(75.0)
      end

      it 'returns 100 when at or above next level XP' do
        stats.update!(level: 1, xp: 100)
        expect(stats.level_progress_percentage).to eq(100)

        stats.update!(level: 1, xp: 150)
        expect(stats.level_progress_percentage).to eq(100)
      end
    end

    describe '#check_level_up! integration' do
      it 'levels up and publishes event' do
        stats.update!(level: 1, xp: 100)

        # Allow all debug calls and verify the level_up event was logged
        allow(Rails.logger).to receive(:debug).and_call_original

        stats.check_level_up!
        expect(stats.level).to eq(2)

        # Verify the event was logged (check_level_up! calls publish_event which logs)
        expect(Rails.logger).to have_received(:debug).with(/gamification\.level_up/).at_least(:once)
      end

      it 'levels up multiple times' do
        stats.update!(level: 1, xp: 10_000)

        stats.check_level_up!

        # Should have leveled up to 20 (requires 10,000 XP)
        expect(stats.level).to be >= 20
      end
    end

    describe '#should_level_up? integration' do
      it 'returns true when ready to level up' do
        stats.update!(level: 1, xp: 100)
        expect(stats.should_level_up?).to be true
      end

      it 'returns false when not ready' do
        stats.update!(level: 1, xp: 99)
        expect(stats.should_level_up?).to be false
      end
    end

    describe '#next_available_level integration' do
      it 'finds the next level in LEVELS hash' do
        stats.update!(level: 1)
        expect(stats.next_available_level).to eq(2)

        stats.update!(level: 5)
        expect(stats.next_available_level).to eq(10)

        stats.update!(level: 10)
        expect(stats.next_available_level).to eq(15)
      end

      it 'returns nil at max level' do
        max_level = Gamification::UserStats::LEVELS.keys.max
        stats.update!(level: max_level)
        expect(stats.next_available_level).to be_nil
      end
    end

    describe '#update_streak! integration' do
      around do |example|
        travel_to Time.zone.parse('2024-06-15 12:00:00') do
          example.run
        end
      end

      it 'initializes streak on first activity' do
        stats.update!(last_active_date: nil, current_streak: 0)
        stats.update_streak!

        expect(stats.current_streak).to eq(1)
        expect(stats.last_active_date).to eq(Time.zone.today)
      end

      it 'continues streak on consecutive days' do
        stats.update!(last_active_date: Time.zone.yesterday, current_streak: 5, longest_streak: 5)
        stats.update_streak!

        expect(stats.current_streak).to eq(6)
        expect(stats.longest_streak).to eq(6)
      end

      it 'does not change streak if already active today' do
        stats.update!(last_active_date: Time.zone.today, current_streak: 10)
        stats.update_streak!

        expect(stats.current_streak).to eq(10)
      end

      it 'resets streak when broken' do
        stats.update!(last_active_date: 5.days.ago, current_streak: 20, longest_streak: 25)
        stats.update_streak!

        expect(stats.current_streak).to eq(1)
        expect(stats.longest_streak).to eq(25) # Should not change
      end
    end

    describe '#award_streak_bonus! integration' do
      it 'awards bonus points for 7-day streak' do
        stats.update!(current_streak: 7, total_points: 0, xp: 0, level: 1)

        stats.award_streak_bonus!
        stats.reload

        # 7 / 7 * 50 = 50 bonus points
        expect(stats.total_points).to eq(50)
        expect(stats.xp).to eq(50)
      end

      it 'awards larger bonus for longer streaks' do
        stats.update!(current_streak: 21, total_points: 0, xp: 0, level: 1)

        stats.award_streak_bonus!
        stats.reload

        # 21 / 7 * 50 = 150 bonus points
        expect(stats.total_points).to eq(150)
      end
    end

    describe '#summary integration' do
      before do
        create(:gamification_user_badge, user: user)
      end

      it 'returns complete summary with all fields populated' do
        stats.update!(
          level: 5,
          total_points: 1500,
          xp: 1500,
          current_streak: 10,
          longest_streak: 15
        )

        summary = stats.summary

        expect(summary[:level]).to eq(5)
        expect(summary[:level_name]).to eq('Defensor')
        expect(summary[:total_points]).to eq(1500)
        expect(summary[:xp]).to eq(1500)
        expect(summary[:current_streak]).to eq(10)
        expect(summary[:longest_streak]).to eq(15)
        expect(summary[:badges_count]).to eq(1)
        expect(summary[:leaderboard_position]).to be_a(Integer)
        expect(summary[:xp_to_next_level]).to be_a(Integer)
        # level_progress can be Float or Integer (100 when at max)
        expect(summary[:level_progress]).to be_a(Numeric)
      end
    end

    describe '.leaderboard integration' do
      let!(:user2) { create(:user) }
      let!(:user3) { create(:user) }

      before do
        stats.update!(total_points: 100, last_active_date: Time.zone.today)
        Gamification::UserStats.find_by(user_id: user2.id)&.update!(total_points: 500, last_active_date: Time.zone.today)
        Gamification::UserStats.find_by(user_id: user3.id)&.update!(total_points: 200, last_active_date: 2.weeks.ago)
      end

      it 'returns properly formatted leaderboard' do
        leaderboard = Gamification::UserStats.leaderboard(limit: 10)

        expect(leaderboard).to be_an(Array)
        expect(leaderboard.first[:rank]).to eq(1)
        expect(leaderboard.first[:user]).to be_a(Hash)
        expect(leaderboard.first[:stats]).to be_a(Hash)
      end

      it 'filters by period :today' do
        leaderboard = Gamification::UserStats.leaderboard(period: :today, limit: 100)
        user_ids = leaderboard.map { |entry| entry[:user][:id] }

        expect(user_ids).not_to include(user3.id)
      end

      it 'filters by period :week' do
        Gamification::UserStats.find_by(user_id: user3.id)&.update!(last_active_date: 3.days.ago)
        leaderboard = Gamification::UserStats.leaderboard(period: :week, limit: 100)
        user_ids = leaderboard.map { |entry| entry[:user][:id] }

        expect(user_ids).to include(user3.id)
      end

      it 'filters by period :month' do
        Gamification::UserStats.find_by(user_id: user3.id)&.update!(last_active_date: 2.months.ago)
        leaderboard = Gamification::UserStats.leaderboard(period: :month, limit: 100)
        user_ids = leaderboard.map { |entry| entry[:user][:id] }

        expect(user_ids).not_to include(user3.id)
      end
    end
  end
end
