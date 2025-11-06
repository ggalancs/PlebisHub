require 'test_helper'

class NoticeTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid notice" do
    notice = build(:notice)
    assert notice.valid?, "Factory should create a valid notice"
  end

  test "factory creates valid sent notice" do
    notice = build(:notice, :sent)
    assert notice.valid?
    assert_not_nil notice.sent_at
  end

  test "factory creates valid active notice" do
    notice = build(:notice, :active)
    assert notice.valid?
    assert notice.active?
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  # Title validations
  test "should require title" do
    notice = build(:notice, title: nil)
    assert_not notice.valid?
    assert_includes notice.errors[:title], "can't be blank"
  end

  test "should accept valid title" do
    notice = build(:notice, title: "Important Announcement")
    assert notice.valid?
  end

  test "should reject empty string title" do
    notice = build(:notice, title: "")
    assert_not notice.valid?
    assert_includes notice.errors[:title], "can't be blank"
  end

  # Body validations
  test "should require body" do
    notice = build(:notice, body: nil)
    assert_not notice.valid?
    assert_includes notice.errors[:body], "can't be blank"
  end

  test "should accept valid body" do
    notice = build(:notice, body: "This is a detailed message for all users.")
    assert notice.valid?
  end

  test "should reject empty string body" do
    notice = build(:notice, body: "")
    assert_not notice.valid?
    assert_includes notice.errors[:body], "can't be blank"
  end

  # Link validations
  test "should accept nil link" do
    notice = build(:notice, link: nil)
    assert notice.valid?
  end

  test "should accept blank link" do
    notice = build(:notice, link: "")
    assert notice.valid?
  end

  test "should accept valid http URL" do
    notice = build(:notice, link: "http://example.com/page")
    assert notice.valid?
  end

  test "should accept valid https URL" do
    notice = build(:notice, link: "https://example.com/page")
    assert notice.valid?
  end

  test "should reject invalid URL format" do
    notice = build(:notice, link: "not-a-url")
    assert_not notice.valid?
    assert_includes notice.errors[:link], "must be a valid URL"
  end

  test "should reject URL without protocol" do
    notice = build(:notice, link: "example.com")
    assert_not notice.valid?
    assert_includes notice.errors[:link], "must be a valid URL"
  end

  test "should reject invalid protocol" do
    notice = build(:notice, link: "ftp://example.com")
    assert_not notice.valid?
    assert_includes notice.errors[:link], "must be a valid URL"
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create notice with valid attributes" do
    assert_difference('Notice.count', 1) do
      create(:notice)
    end
  end

  test "should read notice attributes correctly" do
    notice = create(:notice,
      title: "Test Title",
      body: "Test Body",
      link: "https://example.com"
    )

    found_notice = Notice.find(notice.id)
    assert_equal "Test Title", found_notice.title
    assert_equal "Test Body", found_notice.body
    assert_equal "https://example.com", found_notice.link
  end

  test "should update notice attributes" do
    notice = create(:notice, title: "Original Title")
    notice.update(title: "Updated Title")

    assert_equal "Updated Title", notice.reload.title
  end

  test "should not update with invalid attributes" do
    notice = create(:notice, title: "Valid Title")
    notice.update(title: nil)

    assert_not notice.valid?
    assert_equal "Valid Title", notice.reload.title
  end

  test "should delete notice" do
    notice = create(:notice)
    assert_difference('Notice.count', -1) do
      notice.destroy
    end
  end

  # ====================
  # DEFAULT SCOPE TESTS
  # ====================

  test "default scope should order by created_at DESC" do
    old_notice = create(:notice, created_at: 2.days.ago)
    new_notice = create(:notice, created_at: 1.day.ago)
    newest_notice = create(:notice, created_at: 1.hour.ago)

    notices = Notice.all.to_a

    assert_equal newest_notice, notices[0]
    assert_equal new_notice, notices[1]
    assert_equal old_notice, notices[2]
  end

  test "should maintain order after updates" do
    first = create(:notice, created_at: 3.days.ago)
    second = create(:notice, created_at: 2.days.ago)

    first.update(title: "Updated")

    notices = Notice.all.to_a
    assert_equal second, notices[0]
    assert_equal first, notices[1]
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "sent scope should return only sent notices" do
    sent_notice = create(:notice, :sent)
    pending_notice = create(:notice, :pending)

    sent_notices = Notice.sent

    assert_includes sent_notices, sent_notice
    assert_not_includes sent_notices, pending_notice
  end

  test "sent scope should return empty when no sent notices exist" do
    create(:notice, :pending)
    create(:notice, :pending)

    assert_empty Notice.sent
  end

  test "pending scope should return only pending notices" do
    sent_notice = create(:notice, :sent)
    pending_notice = create(:notice, :pending)

    pending_notices = Notice.pending

    assert_includes pending_notices, pending_notice
    assert_not_includes pending_notices, sent_notice
  end

  test "pending scope should return empty when no pending notices exist" do
    create(:notice, :sent)
    create(:notice, :sent)

    assert_empty Notice.pending
  end

  test "active scope should return notices without expiration" do
    active_notice = create(:notice, final_valid_at: nil)
    expired_notice = create(:notice, :expired)

    active_notices = Notice.active

    assert_includes active_notices, active_notice
    assert_not_includes active_notices, expired_notice
  end

  test "active scope should return notices not yet expired" do
    active_notice = create(:notice, final_valid_at: 1.day.from_now)
    expired_notice = create(:notice, :expired)

    active_notices = Notice.active

    assert_includes active_notices, active_notice
    assert_not_includes active_notices, expired_notice
  end

  test "active scope should handle edge case at expiration time" do
    almost_expired = create(:notice, final_valid_at: 1.second.from_now)

    assert_includes Notice.active, almost_expired

    # Simulate time passing
    travel 2.seconds do
      assert_not_includes Notice.active, almost_expired
    end
  end

  test "expired scope should return only expired notices" do
    active_notice = create(:notice, :active)
    expired_notice = create(:notice, :expired)

    expired_notices = Notice.expired

    assert_includes expired_notices, expired_notice
    assert_not_includes expired_notices, active_notice
  end

  test "expired scope should not include notices without expiration" do
    without_expiration = create(:notice, final_valid_at: nil)
    expired = create(:notice, :expired)

    expired_notices = Notice.expired

    assert_includes expired_notices, expired
    assert_not_includes expired_notices, without_expiration
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  test "has_sent should return true when sent_at is present" do
    notice = create(:notice, :sent)
    assert notice.has_sent
  end

  test "has_sent should return false when sent_at is nil" do
    notice = create(:notice, :pending)
    assert_not notice.has_sent
  end

  test "sent? should be an alias for has_sent" do
    notice = create(:notice, :sent)
    assert_equal notice.has_sent, notice.sent?
  end

  test "sent? should return true when sent" do
    notice = create(:notice, :sent)
    assert notice.sent?
  end

  test "sent? should return false when pending" do
    notice = create(:notice, :pending)
    assert_not notice.sent?
  end

  test "active? should return true when final_valid_at is nil" do
    notice = create(:notice, final_valid_at: nil)
    assert notice.active?
  end

  test "active? should return true when final_valid_at is in future" do
    notice = create(:notice, final_valid_at: 1.day.from_now)
    assert notice.active?
  end

  test "active? should return false when final_valid_at is in past" do
    notice = create(:notice, :expired)
    assert_not notice.active?
  end

  test "active? should handle current time edge case" do
    notice = create(:notice, final_valid_at: Time.current + 1.second)
    assert notice.active?
  end

  test "expired? should return false when active" do
    notice = create(:notice, :active)
    assert_not notice.expired?
  end

  test "expired? should return true when past final_valid_at" do
    notice = create(:notice, :expired)
    assert notice.expired?
  end

  test "expired? should return false when no expiration set" do
    notice = create(:notice, final_valid_at: nil)
    assert_not notice.expired?
  end

  # Note: broadcast! and broadcast_gcm methods require external GCM service
  # These methods should be tested with integration tests or with proper mocking library
  # For unit tests, we focus on the state changes we can verify

  test "broadcast! should update sent_at timestamp" do
    skip "broadcast! requires GCM service - should be tested in integration tests"
  end

  test "broadcast_gcm method exists and accepts correct parameters" do
    notice = create(:notice)
    assert_respond_to notice, :broadcast_gcm
    # Method signature verification
    assert_equal 3, notice.method(:broadcast_gcm).arity
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle very long title" do
    long_title = "A" * 1000
    notice = build(:notice, title: long_title)
    # Should not crash
    notice.valid?
    assert_not_nil notice
  end

  test "should handle very long body" do
    long_body = "B" * 10000
    notice = build(:notice, body: long_body)
    # Should not crash
    notice.valid?
    assert_not_nil notice
  end

  test "should handle special characters in title" do
    notice = build(:notice, title: "Special chars: @#$% & <> 特殊")
    assert notice.valid?
  end

  test "should handle special characters in body" do
    notice = build(:notice, body: "Body with émojis 🎉 and symbols © ® ™")
    assert notice.valid?
  end

  test "should handle very long URL" do
    long_url = "https://example.com/" + ("a" * 1000)
    notice = build(:notice, link: long_url)
    assert notice.valid?
  end

  # ====================
  # PAGINATION TESTS
  # ====================

  test "should paginate with 5 items per page" do
    10.times { create(:notice) }

    first_page = Notice.page(1)
    assert_equal 5, first_page.count

    second_page = Notice.page(2)
    assert_equal 5, second_page.count
  end

  test "should return correct page count" do
    12.times { create(:notice) }

    # 12 items / 5 per page = 3 pages
    assert_equal 3, Notice.page.total_pages
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "should handle sent active notices" do
    notice = create(:notice, :sent_active)

    assert notice.sent?
    assert notice.active?
    assert_includes Notice.sent, notice
    assert_includes Notice.active, notice
  end

  test "should handle pending expired notices" do
    notice = create(:notice, :pending, :expired)

    assert_not notice.sent?
    assert notice.expired?
    assert_includes Notice.pending, notice
    assert_includes Notice.expired, notice
  end

  test "should filter sent and active notices" do
    sent_active = create(:notice, :sent_active)
    sent_expired = create(:notice, :sent_expired)
    pending_active = create(:notice, :pending_active)

    results = Notice.sent.active

    assert_includes results, sent_active
    assert_not_includes results, sent_expired
    assert_not_includes results, pending_active
  end
end
