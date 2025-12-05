# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BrandSettingsController, type: :controller do
  let(:brand_setting) { create(:brand_setting) }
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    # Ensure BrandSetting model has necessary methods
    allow(BrandSetting).to receive(:current_for_organization).and_call_original rescue nil
  end

  describe 'GET #current' do
    context 'when user is logged in' do
      before { sign_in user }

      it 'returns http success' do
        allow(BrandSetting).to receive(:current_for_organization).and_return(brand_setting)
        allow(brand_setting).to receive(:to_brand_json).and_return({})
        get :current, format: :json
        expect(response).to have_http_status(:success)
      end

      it 'returns JSON response' do
        allow(BrandSetting).to receive(:current_for_organization).and_return(brand_setting)
        allow(brand_setting).to receive(:to_brand_json).and_return({ theme: 'test' })
        get :current, format: :json
        expect(response.content_type).to match(%r{application/json})
      end

      it 'uses user organization_id' do
        user.update(organization_id: organization.id)
        expect(BrandSetting).to receive(:current_for_organization).with(organization.id).and_return(brand_setting)
        allow(brand_setting).to receive(:to_brand_json).and_return({})
        get :current, format: :json
      end
    end

    context 'when user is not logged in' do
      it 'uses params organization_id if provided' do
        expect(BrandSetting).to receive(:current_for_organization).with('123').and_return(brand_setting)
        allow(brand_setting).to receive(:to_brand_json).and_return({})
        get :current, params: { organization_id: '123' }, format: :json
      end

      it 'uses nil if no organization_id' do
        expect(BrandSetting).to receive(:current_for_organization).with(nil).and_return(brand_setting)
        allow(brand_setting).to receive(:to_brand_json).and_return({})
        get :current, format: :json
      end
    end

    context 'when error occurs' do
      before do
        allow(BrandSetting).to receive(:current_for_organization).and_raise(StandardError.new('DB error'))
      end

      it 'returns http internal_server_error' do
        get :current, format: :json
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns error JSON with fallback' do
        get :current, format: :json
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['error']).to be_present
        expect(json['fallback']).to be_present
        expect(json['fallback']['theme']).to be_present
      end

      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with(/Brand settings fetch failed/)
        get :current, format: :json
      end

      it 'returns default brand colors in fallback' do
        get :current, format: :json
        json = JSON.parse(response.body)
        expect(json['fallback']['theme']['colors']['primary']).to eq('#612d62')
        expect(json['fallback']['theme']['colors']['secondary']).to eq('#269283')
      end
    end

    context 'CSRF protection' do
      it 'skips authenticity token for current action' do
        allow(BrandSetting).to receive(:current_for_organization).and_return(brand_setting)
        allow(brand_setting).to receive(:to_brand_json).and_return({})
        expect(controller).not_to receive(:verify_authenticity_token)
        get :current, format: :json
      end
    end
  end

  describe 'GET #show' do
    context 'when brand setting exists' do
      it 'returns http success' do
        allow(BrandSetting).to receive(:find).and_return(brand_setting)
        allow(brand_setting).to receive(:to_brand_json).and_return({})
        get :show, params: { id: brand_setting.id }, format: :json
        expect(response).to have_http_status(:success)
      end

      it 'returns brand setting JSON' do
        allow(BrandSetting).to receive(:find).and_return(brand_setting)
        allow(brand_setting).to receive(:to_brand_json).and_return({ id: brand_setting.id, theme: 'test' })
        get :show, params: { id: brand_setting.id }, format: :json
        json = JSON.parse(response.body)
        expect(json['id']).to eq(brand_setting.id)
      end

      it 'calls to_brand_json on brand setting' do
        allow(BrandSetting).to receive(:find).and_return(brand_setting)
        expect(brand_setting).to receive(:to_brand_json).and_return({})
        get :show, params: { id: brand_setting.id }, format: :json
      end
    end

    context 'when brand setting does not exist' do
      before do
        allow(BrandSetting).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      end

      it 'returns http not_found' do
        get :show, params: { id: 999 }, format: :json
        expect(response).to have_http_status(:not_found)
      end

      it 'returns error JSON' do
        get :show, params: { id: 999 }, format: :json
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['error']).to include('no encontrada')
      end
    end

    context 'CSRF protection' do
      it 'skips authenticity token for show action' do
        allow(BrandSetting).to receive(:find).and_return(brand_setting)
        allow(brand_setting).to receive(:to_brand_json).and_return({})
        expect(controller).not_to receive(:verify_authenticity_token)
        get :show, params: { id: brand_setting.id }, format: :json
      end
    end
  end

  describe '#default_brand_json' do
    it 'returns complete default brand configuration' do
      result = controller.send(:default_brand_json)
      expect(result[:theme]).to be_present
      expect(result[:theme][:id]).to eq('default')
      expect(result[:theme][:name]).to eq('PlebisHub Default')
      expect(result[:theme][:colors]).to be_present
    end

    it 'includes primary colors' do
      result = controller.send(:default_brand_json)
      colors = result[:theme][:colors]
      expect(colors[:primary]).to eq('#612d62')
      expect(colors[:primaryLight]).to eq('#8a4f98')
      expect(colors[:primaryDark]).to eq('#4c244a')
    end

    it 'includes secondary colors' do
      result = controller.send(:default_brand_json)
      colors = result[:theme][:colors]
      expect(colors[:secondary]).to eq('#269283')
      expect(colors[:secondaryLight]).to eq('#14b8a6')
      expect(colors[:secondaryDark]).to eq('#0f766e')
    end

    it 'marks as active and global scope' do
      result = controller.send(:default_brand_json)
      expect(result[:scope]).to eq('global')
      expect(result[:active]).to be true
      expect(result[:version]).to eq(1)
    end
  end
end
