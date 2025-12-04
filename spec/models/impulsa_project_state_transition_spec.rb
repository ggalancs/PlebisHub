# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaProjectStateTransition, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid impulsa_project_state_transition' do
      transition = build(:impulsa_project_state_transition)
      expect(transition).to be_valid, 'Factory should create a valid impulsa_project_state_transition'
    end

    it 'creates transition with attributes' do
      transition = create(:impulsa_project_state_transition)
      expect(transition.impulsa_project).not_to be_nil
      expect(transition.namespace).not_to be_nil
      expect(transition.event).not_to be_nil
      expect(transition.from).not_to be_nil
      expect(transition.to).not_to be_nil
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'requires impulsa_project' do
      transition = build(:impulsa_project_state_transition, impulsa_project: nil)
      expect(transition).not_to be_valid
      expect(transition.errors[:impulsa_project]).to include('must exist')
    end

    it 'allows transition without namespace' do
      transition = build(:impulsa_project_state_transition, namespace: nil)
      # No validation in model
      expect(transition).to be_valid
    end

    it 'allows transition without event' do
      transition = build(:impulsa_project_state_transition, event: nil)
      expect(transition).to be_valid
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates impulsa_project_state_transition with valid attributes' do
      # Creating an ImpulsaProject automatically creates an initial state transition
      # So we expect 2 transitions: 1 from project creation + 1 explicit
      expect do
        create(:impulsa_project_state_transition)
      end.to change(ImpulsaProjectStateTransition, :count).by(2)
    end

    it 'reads impulsa_project_state_transition attributes correctly' do
      project = create(:impulsa_project)
      transition = create(:impulsa_project_state_transition,
                          impulsa_project: project,
                          namespace: 'test_namespace',
                          event: 'test_event',
                          from: 'state_a',
                          to: 'state_b')

      found_transition = ImpulsaProjectStateTransition.find(transition.id)
      expect(found_transition.impulsa_project_id).to eq(project.id)
      expect(found_transition.namespace).to eq('test_namespace')
      expect(found_transition.event).to eq('test_event')
      expect(found_transition.from).to eq('state_a')
      expect(found_transition.to).to eq('state_b')
    end

    it 'updates impulsa_project_state_transition attributes' do
      transition = create(:impulsa_project_state_transition, event: 'original')

      transition.update(event: 'updated')

      expect(transition.reload.event).to eq('updated')
    end

    it 'deletes impulsa_project_state_transition' do
      transition = create(:impulsa_project_state_transition)

      expect do
        transition.destroy
      end.to change(ImpulsaProjectStateTransition, :count).by(-1)
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to impulsa_project' do
      transition = create(:impulsa_project_state_transition)
      expect(transition).to respond_to(:impulsa_project)
      expect(transition.impulsa_project).to be_a(ImpulsaProject)
    end

    it 'is associated with impulsa_project' do
      project = create(:impulsa_project)
      transition = create(:impulsa_project_state_transition, impulsa_project: project)

      expect(project.impulsa_project_state_transitions).to include(transition)
    end

    it 'allows multiple transitions for same project' do
      project = create(:impulsa_project)
      initial_count = project.impulsa_project_state_transitions.count

      transition1 = create(:impulsa_project_state_transition,
                           impulsa_project: project,
                           from: 'draft',
                           to: 'submitted')

      transition2 = create(:impulsa_project_state_transition,
                           impulsa_project: project,
                           from: 'submitted',
                           to: 'approved')

      expect(project.impulsa_project_state_transitions.count).to eq(initial_count + 2)
      expect(project.impulsa_project_state_transitions).to include(transition1)
      expect(project.impulsa_project_state_transitions).to include(transition2)
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles empty string values' do
      transition = build(:impulsa_project_state_transition,
                         namespace: '',
                         event: '',
                         from: '',
                         to: '')
      expect(transition).to be_valid
    end

    it 'handles very long strings' do
      transition = build(:impulsa_project_state_transition,
                         namespace: 'A' * 1000,
                         event: 'B' * 1000,
                         from: 'C' * 1000,
                         to: 'D' * 1000)
      expect(transition).to be_valid
    end

    it 'handles special characters' do
      transition = build(:impulsa_project_state_transition,
                         event: 'submit@v2.0',
                         from: 'draft-pending',
                         to: 'submitted_for_review')
      expect(transition).to be_valid
    end

    it 'handles unicode characters' do
      transition = build(:impulsa_project_state_transition,
                         event: '提交',
                         from: '草稿',
                         to: '已提交')
      expect(transition).to be_valid
    end
  end

  # ====================
  # WORKFLOW TESTS
  # ====================

  describe 'workflow' do
    it 'tracks state transition history' do
      project = create(:impulsa_project)
      initial_count = project.impulsa_project_state_transitions.count

      # Create transition sequence
      create(:impulsa_project_state_transition,
             impulsa_project: project,
             from: 'draft',
             to: 'submitted',
             event: 'submit')

      create(:impulsa_project_state_transition,
             impulsa_project: project,
             from: 'submitted',
             to: 'under_review',
             event: 'review')

      create(:impulsa_project_state_transition,
             impulsa_project: project,
             from: 'under_review',
             to: 'approved',
             event: 'approve')

      transitions = project.impulsa_project_state_transitions.order(created_at: :asc)

      expect(transitions.count).to eq(initial_count + 3)
      # Check the last 3 transitions (our explicit ones)
      last_three = transitions.last(3)
      expect(last_three.map(&:from)).to eq(%w[draft submitted under_review])
      expect(last_three.map(&:to)).to eq(%w[submitted under_review approved])
    end

    it 'handles backward transitions (rollbacks)' do
      project = create(:impulsa_project)
      initial_count = project.impulsa_project_state_transitions.count

      create(:impulsa_project_state_transition,
             impulsa_project: project,
             from: 'draft',
             to: 'submitted')

      create(:impulsa_project_state_transition,
             impulsa_project: project,
             from: 'submitted',
             to: 'draft',
             event: 'rollback')

      expect(project.impulsa_project_state_transitions.count).to eq(initial_count + 2)
    end

    it 'maintains chronological order with created_at' do
      project = create(:impulsa_project)

      t1 = create(:impulsa_project_state_transition, impulsa_project: project, from: 'a', to: 'b')
      sleep 0.01
      t2 = create(:impulsa_project_state_transition, impulsa_project: project, from: 'b', to: 'c')
      sleep 0.01
      t3 = create(:impulsa_project_state_transition, impulsa_project: project, from: 'c', to: 'd')

      ordered = project.impulsa_project_state_transitions.order(created_at: :asc)

      # Check that our 3 transitions are in the correct order (last 3)
      last_three_ids = ordered.last(3).map(&:id)
      expect(last_three_ids).to eq([t1.id, t2.id, t3.id])
    end
  end

  # ====================
  # QUERY TESTS
  # ====================

  describe 'queries' do
    it 'finds transitions by event' do
      project = create(:impulsa_project)

      submit_transition = create(:impulsa_project_state_transition,
                                 impulsa_project: project,
                                 event: 'submit')

      approve_transition = create(:impulsa_project_state_transition,
                                  impulsa_project: project,
                                  event: 'approve')

      found = ImpulsaProjectStateTransition.where(event: 'submit')

      expect(found).to include(submit_transition)
      expect(found).not_to include(approve_transition)
    end

    it 'finds transitions by from state' do
      project = create(:impulsa_project)

      transition1 = create(:impulsa_project_state_transition,
                           impulsa_project: project,
                           from: 'draft')

      transition2 = create(:impulsa_project_state_transition,
                           impulsa_project: project,
                           from: 'submitted')

      found = ImpulsaProjectStateTransition.where(from: 'draft')

      expect(found).to include(transition1)
      expect(found).not_to include(transition2)
    end

    it 'counts transitions per project' do
      project1 = create(:impulsa_project)
      project2 = create(:impulsa_project)

      initial_count1 = project1.impulsa_project_state_transitions.count
      initial_count2 = project2.impulsa_project_state_transitions.count

      3.times { create(:impulsa_project_state_transition, impulsa_project: project1) }
      2.times { create(:impulsa_project_state_transition, impulsa_project: project2) }

      expect(project1.impulsa_project_state_transitions.count).to eq(initial_count1 + 3)
      expect(project2.impulsa_project_state_transitions.count).to eq(initial_count2 + 2)
    end
  end
end
