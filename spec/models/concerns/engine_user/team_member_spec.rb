# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EngineUser::TeamMember, type: :model do
  let(:user) { create(:user) }
  let(:team1) { create(:participation_team, name: 'Team Alpha') }
  let(:team2) { create(:participation_team, name: 'Team Beta') }

  describe '#in_participation_team?' do
    context 'when user is member of the team' do
      before do
        user.participation_teams << team1
      end

      it 'returns true' do
        expect(user.in_participation_team?(team1.id)).to be true
      end
    end

    context 'when user is not member of the team' do
      it 'returns false' do
        expect(user.in_participation_team?(team2.id)).to be false
      end
    end

    context 'when user has multiple teams' do
      before do
        user.participation_teams << team1
        user.participation_teams << team2
      end

      it 'correctly identifies membership in first team' do
        expect(user.in_participation_team?(team1.id)).to be true
      end

      it 'correctly identifies membership in second team' do
        expect(user.in_participation_team?(team2.id)).to be true
      end
    end

    context 'when team_id does not exist' do
      it 'returns false for non-existent team' do
        expect(user.in_participation_team?(99999)).to be false
      end
    end

    context 'when team_id is nil' do
      it 'returns false for nil team_id' do
        expect(user.in_participation_team?(nil)).to be false
      end
    end
  end

  describe 'associations' do
    it 'has has_and_belongs_to_many association with participation_teams' do
      expect(user).to respond_to(:participation_teams)
      expect(user.participation_teams).to be_an(ActiveRecord::Relation)
    end

    it 'defines association with correct class_name' do
      reflection = user.class.reflect_on_association(:participation_teams)
      expect(reflection).not_to be_nil
      expect(reflection.macro).to eq(:has_and_belongs_to_many)
      expect(reflection.options[:class_name]).to eq('PlebisParticipation::ParticipationTeam')
    end

    it 'allows adding teams' do
      user.participation_teams << team1
      expect(user.participation_teams).to include(team1)
    end

    it 'allows removing teams' do
      user.participation_teams << team1
      user.participation_teams.delete(team1)
      expect(user.participation_teams).not_to include(team1)
    end

    it 'returns participation_team_ids' do
      user.participation_teams << team1
      user.participation_teams << team2
      expect(user.participation_team_ids).to match_array([team1.id, team2.id])
    end
  end
end
