# frozen_string_literal: true

require 'rails_helper'

module PlebisImpulsa
  RSpec.describe ImpulsaEditionCategory, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:impulsa_edition).class_name('PlebisImpulsa::ImpulsaEdition') }
      it { is_expected.to have_many(:impulsa_projects).class_name('PlebisImpulsa::ImpulsaProject') }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:category_type) }
      it { is_expected.to validate_presence_of(:winners) }
      it { is_expected.to validate_presence_of(:prize) }
    end

    describe 'scopes' do
      describe '.state' do
        it 'returns state categories' do
          state = create(:impulsa_edition_category, :state)
          territorial = create(:impulsa_edition_category, :territorial)

          expect(ImpulsaEditionCategory.state).to include(state)
          expect(ImpulsaEditionCategory.state).not_to include(territorial)
        end
      end

      describe '.territorial' do
        it 'returns territorial categories' do
          state = create(:impulsa_edition_category, :state)
          territorial = create(:impulsa_edition_category, :territorial)

          expect(ImpulsaEditionCategory.territorial).to include(territorial)
          expect(ImpulsaEditionCategory.territorial).not_to include(state)
        end
      end
    end

    describe '#has_territory?' do
      it 'returns true for territorial category' do
        category = build(:impulsa_edition_category, :territorial)
        expect(category.has_territory?).to be true
      end

      it 'returns false for state category' do
        category = build(:impulsa_edition_category, :state)
        expect(category.has_territory?).to be false
      end
    end

    describe 'table name' do
      it 'uses impulsa_edition_categories table' do
        expect(ImpulsaEditionCategory.table_name).to eq('impulsa_edition_categories')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        category = build(:impulsa_edition_category)
        expect(category).to be_valid
      end

      it 'creates a category with required attributes' do
        category = create(:impulsa_edition_category)
        expect(category).to be_persisted
        expect(category.name).to be_present
      end
    end
  end
end
