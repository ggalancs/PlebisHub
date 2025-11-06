require 'test_helper'

class VoteCircleTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid vote_circle" do
    circle = build(:vote_circle)
    assert circle.valid?, "Factory should create a valid vote_circle"
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create vote_circle with valid attributes" do
    assert_difference('VoteCircle.count', 1) do
      create(:vote_circle)
    end
  end

  test "should read vote_circle attributes correctly" do
    circle = create(:vote_circle, name: "Test Circle", code: "TEST001")

    found_circle = VoteCircle.find(circle.id)
    assert_equal "Test Circle", found_circle.name
    assert_equal "TEST001", found_circle.code
  end

  test "should update vote_circle attributes" do
    circle = create(:vote_circle, name: "Original")

    circle.update(name: "Updated")

    assert_equal "Updated", circle.reload.name
  end

  test "should delete vote_circle" do
    circle = create(:vote_circle)

    assert_difference('VoteCircle.count', -1) do
      circle.destroy
    end
  end

  # ====================
  # ENUM TESTS
  # ====================

  test "should have kind enum" do
    circle = create(:vote_circle, kind: :municipal)
    assert_equal "municipal", circle.kind
    assert circle.municipal?
  end

  test "should support all kind values" do
    %i[interno barrial municipal comarcal exterior].each do |kind|
      circle = build(:vote_circle, kind: kind)
      assert circle.valid?
      assert_equal kind.to_s, circle.kind
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "in_spain scope should return spanish circles" do
    barrial = create(:vote_circle, kind: :barrial)
    municipal = create(:vote_circle, kind: :municipal)
    comarcal = create(:vote_circle, kind: :comarcal)
    interno = create(:vote_circle, kind: :interno)
    exterior = create(:vote_circle, kind: :exterior)

    results = VoteCircle.in_spain

    assert_includes results, barrial
    assert_includes results, municipal
    assert_includes results, comarcal
    assert_not_includes results, interno
    assert_not_includes results, exterior
  end

  test "not_interno scope should exclude interno circles" do
    interno = create(:vote_circle, kind: :interno)
    municipal = create(:vote_circle, kind: :municipal)

    results = VoteCircle.not_interno

    assert_includes results, municipal
    assert_not_includes results, interno
  end

  # ====================
  # METHOD TESTS
  # ====================

  test "is_active? should return false for interno" do
    circle = create(:vote_circle, kind: :interno)
    assert_equal false, circle.is_active?
  end

  test "is_active? should return true for non-interno" do
    circle = create(:vote_circle, kind: :municipal)
    assert_equal true, circle.is_active?
  end
end
