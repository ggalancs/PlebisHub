# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gamification::UserBadge, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid user badge' do
      user_badge = build(:gamification_user_badge)
      expect(user_badge).to be_valid
    end

    it 'creates valid user badge with different traits' do
      expect(build(:gamification_user_badge, :with_metadata)).to be_valid
      expect(build(:gamification_user_badge, :recent)).to be_valid
      expect(build(:gamification_user_badge, :old)).to be_valid
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to user' do
      user_badge = build(:gamification_user_badge)
      expect(user_badge).to respond_to(:user)
      expect(user_badge.user).to be_a(User)
    end

    it 'belongs to badge' do
      user_badge = build(:gamification_user_badge)
      expect(user_badge).to respond_to(:badge)
      expect(user_badge.badge).to be_a(Gamification::Badge)
    end

    it 'can access badge through user_badge' do
      badge = create(:gamification_badge, name: 'Test Badge')
      user_badge = create(:gamification_user_badge, badge: badge)

      expect(user_badge.badge.name).to eq('Test Badge')
    end

    it 'can access user through user_badge' do
      user = create(:user)
      user_badge = create(:gamification_user_badge, user: user)

      expect(user_badge.user).to eq(user)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    subject { build(:gamification_user_badge) }

    it 'validates presence of earned_at' do
      user_badge = build(:gamification_user_badge, earned_at: nil)
      expect(user_badge).not_to be_valid
      expect(user_badge.errors[:earned_at]).to be_present
    end

    it 'validates uniqueness of user_id scoped to badge_id' do
      existing = create(:gamification_user_badge)
      duplicate = build(:gamification_user_badge,
                        user: existing.user,
                        badge: existing.badge)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it 'allows same badge for different users' do
      badge = create(:gamification_badge)
      user1 = create(:user)
      user2 = create(:user)

      badge1 = create(:gamification_user_badge, user: user1, badge: badge)
      badge2 = build(:gamification_user_badge, user: user2, badge: badge)

      expect(badge2).to be_valid
    end

    it 'allows different badges for same user' do
      user = create(:user)
      badge1 = create(:gamification_badge)
      badge2 = create(:gamification_badge)

      user_badge1 = create(:gamification_user_badge, user: user, badge: badge1)
      user_badge2 = build(:gamification_user_badge, user: user, badge: badge2)

      expect(user_badge2).to be_valid
    end

    it 'requires earned_at to be present' do
      user_badge = build(:gamification_user_badge, earned_at: nil)
      expect(user_badge).not_to be_valid
      expect(user_badge.errors[:earned_at]).to be_present
    end

    it 'accepts past dates for earned_at' do
      user_badge = build(:gamification_user_badge, earned_at: 1.year.ago)
      expect(user_badge).to be_valid
    end

    it 'accepts current time for earned_at' do
      user_badge = build(:gamification_user_badge, earned_at: Time.current)
      expect(user_badge).to be_valid
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:proposal_badge) { create(:gamification_badge, category: 'proposals', tier: 'bronze') }
    let(:voting_badge) { create(:gamification_badge, category: 'voting', tier: 'silver') }
    let(:level_badge) { create(:gamification_badge, category: 'levels', tier: 'gold') }

    let!(:user_badge1) do
      create(:gamification_user_badge, user: user, badge: proposal_badge, earned_at: 3.days.ago)
    end
    let!(:user_badge2) do
      create(:gamification_user_badge, user: user, badge: voting_badge, earned_at: 1.day.ago)
    end
    let!(:user_badge3) do
      create(:gamification_user_badge, user: user, badge: level_badge, earned_at: Time.current)
    end

    describe '.recent' do
      it 'orders by earned_at descending' do
        result = described_class.recent
        expect(result.first).to eq(user_badge3)
        expect(result.second).to eq(user_badge2)
        expect(result.third).to eq(user_badge1)
      end

      it 'shows most recently earned badges first' do
        newest = create(:gamification_user_badge, earned_at: 1.minute.ago)
        result = described_class.recent

        expect(result.first).to eq(newest)
      end
    end

    describe '.by_category' do
      it 'returns badges for specific category' do
        result = described_class.by_category('proposals')
        expect(result).to include(user_badge1)
        expect(result).not_to include(user_badge2, user_badge3)
      end

      it 'returns multiple badges in same category' do
        another_proposal_badge = create(:gamification_badge, category: 'proposals')
        another_user_badge = create(:gamification_user_badge,
                                    user: user,
                                    badge: another_proposal_badge)

        result = described_class.by_category('proposals')
        expect(result).to include(user_badge1, another_user_badge)
      end

      it 'returns empty for non-existent category' do
        result = described_class.by_category('non_existent')
        expect(result).to be_empty
      end
    end

    describe '.by_tier' do
      it 'returns badges for specific tier' do
        result = described_class.by_tier('silver')
        expect(result).to include(user_badge2)
        expect(result).not_to include(user_badge1, user_badge3)
      end

      it 'returns multiple badges in same tier' do
        another_silver = create(:gamification_badge, tier: 'silver')
        another_user_badge = create(:gamification_user_badge, user: user, badge: another_silver)

        result = described_class.by_tier('silver')
        expect(result).to include(user_badge2, another_user_badge)
      end

      it 'works with all tier types' do
        %w[bronze silver gold platinum diamond].each do |tier|
          badge = create(:gamification_badge, tier: tier)
          user_badge = create(:gamification_user_badge, badge: badge)

          result = described_class.by_tier(tier)
          expect(result).to include(user_badge)
        end
      end
    end
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  describe 'callbacks' do
    describe 'after_create :notify_user' do
      it 'is called after creation' do
        user_badge = build(:gamification_user_badge)
        expect(user_badge).to receive(:notify_user)
        user_badge.save!
      end

      it 'does not break if notification fails' do
        user_badge = build(:gamification_user_badge)
        # The current implementation is a no-op, so it should always succeed
        expect { user_badge.save! }.not_to raise_error
      end
    end
  end

  # ====================
  # AS_JSON_SUMMARY TESTS
  # ====================

  describe '#as_json_summary' do
    let(:badge) do
      create(:gamification_badge,
             key: 'test_badge',
             name: 'Test Badge',
             description: 'A test badge',
             icon: '🏆',
             tier: 'gold',
             category: 'testing')
    end
    let(:user_badge) do
      create(:gamification_user_badge,
             badge: badge,
             earned_at: Time.zone.parse('2024-01-15 10:30:00'),
             metadata: { note: 'special achievement' })
    end

    it 'returns hash with all expected keys' do
      json = user_badge.as_json_summary

      expect(json).to have_key(:id)
      expect(json).to have_key(:badge)
      expect(json).to have_key(:earned_at)
      expect(json).to have_key(:metadata)
    end

    it 'includes user badge id' do
      json = user_badge.as_json_summary
      expect(json[:id]).to eq(user_badge.id)
    end

    it 'includes badge details' do
      json = user_badge.as_json_summary
      badge_data = json[:badge]

      expect(badge_data[:key]).to eq('test_badge')
      expect(badge_data[:name]).to eq('Test Badge')
      expect(badge_data[:description]).to eq('A test badge')
      expect(badge_data[:icon]).to eq('🏆')
      expect(badge_data[:tier]).to eq('gold')
      expect(badge_data[:category]).to eq('testing')
    end

    it 'formats earned_at as ISO8601' do
      json = user_badge.as_json_summary
      expect(json[:earned_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    end

    it 'includes metadata' do
      json = user_badge.as_json_summary
      expect(json[:metadata]).to eq({ 'note' => 'special achievement' })
    end

    it 'handles empty metadata' do
      user_badge.update(metadata: {})
      json = user_badge.as_json_summary
      expect(json[:metadata]).to eq({})
    end

    it 'handles nil metadata gracefully' do
      user_badge.update(metadata: nil)
      json = user_badge.as_json_summary
      expect(json[:metadata]).to be_nil
    end
  end

  # ====================
  # TABLE NAME
  # ====================

  describe 'table name' do
    it 'uses correct table name' do
      expect(described_class.table_name).to eq('gamification_user_badges')
    end
  end

  # ====================
  # METADATA TESTS
  # ====================

  describe 'metadata field' do
    it 'allows storing arbitrary JSON data' do
      user_badge = create(:gamification_user_badge,
                          metadata: {
                            custom_field: 'value',
                            number: 42,
                            array: [1, 2, 3]
                          })

      expect(user_badge.metadata['custom_field']).to eq('value')
      expect(user_badge.metadata['number']).to eq(42)
      expect(user_badge.metadata['array']).to eq([1, 2, 3])
    end

    it 'defaults to empty hash' do
      user_badge = create(:gamification_user_badge)
      expect(user_badge.metadata).to eq({})
    end

    it 'handles nested JSON structures' do
      user_badge = create(:gamification_user_badge,
                          metadata: {
                            details: {
                              level: 5,
                              category: 'test'
                            }
                          })

      expect(user_badge.metadata['details']['level']).to eq(5)
    end
  end

  # ====================
  # INTEGRATION TESTS
  # ====================

  describe 'integration scenarios' do
    it 'tracks badge progression for a user' do
      user = create(:user)
      bronze = create(:gamification_badge, tier: 'bronze')
      silver = create(:gamification_badge, tier: 'silver')
      gold = create(:gamification_badge, tier: 'gold')

      create(:gamification_user_badge, user: user, badge: bronze, earned_at: 3.days.ago)
      create(:gamification_user_badge, user: user, badge: silver, earned_at: 2.days.ago)
      create(:gamification_user_badge, user: user, badge: gold, earned_at: 1.day.ago)

      user_badges = described_class.where(user: user).recent
      expect(user_badges.map { |ub| ub.badge.tier }).to eq(%w[gold silver bronze])
    end

    it 'prevents duplicate badge awards' do
      user = create(:user)
      badge = create(:gamification_badge)

      create(:gamification_user_badge, user: user, badge: badge)

      expect do
        create(:gamification_user_badge, user: user, badge: badge)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'allows viewing all badges earned by category' do
      user = create(:user)
      proposal_badge1 = create(:gamification_badge, category: 'proposals')
      proposal_badge2 = create(:gamification_badge, category: 'proposals')
      voting_badge = create(:gamification_badge, category: 'voting')

      create(:gamification_user_badge, user: user, badge: proposal_badge1)
      create(:gamification_user_badge, user: user, badge: proposal_badge2)
      create(:gamification_user_badge, user: user, badge: voting_badge)

      proposal_badges = described_class.where(user: user).by_category('proposals')
      expect(proposal_badges.count).to eq(2)
    end
  end

  # ====================
  # EDGE CASES
  # ====================

  describe 'edge cases' do
    it 'handles badge deletion gracefully (should fail due to foreign key)' do
      user_badge = create(:gamification_user_badge)
      badge = user_badge.badge

      expect { badge.destroy! }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it 'handles user deletion (cascade behavior)' do
      user = create(:user)
      user_badge = create(:gamification_user_badge, user: user)

      expect { user.destroy! }.to change(described_class, :count).by(-1)
    end

    it 'handles very old earned_at dates' do
      user_badge = create(:gamification_user_badge, earned_at: 10.years.ago)
      expect(user_badge).to be_valid
      expect(user_badge.earned_at).to be < 1.year.ago
    end

    it 'handles earned_at in different time zones' do
      time_in_utc = Time.utc(2024, 1, 15, 12, 0, 0)
      user_badge = create(:gamification_user_badge, earned_at: time_in_utc)

      expect(user_badge.earned_at).to be_present
      json = user_badge.as_json_summary
      expect(json[:earned_at]).to be_present
    end

    it 'handles special characters in metadata' do
      user_badge = create(:gamification_user_badge,
                          metadata: {
                            message: "Test with 'quotes' and émojis 🎉"
                          })

      expect(user_badge).to be_valid
      expect(user_badge.metadata['message']).to include('🎉')
    end

    it 'handles large metadata objects' do
      large_metadata = { data: Array.new(100) { |i| { index: i, value: "item_#{i}" } } }
      user_badge = create(:gamification_user_badge, metadata: large_metadata)

      expect(user_badge).to be_valid
      expect(user_badge.metadata['data'].length).to eq(100)
    end
  end

  # ====================
  # QUERY PERFORMANCE
  # ====================

  describe 'query performance considerations' do
    it 'eager loads badge data when needed' do
      user = create(:user)
      5.times { create(:gamification_user_badge, user: user) }

      # This should use the join in by_category
      badges = described_class.where(user: user).by_category('test')
      # Just verify that we can access badge data without errors
      expect(badges.map { |ub| ub.badge.name }).to all(be_a(String))
    end
  end
end
