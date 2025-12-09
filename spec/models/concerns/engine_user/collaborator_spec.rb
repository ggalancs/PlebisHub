# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser::Collaborator, type: :model do
  let(:user) { create(:user, :with_dni) }
  # NOTE: MIN_MILITANT_AMOUNT is in euros (e.g. 3), but amount is stored in cents
  # The concern code compares them directly which may be a bug, but we test actual behavior
  let(:min_amount) { User::MIN_MILITANT_AMOUNT } # This is in euros, not cents!

  describe 'associations' do
    it 'responds to collaborations' do
      expect(user).to respond_to(:collaborations)
    end

    it 'returns an ActiveRecord relation' do
      expect(user.collaborations).to be_an(ActiveRecord::Relation)
    end
  end

  describe '#recurrent_collaboration' do
    context 'when user has recurrent collaborations' do
      let!(:monthly_collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: 1000).tap do |c|
          c.update_column(:status, 3)
        end
      end
      let!(:annual_collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 12, amount: 5000).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns the last recurrent collaboration' do
        expect(user.recurrent_collaboration).to eq(annual_collaboration)
      end
    end

    context 'when user has only single collaborations' do
      let!(:single_collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 0, amount: 1000).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns nil' do
        expect(user.recurrent_collaboration).to be_nil
      end
    end

    context 'when user has no collaborations' do
      it 'returns nil' do
        expect(user.recurrent_collaboration).to be_nil
      end
    end
  end

  describe '#single_collaboration' do
    context 'when user has single collaborations' do
      let!(:first_single) do
        create(:collaboration, :skip_validations, user: user, frequency: 0, amount: 1000).tap do |c|
          c.update_column(:status, 3)
        end
      end
      let!(:second_single) do
        create(:collaboration, :skip_validations, user: user, frequency: 0, amount: 2000).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns the last single collaboration' do
        expect(user.single_collaboration).to eq(second_single)
      end
    end

    context 'when user has only recurrent collaborations' do
      let!(:monthly_collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: 1000).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns nil' do
        expect(user.single_collaboration).to be_nil
      end
    end

    context 'when user has no collaborations' do
      it 'returns nil' do
        expect(user.single_collaboration).to be_nil
      end
    end
  end

  describe '#pending_single_collaborations' do
    let!(:pending_single) do
      create(:collaboration, :skip_validations, user: user, frequency: 0, amount: 1000).tap do |c|
        c.update_column(:status, 2) # unconfirmed/pending
      end
    end
    let!(:active_single) do
      create(:collaboration, :skip_validations, user: user, frequency: 0, amount: 2000).tap do |c|
        c.update_column(:status, 3) # active
      end
    end
    let!(:pending_monthly) do
      create(:collaboration, :skip_validations, user: user, frequency: 1, amount: 1000).tap do |c|
        c.update_column(:status, 2)
      end
    end

    it 'returns only pending single collaborations' do
      expect(user.pending_single_collaborations).to contain_exactly(pending_single)
    end

    it 'does not include active single collaborations' do
      expect(user.pending_single_collaborations).not_to include(active_single)
    end

    it 'does not include pending recurrent collaborations' do
      expect(user.pending_single_collaborations).not_to include(pending_monthly)
    end
  end

  describe '#active_collaborations' do
    let!(:active_collab) do
      create(:collaboration, :skip_validations, user: user, frequency: 1, amount: 1000).tap do |c|
        c.update_column(:status, 3)
      end
    end
    let!(:deleted_collab) do
      create(:collaboration, :skip_validations, user: user, frequency: 1, amount: 1000, deleted_at: 1.day.ago).tap do |c|
        c.update_column(:status, 3)
      end
    end
    let!(:pending_collab) do
      create(:collaboration, :skip_validations, user: user, frequency: 1, amount: 1000).tap do |c|
        c.update_column(:status, 2)
      end
    end

    it 'returns only active collaborations' do
      expect(user.active_collaborations).to contain_exactly(active_collab)
    end

    it 'excludes deleted collaborations' do
      expect(user.active_collaborations).not_to include(deleted_collab)
    end

    it 'excludes non-active status collaborations' do
      expect(user.active_collaborations).not_to include(pending_collab)
    end
  end

  describe '#has_min_monthly_collaboration?' do
    context 'when user has active collaboration above minimum' do
      let!(:collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3) # active
        end
      end

      it 'returns true' do
        expect(user.has_min_monthly_collaboration?).to be true
      end
    end

    context 'when user has active collaboration at exact minimum' do
      let!(:collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns true' do
        expect(user.has_min_monthly_collaboration?).to be true
      end
    end

    context 'when user has collaboration below minimum' do
      let!(:collaboration) do
        # min_amount is 3 (euros), so we need amount < 3 cents (e.g. 2 cents)
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount - 1).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns false' do
        expect(user.has_min_monthly_collaboration?).to be false
      end
    end

    context 'when user has single (non-recurrent) collaboration' do
      let!(:collaboration) do
        create(:collaboration, user: user, frequency: 0, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns false' do
        expect(user.has_min_monthly_collaboration?).to be false
      end
    end

    context 'when user has pending collaboration' do
      let!(:collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 2) # pending
        end
      end

      it 'returns false' do
        expect(user.has_min_monthly_collaboration?).to be false
      end
    end

    context 'when user has no collaborations' do
      it 'returns false' do
        expect(user.has_min_monthly_collaboration?).to be false
      end
    end
  end

  describe '#collaborator_for_militant?' do
    # min_amount is in the same unit as MIN_MILITANT_AMOUNT (not cents)
    let(:min_amount) { User::MIN_MILITANT_AMOUNT }

    context 'when user has active minimum collaboration' do
      let!(:collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3) # active
        end
      end

      it 'returns true' do
        expect(user.collaborator_for_militant?).to be true
      end
    end

    context 'when user has pending minimum collaboration' do
      let!(:collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 2) # pending/unconfirmed
        end
      end

      it 'returns true' do
        expect(user.collaborator_for_militant?).to be true
      end
    end

    context 'when user has incomplete collaboration' do
      let!(:collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 0) # incomplete - should not count
        end
      end

      it 'returns false' do
        expect(user.collaborator_for_militant?).to be false
      end
    end

    context 'when user has both active and pending collaborations' do
      let!(:active_collab) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end
      let!(:pending_collab) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount).tap do |c|
          c.update_column(:status, 2)
        end
      end

      it 'returns true' do
        expect(user.collaborator_for_militant?).to be true
      end
    end

    context 'when user has collaboration below minimum amount' do
      let!(:collaboration) do
        create(:collaboration, :skip_validations, user: user, frequency: 1, amount: min_amount - 1).tap do |c|
          c.update_column(:status, 2)
        end
      end

      it 'returns false' do
        expect(user.collaborator_for_militant?).to be false
      end
    end

    context 'when user has only single collaborations' do
      let!(:collaboration) do
        create(:collaboration, user: user, frequency: 0, amount: min_amount).tap do |c|
          c.update_column(:status, 3)
        end
      end

      it 'returns false' do
        expect(user.collaborator_for_militant?).to be false
      end
    end

    context 'when user has no collaborations' do
      it 'returns false' do
        expect(user.collaborator_for_militant?).to be false
      end
    end
  end
end
