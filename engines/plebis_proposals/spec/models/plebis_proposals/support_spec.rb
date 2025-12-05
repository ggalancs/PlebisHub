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
  end
end
