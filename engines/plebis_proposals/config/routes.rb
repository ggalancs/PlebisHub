# frozen_string_literal: true

PlebisProposals::Engine.routes.draw do
  resources :proposals, only: [:index, :show] do
    collection do
      get 'info'
    end

    resources :supports, only: [:create]
  end
end
