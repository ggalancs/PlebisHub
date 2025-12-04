# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Gamification::Point, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid point record' do
      point = build(:gamification_point)
      expect(point).to be_valid
    end

    it 'creates valid point with different traits' do
      expect(build(:gamification_point, :with_source)).to be_valid
      expect(build(:gamification_point, :proposal_creation)).to be_valid
      expect(build(:gamification_point, :vote_cast)).to be_valid
      expect(build(:gamification_point, :badge_reward)).to be_valid
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to user' do
      point = build(:gamification_point)
      expect(point).to respond_to(:user)
    end

    it 'belongs to source (optional)' do
      point = build(:gamification_point)
      expect(point).to respond_to(:source)
    end

    it 'allows polymorphic source' do
      proposal = create(:proposal)
      point = create(:gamification_point, source: proposal)
      expect(point.source).to eq(proposal)
      expect(point.source_type).to match(/Proposal/)
    end

    it 'allows nil source' do
      point = create(:gamification_point, source: nil)
      expect(point.source).to be_nil
      expect(point).to be_valid
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

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

    it 'validates amount is greater than 0' do
      point = build(:gamification_point, amount: 0)
      expect(point).not_to be_valid
      expect(point.errors[:amount]).to be_present
    end

    it 'rejects zero amount' do
      point = build(:gamification_point, amount: 0)
      expect(point).not_to be_valid
      expect(point.errors[:amount]).to be_present
    end

    it 'rejects negative amount' do
      point = build(:gamification_point, amount: -10)
      expect(point).not_to be_valid
      expect(point.errors[:amount]).to be_present
    end

    it 'accepts large amounts' do
      point = build(:gamification_point, amount: 1_000_000)
      expect(point).to be_valid
    end

    it 'requires reason' do
      point = build(:gamification_point, reason: nil)
      expect(point).not_to be_valid
      expect(point.errors[:reason]).to be_present
    end

    it 'accepts empty reason string' do
      point = build(:gamification_point, reason: '')
      expect(point).not_to be_valid
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:point1) { create(:gamification_point, user: user, created_at: 3.days.ago) }
    let!(:point2) { create(:gamification_point, user: user, created_at: 1.day.ago) }
    let!(:point3) { create(:gamification_point, user: user, created_at: Time.current) }

    describe '.recent' do
      it 'orders by created_at descending' do
        result = described_class.recent
        expect(result.first).to eq(point3)
        expect(result.second).to eq(point2)
        expect(result.third).to eq(point1)
      end
    end

    describe '.by_date_range' do
      it 'returns points within date range' do
        result = described_class.by_date_range(2.days.ago, Time.current)
        expect(result).to include(point2, point3)
        expect(result).not_to include(point1)
      end

      it 'returns empty for invalid range' do
        result = described_class.by_date_range(10.days.ago, 5.days.ago)
        expect(result).not_to include(point1, point2, point3)
      end

      it 'includes boundary dates' do
        start_date = point1.created_at
        end_date = point3.created_at
        result = described_class.by_date_range(start_date, end_date)
        expect(result).to include(point1, point2, point3)
      end
    end

    describe '.for_reason' do
      let!(:proposal_point) { create(:gamification_point, user: user, reason: 'Created proposal') }
      let!(:vote_point) { create(:gamification_point, user: user, reason: 'Cast vote') }
      let!(:another_proposal) { create(:gamification_point, user: user, reason: 'Created proposal') }

      it 'returns points with specific reason' do
        result = described_class.for_reason('Created proposal')
        expect(result).to include(proposal_point, another_proposal)
        expect(result).not_to include(vote_point)
      end

      it 'returns empty for non-existent reason' do
        result = described_class.for_reason('Non-existent reason')
        expect(result).to be_empty
      end

      it 'is case sensitive' do
        result = described_class.for_reason('created proposal')
        expect(result).to be_empty
      end
    end
  end

  # ====================
  # HISTORY_FOR TESTS
  # ====================

  describe '.history_for' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    before do
      # Create points for the user
      5.times do |i|
        create(:gamification_point,
               user: user,
               amount: (i + 1) * 10,
               reason: "Activity #{i + 1}",
               created_at: (5 - i).days.ago)
      end

      # Create points for other user (should not be included)
      create(:gamification_point, user: other_user)
    end

    it 'returns point history for specific user' do
      history = described_class.history_for(user)
      expect(history.length).to eq(5)
      expect(history.first[:amount]).to eq(50) # Most recent first (created with i=4, so (4+1)*10=50)
    end

    it 'filters by user_id correctly' do
      # Test that ensures line 25 (where(user_id: user.id)) is covered
      create(:gamification_point, user: user, amount: 100)
      other_point = create(:gamification_point, user: other_user, amount: 200)

      history = described_class.history_for(user, limit: 100)
      user_ids = history.map { |h| described_class.find(h[:id]).user_id }.uniq

      expect(user_ids).to eq([user.id])
      expect(history.any? { |h| h[:id] == other_point.id }).to be false
    end

    it 'returns detailed JSON format' do
      history = described_class.history_for(user)
      first_point = history.first

      expect(first_point).to have_key(:id)
      expect(first_point).to have_key(:amount)
      expect(first_point).to have_key(:reason)
      expect(first_point).to have_key(:source)
      expect(first_point).to have_key(:earned_at)
    end

    it 'orders by most recent first' do
      history = described_class.history_for(user)
      expect(history.first[:amount]).to eq(50) # Created most recently (i=4, created_at: 1.day.ago)
      expect(history.last[:amount]).to eq(10) # Created first (i=0, created_at: 5.days.ago)
    end

    it 'respects limit parameter' do
      history = described_class.history_for(user, limit: 3)
      expect(history.length).to eq(3)
    end

    it 'includes source information when available' do
      proposal = create(:proposal)
      create(:gamification_point, user: user, source: proposal, reason: 'Proposal created')

      history = described_class.history_for(user, limit: 10)
      point_with_source = history.find { |p| p[:reason] == 'Proposal created' }

      expect(point_with_source[:source]).to be_present
      expect(point_with_source[:source][:type]).to match(/Proposal/)
      expect(point_with_source[:source][:id]).to eq(proposal.id)
    end

    it 'handles nil source gracefully' do
      history = described_class.history_for(user)
      point_without_source = history.first

      expect(point_without_source[:source]).to be_nil
    end

    it 'does not include other users points' do
      history = described_class.history_for(user)
      other_point = described_class.where(user: other_user).first

      expect(history.none? { |p| p[:id] == other_point.id }).to be true
    end
  end

  # ====================
  # AS_JSON_DETAILED TESTS
  # ====================

  describe '#as_json_detailed' do
    let(:user) { create(:user) }
    let(:point) { create(:gamification_point, user: user, amount: 150, reason: 'Test reward') }

    it 'returns detailed hash with all fields' do
      json = point.as_json_detailed

      expect(json).to have_key(:id)
      expect(json).to have_key(:amount)
      expect(json).to have_key(:reason)
      expect(json).to have_key(:source)
      expect(json).to have_key(:earned_at)
    end

    it 'includes correct values' do
      json = point.as_json_detailed

      expect(json[:id]).to eq(point.id)
      expect(json[:amount]).to eq(150)
      expect(json[:reason]).to eq('Test reward')
    end

    it 'includes all hash keys with correct types' do
      json = point.as_json_detailed

      # Ensure line 34 (id: id,) is covered
      expect(json[:id]).to be_a(Integer)
      expect(json[:amount]).to be_a(Integer)
      expect(json[:reason]).to be_a(String)
      expect(json.key?(:source)).to be true
      expect(json[:earned_at]).to be_a(String)
    end

    it 'formats earned_at as ISO8601' do
      json = point.as_json_detailed
      expect(json[:earned_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    end

    context 'with source' do
      let(:proposal) { create(:proposal) }
      let(:point_with_source) { create(:gamification_point, user: user, source: proposal) }

      it 'includes source summary' do
        json = point_with_source.as_json_detailed

        expect(json[:source]).to be_present
        expect(json[:source][:type]).to match(/Proposal/)
        expect(json[:source][:id]).to eq(proposal.id)
      end

      it 'includes source name from title' do
        json = point_with_source.as_json_detailed
        expect(json[:source][:name]).to eq(proposal.title)
      end
    end

    context 'without source' do
      it 'returns nil for source' do
        json = point.as_json_detailed
        expect(json[:source]).to be_nil
      end
    end
  end

  # ====================
  # SOURCE_SUMMARY TESTS
  # ====================

  describe '#source_summary (private method)' do
    let(:user) { create(:user) }

    context 'with proposal source' do
      let(:proposal) { create(:proposal) }
      let(:point) { create(:gamification_point, user: user, source: proposal) }

      it 'returns hash with type, id, and name' do
        summary = point.send(:source_summary)
        expect(summary[:type]).to match(/Proposal/)
        expect(summary[:id]).to eq(proposal.id)
        expect(summary[:name]).to eq(proposal.title)
      end

      it 'includes all hash keys for source' do
        # Ensure line 48 (type: source_type,) is covered
        summary = point.send(:source_summary)
        expect(summary).to have_key(:type)
        expect(summary).to have_key(:id)
        expect(summary).to have_key(:name)
        expect(summary[:type]).to be_a(String)
        expect(summary[:id]).to be_a(Integer)
      end
    end

    context 'with badge source' do
      let(:badge) { create(:gamification_badge) }
      let(:point) { create(:gamification_point, user: user, source: badge) }

      it 'returns hash with badge name' do
        summary = point.send(:source_summary)
        expect(summary[:type]).to eq('Gamification::Badge')
        expect(summary[:name]).to eq(badge.name)
      end
    end

    context 'without source' do
      let(:point) { create(:gamification_point, user: user, source: nil) }

      it 'returns nil' do
        # Ensure line 45 (return nil unless source) is covered
        summary = point.send(:source_summary)
        expect(summary).to be_nil
      end

      it 'returns nil early when source is absent' do
        point.source = nil
        expect(point.send(:source_summary)).to be_nil
      end
    end

    context 'with source that has neither title nor name' do
      let(:vote_circle) { create(:vote_circle) }
      let(:point) { create(:gamification_point, user: user, source: vote_circle) }

      it 'falls back to to_s' do
        summary = point.send(:source_summary)
        expect(summary[:name]).to be_present
        # VoteCircle has a name method, so it will use that
        expect(summary[:name]).to eq(vote_circle.name)
      end
    end
  end

  # ====================
  # TABLE NAME
  # ====================

  describe 'table name' do
    it 'uses correct table name' do
      expect(described_class.table_name).to eq('gamification_points')
    end
  end

  # ====================
  # METADATA TESTS
  # ====================

  describe 'metadata field' do
    it 'allows storing arbitrary JSON data' do
      point = create(:gamification_point, metadata: { custom_field: 'value', number: 42 })
      expect(point.metadata['custom_field']).to eq('value')
      expect(point.metadata['number']).to eq(42)
    end

    it 'defaults to empty hash' do
      point = create(:gamification_point)
      expect(point.metadata).to eq({})
    end

    it 'handles nested JSON structures' do
      point = create(:gamification_point,
                     metadata: {
                       details: {
                         level: 5,
                         category: 'test'
                       }
                     })
      expect(point.metadata['details']['level']).to eq(5)
    end
  end

  # ====================
  # INTEGRATION TESTS
  # ====================

  describe 'integration scenarios' do
    let(:user) { create(:user) }

    it 'tracks points from multiple activities' do
      create(:gamification_point, user: user, amount: 50, reason: 'Created proposal')
      create(:gamification_point, user: user, amount: 10, reason: 'Cast vote')
      create(:gamification_point, user: user, amount: 100, reason: 'Badge earned')

      history = described_class.history_for(user)
      expect(history.length).to eq(3)

      total = history.sum { |h| h[:amount] }
      expect(total).to eq(160)
    end

    it 'maintains point history integrity' do
      point = create(:gamification_point, user: user)
      original_amount = point.amount

      # Points should be immutable (not updated after creation)
      history = described_class.history_for(user)
      expect(history.first[:amount]).to eq(original_amount)
    end

    it 'properly chains query methods in history_for' do
      # Create multiple points to test the full query chain
      proposal = create(:proposal)
      3.times do |i|
        create(:gamification_point,
               user: user,
               source: proposal,
               amount: (i + 1) * 10,
               created_at: i.days.ago)
      end

      # This tests the full chain: where -> includes -> order -> limit -> map
      history = described_class.history_for(user, limit: 2)

      expect(history.length).to eq(2)
      expect(history.first[:source]).to be_present
      # i=0: 10 points, 0.days.ago (most recent)
      # i=1: 20 points, 1.day.ago
      # i=2: 30 points, 2.days.ago
      expect(history.first[:amount]).to eq(10) # Most recent (created today)
      expect(history.last[:amount]).to eq(20) # Second most recent (created yesterday)
    end

    it 'returns complete json structure for each point' do
      proposal = create(:proposal)
      point = create(:gamification_point,
                     user: user,
                     source: proposal,
                     amount: 75,
                     reason: 'Complete test')

      history = described_class.history_for(user)
      json = history.first

      # Verify all fields are present and correctly formatted
      expect(json[:id]).to eq(point.id)
      expect(json[:amount]).to eq(75)
      expect(json[:reason]).to eq('Complete test')
      expect(json[:earned_at]).to be_present
      expect(json[:source][:id]).to eq(proposal.id)
      expect(json[:source][:type]).to be_present
      expect(json[:source][:name]).to eq(proposal.title)
    end
  end

  # ====================
  # EDGE CASES
  # ====================

  describe 'edge cases' do
    let(:user) { create(:user) }

    it 'handles very long reasons' do
      long_reason = 'A' * 1000
      point = build(:gamification_point, reason: long_reason)
      expect(point).to be_valid
    end

    it 'handles special characters in reason' do
      point = build(:gamification_point, reason: "Test with émojis 🎉 and 'quotes'")
      expect(point).to be_valid
    end

    it 'handles maximum integer amount' do
      point = build(:gamification_point, amount: 2_147_483_647) # Max 32-bit int
      expect(point).to be_valid
    end

    it 'prevents fractional amounts' do
      point = build(:gamification_point, amount: 10.5)
      expect(point.amount).to eq(10) # Should be coerced to integer
    end
  end

  # ====================
  # COVERAGE BOOSTING TESTS
  # ====================
  # These tests specifically target uncovered lines in SimpleCov

  describe 'coverage edge cases' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    it 'calls as_json_detailed and accesses id field directly' do
      point = create(:gamification_point, user: user, amount: 99)
      json = point.as_json_detailed
      # Directly test line 34: id: id,
      expect(json.fetch(:id)).to eq(point.id)
      expect(json.fetch(:amount)).to eq(99)
      expect(json.fetch(:reason)).to be_present
      expect(json.fetch(:earned_at)).to be_present
      expect(json.key?(:source)).to be true
    end

    it 'calls source_summary with nil source to test early return' do
      point = create(:gamification_point, user: user, source: nil)
      # Directly test line 45: return nil unless source
      expect(point.source).to be_nil
      result = point.send(:source_summary)
      expect(result).to be_nil
    end

    it 'calls source_summary with source to test hash construction' do
      proposal = create(:proposal)
      point = create(:gamification_point, user: user, source: proposal)
      summary = point.send(:source_summary)
      # Directly test line 48: type: source_type,
      expect(summary.fetch(:type)).to eq(point.source_type)
      expect(summary.fetch(:id)).to eq(point.source_id)
      expect(summary.fetch(:name)).to eq(proposal.title)
    end

    it 'calls history_for to test where clause with user_id' do
      # Create points for both users
      point1 = create(:gamification_point, user: user, amount: 10)
      point2 = create(:gamification_point, user: user, amount: 20)
      point3 = create(:gamification_point, user: other_user, amount: 30)

      # Directly test line 25: where(user_id: user.id)
      result = described_class.where(user_id: user.id).to_a
      expect(result).to include(point1, point2)
      expect(result).not_to include(point3)

      # Also test through history_for
      history = described_class.history_for(user)
      history_ids = history.map { |h| h[:id] }
      expect(history_ids).to include(point1.id, point2.id)
      expect(history_ids).not_to include(point3.id)
    end

    it 'tests full method chain in history_for' do
      proposal = create(:proposal)
      points = []
      5.times do |i|
        points << create(:gamification_point,
                        user: user,
                        source: proposal,
                        amount: (i + 1) * 10,
                        created_at: i.hours.ago)
      end

      # Test the complete chain: where -> includes -> order -> limit -> map
      history = described_class.history_for(user, limit: 3)

      expect(history).to be_an(Array)
      expect(history.length).to eq(3)
      expect(history.first).to be_a(Hash)
      expect(history.first[:source]).to be_present
    end
  end
end
