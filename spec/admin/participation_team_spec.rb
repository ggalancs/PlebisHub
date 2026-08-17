# frozen_string_literal: true

require 'rails_helper'

# Pantalla registrada durante el upgrade a Rails 8, sin specs hasta ahora (29,03%).
RSpec.describe 'ParticipationTeam Admin', type: :request do
  let(:admin_user) { create(:user, :admin, :superadmin) }
  let!(:team) do
    create(:participation_team, name: 'Equipo de prueba', description: 'Descripcion del equipo', active: true)
  end

  before { sign_in_admin admin_user }

  describe 'GET /admin/participation_teams' do
    it 'responde correctamente' do
      get admin_participation_teams_path
      expect(response).to have_http_status(:success)
    end

    it 'muestra nombre, descripcion y estado' do
      get admin_participation_teams_path
      expect(response.body).to include('Equipo de prueba')
      expect(response.body).to include('Descripcion del equipo')
    end

    it 'incluye la columna seleccionable y el id' do
      get admin_participation_teams_path
      expect(response.body).to match(/batch_action/i)
      expect(response.body).to include(team.id.to_s)
    end

    it 'filtra por nombre' do
      create(:participation_team, name: 'Equipo distinto')
      get admin_participation_teams_path, params: { q: { name_cont: 'Equipo de prueba' } }

      expect(response.body).to include('Equipo de prueba')
      expect(response.body).not_to include('Equipo distinto')
    end

    it 'filtra por activo' do
      create(:participation_team, :inactive, name: 'Equipo inactivo')
      get admin_participation_teams_path, params: { q: { active_eq: true } }

      expect(response.body).to include('Equipo de prueba')
      expect(response.body).not_to include('Equipo inactivo')
    end
  end

  describe 'GET /admin/participation_teams/:id' do
    it 'muestra la tabla de atributos' do
      get admin_participation_team_path(team)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(team.name)
      expect(response.body).to include(team.description)
    end

    it 'calcula el numero de usuarios del equipo' do
      team.users << create_list(:user, 2)
      get admin_participation_team_path(team)

      # El bloque `row :users_count` hace team.users.count
      expect(response).to have_http_status(:success)
      expect(response.body).to include('2')
    end

    it 'muestra cero usuarios cuando el equipo esta vacio' do
      get admin_participation_team_path(team)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('0')
    end
  end

  describe 'GET /admin/participation_teams/new y /edit' do
    it 'renderiza el formulario de alta' do
      get new_admin_participation_team_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include('Participation Team')
      expect(response.body).to include('participation_team[name]')
      expect(response.body).to include('participation_team[description]')
      expect(response.body).to include('participation_team[active]')
    end

    it 'renderiza el formulario de edicion' do
      get edit_admin_participation_team_path(team)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(team.name)
    end
  end

  describe 'POST /admin/participation_teams' do
    it 'crea el equipo con los parametros permitidos' do
      expect do
        post admin_participation_teams_path, params: {
          participation_team: { name: 'Equipo nuevo', description: 'Otra descripcion', active: true }
        }
      end.to change(PlebisParticipation::ParticipationTeam, :count).by(1)

      creado = PlebisParticipation::ParticipationTeam.find_by(name: 'Equipo nuevo')
      expect(creado.description).to eq('Otra descripcion')
      expect(creado.active).to be(true)
    end
  end

  describe 'PATCH /admin/participation_teams/:id' do
    it 'actualiza el equipo' do
      patch admin_participation_team_path(team), params: { participation_team: { name: 'Equipo corregido' } }
      expect(team.reload.name).to eq('Equipo corregido')
    end
  end
end
