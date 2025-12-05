# frozen_string_literal: true

require 'rails_helper'

module PlebisProposals
  RSpec.describe Proposal, type: :model do
    let(:user) { create(:user) }
    
    describe 'associations' do
      it { is_expected.to have_many(:supports).class_name('PlebisProposals::Support').dependent(:destroy) }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:title) }
      it { is_expected.to validate_presence_of(:description) }
      it { is_expected.to validate_numericality_of(:votes).is_greater_than_or_equal_to(0).allow_nil }
      it { is_expected.to validate_numericality_of(:supports_count).is_greater_than_or_equal_to(0).allow_nil }
      it { is_expected.to validate_numericality_of(:hotness).is_greater_than_or_equal_to(0).allow_nil }
    end

    describe 'scopes' do
      describe '.recent' do
        it 'orders by created_at descending' do
          old = create(:proposal, created_at: 2.days.ago)
          new = create(:proposal, created_at: 1.hour.ago)
          expect(Proposal.recent.first).to eq(new)
        end
      end

      describe '.popular' do
        it 'orders by supports_count descending' do
          less_popular = create(:proposal, supports_count: 5)
          more_popular = create(:proposal, supports_count: 10)
          expect(Proposal.popular.first).to eq(more_popular)
        end
      end

      describe '.active' do
        it 'returns proposals created within 3 months' do
          active = create(:proposal, created_at: 2.months.ago)
          old = create(:proposal, created_at: 4.months.ago)
          expect(Proposal.active).to include(active)
          expect(Proposal.active).not_to include(old)
        end
      end

      describe '.finished' do
        it 'returns proposals older than 3 months' do
          active = create(:proposal, created_at: 2.months.ago)
          finished = create(:proposal, created_at: 4.months.ago)
          expect(Proposal.finished).to include(finished)
          expect(Proposal.finished).not_to include(active)
        end
      end
    end

    describe '#finished?' do
      it 'returns true if created more than 3 months ago' do
        proposal = build(:proposal, created_at: 4.months.ago)
        expect(proposal.finished?).to be true
      end

      it 'returns false if created less than 3 months ago' do
        proposal = build(:proposal, created_at: 2.months.ago)
        expect(proposal.finished?).to be false
      end
    end

    describe '#finishes_at' do
      it 'returns created_at plus 3 months' do
        proposal = create(:proposal, created_at: 1.month.ago)
        expect(proposal.finishes_at).to eq(proposal.created_at + 3.months)
      end
    end

    describe 'table name' do
      it 'uses proposals table' do
        expect(Proposal.table_name).to eq('proposals')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        proposal = build(:proposal)
        expect(proposal).to be_valid
      end

      it 'creates a proposal with required attributes' do
        proposal = create(:proposal)
        expect(proposal).to be_persisted
        expect(proposal.title).to be_present
        expect(proposal.description).to be_present
      end
    end
  end
end
