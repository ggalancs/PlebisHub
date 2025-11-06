require "test_helper"

class ImpulsaProjectTest < ActiveSupport::TestCase
  # Factory Test
  test "factory creates valid impulsa_project" do
    project = build(:impulsa_project)
    assert project.valid?, "Factory should create valid project. Errors: #{project.errors.full_messages.join(', ')}"
  end

  # Association Tests
  test "should belong to impulsa_edition_category" do
    project = create(:impulsa_project)
    assert_respond_to project, :impulsa_edition_category
  end

  test "should belong to user with soft delete" do
    project = create(:impulsa_project)
    assert_respond_to project, :user

    user = project.user
    user.destroy
    project.reload
    assert_not_nil project.user # Should still load deleted user
  end

  test "should have one impulsa_edition through category" do
    project = create(:impulsa_project)
    assert_respond_to project, :impulsa_edition
  end

  test "should have many impulsa_project_state_transitions" do
    project = create(:impulsa_project)
    assert_respond_to project, :impulsa_project_state_transitions
  end

  test "should have many impulsa_project_topics" do
    project = create(:impulsa_project)
    assert_respond_to project, :impulsa_project_topics
  end

  # Validation Tests
  test "should require name" do
    project = build(:impulsa_project, name: nil)
    assert_not project.valid?
    assert_includes project.errors[:name], "no puede estar en blanco"
  end

  test "should require impulsa_edition_category_id" do
    project = build(:impulsa_project, impulsa_edition_category_id: nil)
    assert_not project.valid?
    assert_includes project.errors[:impulsa_edition_category_id], "no puede estar en blanco"
  end

  test "should require status" do
    project = build(:impulsa_project, status: nil)
    assert_not project.valid?
    assert_includes project.errors[:status], "no puede estar en blanco"
  end

  test "should require terms_of_service acceptance" do
    project = build(:impulsa_project, terms_of_service: false)
    assert_not project.valid?
    assert_includes project.errors[:terms_of_service], "debe ser aceptado"
  end

  test "should require data_truthfulness acceptance" do
    project = build(:impulsa_project, data_truthfulness: false)
    assert_not project.valid?
    assert_includes project.errors[:data_truthfulness], "debe ser aceptado"
  end

  test "should require content_rights acceptance" do
    project = build(:impulsa_project, content_rights: false)
    assert_not project.valid?
    assert_includes project.errors[:content_rights], "debe ser aceptado"
  end

  # Scope Tests
  test "by_status scope should filter by status" do
    project_status_0 = create(:impulsa_project, status: 0)
    project_status_6 = create(:impulsa_project, status: 6)

    result = ImpulsaProject.by_status(0)
    assert_includes result, project_status_0
    assert_not_includes result, project_status_6
  end

  test "first_phase scope should return projects with status 0-3" do
    first_phase_project = create(:impulsa_project, status: 1)
    second_phase_project = create(:impulsa_project, status: 6)

    result = ImpulsaProject.first_phase
    assert_includes result, first_phase_project
    assert_not_includes result, second_phase_project
  end

  test "second_phase scope should return projects with status 4 or 6" do
    second_phase_project = create(:impulsa_project, status: 6)
    first_phase_project = create(:impulsa_project, status: 1)

    result = ImpulsaProject.second_phase
    assert_includes result, second_phase_project
    assert_not_includes result, first_phase_project
  end

  test "votable scope should return projects with status 6" do
    votable_project = create(:impulsa_project, status: 6)
    non_votable_project = create(:impulsa_project, status: 1)

    result = ImpulsaProject.votable
    assert_includes result, votable_project
    assert_not_includes result, non_votable_project
  end

  test "public_visible scope should return projects with status 9, 6, or 7" do
    visible_project = create(:impulsa_project, status: 6)
    hidden_project = create(:impulsa_project, status: 1)

    result = ImpulsaProject.public_visible
    assert_includes result, visible_project
    assert_not_includes result, hidden_project
  end

  # Instance Method Tests
  test "voting_dates should return formatted date range" do
    edition = create(:impulsa_edition, :active)
    category = create(:impulsa_edition_category, impulsa_edition: edition)
    project = create(:impulsa_project, impulsa_edition_category: category)

    dates = project.voting_dates
    assert_kind_of String, dates
    assert_match(/al/, dates) # Should contain " al " separator
  end

  test "files_folder should return path to project files" do
    project = create(:impulsa_project)
    folder = project.files_folder

    assert_kind_of String, folder
    assert_includes folder, "impulsa_projects"
    assert_includes folder, project.id.to_s
  end
end
