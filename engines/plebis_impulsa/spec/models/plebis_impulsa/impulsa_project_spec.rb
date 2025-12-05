# frozen_string_literal: true

require 'rails_helper'

module PlebisImpulsa
  RSpec.describe ImpulsaProject, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:impulsa_edition_category).class_name('PlebisImpulsa::ImpulsaEditionCategory') }
      it { is_expected.to belong_to(:user) }
      it { is_expected.to have_one(:impulsa_edition).through(:impulsa_edition_category) }
      it { is_expected.to have_many(:impulsa_project_state_transitions).class_name('PlebisImpulsa::ImpulsaProjectStateTransition').dependent(:destroy) }
      it { is_expected.to have_many(:impulsa_project_topics).class_name('PlebisImpulsa::ImpulsaProjectTopic').dependent(:destroy) }
    end

    describe 'validations' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:status) }
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
    end

    describe 'table name' do
      it 'uses impulsa_projects table' do
        expect(ImpulsaProject.table_name).to eq('impulsa_projects')
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
  end
end
