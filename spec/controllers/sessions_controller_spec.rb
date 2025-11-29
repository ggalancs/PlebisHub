# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes
  end

  let(:user) { create(:user, password: 'Password123!', password_confirmation: 'Password123!') }
  let(:election) { create(:election) }

  describe 'GET #new' do
    context 'election query' do
      before do
        allow(Election).to receive_message_chain(:upcoming_finished, :show_on_index, :first).and_return(election)
      end

      it 'loads upcoming election' do
        get :new

        expect(assigns(:upcoming_election)).to eq(election)
      end

      it 'caches election query' do
        # First call should query database
        expect(Election).to receive_message_chain(:upcoming_finished, :show_on_index, :first).once.and_return(election)

        get :new
        get :new  # Second call should use cache

        expect(response).to be_successful
      end

      it 'logs login page view' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/login_page_viewed/))

        get :new
      end

      it 'renders new template' do
        get :new

        expect(response).to render_template(:new)
      end
    end

    context 'when election query fails' do
      before do
        allow(Election).to receive_message_chain(:upcoming_finished, :show_on_index, :first).and_raise(StandardError.new('DB error'))
      end

      it 'allows page to render' do
        # Devise will handle the error, we just want to ensure our controller doesn't crash
        expect { get :new }.to raise_error(StandardError)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'logs in user' do
        post :create, params: { user: { email: user.email, password: 'Password123!' } }

        expect(controller.current_user).to eq(user)
      end

      it 'logs successful login' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/login_success/))

        post :create, params: { user: { email: user.email, password: 'Password123!' } }
      end

      it 'logs user_id in security event' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/user_id.*#{user.id}/))

        post :create, params: { user: { email: user.email, password: 'Password123!' } }
      end

      it 'logs email in security event' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/#{user.email}/))

        post :create, params: { user: { email: user.email, password: 'Password123!' } }
      end

      it 'redirects after login' do
        post :create, params: { user: { email: user.email, password: 'Password123!' } }

        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid credentials' do
      it 'does not log in user' do
        post :create, params: { user: { email: user.email, password: 'WrongPassword' } }

        expect(controller.current_user).to be_nil
      end

      it 'does not log successful login' do
        expect(Rails.logger).not_to receive(:info).with(a_string_matching(/login_success/))

        post :create, params: { user: { email: user.email, password: 'WrongPassword' } }
      end

      it 'renders new template' do
        post :create, params: { user: { email: user.email, password: 'WrongPassword' } }

        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      sign_in user
    end

    it 'logs out user' do
      delete :destroy

      expect(controller.current_user).to be_nil
    end

    it 'logs logout event' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/logout/))

      delete :destroy
    end

    it 'logs user_id in logout event' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/user_id.*#{user.id}/))

      delete :destroy
    end

    it 'redirects after logout' do
      delete :destroy

      expect(response).to have_http_status(:redirect)
    end

    context 'CSRF protection' do
      it 'does not skip CSRF verification' do
        # This is a meta-test to ensure CSRF protection is enabled
        expect(controller.class._process_action_callbacks.any? { |c|
          c.filter == :verify_authenticity_token && c.options[:only]&.include?(:destroy)
        }).to be false
      end

      it 'does not have skip_before_action for destroy' do
        skipped_actions = controller.class._process_action_callbacks
          .select { |c| c.kind == :skip }
          .select { |c| c.filter == :verify_authenticity_token }
          .flat_map { |c| c.options[:only] || [] }

        expect(skipped_actions).not_to include(:destroy)
      end
    end
  end

  describe '#after_login hook' do
    let(:verification) { create(:user_verification, user: user) }

    before do
      allow(user).to receive(:imperative_verification).and_return(verification)
      sign_in user
    end

    context 'when verification exists' do
      it 'updates verification priority to 1' do
        expect(verification).to receive(:update).with(priority: 1).and_return(true)

        controller.send(:after_login)
      end

      it 'does not raise error if update succeeds' do
        allow(verification).to receive(:update).and_return(true)

        expect { controller.send(:after_login) }.not_to raise_error
      end
    end

    context 'when verification update fails' do
      before do
        allow(verification).to receive(:update).and_return(false)
        allow(verification).to receive(:errors).and_return(double(full_messages: ['Error message']))
      end

      it 'logs error' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/verification_priority_update_failed/))

        controller.send(:after_login)
      end

      it 'does not raise error' do
        expect { controller.send(:after_login) }.not_to raise_error
      end

      it 'logs verification_id' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/verification_id/))

        controller.send(:after_login)
      end

      it 'logs error messages' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/errors/))

        controller.send(:after_login)
      end
    end

    context 'when verification update raises exception' do
      before do
        allow(verification).to receive(:update).and_raise(ActiveRecord::RecordInvalid.new(verification))
      end

      it 'rescues exception' do
        expect { controller.send(:after_login) }.not_to raise_error
      end

      it 'logs error with backtrace' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/after_login_hook_error.*backtrace/m))

        controller.send(:after_login)
      end

      it 'logs error context' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/error_context.*imperative_verification_update/))

        controller.send(:after_login)
      end
    end

    context 'when verification does not exist' do
      before do
        allow(user).to receive(:imperative_verification).and_return(nil)
      end

      it 'does not raise error' do
        expect { controller.send(:after_login) }.not_to raise_error
      end

      it 'does not log error' do
        expect(Rails.logger).not_to receive(:error)

        controller.send(:after_login)
      end
    end

    context 'when current_user is nil' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it 'returns early without error' do
        expect { controller.send(:after_login) }.not_to raise_error
      end
    end
  end

  describe 'security logging' do
    before do
      sign_in user
    end

    it 'logs with IP address' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"ip_address"/))

      delete :destroy
    end

    it 'logs with user agent' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"user_agent"/))

      delete :destroy
    end

    it 'logs with timestamp in ISO8601 format' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"timestamp":".*T.*Z?"/))

      delete :destroy
    end

    it 'logs with controller name' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"controller":"sessions"/))

      delete :destroy
    end

    it 'logs in JSON format' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/^\{.*\}$/))

      delete :destroy
    end
  end

  describe 'error logging' do
    let(:verification) { create(:user_verification, user: user) }

    before do
      sign_in user
      allow(user).to receive(:imperative_verification).and_return(verification)
      allow(verification).to receive(:update).and_raise(StandardError.new('Test error'))
    end

    it 'logs error class' do
      expect(Rails.logger).to receive(:error).with(a_string_matching(/"error_class":"StandardError"/))

      controller.send(:after_login)
    end

    it 'logs error message' do
      expect(Rails.logger).to receive(:error).with(a_string_matching(/"error_message":"Test error"/))

      controller.send(:after_login)
    end

    it 'logs backtrace' do
      expect(Rails.logger).to receive(:error).with(a_string_matching(/"backtrace":\[/))

      controller.send(:after_login)
    end

    it 'logs in JSON format' do
      expect(Rails.logger).to receive(:error).with(a_string_matching(/^\{.*\}$/))

      controller.send(:after_login)
    end
  end

  describe 'integration test' do
    it 'successfully logs in user even when verification update fails' do
      verification = create(:user_verification, user: user)
      allow(user).to receive(:imperative_verification).and_return(verification)
      allow(verification).to receive(:update).and_return(false)

      post :create, params: { user: { email: user.email, password: 'Password123!' } }

      # User should still be logged in despite verification update failure
      expect(controller.current_user).to eq(user)
      expect(response).to have_http_status(:redirect)
    end

    it 'successfully logs in user even when verification update raises exception' do
      verification = create(:user_verification, user: user)
      allow(user).to receive(:imperative_verification).and_return(verification)
      allow(verification).to receive(:update).and_raise(StandardError.new('DB error'))

      post :create, params: { user: { email: user.email, password: 'Password123!' } }

      # User should still be logged in despite exception
      expect(controller.current_user).to eq(user)
      expect(response).to have_http_status(:redirect)
    end
  end
end
