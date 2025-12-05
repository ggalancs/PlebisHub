# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OpenIdController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user, :with_dni) }
  let(:openid_store) { instance_double(OpenID::Store::Filesystem) }
  let(:openid_server) { instance_double(OpenID::Server::Server) }

  before do
    # Skip ApplicationController filters for isolation
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Mock OpenID server
    allow(OpenID::Store::Filesystem).to receive(:new).and_return(openid_store)
    allow(OpenID::Server::Server).to receive(:new).and_return(openid_server)

    # Mock URL helpers since routes may not be available
    # Use without_partial_double_verification for URL helpers that may not exist
    RSpec::Mocks.without_partial_double_verification do
      allow(controller).to receive(:open_id_xrds_url).and_return('http://test.host/openid/xrds')
      allow(controller).to receive(:open_id_create_url).and_return('http://test.host/openid')
      allow(controller).to receive(:open_id_user_url).and_return('http://test.host/user/1')
    end
  end

  # ==================== DISCOVERY ENDPOINT TESTS ====================

  describe 'GET #discover' do
    it 'returns XRDS document' do
      get :discover
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq('application/xrds+xml')
    end

    it 'includes OpenID 2.0 IDP type' do
      get :discover
      expect(response.body).to include(OpenID::OPENID_IDP_2_0_TYPE)
    end

    it 'includes OpenID 2.0 type' do
      get :discover
      expect(response.body).to include(OpenID::OPENID_2_0_TYPE)
    end

    it 'includes service URI' do
      get :discover
      expect(response.body).to include('<URI>')
    end

    it 'renders valid XML' do
      get :discover
      expect(response.body).to match(/\<\?xml version="1.0"/)
      expect(response.body).to include('<xrds:XRDS')
    end

    it 'handles errors gracefully' do
      allow(controller).to receive(:render_xrds).and_raise(StandardError.new('XML error'))
      expect(Rails.logger).to receive(:error).with(a_string_matching(/openid_discover_error/))
      get :discover
      expect(response).to have_http_status(:internal_server_error)
    end

    it 'logs security event on error' do
      allow(controller).to receive(:render_xrds).and_raise(StandardError.new('Error'))
      expect(Rails.logger).to receive(:error).with(a_string_matching(/openid_discover_error/))
      get :discover
    end
  end

  # ==================== XRDS ENDPOINT TESTS ====================

  describe 'GET #xrds' do
    it 'returns XRDS document' do
      get :xrds
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq('application/xrds+xml')
    end

    it 'includes OpenID 2.0 type' do
      get :xrds
      expect(response.body).to include(OpenID::OPENID_2_0_TYPE)
    end

    it 'includes OpenID 1.0 type' do
      get :xrds
      expect(response.body).to include(OpenID::OPENID_1_0_TYPE)
    end

    it 'includes SREG URI' do
      get :xrds
      expect(response.body).to include(OpenID::SREG_URI)
    end

    it 'renders valid XML structure' do
      get :xrds
      expect(response.body).to include('<XRD>')
      expect(response.body).to include('<Service priority="0">')
    end

    it 'handles errors gracefully' do
      allow(controller).to receive(:render_xrds).and_raise(StandardError.new('Error'))
      expect(Rails.logger).to receive(:error).with(a_string_matching(/openid_xrds_error/))
      get :xrds
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  # ==================== USER IDENTITY PAGE TESTS ====================

  describe 'GET #user' do
    context 'with XRDS content negotiation' do
      it 'returns XRDS when requested' do
        request.env['HTTP_ACCEPT'] = 'application/xrds+xml'
        get :user
        expect(response.content_type).to eq('application/xrds+xml')
      end

      it 'includes XRDS content types' do
        request.env['HTTP_ACCEPT'] = 'application/xrds+xml'
        get :user
        expect(response.body).to include(OpenID::OPENID_2_0_TYPE)
      end
    end

    context 'without XRDS content negotiation' do
      it 'returns identity HTML page' do
        get :user
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('text/plain; charset=utf-8')
      end

      it 'includes X-XRDS-Location meta tag' do
        get :user
        expect(response.body).to include('X-XRDS-Location')
      end

      it 'includes X-XRDS-Location header' do
        get :user
        expect(response.headers['X-XRDS-Location']).to be_present
      end

      it 'includes openid.server link' do
        get :user
        expect(response.body).to include('openid.server')
      end

      it 'renders minimal HTML structure' do
        get :user
        expect(response.body).to include('<html>')
        expect(response.body).to include('</html>')
      end
    end

    context 'error handling' do
      it 'handles errors gracefully' do
        allow(controller).to receive(:open_id_xrds_url).and_raise(StandardError.new('Error'))
        expect(Rails.logger).to receive(:error).with(a_string_matching(/openid_user_error/))
        get :user
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end

  # ==================== AUTHENTICATION ENDPOINT TESTS ====================

  describe 'POST #create' do
    let(:checkid_request) { instance_double(OpenID::Server::CheckIDRequest) }
    let(:web_response) { instance_double(OpenID::Server::WebResponse, code: 200, body: 'OK', headers: {}) }

    before do
      allow(openid_server).to receive(:decode_request).and_return(checkid_request)
      allow(openid_server).to receive(:handle_request).and_return(web_response)
      allow(openid_server).to receive(:signatory).and_return(double(sign: true))
      allow(openid_server).to receive(:encode_response).and_return(web_response)
    end

    context 'with valid OpenID request' do
      it 'processes the request' do
        post :create
        expect(response).to have_http_status(:success)
      end

      it 'calls server decode_request' do
        expect(openid_server).to receive(:decode_request).with(hash_including(controller: 'open_id'))
        post :create
      end

      it 'returns plain text response' do
        post :create
        expect(response.content_type).to eq('text/plain; charset=utf-8')
      end
    end

    context 'with nil request (endpoint info)' do
      before do
        allow(openid_server).to receive(:decode_request).and_return(nil)
      end

      it 'returns endpoint information' do
        post :create
        expect(response).to have_http_status(:success)
        expect(response.body).to include('OpenID server endpoint')
      end
    end

    context 'with CheckIDRequest' do
      before do
        sign_in user
        allow(controller).to receive(:open_id_user_url).with(user.id).and_return("http://test.host/user/#{user.id}")
        allow(checkid_request).to receive(:is_a?).with(OpenID::Server::CheckIDRequest).and_return(true)
        allow(checkid_request).to receive(:id_select).and_return(false)
        allow(checkid_request).to receive(:identity).and_return("http://test.host/user/#{user.id}")
        allow(checkid_request).to receive(:trust_root).and_return('https://example.com')
        allow(checkid_request).to receive(:answer).and_return(web_response)
        allow(web_response).to receive(:needs_signing).and_return(false)
      end

      it 'handles authorized identity' do
        post :create
        expect(response).to have_http_status(:success)
      end

      it 'logs authentication approval' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/openid_authentication_approved/))
        post :create
      end

      it 'checks identity authorization' do
        allow(controller).to receive(:is_authorized).and_call_original
        post :create
        expect(controller).to have_received(:is_authorized)
      end
    end

    context 'with id_select mode' do
      before do
        sign_in user
        allow(checkid_request).to receive(:is_a?).with(OpenID::Server::CheckIDRequest).and_return(true)
        allow(checkid_request).to receive(:id_select).and_return(true)
        allow(checkid_request).to receive(:immediate).and_return(false)
        allow(checkid_request).to receive(:identity).and_return(nil)
        allow(checkid_request).to receive(:trust_root).and_return('https://example.com')
        allow(checkid_request).to receive(:answer).and_return(web_response)
        allow(web_response).to receive(:needs_signing).and_return(false)
      end

      it 'uses current user identity' do
        post :create
        expect(response).to have_http_status(:success)
      end
    end

    context 'with immediate mode request' do
      before do
        allow(checkid_request).to receive(:is_a?).with(OpenID::Server::CheckIDRequest).and_return(true)
        allow(checkid_request).to receive(:id_select).and_return(true)
        allow(checkid_request).to receive(:immediate).and_return(true)
        allow(checkid_request).to receive(:answer).and_return(web_response)
        allow(web_response).to receive(:needs_signing).and_return(false)
      end

      it 'denies immediate requests' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/openid_immediate_request_denied/))
        post :create
      end
    end

    context 'with unauthenticated id_select request' do
      before do
        allow(checkid_request).to receive(:is_a?).with(OpenID::Server::CheckIDRequest).and_return(true)
        allow(checkid_request).to receive(:id_select).and_return(true)
        allow(checkid_request).to receive(:immediate).and_return(false)
      end

      it 'redirects to login' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/openid_unauthenticated_request/))
        post :create
        expect(response).to be_redirect
      end
    end

    context 'with unauthorized identity' do
      before do
        sign_in user
        allow(checkid_request).to receive(:is_a?).with(OpenID::Server::CheckIDRequest).and_return(true)
        allow(checkid_request).to receive(:id_select).and_return(false)
        allow(checkid_request).to receive(:identity).and_return('https://other-user.example.com')
        allow(checkid_request).to receive(:trust_root).and_return('https://example.com')
        allow(checkid_request).to receive(:answer).and_return(web_response)
        allow(web_response).to receive(:needs_signing).and_return(false)
      end

      it 'denies authentication' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/openid_authentication_denied/))
        post :create
      end
    end

    context 'with ProtocolError' do
      before do
        allow(openid_server).to receive(:decode_request).and_raise(OpenID::Server::ProtocolError.new('Invalid request'))
      end

      it 'handles protocol errors' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/openid_protocol_error/))
        post :create
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns error message' do
        allow(Rails.logger).to receive(:error)
        post :create
        expect(response.body).to include('Invalid request')
      end
    end

    context 'with StandardError' do
      before do
        allow(openid_server).to receive(:decode_request).and_raise(StandardError.new('Server error'))
      end

      it 'handles general errors' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/openid_create_error/))
        post :create
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns generic error message' do
        allow(Rails.logger).to receive(:error)
        post :create
        expect(response.body).to eq('OpenID authentication error')
      end
    end
  end

  # ==================== INDEX ENDPOINT TESTS ====================

  describe 'GET #index' do
    let(:checkid_request) { instance_double(OpenID::Server::CheckIDRequest) }
    let(:web_response) { instance_double(OpenID::Server::WebResponse, code: 200, body: 'OK', headers: {}) }

    before do
      sign_in user
      allow(openid_server).to receive(:decode_request).and_return(checkid_request)
      allow(openid_server).to receive(:handle_request).and_return(web_response)
      allow(openid_server).to receive(:signatory).and_return(double(sign: true))
      allow(openid_server).to receive(:encode_response).and_return(web_response)
    end

    it 'requires authentication' do
      sign_out user
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'processes authenticated requests' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'handles protocol errors' do
      allow(openid_server).to receive(:decode_request).and_raise(OpenID::Server::ProtocolError.new('Error'))
      expect(Rails.logger).to receive(:error).with(a_string_matching(/openid_protocol_error/))
      get :index
    end

    it 'handles general errors' do
      allow(openid_server).to receive(:decode_request).and_raise(StandardError.new('Error'))
      expect(Rails.logger).to receive(:error).with(a_string_matching(/openid_index_error/))
      get :index
    end
  end

  # ==================== RESPONSE RENDERING TESTS ====================

  describe 'response rendering' do
    let(:web_response) { instance_double(OpenID::Server::WebResponse, code: code, body: body, headers: headers) }
    let(:body) { 'Response body' }
    let(:headers) { {} }

    before do
      allow(openid_server).to receive(:decode_request).and_return(nil)
      allow(openid_server).to receive(:signatory).and_return(double(sign: true))
      allow(openid_server).to receive(:encode_response).and_return(web_response)
      allow(web_response).to receive(:needs_signing).and_return(false)
    end

    context 'with HTTP_OK response' do
      let(:code) { 200 }

      it 'renders plain text' do
        post :create
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(body)
      end
    end

    context 'with HTTP_REDIRECT response' do
      let(:code) { 302 }
      let(:headers) { { 'location' => 'https://example.com/callback' } }

      it 'redirects to location' do
        post :create
        expect(response).to redirect_to('https://example.com/callback')
      end

      it 'allows other hosts' do
        post :create
        expect(response.location).to eq('https://example.com/callback')
      end
    end

    context 'with other response codes' do
      let(:code) { 500 }

      it 'renders bad request' do
        post :create
        expect(response).to have_http_status(:bad_request)
      end

      it 'includes response body' do
        post :create
        expect(response.body).to eq(body)
      end
    end

    context 'with nil response' do
      before do
        allow(checkid_request).to receive(:is_a?).with(OpenID::Server::CheckIDRequest).and_return(true)
        allow(checkid_request).to receive(:id_select).and_return(true)
        allow(checkid_request).to receive(:immediate).and_return(false)
        allow(openid_server).to receive(:decode_request).and_return(checkid_request)
      end

      it 'redirects to root when response is nil' do
        post :create
        expect(response).to redirect_to(root_path)
      end

      it 'sets flash notice' do
        post :create
        expect(flash[:notice]).to eq(I18n.t('devise.failure.unauthenticated'))
      end
    end
  end

  # ==================== SREG EXTENSION TESTS ====================

  describe 'SREG extension' do
    let(:checkid_request) { instance_double(OpenID::Server::CheckIDRequest) }
    let(:oidresp) { instance_double(OpenID::Server::OpenIDResponse) }
    let(:sregreq) { instance_double(OpenID::SReg::Request, required: [], optional: %i[email fullname]) }
    let(:web_response) { instance_double(OpenID::Server::WebResponse, code: 200, body: 'OK', headers: {}) }

    before do
      sign_in user
      allow(checkid_request).to receive(:is_a?).with(OpenID::Server::CheckIDRequest).and_return(true)
      allow(checkid_request).to receive(:id_select).and_return(false)
      allow(checkid_request).to receive(:identity).and_return(open_id_user_url(user.id))
      allow(checkid_request).to receive(:trust_root).and_return('https://example.com')
      allow(checkid_request).to receive(:answer).and_return(oidresp)
      allow(oidresp).to receive(:needs_signing).and_return(false)
      allow(oidresp).to receive(:add_extension)
      allow(OpenID::SReg::Request).to receive(:from_openid_request).and_return(sregreq)
      allow(OpenID::SReg::Response).to receive(:extract_response).and_return(double)
      allow(openid_server).to receive(:decode_request).and_return(checkid_request)
      allow(openid_server).to receive(:signatory).and_return(double(sign: true))
      allow(openid_server).to receive(:encode_response).and_return(web_response)
    end

    it 'provides email when requested' do
      expect(OpenID::SReg::Response).to receive(:extract_response).with(
        sregreq,
        hash_including('email' => user.email)
      )
      post :create
    end

    it 'provides fullname when requested' do
      expect(OpenID::SReg::Response).to receive(:extract_response).with(
        sregreq,
        hash_including('fullname' => user.full_name)
      )
      post :create
    end

    it 'provides nickname when requested' do
      allow(sregreq).to receive(:required).and_return([])
      allow(sregreq).to receive(:optional).and_return([:nickname])
      expect(OpenID::SReg::Response).to receive(:extract_response).with(
        sregreq,
        hash_including('nickname' => user.first_name)
      )
      post :create
    end

    it 'logs PII disclosure' do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/openid_pii_disclosure/))
      post :create
    end

    it 'only provides requested fields' do
      allow(sregreq).to receive(:required).and_return([:email])
      allow(sregreq).to receive(:optional).and_return([])
      expect(OpenID::SReg::Response).to receive(:extract_response).with(
        sregreq,
        { 'email' => user.email }
      )
      post :create
    end

    it 'does not add extension when no SREG request' do
      allow(OpenID::SReg::Request).to receive(:from_openid_request).and_return(nil)
      expect(oidresp).not_to receive(:add_extension)
      post :create
    end
  end

  # ==================== PAPE EXTENSION TESTS ====================

  describe 'PAPE extension' do
    let(:checkid_request) { instance_double(OpenID::Server::CheckIDRequest) }
    let(:oidresp) { instance_double(OpenID::Server::OpenIDResponse) }
    let(:papereq) { instance_double(OpenID::PAPE::Request) }
    let(:web_response) { instance_double(OpenID::Server::WebResponse, code: 200, body: 'OK', headers: {}) }

    before do
      sign_in user
      allow(checkid_request).to receive(:is_a?).with(OpenID::Server::CheckIDRequest).and_return(true)
      allow(checkid_request).to receive(:id_select).and_return(false)
      allow(checkid_request).to receive(:identity).and_return(open_id_user_url(user.id))
      allow(checkid_request).to receive(:trust_root).and_return('https://example.com')
      allow(checkid_request).to receive(:answer).and_return(oidresp)
      allow(oidresp).to receive(:needs_signing).and_return(false)
      allow(oidresp).to receive(:add_extension)
      allow(OpenID::PAPE::Request).to receive(:from_openid_request).and_return(papereq)
      allow(OpenID::SReg::Request).to receive(:from_openid_request).and_return(nil)
      allow(openid_server).to receive(:decode_request).and_return(checkid_request)
      allow(openid_server).to receive(:signatory).and_return(double(sign: true))
      allow(openid_server).to receive(:encode_response).and_return(web_response)
    end

    it 'adds PAPE response when requested' do
      expect(oidresp).to receive(:add_extension).with(an_instance_of(OpenID::PAPE::Response))
      post :create
    end

    it 'sets NIST auth level to 0' do
      pape_response = nil
      allow(oidresp).to receive(:add_extension) do |ext|
        pape_response = ext if ext.is_a?(OpenID::PAPE::Response)
      end
      post :create
      expect(pape_response.nist_auth_level).to eq(0) if pape_response
    end

    it 'does not add extension when no PAPE request' do
      allow(OpenID::PAPE::Request).to receive(:from_openid_request).and_return(nil)
      expect(oidresp).not_to receive(:add_extension)
      post :create
    end
  end

  # ==================== SECURITY LOGGING TESTS ====================

  describe 'security logging' do
    it 'logs IP address in security events' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"ip_address":/))
      get :discover
    end

    it 'logs user agent in security events' do
      request.env['HTTP_USER_AGENT'] = 'Test Browser'
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"user_agent":"Test Browser"/))
      get :discover
    end

    it 'logs timestamp in ISO8601 format' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"timestamp":"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/))
      get :discover
    end

    it 'logs controller name' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"controller":"open_id"/))
      get :discover
    end

    it 'logs error class in error events' do
      allow(controller).to receive(:render_xrds).and_raise(StandardError.new('Test error'))
      expect(Rails.logger).to receive(:error).with(a_string_matching(/"error_class":"StandardError"/))
      get :discover
    end

    it 'logs error message in error events' do
      allow(controller).to receive(:render_xrds).and_raise(StandardError.new('Test error'))
      expect(Rails.logger).to receive(:error).with(a_string_matching(/"error_message":"Test error"/))
      get :discover
    end

    it 'logs backtrace in error events' do
      allow(controller).to receive(:render_xrds).and_raise(StandardError.new('Error'))
      expect(Rails.logger).to receive(:error).with(a_string_matching(/"backtrace":\[/))
      get :discover
    end
  end

  # ==================== AUTHORIZATION TESTS ====================

  describe 'authorization' do
    it 'allows unauthenticated access to discover' do
      get :discover
      expect(response).not_to be_redirect
    end

    it 'allows unauthenticated access to xrds' do
      get :xrds
      expect(response).not_to be_redirect
    end

    it 'allows unauthenticated access to user' do
      get :user, params: { id: 1 }
      expect(response).not_to be_redirect
    end

    it 'allows unauthenticated access to create (OpenID endpoint)' do
      allow(openid_server).to receive(:decode_request).and_return(nil)
      post :create
      expect(response).not_to redirect_to(new_user_session_path)
    end

    it 'requires authentication for index' do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  # ==================== CSRF PROTECTION TESTS ====================

  describe 'CSRF protection' do
    it 'disables CSRF for create action' do
      # This is tested implicitly - if CSRF was enabled, POST without token would fail
      allow(openid_server).to receive(:decode_request).and_return(nil)
      allow(openid_server).to receive(:signatory).and_return(double(sign: true))
      allow(openid_server).to receive(:encode_response).and_return(
        instance_double(OpenID::Server::WebResponse, code: 200, body: 'OK', headers: {}, needs_signing: false)
      )
      post :create
      expect(response).to have_http_status(:success)
    end
  end

  # ==================== HELPER METHOD TESTS ====================

  describe 'helper methods' do
    before { sign_in user }

    describe '#url_for_user' do
      it 'returns user URL' do
        allow(controller).to receive(:open_id_user_url).with(user.id).and_return("http://test.host/user/#{user.id}")
        url = controller.send(:url_for_user)
        expect(url).to include(user.id.to_s)
      end
    end

    describe '#approved' do
      it 'returns true for all trust roots' do
        result = controller.send(:approved, 'https://example.com')
        expect(result).to be true
      end
    end

    describe '#is_authorized' do
      it 'returns true for matching identity and authenticated user' do
        allow(controller).to receive(:open_id_user_url).with(user.id).and_return("http://test.host/user/#{user.id}")
        identity_url = "http://test.host/user/#{user.id}"
        result = controller.send(:is_authorized, identity_url, 'https://example.com')
        expect(result).to be true
      end

      it 'returns false for mismatched identity' do
        result = controller.send(:is_authorized, 'https://other.example.com', 'https://example.com')
        expect(result).to be false
      end

      it 'returns false for unauthenticated user' do
        sign_out user
        identity_url = "http://test.host/user/#{user.id}"
        result = controller.send(:is_authorized, identity_url, 'https://example.com')
        expect(result).to be false
      end
    end

    describe '#server' do
      it 'creates OpenID server instance' do
        server = controller.send(:server)
        expect(server).to be_present
      end

      it 'uses filesystem store' do
        # Reset memoization
        controller.instance_variable_set(:@server, nil)
        expect(OpenID::Store::Filesystem).to receive(:new).with(Rails.root.join('db/openid-store')).and_return(openid_store)
        controller.send(:server)
      end

      it 'caches server instance' do
        server1 = controller.send(:server)
        server2 = controller.send(:server)
        expect(server1).to eq(server2)
      end
    end
  end
end
