# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2Controller, type: :controller do
  let(:secret) { 'test_secret_key_123' }
  let(:host) { 'example.com' }
  let(:timestamp) { Time.current.to_i.to_s }
  let(:valid_email) { 'test@example.com' }

  let!(:user) { create(:user, email: valid_email) }
  let!(:vote_circle) { create(:vote_circle, autonomy_code: 'AN', province_code: 'SE', town: 'Sevilla') }
  let!(:user_with_vote_circle) do
    create(:user,
           email: 'militant@example.com',
           vote_circle: vote_circle,
           first_name: 'Test',
           phone: '+34666777888')
  end

  before do
    @routes = Rails.application.routes
    allow(Rails.application).to receive(:secrets).and_return(
      double(
        host: host,
        forms: { 'secret' => secret }
      )
    )
  end

  # Helper method to generate valid HMAC signature
  def generate_signature(path, params_list, params_hash)
    data = "http://#{host}#{path}?"
    params_list.each_with_index do |k, i|
      sep = i.zero? ? '' : '&'
      data += "#{sep}#{k}=#{params_hash[k]}" if params_hash[k].present?
    end

    timestamp = params_hash['timestamp']
    Base64.urlsafe_encode64(OpenSSL::HMAC.digest('SHA256', secret, "#{timestamp}::#{data}"))
  end

  # ==================== SIGNATURE VERIFICATION TESTS ====================

  describe 'HMAC signature verification' do
    let(:params_hash) do
      {
        'email' => valid_email,
        'territory' => 'autonomy',
        'timestamp' => timestamp,
        'range_name' => '',
        'command' => 'militants_from_territory'
      }
    end
    let(:params_list) { %w[email territory timestamp range_name command] }

    context 'with valid signature' do
      it 'allows access to get_data' do
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
      end

      it 'uses secure_compare to prevent timing attacks' do
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        expect(ActiveSupport::SecurityUtils).to receive(:secure_compare).and_call_original

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
      end
    end

    context 'with invalid signature' do
      it 'returns 401 unauthorized' do
        params_hash['signature'] = 'invalid_signature'

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json['error']).to eq('Unauthorized')
        expect(json['message']).to eq('Invalid signature')
      end

      it 'logs signature verification failure' do
        params_hash['signature'] = 'invalid_signature'

        expect(Rails.logger).to receive(:warn).with(a_string_matching(/signature_verification_failed/))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
      end
    end

    context 'with missing signature' do
      it 'returns 401 unauthorized' do
        get :get_data, params: params_hash.except('signature').transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'timestamp validation' do
      it 'accepts timestamp within valid range' do
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
      end

      it 'rejects timestamp older than 1 hour' do
        old_timestamp = 2.hours.ago.to_i.to_s
        params_hash['timestamp'] = old_timestamp
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json['message']).to eq('Timestamp out of valid range')
      end

      it 'rejects timestamp in future (> 5 minutes)' do
        future_timestamp = 10.minutes.from_now.to_i.to_s
        params_hash['timestamp'] = future_timestamp
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'rejects invalid timestamp format' do
        params_hash['timestamp'] = 'invalid'

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        # 'invalid'.to_i becomes 0, which is way older than 1 hour ago
        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json['message']).to eq('Timestamp out of valid range')
      end

      it 'logs invalid timestamp attempts' do
        old_timestamp = 2.hours.ago.to_i.to_s
        params_hash['timestamp'] = old_timestamp

        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_timestamp/))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
      end
    end
  end

  # ==================== INPUT VALIDATION TESTS ====================

  describe 'input validation' do
    let(:params_hash) do
      {
        'email' => valid_email,
        'territory' => 'autonomy',
        'timestamp' => timestamp,
        'command' => 'militants_from_territory'
      }
    end
    let(:params_list) { %w[email territory timestamp range_name command] }

    before do
      signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
      params_hash['signature'] = signature
    end

    context 'command validation' do
      it 'rejects missing command' do
        get :get_data, params: params_hash.except('command').transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to eq('command parameter is required')
      end

      it 'rejects invalid command' do
        params_hash['command'] = 'invalid_command'

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to eq('Invalid command')
      end

      it 'accepts valid command' do
        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).not_to have_http_status(:bad_request)
      end
    end

    context 'territory validation' do
      it 'rejects missing territory' do
        get :get_data, params: params_hash.except('territory').transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to eq('territory parameter is required')
      end

      it 'rejects invalid territory' do
        params_hash['territory'] = 'invalid_territory'

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to eq('Invalid territory')
      end

      it 'accepts valid territories' do
        %w[autonomy province town island circle].each do |territory|
          params_hash['territory'] = territory
          signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
          params_hash['signature'] = signature

          get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

          expect(response).not_to have_http_status(:bad_request), "Failed for territory: #{territory}"
        end
      end
    end

    context 'email validation for militants_from_territory' do
      it 'rejects missing email' do
        get :get_data, params: params_hash.except('email').transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to eq('email parameter is required for this command')
      end

      it 'rejects invalid email format' do
        params_hash['email'] = 'invalid_email'

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to eq('Invalid email format')
      end

      it 'accepts valid email format' do
        params_hash['email'] = 'valid@example.com'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).not_to have_http_status(:bad_request)
      end
    end

    context 'vote_circle_id validation for militants_from_vote_circle_territory' do
      let(:params_hash) do
        {
          'vote_circle_id' => vote_circle.id.to_s,
          'territory' => 'autonomy',
          'timestamp' => timestamp,
          'command' => 'militants_from_vote_circle_territory'
        }
      end
      let(:params_list) { %w[vote_circle_id territory timestamp range_name command] }

      before do
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature
      end

      it 'rejects missing vote_circle_id' do
        get :get_data, params: params_hash.except('vote_circle_id').transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to eq('vote_circle_id parameter is required for this command')
      end

      it 'rejects non-numeric vote_circle_id' do
        params_hash['vote_circle_id'] = 'abc'

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to eq('vote_circle_id must be numeric')
      end

      it 'accepts valid numeric vote_circle_id' do
        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).not_to have_http_status(:bad_request)
      end
    end
  end

  # ==================== FUNCTIONALITY TESTS ====================

  describe 'militants_from_territory command' do
    let(:params_hash) do
      {
        'email' => user_with_vote_circle.email,
        'territory' => 'autonomy',
        'timestamp' => timestamp,
        'range_name' => '',
        'command' => 'militants_from_territory'
      }
    end
    let(:params_list) { %w[email territory timestamp range_name command] }

    before do
      signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
      params_hash['signature'] = signature
    end

    context 'with valid user' do
      it 'returns militants data' do
        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['success']).to be true
        expect(json['data']).to be_an(Array)
      end

      it 'logs PII access' do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/pii_access/))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
      end

      it 'includes user details in response' do
        # Create a militant in the same autonomy
        militant = create(:user,
                          vote_circle: vote_circle,
                          first_name: 'Militant',
                          phone: '+34987654321')
        allow(militant).to receive(:vote_circle).and_return(vote_circle)
        allow(User).to receive_message_chain(:militant, :where, :find_each).and_yield(militant)

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        json = response.parsed_body
        expect(json['success']).to be true
      end
    end

    context 'with non-existent user' do
      it 'returns 404 not found' do
        params_hash['email'] = 'nonexistent@example.com'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:not_found)
        json = response.parsed_body
        expect(json['success']).to be false
        expect(json['error']).to eq('Not Found')
        expect(json['message']).to eq('User not found')
      end

      it 'logs user not found event' do
        params_hash['email'] = 'nonexistent@example.com'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        expect(Rails.logger).to receive(:warn).with(a_string_matching(/user_not_found/))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
      end
    end

    context 'territory filtering' do
      it 'filters by autonomy' do
        params_hash['territory'] = 'autonomy'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
      end

      it 'filters by province' do
        params_hash['territory'] = 'province'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
      end

      it 'filters by town' do
        params_hash['territory'] = 'town'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
      end

      it 'filters by circle' do
        params_hash['territory'] = 'circle'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'militants_from_vote_circle_territory command' do
    let(:params_hash) do
      {
        'vote_circle_id' => vote_circle.id.to_s,
        'territory' => 'autonomy',
        'timestamp' => timestamp,
        'range_name' => '',
        'command' => 'militants_from_vote_circle_territory'
      }
    end
    let(:params_list) { %w[vote_circle_id territory timestamp range_name command] }

    before do
      signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
      params_hash['signature'] = signature
    end

    context 'with valid vote circle' do
      it 'returns militants data' do
        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['success']).to be true
        expect(json['data']).to be_an(Array)
      end

      it 'logs PII access' do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/pii_access/))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
      end
    end

    context 'with non-existent vote circle' do
      it 'returns 404 not found' do
        params_hash['vote_circle_id'] = '99999'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:not_found)
        json = response.parsed_body
        expect(json['success']).to be false
        expect(json['error']).to eq('Not Found')
        expect(json['message']).to eq('Vote circle not found')
      end

      it 'logs vote circle not found event' do
        params_hash['vote_circle_id'] = '99999'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        expect(Rails.logger).to receive(:warn).with(a_string_matching(/vote_circle_not_found/))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
      end
    end
  end

  # ==================== ERROR HANDLING TESTS ====================

  describe 'error handling' do
    let(:params_hash) do
      {
        'email' => valid_email,
        'territory' => 'autonomy',
        'timestamp' => timestamp,
        'command' => 'militants_from_territory'
      }
    end
    let(:params_list) { %w[email territory timestamp range_name command] }

    before do
      signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
      params_hash['signature'] = signature
    end

    context 'when database error occurs' do
      it 'returns 500 internal server error' do
        allow(User).to receive(:find_by).and_raise(StandardError.new('Database error'))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:internal_server_error)
        json = response.parsed_body
        expect(json['success']).to be false
        expect(json['error']).to eq('Internal server error')
      end

      it 'does not expose error details' do
        allow(User).to receive(:find_by).and_raise(StandardError.new('Sensitive error'))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        json = response.parsed_body
        expect(json).not_to have_key('details')
        expect(json['error']).to eq('Internal server error')
      end

      it 'logs error with backtrace' do
        allow(User).to receive(:find_by).and_raise(StandardError.new('Database error'))

        expect(Rails.logger).to receive(:error).with(a_string_matching(/militants_from_territory_error.*backtrace/m))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
      end
    end

    context 'when vote circle query fails' do
      let(:params_hash) do
        {
          'vote_circle_id' => vote_circle.id.to_s,
          'territory' => 'autonomy',
          'timestamp' => timestamp,
          'command' => 'militants_from_vote_circle_territory'
        }
      end
      let(:params_list) { %w[vote_circle_id territory timestamp range_name command] }

      before do
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature
      end

      it 'returns 500 internal server error' do
        allow(VoteCircle).to receive(:find_by).and_raise(StandardError.new('Database error'))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:internal_server_error)
      end

      it 'logs error' do
        allow(VoteCircle).to receive(:find_by).and_raise(StandardError.new('Database error'))

        expect(Rails.logger).to receive(:error).with(a_string_matching(/militants_from_vote_circle_territory_error/))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
      end
    end
  end

  # ==================== LOGGING TESTS ====================

  describe 'security logging' do
    let(:params_hash) do
      {
        'email' => user_with_vote_circle.email,
        'territory' => 'autonomy',
        'timestamp' => timestamp,
        'command' => 'militants_from_territory'
      }
    end
    let(:params_list) { %w[email territory timestamp range_name command] }

    before do
      signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
      params_hash['signature'] = signature
    end

    it 'logs API calls' do
      expect(controller.send(:api_logger)).to receive(:info).with(a_string_matching(/api_call/))

      get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
    end

    it 'logs IP address' do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/ip_address/))

      get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
    end

    it 'logs user agent' do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/user_agent/))

      get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
    end

    it 'logs API version' do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/api_version.*v2/))

      get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
    end

    it 'logs timestamp in ISO8601 format' do
      expect(Rails.logger).to receive(:warn).with(a_string_matching(/timestamp.*\d{4}-\d{2}-\d{2}T/))

      get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json
    end
  end

  # ==================== RESPONSE FORMAT TESTS ====================

  describe 'response format' do
    let(:params_hash) do
      {
        'email' => user_with_vote_circle.email,
        'territory' => 'autonomy',
        'timestamp' => timestamp,
        'command' => 'militants_from_territory'
      }
    end
    let(:params_list) { %w[email territory timestamp range_name command] }

    before do
      signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
      params_hash['signature'] = signature
    end

    it 'returns success response with consistent structure' do
      get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

      json = response.parsed_body
      expect(json).to have_key('success')
      expect(json).to have_key('data')
      expect(json['success']).to be true
    end

    it 'returns error response with consistent structure' do
      params_hash['signature'] = 'invalid'

      get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

      json = response.parsed_body
      expect(json).to have_key('success')
      expect(json).to have_key('error')
      expect(json).to have_key('message')
      expect(json['success']).to be false
    end
  end
end
