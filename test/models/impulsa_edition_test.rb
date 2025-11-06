require "test_helper"

class ImpulsaEditionTest < ActiveSupport::TestCase
  # Factory Test
  test "factory creates valid impulsa_edition" do
    edition = build(:impulsa_edition)
    assert edition.valid?, "Factory should create valid edition. Errors: #{edition.errors.full_messages.join(', ')}"
  end

  # Association Tests
  test "should have many impulsa_edition_categories" do
    edition = create(:impulsa_edition)
    assert_respond_to edition, :impulsa_edition_categories
  end

  test "should have many impulsa_projects through categories" do
    edition = create(:impulsa_edition)
    assert_respond_to edition, :impulsa_projects
  end

  test "should have many impulsa_edition_topics" do
    edition = create(:impulsa_edition)
    assert_respond_to edition, :impulsa_edition_topics
  end

  # Validation Tests
  test "should require name" do
    edition = build(:impulsa_edition, name: nil)
    assert_not edition.valid?
    assert_includes edition.errors[:name], "no puede estar en blanco"
  end

  test "should require email" do
    edition = build(:impulsa_edition, email: nil)
    assert_not edition.valid?
    assert_includes edition.errors[:email], "no puede estar en blanco"
  end

  test "should validate email format" do
    edition = build(:impulsa_edition, email: "invalid")
    assert_not edition.valid?
    assert_includes edition.errors[:email], "no es un correo válido"
  end

  # Scope Tests
  test "active scope should return active editions" do
    active = create(:impulsa_edition, :active)
    previous = create(:impulsa_edition, :previous)

    result = ImpulsaEdition.active
    assert_includes result, active
    assert_not_includes result, previous
  end

  test "upcoming scope should return upcoming editions" do
    upcoming = create(:impulsa_edition, :upcoming)
    previous = create(:impulsa_edition, :previous)

    result = ImpulsaEdition.upcoming
    assert_includes result, upcoming
    assert_not_includes result, previous
  end

  test "previous scope should return previous editions" do
    previous = create(:impulsa_edition, :previous)
    upcoming = create(:impulsa_edition, :upcoming)

    result = ImpulsaEdition.previous
    assert_includes result, previous
    assert_not_includes result, upcoming
  end

  # Class Method Tests
  test "current should return first active or first previous" do
    previous = create(:impulsa_edition, :previous)
    assert_equal previous, ImpulsaEdition.current

    active = create(:impulsa_edition, :active)
    assert_equal active, ImpulsaEdition.current
  end

  # Phase Method Tests
  test "current_phase should return not_started before start_at" do
    edition = build(:impulsa_edition, start_at: 1.day.from_now)
    assert_equal ImpulsaEdition::EDITION_PHASES[:not_started], edition.current_phase
  end

  test "current_phase should return new_projects during new projects period" do
    edition = create(:impulsa_edition,
      start_at: 1.day.ago,
      new_projects_until: 1.day.from_now,
      review_projects_until: 2.days.from_now,
      validation_projects_until: 3.days.from_now,
      votings_start_at: 4.days.from_now,
      ends_at: 5.days.from_now
    )
    assert_equal ImpulsaEdition::EDITION_PHASES[:new_projects], edition.current_phase
  end

  test "current_phase should return votings during voting period" do
    edition = create(:impulsa_edition, :active)
    assert_equal ImpulsaEdition::EDITION_PHASES[:votings], edition.current_phase
  end

  test "current_phase should return ended after publish_results_at" do
    edition = create(:impulsa_edition,
      start_at: 3.months.ago,
      new_projects_until: 2.months.ago,
      review_projects_until: 2.months.ago,
      validation_projects_until: 2.months.ago,
      votings_start_at: 2.months.ago,
      ends_at: 1.month.ago,
      publish_results_at: 1.day.ago
    )
    assert_equal ImpulsaEdition::EDITION_PHASES[:ended], edition.current_phase
  end

  # Permission Methods Tests
  test "allow_creation? should return true during new_projects phase" do
    edition = create(:impulsa_edition,
      start_at: 1.day.ago,
      new_projects_until: 1.day.from_now,
      review_projects_until: 2.days.from_now,
      validation_projects_until: 3.days.from_now,
      votings_start_at: 4.days.from_now,
      ends_at: 5.days.from_now
    )
    assert edition.allow_creation?
  end

  test "allow_creation? should return false outside new_projects phase" do
    edition = create(:impulsa_edition, :active)
    assert_not edition.allow_creation?
  end

  test "allow_edition? should return true before review_projects" do
    edition = create(:impulsa_edition,
      start_at: 1.day.ago,
      new_projects_until: 1.day.from_now,
      review_projects_until: 2.days.from_now,
      validation_projects_until: 3.days.from_now,
      votings_start_at: 4.days.from_now,
      ends_at: 5.days.from_now
    )
    assert edition.allow_edition?
  end

  test "allow_fixes? should return true before validation_projects" do
    edition = create(:impulsa_edition,
      start_at: 2.days.ago,
      new_projects_until: 1.day.ago,
      review_projects_until: 1.hour.ago,
      validation_projects_until: 1.day.from_now,
      votings_start_at: 2.days.from_now,
      ends_at: 3.days.from_now
    )
    assert edition.allow_fixes?
  end

  test "allow_validation? should return true during validation_projects phase" do
    edition = create(:impulsa_edition,
      start_at: 3.days.ago,
      new_projects_until: 2.days.ago,
      review_projects_until: 1.day.ago,
      validation_projects_until: 1.day.from_now,
      votings_start_at: 2.days.from_now,
      ends_at: 3.days.from_now
    )
    assert edition.allow_validation?
  end

  test "show_projects? should return true after validation_projects" do
    edition = create(:impulsa_edition, :active)
    assert edition.show_projects?
  end

  test "active? should return false when ended" do
    edition = create(:impulsa_edition, :previous)
    assert_not edition.active?
  end

  test "active? should return true when not ended" do
    edition = create(:impulsa_edition, :active)
    assert edition.active?
  end

  # Paperclip Tests
  test "should have schedule_model attachment" do
    edition = create(:impulsa_edition)
    assert_respond_to edition, :schedule_model
  end

  test "should have activities_resources_model attachment" do
    edition = create(:impulsa_edition)
    assert_respond_to edition, :activities_resources_model
  end

  test "should have requested_budget_model attachment" do
    edition = create(:impulsa_edition)
    assert_respond_to edition, :requested_budget_model
  end

  test "should have monitoring_evaluation_model attachment" do
    edition = create(:impulsa_edition)
    assert_respond_to edition, :monitoring_evaluation_model
  end
end
