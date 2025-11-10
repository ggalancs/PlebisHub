# frozen_string_literal: true

PlebisCollaborations::Engine.routes.draw do
  scope module: 'plebis_collaborations' do
    # Collaboration routes
    scope path: 'microcreditos' do
      delete 'baja', to: 'collaborations#destroy', as: 'destroy_collaboration'
      get 'ver', to: 'collaborations#edit', as: 'edit_collaboration'
      get '', to: 'collaborations#new', as: 'new_collaboration'
      get 'confirmar', to: 'collaborations#confirm', as: 'confirm_collaboration'
      post 'crear', to: 'collaborations#create', as: 'create_collaboration'
      post 'modificar', to: 'collaborations#modify', as: 'modify_collaboration'
      get 'puntual', to: 'collaborations#single', as: 'single_collaboration'
      get 'OK', to: 'collaborations#OK', as: 'ok_collaboration'
      get 'KO', to: 'collaborations#KO', as: 'ko_collaboration'
    end
  end
end
