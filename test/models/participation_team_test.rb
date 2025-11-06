require 'test_helper'

class ParticipationTeamTest < ActiveSupport::TestCase
  # ====================
  # FACTORY TESTS
  # ====================

  test "factory creates valid participation_team" do
    team = build(:participation_team)
    assert team.valid?, "Factory should create a valid participation_team"
  end

  test "factory creates team with attributes" do
    team = create(:participation_team)
    assert_not_nil team.name
    assert_not_nil team.description
    assert_equal true, team.active
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  test "should allow team without name" do
    team = build(:participation_team, name: nil)
    # No validation in model, so it's valid
    assert team.valid?
  end

  test "should allow team without description" do
    team = build(:participation_team, description: nil)
    assert team.valid?
  end

  test "should default active to nil if not specified" do
    team = ParticipationTeam.new(name: "Test")
    assert_nil team.active
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  test "should create participation_team with valid attributes" do
    assert_difference('ParticipationTeam.count', 1) do
      create(:participation_team)
    end
  end

  test "should read participation_team attributes correctly" do
    team = create(:participation_team,
      name: "Test Team",
      description: "Test Description",
      active: true
    )

    found_team = ParticipationTeam.find(team.id)
    assert_equal "Test Team", found_team.name
    assert_equal "Test Description", found_team.description
    assert_equal true, found_team.active
  end

  test "should update participation_team attributes" do
    team = create(:participation_team, name: "Original Name")

    team.update(name: "Updated Name")

    assert_equal "Updated Name", team.reload.name
  end

  test "should delete participation_team" do
    team = create(:participation_team)

    assert_difference('ParticipationTeam.count', -1) do
      team.destroy
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  test "should have many users through HABTM" do
    team = create(:participation_team)
    assert_respond_to team, :users
  end

  test "should allow adding users to team" do
    team = create(:participation_team)
    user1 = create(:user)
    user2 = create(:user)

    team.users << user1
    team.users << user2

    assert_equal 2, team.users.count
    assert_includes team.users, user1
    assert_includes team.users, user2
  end

  test "should allow removing users from team" do
    team = create(:participation_team)
    user = create(:user)
    team.users << user

    assert_equal 1, team.users.count

    team.users.delete(user)

    assert_equal 0, team.reload.users.count
  end

  test "should maintain HABTM relationship" do
    team = create(:participation_team)
    user = create(:user)

    team.users << user

    # Verify from both sides
    assert_includes team.users, user
    assert_includes user.participation_teams, team
  end

  # ====================
  # SCOPE TESTS
  # ====================

  test "active scope should return only active teams" do
    active_team = create(:participation_team, active: true)
    inactive_team = create(:participation_team, active: false)
    nil_team = create(:participation_team, active: nil)

    results = ParticipationTeam.active

    assert_includes results, active_team
    assert_not_includes results, inactive_team
    assert_not_includes results, nil_team
  end

  test "active scope should filter correctly" do
    3.times { create(:participation_team, active: true) }
    2.times { create(:participation_team, active: false) }

    assert_equal 3, ParticipationTeam.active.count
    assert_equal 5, ParticipationTeam.count
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  test "should handle empty name" do
    team = build(:participation_team, name: "")
    assert team.valid?
  end

  test "should handle very long name" do
    team = build(:participation_team, name: "A" * 1000)
    assert team.valid?
  end

  test "should handle very long description" do
    team = build(:participation_team, description: "A" * 10000)
    assert team.valid?
  end

  test "should handle special characters in name" do
    team = build(:participation_team, name: "Team with émojis 🎉 and symbols &@#")
    assert team.valid?
  end

  test "should handle unicode in description" do
    team = build(:participation_team, description: "Description with unicode: 你好 مرحبا שלום")
    assert team.valid?
  end

  test "should allow duplicate names" do
    team1 = create(:participation_team, name: "Duplicate")
    team2 = build(:participation_team, name: "Duplicate")

    # No uniqueness constraint
    assert team2.valid?
  end

  test "should handle nil active status" do
    team = create(:participation_team, active: nil)
    assert_nil team.active
    assert_not_includes ParticipationTeam.active, team
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  test "should track full lifecycle of team with users" do
    initial_count = ParticipationTeam.count

    # Create team
    team = create(:participation_team, name: "Lifecycle Team")
    assert_equal initial_count + 1, ParticipationTeam.count

    # Add users
    user1 = create(:user)
    user2 = create(:user)
    team.users << user1
    team.users << user2

    # Verify associations
    assert_equal 2, team.users.count

    # Update team
    team.update(active: false)
    assert_equal false, team.reload.active
    assert_not_includes ParticipationTeam.active, team

    # Remove users
    team.users.clear
    assert_equal 0, team.reload.users.count

    # Delete team
    team.destroy
    assert_equal initial_count, ParticipationTeam.count
  end

  test "should handle multiple teams with shared users" do
    team1 = create(:participation_team, name: "Team 1")
    team2 = create(:participation_team, name: "Team 2")
    team3 = create(:participation_team, name: "Team 3")

    user1 = create(:user)
    user2 = create(:user)

    # User1 in all teams
    team1.users << user1
    team2.users << user1
    team3.users << user1

    # User2 in team1 and team2
    team1.users << user2
    team2.users << user2

    # Verify counts
    assert_equal 2, team1.users.count
    assert_equal 2, team2.users.count
    assert_equal 1, team3.users.count

    assert_equal 3, user1.participation_teams.count
    assert_equal 2, user2.participation_teams.count
  end

  test "should maintain referential integrity" do
    team = create(:participation_team, name: "Integrity Test")
    user = create(:user)

    team.users << user

    # Verify IDs are set correctly
    assert_not_nil team.id
    assert_not_nil user.id

    # Reload and verify persistence
    team.reload
    user.reload

    assert_includes team.users.pluck(:id), user.id
    assert_includes user.participation_teams.pluck(:id), team.id
  end

  test "should handle active scope with mixed statuses" do
    active = create(:participation_team, name: "Active", active: true)
    inactive = create(:participation_team, name: "Inactive", active: false)
    nil_status = create(:participation_team, name: "Nil Status", active: nil)

    active_teams = ParticipationTeam.active

    assert_equal 1, active_teams.count
    assert_equal active.id, active_teams.first.id
  end

  test "should allow team to function without users" do
    team = create(:participation_team)

    assert_equal 0, team.users.count
    assert team.valid?
  end

  test "should handle deletion of team with users" do
    team = create(:participation_team)
    user1 = create(:user)
    user2 = create(:user)

    team.users << user1
    team.users << user2

    assert_equal 2, team.users.count

    # Delete team
    team.destroy

    # Users should still exist
    assert_not_nil User.find(user1.id)
    assert_not_nil User.find(user2.id)

    # Users should no longer have this team
    assert_not_includes user1.reload.participation_teams, team
    assert_not_includes user2.reload.participation_teams, team
  end
end
