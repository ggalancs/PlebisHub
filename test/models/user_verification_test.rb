require 'test_helper'

class UserVerificationTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates user_verification" do
    verification = build(:user_verification)
    # Factory skips validation since we can't create actual image files
    assert_not_nil verification
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create user_verification with valid attributes" do
    assert_difference('UserVerification.count', 1) do
      create(:user_verification)
    end
  end

  test "should update user_verification attributes" do
    verification = create(:user_verification, status: :pending)

    verification.update_column(:status, 1) # accepted = 1

    assert_equal "accepted", verification.reload.status
    assert verification.accepted?
  end

  test "should delete user_verification" do
    verification = create(:user_verification)

    assert_difference('UserVerification.count', -1) do
      verification.destroy
    end
  end

  # ====================
  # ENUM TESTS
  # ====================

  test "should have status enum" do
    verification = create(:user_verification, status: :accepted)
    assert_equal "accepted", verification.status
    assert verification.accepted?
  end

  test "should support all status values" do
    %i[pending accepted issues rejected accepted_by_email discarded paused].each do |status|
      verification = build(:user_verification, status: status)
      assert_equal status.to_s, verification.status
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "verifying scope should return pending, issues, and paused verifications" do
    pending = create(:user_verification, status: :pending)
    issues = create(:user_verification, status: :issues)
    paused = create(:user_verification, status: :paused)
    accepted = create(:user_verification, status: :accepted)
    rejected = create(:user_verification, status: :rejected)

    results = UserVerification.verifying

    assert_includes results, pending
    assert_includes results, issues
    assert_includes results, paused
    assert_not_includes results, accepted
    assert_not_includes results, rejected
  end

  test "not_discarded scope should exclude discarded verifications" do
    pending = create(:user_verification, status: :pending)
    discarded = create(:user_verification, status: :discarded)

    results = UserVerification.not_discarded

    assert_includes results, pending
    assert_not_includes results, discarded
  end

  test "discardable scope should return pending and issues verifications" do
    pending = create(:user_verification, status: :pending)
    issues = create(:user_verification, status: :issues)
    accepted = create(:user_verification, status: :accepted)

    results = UserVerification.discardable

    assert_includes results, pending
    assert_includes results, issues
    assert_not_includes results, accepted
  end

  test "not_sended scope should return verifications wanting card without born_at" do
    not_sent = create(:user_verification, wants_card: true, born_at: nil)
    sent = create(:user_verification, wants_card: true, born_at: 20.years.ago)
    no_card = create(:user_verification, wants_card: false, born_at: nil)

    results = UserVerification.not_sended

    assert_includes results, not_sent
    assert_not_includes results, sent
    assert_not_includes results, no_card
  end

  # ====================
  # METHOD TESTS
  # ====================

  test "discardable? should return true for pending status" do
    verification = create(:user_verification, status: :pending)
    assert verification.discardable?
  end

  test "discardable? should return true for issues status" do
    verification = create(:user_verification, status: :issues)
    assert verification.discardable?
  end

  test "discardable? should return false for accepted status" do
    verification = create(:user_verification, status: :accepted)
    assert_not verification.discardable?
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should belong to user" do
    verification = create(:user_verification)
    assert_respond_to verification, :user
    assert_instance_of User, verification.user
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "should track verification lifecycle" do
    user = create(:user)
    verification = create(:user_verification, user: user, status: :pending)

    assert verification.pending?
    assert_nil verification.processed_at

    verification.update_columns(status: 1, processed_at: Time.current) # accepted = 1

    assert verification.reload.accepted?
    assert_not_nil verification.processed_at
  end
end
