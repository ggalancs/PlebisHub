# frozen_string_literal: true

PlebisMicrocredit::Engine.routes.draw do
  # Microcredit campaigns and loans routes
  get '/microcreditos', to: 'microcredit#index', as: 'microcredit'
  get '/microcréditos', to: redirect('/microcreditos')
  get '/microcreditos/provincias', to: 'microcredit#provinces'
  get '/microcreditos/municipios', to: 'microcredit#towns'
  get '/microcreditos/informacion', to: 'microcredit#info', as: 'microcredits_info'
  get '/microcreditos/informacion/papeletas_con_futuro', to: 'microcredit#info_mailing', as: 'microcredits_info_mailing'
  get '/microcreditos/informacion/euskera', to: 'microcredit#info_euskera', as: 'microcredits_info_euskera'
  get '/microcreditos/renovar(/:loan_id/:hash)', to: 'microcredit#renewal', as: :renewal_microcredit_loan
  get '/microcreditos/:id', to: 'microcredit#new_loan', as: :new_microcredit_loan
  get '/microcreditos/:id/detalle', to: 'microcredit#show_options', as: :show_microcredit_options_detail
  get '/microcreditos/:id/login', to: 'microcredit#login', as: :microcredit_login
  post '/microcreditos/:id', to: 'microcredit#create_loan', as: :create_microcredit_loan
  get '/microcreditos/:id/renovar(/:loan_id/:hash)', to: 'microcredit#loans_renewal', as: :loans_renewal_microcredit_loan
  post '/microcreditos/:id/renovar/:loan_id/:hash', to: 'microcredit#loans_renew', as: :loans_renew_microcredit_loan
end
