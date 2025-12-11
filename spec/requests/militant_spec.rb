# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Militant API', type: :request do
  let(:user) { create(:user, :with_dni) }
  let(:signature_service) { instance_double(UrlSignatureService) }

  # Use correct route path from routes.rb
  # Route: (/:locale)/tools/militant_request/get_external_info
  let(:base_path) { '/es/tools/militant_request/get_external_info' }

  before do
    allow(UrlSignatureService).to receive(:new).and_return(signature_service)
  end

  describe 'GET /es/tools/militant_request/get_external_info' do
    describe 'A. INPUT VALIDATION' do
      it 'requires participa_user_id parameter' do
        allow(signature_service).to receive(:verify_militant_url).and_return([true, 'verified'])

        get base_path
        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['error']).to include('participa_user_id')
      end

      it 'rejects invalid (non-numeric) user_id' do
        allow(signature_service).to receive(:verify_militant_url).and_return([true, 'verified'])

        get base_path, params: { participa_user_id: 'abc' }
        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['error']).to eq('Invalid user ID')
      end

      it 'rejects zero user_id' do
        allow(signature_service).to receive(:verify_militant_url).and_return([true, 'verified'])

        get base_path, params: { participa_user_id: 0 }
        expect(response).to have_http_status(:bad_request)
      end

      it 'rejects negative user_id' do
        allow(signature_service).to receive(:verify_militant_url).and_return([true, 'verified'])

        get base_path, params: { participa_user_id: -1 }
        expect(response).to have_http_status(:bad_request)
      end
    end

    describe 'B. SIGNATURE VERIFICATION' do
      it 'rejects request with invalid signature' do
        allow(signature_service).to receive(:verify_militant_url).and_return([false, 'Invalid signature'])

        get base_path, params: { participa_user_id: user.id }
        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json['error']).to eq('Invalid signature')
      end

      it 'accepts request with valid signature' do
        allow(signature_service).to receive(:verify_militant_url).and_return([true, 'verified'])
        allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(true)

        get base_path, params: { participa_user_id: user.id, collaborate: 'true' }
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'C. USER LOOKUP' do
      before do
        allow(signature_service).to receive(:verify_militant_url).and_return([true, 'verified'])
      end

      it 'returns not found for non-existent user' do
        get base_path, params: { participa_user_id: 999_999 }
        expect(response).to have_http_status(:not_found)
        json = response.parsed_body
        expect(json['error']).to eq('User not found')
        expect(json['user_id']).to eq(999_999)
      end

      it 'finds existing user' do
        allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(true)

        get base_path, params: { participa_user_id: user.id, collaborate: 'true' }
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['user_id']).to eq(user.id)
      end
    end

    describe 'D. COLLABORATE QUERY' do
      before do
        allow(signature_service).to receive(:verify_militant_url).and_return([true, 'verified'])
      end

      context 'when user is a collaborator' do
        before do
          allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(true)
        end

        it 'returns result=1' do
          get base_path, params: { participa_user_id: user.id, collaborate: 'true' }
          expect(response).to have_http_status(:ok)
          json = response.parsed_body
          expect(json['result']).to eq('1')
          expect(json['is_collaborator']).to be true
        end
      end

      context 'when user is not a collaborator' do
        before do
          allow_any_instance_of(User).to receive(:collaborator_for_militant?).and_return(false)
        end

        it 'returns result=0' do
          get base_path, params: { participa_user_id: user.id, collaborate: 'true' }
          expect(response).to have_http_status(:ok)
          json = response.parsed_body
          expect(json['result']).to eq('0')
          expect(json['is_collaborator']).to be false
        end
      end
    end

    describe 'E. EXEMPTION UPDATE' do
      before do
        allow(signature_service).to receive(:verify_militant_url).and_return([true, 'verified'])
        allow_any_instance_of(User).to receive(:still_militant?).and_return(true)
        allow_any_instance_of(User).to receive(:process_militant_data)
      end

      it 'accepts exemption=true' do
        get base_path, params: {
          participa_user_id: user.id,
          exemption: 'true'
        }
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['result']).to eq('OK')
        expect(json['exemption']).to be true
      end

      it 'accepts exemption=1' do
        get base_path, params: {
          participa_user_id: user.id,
          exemption: '1'
        }
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['exemption']).to be true
      end

      it 'accepts exemption=false' do
        get base_path, params: {
          participa_user_id: user.id,
          exemption: 'false'
        }
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['exemption']).to be false
      end

      it 'accepts exemption=0' do
        get base_path, params: {
          participa_user_id: user.id,
          exemption: '0'
        }
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['exemption']).to be false
      end

      it 'rejects invalid exemption value' do
        get base_path, params: {
          participa_user_id: user.id,
          exemption: 'invalid'
        }
        expect(response).to have_http_status(:bad_request)
        json = response.parsed_body
        expect(json['error']).to include('Invalid exemption value')
      end

      it 'defaults to false when exemption is empty' do
        get base_path, params: {
          participa_user_id: user.id,
          exemption: ''
        }
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['exemption']).to be false
      end

      it 'returns militant status in response' do
        get base_path, params: {
          participa_user_id: user.id,
          exemption: 'true'
        }
        json = response.parsed_body
        expect(json).to have_key('militant')
      end
    end

    describe 'F. ERROR HANDLING' do
      before do
        allow(signature_service).to receive(:verify_militant_url).and_return([true, 'verified'])
      end

      it 'handles update failure gracefully' do
        allow_any_instance_of(User).to receive(:update!).and_raise(
          ActiveRecord::RecordInvalid.new(User.new)
        )

        get base_path, params: {
          participa_user_id: user.id,
          exemption: 'true'
        }
        expect(response).to have_http_status(:unprocessable_content)
        json = response.parsed_body
        expect(json['error']).to eq('Failed to update user')
      end
    end
  end
end
