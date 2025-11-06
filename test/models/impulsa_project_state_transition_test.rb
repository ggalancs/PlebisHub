require 'test_helper'

class ImpulsaProjectStateTransitionTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid impulsa_project_state_transition" do
    transition = build(:impulsa_project_state_transition)
    assert transition.valid?, "Factory should create a valid impulsa_project_state_transition"
  end

  test "factory creates transition with attributes" do
    transition = create(:impulsa_project_state_transition)
    assert_not_nil transition.impulsa_project
    assert_not_nil transition.namespace
    assert_not_nil transition.event
    assert_not_nil transition.from
    assert_not_nil transition.to
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should require impulsa_project" do
    transition = build(:impulsa_project_state_transition, impulsa_project: nil)
    assert_not transition.valid?
    assert_includes transition.errors[:impulsa_project], "must exist"
  end

  test "should allow transition without namespace" do
    transition = build(:impulsa_project_state_transition, namespace: nil)
    # No validation in model
    assert transition.valid?
  end

  test "should allow transition without event" do
    transition = build(:impulsa_project_state_transition, event: nil)
    assert transition.valid?
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create impulsa_project_state_transition with valid attributes" do
    # Creating an ImpulsaProject automatically creates an initial state transition
    # So we expect 2 transitions: 1 from project creation + 1 explicit
    assert_difference('ImpulsaProjectStateTransition.count', 2) do
      create(:impulsa_project_state_transition)
    end
  end

  test "should read impulsa_project_state_transition attributes correctly" do
    project = create(:impulsa_project)
    transition = create(:impulsa_project_state_transition,
      impulsa_project: project,
      namespace: "test_namespace",
      event: "test_event",
      from: "state_a",
      to: "state_b"
    )

    found_transition = ImpulsaProjectStateTransition.find(transition.id)
    assert_equal project.id, found_transition.impulsa_project_id
    assert_equal "test_namespace", found_transition.namespace
    assert_equal "test_event", found_transition.event
    assert_equal "state_a", found_transition.from
    assert_equal "state_b", found_transition.to
  end

  test "should update impulsa_project_state_transition attributes" do
    transition = create(:impulsa_project_state_transition, event: "original")

    transition.update(event: "updated")

    assert_equal "updated", transition.reload.event
  end

  test "should delete impulsa_project_state_transition" do
    transition = create(:impulsa_project_state_transition)

    assert_difference('ImpulsaProjectStateTransition.count', -1) do
      transition.destroy
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should belong to impulsa_project" do
    transition = create(:impulsa_project_state_transition)
    assert_respond_to transition, :impulsa_project
    assert_instance_of ImpulsaProject, transition.impulsa_project
  end

  test "should be associated with impulsa_project" do
    project = create(:impulsa_project)
    transition = create(:impulsa_project_state_transition, impulsa_project: project)

    assert_includes project.impulsa_project_state_transitions, transition
  end

  test "should allow multiple transitions for same project" do
    project = create(:impulsa_project)
    initial_count = project.impulsa_project_state_transitions.count

    transition1 = create(:impulsa_project_state_transition,
      impulsa_project: project,
      from: "draft",
      to: "submitted"
    )

    transition2 = create(:impulsa_project_state_transition,
      impulsa_project: project,
      from: "submitted",
      to: "approved"
    )

    assert_equal initial_count + 2, project.impulsa_project_state_transitions.count
    assert_includes project.impulsa_project_state_transitions, transition1
    assert_includes project.impulsa_project_state_transitions, transition2
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle empty string values" do
    transition = build(:impulsa_project_state_transition,
      namespace: "",
      event: "",
      from: "",
      to: ""
    )
    assert transition.valid?
  end

  test "should handle very long strings" do
    transition = build(:impulsa_project_state_transition,
      namespace: "A" * 1000,
      event: "B" * 1000,
      from: "C" * 1000,
      to: "D" * 1000
    )
    assert transition.valid?
  end

  test "should handle special characters" do
    transition = build(:impulsa_project_state_transition,
      event: "submit@v2.0",
      from: "draft-pending",
      to: "submitted_for_review"
    )
    assert transition.valid?
  end

  test "should handle unicode characters" do
    transition = build(:impulsa_project_state_transition,
      event: "提交",
      from: "草稿",
      to: "已提交"
    )
    assert transition.valid?
  end

  # ====================
  # WORKFLOW TESTS
  # ====================

  test "should track state transition history" do
    project = create(:impulsa_project)
    initial_count = project.impulsa_project_state_transitions.count

    # Create transition sequence
    t1 = create(:impulsa_project_state_transition,
      impulsa_project: project,
      from: "draft",
      to: "submitted",
      event: "submit"
    )

    t2 = create(:impulsa_project_state_transition,
      impulsa_project: project,
      from: "submitted",
      to: "under_review",
      event: "review"
    )

    t3 = create(:impulsa_project_state_transition,
      impulsa_project: project,
      from: "under_review",
      to: "approved",
      event: "approve"
    )

    transitions = project.impulsa_project_state_transitions.order(created_at: :asc)

    assert_equal initial_count + 3, transitions.count
    # Check the last 3 transitions (our explicit ones)
    last_three = transitions.last(3)
    assert_equal ["draft", "submitted", "under_review"], last_three.map(&:from)
    assert_equal ["submitted", "under_review", "approved"], last_three.map(&:to)
  end

  test "should handle backward transitions (rollbacks)" do
    project = create(:impulsa_project)
    initial_count = project.impulsa_project_state_transitions.count

    forward = create(:impulsa_project_state_transition,
      impulsa_project: project,
      from: "draft",
      to: "submitted"
    )

    backward = create(:impulsa_project_state_transition,
      impulsa_project: project,
      from: "submitted",
      to: "draft",
      event: "rollback"
    )

    assert_equal initial_count + 2, project.impulsa_project_state_transitions.count
  end

  test "should maintain chronological order with created_at" do
    project = create(:impulsa_project)

    t1 = create(:impulsa_project_state_transition, impulsa_project: project, from: "a", to: "b")
    sleep 0.01
    t2 = create(:impulsa_project_state_transition, impulsa_project: project, from: "b", to: "c")
    sleep 0.01
    t3 = create(:impulsa_project_state_transition, impulsa_project: project, from: "c", to: "d")

    ordered = project.impulsa_project_state_transitions.order(created_at: :asc)

    # Check that our 3 transitions are in the correct order (last 3)
    last_three_ids = ordered.last(3).map(&:id)
    assert_equal [t1.id, t2.id, t3.id], last_three_ids
  end

  # ====================
  # QUERY TESTS
  # ====================

  test "should find transitions by event" do
    project = create(:impulsa_project)

    submit_transition = create(:impulsa_project_state_transition,
      impulsa_project: project,
      event: "submit"
    )

    approve_transition = create(:impulsa_project_state_transition,
      impulsa_project: project,
      event: "approve"
    )

    found = ImpulsaProjectStateTransition.where(event: "submit")

    assert_includes found, submit_transition
    assert_not_includes found, approve_transition
  end

  test "should find transitions by from state" do
    project = create(:impulsa_project)

    transition1 = create(:impulsa_project_state_transition,
      impulsa_project: project,
      from: "draft"
    )

    transition2 = create(:impulsa_project_state_transition,
      impulsa_project: project,
      from: "submitted"
    )

    found = ImpulsaProjectStateTransition.where(from: "draft")

    assert_includes found, transition1
    assert_not_includes found, transition2
  end

  test "should count transitions per project" do
    project1 = create(:impulsa_project)
    project2 = create(:impulsa_project)

    initial_count1 = project1.impulsa_project_state_transitions.count
    initial_count2 = project2.impulsa_project_state_transitions.count

    3.times { create(:impulsa_project_state_transition, impulsa_project: project1) }
    2.times { create(:impulsa_project_state_transition, impulsa_project: project2) }

    assert_equal initial_count1 + 3, project1.impulsa_project_state_transitions.count
    assert_equal initial_count2 + 2, project2.impulsa_project_state_transitions.count
  end
end
