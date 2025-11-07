# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let(:user) { create(:user, password: 'OldPassword123!', has_legacy_password: true) }

  describe 'POST #create' do
    it 'logs password reset request' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/password_reset_requested/))

      post :create, params: { user: { email: user.email } }
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
        expect(Rails.logger).to receive(:info).with(a_string_matching(/legacy_password_cleared/))

        put :update, params: valid_params

        user.reload
        expect(user.has_legacy_password?).to be false
      end

      it 'logs password reset success' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/password_reset_success/))

        put :update, params: valid_params
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
        expect(Rails.logger).to receive(:info).with(a_string_matching(/password_reset_failed/))

        put :update, params: invalid_params
      end

      it 'renders errors' do
        put :update, params: invalid_params

        expect(response).to render_template(:edit)
      end
    end

    context 'error handling' do
      before do
        allow_any_instance_of(User).to receive(:update_attribute).and_raise(StandardError.new('DB error'))
      end

      it 'handles errors gracefully' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/password_reset_error/))

        put :update, params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }

        expect(response).to redirect_to(new_user_session_path)
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
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"ip_address"/))

      post :create, params: { user: { email: user.email } }
    end

    it 'logs with user agent' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"user_agent"/))

      post :create, params: { user: { email: user.email } }
    end

    it 'logs in JSON format' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/^\{.*\}$/))

      post :create, params: { user: { email: user.email } }
    end
  end
end
