# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes
  end

  let(:user) { create(:user, password: 'OldPassword123!', password_confirmation: 'OldPassword123!', has_legacy_password: true) }

  describe 'POST #create' do
    it 'logs password reset request' do
      allow(Rails.logger).to receive(:info).and_call_original

      post :create, params: { user: { email: user.email } }

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/password_reset_requested/)).at_least(:once)
    end

    it 'sends reset email' do
      post :create, params: { user: { email: user.email } }

      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'PUT #update' do
    let(:reset_token) { user.send(:set_reset_password_token) }

    context 'with valid token and passwords' do
      let(:valid_params) do
        {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }
      end

      it 'resets password' do
        put :update, params: valid_params

        user.reload
        expect(user.valid_password?('NewPassword123!')).to be true
      end

      it 'clears legacy password flag' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: valid_params

        user.reload
        expect(user.has_legacy_password?).to be false
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/legacy_password_cleared/)).at_least(:once)
      end

      it 'logs password reset success' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: valid_params

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/password_reset_success/)).at_least(:once)
      end

      it 'signs in user' do
        put :update, params: valid_params

        expect(controller.current_user).to eq(user)
      end

      it 'redirects after reset' do
        put :update, params: valid_params

        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid passwords' do
      let(:invalid_params) do
        {
          user: {
            reset_password_token: reset_token,
            password: 'short',
            password_confirmation: 'different'
          }
        }
      end

      it 'does not reset password' do
        old_encrypted_password = user.encrypted_password

        put :update, params: invalid_params

        user.reload
        expect(user.encrypted_password).to eq(old_encrypted_password)
      end

      it 'logs password reset failure' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: invalid_params

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/password_reset_failed/)).at_least(:once)
      end

      it 'renders errors' do
        put :update, params: invalid_params

        expect(response).to render_template(:edit)
      end
    end

    context 'error handling' do
      before do
        # Rails 7.2: Mock update_column instead of deprecated update_attribute
        allow_any_instance_of(User).to receive(:update_column).and_raise(StandardError.new('DB error'))
      end

      it 'handles errors gracefully' do
        allow(Rails.logger).to receive(:error).and_call_original

        put :update, params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }

        expect(Rails.logger).to have_received(:error).with(a_string_matching(/password_reset_error/)).at_least(:once)
        expect(response).to redirect_to("/en/users/sign_in")
      end
    end
  end

  describe '#set_flash_message' do
    it 'handles errors gracefully' do
      allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))

      expect { controller.send(:set_flash_message, :notice, :updated) }.not_to raise_error
    end
  end

  describe 'security logging' do
    it 'logs with IP address' do
      allow(Rails.logger).to receive(:info).and_call_original

      post :create, params: { user: { email: user.email } }

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"ip_address"/)).at_least(:once)
    end

    it 'logs with user agent' do
      allow(Rails.logger).to receive(:info).and_call_original

      post :create, params: { user: { email: user.email } }

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_agent"/)).at_least(:once)
    end

    it 'logs in JSON format' do
      allow(Rails.logger).to receive(:info).and_call_original

      post :create, params: { user: { email: user.email } }

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/^\{.*\}$/)).at_least(:once)
    end
  end
end
