# frozen_string_literal: true

PlebisVotes::Engine.routes.draw do
  # Vote routes
  scope module: 'plebis_votes' do
    get '/vote/create/:election_id', to: 'vote#create', as: :create_vote
    get '/vote/create_token/:election_id', to: 'vote#create_token', as: :create_token_vote
    get '/vote/check/:election_id', to: 'vote#check', as: :check_vote

    get '/vote/sms_check/:election_id', to: 'vote#sms_check', as: :sms_check_vote
    get '/vote/send_sms_check/:election_id', to: 'vote#send_sms_check', as: :send_sms_check_vote

    get '/votos/:election_id/:token', to: 'vote#election_votes_count', as: 'election_votes_count'
    get '/votos/:election_id/:election_location_id/:token', to: 'vote#election_location_votes_count', as: 'election_location_votes_count'
    match '/paper_vote/:election_id/:election_location_id/:token', to: 'vote#paper_vote', as: 'election_location_paper_vote', via: %w(get post)
  end
end
