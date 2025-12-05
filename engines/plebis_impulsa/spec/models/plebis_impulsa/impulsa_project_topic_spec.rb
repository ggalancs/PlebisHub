# frozen_string_literal: true

require 'rails_helper'

module PlebisImpulsa
  RSpec.describe ImpulsaProjectTopic, type: :model do
    describe 'associations' do
      it { is_expected.to belong_to(:impulsa_project).class_name('PlebisImpulsa::ImpulsaProject') }
      it { is_expected.to belong_to(:impulsa_edition_topic).class_name('PlebisImpulsa::ImpulsaEditionTopic') }

      it 'has working impulsa_project association' do
        project = create(:impulsa_project)
        topic = create(:impulsa_edition_topic)
        project_topic = create(:impulsa_project_topic, impulsa_project: project, impulsa_edition_topic: topic)
        expect(project_topic.impulsa_project).to eq(project)
      end

      it 'has working impulsa_edition_topic association' do
        topic = create(:impulsa_edition_topic)
        project_topic = create(:impulsa_project_topic, impulsa_edition_topic: topic)
        expect(project_topic.impulsa_edition_topic).to eq(topic)
      end
    end

    describe '#slug' do
      it 'returns parameterized edition topic name when present' do
        edition_topic = create(:impulsa_edition_topic, name: 'Test Topic Name')
        project_topic = create(:impulsa_project_topic, impulsa_edition_topic: edition_topic)
        expect(project_topic.slug).to eq('test-topic-name')
      end

      it 'handles special characters in topic name' do
        edition_topic = create(:impulsa_edition_topic, name: 'Tópico Español & Ñoño!')
        project_topic = create(:impulsa_project_topic, impulsa_edition_topic: edition_topic)
        expect(project_topic.slug).to match(/topico.*espanol/)
      end

      it 'returns fallback slug when edition topic has no name' do
        edition_topic = create(:impulsa_edition_topic)
        allow(edition_topic).to receive(:name).and_return(nil)
        project_topic = create(:impulsa_project_topic, impulsa_edition_topic: edition_topic)
        expect(project_topic.slug).to match(/topic-\d+/)
      end

      it 'returns fallback slug when edition topic is nil' do
        project_topic = build(:impulsa_project_topic)
        allow(project_topic).to receive(:impulsa_edition_topic).and_return(nil)
        expect(project_topic.slug).to match(/topic-/)
      end
    end

    describe 'table name' do
      it 'uses impulsa_project_topics table' do
        expect(ImpulsaProjectTopic.table_name).to eq('impulsa_project_topics')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        project_topic = build(:impulsa_project_topic)
        expect(project_topic).to be_valid
      end

      it 'creates a project topic with all required attributes' do
        project_topic = create(:impulsa_project_topic)
        expect(project_topic).to be_persisted
        expect(project_topic.impulsa_project).to be_present
        expect(project_topic.impulsa_edition_topic).to be_present
      end
    end
  end
end
