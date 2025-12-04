# frozen_string_literal: true

PlebisImpulsa::Engine.routes.draw do
  scope :impulsa do
    get '', to: 'impulsa#index', as: 'impulsa'
    get 'proyecto', to: 'impulsa#project', as: 'project_impulsa'
    get 'proyecto/:step', to: 'impulsa#project_step', as: 'project_step_impulsa'
    get 'evaluacion', to: 'impulsa#evaluation', as: 'evaluation_impulsa'
    post 'revisar', to: 'impulsa#review', as: 'review_impulsa'
    delete 'proyecto/borrar', to: 'impulsa#delete', as: 'delete_impulsa'
    post 'modificar', to: 'impulsa#update', as: 'update_impulsa'
    post 'modificar/:step', to: 'impulsa#update_step', as: 'update_step_impulsa'
    post 'subir/:step/:field', to: 'impulsa#upload', as: 'upload_impulsa', constraints: { field: %r{[^/]*} }
    delete 'borrar/:step/:field', to: 'impulsa#delete_file', as: 'delete_file_impulsa',
                                  constraints: { field: %r{[^/]*} }
    get 'descargar/:field', to: 'impulsa#download', as: 'download_impulsa', constraints: { field: %r{[^/]*} }
  end
end
