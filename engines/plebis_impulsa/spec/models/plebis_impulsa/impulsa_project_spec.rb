# frozen_string_literal: true

require 'rails_helper'

module PlebisImpulsa
  RSpec.describe ImpulsaProject, type: :model do
    describe 'associations' do
      it 'belongs to impulsa_edition_category' do
        expect(ImpulsaProject.reflect_on_association(:impulsa_edition_category).macro).to eq(:belongs_to)
      end

      it 'belongs to user' do
        expect(ImpulsaProject.reflect_on_association(:user).macro).to eq(:belongs_to)
      end

      it 'has one impulsa_edition through impulsa_edition_category' do
        association = ImpulsaProject.reflect_on_association(:impulsa_edition)
        expect(association.macro).to eq(:has_one)
        expect(association.options[:through]).to eq(:impulsa_edition_category)
      end

      it 'has many impulsa_project_state_transitions' do
        expect(ImpulsaProject.reflect_on_association(:impulsa_project_state_transitions).macro).to eq(:has_many)
      end

      it 'has many impulsa_project_topics' do
        expect(ImpulsaProject.reflect_on_association(:impulsa_project_topics).macro).to eq(:has_many)
      end
    end

    describe 'validations' do
      it 'validates presence of name' do
        project = build(:impulsa_project, name: nil)
        expect(project).not_to be_valid
        expect(project.errors[:name]).to be_present
      end

      it 'validates presence of status' do
        project = build(:impulsa_project, status: nil)
        expect(project).not_to be_valid
        expect(project.errors[:status]).to be_present
      end
    end

    describe 'scopes' do
      describe '.votable' do
        it 'returns projects with status 6' do
          votable = create(:impulsa_project, status: 6)
          not_votable = create(:impulsa_project, status: 0)

          expect(ImpulsaProject.votable).to include(votable)
          expect(ImpulsaProject.votable).not_to include(not_votable)
        end
      end

      describe '.by_status' do
        it 'filters projects by status' do
          project1 = create(:impulsa_project, status: 0)
          project2 = create(:impulsa_project, status: 6)

          expect(ImpulsaProject.by_status(0)).to include(project1)
          expect(ImpulsaProject.by_status(0)).not_to include(project2)
        end
      end

      describe '.first_phase' do
        it 'returns projects in first phase statuses' do
          project = create(:impulsa_project, status: 1)
          expect(ImpulsaProject.first_phase).to include(project)
        end
      end

      describe '.second_phase' do
        it 'returns projects in second phase statuses' do
          project = create(:impulsa_project, status: 6)
          expect(ImpulsaProject.second_phase).to include(project)
        end
      end

      describe '.no_phase' do
        it 'returns projects with no phase status' do
          project = create(:impulsa_project, status: 5)
          expect(ImpulsaProject.no_phase).to include(project)
        end
      end

      describe '.public_visible' do
        it 'returns publicly visible projects' do
          project = create(:impulsa_project, status: 6)
          expect(ImpulsaProject.public_visible).to include(project)
        end
      end
    end

    describe 'table name' do
      it 'uses impulsa_projects table' do
        expect(ImpulsaProject.table_name).to eq('impulsa_projects')
      end
    end

    describe '#method_missing' do
      let(:project) { create(:impulsa_project) }

      it 'delegates to wizard_method_missing' do
        allow(project).to receive(:wizard_method_missing).and_return(:super)
        allow(project).to receive(:evaluation_method_missing).and_return(:super)
        expect { project.some_undefined_method }.to raise_error(NoMethodError)
      end
    end

    describe '#voting_dates' do
      let(:edition) { create(:impulsa_edition, votings_start_at: 10.days.from_now, ends_at: 20.days.from_now) }
      let(:category) { create(:impulsa_edition_category, impulsa_edition: edition) }
      let(:project) { create(:impulsa_project, impulsa_edition_category: category) }

      it 'returns formatted voting dates' do
        result = project.voting_dates
        expect(result).to be_a(String)
        expect(result).to include(' al ')
      end
    end

    describe '#files_folder' do
      let(:project) { create(:impulsa_project) }

      it 'returns the files folder path' do
        result = project.files_folder
        expect(result).to include('non-public/system/impulsa_projects/')
        expect(result).to include(project.id.to_s)
      end

      it 'includes Rails root path' do
        result = project.files_folder
        expect(result).to start_with(Rails.application.root.to_s)
      end
    end

    describe 'validations' do
      let(:user) { create(:user) }
      let(:category) { create(:impulsa_edition_category) }

      it 'validates uniqueness of user scoped to category for non-authors' do
        create(:impulsa_project, user: user, impulsa_edition_category: category)
        duplicate = build(:impulsa_project, user: user, impulsa_edition_category: category)
        expect(duplicate).not_to be_valid
      end

      it 'validates acceptance of terms_of_service' do
        project = build(:impulsa_project, terms_of_service: false)
        expect(project).not_to be_valid
      end

      it 'validates acceptance of data_truthfulness' do
        project = build(:impulsa_project, data_truthfulness: false)
        expect(project).not_to be_valid
      end

      it 'validates acceptance of content_rights' do
        project = build(:impulsa_project, content_rights: false)
        expect(project).not_to be_valid
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        project = build(:impulsa_project)
        expect(project).to be_valid
      end

      it 'creates a project with required attributes' do
        project = create(:impulsa_project)
        expect(project).to be_persisted
        expect(project.name).to be_present
      end
    end

    describe 'concerns inclusion' do
      it 'includes ImpulsaProjectStates' do
        expect(ImpulsaProject.ancestors).to include(PlebisImpulsa::ImpulsaProjectStates)
      end

      it 'includes ImpulsaProjectWizard' do
        expect(ImpulsaProject.ancestors).to include(PlebisImpulsa::ImpulsaProjectWizard)
      end

      it 'includes ImpulsaProjectEvaluation' do
        expect(ImpulsaProject.ancestors).to include(PlebisImpulsa::ImpulsaProjectEvaluation)
      end
    end

    describe 'state-dependent methods' do
      let(:edition) { create(:impulsa_edition, :current) }
      let(:category) { create(:impulsa_edition_category, impulsa_edition: edition) }
      let(:project) { create(:impulsa_project, impulsa_edition_category: category) }

      describe '#editable?' do
        it 'returns true for new projects when edition allows edition' do
          project.state = 'new'
          allow(project.impulsa_edition).to receive(:allow_edition?).and_return(true)
          expect(project.editable?).to be true
        end

        it 'returns false for new projects when edition does not allow edition' do
          project.state = 'new'
          allow(project.impulsa_edition).to receive(:allow_edition?).and_return(false)
          expect(project.editable?).to be false
        end

        it 'returns false for validated projects' do
          project.state = 'validated'
          expect(project.editable?).to be false
        end

        it 'returns false for resigned projects' do
          project.state = 'resigned'
          expect(project.editable?).to be false
        end
      end

      describe '#saveable?' do
        it 'returns true when editable' do
          project.state = 'new'
          allow(project.impulsa_edition).to receive(:allow_edition?).and_return(true)
          expect(project.saveable?).to be true
        end

        it 'returns true when fixable' do
          project.state = 'fixes'
          allow(project.impulsa_edition).to receive(:allow_fixes?).and_return(true)
          expect(project.saveable?).to be true
        end

        it 'returns false when resigned' do
          project.state = 'resigned'
          expect(project.saveable?).to be false
        end
      end

      describe '#reviewable?' do
        it 'returns true for review state' do
          project.save!
          project.state = 'review'
          expect(project.reviewable?).to be true
        end

        it 'returns true for review_fixes state' do
          project.save!
          project.state = 'review_fixes'
          expect(project.reviewable?).to be true
        end

        it 'returns false for resigned projects' do
          project.save!
          project.state = 'resigned'
          expect(project.reviewable?).to be false
        end

        it 'returns false for new projects' do
          project.save!
          project.state = 'new'
          expect(project.reviewable?).to be false
        end
      end

      describe '#markable_for_review?' do
        it 'returns true when conditions are met' do
          project.save!
          project.state = 'new'
          allow(project).to receive(:wizard_has_errors?).and_return(false)
          allow(project.impulsa_edition).to receive(:allow_edition?).and_return(true)
          expect(project.markable_for_review?).to be true
        end

        it 'returns false when resigned' do
          project.save!
          project.state = 'resigned'
          expect(project.markable_for_review?).to be false
        end

        it 'returns false when wizard has errors' do
          project.save!
          project.state = 'new'
          allow(project).to receive(:wizard_has_errors?).and_return(true)
          allow(project.impulsa_edition).to receive(:allow_edition?).and_return(true)
          expect(project.markable_for_review?).to be false
        end
      end

      describe '#deleteable?' do
        it 'returns true for editable projects' do
          project.save!
          project.state = 'new'
          allow(project.impulsa_edition).to receive(:allow_edition?).and_return(true)
          expect(project.deleteable?).to be true
        end

        it 'returns false for resigned projects' do
          project.save!
          project.state = 'resigned'
          expect(project.deleteable?).to be false
        end

        it 'returns false for non-editable projects' do
          project.save!
          project.state = 'validated'
          expect(project.deleteable?).to be false
        end
      end

      describe '#fixable?' do
        it 'returns true when in fixes state and edition allows fixes' do
          project.save!
          project.state = 'fixes'
          allow(project.impulsa_edition).to receive(:allow_fixes?).and_return(true)
          expect(project.fixable?).to be true
        end

        it 'returns false when edition does not allow fixes' do
          project.save!
          project.state = 'fixes'
          allow(project.impulsa_edition).to receive(:allow_fixes?).and_return(false)
          expect(project.fixable?).to be false
        end

        it 'returns false when resigned' do
          project.save!
          project.state = 'resigned'
          allow(project.impulsa_edition).to receive(:allow_fixes?).and_return(true)
          expect(project.fixable?).to be false
        end
      end
    end
  end
end
