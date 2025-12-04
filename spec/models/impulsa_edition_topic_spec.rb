# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpulsaEditionTopic, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid impulsa_edition_topic' do
      topic = build(:impulsa_edition_topic)
      expect(topic).to be_valid, 'Factory should create a valid impulsa_edition_topic'
    end

    it 'creates topic with associations' do
      topic = create(:impulsa_edition_topic)
      expect(topic.impulsa_edition).not_to be_nil
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates topic with valid attributes' do
      expect do
        create(:impulsa_edition_topic)
      end.to change(ImpulsaEditionTopic, :count).by(1)
    end

    it 'reads topic attributes correctly' do
      edition = create(:impulsa_edition)
      topic = create(:impulsa_edition_topic,
                     impulsa_edition: edition,
                     name: 'Test Topic')

      found_topic = ImpulsaEditionTopic.find(topic.id)
      expect(found_topic.name).to eq('Test Topic')
      expect(found_topic.impulsa_edition_id).to eq(edition.id)
    end

    it 'updates topic attributes' do
      topic = create(:impulsa_edition_topic, name: 'Original Name')
      topic.update(name: 'Updated Name')

      expect(topic.reload.name).to eq('Updated Name')
    end

    it 'deletes topic' do
      topic = create(:impulsa_edition_topic)

      expect do
        topic.destroy
      end.to change(ImpulsaEditionTopic, :count).by(-1)
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to impulsa_edition' do
      topic = create(:impulsa_edition_topic)
      expect(topic).to respond_to(:impulsa_edition)
      expect(topic.impulsa_edition).to be_a(ImpulsaEdition)
    end

    it 'has many impulsa_projects' do
      topic = create(:impulsa_edition_topic)
      expect(topic).to respond_to(:impulsa_projects)
    end

    it 'does not allow nil impulsa_edition_id' do
      topic = build(:impulsa_edition_topic, impulsa_edition: nil)
      # belongs_to requires the association by default in Rails
      expect(topic).not_to be_valid
    end

    it 'allows nil name' do
      topic = build(:impulsa_edition_topic, name: nil)
      # No validation on name, so it should be valid
      expect(topic).to be_valid
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles empty string name' do
      topic = build(:impulsa_edition_topic, name: '')
      expect(topic).to be_valid
    end

    it 'handles very long name' do
      long_name = 'A' * 1000
      topic = build(:impulsa_edition_topic, name: long_name)
      expect(topic).to be_valid
    end

    it 'handles special characters in name' do
      topic = build(:impulsa_edition_topic, name: 'Special chars: @#$% & <> 特殊')
      expect(topic).to be_valid
    end

    it 'handles unicode in name' do
      topic = build(:impulsa_edition_topic, name: 'Tópico con émojis 🎉 y símbolos')
      expect(topic).to be_valid
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'creates multiple topics for same edition' do
      edition = create(:impulsa_edition)

      topic1 = create(:impulsa_edition_topic, impulsa_edition: edition, name: 'Topic 1')
      topic2 = create(:impulsa_edition_topic, impulsa_edition: edition, name: 'Topic 2')
      topic3 = create(:impulsa_edition_topic, impulsa_edition: edition, name: 'Topic 3')

      expect(edition.impulsa_edition_topics.count).to eq(3)
      expect(edition.impulsa_edition_topics).to include(topic1)
      expect(edition.impulsa_edition_topics).to include(topic2)
      expect(edition.impulsa_edition_topics).to include(topic3)
    end

    it 'creates topics for different editions' do
      edition1 = create(:impulsa_edition)
      edition2 = create(:impulsa_edition)

      create(:impulsa_edition_topic, impulsa_edition: edition1)
      create(:impulsa_edition_topic, impulsa_edition: edition2)

      expect(edition1.impulsa_edition_topics.count).to eq(1)
      expect(edition2.impulsa_edition_topics.count).to eq(1)
    end

    it 'allows duplicate topic names within same edition' do
      edition = create(:impulsa_edition)

      create(:impulsa_edition_topic, impulsa_edition: edition, name: 'Duplicate')
      topic2 = build(:impulsa_edition_topic, impulsa_edition: edition, name: 'Duplicate')

      # No uniqueness validation, so it should be valid
      expect(topic2).to be_valid
    end

    it 'allows duplicate topic names across editions' do
      edition1 = create(:impulsa_edition)
      edition2 = create(:impulsa_edition)

      create(:impulsa_edition_topic, impulsa_edition: edition1, name: 'Same Name')
      topic2 = build(:impulsa_edition_topic, impulsa_edition: edition2, name: 'Same Name')

      expect(topic2).to be_valid
    end

    it 'maintains topic when edition is deleted' do
      edition = create(:impulsa_edition)
      topic = create(:impulsa_edition_topic, impulsa_edition: edition)

      topic_id = topic.id

      # Cannot delete edition with associated topics due to foreign key constraint
      expect { edition.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)

      # Topic should still exist after failed deletion attempt
      remaining_topic = ImpulsaEditionTopic.find_by(id: topic_id)
      expect(remaining_topic).not_to be_nil, 'Topic should still exist after edition deletion fails'
    end
  end
end
