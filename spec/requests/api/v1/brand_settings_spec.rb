# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::BrandSettings', type: :request do
  before do
    # Clear any existing brand settings
    BrandSetting.destroy_all
  end

  describe 'GET /api/v1/brand_settings/current' do
    context 'when no organization_id is provided' do
      it 'returns the active global brand setting' do
        global_setting = BrandSetting.create!(
          name: 'Global Theme',
          scope: 'global',
          theme_id: 'ocean',
          active: true
        )

        get '/api/v1/brand_settings/current'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json['theme']['id']).to eq('ocean')
        expect(json['theme']['name']).to eq('Ocean Blue')
        expect(json['scope']).to eq('global')
        expect(json['active']).to be true
      end

      it 'returns default theme when no settings exist' do
        get '/api/v1/brand_settings/current'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json['theme']['id']).to eq('default')
        expect(json['theme']['colors']['primary']).to eq('#612d62')
      end
    end

    context 'when organization_id is provided' do
      it 'returns organization-specific setting if exists' do
        organization = Organization.create!(name: 'Test Org')

        global_setting = BrandSetting.create!(
          name: 'Global',
          scope: 'global',
          theme_id: 'default',
          active: true
        )

        org_setting = BrandSetting.create!(
          name: 'Org Theme',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'sunset',
          active: true
        )

        get "/api/v1/brand_settings/current?organization_id=#{organization.id}"

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json['theme']['id']).to eq('sunset')
        expect(json['scope']).to eq('organization')
      end

      it 'falls back to global setting when no org setting exists' do
        organization = Organization.create!(name: 'Test Org')

        global_setting = BrandSetting.create!(
          name: 'Global',
          scope: 'global',
          theme_id: 'forest',
          active: true
        )

        get "/api/v1/brand_settings/current?organization_id=#{organization.id}"

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json['theme']['id']).to eq('forest')
        expect(json['scope']).to eq('global')
      end
    end

    context 'with custom colors' do
      it 'returns custom colors when present' do
        setting = BrandSetting.create!(
          name: 'Custom Theme',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#ff0000',
          secondary_color: '#00ff00',
          active: true
        )

        get '/api/v1/brand_settings/current'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json['customColors']).not_to be_nil
        expect(json['customColors']['primary']).to eq('#ff0000')
        expect(json['customColors']['secondary']).to eq('#00ff00')
      end
    end

    context 'error handling' do
      it 'returns fallback data on internal errors' do
        allow(BrandSetting).to receive(:current_for_organization).and_raise(StandardError, 'Database error')

        get '/api/v1/brand_settings/current'

        expect(response).to have_http_status(:internal_server_error)
        json = JSON.parse(response.body)

        expect(json['success']).to be false
        expect(json['error']).to be_present
        expect(json['fallback']).to be_present
        expect(json['fallback']['theme']['id']).to eq('default')
      end
    end

    context 'with authenticated user' do
      let(:user) { User.create!(email: 'test@example.com', password: 'password123', first_name: 'Test', last_name: 'User', document_vatid: '12345678Z', document_type: 1, born_at: 25.years.ago) }
      let(:organization) { Organization.create!(name: 'User Org') }

      before do
        user.update!(organization_id: organization.id)
        sign_in user
      end

      it 'uses current user organization_id' do
        org_setting = BrandSetting.create!(
          name: 'User Org Theme',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'monochrome',
          active: true
        )

        get '/api/v1/brand_settings/current'

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json['theme']['id']).to eq('monochrome')
        expect(json['organizationId']).to eq(organization.id)
      end
    end
  end

  describe 'GET /api/v1/brand_settings/:id' do
    it 'returns specific brand setting' do
      setting = BrandSetting.create!(
        name: 'Specific Theme',
        description: 'A specific theme for testing',
        scope: 'global',
        theme_id: 'ocean',
        active: true
      )

      get "/api/v1/brand_settings/#{setting.id}"

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json['theme']['id']).to eq('ocean')
      expect(json['theme']['name']).to eq('Ocean Blue')
      expect(json['theme']['description']).to eq('Cool blue tones')
    end

    it 'returns 404 for non-existent setting' do
      get '/api/v1/brand_settings/99999'

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)

      expect(json['success']).to be false
      expect(json['error']).to include('no encontrada')
    end

    context 'JSON structure validation' do
      it 'includes all required fields in response' do
        setting = BrandSetting.create!(
          name: 'Complete Theme',
          scope: 'global',
          theme_id: 'default',
          active: true,
          metadata: { custom: 'value' }
        )

        get "/api/v1/brand_settings/#{setting.id}"

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        # Verify theme structure
        expect(json['theme']).to have_key('id')
        expect(json['theme']).to have_key('name')
        expect(json['theme']).to have_key('description')
        expect(json['theme']).to have_key('colors')

        # Verify colors structure
        expect(json['theme']['colors']).to have_key('primary')
        expect(json['theme']['colors']).to have_key('primaryLight')
        expect(json['theme']['colors']).to have_key('primaryDark')
        expect(json['theme']['colors']).to have_key('secondary')
        expect(json['theme']['colors']).to have_key('secondaryLight')
        expect(json['theme']['colors']).to have_key('secondaryDark')

        # Verify root fields
        expect(json).to have_key('scope')
        expect(json).to have_key('active')
        expect(json).to have_key('version')
        expect(json).to have_key('metadata')
        expect(json).to have_key('createdAt')
        expect(json).to have_key('updatedAt')
      end
    end

    context 'versioning' do
      it 'includes correct version number' do
        setting = BrandSetting.create!(
          name: 'Versioned Theme',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#612d62'
        )

        # Update to increment version
        setting.update!(primary_color: '#8a4f98')

        get "/api/v1/brand_settings/#{setting.id}"

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)

        expect(json['version']).to eq(2)
      end
    end
  end

  describe 'CORS and public access' do
    it 'allows access without authentication' do
      setting = BrandSetting.create!(
        name: 'Public Theme',
        scope: 'global',
        theme_id: 'default',
        active: true
      )

      get '/api/v1/brand_settings/current'

      expect(response).to have_http_status(:success)
    end

    it 'skips CSRF token verification' do
      # Make request without CSRF token
      get '/api/v1/brand_settings/current'

      expect(response).to have_http_status(:success)
    end
  end

  describe 'caching behavior' do
    it 'returns fresh data after brand setting update' do
      setting = BrandSetting.create!(
        name: 'Original',
        scope: 'global',
        theme_id: 'default',
        active: true
      )

      get '/api/v1/brand_settings/current'
      json1 = JSON.parse(response.body)

      # Update setting
      setting.update!(theme_id: 'ocean')

      get '/api/v1/brand_settings/current'
      json2 = JSON.parse(response.body)

      expect(json2['theme']['id']).to eq('ocean')
      expect(json2['theme']['id']).not_to eq(json1['theme']['id'])
    end
  end

  describe 'performance' do
    it 'responds quickly even with multiple settings' do
      # Create multiple settings
      10.times do |i|
        BrandSetting.create!(
          name: "Theme #{i}",
          scope: 'global',
          theme_id: 'default',
          active: false
        )
      end

      # Create one active setting
      BrandSetting.create!(
        name: 'Active Theme',
        scope: 'global',
        theme_id: 'ocean',
        active: true
      )

      start_time = Time.now
      get '/api/v1/brand_settings/current'
      duration = Time.now - start_time

      expect(response).to have_http_status(:success)
      expect(duration).to be < 1.0 # Should respond in less than 1 second
    end
  end
end
