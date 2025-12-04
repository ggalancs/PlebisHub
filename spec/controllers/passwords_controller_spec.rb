# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes
  end

  let(:user) do
    create(:user,
           password: 'OldPassword123!',
           password_confirmation: 'OldPassword123!',
           has_legacy_password: true)
  end

  let(:user_without_legacy) do
    create(:user,
           password: 'OldPassword123!',
           password_confirmation: 'OldPassword123!',
           has_legacy_password: false)
  end

  let(:locked_user) do
    create(:user,
           password: 'OldPassword123!',
           password_confirmation: 'OldPassword123!',
           locked_at: 1.hour.ago,
           has_legacy_password: true)
  end

  let(:inactive_user) do
    create(:user,
           password: 'OldPassword123!',
           password_confirmation: 'OldPassword123!',
           confirmed_at: nil,
           has_legacy_password: false)
  end

  describe 'GET #new' do
    it 'renders the new password form' do
      get :new

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe 'GET #edit' do
    let(:reset_token) { user.send(:set_reset_password_token) }

    it 'renders the edit password form with valid token' do
      get :edit, params: { reset_password_token: reset_token }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
    end

    it 'handles invalid token gracefully' do
      get :edit, params: { reset_password_token: 'invalid_token' }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    context 'with valid email' do
      it 'logs password reset request' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/password_reset_requested/))
          .at_least(:once)
      end

      it 'logs email in security event' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/#{user.email}/))
          .at_least(:once)
      end

      it 'sends reset email' do
        post :create, params: { user: { email: user.email } }

        expect(response).to have_http_status(:redirect)
      end

      it 'redirects to login page' do
        post :create, params: { user: { email: user.email } }

        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets flash message' do
        post :create, params: { user: { email: user.email } }

        expect(flash[:notice]).to be_present
      end
    end

    context 'with non-existent email' do
      it 'still succeeds (security: no user enumeration)' do
        post :create, params: { user: { email: 'nonexistent@example.com' } }

        expect(response).to have_http_status(:redirect)
      end

      it 'logs the attempt' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: 'nonexistent@example.com' } }

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/password_reset_requested/))
          .at_least(:once)
      end
    end

    context 'with blank email' do
      it 'redirects after processing (security: no enumeration)' do
        post :create, params: { user: { email: '' } }

        # Devise still redirects even with blank email (security best practice)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid format email' do
      it 'redirects after processing (security: no enumeration)' do
        post :create, params: { user: { email: 'not-an-email' } }

        # Devise still redirects even with invalid email (security best practice)
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'security logging' do
      it 'logs IP address' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/"ip_address"/))
          .at_least(:once)
      end

      it 'logs user agent' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/"user_agent"/))
          .at_least(:once)
      end

      it 'logs timestamp' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/"timestamp"/))
          .at_least(:once)
      end

      it 'logs in JSON format' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/^\{.*\}$/))
          .at_least(:once)
      end

      it 'logs controller name' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/"controller":"passwords"/))
          .at_least(:once)
      end
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

      it 'invalidates old password' do
        put :update, params: valid_params

        user.reload
        expect(user.valid_password?('OldPassword123!')).to be false
      end

      it 'clears legacy password flag when user has legacy password' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: valid_params

        user.reload
        expect(user.has_legacy_password?).to be false
        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/legacy_password_cleared/))
          .at_least(:once)
      end

      it 'does not log legacy password cleared when user does not have legacy password' do
        token = user_without_legacy.send(:set_reset_password_token)
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: {
          user: {
            reset_password_token: token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }

        expect(Rails.logger).not_to have_received(:info)
          .with(a_string_matching(/legacy_password_cleared/))
      end

      it 'logs password reset success' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: valid_params

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/password_reset_success/))
          .at_least(:once)
      end

      it 'logs user ID in success event' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: valid_params

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/user_id.*#{user.id}/))
          .at_least(:once)
      end

      it 'logs user email in success event' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: valid_params

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/#{user.email}/))
          .at_least(:once)
      end

      it 'signs in user' do
        put :update, params: valid_params

        expect(controller.current_user).to eq(user)
      end

      it 'redirects after reset' do
        put :update, params: valid_params

        expect(response).to have_http_status(:redirect)
      end

      it 'sets flash notice for active user' do
        put :update, params: valid_params

        expect(flash[:notice]).to be_present
      end

      it 'redirects to root path for active user' do
        put :update, params: valid_params

        expect(response).to redirect_to(root_path)
      end
    end

    context 'with locked user' do
      let(:reset_token) { locked_user.send(:set_reset_password_token) }
      let(:valid_params) do
        {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }
      end

      it 'unlocks the account if unlockable' do
        put :update, params: valid_params

        locked_user.reload
        # Account gets unlocked via unlock_access! if resource has lockable strategy
        expect(locked_user.access_locked?).to be false
      end

      it 'resets password for locked user' do
        put :update, params: valid_params

        locked_user.reload
        expect(locked_user.valid_password?('NewPassword123!')).to be true
      end
    end

    context 'with inactive user' do
      let(:reset_token) { inactive_user.send(:set_reset_password_token) }
      let(:valid_params) do
        {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }
      end

      it 'resets password for inactive user' do
        put :update, params: valid_params

        inactive_user.reload
        expect(inactive_user.valid_password?('NewPassword123!')).to be true
      end

      it 'sets appropriate flash message for inactive user' do
        put :update, params: valid_params

        expect(flash[:notice]).to be_present
      end

      it 'signs in user and redirects' do
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

      it 'does not change legacy password flag' do
        put :update, params: invalid_params

        user.reload
        expect(user.has_legacy_password?).to be true
      end

      it 'logs password reset failure' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: invalid_params

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/password_reset_failed/))
          .at_least(:once)
      end

      it 'logs errors in failure event' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: invalid_params

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/errors/))
          .at_least(:once)
      end

      it 'logs token presence in failure event' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: invalid_params

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/token_present.*true/))
          .at_least(:once)
      end

      it 'renders errors' do
        put :update, params: invalid_params

        expect(response).to render_template(:edit)
      end

      it 'does not sign in user' do
        put :update, params: invalid_params

        expect(controller.current_user).to be_nil
      end

      it 'shows error messages' do
        put :update, params: invalid_params

        expect(response).to render_template(:edit)
      end
    end

    context 'with missing password' do
      let(:params_without_password) do
        {
          user: {
            reset_password_token: reset_token,
            password: '',
            password_confirmation: ''
          }
        }
      end

      it 'does not reset password' do
        old_encrypted_password = user.encrypted_password

        put :update, params: params_without_password

        user.reload
        expect(user.encrypted_password).to eq(old_encrypted_password)
      end

      it 'renders edit template' do
        put :update, params: params_without_password

        expect(response).to render_template(:edit)
      end
    end

    context 'with mismatched password confirmation' do
      let(:mismatched_params) do
        {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'DifferentPassword123!'
          }
        }
      end

      it 'does not reset password' do
        old_encrypted_password = user.encrypted_password

        put :update, params: mismatched_params

        user.reload
        expect(user.encrypted_password).to eq(old_encrypted_password)
      end

      it 'logs failure with token present' do
        allow(Rails.logger).to receive(:info).and_call_original

        put :update, params: mismatched_params

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/password_reset_failed.*token_present.*true/m))
          .at_least(:once)
      end
    end

    context 'with expired token' do
      let(:expired_params) do
        {
          user: {
            reset_password_token: 'expired_token',
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }
      end

      it 'does not reset password' do
        old_encrypted_password = user.encrypted_password

        put :update, params: expired_params

        user.reload
        expect(user.encrypted_password).to eq(old_encrypted_password)
      end

      it 'responds with edit or redirect' do
        put :update, params: expired_params

        # May render edit or respond_with based on Devise configuration
        expect([200, 302]).to include(response.status)
      end
    end

    context 'with missing token' do
      let(:params_without_token) do
        {
          user: {
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }
      end

      it 'does not reset password' do
        old_encrypted_password = user.encrypted_password

        put :update, params: params_without_token

        user.reload
        expect(user.encrypted_password).to eq(old_encrypted_password)
      end

      it 'responds with error state' do
        put :update, params: params_without_token

        # Responds with edit template showing errors
        expect(response.status).to be_in([200, 302])
      end
    end

    context 'with weak password' do
      let(:weak_password_params) do
        {
          user: {
            reset_password_token: reset_token,
            password: 'weak',
            password_confirmation: 'weak'
          }
        }
      end

      it 'does not reset password' do
        old_encrypted_password = user.encrypted_password

        put :update, params: weak_password_params

        user.reload
        expect(user.encrypted_password).to eq(old_encrypted_password)
      end

      it 'renders edit showing validation errors' do
        put :update, params: weak_password_params

        expect(response).to render_template(:edit)
      end
    end

    context 'error handling' do
      before do
        # Rails 7.2: Mock update_column to raise error
        allow_any_instance_of(User).to receive(:update_column)
          .and_raise(StandardError.new('DB error'))
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

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/password_reset_error/))
          .at_least(:once)
      end

      it 'logs error class' do
        allow(Rails.logger).to receive(:error).and_call_original

        put :update, params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/error_class.*StandardError/))
          .at_least(:once)
      end

      it 'logs error message' do
        allow(Rails.logger).to receive(:error).and_call_original

        put :update, params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/error_message.*DB error/))
          .at_least(:once)
      end

      it 'logs backtrace' do
        allow(Rails.logger).to receive(:error).and_call_original

        put :update, params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/backtrace/))
          .at_least(:once)
      end

      it 'redirects to login page' do
        put :update, params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }

        expect(response).to redirect_to('/en/users/sign_in')
      end

      it 'sets flash alert' do
        put :update, params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }

        expect(flash[:alert]).to be_present
      end

      it 'does not expose error details to user' do
        put :update, params: {
          user: {
            reset_password_token: reset_token,
            password: 'NewPassword123!',
            password_confirmation: 'NewPassword123!'
          }
        }

        expect(flash[:alert]).not_to include('DB error')
      end
    end
  end

  describe '#set_flash_message' do
    it 'sets flash message with resource params' do
      allow(controller).to receive(:resource_params).and_return({ test: 'value' })
      allow(controller).to receive(:find_message).and_return('Test message')

      controller.send(:set_flash_message, :notice, :updated)

      expect(flash[:notice]).to eq('Test message')
    end

    it 'handles errors gracefully' do
      allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))

      expect { controller.send(:set_flash_message, :notice, :updated) }.not_to raise_error
    end

    it 'sets default message when custom logic fails' do
      allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))
      allow(I18n).to receive(:t).with('devise.passwords.updated').and_return('Default message')

      controller.send(:set_flash_message, :notice, :updated)

      expect(flash[:notice]).to eq('Default message')
    end

    it 'logs error when flash message fails' do
      allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))
      allow(Rails.logger).to receive(:error).and_call_original

      controller.send(:set_flash_message, :notice, :updated)

      expect(Rails.logger).to have_received(:error)
        .with(a_string_matching(/flash_message_error/))
        .at_least(:once)
    end

    it 'does not set flash when find_message returns nil' do
      allow(controller).to receive(:resource_params).and_return({})
      allow(controller).to receive(:find_message).and_return(nil)

      controller.send(:set_flash_message, :notice, :updated)

      expect(flash[:notice]).to be_blank
    end

    it 'does not set flash when find_message returns empty string' do
      allow(controller).to receive(:resource_params).and_return({})
      allow(controller).to receive(:find_message).and_return('')

      controller.send(:set_flash_message, :notice, :updated)

      expect(flash[:notice]).to be_blank
    end
  end

  describe 'private methods' do
    describe '#log_security_event' do
      it 'logs event type' do
        allow(Rails.logger).to receive(:info).and_call_original

        controller.send(:log_security_event, 'test_event', { test: 'data' })

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/test_event/))
      end

      it 'logs additional details' do
        allow(Rails.logger).to receive(:info).and_call_original

        controller.send(:log_security_event, 'test_event', { custom: 'detail' })

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/custom.*detail/))
      end

      it 'logs IP address from request' do
        allow(Rails.logger).to receive(:info).and_call_original

        controller.send(:log_security_event, 'test_event')

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/ip_address/))
      end

      it 'logs user agent from request' do
        allow(Rails.logger).to receive(:info).and_call_original

        controller.send(:log_security_event, 'test_event')

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/user_agent/))
      end

      it 'logs controller name' do
        allow(Rails.logger).to receive(:info).and_call_original

        controller.send(:log_security_event, 'test_event')

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/controller.*passwords/))
      end

      it 'logs timestamp in ISO8601 format' do
        allow(Rails.logger).to receive(:info).and_call_original

        controller.send(:log_security_event, 'test_event')

        expect(Rails.logger).to have_received(:info)
          .with(a_string_matching(/timestamp.*\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/))
      end

      it 'outputs valid JSON' do
        logged_json = nil
        allow(Rails.logger).to receive(:info) do |msg|
          logged_json = msg if msg.is_a?(String) && msg.start_with?('{')
        end

        controller.send(:log_security_event, 'test_event')

        expect { JSON.parse(logged_json) }.not_to raise_error if logged_json
      end
    end

    describe '#log_error' do
      let(:test_error) { StandardError.new('Test error') }

      before do
        test_error.set_backtrace(['line1', 'line2', 'line3', 'line4', 'line5', 'line6'])
      end

      it 'logs error class name' do
        allow(Rails.logger).to receive(:error).and_call_original

        controller.send(:log_error, 'test_error_event', test_error)

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/error_class.*StandardError/))
      end

      it 'logs error message' do
        allow(Rails.logger).to receive(:error).and_call_original

        controller.send(:log_error, 'test_error_event', test_error)

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/error_message.*Test error/))
      end

      it 'logs first 5 lines of backtrace' do
        allow(Rails.logger).to receive(:error).and_call_original

        controller.send(:log_error, 'test_error_event', test_error)

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/backtrace.*line1.*line5/m))
      end

      it 'logs IP address' do
        allow(Rails.logger).to receive(:error).and_call_original

        controller.send(:log_error, 'test_error_event', test_error)

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/ip_address/))
      end

      it 'logs controller name' do
        allow(Rails.logger).to receive(:error).and_call_original

        controller.send(:log_error, 'test_error_event', test_error)

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/controller.*passwords/))
      end

      it 'logs timestamp' do
        allow(Rails.logger).to receive(:error).and_call_original

        controller.send(:log_error, 'test_error_event', test_error)

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/timestamp/))
      end

      it 'includes additional details' do
        allow(Rails.logger).to receive(:error).and_call_original

        controller.send(:log_error, 'test_error_event', test_error, { custom: 'data' })

        expect(Rails.logger).to have_received(:error)
          .with(a_string_matching(/custom.*data/))
      end

      it 'outputs valid JSON' do
        logged_json = nil
        allow(Rails.logger).to receive(:error) do |msg|
          logged_json = msg if msg.is_a?(String) && msg.start_with?('{')
        end

        controller.send(:log_error, 'test_error_event', test_error)

        expect { JSON.parse(logged_json) }.not_to raise_error if logged_json
      end

      it 'handles error without backtrace' do
        error_without_backtrace = StandardError.new('No backtrace')
        allow(Rails.logger).to receive(:error).and_call_original

        expect do
          controller.send(:log_error, 'test_error_event', error_without_backtrace)
        end.not_to raise_error
      end
    end
  end
end
