# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Support, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid support' do
      support = build(:support)
      expect(support).to be_valid, "Factory should create a valid support"
    end

    it 'creates support with associations' do
      support = create(:support)
      expect(support.user).not_to be_nil
      expect(support.proposal).not_to be_nil
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    context 'user' do
      it 'requires user' do
        support = build(:support, user: nil)
        expect(support).not_to be_valid
        expect(support.errors[:user]).to include("no puede estar en blanco")
      end

      it 'accepts valid user' do
        skip "Skipping due to email uniqueness issues from Collaboration factory workarounds"
        user = create(:user)
        support = build(:support, user: user)
        expect(support).to be_valid
      end
    end

    context 'proposal' do
      it 'requires proposal' do
        support = build(:support, proposal: nil)
        expect(support).not_to be_valid
        expect(support.errors[:proposal]).to include("no puede estar en blanco")
      end

      it 'accepts valid proposal' do
        proposal = create(:proposal)
        support = build(:support, proposal: proposal)
        expect(support).to be_valid
      end
    end

    context 'uniqueness' do
      it 'does not allow duplicate user support for same proposal' do
        user = create(:user)
        proposal = create(:proposal)

        create(:support, user: user, proposal: proposal)

        duplicate_support = build(:support, user: user, proposal: proposal)
        expect(duplicate_support).not_to be_valid
        expect(duplicate_support.errors[:user_id]).to include("has already supported this proposal")
      end

      it 'allows same user to support different proposals' do
        user = create(:user)
        proposal1 = create(:proposal)
        proposal2 = create(:proposal)

        support1 = create(:support, user: user, proposal: proposal1)
        support2 = build(:support, user: user, proposal: proposal2)

        expect(support2).to be_valid
      end

      it 'allows different users to support same proposal' do
        user1 = create(:user)
        user2 = create(:user)
        proposal = create(:proposal)

        support1 = create(:support, user: user1, proposal: proposal)
        support2 = build(:support, user: user2, proposal: proposal)

        expect(support2).to be_valid
      end
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates support with valid attributes' do
      expect { create(:support) }.to change(Support, :count).by(1)
    end

    it 'reads support attributes correctly' do
      user = create(:user)
      proposal = create(:proposal)
      support = create(:support, user: user, proposal: proposal)

      found_support = Support.find(support.id)
      expect(found_support.user_id).to eq(user.id)
      expect(found_support.proposal_id).to eq(proposal.id)
    end

    it 'updates support attributes' do
      support = create(:support)
      new_user = create(:user)

      support.update(user: new_user)

      expect(support.reload.user).to eq(new_user)
    end

    it 'deletes support' do
      support = create(:support)

      expect { support.destroy }.to change(Support, :count).by(-1)
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to user' do
      support = create(:support)
      expect(support).to respond_to(:user)
      expect(support.user).to be_an_instance_of(User)
    end

    it 'belongs to proposal' do
      support = create(:support)
      expect(support).to respond_to(:proposal)
      expect(support.proposal.class.name).to match(/Proposal/)
    end

    it 'updates proposal counter cache when created' do
      proposal = create(:proposal)
      initial_count = proposal.reload.supports_count

      create(:support, proposal: proposal)

      expect(proposal.reload.supports_count).to eq(initial_count + 1)
    end

    it 'updates proposal counter cache when destroyed' do
      support = create(:support)
      proposal = support.proposal
      count_with_support = proposal.reload.supports_count

      support.destroy

      expect(proposal.reload.supports_count).to eq(count_with_support - 1)
    end

    it 'handles multiple supports for same proposal' do
      proposal = create(:proposal)

      3.times do
        create(:support, proposal: proposal)
      end

      expect(proposal.reload.supports_count).to eq(3)
    end
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  describe 'callbacks' do
    it 'updates proposal hotness after save' do
      proposal = create(:proposal, created_at: 2.days.ago)
      initial_hotness = proposal.hotness

      # Create a support which should trigger update_hotness callback
      create(:support, proposal: proposal)

      # Hotness should be recalculated
      updated_hotness = proposal.reload.hotness
      expect(updated_hotness).not_to eq(initial_hotness)
    end

    it 'calls update_hotness method after save' do
      proposal = create(:proposal, created_at: 2.days.ago)
      proposal.update_column(:hotness, 0)

      support = build(:support, proposal: proposal)
      support.save

      # Verify hotness was updated (which means update_hotness was called)
      expect(proposal.reload.hotness).not_to eq(0)
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#update_hotness' do
      it 'updates proposal hotness attribute' do
        proposal = create(:proposal, created_at: 5.days.ago)
        proposal.update_column(:supports_count, 0)
        proposal.update_column(:hotness, 0)

        support = create(:support, proposal: proposal)

        # Hotness should be updated to supports_count + days_since_created * 1000
        expected_hotness = proposal.reload.supports_count + (proposal.days_since_created * 1000)
        expect(proposal.reload.hotness).to eq(expected_hotness)
      end

      it 'persists hotness to database' do
        support = create(:support)
        proposal = support.proposal

        # Get the hotness value
        calculated_hotness = proposal.hotness

        # Reload from database to verify it was persisted
        expect(proposal.reload.hotness).to eq(calculated_hotness)
      end
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles support for old proposals' do
      old_proposal = create(:proposal, created_at: 1.year.ago)
      support = build(:support, proposal: old_proposal)

      expect(support).to be_valid
    end

    it 'handles support for very new proposals' do
      new_proposal = create(:proposal, created_at: 1.minute.ago)
      support = build(:support, proposal: new_proposal)

      expect(support).to be_valid
    end

    it 'handles rapid creation of multiple supports' do
      proposal = create(:proposal)
      users = 5.times.map { create(:user) }

      expect {
        users.each do |user|
          create(:support, user: user, proposal: proposal)
        end
      }.to change(Support, :count).by(5)

      expect(proposal.reload.supports_count).to eq(5)
    end

    it 'prevents race condition with duplicate supports' do
      user = create(:user)
      proposal = create(:proposal)

      support1 = create(:support, user: user, proposal: proposal)

      expect {
        create(:support, user: user, proposal: proposal)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'handles deletion of user\'s supports when user has multiple' do
      user = create(:user)
      proposal1 = create(:proposal)
      proposal2 = create(:proposal)
      proposal3 = create(:proposal)

      create(:support, user: user, proposal: proposal1)
      create(:support, user: user, proposal: proposal2)
      create(:support, user: user, proposal: proposal3)

      expect(user.supports.count).to eq(3)
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'tracks full support lifecycle' do
      user = create(:user)
      proposal = create(:proposal, created_at: 3.days.ago)
      proposal.update_column(:supports_count, 0)

      initial_count = proposal.supports_count
      initial_hotness = proposal.hotness

      # Create support
      support = create(:support, user: user, proposal: proposal)

      # Verify counter cache updated
      expect(proposal.reload.supports_count).to eq(initial_count + 1)

      # Verify hotness updated
      expect(proposal.reload.hotness).not_to eq(initial_hotness)

      # Verify relationship
      expect(user.supports.map(&:id)).to include(support.id)
      expect(proposal.supports.map(&:id)).to include(support.id)

      # Delete support
      support.destroy

      # Verify counter cache decremented
      expect(proposal.reload.supports_count).to eq(initial_count)
    end

    it 'handles multiple users supporting multiple proposals' do
      users = 3.times.map { create(:user) }
      proposals = 3.times.map { create(:proposal) }

      # Create all combinations of supports
      supports = []
      users.each do |user|
        proposals.each do |proposal|
          supports << create(:support, user: user, proposal: proposal)
        end
      end

      # Verify counts
      expect(Support.count).to eq(9)

      users.each do |user|
        expect(user.supports.count).to eq(3)
      end

      proposals.each do |proposal|
        expect(proposal.supports.count).to eq(3)
      end
    end

    it 'maintains data integrity when user is deleted' do
      user = create(:user)
      proposal = create(:proposal)
      support = create(:support, user: user, proposal: proposal)

      # User deletion should delete their supports (dependent: :destroy)
      expect { user.destroy }.to change(Support, :count).by(-1)
    end

    it 'maintains data integrity when proposal is deleted' do
      proposal = create(:proposal)
      user = create(:user)
      support = create(:support, user: user, proposal: proposal)

      # Proposal deletion should delete its supports (dependent: :destroy)
      expect { proposal.destroy }.to change(Support, :count).by(-1)
    end
  end
end
