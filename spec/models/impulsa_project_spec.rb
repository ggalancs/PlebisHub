# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaProject, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid impulsa_project' do
      project = create(:impulsa_project)
      expect(project).to be_valid, "Factory should create valid project. Errors: #{project.errors.full_messages.join(', ')}"
      expect(project).to be_persisted
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to impulsa_edition_category' do
      project = create(:impulsa_project)
      expect(project).to respond_to(:impulsa_edition_category)
    end

    it 'belongs to user with soft delete' do
      project = create(:impulsa_project)
      expect(project).to respond_to(:user)

      user = project.user
      user.destroy
      project.reload
      expect(project.user).not_to be_nil # Should still load deleted user
    end

    it 'has one impulsa_edition through category' do
      project = create(:impulsa_project)
      expect(project).to respond_to(:impulsa_edition)
    end

    it 'has many impulsa_project_state_transitions' do
      project = create(:impulsa_project)
      expect(project).to respond_to(:impulsa_project_state_transitions)
    end

    it 'has many impulsa_project_topics' do
      project = create(:impulsa_project)
      expect(project).to respond_to(:impulsa_project_topics)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'requires name' do
      project = build(:impulsa_project, name: nil)
      expect(project).not_to be_valid
      expect(project.errors[:name]).to include('no puede estar en blanco')
    end

    it 'requires impulsa_edition_category_id' do
      project = build(:impulsa_project, impulsa_edition_category_id: nil)
      expect(project).not_to be_valid
      expect(project.errors[:impulsa_edition_category]).to include('must exist')
    end

    it 'requires status' do
      project = build(:impulsa_project, status: nil)
      expect(project).not_to be_valid
      expect(project.errors[:status]).to include('no puede estar en blanco')
    end

    it 'requires terms_of_service acceptance' do
      project = build(:impulsa_project, terms_of_service: false)
      expect(project).not_to be_valid
      expect(project.errors[:terms_of_service]).to include('debe ser aceptado')
    end

    it 'requires data_truthfulness acceptance' do
      project = build(:impulsa_project, data_truthfulness: false)
      expect(project).not_to be_valid
      expect(project.errors[:data_truthfulness]).to include('debe ser aceptado')
    end

    it 'requires content_rights acceptance' do
      project = build(:impulsa_project, content_rights: false)
      expect(project).not_to be_valid
      expect(project.errors[:content_rights]).to include('debe ser aceptado')
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.by_status' do
      it 'filters by status' do
        project_status_0 = create(:impulsa_project, status: 0)
        project_status_6 = create(:impulsa_project, status: 6)

        result = ImpulsaProject.by_status(0)
        expect(result).to include(project_status_0)
        expect(result).not_to include(project_status_6)
      end
    end

    describe '.first_phase' do
      it 'returns projects with status 0-3' do
        first_phase_project = create(:impulsa_project, status: 1)
        second_phase_project = create(:impulsa_project, status: 6)

        result = ImpulsaProject.first_phase
        expect(result).to include(first_phase_project)
        expect(result).not_to include(second_phase_project)
      end
    end

    describe '.second_phase' do
      it 'returns projects with status 4 or 6' do
        second_phase_project = create(:impulsa_project, status: 6)
        first_phase_project = create(:impulsa_project, status: 1)

        result = ImpulsaProject.second_phase
        expect(result).to include(second_phase_project)
        expect(result).not_to include(first_phase_project)
      end
    end

    describe '.votable' do
      it 'returns projects with status 6' do
        votable_project = create(:impulsa_project, status: 6)
        non_votable_project = create(:impulsa_project, status: 1)

        result = ImpulsaProject.votable
        expect(result).to include(votable_project)
        expect(result).not_to include(non_votable_project)
      end
    end

    describe '.public_visible' do
      it 'returns projects with status 9, 6, or 7' do
        visible_project = create(:impulsa_project, status: 6)
        hidden_project = create(:impulsa_project, status: 1)

        result = ImpulsaProject.public_visible
        expect(result).to include(visible_project)
        expect(result).not_to include(hidden_project)
      end
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#voting_dates' do
      it 'returns formatted date range' do
        edition = create(:impulsa_edition, :active)
        category = create(:impulsa_edition_category, impulsa_edition: edition)
        project = create(:impulsa_project, impulsa_edition_category: category)

        dates = project.voting_dates
        expect(dates).to be_a(String)
        expect(dates).to match(/al/) # Should contain " al " separator
      end
    end

    describe '#files_folder' do
      it 'returns path to project files' do
        project = create(:impulsa_project)
        folder = project.files_folder

        expect(folder).to be_a(String)
        expect(folder).to include('impulsa_projects')
        expect(folder).to include(project.id.to_s)
      end
    end
  end
end
