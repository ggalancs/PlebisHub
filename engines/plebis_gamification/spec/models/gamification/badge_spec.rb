# frozen_string_literal: true

require 'rails_helper'

module Gamification
  RSpec.describe Badge, type: :model do
    describe 'associations' do
      it 'has many user_badges' do
        badge = create(:gamification_badge)
        expect(badge).to respond_to(:user_badges)
        expect(badge.user_badges).to be_a(ActiveRecord::Associations::CollectionProxy)
      end

      it 'has many users through user_badges' do
        badge = create(:gamification_badge)
        expect(badge).to respond_to(:users)
      end
    end

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

      describe 'uniqueness' do
        it 'validates uniqueness of key' do
          create(:gamification_badge, key: 'test_key')
          duplicate = build(:gamification_badge, key: 'test_key')
          expect(duplicate).not_to be_valid
          expect(duplicate.errors[:key]).to be_present
        end
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

        it 'rejects invalid tier' do
          badge = build(:gamification_badge, tier: 'invalid')
          expect(badge).not_to be_valid
        end
      end
    end

    describe 'scopes' do
      describe '.by_category' do
        it 'filters by category' do
          proposals_badge = create(:gamification_badge, category: 'proposals')
          voting_badge = create(:gamification_badge, category: 'voting')

          result = Badge.by_category('proposals')
          expect(result).to include(proposals_badge)
          expect(result).not_to include(voting_badge)
        end
      end

      describe '.by_tier' do
        it 'filters by tier' do
          bronze = create(:gamification_badge, tier: 'bronze')
          gold = create(:gamification_badge, tier: 'gold')

          result = Badge.by_tier('bronze')
          expect(result).to include(bronze)
          expect(result).not_to include(gold)
        end
      end
    end

    describe 'table name' do
      it 'uses gamification_badges table' do
        expect(Badge.table_name).to eq('gamification_badges')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        badge = build(:gamification_badge)
        expect(badge).to be_valid
      end

      it 'creates a badge with all required attributes' do
        badge = create(:gamification_badge)
        expect(badge).to be_persisted
        expect(badge.key).to be_present
        expect(badge.name).to be_present
        expect(badge.icon).to be_present
      end
    end

    # ====================
    # INTEGRATION TESTS
    # ====================

    describe '#criteria_met?' do
      let(:user) { create(:user) }
      let(:badge) { create(:gamification_badge) }
      let!(:stats) do
        Gamification::UserStats.find_or_create_by!(user_id: user.id) do |s|
          s.total_points = 0
          s.level = 1
          s.xp = 0
          s.current_streak = 0
          s.longest_streak = 0
        end
      end

      before do
        # Stub associations that might not exist in test DB schema
        # The proposals table uses "author" column, not "user_id"
        allow(user).to receive(:respond_to?).and_call_original
        allow(user).to receive(:respond_to?).with(:authored_proposals).and_return(false)
        allow(user).to receive(:respond_to?).with(:proposals).and_return(false)
        allow(user).to receive(:respond_to?).with(:votes).and_return(false)
        allow(user).to receive(:respond_to?).with(:comments).and_return(false)
      end

      it 'checks criteria against user metrics' do
        badge.update!(criteria: { 'level' => { 'gte' => 1 } })
        expect(badge.criteria_met?(user)).to be true
      end

      it 'returns false when criteria not met' do
        badge.update!(criteria: { 'level' => { 'gte' => 100 } })
        expect(badge.criteria_met?(user)).to be false
      end

      it 'handles streak_days criteria' do
        stats.update!(current_streak: 5)
        badge.update!(criteria: { 'streak_days' => { 'gte' => 3 } })
        expect(badge.criteria_met?(user)).to be true

        badge.update!(criteria: { 'streak_days' => { 'gte' => 10 } })
        expect(badge.criteria_met?(user)).to be false
      end

      it 'handles registered_before date criteria' do
        # User registered today
        badge.update!(criteria: { 'registered_before' => (Date.today + 1.day).to_s })
        expect(badge.criteria_met?(user)).to be true

        badge.update!(criteria: { 'registered_before' => (Date.today - 10.years).to_s })
        expect(badge.criteria_met?(user)).to be false
      end

      it 'handles proposals_created criteria when user has no proposals method' do
        # User doesn't have proposals association, so count defaults to 0
        badge.update!(criteria: { 'proposals_created' => { 'gte' => 1 } })
        expect(badge.criteria_met?(user)).to be false

        badge.update!(criteria: { 'proposals_created' => { 'gte' => 0 } })
        expect(badge.criteria_met?(user)).to be true
      end

      it 'handles votes_cast criteria when user has no votes method' do
        # User doesn't have votes association, so count defaults to 0
        badge.update!(criteria: { 'votes_cast' => { 'gte' => 1 } })
        expect(badge.criteria_met?(user)).to be false

        badge.update!(criteria: { 'votes_cast' => { 'gte' => 0 } })
        expect(badge.criteria_met?(user)).to be true
      end

      it 'handles comments_posted criteria when user has no comments method' do
        # User doesn't have comments association, so count defaults to 0
        badge.update!(criteria: { 'comments_posted' => { 'gte' => 1 } })
        expect(badge.criteria_met?(user)).to be false

        badge.update!(criteria: { 'comments_posted' => { 'gte' => 0 } })
        expect(badge.criteria_met?(user)).to be true
      end

      it 'handles multiple criteria' do
        stats.update!(level: 5, current_streak: 10)
        badge.update!(criteria: { 'level' => { 'gte' => 3 }, 'streak_days' => { 'gte' => 7 } })
        expect(badge.criteria_met?(user)).to be true

        badge.update!(criteria: { 'level' => { 'gte' => 10 }, 'streak_days' => { 'gte' => 7 } })
        expect(badge.criteria_met?(user)).to be false
      end
    end

    describe '#check_condition' do
      let(:badge) { build(:gamification_badge) }

      context 'with hash conditions' do
        it 'handles :gte (greater than or equal)' do
          expect(badge.check_condition(10, { gte: 5 })).to be true
          expect(badge.check_condition(5, { gte: 5 })).to be true
          expect(badge.check_condition(3, { gte: 5 })).to be false
        end

        it 'handles :gt (greater than)' do
          expect(badge.check_condition(10, { gt: 5 })).to be true
          expect(badge.check_condition(5, { gt: 5 })).to be false
        end

        it 'handles :lte (less than or equal)' do
          expect(badge.check_condition(3, { lte: 5 })).to be true
          expect(badge.check_condition(5, { lte: 5 })).to be true
          expect(badge.check_condition(10, { lte: 5 })).to be false
        end

        it 'handles :lt (less than)' do
          expect(badge.check_condition(3, { lt: 5 })).to be true
          expect(badge.check_condition(5, { lt: 5 })).to be false
        end

        it 'handles :eq (equal)' do
          expect(badge.check_condition(5, { eq: 5 })).to be true
          expect(badge.check_condition(10, { eq: 5 })).to be false
        end

        it 'handles multiple conditions in one hash' do
          expect(badge.check_condition(5, { gte: 3, lte: 10 })).to be true
          expect(badge.check_condition(15, { gte: 3, lte: 10 })).to be false
        end

        it 'handles unknown operators by returning false' do
          expect(badge.check_condition(5, { unknown: 5 })).to be false
        end
      end

      context 'with string conditions (date comparison)' do
        it 'compares dates' do
          past_date = Date.today - 30.days
          expect(badge.check_condition(past_date, '2030-01-01')).to be true
          expect(badge.check_condition(Date.today, '2000-01-01')).to be false
        end
      end

      context 'with direct value conditions' do
        it 'compares for equality with numbers' do
          expect(badge.check_condition(5, 5)).to be true
          expect(badge.check_condition(5, 10)).to be false
        end

        it 'compares for equality with symbols' do
          expect(badge.check_condition(:active, :active)).to be true
          expect(badge.check_condition(:active, :inactive)).to be false
        end
      end
    end

    describe '.seed!' do
      it 'creates predefined badges' do
        # Clear existing badges
        Badge.delete_all

        Badge.seed!

        expect(Badge.count).to eq(Badge::PREDEFINED_BADGES.count)
      end

      it 'creates badges with correct attributes' do
        Badge.delete_all
        Badge.seed!

        first_badge_data = Badge::PREDEFINED_BADGES.first
        badge = Badge.find_by(key: first_badge_data[:key])

        expect(badge).to be_present
        expect(badge.name).to eq(first_badge_data[:name])
        expect(badge.description).to eq(first_badge_data[:description])
        expect(badge.icon).to eq(first_badge_data[:icon])
        expect(badge.tier).to eq(first_badge_data[:tier])
      end

      it 'does not create duplicates' do
        Badge.delete_all
        Badge.seed!
        initial_count = Badge.count

        Badge.seed!
        expect(Badge.count).to eq(initial_count)
      end
    end

    describe 'PREDEFINED_BADGES constant' do
      it 'is a frozen array' do
        expect(Badge::PREDEFINED_BADGES).to be_frozen
      end

      it 'contains valid badge definitions' do
        Badge::PREDEFINED_BADGES.each do |badge_data|
          expect(badge_data).to have_key(:key)
          expect(badge_data).to have_key(:name)
          expect(badge_data).to have_key(:icon)
          expect(badge_data).to have_key(:category)
        end
      end

      it 'has unique keys' do
        keys = Badge::PREDEFINED_BADGES.map { |b| b[:key] }
        expect(keys.uniq.count).to eq(keys.count)
      end
    end
  end
end
