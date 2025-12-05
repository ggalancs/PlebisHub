# frozen_string_literal: true

require 'rails_helper'

module PlebisParticipation
  RSpec.describe ParticipationTeam, type: :model do
    describe 'associations' do
      it { is_expected.to have_and_belong_to_many(:users) }
    end

    describe 'scopes' do
      describe '.active' do
        it 'returns teams that are active' do
          active_team = create(:participation_team, active: true)
          inactive_team = create(:participation_team, active: false)

          expect(ParticipationTeam.active).to include(active_team)
          expect(ParticipationTeam.active).not_to include(inactive_team)
        end
      end

      describe '.inactive' do
        it 'returns teams that are inactive' do
          active_team = create(:participation_team, active: true)
          inactive_team = create(:participation_team, active: false)

          expect(ParticipationTeam.inactive).to include(inactive_team)
          expect(ParticipationTeam.inactive).not_to include(active_team)
        end
      end
    end

    describe 'table name' do
      it 'uses participation_teams table' do
        expect(ParticipationTeam.table_name).to eq('participation_teams')
      end
    end

    describe 'factory' do
      it 'has a valid factory' do
        team = build(:participation_team)
        expect(team).to be_valid
      end

      it 'creates a team with all required attributes' do
        team = create(:participation_team)
        expect(team).to be_persisted
      end
    end
  end
end
