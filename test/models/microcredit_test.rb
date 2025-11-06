require 'test_helper'

class MicrocreditTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid microcredit" do
    microcredit = build(:microcredit)
    assert microcredit.valid?, "Factory should create a valid microcredit"
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should validate limits format" do
    microcredit = build(:microcredit, limits: "invalid")
    assert_not microcredit.valid?
    assert_includes microcredit.errors[:limits], "Introduce pares (monto, cantidad)"
  end

  test "should accept valid limits format" do
    microcredit = build(:microcredit, limits: "100€: 10\n500€: 5")
    assert microcredit.valid?
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create microcredit with valid attributes" do
    assert_difference('Microcredit.count', 1) do
      create(:microcredit)
    end
  end

  test "should update microcredit attributes" do
    microcredit = create(:microcredit, title: "Original")

    microcredit.update(title: "Updated")

    assert_equal "Updated", microcredit.reload.title
  end

  test "should soft delete microcredit" do
    microcredit = create(:microcredit)

    assert_difference('Microcredit.count', -1) do
      microcredit.destroy
    end

    assert_not_nil microcredit.reload.deleted_at
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "active scope should return currently active microcredits" do
    active = create(:microcredit, :active)
    upcoming = create(:microcredit, :upcoming)
    finished = create(:microcredit, :finished)

    results = Microcredit.active

    assert_includes results, active
    assert_not_includes results, upcoming
    assert_not_includes results, finished
  end

  test "non_finished scope should return future microcredits" do
    active = create(:microcredit, :active)
    finished = create(:microcredit, :finished)

    results = Microcredit.non_finished

    assert_includes results, active
    assert_not_includes results, finished
  end

  test "standard scope should return non-mailing microcredits" do
    standard = create(:microcredit, mailing: false)
    mailing = create(:microcredit, :with_mailing)

    results = Microcredit.standard

    assert_includes results, standard
    assert_not_includes results, mailing
  end

  test "mailing scope should return mailing microcredits" do
    standard = create(:microcredit, mailing: false)
    mailing = create(:microcredit, :with_mailing)

    results = Microcredit.mailing

    assert_includes results, mailing
    assert_not_includes results, standard
  end

  # ====================
  # FLAG TESTS
  # ====================

  test "should have mailing flag" do
    microcredit = create(:microcredit, :with_mailing)
    assert microcredit.mailing?
  end

  test "should not have mailing flag by default" do
    microcredit = create(:microcredit)
    assert_not microcredit.mailing?
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should have many loans" do
    microcredit = create(:microcredit)
    assert_respond_to microcredit, :loans
  end

  test "should have many microcredit_options" do
    microcredit = create(:microcredit)
    assert_respond_to microcredit, :microcredit_options
  end

  test "should destroy dependent microcredit_options" do
    microcredit = create(:microcredit)
    option = create(:microcredit_option, microcredit: microcredit)

    assert_difference('MicrocreditOption.count', -1) do
      microcredit.destroy
    end
  end
end
