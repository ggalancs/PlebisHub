# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  let(:user) { create(:user) }

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

    context 'security logging' do
      it 'logs security event when error page is displayed' do
        logged_events = []
        allow(Rails.logger).to receive(:info) do |log_entry|
          begin
            logged_events << JSON.parse(log_entry)
          rescue JSON::ParserError
            # Skip non-JSON log entries
          end
        end

        get :show, params: { code: '404' }

        event = logged_events.find { |e| e['event'] == 'error_page_displayed' }
        expect(event).to be_present
        expect(event['code']).to eq('404')
        expect(event['raw_code']).to eq('404')
        expect(event['controller']).to eq('errors')
        expect(event).to have_key('ip_address')
        expect(event).to have_key('user_agent')
        expect(event).to have_key('timestamp')
      end

      it 'logs security event for invalid error code attempt' do
        logged_events = []
        allow(Rails.logger).to receive(:info) do |log_entry|
          begin
            logged_events << JSON.parse(log_entry)
          rescue JSON::ParserError
            # Skip non-JSON log entries
          end
        end

        get :show, params: { code: '999' }

        invalid_code_event = logged_events.find { |e| e['event'] == 'invalid_error_code_attempt' }
        expect(invalid_code_event).to be_present
        expect(invalid_code_event['attempted_code']).to eq('999')
        expect(invalid_code_event['controller']).to eq('errors')
      end

      it 'logs user_id when user is logged in' do
        allow(controller).to receive(:current_user).and_return(user)
        logged_events = []
        allow(Rails.logger).to receive(:info) do |log_entry|
          begin
            logged_events << JSON.parse(log_entry)
          rescue JSON::ParserError
            # Skip non-JSON log entries
          end
        end

        get :show, params: { code: '404' }

        event = logged_events.find { |e| e['event'] == 'error_page_displayed' }
        expect(event).to be_present
        expect(event['user_id']).to eq(user.id)
      end

      it 'logs nil user_id when no user is logged in' do
        allow(controller).to receive(:current_user).and_return(nil)
        logged_events = []
        allow(Rails.logger).to receive(:info) do |log_entry|
          begin
            logged_events << JSON.parse(log_entry)
          rescue JSON::ParserError
            # Skip non-JSON log entries
          end
        end

        get :show, params: { code: '404' }

        event = logged_events.find { |e| e['event'] == 'error_page_displayed' }
        expect(event).to be_present
        expect(event['user_id']).to be_nil
      end

      it 'logs IP address and user agent' do
        logged_events = []
        allow(Rails.logger).to receive(:info) do |log_entry|
          begin
            logged_events << JSON.parse(log_entry)
          rescue JSON::ParserError
            # Skip non-JSON log entries
          end
        end

        get :show, params: { code: '404' }

        event = logged_events.find { |e| e['event'] == 'error_page_displayed' }
        expect(event).to be_present
        expect(event['ip_address']).to be_present
        expect(event['user_agent']).to be_present
      end
    end

    context 'error handling in show action' do
      it 'rescues StandardError and renders plain error message' do
        allow(controller).to receive(:sanitize_error_code).and_raise(StandardError.new('Test error'))
        allow(Rails.logger).to receive(:error)

        get :show, params: { code: '404' }

        expect(response.body).to eq('Internal Server Error')
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'logs error details when StandardError is raised' do
        test_error = StandardError.new('Test error message')
        allow(controller).to receive(:sanitize_error_code).and_raise(test_error)
        allow(Rails.logger).to receive(:error).and_call_original

        get :show, params: { code: '404' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/error_page_render_error.*StandardError/m)).at_least(:once)
      end

      it 'includes backtrace in error logs' do
        test_error = StandardError.new('Test error')
        test_error.set_backtrace(['/path/to/file.rb:123', '/path/to/file2.rb:456'])
        allow(controller).to receive(:sanitize_error_code).and_raise(test_error)
        allow(Rails.logger).to receive(:error).and_call_original

        get :show, params: { code: '404' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/backtrace/)).at_least(:once)
      end
    end

    context 'edge cases for code parameter' do
      it 'handles string code that looks like a number' do
        get :show, params: { code: '404' }
        expect(assigns(:code)).to eq('404')
        expect(response).to have_http_status(:not_found)
      end

      it 'handles integer code' do
        get :show, params: { code: 404 }
        expect(assigns(:code)).to eq('404')
        expect(response).to have_http_status(:not_found)
      end

      it 'handles code as a string with leading zeros' do
        get :show, params: { code: '0404' }
        expect(assigns(:code)).to eq('500')
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'handles code with special characters' do
        get :show, params: { code: '404!@#' }
        expect(assigns(:code)).to eq('500')
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'handles very large code numbers' do
        get :show, params: { code: 99999999 }
        expect(assigns(:code)).to eq('500')
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'handles negative code numbers' do
        get :show, params: { code: -404 }
        expect(assigns(:code)).to eq('500')
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'handles code as array (Rails strong params)' do
        get :show, params: { code: ['404', '500'] }
        expect(assigns(:code)).to eq('500')
        expect(response).to have_http_status(:internal_server_error)
      end

      it 'handles code as hash (Rails strong params)' do
        get :show, params: { code: { nested: '404' } }
        expect(assigns(:code)).to eq('500')
        expect(response).to have_http_status(:internal_server_error)
      end
    end

    context '4xx client error codes' do
      [
        ['400', :bad_request],
        ['401', :unauthorized],
        ['403', :forbidden],
        ['404', :not_found],
        ['405', :method_not_allowed],
        ['406', :not_acceptable],
        ['408', :request_timeout],
        ['409', :conflict],
        ['410', :gone],
        ['422', :unprocessable_entity],
        ['429', :too_many_requests]
      ].each do |code, status_symbol|
        it "handles #{code} (#{status_symbol}) correctly" do
          get :show, params: { code: code }
          expect(assigns(:code)).to eq(code)
          expect(response).to have_http_status(status_symbol)
          expect(response.status).to eq(code.to_i)
        end
      end
    end

    context '5xx server error codes' do
      [
        ['500', :internal_server_error],
        ['501', :not_implemented],
        ['502', :bad_gateway],
        ['503', :service_unavailable],
        ['504', :gateway_timeout]
      ].each do |code, status_symbol|
        it "handles #{code} (#{status_symbol}) correctly" do
          get :show, params: { code: code }
          expect(assigns(:code)).to eq(code)
          expect(response).to have_http_status(status_symbol)
          expect(response.status).to eq(code.to_i)
        end
      end
    end
  end

  describe 'private methods' do
    describe '#sanitize_error_code' do
      it 'returns code if it is in whitelist' do
        result = controller.send(:sanitize_error_code, '404')
        expect(result).to eq('404')
      end

      it 'returns 500 if code is not in whitelist' do
        result = controller.send(:sanitize_error_code, '999')
        expect(result).to eq('500')
      end

      it 'converts non-string codes to string before checking' do
        result = controller.send(:sanitize_error_code, 404)
        expect(result).to eq('404')
      end

      it 'handles nil by converting to string and defaulting to 500' do
        result = controller.send(:sanitize_error_code, nil)
        expect(result).to eq('500')
      end

      it 'logs security event for invalid codes' do
        allow(Rails.logger).to receive(:info).and_call_original
        controller.send(:sanitize_error_code, '999')
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/invalid_error_code_attempt/)).at_least(:once)
      end
    end

    describe '#http_status_code' do
      it 'converts @code to integer' do
        controller.instance_variable_set(:@code, '404')
        result = controller.send(:http_status_code)
        expect(result).to eq(404)
        expect(result).to be_a(Integer)
      end

      it 'handles 500 code' do
        controller.instance_variable_set(:@code, '500')
        result = controller.send(:http_status_code)
        expect(result).to eq(500)
      end
    end

    describe '#log_security_event' do
      let(:mock_logger) { instance_double(ActiveSupport::Logger) }

      before do
        allow(Rails).to receive(:logger).and_return(mock_logger)
      end

      it 'logs event with correct format' do
        expect(mock_logger).to receive(:info) do |log_entry|
          parsed = JSON.parse(log_entry)
          expect(parsed['event']).to eq('test_event')
          expect(parsed['test_detail']).to eq('test_value')
          expect(parsed['controller']).to eq('errors')
          expect(parsed).to have_key('ip_address')
          expect(parsed).to have_key('user_agent')
          expect(parsed).to have_key('timestamp')
        end

        controller.send(:log_security_event, 'test_event', test_detail: 'test_value')
      end

      it 'includes timestamp in ISO8601 format' do
        frozen_time = Time.parse('2025-01-15 12:00:00 UTC')
        allow(Time).to receive(:current).and_return(frozen_time)

        expect(mock_logger).to receive(:info) do |log_entry|
          parsed = JSON.parse(log_entry)
          expect(parsed['timestamp']).to eq(frozen_time.iso8601)
        end

        controller.send(:log_security_event, 'test_event')
      end

      it 'includes request details' do
        expect(mock_logger).to receive(:info) do |log_entry|
          parsed = JSON.parse(log_entry)
          expect(parsed['ip_address']).to eq(controller.request.remote_ip)
          expect(parsed['user_agent']).to eq(controller.request.user_agent)
        end

        controller.send(:log_security_event, 'test_event')
      end
    end

    describe '#log_error' do
      let(:mock_logger) { instance_double(ActiveSupport::Logger) }
      let(:test_exception) { StandardError.new('Test error') }

      before do
        allow(Rails).to receive(:logger).and_return(mock_logger)
        test_exception.set_backtrace([
                                       '/path/to/file1.rb:10',
                                       '/path/to/file2.rb:20',
                                       '/path/to/file3.rb:30',
                                       '/path/to/file4.rb:40',
                                       '/path/to/file5.rb:50',
                                       '/path/to/file6.rb:60'
                                     ])
      end

      it 'logs error with correct format' do
        expect(mock_logger).to receive(:error) do |log_entry|
          parsed = JSON.parse(log_entry)
          expect(parsed['event']).to eq('test_error_event')
          expect(parsed['error_class']).to eq('StandardError')
          expect(parsed['error_message']).to eq('Test error')
          expect(parsed['controller']).to eq('errors')
          expect(parsed['test_detail']).to eq('test_value')
          expect(parsed).to have_key('backtrace')
          expect(parsed).to have_key('ip_address')
          expect(parsed).to have_key('timestamp')
        end

        controller.send(:log_error, 'test_error_event', test_exception, test_detail: 'test_value')
      end

      it 'limits backtrace to first 5 entries' do
        expect(mock_logger).to receive(:error) do |log_entry|
          parsed = JSON.parse(log_entry)
          expect(parsed['backtrace'].length).to eq(5)
          expect(parsed['backtrace'].first).to eq('/path/to/file1.rb:10')
          expect(parsed['backtrace'].last).to eq('/path/to/file5.rb:50')
        end

        controller.send(:log_error, 'test_error', test_exception)
      end

      it 'handles exceptions with no backtrace' do
        exception_no_backtrace = StandardError.new('Error without backtrace')

        expect(mock_logger).to receive(:error) do |log_entry|
          parsed = JSON.parse(log_entry)
          expect(parsed['backtrace']).to be_nil
        end

        controller.send(:log_error, 'test_error', exception_no_backtrace)
      end

      it 'includes timestamp in ISO8601 format' do
        frozen_time = Time.parse('2025-01-15 12:00:00 UTC')
        allow(Time).to receive(:current).and_return(frozen_time)

        expect(mock_logger).to receive(:error) do |log_entry|
          parsed = JSON.parse(log_entry)
          expect(parsed['timestamp']).to eq(frozen_time.iso8601)
        end

        controller.send(:log_error, 'test_error', test_exception)
      end
    end
  end

  describe 'ALLOWED_ERROR_CODES constant' do
    it 'is frozen to prevent modification' do
      expect(ErrorsController::ALLOWED_ERROR_CODES).to be_frozen
    end

    it 'contains all expected 4xx error codes' do
      expected_4xx = %w[400 401 403 404 405 406 408 409 410 422 429]
      expected_4xx.each do |code|
        expect(ErrorsController::ALLOWED_ERROR_CODES).to have_key(code)
      end
    end

    it 'contains all expected 5xx error codes' do
      expected_5xx = %w[500 501 502 503 504]
      expected_5xx.each do |code|
        expect(ErrorsController::ALLOWED_ERROR_CODES).to have_key(code)
      end
    end

    it 'has symbol values for each code' do
      ErrorsController::ALLOWED_ERROR_CODES.each do |_code, status|
        expect(status).to be_a(Symbol)
      end
    end

    it 'has exactly 16 error codes defined' do
      expect(ErrorsController::ALLOWED_ERROR_CODES.size).to eq(16)
    end
  end
end
