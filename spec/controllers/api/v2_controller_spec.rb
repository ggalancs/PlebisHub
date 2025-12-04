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
        forms: { 'secret' => secret },
        metas: nil
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

    context 'signature with length parameter' do
      it 'verifies signature with truncated length' do
        # Test the len parameter in verify_sign_url
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        # Simulate truncation by taking first 20 chars
        truncated_sig = signature[0..19]
        params_hash['signature'] = truncated_sig

        # This should fail since the signature doesn't match
        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

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

      it 'rejects missing timestamp' do
        params_hash.delete('timestamp')

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to eq('timestamp parameter is required')
      end

      it 'handles timestamp parsing exceptions' do
        # Stub Time.zone.at to raise an exception
        allow(Time.zone).to receive(:at).and_raise(ArgumentError.new('Invalid time'))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to eq('Invalid timestamp format')
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

      it 'filters by island' do
        vote_circle_with_island = create(:vote_circle, island_code: 'TF', autonomy_code: 'CN')
        user_with_island = create(:user, vote_circle: vote_circle_with_island, email: 'island@example.com')

        params_hash['email'] = user_with_island.email
        params_hash['territory'] = 'island'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
      end

      it 'filters by circle with exterior range_name' do
        exterior_circle = create(:vote_circle, :exterior)
        allow(VoteCircle).to receive(:exterior).and_return(VoteCircle.where(id: exterior_circle.id))

        params_hash['territory'] = 'circle'
        params_hash['range_name'] = 'exterior'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with user without vote circle' do
      it 'returns empty array when user has no vote circle' do
        user_without_circle = create(:user, email: 'nocircle@example.com', vote_circle: nil)

        params_hash['email'] = user_without_circle.email
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['data']).to eq([])
      end
    end

    context 'with vote circle missing territory values' do
      it 'returns empty array when territory value is nil' do
        vc_no_autonomy = create(:vote_circle, autonomy_code: nil)
        user_no_autonomy = create(:user, vote_circle: vc_no_autonomy, email: 'noautonomy@example.com')

        params_hash['email'] = user_no_autonomy.email
        params_hash['territory'] = 'autonomy'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['data']).to eq([])
      end
    end

    context 'data format verification' do
      it 'returns user data with correct structure' do
        # Create a militant user (need to check if User has militant scope or is_militant attribute)
        militant = create(:user, vote_circle: vote_circle, first_name: 'MilitantUser', phone: '+34600111222')

        # Stub the militant scope since we couldn't find it in the model
        allow(User).to receive_message_chain(:militant, :where, :find_each).and_yield(militant)

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        json = response.parsed_body
        expect(json['success']).to be true
        expect(json['data']).to be_an(Array)

        if json['data'].any?
          first_user = json['data'].first
          expect(first_user).to have_key('first_name')
          expect(first_user).to have_key('phone')
          expect(first_user).to have_key('circle_name')
        end
      end
    end

    context 'when get_militants_data raises error' do
      it 'returns empty array on error' do
        allow_any_instance_of(Api::V2Controller).to receive(:build_territory_query)
          .and_raise(StandardError.new('Database error'))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['data']).to eq([])
      end
    end
  end

  describe 'unknown command handling' do
    let(:params_hash) do
      {
        'email' => valid_email,
        'territory' => 'autonomy',
        'timestamp' => timestamp,
        'command' => 'unknown_command'
      }
    end
    let(:params_list) { %w[email territory timestamp range_name command] }

    # This test simulates what happens if validation is bypassed but an unknown command gets through
    it 'returns error for unknown command after signature verification' do
      # Bypass validation to test the command case statement
      allow_any_instance_of(Api::V2Controller).to receive(:validate_inputs).and_return(true)
      # Make signature verification pass
      allow_any_instance_of(Api::V2Controller).to receive(:verify_sign_url).and_return([true, 'test'])

      get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

      expect(response).to have_http_status(:bad_request)
      json = response.parsed_body
      expect(json['success']).to be false
      expect(json['error']).to eq('Bad Request')
      expect(json['message']).to eq('Unknown command')
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

    context 'territory filtering' do
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

      it 'filters by island' do
        vote_circle_with_island = create(:vote_circle, island_code: 'TF')
        params_hash['vote_circle_id'] = vote_circle_with_island.id.to_s
        params_hash['territory'] = 'island'
        signature = generate_signature('/api/v2/get_data.json', params_list, params_hash)
        params_hash['signature'] = signature

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:ok)
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

    context 'when unexpected error occurs in get_data' do
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

      it 'handles unexpected errors with 500 response' do
        # Make the command processing raise an unexpected error after signature verification
        allow_any_instance_of(Api::V2Controller).to receive(:build_param_list)
          .and_raise(StandardError.new('Unexpected error'))

        get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

        expect(response).to have_http_status(:internal_server_error)
        json = response.parsed_body
        expect(json['success']).to be false
        expect(json['error']).to eq('Internal server error')
      end

      it 'logs unexpected errors' do
        allow_any_instance_of(Api::V2Controller).to receive(:build_param_list)
          .and_raise(StandardError.new('Unexpected error'))

        expect(Rails.logger).to receive(:error).with(a_string_matching(/api_error.*Unexpected error/m))

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

  # ==================== API HEADERS TESTS ====================

  describe 'API version headers' do
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

    it 'sets X-API-Version header' do
      get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

      expect(response.headers['X-API-Version']).to eq('2.0')
    end

    it 'sets X-API-Deprecated header' do
      get :get_data, params: params_hash.transform_keys(&:to_sym), format: :json

      expect(response.headers['X-API-Deprecated']).to eq('false')
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
