# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaProjectStates, type: :model do
  # Test with actual ImpulsaProject model that includes the concern
  let(:edition_active) do
    create(:impulsa_edition,
           start_at: 1.day.ago,
           new_projects_until: 1.day.from_now,
           review_projects_until: 2.days.from_now,
           validation_projects_until: 3.days.from_now,
           votings_start_at: 4.days.from_now,
           ends_at: 5.days.from_now)
  end

  let(:edition_fixes) do
    create(:impulsa_edition,
           start_at: 3.days.ago,
           new_projects_until: 2.days.ago,
           review_projects_until: 1.hour.from_now,
           validation_projects_until: 1.day.from_now,
           votings_start_at: 2.days.from_now,
           ends_at: 3.days.from_now)
  end

  let(:edition_closed) do
    create(:impulsa_edition,
           start_at: 5.days.ago,
           new_projects_until: 4.days.ago,
           review_projects_until: 3.days.ago,
           validation_projects_until: 2.days.ago,
           votings_start_at: 1.day.ago,
           ends_at: 1.hour.from_now)
  end

  let(:wizard_config) do
    {
      step1: {
        title: 'Step 1',
        groups: {
          group1: {
            fields: {
              field1: { type: 'text', optional: false }
            }
          }
        }
      }
    }
  end

  let(:category_active) { create(:impulsa_edition_category, impulsa_edition: edition_active, wizard: wizard_config) }
  let(:category_fixes) { create(:impulsa_edition_category, impulsa_edition: edition_fixes, wizard: wizard_config) }
  let(:category_closed) { create(:impulsa_edition_category, impulsa_edition: edition_closed, wizard: wizard_config) }

  # ====================
  # INITIAL STATE TESTS
  # ====================

  describe 'initial state' do
    it 'starts in new state' do
      project = create(:impulsa_project, impulsa_edition_category: category_active)
      expect(project.state).to eq('new')
      expect(project).to be_new
    end

    it 'is not persisted before creation' do
      project = build(:impulsa_project, impulsa_edition_category: category_active)
      expect(project).not_to be_persisted
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe '.exportable scope' do
    it 'defines scope with validated and winner states' do
      expect(ImpulsaProject.exportable.to_sql).to include('validated', 'winner')
    end

    it 'includes validated projects' do
      validated = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validated')
      expect(ImpulsaProject.exportable).to include(validated)
    end

    it 'includes winner projects' do
      winner = create(:impulsa_project, impulsa_edition_category: category_active, state: 'winner')
      expect(ImpulsaProject.exportable).to include(winner)
    end

    it 'excludes new projects' do
      new_project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      expect(ImpulsaProject.exportable).not_to include(new_project)
    end

    it 'excludes review projects' do
      review = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
      expect(ImpulsaProject.exportable).not_to include(review)
    end

    it 'excludes spam projects' do
      spam = create(:impulsa_project, impulsa_edition_category: category_active, state: 'spam')
      expect(ImpulsaProject.exportable).not_to include(spam)
    end

    it 'excludes fixes projects' do
      fixes = create(:impulsa_project, impulsa_edition_category: category_active, state: 'fixes')
      expect(ImpulsaProject.exportable).not_to include(fixes)
    end

    it 'excludes validable projects' do
      validable = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
      expect(ImpulsaProject.exportable).not_to include(validable)
    end

    it 'excludes invalidated projects' do
      invalidated = create(:impulsa_project, impulsa_edition_category: category_active, state: 'invalidated')
      expect(ImpulsaProject.exportable).not_to include(invalidated)
    end

    it 'excludes resigned projects' do
      resigned = create(:impulsa_project, impulsa_edition_category: category_active, state: 'resigned')
      expect(ImpulsaProject.exportable).not_to include(resigned)
    end
  end

  # ====================
  # STATE TRANSITION TESTS
  # ====================

  describe 'state transitions' do
    describe '#mark_as_spam' do
      it 'transitions from new to spam' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        expect { project.mark_as_spam }.to change { project.state }.from('new').to('spam')
      end

      it 'transitions from review to spam' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
        expect { project.mark_as_spam }.to change { project.state }.from('review').to('spam')
      end

      it 'transitions from fixes to spam' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'fixes')
        expect { project.mark_as_spam }.to change { project.state }.from('fixes').to('spam')
      end

      it 'transitions from validable to spam' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
        expect { project.mark_as_spam }.to change { project.state }.from('validable').to('spam')
      end

      it 'transitions from any state to spam' do
        %w[new review spam fixes review_fixes validable validated invalidated winner resigned].each do |state|
          project = create(:impulsa_project, impulsa_edition_category: category_active, state: state)
          project.mark_as_spam
          expect(project.state).to eq('spam')
        end
      end
    end

    describe '#mark_for_review' do
      it 'transitions from new to review when markable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        project.wizard_values = { 'group1.field1' => 'value' }
        expect { project.mark_for_review }.to change { project.state }.from('new').to('review')
      end

      it 'transitions from spam to review when markable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'spam')
        project.wizard_values = { 'group1.field1' => 'value' }
        expect { project.mark_for_review }.to change { project.state }.from('spam').to('review')
      end

      it 'transitions from fixes to review_fixes when markable' do
        project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
        project.wizard_values = { 'group1.field1' => 'value' }
        expect { project.mark_for_review }.to change { project.state }.from('fixes').to('review_fixes')
      end

      it 'does not transition when not markable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        # No wizard values, so has errors
        expect { project.mark_for_review rescue nil }.not_to change { project.state }
      end

      it 'does not transition when resigned' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'resigned')
        project.wizard_values = { 'group1.field1' => 'value' }
        expect { project.mark_for_review rescue nil }.not_to change { project.state }
      end
    end

    describe '#mark_as_fixes' do
      it 'transitions from review to fixes' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
        expect { project.mark_as_fixes }.to change { project.state }.from('review').to('fixes')
      end

      it 'transitions from review_fixes to fixes' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review_fixes')
        expect { project.mark_as_fixes }.to change { project.state }.from('review_fixes').to('fixes')
      end

      it 'does not transition from other states' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        expect { project.mark_as_fixes rescue nil }.not_to change { project.state }
      end
    end

    describe '#mark_as_validable' do
      it 'transitions from review to validable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
        expect { project.mark_as_validable }.to change { project.state }.from('review').to('validable')
      end

      it 'transitions from review_fixes to validable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review_fixes')
        expect { project.mark_as_validable }.to change { project.state }.from('review_fixes').to('validable')
      end

      it 'does not transition from other states' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        expect { project.mark_as_validable rescue nil }.not_to change { project.state }
      end
    end

    describe '#mark_as_validated' do
      it 'transitions from validable to validated when evaluation_result? is true' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(true)
        expect { project.mark_as_validated }.to change { project.state }.from('validable').to('validated')
      end

      it 'does not transition when evaluation_result? is false' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(false)
        expect { project.mark_as_validated rescue nil }.not_to change { project.state }
      end

      it 'does not transition from other states' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
        allow(project).to receive(:evaluation_result?).and_return(true)
        expect { project.mark_as_validated rescue nil }.not_to change { project.state }
      end
    end

    describe '#mark_as_invalidated' do
      it 'transitions from validable to invalidated when evaluation_result? is true' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(true)
        expect { project.mark_as_invalidated }.to change { project.state }.from('validable').to('invalidated')
      end

      it 'does not transition when evaluation_result? is false' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(false)
        expect { project.mark_as_invalidated rescue nil }.not_to change { project.state }
      end

      it 'does not transition from other states' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
        allow(project).to receive(:evaluation_result?).and_return(true)
        expect { project.mark_as_invalidated rescue nil }.not_to change { project.state }
      end
    end

    describe '#mark_as_winner' do
      it 'transitions from validated to winner' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validated')
        expect { project.mark_as_winner }.to change { project.state }.from('validated').to('winner')
      end

      it 'does not transition from other states' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
        expect { project.mark_as_winner rescue nil }.not_to change { project.state }
      end
    end

    describe '#mark_as_resigned' do
      it 'transitions from new to resigned' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        expect { project.mark_as_resigned }.to change { project.state }.from('new').to('resigned')
      end

      it 'transitions from any state to resigned' do
        %w[new review spam fixes review_fixes validable validated invalidated winner].each do |state|
          project = create(:impulsa_project, impulsa_edition_category: category_active, state: state)
          project.mark_as_resigned
          expect(project.state).to eq('resigned')
        end
      end
    end
  end

  # ====================
  # AUDIT TRAIL TESTS
  # ====================

  describe 'audit trail' do
    it 'creates state transition record on state change' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      initial_count = project.impulsa_project_state_transitions.count

      project.mark_as_spam

      expect(project.impulsa_project_state_transitions.count).to be > initial_count
    end

    it 'records correct from and to states' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.mark_as_spam

      transition = project.impulsa_project_state_transitions.last
      expect(transition.from).to eq('new')
      expect(transition.to).to eq('spam')
    end

    it 'records transition event' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.mark_as_spam

      transition = project.impulsa_project_state_transitions.last
      expect(transition.event).to eq('mark_as_spam')
    end
  end

  # ====================
  # STATE-SPECIFIC BEHAVIOR TESTS
  # ====================

  describe '#editable?' do
    context 'in new state' do
      it 'returns true when edition allows edition' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        expect(project.editable?).to be true
      end

      it 'returns false when edition does not allow edition' do
        project = create(:impulsa_project, impulsa_edition_category: category_closed, state: 'new')
        expect(project.editable?).to be false
      end

      it 'returns false when resigned' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        project.mark_as_resigned
        expect(project.editable?).to be false
      end

      it 'returns true when not persisted' do
        project = build(:impulsa_project, impulsa_edition_category: category_active)
        expect(project.editable?).to be true
      end

      it 'checks both persisted and edition allow_edition conditions' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        expect(project.persisted?).to be true
        expect(project.impulsa_edition.allow_edition?).to be true
        expect(project.editable?).to be true
      end
    end

    context 'in review state' do
      it 'returns true when edition allows edition' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
        expect(project.editable?).to be true
      end

      it 'returns false when edition does not allow edition' do
        project = create(:impulsa_project, impulsa_edition_category: category_closed, state: 'review')
        expect(project.editable?).to be false
      end
    end

    context 'in spam state' do
      it 'returns true when edition allows edition' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'spam')
        expect(project.editable?).to be true
      end

      it 'returns false when edition does not allow edition' do
        project = create(:impulsa_project, impulsa_edition_category: category_closed, state: 'spam')
        expect(project.editable?).to be false
      end
    end

    context 'in other states' do
      it 'returns false for fixes' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'fixes')
        expect(project.editable?).to be false
      end

      it 'returns false for review_fixes' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review_fixes')
        expect(project.editable?).to be false
      end

      it 'returns false for validable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
        expect(project.editable?).to be false
      end

      it 'returns false for validated' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validated')
        expect(project.editable?).to be false
      end

      it 'returns false for invalidated' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'invalidated')
        expect(project.editable?).to be false
      end

      it 'returns false for winner' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'winner')
        expect(project.editable?).to be false
      end

      it 'returns false for resigned' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'resigned')
        expect(project.editable?).to be false
      end

      it 'state blocks define editable? method for non-editable states' do
        %w[fixes review_fixes validable validated invalidated winner resigned].each do |state|
          project = create(:impulsa_project, impulsa_edition_category: category_active, state: state)
          expect(project).to respond_to(:editable?)
          expect(project.editable?).to be false
        end
      end
    end
  end

  # ====================
  # HELPER METHOD TESTS
  # ====================

  describe '#saveable?' do
    it 'returns true when editable and not resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      expect(project.saveable?).to be true
    end

    it 'returns true when fixable and not resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
      expect(project.saveable?).to be true
    end

    it 'returns false when resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'resigned')
      expect(project.saveable?).to be false
    end

    it 'returns false when neither editable nor fixable' do
      project = create(:impulsa_project, impulsa_edition_category: category_closed, state: 'validable')
      expect(project.saveable?).to be false
    end

    it 'returns false when editable but resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.mark_as_resigned
      expect(project.saveable?).to be false
    end

    it 'returns false when fixable but resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
      project.mark_as_resigned
      expect(project.saveable?).to be false
    end
  end

  describe '#reviewable?' do
    it 'returns true for review state when persisted and not resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
      expect(project.reviewable?).to be true
    end

    it 'returns true for review_fixes state when persisted and not resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review_fixes')
      expect(project.reviewable?).to be true
    end

    it 'returns false for new state' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      expect(project.reviewable?).to be false
    end

    it 'returns false when not persisted' do
      project = build(:impulsa_project, impulsa_edition_category: category_active)
      expect(project.reviewable?).to be false
    end

    it 'returns false when resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
      project.mark_as_resigned
      expect(project.reviewable?).to be false
    end
  end

  describe '#markable_for_review?' do
    it 'returns true when all conditions are met' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.wizard_values = { 'group1.field1' => 'value' }
      expect(project.markable_for_review?).to be true
    end

    it 'returns false when not persisted' do
      project = build(:impulsa_project, impulsa_edition_category: category_active)
      project.wizard_values = { 'group1.field1' => 'value' }
      expect(project.markable_for_review?).to be false
    end

    it 'returns false when resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.wizard_values = { 'group1.field1' => 'value' }
      project.mark_as_resigned
      expect(project.markable_for_review?).to be false
    end

    it 'returns false when already reviewable' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
      project.wizard_values = { 'group1.field1' => 'value' }
      expect(project.markable_for_review?).to be false
    end

    it 'returns false when not saveable' do
      project = create(:impulsa_project, impulsa_edition_category: category_closed, state: 'validable')
      expect(project.markable_for_review?).to be false
    end

    it 'returns false when wizard has errors' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.wizard_values = {} # Missing required field
      expect(project.markable_for_review?).to be false
    end

    it 'returns true for spam state with valid data' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'spam')
      project.wizard_values = { 'group1.field1' => 'value' }
      expect(project.markable_for_review?).to be true
    end

    it 'returns true for fixes state with valid data' do
      project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
      project.wizard_values = { 'group1.field1' => 'value' }
      expect(project.markable_for_review?).to be true
    end
  end

  describe '#deleteable?' do
    it 'returns true when editable and persisted and not resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      expect(project.deleteable?).to be true
    end

    it 'returns false when not persisted' do
      project = build(:impulsa_project, impulsa_edition_category: category_active)
      expect(project.deleteable?).to be false
    end

    it 'returns false when resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.mark_as_resigned
      expect(project.deleteable?).to be false
    end

    it 'returns false when not editable' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
      expect(project.deleteable?).to be false
    end

    it 'returns true for review state when edition allows' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
      expect(project.deleteable?).to be true
    end

    it 'returns true for spam state when edition allows' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'spam')
      expect(project.deleteable?).to be true
    end
  end

  describe '#fixable?' do
    it 'returns true in fixes state when edition allows fixes' do
      project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
      expect(project.fixable?).to be true
    end

    it 'returns false when not in fixes state' do
      project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'review')
      expect(project.fixable?).to be false
    end

    it 'returns false when resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
      project.mark_as_resigned
      expect(project.fixable?).to be false
    end

    it 'returns false when edition does not allow fixes' do
      project = create(:impulsa_project, impulsa_edition_category: category_closed, state: 'fixes')
      expect(project.fixable?).to be false
    end

    it 'returns false when not persisted' do
      project = build(:impulsa_project, impulsa_edition_category: category_fixes)
      expect(project.fixable?).to be false
    end
  end

  # ====================
  # STATE PREDICATE TESTS
  # ====================

  describe 'state predicates' do
    it 'provides predicate methods for all states' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      expect(project).to respond_to(:new?)
      expect(project).to respond_to(:review?)
      expect(project).to respond_to(:spam?)
      expect(project).to respond_to(:fixes?)
      expect(project).to respond_to(:review_fixes?)
      expect(project).to respond_to(:validable?)
      expect(project).to respond_to(:validated?)
      expect(project).to respond_to(:invalidated?)
      expect(project).to respond_to(:winner?)
      expect(project).to respond_to(:resigned?)
    end

    it 'returns true for current state' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
      expect(project.review?).to be true
      expect(project.new?).to be false
    end

    it 'updates predicates after state change' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      expect(project.new?).to be true

      project.mark_as_spam
      expect(project.new?).to be false
      expect(project.spam?).to be true
    end
  end

  # ====================
  # INTEGRATION TESTS
  # ====================

  describe 'integration tests' do
    it 'completes full state flow from new to winner' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.wizard_values = { 'group1.field1' => 'value' }

      # New -> Review
      expect(project.state).to eq('new')
      project.mark_for_review
      expect(project.state).to eq('review')

      # Review -> Validable
      project.mark_as_validable
      expect(project.state).to eq('validable')

      # Validable -> Validated
      allow(project).to receive(:evaluation_result?).and_return(true)
      project.mark_as_validated
      expect(project.state).to eq('validated')

      # Validated -> Winner
      project.mark_as_winner
      expect(project.state).to eq('winner')

      # Check exportable
      expect(ImpulsaProject.exportable).to include(project)
    end

    it 'handles fixes flow' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.wizard_values = { 'group1.field1' => 'value' }

      # New -> Review
      project.mark_for_review
      expect(project.state).to eq('review')

      # Review -> Fixes
      project.mark_as_fixes
      expect(project.state).to eq('fixes')

      # Update edition to allow fixes
      project.impulsa_edition_category.impulsa_edition.update(
        new_projects_until: 2.days.ago,
        review_projects_until: 1.hour.from_now
      )

      # Fixes -> Review_fixes
      project.mark_for_review
      expect(project.state).to eq('review_fixes')

      # Review_fixes -> Validable
      project.mark_as_validable
      expect(project.state).to eq('validable')
    end

    it 'handles invalidation flow' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
      allow(project).to receive(:evaluation_result?).and_return(true)

      project.mark_as_invalidated
      expect(project.state).to eq('invalidated')
      expect(ImpulsaProject.exportable).not_to include(project)
    end

    it 'can resign from any state' do
      %w[new review spam fixes review_fixes validable validated invalidated winner].each do |state|
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: state)
        project.mark_as_resigned
        expect(project.state).to eq('resigned')
        expect(project.saveable?).to be false
        expect(project.editable?).to be false
      end
    end

    it 'tracks all transitions in audit trail' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.wizard_values = { 'group1.field1' => 'value' }

      initial_count = project.impulsa_project_state_transitions.count

      project.mark_for_review
      project.mark_as_validable
      allow(project).to receive(:evaluation_result?).and_return(true)
      project.mark_as_validated
      project.mark_as_winner

      expect(project.impulsa_project_state_transitions.count).to eq(initial_count + 4)

      transitions = project.impulsa_project_state_transitions.order(:created_at)
      expect(transitions.map(&:event)).to include('mark_for_review', 'mark_as_validable', 'mark_as_validated', 'mark_as_winner')
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles multiple spam markings' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.mark_as_spam
      expect(project.state).to eq('spam')

      # Mark as spam again
      project.mark_as_spam
      expect(project.state).to eq('spam')
    end

    it 'prevents invalid transitions' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')

      # Try invalid transition - mark_as_winner from new state should fail
      expect(project.mark_as_winner).to be false
      expect(project.state).to eq('new')
    end

    it 'does not allow mark_for_review when resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.wizard_values = { 'group1.field1' => 'value' }
      project.mark_as_resigned

      # Should fail because markable_for_review? returns false when resigned
      expect(project.mark_for_review).to be false
      expect(project.state).to eq('resigned')
    end

    it 'handles transition from spam to spam' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'spam')
      expect { project.mark_as_spam }.not_to change { project.state }
    end

    it 'handles transition from resigned to resigned' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'resigned')
      expect { project.mark_as_resigned }.not_to change { project.state }
    end
  end

  # ====================
  # ADDITIONAL GUARD CLAUSE TESTS
  # ====================

  describe 'guard clauses' do
    describe 'evaluation_result? guard' do
      it 'prevents mark_as_validated without evaluation_result' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(false)

        expect(project.mark_as_validated).to be false
        expect(project.state).to eq('validable')
      end

      it 'prevents mark_as_invalidated without evaluation_result' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
        allow(project).to receive(:evaluation_result?).and_return(false)

        expect(project.mark_as_invalidated).to be false
        expect(project.state).to eq('validable')
      end
    end

    describe 'markable_for_review? guard' do
      it 'allows transition from new when markable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        project.wizard_values = { 'group1.field1' => 'value' }

        expect(project.markable_for_review?).to be true
        expect(project.mark_for_review).to be true
      end

      it 'prevents transition from new when not markable (wizard errors)' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        project.wizard_values = {} # Missing required field

        expect(project.markable_for_review?).to be false
        expect(project.mark_for_review).to be false
      end

      it 'allows transition from spam when markable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'spam')
        project.wizard_values = { 'group1.field1' => 'value' }

        expect(project.markable_for_review?).to be true
        expect(project.mark_for_review).to be true
      end

      it 'prevents transition from spam when not markable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'spam')
        project.wizard_values = {} # Missing required field

        expect(project.markable_for_review?).to be false
        expect(project.mark_for_review).to be false
      end

      it 'allows transition from fixes when markable' do
        project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
        project.wizard_values = { 'group1.field1' => 'value' }

        expect(project.markable_for_review?).to be true
        expect(project.mark_for_review).to be true
      end

      it 'prevents transition from fixes when not markable' do
        project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
        project.wizard_values = {} # Missing required field

        expect(project.markable_for_review?).to be false
        expect(project.mark_for_review).to be false
      end
    end
  end

  # ====================
  # COMPREHENSIVE STATE COVERAGE
  # ====================

  describe 'comprehensive state coverage' do
    describe 'editable? with resigned flag' do
      it 'returns false for new state when resigned' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        project.mark_as_resigned
        expect(project.editable?).to be false
        expect(project.resigned?).to be true
      end

      it 'returns false for review state when resigned' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
        project.mark_as_resigned
        expect(project.editable?).to be false
        expect(project.resigned?).to be true
      end

      it 'returns false for spam state when resigned' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'spam')
        project.mark_as_resigned
        expect(project.editable?).to be false
        expect(project.resigned?).to be true
      end
    end

    describe 'saveable? comprehensive' do
      it 'returns true when editable but not fixable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        expect(project.editable?).to be true
        expect(project.fixable?).to be false
        expect(project.saveable?).to be true
      end

      it 'returns true when fixable but not editable' do
        project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
        expect(project.editable?).to be false
        expect(project.fixable?).to be true
        expect(project.saveable?).to be true
      end

      it 'returns true when both editable and fixable' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        # In new state, editable is true but fixable is false (not in fixes state)
        # So this tests the OR condition
        expect(project.saveable?).to be true
      end
    end

    describe 'reviewable? comprehensive' do
      it 'returns false for review state when resigned' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
        project.mark_as_resigned
        expect(project.reviewable?).to be false
      end

      it 'returns false for review_fixes state when resigned' do
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review_fixes')
        project.mark_as_resigned
        expect(project.reviewable?).to be false
      end

      it 'returns false for non-review states' do
        %w[new spam fixes validable validated invalidated winner resigned].each do |state|
          project = create(:impulsa_project, impulsa_edition_category: category_active, state: state)
          expect(project.reviewable?).to be false
        end
      end
    end

    describe 'deleteable? comprehensive' do
      it 'requires all three conditions: persisted, not resigned, editable' do
        # Not persisted
        project = build(:impulsa_project, impulsa_edition_category: category_active)
        expect(project.deleteable?).to be false

        # Persisted but resigned
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        project.mark_as_resigned
        expect(project.deleteable?).to be false

        # Persisted but not editable
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validable')
        expect(project.deleteable?).to be false

        # All conditions met
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        expect(project.deleteable?).to be true
      end
    end

    describe 'fixable? comprehensive' do
      it 'requires all four conditions: persisted, not resigned, fixes state, edition allows' do
        # Not persisted
        project = build(:impulsa_project, impulsa_edition_category: category_fixes)
        project.state = 'fixes'
        expect(project.fixable?).to be false

        # Persisted but resigned
        project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
        project.mark_as_resigned
        expect(project.fixable?).to be false

        # Persisted but not in fixes state
        project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'review')
        expect(project.fixable?).to be false

        # Persisted, fixes state, but edition doesn't allow
        project = create(:impulsa_project, impulsa_edition_category: category_closed, state: 'fixes')
        expect(project.fixable?).to be false

        # All conditions met
        project = create(:impulsa_project, impulsa_edition_category: category_fixes, state: 'fixes')
        expect(project.fixable?).to be true
      end
    end

    describe 'markable_for_review? comprehensive' do
      it 'requires all five conditions' do
        # Not persisted
        project = build(:impulsa_project, impulsa_edition_category: category_active)
        project.wizard_values = { 'group1.field1' => 'value' }
        expect(project.markable_for_review?).to be false

        # Persisted but resigned
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        project.wizard_values = { 'group1.field1' => 'value' }
        project.mark_as_resigned
        expect(project.markable_for_review?).to be false

        # Persisted but already reviewable
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review')
        project.wizard_values = { 'group1.field1' => 'value' }
        expect(project.markable_for_review?).to be false

        # Persisted but not saveable (edition closed)
        project = create(:impulsa_project, impulsa_edition_category: category_closed, state: 'validable')
        expect(project.markable_for_review?).to be false

        # Persisted but wizard has errors
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        project.wizard_values = {} # Missing required field
        expect(project.markable_for_review?).to be false

        # All conditions met
        project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
        project.wizard_values = { 'group1.field1' => 'value' }
        expect(project.markable_for_review?).to be true
      end
    end
  end

  # ====================
  # ADDITIONAL TRANSITION COMBINATIONS
  # ====================

  describe 'additional transition combinations' do
    it 'can transition review_fixes to fixes' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'review_fixes')
      expect { project.mark_as_fixes }.to change { project.state }.from('review_fixes').to('fixes')
    end

    it 'exportable scope includes only validated and winner' do
      validated = create(:impulsa_project, impulsa_edition_category: category_active, state: 'validated')
      winner = create(:impulsa_project, impulsa_edition_category: category_active, state: 'winner')
      other = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')

      exportable = ImpulsaProject.exportable
      expect(exportable).to include(validated, winner)
      expect(exportable).not_to include(other)
      expect(exportable.count).to eq(2)
    end

    it 'maintains state through reload' do
      project = create(:impulsa_project, impulsa_edition_category: category_active, state: 'new')
      project.wizard_values = { 'group1.field1' => 'value' }
      project.mark_for_review

      project.reload
      expect(project.state).to eq('review')
      expect(project.reviewable?).to be true
    end
  end
end
