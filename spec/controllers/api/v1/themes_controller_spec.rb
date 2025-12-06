# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ThemesController, type: :controller do
  let(:theme) { create(:theme_setting) rescue double('ThemeSetting', id: 1, name: 'Test Theme', is_active: false) }
  let(:admin_user) { create(:user, :admin) rescue create(:user) }
  let(:regular_user) { create(:user) }

  before do
    # Mock ThemeSetting model if it doesn't exist
    unless defined?(ThemeSetting)
      stub_const('ThemeSetting', Class.new)
      allow(ThemeSetting).to receive(:order).and_return(ThemeSetting)
      allow(ThemeSetting).to receive(:offset).and_return(ThemeSetting)
      allow(ThemeSetting).to receive(:limit).and_return([theme])
      allow(ThemeSetting).to receive(:count).and_return(1)
      allow(ThemeSetting).to receive(:find).and_return(theme)
      allow(ThemeSetting).to receive(:active).and_return(theme)
      allow(ThemeSetting).to receive(:lock).and_return(ThemeSetting)
      allow(ThemeSetting).to receive(:update_all)
    end
  end

  describe 'GET #index' do
    it 'returns http success' do
      allow(theme).to receive(:to_theme_json).and_return({})
      get :index, format: :json
      expect(response).to have_http_status(:success)
    end

    it 'returns JSON with themes array' do
      allow(theme).to receive(:to_theme_json).and_return({ id: 1 })
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json['themes']).to be_an(Array)
    end

    it 'includes pagination metadata' do
      allow(theme).to receive(:to_theme_json).and_return({})
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json['meta']).to be_present
      expect(json['meta']['current_page']).to be_present
      expect(json['meta']['per_page']).to be_present
      expect(json['meta']['total_count']).to be_present
      expect(json['meta']['total_pages']).to be_present
    end

    it 'defaults to page 1' do
      allow(theme).to receive(:to_theme_json).and_return({})
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json['meta']['current_page']).to eq(1)
    end

    it 'defaults to 20 per page' do
      allow(theme).to receive(:to_theme_json).and_return({})
      get :index, format: :json
      json = JSON.parse(response.body)
      expect(json['meta']['per_page']).to eq(20)
    end

    it 'respects page parameter' do
      allow(theme).to receive(:to_theme_json).and_return({})
      get :index, params: { page: 2 }, format: :json
      json = JSON.parse(response.body)
      expect(json['meta']['current_page']).to eq(2)
    end

    it 'respects per_page parameter' do
      allow(theme).to receive(:to_theme_json).and_return({})
      get :index, params: { per_page: 10 }, format: :json
      json = JSON.parse(response.body)
      expect(json['meta']['per_page']).to eq(10)
    end

    it 'limits per_page to maximum 100' do
      allow(theme).to receive(:to_theme_json).and_return({})
      get :index, params: { per_page: 200 }, format: :json
      json = JSON.parse(response.body)
      expect(json['meta']['per_page']).to eq(100)
    end

    it 'sets per_page to 20 for invalid values' do
      allow(theme).to receive(:to_theme_json).and_return({})
      get :index, params: { per_page: -5 }, format: :json
      json = JSON.parse(response.body)
      expect(json['meta']['per_page']).to eq(20)
    end

    it 'calculates total_pages correctly' do
      allow(ThemeSetting).to receive(:count).and_return(45)
      allow(theme).to receive(:to_theme_json).and_return({})
      get :index, params: { per_page: 20 }, format: :json
      json = JSON.parse(response.body)
      expect(json['meta']['total_pages']).to eq(3) # ceil(45/20)
    end
  end

  describe 'GET #show' do
    context 'when theme exists' do
      it 'returns http success' do
        allow(theme).to receive(:to_theme_json).and_return({})
        get :show, params: { id: theme.id }, format: :json
        expect(response).to have_http_status(:success)
      end

      it 'returns theme JSON' do
        allow(theme).to receive(:to_theme_json).and_return({ id: theme.id, name: theme.name })
        get :show, params: { id: theme.id }, format: :json
        json = JSON.parse(response.body)
        expect(json['id']).to eq(theme.id)
        expect(json['name']).to eq(theme.name)
      end
    end

    context 'when theme does not exist' do
      before do
        allow(ThemeSetting).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      end

      it 'returns http not_found' do
        get :show, params: { id: 999 }, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error JSON' do
        get :show, params: { id: 999 }, format: :json
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['error']).to include('no encontrado')
      end
    end
  end

  describe 'POST #activate' do
    before do
      allow(theme).to receive(:update!).and_return(true)
      allow(theme).to receive(:lock!).and_return(theme)
      allow(theme).to receive(:to_theme_json).and_return({ id: theme.id })
    end

    context 'when user is admin' do
      before do
        sign_in admin_user
        allow(admin_user).to receive(:is_admin?).and_return(true)
      end

      it 'returns http success' do
        post :activate, params: { id: theme.id }, format: :json
        expect(response).to have_http_status(:success)
      end

      it 'deactivates all other themes' do
        expect(ThemeSetting).to receive(:update_all).with(is_active: false)
        post :activate, params: { id: theme.id }, format: :json
      end

      it 'activates the specified theme' do
        expect(theme).to receive(:update!).with(is_active: true)
        post :activate, params: { id: theme.id }, format: :json
      end

      it 'invalidates cache' do
        expect(Rails.cache).to receive(:delete).with('active_theme')
        post :activate, params: { id: theme.id }, format: :json
      end

      it 'returns success JSON' do
        post :activate, params: { id: theme.id }, format: :json
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['message']).to include('activado exitosamente')
      end

      it 'uses database transaction' do
        expect(ActiveRecord::Base).to receive(:transaction).and_yield
        post :activate, params: { id: theme.id }, format: :json
      end
    end

    context 'when user is not admin' do
      before do
        sign_in regular_user
        allow(regular_user).to receive(:is_admin?).and_return(false)
      end

      it 'returns http forbidden' do
        post :activate, params: { id: theme.id }, format: :json
        expect(response).to have_http_status(:forbidden)
      end

      it 'returns error JSON' do
        post :activate, params: { id: theme.id }, format: :json
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['error']).to include('permisos')
      end
    end

    context 'when user is not logged in' do
      it 'returns http forbidden' do
        post :activate, params: { id: theme.id }, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when validation fails' do
      before do
        sign_in admin_user
        allow(admin_user).to receive(:is_admin?).and_return(true)
        allow(theme).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(theme))
        allow(theme).to receive(:errors).and_return(double(full_messages: ['Error message']))
      end

      it 'returns http unprocessable_content' do
        post :activate, params: { id: theme.id }, format: :json
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns error details' do
        post :activate, params: { id: theme.id }, format: :json
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['details']).to be_present
      end
    end

    context 'when unexpected error occurs' do
      before do
        sign_in admin_user
        allow(admin_user).to receive(:is_admin?).and_return(true)
        allow(theme).to receive(:update!).and_raise(StandardError.new('DB error'))
      end

      it 'returns http internal_server_error' do
        post :activate, params: { id: theme.id }, format: :json
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'logs the error' do
        allow(Rails.logger).to receive(:error).and_call_original
        post :activate, params: { id: theme.id }, format: :json
        expect(Rails.logger).to have_received(:error).with(/Theme activation failed/).at_least(:once)
      end
    end
  end

  describe 'GET #active' do
    context 'when active theme exists' do
      before do
        allow(ThemeSetting).to receive(:active).and_return(theme)
        allow(theme).to receive(:to_theme_json).and_return({ id: theme.id, name: 'Active Theme' })
      end

      it 'returns http success' do
        get :active, format: :json
        expect(response).to have_http_status(:success)
      end

      it 'returns active theme JSON' do
        get :active, format: :json
        json = JSON.parse(response.body)
        expect(json['name']).to eq('Active Theme')
      end
    end

    context 'when no active theme exists' do
      before do
        allow(ThemeSetting).to receive(:active).and_return(nil)
      end

      it 'returns default theme' do
        get :active, format: :json
        json = JSON.parse(response.body)
        expect(json['name']).to eq('Default')
        expect(json['colors']).to be_present
        expect(json['typography']).to be_present
      end

      it 'returns default colors' do
        get :active, format: :json
        json = JSON.parse(response.body)
        expect(json['colors']['primary']).to eq('#612d62')
        expect(json['colors']['secondary']).to eq('#269283')
        expect(json['colors']['accent']).to eq('#954e99')
      end

      it 'returns default typography' do
        get :active, format: :json
        json = JSON.parse(response.body)
        expect(json['typography']['fontPrimary']).to eq('Inter')
        expect(json['typography']['fontDisplay']).to eq('Montserrat')
      end
    end
  end
end
