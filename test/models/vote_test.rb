# frozen_string_literal: true

require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "should create vote from factory" do
    vote = build(:vote)
    assert vote.save
    assert_not_nil vote.user
    assert_not_nil vote.election
    assert_not_nil vote.paper_authority
  end

  test "should create deleted vote" do
    vote = create(:vote, :deleted)
    assert_not_nil vote.deleted_at
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should require user_id" do
    vote = build(:vote, user: nil)
    assert_not vote.valid?
    assert_includes vote.errors[:user_id], "can't be blank"
  end

  test "should require election_id" do
    vote = build(:vote, election: nil)
    assert_not vote.valid?
    assert_includes vote.errors[:election_id], "can't be blank"
  end

  test "should require voter_id" do
    vote = build(:vote)
    vote.voter_id = nil
    assert_not vote.valid?
    assert_includes vote.errors[:voter_id], "can't be blank"
  end

  test "should validate uniqueness of voter_id scoped to user_id" do
    user = create(:user)
    election = create(:election)
    vote1 = create(:vote, user: user, election: election)

    vote2 = build(:vote, user: user, election: election)
    vote2.voter_id = vote1.voter_id

    assert_not vote2.valid?
    assert_includes vote2.errors[:voter_id], "has already been taken"
  end

  test "should allow same voter_id for different users" do
    election = create(:election)
    user1 = create(:user)
    user2 = create(:user)

    vote1 = create(:vote, user: user1, election: election)
    vote2 = build(:vote, user: user2, election: election)
    vote2.voter_id = vote1.voter_id

    assert vote2.valid?
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  test "should generate voter_id on create" do
    vote = build(:vote)
    vote.voter_id = nil

    assert vote.save
    assert_not_nil vote.voter_id
    assert vote.voter_id.length > 0
  end

  test "should generate agora_id on create" do
    vote = create(:vote)
    assert_not_nil vote.agora_id
  end

  test "should not regenerate voter_id on update" do
    vote = create(:vote)
    original_voter_id = vote.voter_id

    vote.update(created_at: 1.hour.ago)

    assert_equal original_voter_id, vote.reload.voter_id
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create vote" do
    assert_difference('Vote.count', 1) do
      create(:vote)
    end
  end

  test "should read vote" do
    vote = create(:vote)
    found_vote = Vote.find(vote.id)

    assert_equal vote.id, found_vote.id
    assert_equal vote.voter_id, found_vote.voter_id
  end

  test "should update vote" do
    vote = create(:vote)
    new_paper_authority = create(:user)

    vote.update(paper_authority: new_paper_authority)

    assert_equal new_paper_authority.id, vote.reload.paper_authority_id
  end

  test "should soft delete vote" do
    vote = create(:vote)

    assert_difference('Vote.count', -1) do
      vote.destroy
    end

    assert_not_nil vote.reload.deleted_at
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should belong to user" do
    vote = create(:vote)
    assert_respond_to vote, :user
    assert_instance_of User, vote.user
  end

  test "should belong to election" do
    vote = create(:vote)
    assert_respond_to vote, :election
    assert_instance_of Election, vote.election
  end

  test "should belong to paper_authority" do
    vote = create(:vote)
    assert_respond_to vote, :paper_authority
    assert_instance_of User, vote.paper_authority
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  test "generate_voter_id should return SHA256 hash" do
    vote = create(:vote)
    voter_id = vote.generate_voter_id

    assert_not_nil voter_id
    assert_equal 64, voter_id.length # SHA256 hex digest length
    assert_match /^[0-9a-f]+$/, voter_id
  end

  test "generate_voter_id should be consistent" do
    vote = create(:vote)
    voter_id1 = vote.generate_voter_id
    voter_id2 = vote.generate_voter_id

    assert_equal voter_id1, voter_id2
  end

  test "generate_voter_id should use voter_id_template from election" do
    election = create(:election, voter_id_template: '%{user_id}:%{election_id}')
    vote = create(:vote, election: election)
    voter_id = vote.generate_voter_id

    assert_not_nil voter_id
    assert_equal 64, voter_id.length
  end

  test "generate_message should return formatted string" do
    vote = create(:vote)
    message = vote.generate_message

    assert_includes message, vote.voter_id
    assert_includes message, "AuthEvent"
    assert_includes message, vote.scoped_agora_election_id.to_s
    assert_includes message, "vote"
  end

  test "generate_hash should return HMAC hash" do
    vote = create(:vote)
    message = "test_message"
    hash = vote.generate_hash(message)

    assert_not_nil hash
    assert_equal 64, hash.length # SHA256 HMAC hex digest length
    assert_match /^[0-9a-f]+$/, hash
  end

  test "generate_hash should be consistent for same message" do
    vote = create(:vote)
    message = "test_message"
    hash1 = vote.generate_hash(message)
    hash2 = vote.generate_hash(message)

    assert_equal hash1, hash2
  end

  test "scoped_agora_election_id should return election location vote_id" do
    vote = create(:vote)
    agora_id = vote.scoped_agora_election_id

    assert_not_nil agora_id
    assert_kind_of Integer, agora_id
  end

  test "url should return valid booth URL" do
    vote = create(:vote)
    url = vote.url

    assert_not_nil url
    assert_includes url, vote.election.server_url
    assert_includes url, "booth"
    assert_includes url, vote.scoped_agora_election_id.to_s
    assert_includes url, "vote"
  end

  test "url should include HMAC hash and message" do
    vote = create(:vote)
    url = vote.url

    # URL format: server_url/booth/agora_id/vote/hash/message
    parts = url.split('/')

    assert parts.length >= 7
    assert_equal "vote", parts[-3]
  end

  test "test_url should return valid test HMAC URL" do
    vote = create(:vote)
    url = vote.test_url

    assert_not_nil url
    assert_includes url, vote.election.server_url
    assert_includes url, "test_hmac"
  end

  test "test_url should include key, hash and message" do
    vote = create(:vote)
    url = vote.test_url

    # URL format: server_url/test_hmac/key/hash/message
    parts = url.split('/')

    assert parts.length >= 5
    assert_equal "test_hmac", parts[-4]
  end

  # ====================
  # SOFT DELETE (PARANOIA) TESTS
  # ====================

  test "should exclude soft deleted votes from default scope" do
    active_vote = create(:vote)
    deleted_vote = create(:vote, :deleted)

    votes = Vote.all

    assert_includes votes, active_vote
    assert_not_includes votes, deleted_vote
  end

  test "should include soft deleted votes with with_deleted scope" do
    active_vote = create(:vote)
    deleted_vote = create(:vote, :deleted)

    votes = Vote.with_deleted

    assert_includes votes, active_vote
    assert_includes votes, deleted_vote
  end

  test "should restore soft deleted vote" do
    vote = create(:vote)
    vote.destroy

    assert_not_nil vote.deleted_at

    vote.restore

    assert_nil vote.reload.deleted_at
    assert_includes Vote.all, vote
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle vote without election having voter_id_template" do
    election = create(:election, voter_id_template: nil)
    vote = create(:vote, election: election)

    assert_not_nil vote.voter_id
    assert vote.voter_id.length > 0
  end

  test "should generate different voter_ids for different users" do
    election = create(:election)
    user1 = create(:user)
    user2 = create(:user)

    vote1 = create(:vote, user: user1, election: election)
    vote2 = create(:vote, user: user2, election: election)

    assert_not_equal vote1.voter_id, vote2.voter_id
  end

  test "should generate different voter_ids for different elections" do
    user = create(:user)
    election1 = create(:election)
    election2 = create(:election)

    vote1 = create(:vote, user: user, election: election1)
    vote2 = create(:vote, user: user, election: election2)

    assert_not_equal vote1.voter_id, vote2.voter_id
  end

  test "should handle missing user when creating vote" do
    vote = Vote.new(election: create(:election))

    assert_not vote.save
    assert_includes vote.errors[:user_id], "can't be blank"
  end

  test "should handle missing election when creating vote" do
    vote = Vote.new(user: create(:user))

    assert_not vote.save
    assert_includes vote.errors[:election_id], "can't be blank"
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "complete vote creation workflow" do
    user = create(:user)
    election = create(:election)
    paper_authority = create(:user)

    vote = nil

    assert_difference('Vote.count', 1) do
      vote = create(:vote, user: user, election: election, paper_authority: paper_authority)
    end

    assert_not_nil vote.voter_id
    assert_not_nil vote.agora_id
    assert_equal user.id, vote.user_id
    assert_equal election.id, vote.election_id
    assert_equal paper_authority.id, vote.paper_authority_id
  end

  test "complete URL generation workflow" do
    vote = create(:vote)

    # Generate voter_id
    voter_id = vote.generate_voter_id
    assert_not_nil voter_id

    # Generate message
    message = vote.generate_message
    assert_includes message, voter_id

    # Generate hash
    hash = vote.generate_hash(message)
    assert_not_nil hash

    # Generate URL
    url = vote.url
    assert_includes url, hash
    assert_includes url, message
  end

  test "voter_id uniqueness within user but not across users" do
    election = create(:election)
    user1 = create(:user)
    user2 = create(:user)

    # Create first vote for user1
    vote1 = create(:vote, user: user1, election: election)

    # Try to create another vote with same voter_id for user1 (should fail)
    vote2 = build(:vote, user: user1, election: election)
    vote2.voter_id = vote1.voter_id
    assert_not vote2.valid?

    # Create vote with same voter_id for user2 (should succeed)
    vote3 = build(:vote, user: user2, election: election)
    vote3.voter_id = vote1.voter_id
    assert vote3.valid?
  end

  test "soft delete and restore workflow" do
    vote = create(:vote)
    original_voter_id = vote.voter_id

    # Soft delete
    assert_difference('Vote.count', -1) do
      vote.destroy
    end

    assert_not_nil vote.deleted_at
    assert_not_includes Vote.all, vote
    assert_includes Vote.with_deleted, vote

    # Restore
    vote.restore

    assert_nil vote.reload.deleted_at
    assert_includes Vote.all, vote
    assert_equal original_voter_id, vote.voter_id
  end

  test "multiple votes for same user in different elections" do
    user = create(:user)
    election1 = create(:election)
    election2 = create(:election)

    vote1 = create(:vote, user: user, election: election1)
    vote2 = create(:vote, user: user, election: election2)

    assert_not_equal vote1.voter_id, vote2.voter_id
    assert_equal user.id, vote1.user_id
    assert_equal user.id, vote2.user_id
  end
end
