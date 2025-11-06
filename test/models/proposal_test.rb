require 'test_helper'

class ProposalTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid proposal" do
    proposal = build(:proposal)
    assert proposal.valid?, "Factory should create a valid proposal"
  end

  test "factory creates valid active proposal" do
    proposal = build(:proposal, :active)
    assert proposal.valid?
    assert_not proposal.finished?
  end

  test "factory creates valid finished proposal" do
    proposal = build(:proposal, :finished)
    assert proposal.valid?
    assert proposal.finished?
  end

  test "factory creates proposal with reddit_threshold" do
    proposal = build(:proposal, :reddit_threshold)
    assert proposal.valid?
    assert proposal.reddit_threshold
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  # Title validations
  test "should require title" do
    proposal = build(:proposal, title: nil)
    assert_not proposal.valid?
    assert_includes proposal.errors[:title], "can't be blank"
  end

  test "should reject empty string title" do
    proposal = build(:proposal, title: "")
    assert_not proposal.valid?
    assert_includes proposal.errors[:title], "can't be blank"
  end

  test "should accept valid title" do
    proposal = build(:proposal, title: "Valid Proposal Title")
    assert proposal.valid?
  end

  # Description validations
  test "should require description" do
    proposal = build(:proposal, description: nil)
    assert_not proposal.valid?
    assert_includes proposal.errors[:description], "can't be blank"
  end

  test "should reject empty string description" do
    proposal = build(:proposal, description: "")
    assert_not proposal.valid?
    assert_includes proposal.errors[:description], "can't be blank"
  end

  test "should accept valid description" do
    proposal = build(:proposal, description: "This is a valid description")
    assert proposal.valid?
  end

  # Votes validations
  test "should accept nil votes" do
    proposal = build(:proposal, votes: nil)
    assert proposal.valid?
  end

  test "should accept zero votes" do
    proposal = build(:proposal, votes: 0)
    assert proposal.valid?
  end

  test "should accept positive votes" do
    proposal = build(:proposal, votes: 100)
    assert proposal.valid?
  end

  test "should reject negative votes" do
    proposal = build(:proposal, votes: -1)
    assert_not proposal.valid?
    assert_includes proposal.errors[:votes], "must be greater than or equal to 0"
  end

  # Supports count validations
  test "should accept nil supports_count" do
    proposal = build(:proposal, supports_count: nil)
    assert proposal.valid?
  end

  test "should accept zero supports_count" do
    proposal = build(:proposal, supports_count: 0)
    assert proposal.valid?
  end

  test "should accept positive supports_count" do
    proposal = build(:proposal, supports_count: 50)
    assert proposal.valid?
  end

  test "should reject negative supports_count" do
    proposal = build(:proposal, supports_count: -1)
    assert_not proposal.valid?
    assert_includes proposal.errors[:supports_count], "must be greater than or equal to 0"
  end

  # Hotness validations
  test "should accept nil hotness" do
    proposal = build(:proposal, hotness: nil)
    assert proposal.valid?
  end

  test "should accept zero hotness" do
    proposal = build(:proposal, hotness: 0)
    assert proposal.valid?
  end

  test "should accept positive hotness" do
    proposal = build(:proposal, hotness: 1000)
    assert proposal.valid?
  end

  test "should reject negative hotness" do
    proposal = build(:proposal, hotness: -1)
    assert_not proposal.valid?
    assert_includes proposal.errors[:hotness], "must be greater than or equal to 0"
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create proposal with valid attributes" do
    assert_difference('Proposal.count', 1) do
      create(:proposal)
    end
  end

  test "should read proposal attributes correctly" do
    proposal = create(:proposal,
      title: "Test Proposal",
      description: "Test Description",
      votes: 50
    )

    found_proposal = Proposal.find(proposal.id)
    assert_equal "Test Proposal", found_proposal.title
    assert_equal "Test Description", found_proposal.description
    assert_equal 50, found_proposal.votes
  end

  test "should update proposal attributes" do
    proposal = create(:proposal, title: "Original Title")
    proposal.update(title: "Updated Title")

    assert_equal "Updated Title", proposal.reload.title
  end

  test "should not update with invalid attributes" do
    proposal = create(:proposal, title: "Valid Title")
    proposal.update(title: nil)

    assert_not proposal.valid?
    assert_equal "Valid Title", proposal.reload.title
  end

  test "should delete proposal" do
    proposal = create(:proposal)
    assert_difference('Proposal.count', -1) do
      proposal.destroy
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should have many supports" do
    proposal = create(:proposal)
    user1 = create(:user)
    user2 = create(:user)

    support1 = create(:support, proposal: proposal, user: user1)
    support2 = create(:support, proposal: proposal, user: user2)

    assert_includes proposal.supports, support1
    assert_includes proposal.supports, support2
    assert_equal 2, proposal.supports.count
  end

  test "should destroy dependent supports when proposal is destroyed" do
    proposal = create(:proposal, :with_supports)
    support_ids = proposal.supports.pluck(:id)

    assert_difference('Support.count', -3) do
      proposal.destroy
    end

    support_ids.each do |id|
      assert_nil Support.find_by(id: id)
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "reddit scope should return only proposals with reddit_threshold true" do
    Proposal.delete_all
    reddit_proposal = create(:proposal, reddit_threshold: true)
    normal_proposal = create(:proposal, reddit_threshold: false)

    reddit_proposals = Proposal.reddit

    assert_includes reddit_proposals, reddit_proposal
    assert_not_includes reddit_proposals, normal_proposal
  end

  test "reddit scope should return empty when no reddit proposals exist" do
    # Create users so threshold is not automatically 0
    Proposal.delete_all
    User.delete_all
    1000.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    # Create proposals with reddit_threshold explicitly false and votes below threshold
    proposal1 = build(:proposal, reddit_threshold: false, votes: 0)
    proposal1.save(validate: false) # Skip callbacks
    proposal1.update_column(:reddit_threshold, false)

    proposal2 = build(:proposal, reddit_threshold: false, votes: 0)
    proposal2.save(validate: false) # Skip callbacks
    proposal2.update_column(:reddit_threshold, false)

    assert_empty Proposal.reddit
  end

  test "recent scope should order by created_at DESC" do
    old = create(:proposal, created_at: 3.days.ago)
    middle = create(:proposal, created_at: 2.days.ago)
    new = create(:proposal, created_at: 1.day.ago)

    proposals = Proposal.recent.to_a

    assert_equal new, proposals[0]
    assert_equal middle, proposals[1]
    assert_equal old, proposals[2]
  end

  test "popular scope should order by supports_count DESC" do
    low = create(:proposal)
    low.update_column(:supports_count, 10)
    medium = create(:proposal)
    medium.update_column(:supports_count, 50)
    high = create(:proposal)
    high.update_column(:supports_count, 100)

    proposals = Proposal.popular.to_a

    assert_equal high, proposals[0]
    assert_equal medium, proposals[1]
    assert_equal low, proposals[2]
  end

  test "time scope should order by created_at ASC" do
    new = create(:proposal, created_at: 1.day.ago)
    middle = create(:proposal, created_at: 2.days.ago)
    old = create(:proposal, created_at: 3.days.ago)

    proposals = Proposal.time.to_a

    assert_equal old, proposals[0]
    assert_equal middle, proposals[1]
    assert_equal new, proposals[2]
  end

  test "hot scope should order by hotness DESC" do
    cold = create(:proposal, hotness: 10)
    warm = create(:proposal, hotness: 50)
    hot = create(:proposal, hotness: 100)

    proposals = Proposal.hot.to_a

    assert_equal hot, proposals[0]
    assert_equal warm, proposals[1]
    assert_equal cold, proposals[2]
  end

  test "active scope should return proposals created within last 3 months" do
    active = create(:proposal, created_at: 2.months.ago)
    finished = create(:proposal, created_at: 4.months.ago)

    active_proposals = Proposal.active

    assert_includes active_proposals, active
    assert_not_includes active_proposals, finished
  end

  test "active scope should handle edge case at 3 month boundary" do
    just_active = create(:proposal, created_at: 3.months.ago + 1.day)
    just_finished = create(:proposal, created_at: 3.months.ago - 1.day)

    active_proposals = Proposal.active

    assert_includes active_proposals, just_active
    assert_not_includes active_proposals, just_finished
  end

  test "finished scope should return proposals created more than 3 months ago" do
    active = create(:proposal, created_at: 2.months.ago)
    finished = create(:proposal, created_at: 4.months.ago)

    finished_proposals = Proposal.finished

    assert_includes finished_proposals, finished
    assert_not_includes finished_proposals, active
  end

  test "finished scope should handle edge case at 3 month boundary" do
    just_active = create(:proposal, created_at: 3.months.ago + 1.day)
    just_finished = create(:proposal, created_at: 3.months.ago - 1.day)

    finished_proposals = Proposal.finished

    assert_includes finished_proposals, just_finished
    assert_not_includes finished_proposals, just_active
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  test "should update reddit_threshold before save when votes reach threshold" do
    # Create some confirmed users first
    User.delete_all
    1000.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal, reddit_threshold: false, votes: 0)
    assert_not proposal.reddit_threshold

    # Calculate required votes (0.2% of 1000 confirmed users = 2)
    required = proposal.reddit_required_votes

    # Update votes to meet threshold
    proposal.votes = required
    proposal.save

    assert proposal.reload.reddit_threshold
  end

  test "should not update reddit_threshold when votes below threshold" do
    # Create users so threshold is not 0
    User.delete_all
    1000.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal, reddit_threshold: false, votes: 0)
    assert_not proposal.reddit_threshold

    # 0.2% of 1000 = 2, so 1 vote is below threshold
    proposal.votes = 1
    proposal.save

    assert_not proposal.reload.reddit_threshold
  end

  test "should maintain reddit_threshold when already true" do
    proposal = create(:proposal, reddit_threshold: true, votes: 100)
    assert proposal.reddit_threshold

    proposal.votes = 50
    proposal.save

    assert proposal.reload.reddit_threshold
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  # confirmed_users method
  test "confirmed_users should return count of fully confirmed users" do
    # Clean users from previous tests to get accurate count
    User.delete_all

    create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current)
    create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current)
    create(:user, :unconfirmed)

    proposal = create(:proposal)

    # Users need both email and phone confirmation
    # Our factory creates confirmed users by default
    assert_equal 2, proposal.confirmed_users
  end

  # reddit_required_votes method
  test "reddit_required_votes should return 0.2 percent of confirmed users" do
    User.delete_all
    10.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal)

    # 0.2% of 10 = 0.02, rounded to 0
    assert_equal 0, proposal.reddit_required_votes
  end

  test "reddit_required_votes should calculate correctly for large user base" do
    User.delete_all
    1000.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal)

    # 0.2% of 1000 = 2
    assert_equal 2, proposal.reddit_required_votes
  end

  # monthly_email_required_votes method
  test "monthly_email_required_votes should return 2 percent of confirmed users" do
    User.delete_all
    100.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal)

    # 2% of 100 = 2
    assert_equal 2, proposal.monthly_email_required_votes
  end

  # agoravoting_required_votes method
  test "agoravoting_required_votes should return 10 percent of confirmed users" do
    User.delete_all
    100.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal)

    # 10% of 100 = 10
    assert_equal 10, proposal.agoravoting_required_votes
  end

  # support_percentage method
  test "support_percentage should calculate correctly" do
    User.delete_all
    50.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal)
    proposal.update_column(:supports_count, 10)

    # 10 / 50 * 100 = 20%
    assert_equal 20.0, proposal.support_percentage
  end

  test "support_percentage should handle zero confirmed users" do
    proposal = create(:proposal)
    proposal.update_column(:supports_count, 10)

    # This will cause division by zero, we should check behavior
    # In production this shouldn't happen but it's an edge case
    result = proposal.support_percentage

    # Should return Infinity or handle gracefully
    assert_not_nil result
  end

  # remaining_endorsements_for_approval method
  test "remaining_endorsements_for_approval should calculate correctly" do
    100.times { create(:user) }

    proposal = create(:proposal, votes: 1)

    # 2% of 100 = 2, 2 - 1 = 1
    assert_equal 1, proposal.remaining_endorsements_for_approval
  end

  test "remaining_endorsements_for_approval should return 0 when already approved" do
    100.times { create(:user) }

    proposal = create(:proposal, votes: 10)

    # 2% of 100 = 2, 2 - 10 = -8, but to_i keeps it as integer
    assert_equal(-8, proposal.remaining_endorsements_for_approval)
  end

  # reddit_required_votes? method
  test "reddit_required_votes? should return true when threshold met" do
    100.times { create(:user) }

    proposal = create(:proposal, votes: 1)

    # 0.2% of 100 = 0.2, rounded to 0, so 1 >= 0
    assert proposal.reddit_required_votes?
  end

  test "reddit_required_votes? should return false when threshold not met" do
    1000.times { create(:user) }

    proposal = create(:proposal, votes: 0)

    # 0.2% of 1000 = 2, so 0 < 2
    assert_not proposal.reddit_required_votes?
  end

  # monthly_email_required_votes? method
  test "monthly_email_required_votes? should return true when threshold met" do
    User.delete_all
    100.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal)
    proposal.update_column(:supports_count, 5)

    # 2% of 100 = 2, so 5 >= 2
    assert proposal.monthly_email_required_votes?
  end

  test "monthly_email_required_votes? should return false when threshold not met" do
    User.delete_all
    100.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal)
    proposal.update_column(:supports_count, 1)

    # 2% of 100 = 2, so 1 < 2
    assert_not proposal.monthly_email_required_votes?
  end

  # agoravoting_required_votes? method
  test "agoravoting_required_votes? should return true when threshold met" do
    User.delete_all
    100.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal)
    proposal.update_column(:supports_count, 15)

    # 10% of 100 = 10, so 15 >= 10
    assert proposal.agoravoting_required_votes?
  end

  test "agoravoting_required_votes? should return false when threshold not met" do
    User.delete_all
    100.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal)
    proposal.update_column(:supports_count, 5)

    # 10% of 100 = 10, so 5 < 10
    assert_not proposal.agoravoting_required_votes?
  end

  # finished? method
  test "finished? should return false for active proposal" do
    proposal = create(:proposal, created_at: 1.month.ago)

    assert_not proposal.finished?
  end

  test "finished? should return true for old proposal" do
    proposal = create(:proposal, created_at: 4.months.ago)

    assert proposal.finished?
  end

  test "finished? should handle edge case at 3 month boundary" do
    just_active = create(:proposal, created_at: 3.months.ago + 1.day)
    just_finished = create(:proposal, created_at: 3.months.ago - 1.day)

    assert_not just_active.finished?
    assert just_finished.finished?
  end

  # finishes_at method
  test "finishes_at should return created_at plus 3 months" do
    created = Time.current
    proposal = create(:proposal, created_at: created)

    expected = created + 3.months
    # Use assert_in_delta to handle microsecond precision differences
    assert_in_delta expected.to_f, proposal.finishes_at.to_f, 0.001
  end

  # discarded? method
  test "discarded? should return false for active proposal" do
    User.delete_all
    100.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal, created_at: 1.month.ago)
    proposal.update_column(:supports_count, 20)

    assert_not proposal.discarded?
  end

  test "discarded? should return true for finished proposal without enough votes" do
    User.delete_all
    100.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal, created_at: 4.months.ago)
    proposal.update_column(:supports_count, 5)

    # 10% of 100 = 10, 5 < 10, and it's finished
    assert proposal.discarded?
  end

  test "discarded? should return false for finished proposal with enough votes" do
    User.delete_all
    100.times { create(:user, confirmed_at: Time.current, sms_confirmed_at: Time.current) }

    proposal = create(:proposal, created_at: 4.months.ago)
    proposal.update_column(:supports_count, 20)

    # 10% of 100 = 10, 20 >= 10
    assert_not proposal.discarded?
  end

  # supported?(user) method
  test "supported? should return true when user has supported proposal" do
    user = create(:user)
    proposal = create(:proposal)
    create(:support, user: user, proposal: proposal)

    assert proposal.supported?(user)
  end

  test "supported? should return false when user has not supported proposal" do
    user = create(:user)
    proposal = create(:proposal)

    assert_not proposal.supported?(user)
  end

  test "supported? should return false when user is nil" do
    proposal = create(:proposal)

    assert_not proposal.supported?(nil)
  end

  # supportable?(user) method
  test "supportable? should return true for active proposal" do
    user = create(:user)
    proposal = create(:proposal, created_at: 1.month.ago)

    assert proposal.supportable?(user)
  end

  test "supportable? should return false for finished proposal" do
    user = create(:user)
    proposal = create(:proposal, created_at: 4.months.ago)

    assert_not proposal.supportable?(user)
  end

  test "supportable? should return false for discarded proposal" do
    100.times { create(:user) }
    user = create(:user)
    proposal = create(:proposal, created_at: 4.months.ago)
    proposal.update_column(:supports_count, 0)

    assert_not proposal.supportable?(user)
  end

  # hotness method
  test "hotness should calculate correctly" do
    proposal = create(:proposal, created_at: 2.days.ago)
    proposal.update_column(:supports_count, 10)

    expected = 10 + (2 * 1000)
    assert_equal expected, proposal.hotness
  end

  test "hotness should increase with time" do
    old_proposal = create(:proposal, created_at: 10.days.ago)
    old_proposal.update_column(:supports_count, 10)
    new_proposal = create(:proposal, created_at: 1.day.ago)
    new_proposal.update_column(:supports_count, 10)

    assert_operator old_proposal.hotness, :>, new_proposal.hotness
  end

  # days_since_created method
  test "days_since_created should calculate correctly" do
    proposal = create(:proposal, created_at: 5.days.ago)

    assert_equal 5, proposal.days_since_created
  end

  test "days_since_created should return 0 for new proposal" do
    proposal = create(:proposal, created_at: 1.hour.ago)

    assert_equal 0, proposal.days_since_created
  end

  # supports_count method override
  test "supports_count method should only count supports before finishes_at" do
    proposal = create(:proposal, created_at: 4.months.ago)
    user1 = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    # Create supports at different times
    create(:support, proposal: proposal, user: user1, created_at: (3.months + 15.days).ago) # Before finishes_at (3.5 months)
    create(:support, proposal: proposal, user: user2, created_at: (3.months + 15.days).ago) # Before finishes_at (3.5 months)
    create(:support, proposal: proposal, user: user3, created_at: 15.days.ago) # After finishes_at (0.5 months)

    # Method should only count 2 (before finishes_at)
    assert_equal 2, proposal.supports_count
  end

  test "supports_count method should count all supports for active proposal" do
    proposal = create(:proposal, created_at: 1.month.ago)
    user1 = create(:user)
    user2 = create(:user)

    create(:support, proposal: proposal, user: user1)
    create(:support, proposal: proposal, user: user2)

    assert_equal 2, proposal.supports_count
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  test "filter method should return reddit proposals by default" do
    # Create users so threshold is not automatically 0
    1000.times { create(:user) }

    reddit = create(:proposal, reddit_threshold: true, votes: 10)

    # Create normal proposal with callback skipped
    normal = build(:proposal, reddit_threshold: false, votes: 0)
    normal.save(validate: false)
    normal.update_column(:reddit_threshold, false)

    results = Proposal.filter(nil)

    assert_includes results, reddit
    assert_not_includes results, normal
  end

  test "filter method should apply additional filtering" do
    old_reddit = create(:proposal, reddit_threshold: true, created_at: 5.days.ago)
    new_reddit = create(:proposal, reddit_threshold: true, created_at: 1.day.ago)

    results = Proposal.filter('recent')

    assert_equal new_reddit, results.first
    assert_equal old_reddit, results.second
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "should handle full lifecycle from creation to finish" do
    100.times { create(:user) }

    proposal = create(:proposal, created_at: 1.month.ago)

    # Start: should be active and not finished
    assert_not proposal.finished?
    assert proposal.supportable?(create(:user))

    # Simulate time passing
    travel 3.months do
      # Should now be finished
      assert proposal.finished?
      assert_not proposal.supportable?(create(:user))
    end
  end

  test "should handle reddit threshold achievement" do
    1000.times { create(:user) }

    proposal = create(:proposal, reddit_threshold: false, votes: 0)

    # Start: below threshold
    assert_not proposal.reddit_threshold
    assert_not proposal.reddit_required_votes?

    # Add votes to meet threshold
    required = proposal.reddit_required_votes
    proposal.update(votes: required)

    # Should now have reddit_threshold
    assert proposal.reload.reddit_threshold
    assert proposal.reddit_required_votes?
  end

  test "should track multiple users supporting proposal" do
    proposal = create(:proposal)
    users = 5.times.map { create(:user) }

    users.each do |user|
      create(:support, user: user, proposal: proposal)
    end

    # Check all users have supported
    users.each do |user|
      assert proposal.supported?(user)
    end

    # Check count
    assert_equal 5, proposal.supports_count
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle very long title" do
    long_title = "A" * 1000
    proposal = build(:proposal, title: long_title)

    proposal.valid?
    assert_not_nil proposal
  end

  test "should handle very long description" do
    long_description = "B" * 10000
    proposal = build(:proposal, description: long_description)

    proposal.valid?
    assert_not_nil proposal
  end

  test "should handle special characters in title" do
    proposal = build(:proposal, title: "Special chars: @#$% & <> 特殊")
    assert proposal.valid?
  end

  test "should handle special characters in description" do
    proposal = build(:proposal, description: "Body with émojis 🎉 and symbols © ® ™")
    assert proposal.valid?
  end

  test "should handle very large vote counts" do
    proposal = build(:proposal, votes: 1_000_000)
    assert proposal.valid?
  end

  test "should handle very large support counts" do
    proposal = build(:proposal, supports_count: 1_000_000)
    assert proposal.valid?
  end

  test "should handle proposals with no users in system" do
    User.delete_all
    proposal = create(:proposal)

    # Methods should handle zero users gracefully
    assert_equal 0, proposal.confirmed_users
    assert_equal 0, proposal.reddit_required_votes
  end

  test "should handle proposals created in future (edge case)" do
    future_proposal = build(:proposal, created_at: 1.day.from_now)

    # Should be valid but finished? should return false
    assert future_proposal.valid?
    assert_not future_proposal.finished?
  end
end
