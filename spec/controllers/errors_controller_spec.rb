# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  # Skip ApplicationController filters that may cause issues in testing
  before do
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes
  end

  describe 'GET #show' do
    context 'when no code parameter is provided' do
      it "assigns @code to default value '500' as string" do
        get :show
        expect(assigns(:code)).to eq('500')
      end

      it 'renders the show template' do
        get :show
        expect(response).to render_template(:show)
      end

      it 'returns http status 500 (internal_server_error)' do
        get :show
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns the correct numeric status code' do
        get :show
        expect(response.status).to eq(500)
      end
    end

    context 'when code parameter is 404' do
      it "assigns @code to '404' as string" do
        get :show, params: { code: 404 }
        expect(assigns(:code)).to eq('404')
      end

      it 'renders the show template' do
        get :show, params: { code: 404 }
        expect(response).to render_template(:show)
      end

      it 'returns http status 404 (not_found)' do
        get :show, params: { code: 404 }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns the correct numeric status code' do
        get :show, params: { code: 404 }
        expect(response.status).to eq(404)
      end
    end

    context 'when code parameter is 500' do
      it "assigns @code to '500' as string" do
        get :show, params: { code: 500 }
        expect(assigns(:code)).to eq('500')
      end

      it 'renders the show template' do
        get :show, params: { code: 500 }
        expect(response).to render_template(:show)
      end

      it 'returns http status 500 (internal_server_error)' do
        get :show, params: { code: 500 }
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when code parameter is 422' do
      it "assigns @code to '422' as string" do
        get :show, params: { code: 422 }
        expect(assigns(:code)).to eq('422')
      end

      it 'renders the show template' do
        get :show, params: { code: 422 }
        expect(response).to render_template(:show)
      end

      it 'returns http status 422 (unprocessable_entity)' do
        get :show, params: { code: 422 }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when code parameter is 403' do
      it "assigns @code to '403' as string" do
        get :show, params: { code: 403 }
        expect(assigns(:code)).to eq('403')
      end

      it 'renders the show template' do
        get :show, params: { code: 403 }
        expect(response).to render_template(:show)
      end

      it 'returns http status 403 (forbidden)' do
        get :show, params: { code: 403 }
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when code parameter is an invalid symbolic string' do
      it "sanitizes to default '500' (SECURITY FIX: prevents symbol table pollution)" do
        get :show, params: { code: 'not_found' }
        expect(assigns(:code)).to eq('500')
      end

      it 'renders the show template' do
        get :show, params: { code: 'not_found' }
        expect(response).to render_template(:show)
      end

      it 'returns http status 500 (invalid codes default to 500)' do
        get :show, params: { code: 'not_found' }
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when code parameter is zero (invalid)' do
      it "sanitizes to default '500' (SECURITY FIX: invalid code)" do
        get :show, params: { code: 0 }
        expect(assigns(:code)).to eq('500')
      end

      it 'renders the show template' do
        get :show, params: { code: 0 }
        expect(response).to render_template(:show)
      end

      it 'returns http status 500 (invalid codes default to 500)' do
        get :show, params: { code: 0 }
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when code parameter is nil explicitly' do
      it "assigns @code to default '500' as string" do
        get :show, params: { code: nil }
        expect(assigns(:code)).to eq('500')
      end

      it 'renders the show template' do
        get :show, params: { code: nil }
        expect(response).to render_template(:show)
      end

      it 'returns http status 500' do
        get :show, params: { code: nil }
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'when code parameter is an empty string' do
      it "assigns @code to default '500' as string (empty string is falsy)" do
        get :show, params: { code: '' }
        expect(assigns(:code)).to eq('500')
      end

      it 'renders the show template' do
        get :show, params: { code: '' }
        expect(response).to render_template(:show)
      end

      it 'returns http status 500' do
        get :show, params: { code: '' }
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context 'type consistency verification' do
      it 'always returns @code as a String regardless of input' do
        test_cases = [
          { input: 404, expected: '404' },
          { input: '500', expected: '500' },
          { input: nil, expected: '500' },
          { input: '', expected: '500' },
          { input: 0, expected: '500' }, # UPDATED: invalid code defaults to 500
          { input: 'not_found', expected: '500' } # UPDATED: invalid code defaults to 500
        ]

        test_cases.each do |test_case|
          get :show, params: { code: test_case[:input] }
          expect(assigns(:code)).to be_a(String),
                                    "Expected @code to be String for input #{test_case[:input].inspect}, got #{assigns(:code).class}"
          expect(assigns(:code)).to eq(test_case[:expected])
        end
      end
    end

    context 'http status code conversion' do
      it 'converts whitelisted numeric codes to integer status codes' do
        # All codes in the whitelist
        numeric_codes = [400, 401, 403, 404, 405, 406, 408, 409, 410, 422, 429, 500, 501, 502, 503, 504]

        numeric_codes.each do |code|
          get :show, params: { code: code }
          expect(response.status).to eq(code)
        end
      end

      it 'defaults non-whitelisted codes to 500' do
        invalid_codes = [
          { input: 999, expected_status: 500 },
          { input: 100, expected_status: 500 },
          { input: 200, expected_status: 500 },  # Success codes not in error whitelist
          { input: 301, expected_status: 500 },  # Redirect codes not in error whitelist
          { input: -1, expected_status: 500 }
        ]

        invalid_codes.each do |test_case|
          get :show, params: { code: test_case[:input] }
          expect(response.status).to eq(test_case[:expected_status]),
                                     "Expected status #{test_case[:expected_status]} for '#{test_case[:input]}', got #{response.status}"
        end
      end
    end

    context 'security: symbol table pollution prevention' do
      it 'does not convert user input to symbols (HIGH PRIORITY FIX)' do
        # Before the fix, this code would call .to_sym on user input:
        # @code.to_sym
        # This would create new symbols that never get garbage collected.

        # Verify that user input is NOT converted to symbols by checking
        # that invalid codes are rejected and default to '500'
        malicious_attempts = %w[
          malicious_symbol_1
          malicious_symbol_2
          malicious_symbol_3
        ]

        malicious_attempts.each do |malicious_code|
          get :show, params: { code: malicious_code }

          # All should default to '500' (sanitized)
          expect(assigns(:code)).to eq('500')

          # Verify the malicious symbol was NOT created
          # (If it was converted to symbol, it would exist in Symbol table)
          expect(Symbol.all_symbols).not_to include(malicious_code.to_sym),
                                            "Symbol :#{malicious_code} should not exist - this indicates a security vulnerability"
        end
      end

      it "sanitizes all malicious codes to default '500'" do
        malicious_inputs = [
          '../../../../etc/passwd',
          "<script>alert('xss')</script>",
          "'; DROP TABLE users; --",
          '../config/secrets',
          'random_unique_string_12345',
          'malicious_symbol_attack'
        ]

        malicious_inputs.each do |malicious_code|
          get :show, params: { code: malicious_code }
          expect(assigns(:code)).to eq('500'),
                                    "Expected '500' for malicious input '#{malicious_code}', got '#{assigns(:code)}'"
          expect(response).to have_http_status(:internal_server_error)
        end
      end
    end

    context 'security: I18n key injection prevention' do
      it 'only allows whitelisted error codes to prevent I18n key injection (HIGH PRIORITY FIX)' do
        # These attempts should all default to '500' to prevent accessing arbitrary I18n keys
        injection_attempts = [
          '../../config/secrets',
          '../../../database',
          'activerecord.errors.messages',
          'devise.sessions.new'
        ]

        injection_attempts.each do |injection_code|
          get :show, params: { code: injection_code }
          expect(assigns(:code)).to eq('500'),
                                    "I18n key injection attempt '#{injection_code}' should default to '500'"
        end
      end
    end

    context 'all whitelisted error codes work correctly' do
      it 'accepts all codes from ALLOWED_ERROR_CODES constant' do
        ErrorsController::ALLOWED_ERROR_CODES.each_key do |code_str|
          get :show, params: { code: code_str }
          expect(assigns(:code)).to eq(code_str)
          expect(response.status).to eq(code_str.to_i)
        end
      end
    end
  end
end
