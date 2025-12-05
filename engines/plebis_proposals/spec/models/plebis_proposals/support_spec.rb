# frozen_string_literal: true

require 'rails_helper'

module PlebisProposals
  RSpec.describe Support, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:user) }
      it { is_expected.to belong_to(:proposal).class_name('PlebisProposals::Proposal').counter_cache }
    end

    describe 'validations' do
      subject { create(:support) }
      it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:proposal_id) }
    end

    describe 'table name' do
      it 'uses supports table' do
        expect(Support.table_name).to eq('supports')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        support = build(:support)
        expect(support).to be_valid
      end

      it 'creates a support with required attributes' do
        support = create(:support)
        expect(support).to be_persisted
      end
    end

    describe 'callbacks' do
      describe 'after_save' do
        it 'calls update_hotness after save' do
          support = build(:support)
          expect(support).to receive(:update_hotness)
          support.save
        end
      end
    end

    describe '#update_hotness' do
      it 'updates the proposal hotness' do
        proposal = create(:proposal)
        support = create(:support, proposal: proposal)

        expect(proposal).to receive(:update_column).with(:hotness, proposal.hotness)
        support.send(:update_hotness)
      end

      it 'uses update_column instead of deprecated update_attribute' do
        support = create(:support)

        expect(support.proposal).to receive(:update_column).with(:hotness, anything)
        support.send(:update_hotness)
      end
    end
  end
end
