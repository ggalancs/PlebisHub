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

  # ====================
  # ATTACHMENT VALIDATION TESTS
  # ====================

  describe 'attachment content type validations' do
    let(:edition) { build(:impulsa_edition) }

    describe 'spreadsheet attachments' do
      it 'accepts valid spreadsheet content types for schedule_model' do
        edition.schedule_model.attach(io: StringIO.new('test'), filename: 'test.xlsx',
                                      content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        expect(edition).to be_valid
      end

      it 'accepts ODS for schedule_model' do
        edition.schedule_model.attach(io: StringIO.new('test'), filename: 'test.ods',
                                      content_type: 'application/vnd.oasis.opendocument.spreadsheet')
        expect(edition).to be_valid
      end

      it 'rejects invalid content type for schedule_model' do
        edition.schedule_model.attach(io: StringIO.new('test'), filename: 'test.pdf',
                                      content_type: 'application/pdf')
        expect(edition).not_to be_valid
        expect(edition.errors[:schedule_model]).to be_present
      end

      it 'accepts valid spreadsheet for requested_budget_model' do
        edition.requested_budget_model.attach(io: StringIO.new('test'), filename: 'test.xlsx',
                                              content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        expect(edition).to be_valid
      end

      it 'accepts valid spreadsheet for monitoring_evaluation_model' do
        edition.monitoring_evaluation_model.attach(io: StringIO.new('test'), filename: 'test.xlsx',
                                                   content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        expect(edition).to be_valid
      end
    end

    describe 'document attachments' do
      it 'accepts valid document content types for activities_resources_model' do
        edition.activities_resources_model.attach(io: StringIO.new('test'), filename: 'test.docx',
                                                  content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')
        expect(edition).to be_valid
      end

      it 'accepts ODT for activities_resources_model' do
        edition.activities_resources_model.attach(io: StringIO.new('test'), filename: 'test.odt',
                                                  content_type: 'application/vnd.oasis.opendocument.text')
        expect(edition).to be_valid
      end

      it 'rejects invalid content type for activities_resources_model' do
        edition.activities_resources_model.attach(io: StringIO.new('test'), filename: 'test.xlsx',
                                                  content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        expect(edition).not_to be_valid
        expect(edition.errors[:activities_resources_model]).to be_present
      end
    end
  end

  # ====================
  # LEGAL LINK TESTS
  # ====================

  describe '#legal_link' do
    it 'returns legal link for current locale' do
      edition = create(:impulsa_edition)
      edition.legal = { "legal_#{I18n.locale}" => 'http://example.com/legal' }

      expect(edition.legal_link).to eq('http://example.com/legal')
    end

    it 'falls back to default locale when current locale not available' do
      edition = create(:impulsa_edition)
      edition.legal = { "legal_#{I18n.default_locale}" => 'http://example.com/default' }

      I18n.with_locale(:fr) do
        expect(edition.legal_link).to eq('http://example.com/default')
      end
    end
  end

  # ====================
  # CURRENT PHASE EDGE CASES
  # ====================

  describe '#current_phase edge cases' do
    it 'returns review_projects during review period' do
      edition = create(:impulsa_edition,
                       start_at: 2.days.ago,
                       new_projects_until: 1.day.ago,
                       review_projects_until: 1.day.from_now,
                       validation_projects_until: 2.days.from_now,
                       votings_start_at: 3.days.from_now,
                       ends_at: 4.days.from_now)
      expect(edition.current_phase).to eq(ImpulsaEdition::EDITION_PHASES[:review_projects])
    end

    it 'returns validation_projects during validation period' do
      edition = create(:impulsa_edition,
                       start_at: 3.days.ago,
                       new_projects_until: 2.days.ago,
                       review_projects_until: 1.day.ago,
                       validation_projects_until: 1.day.from_now,
                       votings_start_at: 2.days.from_now,
                       ends_at: 3.days.from_now)
      expect(edition.current_phase).to eq(ImpulsaEdition::EDITION_PHASES[:validation_projects])
    end

    it 'returns prevotings during prevoting period' do
      edition = create(:impulsa_edition,
                       start_at: 4.days.ago,
                       new_projects_until: 3.days.ago,
                       review_projects_until: 2.days.ago,
                       validation_projects_until: 1.day.ago,
                       votings_start_at: 1.day.from_now,
                       ends_at: 2.days.from_now)
      expect(edition.current_phase).to eq(ImpulsaEdition::EDITION_PHASES[:prevotings])
    end

    it 'returns publish_results before results are published' do
      edition = create(:impulsa_edition,
                       start_at: 3.months.ago,
                       new_projects_until: 2.months.ago,
                       review_projects_until: 2.months.ago,
                       validation_projects_until: 2.months.ago,
                       votings_start_at: 2.months.ago,
                       ends_at: 1.month.ago,
                       publish_results_at: 1.day.from_now)
      expect(edition.current_phase).to eq(ImpulsaEdition::EDITION_PHASES[:publish_results])
    end
  end

  # ====================
  # PUBLISH RESULTS TESTS
  # ====================

  describe '#publish_results?' do
    it 'returns true before publish_results phase' do
      edition = create(:impulsa_edition, :active)
      expect(edition.publish_results?).to be true
    end

    it 'returns false at or after publish_results phase' do
      edition = create(:impulsa_edition,
                       start_at: 3.months.ago,
                       new_projects_until: 2.months.ago,
                       review_projects_until: 2.months.ago,
                       validation_projects_until: 2.months.ago,
                       votings_start_at: 2.months.ago,
                       ends_at: 1.month.ago,
                       publish_results_at: 1.day.from_now)
      expect(edition.publish_results?).to be false
    end
  end

  # ====================
  # STORE ACCESSOR TESTS
  # ====================

  describe 'legal store' do
    it 'stores legal links for each locale' do
      edition = create(:impulsa_edition)

      I18n.available_locales.each do |locale|
        edition.send("legal_#{locale}=", "http://example.com/legal-#{locale}")
      end

      edition.save!
      edition.reload

      I18n.available_locales.each do |locale|
        expect(edition.send("legal_#{locale}")).to eq("http://example.com/legal-#{locale}")
      end
    end

    it 'validates URL format for legal links' do
      edition = build(:impulsa_edition)
      edition.legal_es = 'not a url'

      expect(edition).not_to be_valid
      expect(edition.errors[:legal_es]).to be_present
    end

    it 'allows blank legal links' do
      edition = build(:impulsa_edition)
      edition.legal_es = ''

      expect(edition).to be_valid
    end
  end

  # ====================
  # NO_PHASE SCOPE TEST
  # ====================

  describe '.no_phase scope' do
    it 'returns projects in status 5, 7, or 10' do
      project_5 = create(:impulsa_project, status: 5)
      project_7 = create(:impulsa_project, status: 7)
      project_10 = create(:impulsa_project, status: 10)
      project_other = create(:impulsa_project, status: 1)

      result = ImpulsaProject.no_phase

      expect(result).to include(project_5)
      expect(result).to include(project_7)
      expect(result).to include(project_10)
      expect(result).not_to include(project_other)
    end
  end
end
