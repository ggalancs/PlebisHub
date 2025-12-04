# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParticipationTeam, type: :model do
  # ====================
  # FACTORY TESTS
  # ====================

  describe 'factory' do
    it 'creates valid participation_team' do
      team = build(:participation_team)
      expect(team).to be_valid, 'Factory should create a valid participation_team'
    end

    it 'creates team with attributes' do
      team = create(:participation_team)
      expect(team.name).not_to be_nil
      expect(team.description).not_to be_nil
      expect(team.active).to eq(true)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    it 'allows team without name' do
      team = build(:participation_team, name: nil)
      # No validation in model, so it's valid
      expect(team).to be_valid
    end

    it 'allows team without description' do
      team = build(:participation_team, description: nil)
      expect(team).to be_valid
    end

    it 'defaults active to nil if not specified' do
      team = ParticipationTeam.new(name: 'Test')
      expect(team.active).to be_nil
    end
  end

  # ====================
  # CRUD OPERATION TESTS
  # ====================

  describe 'CRUD operations' do
    it 'creates participation_team with valid attributes' do
      expect { create(:participation_team) }.to change(ParticipationTeam, :count).by(1)
    end

    it 'reads participation_team attributes correctly' do
      team = create(:participation_team,
                    name: 'Test Team',
                    description: 'Test Description',
                    active: true)

      found_team = ParticipationTeam.find(team.id)
      expect(found_team.name).to eq('Test Team')
      expect(found_team.description).to eq('Test Description')
      expect(found_team.active).to eq(true)
    end

    it 'updates participation_team attributes' do
      team = create(:participation_team, name: 'Original Name')

      team.update(name: 'Updated Name')

      expect(team.reload.name).to eq('Updated Name')
    end

    it 'deletes participation_team' do
      team = create(:participation_team)

      expect { team.destroy }.to change(ParticipationTeam, :count).by(-1)
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'has many users through HABTM' do
      team = create(:participation_team)
      expect(team).to respond_to(:users)
    end

    it 'allows adding users to team' do
      team = create(:participation_team)
      user1 = create(:user)
      user2 = create(:user)

      team.users << user1
      team.users << user2

      expect(team.users.count).to eq(2)
      expect(team.users).to include(user1)
      expect(team.users).to include(user2)
    end

    it 'allows removing users from team' do
      team = create(:participation_team)
      user = create(:user)
      team.users << user

      expect(team.users.count).to eq(1)

      team.users.delete(user)

      expect(team.reload.users.count).to eq(0)
    end

    it 'maintains HABTM relationship' do
      team = create(:participation_team)
      user = create(:user)

      team.users << user

      # Verify from both sides
      expect(team.users).to include(user)
      expect(user.participation_teams).to include(team)
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.active' do
      it 'returns only active teams' do
        active_team = create(:participation_team, active: true)
        inactive_team = create(:participation_team, active: false)
        nil_team = create(:participation_team, active: nil)

        results = ParticipationTeam.active

        expect(results).to include(active_team)
        expect(results).not_to include(inactive_team)
        expect(results).not_to include(nil_team)
      end

      it 'filters correctly' do
        3.times { create(:participation_team, active: true) }
        2.times { create(:participation_team, active: false) }

        expect(ParticipationTeam.active.count).to eq(3)
        expect(ParticipationTeam.count).to eq(5)
      end
    end
  end

  # ====================
  # EDGE CASE TESTS
  # ====================

  describe 'edge cases' do
    it 'handles empty name' do
      team = build(:participation_team, name: '')
      expect(team).to be_valid
    end

    it 'handles very long name' do
      team = build(:participation_team, name: 'A' * 1000)
      expect(team).to be_valid
    end

    it 'handles very long description' do
      team = build(:participation_team, description: 'A' * 10_000)
      expect(team).to be_valid
    end

    it 'handles special characters in name' do
      team = build(:participation_team, name: 'Team with émojis 🎉 and symbols &@#')
      expect(team).to be_valid
    end

    it 'handles unicode in description' do
      team = build(:participation_team, description: 'Description with unicode: 你好 مرحبا שלום')
      expect(team).to be_valid
    end

    it 'allows duplicate names' do
      create(:participation_team, name: 'Duplicate')
      team2 = build(:participation_team, name: 'Duplicate')

      # No uniqueness constraint
      expect(team2).to be_valid
    end

    it 'handles nil active status' do
      team = create(:participation_team, active: nil)
      expect(team.active).to be_nil
      expect(ParticipationTeam.active).not_to include(team)
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'tracks full lifecycle of team with users' do
      initial_count = ParticipationTeam.count

      # Create team
      team = create(:participation_team, name: 'Lifecycle Team')
      expect(ParticipationTeam.count).to eq(initial_count + 1)

      # Add users
      user1 = create(:user)
      user2 = create(:user)
      team.users << user1
      team.users << user2

      # Verify associations
      expect(team.users.count).to eq(2)

      # Update team
      team.update(active: false)
      expect(team.reload.active).to eq(false)
      expect(ParticipationTeam.active).not_to include(team)

      # Remove users
      team.users.clear
      expect(team.reload.users.count).to eq(0)

      # Delete team
      team.destroy
      expect(ParticipationTeam.count).to eq(initial_count)
    end

    it 'handles multiple teams with shared users' do
      team1 = create(:participation_team, name: 'Team 1')
      team2 = create(:participation_team, name: 'Team 2')
      team3 = create(:participation_team, name: 'Team 3')

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
      expect(team1.users.count).to eq(2)
      expect(team2.users.count).to eq(2)
      expect(team3.users.count).to eq(1)

      expect(user1.participation_teams.count).to eq(3)
      expect(user2.participation_teams.count).to eq(2)
    end

    it 'maintains referential integrity' do
      team = create(:participation_team, name: 'Integrity Test')
      user = create(:user)

      team.users << user

      # Verify IDs are set correctly
      expect(team.id).not_to be_nil
      expect(user.id).not_to be_nil

      # Reload and verify persistence
      team.reload
      user.reload

      expect(team.users.pluck(:id)).to include(user.id)
      expect(user.participation_teams.pluck(:id)).to include(team.id)
    end

    it 'handles active scope with mixed statuses' do
      active = create(:participation_team, name: 'Active', active: true)
      create(:participation_team, name: 'Inactive', active: false)
      create(:participation_team, name: 'Nil Status', active: nil)

      active_teams = ParticipationTeam.active

      expect(active_teams.count).to eq(1)
      expect(active_teams.first.id).to eq(active.id)
    end

    it 'allows team to function without users' do
      team = create(:participation_team)

      expect(team.users.count).to eq(0)
      expect(team).to be_valid
    end

    it 'handles deletion of team with users' do
      team = create(:participation_team)
      user1 = create(:user)
      user2 = create(:user)

      team.users << user1
      team.users << user2

      expect(team.users.count).to eq(2)

      # Delete team
      team.destroy

      # Users should still exist
      expect(User.find(user1.id)).not_to be_nil
      expect(User.find(user2.id)).not_to be_nil

      # Users should no longer have this team
      expect(user1.reload.participation_teams).not_to include(team)
      expect(user2.reload.participation_teams).not_to include(team)
    end
  end
end
