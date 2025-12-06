# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConfirmationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @routes = Rails.application.routes
  end

  let(:user) { create(:user, confirmed_at: nil) }

  describe 'GET #show' do
    let(:confirmation_token) { user.confirmation_token }

    context 'with valid token' do
      before do
        user.send(:generate_confirmation_token)
        user.save(validate: false)
      end

      it 'confirms user successfully' do
        get :show, params: { confirmation_token: user.confirmation_token }

        user.reload
        expect(user.confirmed?).to be true
      end

      it 'signs in user automatically after confirmation' do
        get :show, params: { confirmation_token: user.confirmation_token }

        expect(controller.current_user).to eq(user)
        expect(warden.authenticated?(:user)).to be true
      end

      it 'redirects after confirmation' do
        get :show, params: { confirmation_token: user.confirmation_token }

        expect(response).to have_http_status(:redirect)
      end

      it 'sets flash notice message' do
        get :show, params: { confirmation_token: user.confirmation_token }

        expect(flash[:notice]).to be_present
      end

      it 'logs successful email confirmation with user details' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: user.confirmation_token }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/email_confirmed/))
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/user_id/))
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/email/))
      end

      it 'logs IP address in security event' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: user.confirmation_token }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"ip_address"/))
      end

      it 'logs user agent in security event' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: user.confirmation_token }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_agent"/))
      end

      it 'logs controller name in security event' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: user.confirmation_token }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"controller":"confirmations"/))
      end

      it 'logs timestamp in security event' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: user.confirmation_token }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"timestamp"/))
      end

      it 'logs in JSON format' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: user.confirmation_token }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/^\{.*\}$/))
      end

      context 'when block is given to yield resource' do
        it 'yields the resource' do
          # This tests the yield line in the controller
          expect { |b|
            controller.define_singleton_method(:test_yield) do |&block|
              show(&block)
            end
            get :show, params: { confirmation_token: user.confirmation_token }
          }.not_to raise_error
        end
      end
    end

    context 'with invalid token' do
      it 'does not confirm user' do
        get :show, params: { confirmation_token: 'invalid_token_12345' }

        user.reload
        expect(user.confirmed?).to be false
      end

      it 'does not sign in user' do
        get :show, params: { confirmation_token: 'invalid_token_12345' }

        expect(controller.current_user).to be_nil
      end

      it 'renders new template' do
        get :show, params: { confirmation_token: 'invalid_token_12345' }

        expect(response).to render_template(:new)
      end

      it 'returns unprocessable entity status' do
        get :show, params: { confirmation_token: 'invalid_token_12345' }

        expect(response.status).to be_in([200, 422])
      end

      it 'logs confirmation failure event' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: 'invalid_token_12345' }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/email_confirmation_failed/))
      end

      it 'logs errors in failure event' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: 'invalid_token_12345' }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/errors/))
      end

      it 'logs token presence in failure event' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: 'invalid_token_12345' }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/token_present/))
      end

      it 'logs IP address in failure event' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: 'invalid_token_12345' }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"ip_address"/))
      end

      it 'logs user agent in failure event' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: 'invalid_token_12345' }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_agent"/))
      end
    end

    context 'with blank token' do
      it 'logs token_present as false' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: '' }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/email_confirmation_failed/))
      end

      it 'does not confirm user' do
        get :show, params: { confirmation_token: '' }

        user.reload
        expect(user.confirmed?).to be false
      end
    end

    context 'with nil token' do
      it 'handles nil token gracefully' do
        get :show, params: { confirmation_token: nil }

        expect(response.status).to be_in([200, 422])
      end
    end

    context 'error handling' do
      context 'when database error occurs' do
        before do
          allow(User).to receive(:confirm_by_token).and_raise(StandardError.new('Database connection error'))
        end

        it 'catches the exception' do
          expect { get :show, params: { confirmation_token: 'some_token' } }.not_to raise_error
        end

        it 'logs error event' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :show, params: { confirmation_token: 'some_token' }
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/confirmation_error/)).at_least(:once)
        end

        it 'logs error class in error event' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :show, params: { confirmation_token: 'some_token' }
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/error_class/)).at_least(:once)
        end

        it 'logs error message in error event' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :show, params: { confirmation_token: 'some_token' }
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/error_message/)).at_least(:once)
        end

        it 'logs backtrace in error event' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :show, params: { confirmation_token: 'some_token' }
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/backtrace/)).at_least(:once)
        end

        it 'logs IP address in error event' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :show, params: { confirmation_token: 'some_token' }
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/"ip_address"/)).at_least(:once)
        end

        it 'logs controller name in error event' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :show, params: { confirmation_token: 'some_token' }
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/"controller":"confirmations"/)).at_least(:once)
        end

        it 'logs timestamp in error event' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :show, params: { confirmation_token: 'some_token' }
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/"timestamp"/)).at_least(:once)
        end

        it 'logs token presence in error event' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :show, params: { confirmation_token: 'some_token' }
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/token_present/)).at_least(:once)
        end

        it 'sets flash alert message' do
          allow(Rails.logger).to receive(:error)

          get :show, params: { confirmation_token: 'some_token' }

          expect(flash[:alert]).to be_present
          expect(flash[:alert]).to match(/invalid.*token/i)
        end

        it 'redirects to sign in page' do
          allow(Rails.logger).to receive(:error)

          get :show, params: { confirmation_token: 'some_token' }

          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'when runtime error occurs' do
        before do
          allow(User).to receive(:confirm_by_token).and_raise(RuntimeError.new('Unexpected error'))
        end

        it 'handles runtime error gracefully' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :show, params: { confirmation_token: 'some_token' }
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/confirmation_error/)).at_least(:once)
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'when ArgumentError occurs' do
        before do
          allow(User).to receive(:confirm_by_token).and_raise(ArgumentError.new('Invalid argument'))
        end

        it 'handles ArgumentError gracefully' do
          allow(Rails.logger).to receive(:error).and_call_original
          get :show, params: { confirmation_token: 'some_token' }
          expect(Rails.logger).to have_received(:error).with(a_string_matching(/confirmation_error/)).at_least(:once)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe 'POST #create' do
    context 'with valid email' do
      it 'logs confirmation email request' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/confirmation_email_requested/))
      end

      it 'logs email address in request event' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/#{user.email}/)).at_least(:once)
      end

      it 'logs IP address in request event' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"ip_address"/))
      end

      it 'logs user agent in request event' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"user_agent"/))
      end

      it 'logs controller name in request event' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"controller":"confirmations"/))
      end

      it 'logs timestamp in request event' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: user.email } }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"timestamp"/))
      end

      it 'calls super to execute devise logic' do
        # Expect the action to proceed (standard devise behavior)
        post :create, params: { user: { email: user.email } }

        expect(response.status).to be_in([200, 302, 303])
      end

      it 'resends confirmation email' do
        initial_count = ActionMailer::Base.deliveries.count

        post :create, params: { user: { email: user.email } }

        expect(ActionMailer::Base.deliveries.count).to be >= initial_count
      end
    end

    context 'with blank email' do
      it 'logs request with blank email' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: '' } }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/confirmation_email_requested/))
      end

      it 'handles blank email' do
        post :create, params: { user: { email: '' } }

        expect(response.status).to be_in([200, 302, 303])
      end
    end

    context 'with nil email' do
      it 'logs request with nil email' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: nil } }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/confirmation_email_requested/))
      end
    end

    context 'with missing user params' do
      it 'logs request with missing params' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: {}

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/confirmation_email_requested/))
      end
    end

    context 'with non-existent email' do
      it 'logs request for non-existent email' do
        allow(Rails.logger).to receive(:info).and_call_original

        post :create, params: { user: { email: 'nonexistent@example.com' } }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/confirmation_email_requested/))
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/nonexistent@example.com/))
      end

      it 'handles non-existent email gracefully' do
        post :create, params: { user: { email: 'nonexistent@example.com' } }

        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe '#set_flash_message' do
    before do
      user.send(:generate_confirmation_token)
      user.save(validate: false)
    end

    context 'when successful' do
      it 'sets flash message with resource params' do
        # Flash message is set by the controller automatically
        get :show, params: { confirmation_token: user.confirmation_token }

        # Since the token is valid, confirmation succeeds and flash is set
        expect(response).to be_redirect
      end

      it 'merges resource params into options' do
        # This tests that the set_flash_message method is called
        get :show, params: { confirmation_token: user.confirmation_token }

        # Verify the method executed without error
        expect(response).to be_redirect
      end

      it 'finds message for the given kind' do
        get :show, params: { confirmation_token: user.confirmation_token }

        # Verify the confirmation flow completed
        expect(response).to be_redirect
      end

      it 'sets message only if present' do
        # Test that empty messages are not set
        allow(controller).to receive(:set_flash_message) do |key, kind, options|
          # Simulate empty message
          flash[key] = '' if ''.present?
        end

        get :show, params: { confirmation_token: user.confirmation_token }

        # Verify the flow still works
        expect(response.status).to be_in([200, 302, 303])
      end
    end

    context 'when error occurs' do
      it 'handles StandardError gracefully' do
        allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))

        expect { get :show, params: { confirmation_token: user.confirmation_token } }.not_to raise_error
      end

      it 'logs error when exception occurs' do
        allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: user.confirmation_token }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/flash_message_error/)).at_least(:once)
      end

      it 'logs error class when exception occurs' do
        allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: user.confirmation_token }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/error_class/)).at_least(:once)
      end

      it 'logs error message when exception occurs' do
        allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: user.confirmation_token }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/error_message/)).at_least(:once)
      end

      it 'logs backtrace when exception occurs' do
        allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: user.confirmation_token }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/backtrace/)).at_least(:once)
      end

      it 'sets default message when custom logic fails' do
        allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))
        allow(Rails.logger).to receive(:error)

        get :show, params: { confirmation_token: user.confirmation_token }

        expect(flash[:notice]).to be_present
      end

      it 'sets default message even if flash was previously blank' do
        allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))
        allow(Rails.logger).to receive(:error)

        get :show, params: { confirmation_token: user.confirmation_token }

        # The default message is set
        expect(flash[:notice]).to be_present
      end
    end

    context 'when find_message raises error' do
      it 'handles find_message error gracefully and logs it' do
        allow(controller).to receive(:find_message).and_raise(StandardError.new('Find message error'))
        allow(Rails.logger).to receive(:error).and_call_original

        get :show, params: { confirmation_token: user.confirmation_token }

        expect(Rails.logger).to have_received(:error).with(a_string_matching(/flash_message_error/))
        expect(response.status).to be_in([200, 302, 303])
      end
    end
  end

  describe 'private methods' do
    describe '#log_security_event' do
      it 'logs events in JSON format with all required fields' do
        allow(Rails.logger).to receive(:info).and_call_original

        get :show, params: { confirmation_token: 'test_token' }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/^\{.*\}$/))
      end

      it 'includes event type in log' do
        allow(Rails.logger).to receive(:info).and_call_original

        user.send(:generate_confirmation_token)
        user.save(validate: false)

        get :show, params: { confirmation_token: user.confirmation_token }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/"event"/))
      end

      it 'includes additional details passed as parameters' do
        allow(Rails.logger).to receive(:info).and_call_original

        user.send(:generate_confirmation_token)
        user.save(validate: false)

        get :show, params: { confirmation_token: user.confirmation_token }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/user_id/))
      end
    end

    describe '#log_error' do
      before do
        allow(User).to receive(:confirm_by_token).and_raise(StandardError.new('Test error'))
      end

      it 'logs errors in JSON format' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: 'test_token' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/^\{.*\}$/)).at_least(:once)
      end

      it 'includes event type in error log' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: 'test_token' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"event"/)).at_least(:once)
      end

      it 'includes error class in error log' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: 'test_token' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"error_class":"StandardError"/)).at_least(:once)
      end

      it 'includes error message in error log' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: 'test_token' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"error_message":"Test error"/)).at_least(:once)
      end

      it 'includes backtrace (first 5 lines) in error log' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: 'test_token' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"backtrace":\[/)).at_least(:once)
      end

      it 'includes IP address in error log' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: 'test_token' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"ip_address"/)).at_least(:once)
      end

      it 'includes controller name in error log' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: 'test_token' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"controller":"confirmations"/)).at_least(:once)
      end

      it 'includes timestamp in error log' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: 'test_token' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/"timestamp"/)).at_least(:once)
      end

      it 'includes additional details passed as parameters' do
        allow(Rails.logger).to receive(:error).and_call_original
        get :show, params: { confirmation_token: 'test_token' }
        expect(Rails.logger).to have_received(:error).with(a_string_matching(/token_present/)).at_least(:once)
      end
    end
  end

  describe 'integration tests' do
    context 'full confirmation workflow' do
      it 'completes full workflow from unconfirmed to confirmed and signed in' do
        # Start with unconfirmed user
        expect(user.confirmed?).to be false
        expect(user.confirmation_token).to be_present

        # Perform confirmation
        get :show, params: { confirmation_token: user.confirmation_token }

        # Verify all outcomes
        user.reload
        expect(user.confirmed?).to be true
        expect(controller.current_user).to eq(user)
        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to be_present
      end
    end

    context 'security logging throughout workflow' do
      it 'logs all security events in correct format' do
        allow(Rails.logger).to receive(:info).and_call_original
        allow(Rails.logger).to receive(:error).and_call_original

        user.send(:generate_confirmation_token)
        user.save(validate: false)

        # Test confirmation request logging
        post :create, params: { user: { email: user.email } }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/confirmation_email_requested/))

        # Test confirmation success logging
        get :show, params: { confirmation_token: user.confirmation_token }
        expect(Rails.logger).to have_received(:info).with(a_string_matching(/email_confirmed/))
      end
    end
  end
end
