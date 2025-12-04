# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaEdition, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid impulsa_edition' do
      edition = build(:impulsa_edition)
      expect(edition).to be_valid, "Factory should create valid edition. Errors: #{edition.errors.full_messages.join(', ')}"
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'has many impulsa_edition_categories' do
      edition = create(:impulsa_edition)
      expect(edition).to respond_to(:impulsa_edition_categories)
    end

    it 'has many impulsa_projects through categories' do
      edition = create(:impulsa_edition)
      expect(edition).to respond_to(:impulsa_projects)
    end

    it 'has many impulsa_edition_topics' do
      edition = create(:impulsa_edition)
      expect(edition).to respond_to(:impulsa_edition_topics)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'requires name' do
      edition = build(:impulsa_edition, name: nil)
      expect(edition).not_to be_valid
      expect(edition.errors[:name]).to include('no puede estar en blanco')
    end

    it 'requires email' do
      edition = build(:impulsa_edition, email: nil)
      expect(edition).not_to be_valid
      expect(edition.errors[:email]).to include('no puede estar en blanco')
    end

    it 'validates email format' do
      edition = build(:impulsa_edition, email: 'invalid')
      expect(edition).not_to be_valid
      expect(edition.errors[:email]).to include('es incorrecto')
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.active' do
      it 'returns active editions' do
        active = create(:impulsa_edition, :active)
        previous = create(:impulsa_edition, :previous)

        result = ImpulsaEdition.active
        expect(result).to include(active)
        expect(result).not_to include(previous)
      end
    end

    describe '.upcoming' do
      it 'returns upcoming editions' do
        upcoming = create(:impulsa_edition, :upcoming)
        previous = create(:impulsa_edition, :previous)

        result = ImpulsaEdition.upcoming
        expect(result).to include(upcoming)
        expect(result).not_to include(previous)
      end
    end

    describe '.previous' do
      it 'returns previous editions' do
        previous = create(:impulsa_edition, :previous)
        upcoming = create(:impulsa_edition, :upcoming)

        result = ImpulsaEdition.previous
        expect(result).to include(previous)
        expect(result).not_to include(upcoming)
      end
    end
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  describe 'class methods' do
    describe '.current' do
      it 'returns first active or first previous' do
        previous = create(:impulsa_edition, :previous)
        expect(ImpulsaEdition.current).to eq(previous)

        active = create(:impulsa_edition, :active)
        expect(ImpulsaEdition.current).to eq(active)
      end
    end
  end

  # ====================
  # PHASE METHOD TESTS
  # ====================

  describe 'phase methods' do
    describe '#current_phase' do
      it 'returns not_started before start_at' do
        edition = build(:impulsa_edition, start_at: 1.day.from_now)
        expect(edition.current_phase).to eq(ImpulsaEdition::EDITION_PHASES[:not_started])
      end

      it 'returns new_projects during new projects period' do
        edition = create(:impulsa_edition,
                         start_at: 1.day.ago,
                         new_projects_until: 1.day.from_now,
                         review_projects_until: 2.days.from_now,
                         validation_projects_until: 3.days.from_now,
                         votings_start_at: 4.days.from_now,
                         ends_at: 5.days.from_now)
        expect(edition.current_phase).to eq(ImpulsaEdition::EDITION_PHASES[:new_projects])
      end

      it 'returns votings during voting period' do
        edition = create(:impulsa_edition, :active)
        expect(edition.current_phase).to eq(ImpulsaEdition::EDITION_PHASES[:votings])
      end

      it 'returns ended after publish_results_at' do
        edition = create(:impulsa_edition,
                         start_at: 3.months.ago,
                         new_projects_until: 2.months.ago,
                         review_projects_until: 2.months.ago,
                         validation_projects_until: 2.months.ago,
                         votings_start_at: 2.months.ago,
                         ends_at: 1.month.ago,
                         publish_results_at: 1.day.ago)
        expect(edition.current_phase).to eq(ImpulsaEdition::EDITION_PHASES[:ended])
      end
    end
  end

  # ====================
  # PERMISSION METHOD TESTS
  # ====================

  describe 'permission methods' do
    describe '#allow_creation?' do
      it 'returns true during new_projects phase' do
        edition = create(:impulsa_edition,
                         start_at: 1.day.ago,
                         new_projects_until: 1.day.from_now,
                         review_projects_until: 2.days.from_now,
                         validation_projects_until: 3.days.from_now,
                         votings_start_at: 4.days.from_now,
                         ends_at: 5.days.from_now)
        expect(edition.allow_creation?).to be true
      end

      it 'returns false outside new_projects phase' do
        edition = create(:impulsa_edition, :active)
        expect(edition.allow_creation?).not_to be true
      end
    end

    describe '#allow_edition?' do
      it 'returns true before review_projects' do
        edition = create(:impulsa_edition,
                         start_at: 1.day.ago,
                         new_projects_until: 1.day.from_now,
                         review_projects_until: 2.days.from_now,
                         validation_projects_until: 3.days.from_now,
                         votings_start_at: 4.days.from_now,
                         ends_at: 5.days.from_now)
        expect(edition.allow_edition?).to be true
      end
    end

    describe '#allow_fixes?' do
      it 'returns true before validation_projects' do
        edition = create(:impulsa_edition,
                         start_at: 3.days.ago,
                         new_projects_until: 2.days.ago,
                         review_projects_until: 1.hour.from_now,
                         validation_projects_until: 1.day.from_now,
                         votings_start_at: 2.days.from_now,
                         ends_at: 3.days.from_now)
        expect(edition.allow_fixes?).to be true
      end
    end

    describe '#allow_validation?' do
      it 'returns true during validation_projects phase' do
        edition = create(:impulsa_edition,
                         start_at: 3.days.ago,
                         new_projects_until: 2.days.ago,
                         review_projects_until: 1.day.ago,
                         validation_projects_until: 1.day.from_now,
                         votings_start_at: 2.days.from_now,
                         ends_at: 3.days.from_now)
        expect(edition.allow_validation?).to be true
      end
    end

    describe '#show_projects?' do
      it 'returns true after validation_projects' do
        edition = create(:impulsa_edition, :active)
        expect(edition.show_projects?).to be true
      end
    end

    describe '#active?' do
      it 'returns false when ended' do
        edition = create(:impulsa_edition, :previous)
        expect(edition.active?).not_to be true
      end

      it 'returns true when not ended' do
        edition = create(:impulsa_edition, :active)
        expect(edition.active?).to be true
      end
    end
  end

  # ====================
  # PAPERCLIP ATTACHMENT TESTS
  # ====================

  describe 'attachments' do
    it 'has schedule_model attachment' do
      edition = create(:impulsa_edition)
      expect(edition).to respond_to(:schedule_model)
    end

    it 'has activities_resources_model attachment' do
      edition = create(:impulsa_edition)
      expect(edition).to respond_to(:activities_resources_model)
    end

    it 'has requested_budget_model attachment' do
      edition = create(:impulsa_edition)
      expect(edition).to respond_to(:requested_budget_model)
    end

    it 'has monitoring_evaluation_model attachment' do
      edition = create(:impulsa_edition)
      expect(edition).to respond_to(:monitoring_evaluation_model)
    end
  end
end
