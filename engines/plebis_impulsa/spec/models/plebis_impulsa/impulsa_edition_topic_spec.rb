# frozen_string_literal: true

require 'rails_helper'

module PlebisImpulsa
  RSpec.describe ImpulsaEditionTopic, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:impulsa_edition).class_name('PlebisImpulsa::ImpulsaEdition') }
      it { is_expected.to have_many(:impulsa_project_topics).class_name('PlebisImpulsa::ImpulsaProjectTopic').dependent(:restrict_with_error) }
      it { is_expected.to have_many(:impulsa_projects).through(:impulsa_project_topics).class_name('PlebisImpulsa::ImpulsaProject') }
    end

    describe 'table name' do
      it 'uses impulsa_edition_topics table' do
        expect(ImpulsaEditionTopic.table_name).to eq('impulsa_edition_topics')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        topic = build(:impulsa_edition_topic)
        expect(topic).to be_valid
      end

      it 'creates a topic with all required attributes' do
        topic = create(:impulsa_edition_topic)
        expect(topic).to be_persisted
        expect(topic.impulsa_edition).to be_present
        expect(topic.name).to be_present
      end
    end
  end
end
