require 'test_helper'

class ImpulsaEditionTopicTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid impulsa_edition_topic" do
    topic = build(:impulsa_edition_topic)
    assert topic.valid?, "Factory should create a valid impulsa_edition_topic"
  end

  test "factory creates topic with associations" do
    topic = create(:impulsa_edition_topic)
    assert_not_nil topic.impulsa_edition
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create topic with valid attributes" do
    assert_difference('ImpulsaEditionTopic.count', 1) do
      create(:impulsa_edition_topic)
    end
  end

  test "should read topic attributes correctly" do
    edition = create(:impulsa_edition)
    topic = create(:impulsa_edition_topic,
      impulsa_edition: edition,
      name: "Test Topic"
    )

    found_topic = ImpulsaEditionTopic.find(topic.id)
    assert_equal "Test Topic", found_topic.name
    assert_equal edition.id, found_topic.impulsa_edition_id
  end

  test "should update topic attributes" do
    topic = create(:impulsa_edition_topic, name: "Original Name")
    topic.update(name: "Updated Name")

    assert_equal "Updated Name", topic.reload.name
  end

  test "should delete topic" do
    topic = create(:impulsa_edition_topic)

    assert_difference('ImpulsaEditionTopic.count', -1) do
      topic.destroy
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should belong to impulsa_edition" do
    topic = create(:impulsa_edition_topic)
    assert_respond_to topic, :impulsa_edition
    assert_instance_of ImpulsaEdition, topic.impulsa_edition
  end

  test "should have many impulsa_projects" do
    topic = create(:impulsa_edition_topic)
    assert_respond_to topic, :impulsa_projects
  end

  test "should not allow nil impulsa_edition_id" do
    topic = build(:impulsa_edition_topic, impulsa_edition: nil)
    # belongs_to requires the association by default in Rails
    assert_not topic.valid?
  end

  test "should allow nil name" do
    topic = build(:impulsa_edition_topic, name: nil)
    # No validation on name, so it should be valid
    assert topic.valid?
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle empty string name" do
    topic = build(:impulsa_edition_topic, name: "")
    assert topic.valid?
  end

  test "should handle very long name" do
    long_name = "A" * 1000
    topic = build(:impulsa_edition_topic, name: long_name)
    assert topic.valid?
  end

  test "should handle special characters in name" do
    topic = build(:impulsa_edition_topic, name: "Special chars: @#$% & <> 特殊")
    assert topic.valid?
  end

  test "should handle unicode in name" do
    topic = build(:impulsa_edition_topic, name: "Tópico con émojis 🎉 y símbolos")
    assert topic.valid?
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "should create multiple topics for same edition" do
    edition = create(:impulsa_edition)

    topic1 = create(:impulsa_edition_topic, impulsa_edition: edition, name: "Topic 1")
    topic2 = create(:impulsa_edition_topic, impulsa_edition: edition, name: "Topic 2")
    topic3 = create(:impulsa_edition_topic, impulsa_edition: edition, name: "Topic 3")

    assert_equal 3, edition.impulsa_edition_topics.count
    assert_includes edition.impulsa_edition_topics, topic1
    assert_includes edition.impulsa_edition_topics, topic2
    assert_includes edition.impulsa_edition_topics, topic3
  end

  test "should create topics for different editions" do
    edition1 = create(:impulsa_edition)
    edition2 = create(:impulsa_edition)

    topic1 = create(:impulsa_edition_topic, impulsa_edition: edition1)
    topic2 = create(:impulsa_edition_topic, impulsa_edition: edition2)

    assert_equal 1, edition1.impulsa_edition_topics.count
    assert_equal 1, edition2.impulsa_edition_topics.count
  end

  test "should allow duplicate topic names within same edition" do
    edition = create(:impulsa_edition)

    topic1 = create(:impulsa_edition_topic, impulsa_edition: edition, name: "Duplicate")
    topic2 = build(:impulsa_edition_topic, impulsa_edition: edition, name: "Duplicate")

    # No uniqueness validation, so it should be valid
    assert topic2.valid?
  end

  test "should allow duplicate topic names across editions" do
    edition1 = create(:impulsa_edition)
    edition2 = create(:impulsa_edition)

    topic1 = create(:impulsa_edition_topic, impulsa_edition: edition1, name: "Same Name")
    topic2 = build(:impulsa_edition_topic, impulsa_edition: edition2, name: "Same Name")

    assert topic2.valid?
  end

  test "should maintain topic when edition is deleted" do
    edition = create(:impulsa_edition)
    topic = create(:impulsa_edition_topic, impulsa_edition: edition)

    topic_id = topic.id
    edition.destroy

    # Topic should still exist (no dependent: :destroy on has_many)
    remaining_topic = ImpulsaEditionTopic.find_by(id: topic_id)
    assert_not_nil remaining_topic, "Topic should still exist after edition is deleted"
  end
end
