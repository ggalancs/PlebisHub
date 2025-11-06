require 'test_helper'

class NoticeRegistrarTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid notice_registrar" do
    registrar = build(:notice_registrar)
    assert registrar.valid?, "Factory should create a valid notice_registrar"
  end

  test "factory creates registrar with attributes" do
    registrar = create(:notice_registrar)
    assert_not_nil registrar.registration_id
    assert_equal true, registrar.status
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should allow registrar without registration_id" do
    registrar = build(:notice_registrar, registration_id: nil)
    # No validations in model
    assert registrar.valid?
  end

  test "should allow registrar without status" do
    registrar = build(:notice_registrar, status: nil)
    assert registrar.valid?
  end

  test "should allow duplicate registration_ids" do
    registrar1 = create(:notice_registrar, registration_id: "DUPLICATE")
    registrar2 = build(:notice_registrar, registration_id: "DUPLICATE")

    # No uniqueness constraint
    assert registrar2.valid?
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create notice_registrar with valid attributes" do
    assert_difference('NoticeRegistrar.count', 1) do
      create(:notice_registrar)
    end
  end

  test "should read notice_registrar attributes correctly" do
    registrar = create(:notice_registrar,
      registration_id: "TEST123",
      status: true
    )

    found_registrar = NoticeRegistrar.find(registrar.id)
    assert_equal "TEST123", found_registrar.registration_id
    assert_equal true, found_registrar.status
  end

  test "should update notice_registrar attributes" do
    registrar = create(:notice_registrar, status: true)

    registrar.update(status: false)

    assert_equal false, registrar.reload.status
  end

  test "should delete notice_registrar" do
    registrar = create(:notice_registrar)

    assert_difference('NoticeRegistrar.count', -1) do
      registrar.destroy
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle empty registration_id" do
    registrar = build(:notice_registrar, registration_id: "")
    assert registrar.valid?
  end

  test "should handle very long registration_id" do
    registrar = build(:notice_registrar, registration_id: "A" * 1000)
    assert registrar.valid?
  end

  test "should handle special characters in registration_id" do
    registrar = build(:notice_registrar, registration_id: "REG-2024/001@TEST")
    assert registrar.valid?
  end

  test "should handle unicode in registration_id" do
    registrar = build(:notice_registrar, registration_id: "登録123")
    assert registrar.valid?
  end

  test "should handle boolean status values" do
    registrar_true = create(:notice_registrar, status: true)
    registrar_false = create(:notice_registrar, status: false)
    registrar_nil = create(:notice_registrar, status: nil)

    assert_equal true, registrar_true.status
    assert_equal false, registrar_false.status
    assert_nil registrar_nil.status
  end

  test "should handle numeric values for status" do
    registrar = create(:notice_registrar, status: 1)
    # ActiveRecord coerces to boolean
    assert_equal true, registrar.status
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "should track full lifecycle of registrar" do
    initial_count = NoticeRegistrar.count

    # Create
    registrar = create(:notice_registrar, registration_id: "LC001", status: true)
    assert_equal initial_count + 1, NoticeRegistrar.count

    # Update
    registrar.update(status: false)
    assert_equal false, registrar.reload.status

    # Update registration_id
    registrar.update(registration_id: "LC002")
    assert_equal "LC002", registrar.reload.registration_id

    # Delete
    registrar.destroy
    assert_equal initial_count, NoticeRegistrar.count
  end

  test "should handle multiple registrars with different statuses" do
    active = create(:notice_registrar, registration_id: "ACTIVE", status: true)
    inactive = create(:notice_registrar, registration_id: "INACTIVE", status: false)
    pending = create(:notice_registrar, registration_id: "PENDING", status: nil)

    assert_equal 3, NoticeRegistrar.count

    # Verify each can be found
    assert_equal active.id, NoticeRegistrar.find(active.id).id
    assert_equal inactive.id, NoticeRegistrar.find(inactive.id).id
    assert_equal pending.id, NoticeRegistrar.find(pending.id).id
  end

  test "should handle rapid creation of multiple registrars" do
    assert_difference('NoticeRegistrar.count', 10) do
      10.times { |i| create(:notice_registrar, registration_id: "BULK#{i}") }
    end
  end

  test "should handle updates without changing timestamps inappropriately" do
    registrar = create(:notice_registrar)
    original_created_at = registrar.created_at
    original_updated_at = registrar.updated_at

    sleep 0.01 # Ensure time passes

    registrar.update(status: false)

    assert_equal original_created_at.to_i, registrar.reload.created_at.to_i
    assert_operator registrar.updated_at, :>, original_updated_at
  end

  test "should handle nil and empty values distinctly" do
    registrar_nil = create(:notice_registrar, registration_id: nil)
    registrar_empty = create(:notice_registrar, registration_id: "")

    assert_nil registrar_nil.registration_id
    assert_equal "", registrar_empty.registration_id
    assert_not_equal registrar_nil.registration_id, registrar_empty.registration_id
  end

  # ====================
  # QUERY TESTS
  # ====================

  test "should find by registration_id" do
    registrar = create(:notice_registrar, registration_id: "FIND_ME")

    found = NoticeRegistrar.find_by(registration_id: "FIND_ME")

    assert_not_nil found
    assert_equal registrar.id, found.id
  end

  test "should find by status" do
    active1 = create(:notice_registrar, status: true)
    active2 = create(:notice_registrar, status: true)
    inactive = create(:notice_registrar, status: false)

    active_registrars = NoticeRegistrar.where(status: true)

    assert_equal 2, active_registrars.count
    assert_includes active_registrars.pluck(:id), active1.id
    assert_includes active_registrars.pluck(:id), active2.id
    assert_not_includes active_registrars.pluck(:id), inactive.id
  end

  test "should handle ordering by created_at" do
    first = create(:notice_registrar, registration_id: "FIRST")
    sleep 0.01
    second = create(:notice_registrar, registration_id: "SECOND")
    sleep 0.01
    third = create(:notice_registrar, registration_id: "THIRD")

    ordered = NoticeRegistrar.order(created_at: :asc).last(3)

    assert_equal [first.id, second.id, third.id], ordered.map(&:id)
  end

  test "should count registrars by status" do
    3.times { create(:notice_registrar, status: true) }
    2.times { create(:notice_registrar, status: false) }
    1.times { create(:notice_registrar, status: nil) }

    assert_equal 3, NoticeRegistrar.where(status: true).count
    assert_equal 2, NoticeRegistrar.where(status: false).count
    assert_equal 1, NoticeRegistrar.where(status: nil).count
  end
end
