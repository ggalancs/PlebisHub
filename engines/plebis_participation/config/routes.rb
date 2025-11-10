# frozen_string_literal: true

PlebisParticipation::Engine.routes.draw do
  # Participation Teams routes
  # These routes are only loaded when the engine is activated

  get '/equipos-de-accion-participativa', to: 'participation_teams#index', as: 'participation_teams'
  put '/equipos-de-accion-participativa/entrar(/:team_id)', to: 'participation_teams#join', as: 'participation_teams_join'
  put '/equipos-de-accion-participativa/dejar(/:team_id)', to: 'participation_teams#leave', as: 'participation_teams_leave'
  patch '/equipos-de-accion-participativa/actualizar', to: 'participation_teams#update_user', as: 'participation_teams_update_user'
end
