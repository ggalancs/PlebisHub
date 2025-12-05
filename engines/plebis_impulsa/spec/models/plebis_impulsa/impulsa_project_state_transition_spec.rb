# frozen_string_literal: true

require 'rails_helper'

module PlebisImpulsa
  RSpec.describe ImpulsaProjectStateTransition, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:impulsa_project).class_name('PlebisImpulsa::ImpulsaProject').inverse_of(:impulsa_project_state_transitions) }
    end

    describe 'table name' do
      it 'uses impulsa_project_state_transitions table' do
        expect(ImpulsaProjectStateTransition.table_name).to eq('impulsa_project_state_transitions')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        transition = build(:impulsa_project_state_transition)
        expect(transition).to be_valid
      end

      it 'creates a transition with all required attributes' do
        transition = create(:impulsa_project_state_transition)
        expect(transition).to be_persisted
        expect(transition.impulsa_project).to be_present
      end
    end
  end
end
