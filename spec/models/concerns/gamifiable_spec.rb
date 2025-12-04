# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gamifiable, type: :model do
  let(:user) { create(:user) }
  let(:gamification_stats) { user.gamification_user_stats }

  describe 'included module' do
    it 'extends ActiveSupport::Concern' do
      expect(Gamifiable).to be_a(ActiveSupport::Concern)
    end

    it 'is included in User model' do
      expect(user.class.ancestors).to include(Gamifiable)
    end
  end

  describe 'associations' do
    it 'has one gamification_user_stats' do
      expect(user).to respond_to(:gamification_user_stats)
    end

    it 'has many gamification_points' do
      expect(user).to respond_to(:gamification_points)
    end

    it 'has many gamification_user_badges' do
      expect(user).to respond_to(:gamification_user_badges)
    end

    it 'has many gamification_badges through user_badges' do
      expect(user).to respond_to(:gamification_badges)
    end

    it 'gamification_points returns an ActiveRecord relation' do
      expect(user.gamification_points).to be_an(ActiveRecord::Relation)
    end

    it 'gamification_user_badges returns an ActiveRecord relation' do
      expect(user.gamification_user_badges).to be_an(ActiveRecord::Relation)
    end

    describe 'dependent options' do
      it 'destroys gamification_user_stats when user is destroyed' do
        stats = user.gamification_user_stats
        expect(stats).to be_present
        stats_id = stats.id

        user.destroy
        expect(Gamification::UserStats.where(id: stats_id).exists?).to be false
      end

      it 'destroys gamification_points when user is destroyed' do
        point = create(:gamification_point, user: user)
        expect { user.destroy }.to change(Gamification::Point, :count).by(-1)
      end

      it 'destroys gamification_user_badges when user is destroyed' do
        badge = create(:gamification_badge)
        create(:gamification_user_badge, user: user, badge: badge)
        expect { user.destroy }.to change(Gamification::UserBadge, :count).by(-1)
      end

      it 'destroys multiple associated records when user is destroyed' do
        create(:gamification_point, user: user)
        create(:gamification_point, user: user)
        badge = create(:gamification_badge)
        create(:gamification_user_badge, user: user, badge: badge)

        expect { user.destroy }.to change(Gamification::Point, :count).by(-2)
          .and change(Gamification::UserBadge, :count).by(-1)
          .and change(Gamification::UserStats, :count).by(-1)
      end
    end
  end

  describe 'callbacks' do
    describe 'after_create :initialize_gamification_stats' do
      it 'creates gamification_user_stats after user creation' do
        new_user = build(:user)
        expect { new_user.save! }.to change(Gamification::UserStats, :count).by(1)
      end

      it 'associates stats with the user' do
        new_user = create(:user)
        expect(new_user.gamification_user_stats).to be_present
        expect(new_user.gamification_user_stats.user_id).to eq(new_user.id)
      end

      it 'initializes stats only once' do
        new_user = create(:user)
        stats = new_user.gamification_user_stats
        new_user.reload
        expect(new_user.gamification_user_stats.id).to eq(stats.id)
      end
    end
  end

  describe '#gamification_stats' do
    it 'returns gamification_user_stats' do
      expect(user.gamification_stats).to eq(user.gamification_user_stats)
    end

    it 'memoizes the result' do
      stats = user.gamification_stats
      expect(user.instance_variable_get(:@gamification_stats)).to eq(stats)
    end

    it 'initializes stats if not present' do
      new_user = build(:user)
      new_user.save!

      # Clear memoization and destroy existing stats
      new_user.instance_variable_set(:@gamification_stats, nil)
      stats_id = new_user.gamification_user_stats&.id
      Gamification::UserStats.where(id: stats_id).delete_all if stats_id
      new_user.reload

      expect { new_user.gamification_stats }.to change(Gamification::UserStats, :count).by(1)
    end

    it 'returns same stats on multiple calls' do
      stats1 = user.gamification_stats
      stats2 = user.gamification_stats
      expect(stats1.id).to eq(stats2.id)
    end
  end

  describe 'delegated methods' do
    let(:stats) { user.gamification_user_stats }

    describe '#total_points' do
      it 'delegates to gamification_stats' do
        allow(stats).to receive(:total_points).and_return(100)
        expect(user.total_points).to eq(100)
      end

      it 'returns integer value' do
        expect(user.total_points).to be_a(Integer)
      end
    end

    describe '#level' do
      it 'delegates to gamification_stats' do
        allow(stats).to receive(:level).and_return(5)
        expect(user.level).to eq(5)
      end

      it 'returns integer value' do
        expect(user.level).to be_a(Integer)
      end
    end

    describe '#level_name' do
      it 'delegates to gamification_stats' do
        allow(stats).to receive(:level_name).and_return('Expert')
        expect(user.level_name).to eq('Expert')
      end

      it 'returns string value' do
        expect(user.level_name).to be_a(String)
      end
    end

    describe '#current_streak' do
      it 'delegates to gamification_stats' do
        allow(stats).to receive(:current_streak).and_return(7)
        expect(user.current_streak).to eq(7)
      end

      it 'returns integer value' do
        expect(user.current_streak).to be_a(Integer)
      end
    end

    describe '#leaderboard_position' do
      it 'delegates to gamification_stats' do
        allow(stats).to receive(:leaderboard_position).and_return(42)
        expect(user.leaderboard_position).to eq(42)
      end
    end
  end

  describe '#badges' do
    it 'returns gamification_badges' do
      expect(user.badges).to eq(user.gamification_badges)
    end

    it 'returns an ActiveRecord relation' do
      expect(user.badges).to be_an(ActiveRecord::Relation)
    end

    context 'with badges' do
      let(:badge1) { create(:gamification_badge, key: 'first_badge') }
      let(:badge2) { create(:gamification_badge, key: 'second_badge') }

      before do
        create(:gamification_user_badge, user: user, badge: badge1)
        create(:gamification_user_badge, user: user, badge: badge2)
      end

      it 'returns all user badges' do
        expect(user.badges.count).to eq(2)
        expect(user.badges).to include(badge1, badge2)
      end
    end
  end

  describe '#badges_count' do
    it 'returns 0 when user has no badges' do
      expect(user.badges_count).to eq(0)
    end

    it 'returns correct count when user has badges' do
      badge1 = create(:gamification_badge)
      badge2 = create(:gamification_badge)
      create(:gamification_user_badge, user: user, badge: badge1)
      create(:gamification_user_badge, user: user, badge: badge2)

      expect(user.badges_count).to eq(2)
    end

    it 'uses count method on gamification_user_badges' do
      expect(user.gamification_user_badges).to receive(:count).and_call_original
      user.badges_count
    end
  end

  describe '#earn_points!' do
    it 'delegates to gamification_stats' do
      expect(gamification_stats).to receive(:earn_points!).with(100, reason: 'test', source: nil)
      user.earn_points!(100, reason: 'test')
    end

    it 'passes amount and reason parameters' do
      expect(gamification_stats).to receive(:earn_points!).with(50, reason: 'completing task', source: nil)
      user.earn_points!(50, reason: 'completing task')
    end

    it 'passes source parameter when provided' do
      expect(gamification_stats).to receive(:earn_points!).with(75, reason: 'voting', source: 'election')
      user.earn_points!(75, reason: 'voting', source: 'election')
    end

    it 'creates a point record' do
      expect { user.earn_points!(100, reason: 'test') }.to change(Gamification::Point, :count).by(1)
    end

    it 'updates total_points' do
      initial_points = user.total_points
      user.earn_points!(100, reason: 'test')
      expect(user.reload.total_points).to eq(initial_points + 100)
    end
  end

  describe '#has_badge?' do
    let(:badge) { create(:gamification_badge, key: 'test_badge') }

    context 'when user has the badge' do
      before do
        create(:gamification_user_badge, user: user, badge: badge)
      end

      it 'returns true' do
        expect(user.has_badge?('test_badge')).to be true
      end

      it 'uses exists? for performance' do
        expect(user.gamification_badges).to receive(:exists?).with(key: 'test_badge').and_call_original
        user.has_badge?('test_badge')
      end
    end

    context 'when user does not have the badge' do
      it 'returns false' do
        expect(user.has_badge?('test_badge')).to be false
      end
    end

    context 'with multiple badges' do
      let(:badge1) { create(:gamification_badge, key: 'badge_one') }
      let(:badge2) { create(:gamification_badge, key: 'badge_two') }

      before do
        create(:gamification_user_badge, user: user, badge: badge1)
      end

      it 'returns true for owned badges' do
        expect(user.has_badge?('badge_one')).to be true
      end

      it 'returns false for non-owned badges' do
        expect(user.has_badge?('badge_two')).to be false
      end
    end
  end

  describe '#badges_by_category' do
    let(:badge1) { create(:gamification_badge, key: 'badge1', category: 'participation') }
    let(:badge2) { create(:gamification_badge, key: 'badge2', category: 'participation') }
    let(:badge3) { create(:gamification_badge, key: 'badge3', category: 'achievement') }

    before do
      create(:gamification_user_badge, user: user, badge: badge1)
      create(:gamification_user_badge, user: user, badge: badge2)
      create(:gamification_user_badge, user: user, badge: badge3)
    end

    it 'groups badges by category' do
      result = user.badges_by_category
      expect(result.keys).to contain_exactly('participation', 'achievement')
    end

    it 'includes correct badges in each category' do
      result = user.badges_by_category
      expect(result['participation']).to include(badge1, badge2)
      expect(result['achievement']).to include(badge3)
    end

    it 'returns a hash' do
      expect(user.badges_by_category).to be_a(Hash)
    end

    it 'returns empty hash when user has no badges' do
      user.gamification_user_badges.destroy_all
      expect(user.badges_by_category).to eq({})
    end
  end

  describe '#gamification_summary' do
    before do
      allow(gamification_stats).to receive(:xp).and_return(350)
      allow(gamification_stats).to receive(:xp_to_next_level).and_return(150)
      allow(gamification_stats).to receive(:level_progress_percentage).and_return(70.0)
      allow(gamification_stats).to receive(:longest_streak).and_return(10)
    end

    it 'returns a hash' do
      expect(user.gamification_summary).to be_a(Hash)
    end

    it 'includes level' do
      expect(user.gamification_summary[:level]).to eq(user.level)
    end

    it 'includes level_name' do
      expect(user.gamification_summary[:level_name]).to eq(user.level_name)
    end

    it 'includes total_points' do
      expect(user.gamification_summary[:total_points]).to eq(user.total_points)
    end

    it 'includes xp' do
      expect(user.gamification_summary[:xp]).to eq(350)
    end

    it 'includes xp_to_next_level' do
      expect(user.gamification_summary[:xp_to_next_level]).to eq(150)
    end

    it 'includes level_progress' do
      expect(user.gamification_summary[:level_progress]).to eq(70.0)
    end

    it 'includes current_streak' do
      expect(user.gamification_summary[:current_streak]).to eq(user.current_streak)
    end

    it 'includes longest_streak' do
      expect(user.gamification_summary[:longest_streak]).to eq(10)
    end

    it 'includes badges_count' do
      expect(user.gamification_summary[:badges_count]).to eq(user.badges_count)
    end

    it 'includes leaderboard_position' do
      expect(user.gamification_summary[:leaderboard_position]).to eq(user.leaderboard_position)
    end

    it 'includes recent_badges' do
      badge = create(:gamification_badge)
      user_badge = create(:gamification_user_badge, user: user, badge: badge)
      allow(user.gamification_user_badges).to receive_message_chain(:recent, :limit).and_return([user_badge])
      allow(user_badge).to receive(:as_json_summary).and_return({ badge_key: 'test' })

      expect(user.gamification_summary[:recent_badges]).to be_an(Array)
    end

    it 'limits recent_badges to 5' do
      6.times do |i|
        badge = create(:gamification_badge, key: "badge_#{i}")
        create(:gamification_user_badge, user: user, badge: badge)
      end

      # Verify that the summary only includes recent 5 badges
      summary = user.gamification_summary
      expect(summary[:recent_badges].length).to be <= 5
    end

    it 'includes all required keys' do
      summary = user.gamification_summary
      expected_keys = %i[
        level level_name total_points xp xp_to_next_level
        level_progress current_streak longest_streak
        badges_count leaderboard_position recent_badges
      ]
      expect(summary.keys).to match_array(expected_keys)
    end
  end

  describe 'private methods' do
    describe '#initialize_gamification_stats' do
      it 'creates UserStats with user_id' do
        new_user = build(:user)
        new_user.save!
        stats = new_user.gamification_user_stats
        expect(stats.user_id).to eq(new_user.id)
      end

      it 'is called after user creation' do
        new_user = build(:user)
        expect { new_user.save! }.to change(Gamification::UserStats, :count).by(1)
      end

      it 'raises error if creation fails' do
        new_user = build(:user)
        new_user.save!
        new_user.instance_variable_set(:@gamification_stats, nil)

        allow(Gamification::UserStats).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
        expect { new_user.send(:initialize_gamification_stats) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'integration tests' do
    it 'full gamification workflow' do
      new_user = create(:user)

      # User starts with initialized stats
      expect(new_user.gamification_stats).to be_present
      expect(new_user.total_points).to eq(0)
      expect(new_user.badges_count).to eq(0)

      # User earns points
      new_user.earn_points!(100, reason: 'first action')
      expect(new_user.reload.total_points).to eq(100)

      # User earns a badge
      badge = create(:gamification_badge, key: 'first_badge')
      create(:gamification_user_badge, user: new_user, badge: badge)
      expect(new_user.badges_count).to eq(1)
      expect(new_user.has_badge?('first_badge')).to be true

      # Summary includes all data
      summary = new_user.gamification_summary
      expect(summary[:total_points]).to eq(100)
      expect(summary[:badges_count]).to eq(1)
    end

    it 'handles multiple users independently' do
      user1 = create(:user)
      user2 = create(:user)

      user1.earn_points!(100, reason: 'action')
      user2.earn_points!(200, reason: 'action')

      expect(user1.reload.total_points).to eq(100)
      expect(user2.reload.total_points).to eq(200)
    end
  end
end
