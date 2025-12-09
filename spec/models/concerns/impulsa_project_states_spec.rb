# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaProjectStates, type: :model do
  let(:impulsa_edition) { create(:impulsa_edition) }
  let(:impulsa_edition_category) { create(:impulsa_edition_category, impulsa_edition: impulsa_edition) }
  let(:user) { create(:user) }
  let(:project) do
    create(:impulsa_project,
           impulsa_edition: impulsa_edition,
           impulsa_edition_category: impulsa_edition_category,
           user: user)
  end

  describe 'state machine' do
    it 'starts in new state' do
      expect(project.state).to eq('new')
    end

    describe 'mark_as_spam event' do
      it 'transitions from any state to spam' do
        project.mark_as_spam
        expect(project.state).to eq('spam')
      end

      it 'can transition from new to spam' do
        expect(project.state).to eq('new')
        project.mark_as_spam
        expect(project.state).to eq('spam')
      end
    end

    describe 'mark_for_review event' do
      context 'from new state' do
        it 'transitions to review if markable' do
          allow(project).to receive(:markable_for_review?).and_return(true)
          project.mark_for_review
          expect(project.state).to eq('review')
        end

        it 'does not transition if not markable' do
          allow(project).to receive(:markable_for_review?).and_return(false)
          # State machine returns false when guard fails rather than raising error
          expect(project.mark_for_review).to be false
          expect(project.state).to eq('new')
        end
      end

      context 'from spam state' do
        before { project.update_column(:state, 'spam') }

        it 'transitions to review if markable' do
          allow(project).to receive(:markable_for_review?).and_return(true)
          project.mark_for_review
          expect(project.state).to eq('review')
        end
      end

      context 'from fixes state' do
        before { project.update_column(:state, 'fixes') }

        it 'transitions to review_fixes if markable' do
          allow(project).to receive(:markable_for_review?).and_return(true)
          project.mark_for_review
          expect(project.state).to eq('review_fixes')
        end
      end
    end

    describe 'mark_as_fixes event' do
      context 'from review state' do
        before { project.update_column(:state, 'review') }

        it 'transitions to fixes' do
          project.mark_as_fixes
          expect(project.state).to eq('fixes')
        end
      end

      context 'from review_fixes state' do
        before { project.update_column(:state, 'review_fixes') }

        it 'transitions to fixes' do
          project.mark_as_fixes
          expect(project.state).to eq('fixes')
        end
      end
    end

    describe 'mark_as_validable event' do
      context 'from review state' do
        before { project.update_column(:state, 'review') }

        it 'transitions to validable' do
          project.mark_as_validable
          expect(project.state).to eq('validable')
        end
      end

      context 'from review_fixes state' do
        before { project.update_column(:state, 'review_fixes') }

        it 'transitions to validable' do
          project.mark_as_validable
          expect(project.state).to eq('validable')
        end
      end
    end

    describe 'mark_as_validated event' do
      context 'from validable state' do
        before { project.update_column(:state, 'validable') }

        it 'transitions to validated if evaluation_result present' do
          project.evaluation_result = 'Approved'
          project.mark_as_validated
          expect(project.state).to eq('validated')
        end

        it 'does not transition without evaluation_result' do
          project.evaluation_result = nil
          # State machine returns false when guard fails rather than raising error
          expect(project.mark_as_validated).to be false
          expect(project.state).to eq('validable')
        end
      end
    end

    describe 'mark_as_invalidated event' do
      context 'from validable state' do
        before { project.update_column(:state, 'validable') }

        it 'transitions to invalidated if evaluation_result present' do
          project.evaluation_result = 'Rejected'
          project.mark_as_invalidated
          expect(project.state).to eq('invalidated')
        end
      end
    end

    describe 'mark_as_winner event' do
      context 'from validated state' do
        before { project.update_column(:state, 'validated') }

        it 'transitions to winner' do
          project.mark_as_winner
          expect(project.state).to eq('winner')
        end
      end
    end

    describe 'mark_as_resigned event' do
      it 'transitions from any state to resigned' do
        project.mark_as_resigned
        expect(project.state).to eq('resigned')
      end

      it 'works from validated state' do
        project.update_column(:state, 'validated')
        project.mark_as_resigned
        expect(project.state).to eq('resigned')
      end
    end
  end

  describe '#editable?' do
    context 'in new state' do
      it 'returns true if edition allows edition' do
        allow(impulsa_edition).to receive(:allow_edition?).and_return(true)
        expect(project.editable?).to be true
      end

      it 'returns false if edition does not allow edition' do
        allow(impulsa_edition).to receive(:allow_edition?).and_return(false)
        expect(project.editable?).to be false
      end

      it 'returns false if resigned' do
        project.update_column(:state, 'resigned')
        expect(project.editable?).to be false
      end
    end

    context 'in review state' do
      before { project.update_column(:state, 'review') }

      it 'returns true if edition allows edition and not resigned' do
        allow(impulsa_edition).to receive(:allow_edition?).and_return(true)
        expect(project.editable?).to be true
      end
    end

    context 'in other states' do
      before { project.update_column(:state, 'validated') }

      it 'returns false' do
        expect(project.editable?).to be false
      end
    end
  end

  describe '#saveable?' do
    it 'returns true if editable' do
      allow(project).to receive(:editable?).and_return(true)
      allow(project).to receive(:fixable?).and_return(false)
      expect(project.saveable?).to be true
    end

    it 'returns true if fixable' do
      allow(project).to receive(:editable?).and_return(false)
      allow(project).to receive(:fixable?).and_return(true)
      expect(project.saveable?).to be true
    end

    it 'returns false if resigned' do
      project.update_column(:state, 'resigned')
      expect(project.saveable?).to be false
    end
  end

  describe '#reviewable?' do
    it 'returns true in review state and persisted' do
      project.save
      project.update_column(:state, 'review')
      expect(project.reviewable?).to be true
    end

    it 'returns true in review_fixes state' do
      project.save
      project.update_column(:state, 'review_fixes')
      expect(project.reviewable?).to be true
    end

    it 'returns false in new state' do
      expect(project.reviewable?).to be false
    end

    it 'returns false if resigned' do
      project.update_column(:state, 'resigned')
      expect(project.reviewable?).to be false
    end
  end

  describe '#markable_for_review?' do
    before { project.save }

    it 'returns true when conditions are met' do
      allow(project).to receive(:saveable?).and_return(true)
      allow(project).to receive(:wizard_has_errors?).and_return(false)
      expect(project.markable_for_review?).to be true
    end

    it 'returns false if not saveable' do
      allow(project).to receive(:saveable?).and_return(false)
      expect(project.markable_for_review?).to be false
    end

    it 'returns false if has errors' do
      allow(project).to receive(:saveable?).and_return(true)
      allow(project).to receive(:wizard_has_errors?).and_return(true)
      expect(project.markable_for_review?).to be false
    end

    it 'returns false if resigned' do
      project.update_column(:state, 'resigned')
      expect(project.markable_for_review?).to be false
    end
  end

  describe '#deleteable?' do
    before { project.save }

    it 'returns true if editable and persisted' do
      allow(project).to receive(:editable?).and_return(true)
      expect(project.deleteable?).to be true
    end

    it 'returns false if not editable' do
      allow(project).to receive(:editable?).and_return(false)
      expect(project.deleteable?).to be false
    end

    it 'returns false if resigned' do
      project.update_column(:state, 'resigned')
      expect(project.deleteable?).to be false
    end
  end

  describe '#fixable?' do
    before { project.save }

    it 'returns true in fixes state when edition allows fixes' do
      project.update_column(:state, 'fixes')
      allow(impulsa_edition).to receive(:allow_fixes?).and_return(true)
      expect(project.fixable?).to be true
    end

    it 'returns false if edition does not allow fixes' do
      project.update_column(:state, 'fixes')
      allow(impulsa_edition).to receive(:allow_fixes?).and_return(false)
      expect(project.fixable?).to be false
    end

    it 'returns false if not in fixes state' do
      allow(impulsa_edition).to receive(:allow_fixes?).and_return(true)
      expect(project.fixable?).to be false
    end

    it 'returns false if resigned' do
      project.update_column(:state, 'resigned')
      expect(project.fixable?).to be false
    end
  end

  describe 'scope' do
    it 'includes exportable scope' do
      expect(ImpulsaProject).to respond_to(:exportable)
    end

    it 'exportable scope includes validated and winner states' do
      # Create new users to avoid uniqueness violation
      validated_user = create(:user, email: "validated_#{SecureRandom.hex(4)}@test.com")
      validated_project = create(:impulsa_project,
                                   impulsa_edition: impulsa_edition,
                                   impulsa_edition_category: impulsa_edition_category,
                                   user: validated_user)
      validated_project.update_column(:state, 'validated')

      winner_user = create(:user, email: "winner_#{SecureRandom.hex(4)}@test.com")
      winner_project = create(:impulsa_project,
                               impulsa_edition: impulsa_edition,
                               impulsa_edition_category: impulsa_edition_category,
                               user: winner_user)
      winner_project.update_column(:state, 'winner')

      exportable = PlebisImpulsa::ImpulsaProject.exportable
      expect(exportable).to include(validated_project)
      expect(exportable).to include(winner_project)
      expect(exportable).not_to include(project) # new state
    end
  end

  describe 'audit trail' do
    it 'creates state transitions' do
      project.save
      expect {
        project.mark_as_spam
      }.to change { project.impulsa_project_state_transitions.count }.by(1)
    end
  end
end
