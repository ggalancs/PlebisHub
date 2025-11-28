require 'dynamic_router'
require 'resque/server'

Rails.application.routes.draw do
  get '', to: redirect("/#{I18n.locale}")

  # redsys MerchantURL
  post '/orders/callback/redsys', to: 'orders#callback_redsys', as: 'orders_callback_redsys'

  namespace :api do
    scope :v1 do
      scope :gcm do
        post 'registrars', to: 'v1#gcm_registrate'
        delete 'registrars/:registrar_id', to: 'v1#gcm_unregister'
      end
    end

    scope :v2 do
      get 'get_data', to: 'v2#get_data'
    end

    # Theme Management API
    namespace :v1 do
      resources :themes, only: [:index, :show] do
        collection do
          get :active
        end
        member do
          post :activate
        end
      end

      # Brand Settings API
      resources :brand_settings, only: [:show] do
        collection do
          get :current
        end
      end
    end

    # CSP Violation Reporting Endpoint
    # Receives automatic reports from browsers when Content Security Policy is violated
    post 'csp-violations', to: 'csp_violations#create'
  end
  scope "/(:locale)", locale: /es|ca|eu/ do

    if Rails.application.secrets.openid.try(:[], "enabled")
      # WARNING!!
      # Enable this only for internal traffic
      # add the following line in secrets.yml to enable this:
      # openid:
      #   enabled: true

      get '/openid/discover', to: 'open_id#discover', as: "open_id_discover"
      get '/openid', to: 'open_id#index', as: "open_id_index"
      post '/openid', to: 'open_id#create', as: "open_id_create"
      get '/user/:id', to: 'open_id#user', as: "open_id_user"
      get '/user/xrds', to: 'open_id#xrds', as: "open_id_xrds"
    end

    get '/audio_captcha', to: 'audio_captcha#index', as: 'audio_captcha'

    # Mount PlebisCMS Engine - handles blog, pages, and notices
    # Routes are only loaded when engine is activated via EngineActivation
    mount PlebisCms::Engine, at: '/'

    # Mount PlebisParticipation Engine - handles participation teams
    # Routes are only loaded when engine is activated via EngineActivation
    mount PlebisParticipation::Engine, at: '/'
    mount PlebisProposals::Engine, at: '/'
    mount PlebisImpulsa::Engine, at: '/'
    mount PlebisVerification::Engine, at: '/'
    mount PlebisMicrocredit::Engine, at: '/'
    mount PlebisVotes::Engine, at: '/'
    mount PlebisCollaborations::Engine, at: '/'

    # Legacy redirect
    get '/gente-por-el-cambio', to: redirect('/equipos-de-accion-participativa')

    #get '/propuestas', to: 'proposals#index', as: 'proposals'
    #get '/propuestas/info', to: 'proposals#info', as: 'proposals_info'
    #get '/propuestas/:id', to: 'proposals#show', as: 'proposal'
    #post '/apoyar/:proposal_id', to: 'supports#create', as: 'proposal_supports'
    get '/vote/create/:election_id', to: 'vote#create', as: :create_vote
    get '/vote/create_token/:election_id', to: 'vote#create_token', as: :create_token_vote
    get '/vote/check/:election_id', to: 'vote#check', as: :check_vote

    get '/vote/sms_check/:election_id', to: 'vote#sms_check', as: :sms_check_vote
    get '/vote/send_sms_check/:election_id', to: 'vote#send_sms_check', as: :send_sms_check_vote

    get '/votos/:election_id/:token', to: 'vote#election_votes_count', as: 'election_votes_count'
    get '/votos/:election_id/:election_location_id/:token', to: 'vote#election_location_votes_count', as: 'election_location_votes_count'
    match '/paper_vote/:election_id/:election_location_id/:token', to: 'vote#paper_vote', as: 'election_location_paper_vote', via: %w(get post)

    get '/tools/militant_request/get_external_info', to:'militant#get_militant_info', as: 'user_get_militant_info'
    devise_for :users, controllers: {
      registrations: 'registrations',
      passwords:     'passwords',
      confirmations: 'confirmations',
      sessions:      'sessions'
    }

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

    authenticate :user do
      scope :validator do
        scope :sms do
          get :step1, to: 'sms_validator#step1', as: 'sms_validator_step1'
          get :step2, to: 'sms_validator#step2', as: 'sms_validator_step2'
          get :step3, to: 'sms_validator#step3', as: 'sms_validator_step3'
          post :phone, to: 'sms_validator#phone', as: 'sms_validator_phone'
          post :captcha, to: 'sms_validator#captcha', as: 'sms_validator_captcha'
          post :valid, to: 'sms_validator#valid', as: 'sms_validator_valid'
        end
      end

      scope :colabora do
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

      get 'verificacion-identidad(/:election_id)', to: 'user_verifications#new', as: 'new_user_verification'
      post 'verificacion-identidad(/:election_id)', to: 'user_verifications#create', as: 'create_user_verification'
      get 'report/(:report_code)', to: 'user_verifications#report', as: 'report_user_verification'
      get 'report_exterior/(:report_code)', to: 'user_verifications#report_exterior', as: 'report_exterior_user_verification'
      get 'report_town/(:report_code)', to: 'user_verifications#report_town', as: 'report_town_user_verification'
    end

    scope :impulsa do
      get '', to: 'impulsa#index', as: 'impulsa'
      get 'proyecto', to: 'impulsa#project', as: 'project_impulsa'
      get 'proyecto/:step', to: 'impulsa#project_step', as: 'project_step_impulsa'
      get 'evaluacion', to: 'impulsa#evaluation', as: 'evaluation_impulsa'
      post 'revisar', to: 'impulsa#review', as: 'review_impulsa'
      delete 'proyecto/borrar', to: 'impulsa#delete', as: 'delete_impulsa'
      post 'modificar', to: 'impulsa#update', as: 'update_impulsa'
      post 'modificar/:step', to: 'impulsa#update_step', as: 'update_step_impulsa'
      post 'subir/:step/:field', to: 'impulsa#upload', as: 'upload_impulsa', constraints: { field: /[^\/]*/ }
      delete 'borrar/:step/:field', to: 'impulsa#delete_file', as: 'delete_file_impulsa', constraints: { field: /[^\/]*/ }
      get 'descargar/:field', to: 'impulsa#download', as: 'download_impulsa', constraints: { field: /[^\/]*/ }
    end

    # http://stackoverflow.com/a/8884605/319241
    devise_scope :user do
      get '/registrations/regions/provinces', to: 'registrations#regions_provinces'
      get '/registrations/regions/municipies', to: 'registrations#regions_municipies'
      get '/registrations/vote/municipies', to: 'registrations#vote_municipies'
      get '/tools/militant_request', to: 'tools#militant_request', as: 'tools_militant_request'
      authenticated :user do
        root to: 'tools#index', as: :authenticated_root
        get 'password/new', to: 'legacy_password#new', as: 'new_legacy_password'
        post 'password/update', to: 'legacy_password#update', as: 'update_legacy_password'
        delete 'password/recover', to: 'registrations#recover_and_logout'
        get 'carnet_digital_con_qr', to: 'registrations#qr_code', as: 'qr_code'
      end

      unauthenticated do
        root to: 'sessions#new', as: :root
      end
    end

    %w(404 422 500).each do |code|
      get code, to: 'errors#show', code: code
    end

    DynamicRouter.load
  end
  # /admin
  post '/admin/censustool', to: 'admin/censustool#search_document_vatid', as: :admin_censustool_search_document_vatid
  ActiveAdmin.routes(self)

  # Resque admin interface (requires authentication)
  constraints CanAccessResque.new do
    mount Resque::Server.new, at: '/admin/resque', as: :resque
  end

  #get '*path' ,to: redirect("/#{I18n.locale}") # this line must be always the last line
end
