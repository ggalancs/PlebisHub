# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParticipationTeam, type: :model do
  # ====================
  # MODEL CONFIGURATION TESTS
  # ====================

  describe 'model configuration' do
    it 'uses the correct table name' do
      expect(ParticipationTeam.table_name).to eq('participation_teams')
    end

    it 'inherits from PlebisParticipation::ParticipationTeam' do
      expect(ParticipationTeam.superclass).to eq(PlebisParticipation::ParticipationTeam)
    end

    it 'ultimately inherits from ApplicationRecord' do
      expect(PlebisParticipation::ParticipationTeam.superclass).to eq(ApplicationRecord)
    end

    it 'has correct class hierarchy' do
      expect(ParticipationTeam.ancestors).to include(PlebisParticipation::ParticipationTeam)
      expect(ParticipationTeam.ancestors).to include(ApplicationRecord)
      expect(ParticipationTeam.ancestors).to include(ActiveRecord::Base)
    end

    it 'verifies table_name is set on class load' do
      # This ensures the line "self.table_name = 'participation_teams'" is executed
      expect(PlebisParticipation::ParticipationTeam.table_name).to eq('participation_teams')
    end

    it 'has HABTM association defined' do
      # This ensures the has_and_belongs_to_many line is executed
      reflection = ParticipationTeam.reflect_on_association(:users)
      expect(reflection).not_to be_nil
      expect(reflection.macro).to eq(:has_and_belongs_to_many)
    end

    it 'verifies active scope is defined' do
      # This ensures the active scope line is executed
      expect(ParticipationTeam).to respond_to(:active)
    end

    it 'verifies inactive scope is defined' do
      # This ensures the inactive scope line is executed
      expect(ParticipationTeam).to respond_to(:inactive)
    end
  end

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

    it 'creates inactive team with trait' do
      team = create(:participation_team, :inactive)
      expect(team.active).to eq(false)
    end

    it 'creates team with users using trait' do
      team = create(:participation_team, :with_users, users_count: 5)
      expect(team.users.count).to eq(5)
    end

    it 'uses default users_count in with_users trait' do
      team = create(:participation_team, :with_users)
      expect(team.users.count).to eq(3)
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

    it 'allows assigning users collection directly' do
      team = create(:participation_team)
      users = create_list(:user, 3)

      team.users = users

      expect(team.reload.users.count).to eq(3)
      users.each { |user| expect(team.users).to include(user) }
    end

    it 'replaces users when assigning new collection' do
      team = create(:participation_team)
      old_users = create_list(:user, 2)
      new_users = create_list(:user, 3)

      team.users = old_users
      expect(team.reload.users.count).to eq(2)

      team.users = new_users
      expect(team.reload.users.count).to eq(3)
      new_users.each { |user| expect(team.users).to include(user) }
      old_users.each { |user| expect(team.users).not_to include(user) }
    end

    it 'allows clearing all users' do
      team = create(:participation_team)
      team.users << create_list(:user, 5)
      expect(team.users.count).to eq(5)

      team.users.clear

      expect(team.reload.users.count).to eq(0)
    end

    it 'supports user_ids accessor' do
      team = create(:participation_team)
      users = create_list(:user, 3)

      team.user_ids = users.map(&:id)

      expect(team.reload.users.count).to eq(3)
      expect(team.user_ids).to match_array(users.map(&:id))
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

    describe '.inactive' do
      it 'returns only inactive teams' do
        active_team = create(:participation_team, active: true)
        inactive_team = create(:participation_team, active: false)
        nil_team = create(:participation_team, active: nil)

        results = ParticipationTeam.inactive

        expect(results).not_to include(active_team)
        expect(results).to include(inactive_team)
        expect(results).not_to include(nil_team)
      end

      it 'filters correctly' do
        3.times { create(:participation_team, active: true) }
        2.times { create(:participation_team, active: false) }

        expect(ParticipationTeam.inactive.count).to eq(2)
        expect(ParticipationTeam.count).to eq(5)
      end

      it 'can be chained with other scopes' do
        inactive_team = create(:participation_team, active: false)

        results = ParticipationTeam.inactive.where(id: inactive_team.id)

        expect(results.count).to eq(1)
        expect(results.first).to eq(inactive_team)
      end
    end
  end

  # ====================
  # ATTRIBUTE TESTS
  # ====================

  describe 'attributes' do
    it 'has id attribute' do
      team = create(:participation_team)
      expect(team.id).not_to be_nil
      expect(team.id).to be_a(Integer)
    end

    it 'has name attribute' do
      team = create(:participation_team, name: 'Test Name')
      expect(team.name).to eq('Test Name')
    end

    it 'has description attribute' do
      team = create(:participation_team, description: 'Test Description')
      expect(team.description).to eq('Test Description')
    end

    it 'has active attribute' do
      team = create(:participation_team, active: true)
      expect(team.active).to eq(true)
    end

    it 'has created_at timestamp' do
      team = create(:participation_team)
      expect(team.created_at).not_to be_nil
      expect(team.created_at).to be_a(ActiveSupport::TimeWithZone)
    end

    it 'has updated_at timestamp' do
      team = create(:participation_team)
      expect(team.updated_at).not_to be_nil
      expect(team.updated_at).to be_a(ActiveSupport::TimeWithZone)
    end

    it 'updates updated_at on save' do
      team = create(:participation_team)
      original_time = team.updated_at

      sleep 0.1 # Ensure time difference
      team.update(name: 'Updated Name')

      expect(team.updated_at).to be > original_time
    end

    it 'allows setting all attributes at once' do
      team = ParticipationTeam.new(
        name: 'Bulk Team',
        description: 'Bulk Description',
        active: false
      )
      team.save!

      expect(team.name).to eq('Bulk Team')
      expect(team.description).to eq('Bulk Description')
      expect(team.active).to eq(false)
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

    it 'handles SQL injection attempts in name' do
      dangerous_name = "'; DROP TABLE participation_teams; --"
      team = create(:participation_team, name: dangerous_name)

      found = ParticipationTeam.find(team.id)
      expect(found.name).to eq(dangerous_name)
      expect(ParticipationTeam.count).to be > 0
    end

    it 'handles HTML in description' do
      html_desc = '<script>alert("XSS")</script><strong>Bold</strong>'
      team = create(:participation_team, description: html_desc)

      expect(team.description).to eq(html_desc)
    end

    it 'persists through save and reload' do
      team = create(:participation_team,
                    name: 'Persist Test',
                    description: 'Description',
                    active: false)

      team_id = team.id
      team = nil

      reloaded = ParticipationTeam.find(team_id)
      expect(reloaded.name).to eq('Persist Test')
      expect(reloaded.description).to eq('Description')
      expect(reloaded.active).to eq(false)
    end
  end

  # ====================
  # DATABASE QUERY TESTS
  # ====================

  describe 'database queries' do
    it 'can be found by id' do
      team = create(:participation_team)
      found = ParticipationTeam.find(team.id)
      expect(found).to eq(team)
    end

    it 'can be found by name' do
      team = create(:participation_team, name: 'Unique Team Name')
      found = ParticipationTeam.find_by(name: 'Unique Team Name')
      expect(found).to eq(team)
    end

    it 'returns nil for non-existent record with find_by' do
      result = ParticipationTeam.find_by(name: 'Non-existent Team')
      expect(result).to be_nil
    end

    it 'raises error for non-existent record with find' do
      expect { ParticipationTeam.find(999_999) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'supports where queries' do
      create(:participation_team, name: 'Alpha Team')
      create(:participation_team, name: 'Beta Team')
      create(:participation_team, name: 'Alpha Squad')

      results = ParticipationTeam.where('name LIKE ?', 'Alpha%')
      expect(results.count).to eq(2)
    end

    it 'supports count queries' do
      create_list(:participation_team, 5)
      expect(ParticipationTeam.count).to eq(5)
    end

    it 'supports exists? queries' do
      team = create(:participation_team)
      expect(ParticipationTeam.exists?(team.id)).to be true
      expect(ParticipationTeam.exists?(999_999)).to be false
    end

    it 'supports pluck queries' do
      teams = create_list(:participation_team, 3)
      names = ParticipationTeam.pluck(:name)
      expect(names.size).to eq(3)
      expect(names).to include(teams.first.name)
    end

    it 'supports order queries' do
      create(:participation_team, name: 'Zulu')
      create(:participation_team, name: 'Alpha')
      create(:participation_team, name: 'Bravo')

      ordered = ParticipationTeam.order(:name).pluck(:name)
      expect(ordered).to eq(['Alpha', 'Bravo', 'Zulu'])
    end

    it 'supports limit queries' do
      create_list(:participation_team, 10)
      limited = ParticipationTeam.limit(5)
      expect(limited.count).to eq(5)
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
