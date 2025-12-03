# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LegacyPasswordController, type: :controller do
  let(:user_with_legacy) { create(:user, has_legacy_password: true, password: 'OldPassword123!', password_confirmation: 'OldPassword123!') }
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
        allow(Rails.logger).to receive(:info).and_call_original

        get :new

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/legacy_password_form_viewed/)).at_least(:once)
      end
    end

    context 'when user does not have legacy password' do
      before { sign_in user_without_legacy }

      it 'redirects to root' do
        get :new

        expect(response).to redirect_to(root_path)
      end

      it 'logs unauthorized access' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :new

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/legacy_password_unauthorized_access/)).at_least(:once)
      end
    end

    context 'when user not authenticated' do
      it 'redirects to sign in' do
        get :new

        expect(response).to redirect_to(%r{/users/sign_in})
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
          allow(Rails.logger).to receive(:info).and_call_original

          put :update, params: valid_params

          expect(Rails.logger).to have_received(:info).with(a_string_matching(/legacy_password_updated/)).at_least(:once)
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
          allow(Rails.logger).to receive(:info).and_call_original

          put :update, params: invalid_params

          expect(Rails.logger).to have_received(:info).with(a_string_matching(/legacy_password_update_failed/)).at_least(:once)
        end

        it 'renders new template' do
          put :update, params: invalid_params

          expect(response).to render_template(:new)
        end
      end

      context 'error handling' do
        it 'handles errors gracefully' do
          allow(Rails.logger).to receive(:error).and_call_original
          allow(controller).to receive(:current_user).and_return(user_with_legacy)
          allow(user_with_legacy).to receive(:update).and_raise(StandardError.new('DB error'))

          put :update, params: {
            user: {
              password: 'NewPassword123!',
              password_confirmation: 'NewPassword123!'
            }
          }

          expect(Rails.logger).to have_received(:error).with(a_string_matching(/legacy_password_update_error/)).at_least(:once)
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
      allow(Rails.logger).to receive(:info).and_call_original

      get :new

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"ip_address"/)).at_least(:once)
    end

    it 'logs with user agent' do
      allow(Rails.logger).to receive(:info).and_call_original

      get :new

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_agent"/)).at_least(:once)
    end

    it 'logs with user_id' do
      allow(Rails.logger).to receive(:info).and_call_original

      get :new

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_id":#{user_with_legacy.id}/)).at_least(:once)
    end

    it 'logs in JSON format' do
      allow(Rails.logger).to receive(:info).and_call_original

      get :new

      expect(Rails.logger).to have_received(:info).with(a_string_matching(/^\{.*\}$/)).at_least(:once)
    end
  end
end
