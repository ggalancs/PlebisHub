require 'test_helper'

class MilitantRecordTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid militant_record" do
    record = build(:militant_record)
    assert record.valid?, "Factory should create a valid militant_record"
  end

  test "factory creates record with associations" do
    record = create(:militant_record)
    assert_not_nil record.user
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create militant_record with valid attributes" do
    assert_difference('MilitantRecord.count', 1) do
      create(:militant_record)
    end
  end

  test "should read militant_record attributes correctly" do
    user = create(:user)
    record = create(:militant_record,
      user: user,
      amount: 5000,
      payment_type: 2,
      is_militant: true
    )

    found_record = MilitantRecord.find(record.id)
    assert_equal user.id, found_record.user_id
    assert_equal 5000, found_record.amount
    assert_equal 2, found_record.payment_type
    assert_equal true, found_record.is_militant
  end

  test "should update militant_record attributes" do
    record = create(:militant_record, is_militant: true)

    record.update(is_militant: false, end_verified: Time.current)

    assert_equal false, record.reload.is_militant
    assert_not_nil record.end_verified
  end

  test "should delete militant_record" do
    record = create(:militant_record)

    assert_difference('MilitantRecord.count', -1) do
      record.destroy
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should belong to user" do
    record = create(:militant_record)
    assert_respond_to record, :user
    assert_instance_of User, record.user
  end

  # ====================
  # DATE RANGE TESTS
  # ====================

  test "should track verification period" do
    record = create(:militant_record,
      begin_verified: 1.year.ago,
      end_verified: nil
    )

    assert_not_nil record.begin_verified
    assert_nil record.end_verified
  end

  test "should track payment period" do
    record = create(:militant_record,
      begin_payment: 1.year.ago,
      end_payment: nil
    )

    assert_not_nil record.begin_payment
    assert_nil record.end_payment
  end

  test "should handle ended militant status" do
    record = create(:militant_record, :ended)

    assert_not_nil record.end_verified
    assert_not_nil record.end_payment
    assert_equal false, record.is_militant
  end

  # ====================
  # PAYMENT TESTS
  # ====================

  test "should store payment_type" do
    record = create(:militant_record, payment_type: 3)
    assert_equal 3, record.payment_type
  end

  test "should store amount in cents" do
    record = create(:militant_record, amount: 2500)
    assert_equal 2500, record.amount
  end

  test "should handle zero amount" do
    record = create(:militant_record, amount: 0)
    assert_equal 0, record.amount
  end

  # ====================
  # QUERY TESTS
  # ====================

  test "should find active militants by nil end_verified" do
    active = create(:militant_record, end_verified: nil)
    ended = create(:militant_record, end_verified: 1.day.ago)

    results = MilitantRecord.where(end_verified: nil)

    assert_includes results, active
    assert_not_includes results, ended
  end

  test "should find by is_militant flag" do
    militant = create(:militant_record, is_militant: true)
    non_militant = create(:militant_record, is_militant: false)

    results = MilitantRecord.where(is_militant: true)

    assert_includes results, militant
    assert_not_includes results, non_militant
  end

  test "should find records by user" do
    user = create(:user)
    record1 = create(:militant_record, user: user)
    record2 = create(:militant_record, user: user)
    other_record = create(:militant_record)

    user_records = MilitantRecord.where(user: user)

    assert_equal 2, user_records.count
    assert_includes user_records, record1
    assert_includes user_records, record2
    assert_not_includes user_records, other_record
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle nil dates" do
    record = create(:militant_record,
      begin_verified: nil,
      end_verified: nil,
      begin_payment: nil,
      end_payment: nil
    )

    assert_nil record.begin_verified
    assert_nil record.end_verified
    assert_nil record.begin_payment
    assert_nil record.end_payment
  end

  test "should handle negative amounts" do
    record = create(:militant_record, amount: -1000)
    assert_equal(-1000, record.amount)
  end

  test "should handle large amounts" do
    record = create(:militant_record, amount: 1_000_000_00)
    assert_equal 1_000_000_00, record.amount
  end

  # ====================
  # DIFF FUNCTIONALITY TESTS
  # ====================

  test "should support diff functionality" do
    record = create(:militant_record, amount: 1000, is_militant: true)

    assert_respond_to record, :diff
  end

  test "should calculate diff between records" do
    record1 = create(:militant_record, amount: 1000, is_militant: true)
    record2 = build(:militant_record, amount: 2000, is_militant: false)

    # The diff method should work
    diff = record1.diff(record2)

    assert_kind_of Hash, diff
  end

  test "should exclude created_at and updated_at from diff" do
    record1 = create(:militant_record, amount: 1000)
    sleep 0.01
    record2 = create(:militant_record, amount: 1000)

    diff = record1.diff(record2)

    # created_at and updated_at should be excluded
    assert_not_includes diff.keys, :created_at
    assert_not_includes diff.keys, :updated_at
  end
end
