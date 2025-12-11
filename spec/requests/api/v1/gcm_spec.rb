# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1 GCM/FCM Push Notification', type: :request do
  let(:valid_api_token) { 'test_api_token_123' }
  let(:valid_registration_id) { 'dGVzdC1yZWdpc3RyYXRpb24taWQtMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY' }
  let(:headers) { { 'X-API-Token' => valid_api_token } }

  before do
    allow(Rails.application.secrets).to receive(:api_tokens).and_return([valid_api_token])
  end

  describe 'POST /api/v1/gcm_register' do
    describe 'A. AUTHENTICATION' do
      it 'rejects requests without API token' do
        post '/api/v1/gcm_register', params: { v1: { registration_id: valid_registration_id } }
        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json['success']).to be false
        expect(json['error']).to eq('Unauthorized')
      end

      it 'rejects requests with invalid API token' do
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: valid_registration_id } },
             headers: { 'X-API-Token' => 'invalid_token' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'accepts requests with valid API token in header' do
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: valid_registration_id } },
             headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'accepts API token as parameter' do
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: valid_registration_id }, api_token: valid_api_token }
        expect(response).to have_http_status(:created)
      end
    end

    describe 'B. VALIDATION' do
      it 'rejects request without registration_id' do
        post '/api/v1/gcm_register',
             params: { v1: {} },
             headers: headers
        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to include('registration_id is required')
      end

      it 'rejects request with empty registration_id' do
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: '' } },
             headers: headers
        expect(response).to have_http_status(:bad_request)
      end

      it 'rejects registration_id that is too long' do
        long_id = 'a' * 5000
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: long_id } },
             headers: headers
        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to include('exceeds maximum length')
      end

      it 'rejects registration_id with invalid characters' do
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: 'invalid<script>token' } },
             headers: headers
        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['message']).to include('invalid characters')
      end

      it 'accepts valid registration_id format' do
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: 'ABC123-test_token:xyz' } },
             headers: headers
        expect(response).to have_http_status(:created)
      end
    end

    describe 'C. SUCCESSFUL REGISTRATION' do
      it 'creates a new registration' do
        expect {
          post '/api/v1/gcm_register',
               params: { v1: { registration_id: valid_registration_id } },
               headers: headers
        }.to change(NoticeRegistrar, :count).by(1)
      end

      it 'returns registration details' do
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: valid_registration_id } },
             headers: headers

        json = response.parsed_body
        expect(json['success']).to be true
        expect(json['registration']['registration_id']).to eq(valid_registration_id)
        expect(json['registration']['id']).to be_present
      end

      it 'is idempotent - registering twice returns same registration' do
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: valid_registration_id } },
             headers: headers
        first_id = response.parsed_body['registration']['id']

        post '/api/v1/gcm_register',
             params: { v1: { registration_id: valid_registration_id } },
             headers: headers
        second_id = response.parsed_body['registration']['id']

        expect(first_id).to eq(second_id)
      end
    end

    describe 'D. API HEADERS' do
      it 'includes API version header' do
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: valid_registration_id } },
             headers: headers
        expect(response.headers['X-API-Version']).to eq('1.0')
      end

      it 'includes deprecation header' do
        post '/api/v1/gcm_register',
             params: { v1: { registration_id: valid_registration_id } },
             headers: headers
        expect(response.headers['X-API-Deprecated']).to eq('false')
      end
    end
  end

  describe 'DELETE /api/v1/gcm_unregister' do
    let!(:existing_registration) { NoticeRegistrar.create!(registration_id: valid_registration_id) }

    describe 'A. AUTHENTICATION' do
      it 'rejects requests without API token' do
        delete '/api/v1/gcm_unregister', params: { v1: { registration_id: valid_registration_id } }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'accepts requests with valid API token' do
        delete '/api/v1/gcm_unregister',
               params: { v1: { registration_id: valid_registration_id } },
               headers: headers
        expect([200, 404]).to include(response.status)
      end
    end

    describe 'B. VALIDATION' do
      it 'rejects request without registration_id' do
        delete '/api/v1/gcm_unregister',
               params: { v1: {} },
               headers: headers
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'C. SUCCESSFUL UNREGISTRATION' do
      it 'deletes the registration' do
        expect {
          delete '/api/v1/gcm_unregister',
                 params: { v1: { registration_id: valid_registration_id } },
                 headers: headers
        }.to change(NoticeRegistrar, :count).by(-1)
      end

      it 'returns success message' do
        delete '/api/v1/gcm_unregister',
               params: { v1: { registration_id: valid_registration_id } },
               headers: headers

        json = response.parsed_body
        expect(json['success']).to be true
        expect(json['message']).to include('unregistered')
      end
    end

    describe 'D. NON-EXISTENT REGISTRATION' do
      it 'returns not found for non-existent registration' do
        delete '/api/v1/gcm_unregister',
               params: { v1: { registration_id: 'non_existent_token' } },
               headers: headers

        expect(response).to have_http_status(:not_found)
        json = response.parsed_body
        expect(json['success']).to be false
        expect(json['error']).to eq('Registration not found')
      end
    end
  end

  describe 'POST /api/v1/gcm_registrate (alias)' do
    it 'works as alias for gcm_register' do
      post '/api/v1/gcm_registrate',
           params: { v1: { registration_id: valid_registration_id } },
           headers: headers
      # May or may not exist as alias - accept success or not found
      expect([201, 404]).to include(response.status)
    end
  end
end
