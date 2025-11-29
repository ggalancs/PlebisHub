# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConfirmationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes
  end

  let(:user) { create(:user, confirmed_at: nil) }

  describe 'GET #show' do
    let(:confirmation_token) { user.confirmation_token }

    context 'with valid token' do
      before do
        # Set confirmation token
        user.send(:generate_confirmation_token)
        user.save(validate: false)
      end

      it 'confirms user' do
        get :show, params: { confirmation_token: user.confirmation_token }

        user.reload
        expect(user.confirmed?).to be true
      end

      it 'logs email confirmation' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/email_confirmed/))

        get :show, params: { confirmation_token: user.confirmation_token }
      end

      it 'signs in user automatically' do
        get :show, params: { confirmation_token: user.confirmation_token }

        expect(controller.current_user).to eq(user)
      end

      it 'redirects after confirmation' do
        get :show, params: { confirmation_token: user.confirmation_token }

        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid token' do
      it 'does not confirm user' do
        get :show, params: { confirmation_token: 'invalid_token' }

        user.reload
        expect(user.confirmed?).to be false
      end

      it 'logs confirmation failure' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/email_confirmation_failed/))

        get :show, params: { confirmation_token: 'invalid_token' }
      end

      it 'renders errors' do
        get :show, params: { confirmation_token: 'invalid_token' }

        expect(response).to render_template(:new)
      end
    end

    context 'error handling' do
      before do
        allow(User).to receive(:confirm_by_token).and_raise(StandardError.new('DB error'))
      end

      it 'handles errors gracefully' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/confirmation_error/))

        get :show, params: { confirmation_token: 'some_token' }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST #create' do
    it 'logs confirmation email request' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/confirmation_email_requested/))

      post :create, params: { user: { email: user.email } }
    end

    it 'resends confirmation email' do
      post :create, params: { user: { email: user.email } }

      expect(response).to have_http_status(:redirect)
    end
  end

  describe '#set_flash_message' do
    it 'handles errors gracefully' do
      allow(controller).to receive(:find_message).and_raise(StandardError.new('I18n error'))

      expect { controller.send(:set_flash_message, :notice, :confirmed) }.not_to raise_error
    end
  end

  describe 'security logging' do
    before do
      user.send(:generate_confirmation_token)
      user.save(validate: false)
    end

    it 'logs with IP address' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"ip_address"/))

      get :show, params: { confirmation_token: user.confirmation_token }
    end

    it 'logs with user agent' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/"user_agent"/))

      get :show, params: { confirmation_token: user.confirmation_token }
    end

    it 'logs in JSON format' do
      expect(Rails.logger).to receive(:info).with(a_string_matching(/^\{.*\}$/))

      get :show, params: { confirmation_token: user.confirmation_token }
    end
  end
end
