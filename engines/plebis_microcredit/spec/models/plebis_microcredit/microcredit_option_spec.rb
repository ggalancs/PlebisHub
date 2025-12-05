# frozen_string_literal: true

require 'rails_helper'

module PlebisMicrocredit
  RSpec.describe MicrocreditOption, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:microcredit).class_name('PlebisMicrocredit::Microcredit') }
      it { is_expected.to belong_to(:parent).class_name('PlebisMicrocredit::MicrocreditOption').optional }
      it { is_expected.to have_many(:children).class_name('PlebisMicrocredit::MicrocreditOption').dependent(:destroy) }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:name) }
    end

    describe 'scopes' do
      describe '.root_parents' do
        it 'returns options without parent' do
          root = create(:microcredit_option, parent: nil)
          child = create(:microcredit_option, parent: root)

          expect(MicrocreditOption.root_parents).to include(root)
          expect(MicrocreditOption.root_parents).not_to include(child)
        end
      end
    end

    describe 'table name' do
      it 'uses microcredit_options table' do
        expect(MicrocreditOption.table_name).to eq('microcredit_options')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        option = build(:microcredit_option)
        expect(option).to be_valid
      end

      it 'creates an option with required attributes' do
        option = create(:microcredit_option)
        expect(option).to be_persisted
        expect(option.name).to be_present
      end
    end
  end
end
