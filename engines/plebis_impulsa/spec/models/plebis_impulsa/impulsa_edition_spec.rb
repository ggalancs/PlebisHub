# frozen_string_literal: true

require 'rails_helper'

module PlebisImpulsa
  RSpec.describe ImpulsaEdition, type: :model do
    describe 'associations' do
      it { is_expected.to have_many(:impulsa_edition_categories).class_name('PlebisImpulsa::ImpulsaEditionCategory') }
      it { is_expected.to have_many(:impulsa_projects).through(:impulsa_edition_categories) }
      it { is_expected.to have_many(:impulsa_edition_topics).class_name('PlebisImpulsa::ImpulsaEditionTopic') }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:email) }
    end

    describe 'scopes' do
      describe '.active' do
        it 'returns editions that are currently active' do
          active = create(:impulsa_edition, :active)
          upcoming = create(:impulsa_edition, :upcoming)

          expect(ImpulsaEdition.active).to include(active)
          expect(ImpulsaEdition.active).not_to include(upcoming)
        end
      end

      describe '.upcoming' do
        it 'returns editions that start in the future' do
          active = create(:impulsa_edition, :active)
          upcoming = create(:impulsa_edition, :upcoming)

          expect(ImpulsaEdition.upcoming).to include(upcoming)
          expect(ImpulsaEdition.upcoming).not_to include(active)
        end
      end

      describe '.previous' do
        it 'returns editions that have ended' do
          active = create(:impulsa_edition, :active)
          previous = create(:impulsa_edition, :previous)

          expect(ImpulsaEdition.previous).to include(previous)
          expect(ImpulsaEdition.previous).not_to include(active)
        end
      end
    end

    describe 'table name' do
      it 'uses impulsa_editions table' do
        expect(ImpulsaEdition.table_name).to eq('impulsa_editions')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        edition = build(:impulsa_edition)
        expect(edition).to be_valid
      end

      it 'creates an edition with required attributes' do
        edition = create(:impulsa_edition)
        expect(edition).to be_persisted
        expect(edition.name).to be_present
        expect(edition.email).to be_present
      end
    end
  end
end
