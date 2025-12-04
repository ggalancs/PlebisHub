# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser::Proposer, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it 'responds to supports' do
      expect(user).to respond_to(:supports)
    end

    it 'returns an ActiveRecord relation for supports' do
      expect(user.supports).to be_an(ActiveRecord::Relation)
    end
  end

  describe '#proposals' do
    let!(:user_proposal) { create(:proposal, user: user) }
    let!(:other_proposal) { create(:proposal) }

    it 'returns user proposals' do
      expect(user.proposals).to include(user_proposal)
    end

    it 'does not include other user proposals' do
      expect(user.proposals).not_to include(other_proposal)
    end

    it 'returns ActiveRecord relation' do
      expect(user.proposals).to be_an(ActiveRecord::Relation)
    end

    it 'returns empty relation when user has no proposals' do
      user.proposals.delete_all
      expect(user.proposals).to be_empty
    end
  end

  describe '#has_supported?' do
    let(:proposal) { create(:proposal) }

    context 'when user has supported the proposal' do
      before do
        create(:support, user: user, proposal: proposal)
      end

      it 'returns true' do
        expect(user.has_supported?(proposal)).to be true
      end
    end

    context 'when user has not supported the proposal' do
      it 'returns false' do
        expect(user.has_supported?(proposal)).to be false
      end
    end

    context 'when user has supported other proposals but not this one' do
      let(:other_proposal) { create(:proposal) }

      before do
        create(:support, user: user, proposal: other_proposal)
      end

      it 'returns false for unsupported proposal' do
        expect(user.has_supported?(proposal)).to be false
      end

      it 'returns true for supported proposal' do
        expect(user.has_supported?(other_proposal)).to be true
      end
    end
  end
end
