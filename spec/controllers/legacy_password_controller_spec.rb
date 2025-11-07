# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LegacyPasswordController, type: :controller do
  let(:user_with_legacy) { create(:user, has_legacy_password: true, password: 'OldPassword123!') }
  let(:user_without_legacy) { create(:user, has_legacy_password: false) }

  describe 'GET #new' do
    context 'when user has legacy password' do
      before { sign_in user_with_legacy }

      it 'renders new template' do
        get :new

        expect(response).to be_successful
        expect(response).to render_template(:new)
      end

      it 'logs form view' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/legacy_password_form_viewed/))

        get :new
      end
    end

    context 'when user does not have legacy password' do
      before { sign_in user_without_legacy }

      it 'redirects to root' do
        get :new

        expect(response).to redirect_to(root_path)
      end

      it 'logs unauthorized access' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/legacy_password_unauthorized_access/))

        get :new
      end
    end

    context 'when user not authenticated' do
      it 'redirects to sign in' do
        get :new

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PUT #update' do
    context 'when user has legacy password' do
      before { sign_in user_with_legacy }

      context 'with valid password' do
        let(:valid_params) do
          {
            user: {
              password: 'NewPassword123!',
              password_confirmation: 'NewPassword123!'
            }
          }
        end

        it 'updates password' do
          put :update, params: valid_params

          user_with_legacy.reload
          expect(user_with_legacy.valid_password?('NewPassword123!')).to be true
        end

        it 'clears legacy password flag' do
          put :update, params: valid_params

          user_with_legacy.reload
          expect(user_with_legacy.has_legacy_password?).to be false
        end

        it 'logs password update' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/legacy_password_updated/))

          put :update, params: valid_params
        end

        it 're-authenticates user' do
          put :update, params: valid_params

          expect(controller.current_user).to eq(user_with_legacy)
        end

        it 'redirects to root' do
          put :update, params: valid_params

          expect(response).to redirect_to(root_path)
        end
      end

      context 'with invalid password' do
        let(:invalid_params) do
          {
            user: {
              password: 'short',
              password_confirmation: 'different'
            }
          }
        end

        it 'does not update password' do
          old_encrypted_password = user_with_legacy.encrypted_password

          put :update, params: invalid_params

          user_with_legacy.reload
          expect(user_with_legacy.encrypted_password).to eq(old_encrypted_password)
        end

        it 'logs update failure' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/legacy_password_update_failed/))

          put :update, params: invalid_params
        end

        it 'renders new template' do
          put :update, params: invalid_params

          expect(response).to render_template(:new)
        end
      end

      context 'error handling' do
        before do
          allow(user_with_legacy).to receive(:update).and_raise(StandardError.new('DB error'))
        end

        it 'handles errors gracefully' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/legacy_password_update_error/))

          put :update, params: {
            user: {
              password: 'NewPassword123!',
              password_confirmation: 'NewPassword123!'
            }
          }

          expect(response).to render_template(:new)
        end
      end
    end

    context 'when user does not have legacy password' do
      before { sign_in user_without_legacy }

      it 'redirects to root' do
        put :update, params: {
          user: {
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'security logging' do
    before { sign_in user_with_legacy }

    it 'logs with IP address' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"ip_address"/))

      get :new
    end

    it 'logs with user agent' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"user_agent"/))

      get :new
    end

    it 'logs with user_id' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"user_id":#{user_with_legacy.id}/))

      get :new
    end

    it 'logs in JSON format' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/^\{.*\}$/))

      get :new
    end
  end
end
