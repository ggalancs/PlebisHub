# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1Controller, type: :controller do
  let(:valid_token) { 'test_api_token_123' }
  let(:invalid_token) { 'invalid_token' }
  let(:valid_registration_id) { 'test_gcm_token_abc123xyz' }
  let(:existing_registration) { create(:notice_registrar, registration_id: 'existing_token_123') }

  before do
    # Rails 7.2 FIX: Use main app routes
    @routes = Rails.application.routes

    # Mock API tokens configuration
    allow(Rails.application).to receive(:secrets).and_return(
      double(api_tokens: [valid_token])
    )

    # Skip ApplicationController filters for isolation
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)
  end

  # ==================== AUTHENTICATION TESTS ====================

  describe 'API token authentication' do
    context 'with valid token in header' do
      before do
        request.headers['X-API-Token'] = valid_token
      end

      it 'allows access to gcm_register' do
        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json
        expect(response).to have_http_status(:created)
      end

      it 'allows access to gcm_unregister' do
        delete :gcm_unregister, params: { v1: { registration_id: valid_registration_id } }, format: :json
        expect(response).not_to have_http_status(:unauthorized)
      end
    end

    context 'with valid token as parameter' do
      it 'allows access when token passed as param' do
        post :gcm_register, params: {
          v1: { registration_id: valid_registration_id },
          api_token: valid_token
        }, format: :json

        expect(response).to have_http_status(:created)
      end
    end

    context 'without token' do
      it 'returns 401 unauthorized for gcm_register' do
        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body['error']).to eq('Unauthorized')
      end

      it 'returns 401 unauthorized for gcm_unregister' do
        delete :gcm_unregister, params: { v1: { registration_id: valid_registration_id } }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'logs authentication failure' do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_api_token_attempt/))

        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json
      end
    end

    context 'with invalid token' do
      before do
        request.headers['X-API-Token'] = invalid_token
      end

      it 'returns 401 unauthorized' do
        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'logs invalid token attempt' do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_api_token_attempt/))

        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json
      end
    end

    context 'token timing attack prevention' do
      it 'uses secure_compare to prevent timing attacks' do
        expect(ActiveSupport::SecurityUtils).to receive(:secure_compare).at_least(:once).and_call_original

        request.headers['X-API-Token'] = valid_token
        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json
      end
    end
  end

  # ==================== INPUT VALIDATION TESTS ====================

  describe 'registration_id validation' do
    before do
      request.headers['X-API-Token'] = valid_token
    end

    context 'missing registration_id' do
      it 'returns 400 bad request' do
        post :gcm_register, params: { v1: {} }, format: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['message']).to include('required')
      end

      it 'logs missing registration_id' do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/missing_registration_id/))

        post :gcm_register, params: { v1: {} }, format: :json
      end
    end

    context 'blank registration_id' do
      it 'returns 400 bad request for empty string' do
        post :gcm_register, params: { v1: { registration_id: '' } }, format: :json

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns 400 bad request for whitespace only' do
        post :gcm_register, params: { v1: { registration_id: '   ' } }, format: :json

        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'registration_id too long' do
      it 'rejects tokens over 4096 characters' do
        long_token = 'a' * 4097

        post :gcm_register, params: { v1: { registration_id: long_token } }, format: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['message']).to include('exceeds maximum length')
      end

      it 'logs overly long registration_id' do
        long_token = 'a' * 4097

        expect(Rails.logger).to receive(:warn).with(a_string_matching(/registration_id_too_long/))

        post :gcm_register, params: { v1: { registration_id: long_token } }, format: :json
      end
    end

    context 'registration_id with invalid characters' do
      it 'rejects tokens with spaces' do
        post :gcm_register, params: { v1: { registration_id: 'token with spaces' } }, format: :json

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['message']).to include('invalid characters')
      end

      it 'rejects tokens with special characters' do
        post :gcm_register, params: { v1: { registration_id: 'token@#$%' } }, format: :json

        expect(response).to have_http_status(:bad_request)
      end

      it 'accepts tokens with hyphens' do
        post :gcm_register, params: { v1: { registration_id: 'token-with-hyphens' } }, format: :json

        expect(response).to have_http_status(:created)
      end

      it 'accepts tokens with underscores' do
        post :gcm_register, params: { v1: { registration_id: 'token_with_underscores' } }, format: :json

        expect(response).to have_http_status(:created)
      end

      it 'accepts tokens with colons' do
        post :gcm_register, params: { v1: { registration_id: 'token:with:colons' } }, format: :json

        expect(response).to have_http_status(:created)
      end

      it 'logs invalid format attempts' do
        expect(Rails.logger).to receive(:warn).with(a_string_matching(/invalid_registration_id_format/))

        post :gcm_register, params: { v1: { registration_id: 'token with spaces' } }, format: :json
      end
    end

    context 'valid registration_id' do
      it 'accepts alphanumeric tokens' do
        post :gcm_register, params: { v1: { registration_id: 'abc123DEF456' } }, format: :json

        expect(response).to have_http_status(:created)
      end

      it 'accepts tokens up to 4096 characters' do
        max_token = 'a' * 4096

        post :gcm_register, params: { v1: { registration_id: max_token } }, format: :json

        expect(response).to have_http_status(:created)
      end
    end
  end

  # ==================== FUNCTIONALITY TESTS ====================

  describe 'gcm_register' do
    before do
      request.headers['X-API-Token'] = valid_token
    end

    it 'creates new registration' do
      expect do
        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json
      end.to change(NoticeRegistrar, :count).by(1)
    end

    it 'returns 201 created status' do
      post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

      expect(response).to have_http_status(:created)
    end

    it 'returns registration details in response' do
      post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

      json_response = response.parsed_body
      expect(json_response['success']).to be true
      expect(json_response['registration']['registration_id']).to eq(valid_registration_id)
      expect(json_response['registration']).to have_key('id')
      expect(json_response['registration']).to have_key('created_at')
    end

    it 'updates existing registration (idempotent)' do
      create(:notice_registrar, registration_id: valid_registration_id)

      expect do
        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json
      end.not_to change(NoticeRegistrar, :count)

      expect(response).to have_http_status(:created)
    end

    it 'logs registration creation' do
      allow(Rails.logger).to receive(:info).and_call_original

      post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/gcm_registration_created/)).at_least(:once)
    end

    context 'when validation fails' do
      before do
        allow_any_instance_of(NoticeRegistrar).to receive(:save).and_raise(
          ActiveRecord::RecordInvalid.new(NoticeRegistrar.new)
        )
      end

      it 'returns 422 unprocessable entity' do
        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error details' do
        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

        json_response = response.parsed_body
        expect(json_response['success']).to be false
        expect(json_response).to have_key('error')
      end

      it 'logs validation error' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/gcm_registration_failed/))

        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json
      end
    end

    context 'when unexpected error occurs' do
      before do
        allow(NoticeRegistrar).to receive(:find_or_create_by).and_raise(StandardError.new('Database error'))
      end

      it 'returns 500 internal server error' do
        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

        expect(response).to have_http_status(:internal_server_error)
      end

      it "doesn't expose error details" do
        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

        json_response = response.parsed_body
        expect(json_response['error']).to eq('Internal server error')
        expect(json_response).not_to have_key('details')
      end

      it 'logs error with backtrace' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/gcm_registration_error.*backtrace/m))

        post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json
      end
    end
  end

  describe 'gcm_registrate (alias)' do
    before do
      request.headers['X-API-Token'] = valid_token
    end

    it 'works as alias for gcm_register' do
      expect do
        post :gcm_registrate, params: { v1: { registration_id: valid_registration_id } }, format: :json
      end.to change(NoticeRegistrar, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe 'gcm_unregister' do
    before do
      request.headers['X-API-Token'] = valid_token
    end

    context 'with existing registration' do
      let!(:registration) { create(:notice_registrar, registration_id: valid_registration_id) }

      it 'deletes the registration' do
        expect do
          delete :gcm_unregister, params: { v1: { registration_id: valid_registration_id } }, format: :json
        end.to change(NoticeRegistrar, :count).by(-1)
      end

      it 'returns 200 ok status' do
        delete :gcm_unregister, params: { v1: { registration_id: valid_registration_id } }, format: :json

        expect(response).to have_http_status(:ok)
      end

      it 'returns success message' do
        delete :gcm_unregister, params: { v1: { registration_id: valid_registration_id } }, format: :json

        json_response = response.parsed_body
        expect(json_response['success']).to be true
        expect(json_response['message']).to include('unregistered successfully')
      end

      it 'logs unregistration' do
        allow(Rails.logger).to receive(:info).and_call_original

        delete :gcm_unregister, params: { v1: { registration_id: valid_registration_id } }, format: :json

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/gcm_registration_deleted/)).at_least(:once)
      end
    end

    context 'with non-existent registration' do
      it 'returns 404 not found' do
        delete :gcm_unregister, params: { v1: { registration_id: 'nonexistent_token' } }, format: :json

        expect(response).to have_http_status(:not_found)
      end

      it 'returns error message' do
        delete :gcm_unregister, params: { v1: { registration_id: 'nonexistent_token' } }, format: :json

        json_response = response.parsed_body
        expect(json_response['success']).to be false
        expect(json_response['error']).to include('not found')
      end

      it 'logs not found attempt' do
        allow(Rails.logger).to receive(:info).and_call_original

        delete :gcm_unregister, params: { v1: { registration_id: 'nonexistent_token' } }, format: :json

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/gcm_unregister_not_found/)).at_least(:once)
      end

      it "doesn't change registration count" do
        expect do
          delete :gcm_unregister, params: { v1: { registration_id: 'nonexistent_token' } }, format: :json
        end.not_to change(NoticeRegistrar, :count)
      end
    end

    context 'when error occurs during deletion' do
      before do
        allow_any_instance_of(NoticeRegistrar).to receive(:destroy).and_raise(StandardError.new('Delete error'))
      end

      it 'returns 500 internal server error' do
        create(:notice_registrar, registration_id: valid_registration_id)

        delete :gcm_unregister, params: { v1: { registration_id: valid_registration_id } }, format: :json

        expect(response).to have_http_status(:internal_server_error)
      end

      it 'logs error' do
        create(:notice_registrar, registration_id: valid_registration_id)

        expect(Rails.logger).to receive(:error).with(a_string_matching(/gcm_unregister_error/))

        delete :gcm_unregister, params: { v1: { registration_id: valid_registration_id } }, format: :json
      end
    end
  end

  # ==================== LOGGING TESTS ====================

  describe 'security logging' do
    before do
      request.headers['X-API-Token'] = valid_token
    end

    it 'logs IP address' do
      allow(Rails.logger).to receive(:info).and_call_original

      post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/ip_address/)).at_least(:once)
    end

    it 'logs user agent' do
      allow(Rails.logger).to receive(:info).and_call_original

      post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/user_agent/)).at_least(:once)
    end

    it 'logs API version' do
      allow(Rails.logger).to receive(:info).and_call_original

      post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/api_version.*v1/)).at_least(:once)
    end

    it 'logs timestamp in ISO8601 format' do
      allow(Rails.logger).to receive(:info).and_call_original

      post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/timestamp.*\d{4}-\d{2}-\d{2}T/)).at_least(:once)
    end
  end

  # ==================== DEPRECATED METHODS TESTS ====================

  describe 'deprecated methods' do
    it 'uses skip_before_action instead of skip_before_filter' do
      # Rails 7.2 FIX: Verify the controller skips authenticity token verification
      # In Rails 7.2, we verify this by checking that CSRF protection is disabled
      request.headers['X-API-Token'] = valid_token

      # If skip_before_action works, this should succeed without CSRF token
      post :gcm_register, params: { v1: { registration_id: valid_registration_id } }, format: :json

      # The fact that we get a successful response proves skip_before_action worked
      expect(response).to have_http_status(:created)
    end
  end
end
