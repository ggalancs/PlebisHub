require "test_helper"

class ElectionLocationQuestionTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid election_location_question" do
    question = build(:election_location_question)
    assert question.valid?, "Factory should create valid question. Errors: #{question.errors.full_messages.join(', ')}"
  end

  test "factory with pairwise trait creates valid question" do
    question = build(:election_location_question, :pairwise)
    assert question.valid?, "Factory with pairwise trait should be valid. Errors: #{question.errors.full_messages.join(', ')}"
    assert_equal "pairwise-beta", question.voting_system
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should belong to election_location" do
    question = create(:election_location_question)
    assert_respond_to question, :election_location
    assert_kind_of ElectionLocation, question.election_location
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should require title" do
    question = build(:election_location_question, title: nil)
    assert_not question.valid?
    assert_includes question.errors[:title], "can't be blank"
  end

  test "should require voting_system" do
    question = build(:election_location_question, voting_system: nil)
    assert_not question.valid?
    assert_includes question.errors[:voting_system], "can't be blank"
  end

  test "should require winners" do
    question = build(:election_location_question, winners: nil)
    assert_not question.valid?
    assert_includes question.errors[:winners], "can't be blank"
  end

  test "should require minimum" do
    question = build(:election_location_question, minimum: nil)
    assert_not question.valid?
    assert_includes question.errors[:minimum], "can't be blank"
  end

  test "should require maximum" do
    question = build(:election_location_question, maximum: nil)
    assert_not question.valid?
    assert_includes question.errors[:maximum], "can't be blank"
  end

  test "should require totals" do
    question = build(:election_location_question, totals: nil)
    assert_not question.valid?
    assert_includes question.errors[:totals], "can't be blank"
  end

  test "should require options" do
    question = build(:election_location_question)
    question[:options] = nil  # Set directly to avoid getter calling headers.keys
    assert_not question.valid?
    assert_includes question.errors[:options], "can't be blank"
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  test "after_initialize should set defaults when title is blank" do
    question = ElectionLocationQuestion.new
    assert_equal ElectionLocationQuestion::VOTING_SYSTEMS.keys.first, question.voting_system
    assert_equal ElectionLocationQuestion::TOTALS.keys.first, question.totals
    assert_equal true, question.random_order
    assert_equal 1, question.winners
    assert_equal 0, question.minimum
    assert_equal 1, question.maximum
  end

  test "after_initialize should not override when title is present" do
    question = ElectionLocationQuestion.new(title: "Test", voting_system: "pairwise-beta", winners: 5)
    assert_equal "Test", question.title
    assert_equal "pairwise-beta", question.voting_system
    assert_equal 5, question.winners
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  test "layout should return simple for pairwise-beta voting system" do
    election_location = build(:election_location, layout: "pcandidates-election")
    question = build(:election_location_question, :pairwise, election_location: election_location)
    assert_equal "simple", question.layout
  end

  test "layout should return empty string for election layouts" do
    election_location = build(:election_location, layout: "pcandidates-election")
    question = build(:election_location_question, election_location: election_location, voting_system: "plurality-at-large")
    assert_equal "", question.layout
  end

  test "layout should return election_location layout for non-election layouts" do
    election_location = build(:election_location, layout: "simple")
    question = build(:election_location_question, election_location: election_location, voting_system: "plurality-at-large")
    assert_equal "simple", question.layout
  end

  test "options_headers should return array split by tab" do
    question = build(:election_location_question)
    question[:options_headers] = "Text\tImage\tURL"
    assert_equal ["Text", "Image", "URL"], question.options_headers
  end

  test "options_headers should return default when nil" do
    skip "Requires Rails.application.secrets.agora['options_headers'] configuration"
    # This would test: question[:options_headers] = nil; question.options_headers
    # But Rails secrets not configured in test environment
  end

  test "options_headers= should set tab-separated string from array" do
    question = build(:election_location_question)
    question.options_headers = ["Name", "Description", "URL"]
    assert_equal "Name\tDescription\tURL", question[:options_headers]
  end

  test "options_headers= should filter empty values" do
    question = build(:election_location_question)
    question.options_headers = ["Name", "", "URL", nil]
    assert_equal "Name\tURL", question[:options_headers]
  end

  test "options= should process multi-line tab-separated options" do
    question = build(:election_location_question)
    question.options_headers = ["Text", "URL"]
    question.options = "Option 1\thttp://example.com/1\nOption 2\thttp://example.com/2"

    expected = "Option 1\thttp://example.com/1\nOption 2\thttp://example.com/2"
    assert_equal expected, question[:options]
  end

  test "options= should strip whitespace from options" do
    question = build(:election_location_question)
    question.options_headers = ["Text"]
    question.options = "  Option 1  \n  Option 2  \n"

    expected = "Option 1\nOption 2"
    assert_equal expected, question[:options]
  end

  test "options= should handle empty lines" do
    question = build(:election_location_question)
    question.options_headers = ["Text"]
    question.options = "Option 1\n\nOption 2\n\n"

    expected = "Option 1\nOption 2"
    assert_equal expected, question[:options]
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  test "headers class method should return agora options headers" do
    skip "Requires Rails.application.secrets.agora configuration"
    # This depends on test environment secrets configuration
    headers = ElectionLocationQuestion.headers
    assert_kind_of Hash, headers
  end

  # ====================
  # CONSTANTS TESTS
  # ====================

  test "VOTING_SYSTEMS constant should be defined" do
    assert_kind_of Hash, ElectionLocationQuestion::VOTING_SYSTEMS
    assert_includes ElectionLocationQuestion::VOTING_SYSTEMS.keys, "plurality-at-large"
    assert_includes ElectionLocationQuestion::VOTING_SYSTEMS.keys, "pairwise-beta"
  end

  test "TOTALS constant should be defined" do
    assert_kind_of Hash, ElectionLocationQuestion::TOTALS
    assert_includes ElectionLocationQuestion::TOTALS.keys, "over-total-valid-votes"
  end
end
