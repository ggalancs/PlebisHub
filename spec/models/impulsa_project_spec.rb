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

    describe '#method_missing' do
      it 'delegates to wizard_method_missing' do
        project = create(:impulsa_project)
        allow(project).to receive(:wizard_method_missing).and_return(:result)

        expect(project.send(:method_missing, :test_method)).to eq(:result)
      end

      it 'delegates to evaluation_method_missing when wizard returns :super' do
        project = create(:impulsa_project)
        allow(project).to receive(:wizard_method_missing).and_return(:super)
        allow(project).to receive(:evaluation_method_missing).and_return(:eval_result)

        expect(project.send(:method_missing, :test_method)).to eq(:eval_result)
      end

      it 'raises NoMethodError when both return :super' do
        project = create(:impulsa_project)
        allow(project).to receive(:wizard_method_missing).and_return(:super)
        allow(project).to receive(:evaluation_method_missing).and_return(:super)

        expect { project.some_undefined_method }.to raise_error(NoMethodError)
      end
    end
  end

  # ====================
  # STATE MACHINE TESTS (ImpulsaProjectStates)
  # ====================

  describe 'state machine' do
    describe 'initial state' do
      it 'starts in new state' do
        project = create(:impulsa_project)
        expect(project.state).to eq('new')
      end
    end

    describe '#mark_as_spam' do
      it 'transitions from any state to spam' do
        project = create(:impulsa_project, state: 'review')
        expect { project.mark_as_spam }.to change { project.state }.to('spam')
      end
    end

    describe '#mark_for_review' do
      it 'transitions from new to review when markable' do
        edition = create(:impulsa_edition, :active)
        category = create(:impulsa_edition_category, impulsa_edition: edition, wizard: { step1: { title: 'Step 1', groups: {} } })
        project = create(:impulsa_project, impulsa_edition_category: category, state: 'new')

        allow(project).to receive(:markable_for_review?).and_return(true)
        expect { project.mark_for_review }.to change { project.state }.from('new').to('review')
      end

      it 'transitions from spam to review when markable' do
        edition = create(:impulsa_edition, :active)
        category = create(:impulsa_edition_category, impulsa_edition: edition, wizard: { step1: { title: 'Step 1', groups: {} } })
        project = create(:impulsa_project, impulsa_edition_category: category, state: 'spam')

        allow(project).to receive(:markable_for_review?).and_return(true)
        expect { project.mark_for_review }.to change { project.state }.from('spam').to('review')
      end

      it 'transitions from fixes to review_fixes when markable' do
        edition = create(:impulsa_edition, :active)
        category = create(:impulsa_edition_category, impulsa_edition: edition, wizard: { step1: { title: 'Step 1', groups: {} } })
        project = create(:impulsa_project, impulsa_edition_category: category, state: 'fixes')

        allow(project).to receive(:markable_for_review?).and_return(true)
        expect { project.mark_for_review }.to change { project.state }.from('fixes').to('review_fixes')
      end
    end

    describe '#mark_as_fixes' do
      it 'transitions from review to fixes' do
        project = create(:impulsa_project, state: 'review')
        expect { project.mark_as_fixes }.to change { project.state }.from('review').to('fixes')
      end

      it 'transitions from review_fixes to fixes' do
        project = create(:impulsa_project, state: 'review_fixes')
        expect { project.mark_as_fixes }.to change { project.state }.from('review_fixes').to('fixes')
      end
    end

    describe '#mark_as_validable' do
      it 'transitions from review to validable' do
        project = create(:impulsa_project, state: 'review')
        expect { project.mark_as_validable }.to change { project.state }.from('review').to('validable')
      end

      it 'transitions from review_fixes to validable' do
        project = create(:impulsa_project, state: 'review_fixes')
        expect { project.mark_as_validable }.to change { project.state }.from('review_fixes').to('validable')
      end
    end

    describe '#mark_as_validated' do
      it 'transitions from validable to validated when evaluation_result? is true' do
        project = create(:impulsa_project, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(true)
        expect { project.mark_as_validated }.to change { project.state }.from('validable').to('validated')
      end

      it 'does not transition when evaluation_result? is false' do
        project = create(:impulsa_project, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(false)
        expect { project.mark_as_validated rescue nil }.not_to change { project.state }
      end
    end

    describe '#mark_as_invalidated' do
      it 'transitions from validable to invalidated when evaluation_result? is true' do
        project = create(:impulsa_project, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(true)
        expect { project.mark_as_invalidated }.to change { project.state }.from('validable').to('invalidated')
      end
    end

    describe '#mark_as_winner' do
      it 'transitions from validated to winner' do
        project = create(:impulsa_project, state: 'validated')
        expect { project.mark_as_winner }.to change { project.state }.from('validated').to('winner')
      end
    end

    describe '#mark_as_resigned' do
      it 'transitions from any state to resigned' do
        project = create(:impulsa_project, state: 'review')
        expect { project.mark_as_resigned }.to change { project.state }.to('resigned')
      end
    end

    describe '#editable?' do
      context 'in new, review, or spam state' do
        it 'returns true when edition allows edition' do
          edition = create(:impulsa_edition,
                           start_at: 1.day.ago,
                           new_projects_until: 1.day.from_now,
                           review_projects_until: 2.days.from_now,
                           validation_projects_until: 3.days.from_now,
                           votings_start_at: 4.days.from_now,
                           ends_at: 5.days.from_now)
          category = create(:impulsa_edition_category, impulsa_edition: edition)
          project = create(:impulsa_project, impulsa_edition_category: category, state: 'new')

          expect(project.editable?).to be true
        end

        it 'returns false when edition does not allow edition' do
          edition = create(:impulsa_edition, :active)
          category = create(:impulsa_edition_category, impulsa_edition: edition)
          project = create(:impulsa_project, impulsa_edition_category: category, state: 'new')

          expect(project.editable?).to be false
        end

        it 'returns false when resigned' do
          edition = create(:impulsa_edition, :active)
          category = create(:impulsa_edition_category, impulsa_edition: edition)
          project = create(:impulsa_project, impulsa_edition_category: category, state: 'resigned')

          expect(project.editable?).to be false
        end
      end

      context 'in other states' do
        it 'returns false' do
          project = create(:impulsa_project, state: 'validated')
          expect(project.editable?).to be false
        end
      end
    end

    describe '#saveable?' do
      it 'returns true when editable and not resigned' do
        project = create(:impulsa_project, state: 'new')
        allow(project).to receive(:editable?).and_return(true)
        allow(project).to receive(:resigned?).and_return(false)

        expect(project.saveable?).to be true
      end

      it 'returns true when fixable and not resigned' do
        project = create(:impulsa_project, state: 'fixes')
        allow(project).to receive(:fixable?).and_return(true)
        allow(project).to receive(:resigned?).and_return(false)

        expect(project.saveable?).to be true
      end

      it 'returns false when resigned' do
        project = create(:impulsa_project, state: 'resigned')
        expect(project.saveable?).to be false
      end
    end

    describe '#reviewable?' do
      it 'returns true for review state when persisted and not resigned' do
        project = create(:impulsa_project, state: 'review')
        expect(project.reviewable?).to be true
      end

      it 'returns true for review_fixes state when persisted and not resigned' do
        project = create(:impulsa_project, state: 'review_fixes')
        expect(project.reviewable?).to be true
      end

      it 'returns false for other states' do
        project = create(:impulsa_project, state: 'new')
        expect(project.reviewable?).to be false
      end
    end

    describe '#markable_for_review?' do
      it 'returns true when all conditions are met' do
        project = create(:impulsa_project, state: 'new')
        allow(project).to receive(:saveable?).and_return(true)
        allow(project).to receive(:wizard_has_errors?).and_return(false)

        expect(project.markable_for_review?).to be true
      end

      it 'returns false when wizard has errors' do
        project = create(:impulsa_project, state: 'new')
        allow(project).to receive(:saveable?).and_return(true)
        allow(project).to receive(:wizard_has_errors?).and_return(true)

        expect(project.markable_for_review?).to be false
      end

      it 'returns false when not saveable' do
        project = create(:impulsa_project, state: 'new')
        allow(project).to receive(:saveable?).and_return(false)

        expect(project.markable_for_review?).to be false
      end
    end

    describe '#deleteable?' do
      it 'returns true when editable and persisted and not resigned' do
        project = create(:impulsa_project, state: 'new')
        allow(project).to receive(:editable?).and_return(true)

        expect(project.deleteable?).to be true
      end

      it 'returns false when resigned' do
        project = create(:impulsa_project, state: 'resigned')
        expect(project.deleteable?).to be false
      end
    end

    describe '#fixable?' do
      it 'returns true in fixes state when edition allows fixes' do
        edition = create(:impulsa_edition,
                         start_at: 3.days.ago,
                         new_projects_until: 2.days.ago,
                         review_projects_until: 1.hour.from_now,
                         validation_projects_until: 1.day.from_now,
                         votings_start_at: 2.days.from_now,
                         ends_at: 3.days.from_now)
        category = create(:impulsa_edition_category, impulsa_edition: edition)
        project = create(:impulsa_project, impulsa_edition_category: category, state: 'fixes')

        expect(project.fixable?).to be true
      end

      it 'returns false when not in fixes state' do
        project = create(:impulsa_project, state: 'review')
        expect(project.fixable?).to be false
      end

      it 'returns false when resigned' do
        project = create(:impulsa_project, state: 'resigned')
        expect(project.fixable?).to be false
      end
    end

    describe '.exportable scope' do
      it 'includes validated projects' do
        validated = create(:impulsa_project, state: 'validated')
        expect(ImpulsaProject.exportable).to include(validated)
      end

      it 'includes winner projects' do
        winner = create(:impulsa_project, state: 'winner')
        expect(ImpulsaProject.exportable).to include(winner)
      end

      it 'excludes other states' do
        new_project = create(:impulsa_project, state: 'new')
        expect(ImpulsaProject.exportable).not_to include(new_project)
      end
    end

    describe 'audit trail' do
      it 'creates state transition records on state changes' do
        project = create(:impulsa_project, state: 'new')
        initial_count = project.impulsa_project_state_transitions.count

        project.mark_as_spam

        expect(project.impulsa_project_state_transitions.count).to be > initial_count
      end
    end
  end
end
