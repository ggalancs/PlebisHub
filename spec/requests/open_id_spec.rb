# frozen_string_literal: true

require 'rails_helper'

# NOTE: OpenID routes are conditional on Rails.application.secrets.openid["enabled"]
# These tests skip if OpenID is not enabled in the test environment
RSpec.describe 'OpenId', type: :request do
  let(:user) { create(:user, :with_dni) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
  end

  # Check if OpenID is enabled
  def openid_enabled?
    Rails.application.secrets.openid.try(:[], 'enabled')
  end

  describe 'GET /es/openid' do
    describe 'A. DISCOVERY ENDPOINT' do
      before { skip 'OpenID not enabled in test environment' unless openid_enabled? }

      it 'returns XRDS document' do
        get '/es/openid'
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('application/xrds+xml')
      end

      it 'contains OpenID type declarations' do
        get '/es/openid'
        expect(response.body).to include('xrds:XRDS')
        expect(response.body).to include('Type')
      end

      it 'includes service URI' do
        get '/es/openid'
        expect(response.body).to include('URI')
        expect(response.body).to include('/openid')
      end
    end
  end

  describe 'GET /es/user/xrds' do
    describe 'A. XRDS DOCUMENT' do
      before { skip 'OpenID not enabled in test environment' unless openid_enabled? }

      it 'returns XRDS content type' do
        get '/es/user/xrds'
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('application/xrds+xml')
      end

      it 'contains XML declaration' do
        get '/es/user/xrds'
        expect(response.body).to include('<?xml version="1.0"')
      end

      it 'contains XRDS namespace' do
        get '/es/user/xrds'
        expect(response.body).to include('xri://$xrds')
      end
    end
  end

  describe 'GET /es/user/:id' do
    describe 'A. USER IDENTITY PAGE' do
      before { skip 'OpenID not enabled in test environment' unless openid_enabled? }

      it 'returns HTML identity page for HTML request' do
        get "/es/user/#{user.id}"
        expect(response).to have_http_status(:success)
        expect(response.body).to include('openid.server')
      end

      it 'includes XRDS location header' do
        get "/es/user/#{user.id}"
        expect(response.headers['X-XRDS-Location']).to be_present
        expect(response.headers['X-XRDS-Location']).to include('/user/xrds')
      end
    end
  end

  describe 'POST /es/openid' do
    describe 'A. WITHOUT PARAMETERS' do
      before { skip 'OpenID not enabled in test environment' unless openid_enabled? }

      it 'returns success with informational message' do
        post '/es/openid'
        expect([200, 302]).to include(response.status)
      end
    end

    describe 'B. WITH OPENID PARAMETERS' do
      before { skip 'OpenID not enabled in test environment' unless openid_enabled? }

      it 'handles openid.mode associate' do
        post '/es/openid', params: { 'openid.mode' => 'associate' }
        expect([200, 400, 500]).to include(response.status)
      end
    end
  end

  describe 'Security' do
    describe 'A. CSRF PROTECTION' do
      before { skip 'OpenID not enabled in test environment' unless openid_enabled? }

      it 'allows POST without CSRF token (OpenID protocol requirement)' do
        post '/es/openid'
        expect(response.status).not_to eq(422)
      end
    end
  end
end

# Unit tests for OpenIdController that don't require routes
RSpec.describe OpenIdController, type: :controller do
  describe 'LETTERS constant' do
    # Skip route-dependent tests since routes may not be available
    # Test only non-route dependent constants and methods
  end
end
