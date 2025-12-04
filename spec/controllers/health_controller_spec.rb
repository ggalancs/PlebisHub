# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HealthController, type: :controller do
  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end

    it 'returns JSON response by default' do
      get :show, format: :json
      expect(response.content_type).to match(%r{application/json})
    end

    it 'returns status ok' do
      get :show, format: :json
      json = JSON.parse(response.body)
      expect(json['status']).to eq('ok')
    end

    it 'includes database status' do
      get :show, format: :json
      json = JSON.parse(response.body)
      expect(json).to have_key('database')
      expect(json['database']).to eq('connected')
    end

    it 'includes version info' do
      get :show, format: :json
      json = JSON.parse(response.body)
      expect(json).to have_key('version')
      expect(json).to have_key('rails_version')
      expect(json).to have_key('ruby_version')
      expect(json).to have_key('environment')
    end

    it 'includes timestamp' do
      get :show, format: :json
      json = JSON.parse(response.body)
      expect(json).to have_key('timestamp')
      expect(json['timestamp']).to be_present
    end

    it 'returns plain text for HTML format' do
      get :show, format: :html
      expect(response.body).to eq("OK\n")
    end

    it 'returns plain text for any other format' do
      get :show, format: :xml
      expect(response.body).to eq("OK\n")
    end

    context 'with REDIS_URL configured' do
      around do |example|
        original = ENV['REDIS_URL']
        ENV['REDIS_URL'] = 'redis://localhost:6379/1'
        example.run
        ENV['REDIS_URL'] = original
      end

      it 'includes redis status when configured' do
        allow_any_instance_of(Redis).to receive(:ping).and_return('PONG')
        get :show, format: :json
        json = JSON.parse(response.body)
        expect(json).to have_key('redis')
        expect(json['redis']).to eq('connected')
      end
    end

    context 'when database is down' do
      before do
        allow(ActiveRecord::Base.connection).to receive(:execute).and_raise(ActiveRecord::ConnectionNotEstablished.new('DB down'))
      end

      it 'returns degraded status' do
        get :show, format: :json
        json = JSON.parse(response.body)
        expect(json['status']).to eq('degraded')
        expect(json['database']).to eq('disconnected')
      end

      it 'includes error message' do
        get :show, format: :json
        json = JSON.parse(response.body)
        expect(json).to have_key('database_error')
      end

      it 'returns service_unavailable status code' do
        get :show, format: :json
        expect(response).to have_http_status(:service_unavailable)
      end
    end

    context 'when redis is down' do
      around do |example|
        original = ENV['REDIS_URL']
        ENV['REDIS_URL'] = 'redis://localhost:6379/1'
        example.run
        ENV['REDIS_URL'] = original
      end

      before do
        allow(Redis).to receive(:new).and_raise(Redis::CannotConnectError.new('Redis down'))
      end

      it 'returns degraded status' do
        get :show, format: :json
        json = JSON.parse(response.body)
        expect(json['status']).to eq('degraded')
        expect(json['redis']).to eq('disconnected')
      end

      it 'includes error message' do
        get :show, format: :json
        json = JSON.parse(response.body)
        expect(json).to have_key('redis_error')
      end
    end
  end
end

