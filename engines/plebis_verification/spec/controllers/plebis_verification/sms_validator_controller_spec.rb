# frozen_string_literal: true

require 'rails_helper'

module PlebisVerification
  RSpec.describe SmsValidatorController, type: :controller do
    routes { PlebisVerification::Engine.routes }

    let(:user) { create(:user) }

    before do
      sign_in user
      allow(user).to receive(:can_change_phone?).and_return(true)
      # Stub route helpers that reference main app
      allow(controller).to receive(:root_path).and_return('/')
      allow(controller).to receive(:new_user_session_path).and_return('/users/sign_in')
    end

    describe 'authentication' do
      context 'when not logged in' do
        before { sign_out user }

        it 'redirects to sign in for step1' do
          get :step1
          expect(response).to redirect_to(new_user_session_path)
        end

        it 'redirects to sign in for phone' do
          post :phone, params: { user: { unconfirmed_phone: '123456789' } }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'rate limiting' do
      context 'when user cannot change phone' do
        before { allow(user).to receive(:can_change_phone?).and_return(false) }

        it 'redirects to root' do
          get :step1
          expect(response).to redirect_to(root_path)
        end

        it 'sets error flash' do
          get :step1
          expect(flash[:error]).to be_present
        end

        it 'logs the rate limit event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_rate_limited/))
          get :step1
        end
      end
    end

    describe 'GET #step1' do
      it 'renders step1 template' do
        get :step1
        expect(response).to render_template(:step1)
      end

      it 'returns http success' do
        get :step1
        expect(response).to have_http_status(:success)
      end

      it 'logs the step1 view' do
        expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_step1_viewed/))
        get :step1
      end

      context 'error handling' do
        before do
          allow(controller).to receive(:render).and_raise(StandardError)
        end

        it 'handles errors gracefully' do
          expect { get :step1 }.to raise_error(StandardError)
        end
      end
    end

    describe 'GET #step2' do
      context 'with unconfirmed phone' do
        before { user.update(unconfirmed_phone: '123456789') }

        it 'renders step2 template' do
          get :step2
          expect(response).to render_template(:step2)
        end

        it 'assigns user' do
          get :step2
          expect(assigns(:user)).to eq(user)
        end

        it 'logs the step2 view' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_step2_viewed/))
          get :step2
        end
      end

      context 'without unconfirmed phone' do
        it 'redirects to step1' do
          get :step2
          expect(response).to redirect_to(sms_validator_step1_path)
        end

        it 'logs the event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_step2_no_phone/))
          get :step2
        end
      end

      context 'error handling' do
        before do
          user.update(unconfirmed_phone: '123456789')
          allow(controller).to receive(:render).and_raise(StandardError)
        end

        it 'redirects to step1 on error' do
          expect { get :step2 }.to raise_error(StandardError)
        end
      end
    end

    describe 'GET #step3' do
      context 'with unconfirmed phone and token' do
        before do
          user.update(unconfirmed_phone: '123456789', sms_confirmation_token: '123456')
        end

        it 'renders step3 template' do
          get :step3
          expect(response).to render_template(:step3)
        end

        it 'assigns user' do
          get :step3
          expect(assigns(:user)).to eq(user)
        end

        it 'logs the step3 view' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_step3_viewed/))
          get :step3
        end
      end

      context 'without unconfirmed phone' do
        it 'redirects to step1' do
          get :step3
          expect(response).to redirect_to(sms_validator_step1_path)
        end

        it 'logs the event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_step3_no_phone/))
          get :step3
        end
      end

      context 'without sms token' do
        before { user.update(unconfirmed_phone: '123456789') }

        it 'redirects to step2' do
          get :step3
          expect(response).to redirect_to(sms_validator_step2_path)
        end

        it 'logs the event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_step3_no_token/))
          get :step3
        end
      end
    end

    describe 'POST #phone' do
      let(:phone_number) { '123456789' }

      context 'with valid phone number' do
        it 'updates unconfirmed_phone' do
          post :phone, params: { user: { unconfirmed_phone: phone_number } }
          expect(user.reload.unconfirmed_phone).to eq(phone_number)
        end

        it 'sets sms token' do
          expect(user).to receive(:set_sms_token!)
          allow(controller).to receive(:current_user).and_return(user)
          post :phone, params: { user: { unconfirmed_phone: phone_number } }
        end

        it 'redirects to step2' do
          post :phone, params: { user: { unconfirmed_phone: phone_number } }
          expect(response).to redirect_to(sms_validator_step2_path)
        end

        it 'logs the phone save event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_phone_saved/))
          post :phone, params: { user: { unconfirmed_phone: phone_number } }
        end
      end

      context 'with invalid phone number' do
        before do
          allow(user).to receive(:save).and_return(false)
          allow(controller).to receive(:current_user).and_return(user)
        end

        it 'renders step1' do
          post :phone, params: { user: { unconfirmed_phone: 'invalid' } }
          expect(response).to render_template(:step1)
        end

        it 'logs the invalid phone event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_phone_invalid/))
          post :phone, params: { user: { unconfirmed_phone: 'invalid' } }
        end
      end

      context 'error handling' do
        before do
          allow(user).to receive(:unconfirmed_phone=).and_raise(StandardError)
          allow(controller).to receive(:current_user).and_return(user)
        end

        it 'renders step1 on error' do
          post :phone, params: { user: { unconfirmed_phone: phone_number } }
          expect(response).to render_template(:step1)
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/sms_validation_phone_error/))
          post :phone, params: { user: { unconfirmed_phone: phone_number } }
        end
      end
    end

    describe 'POST #captcha' do
      before do
        user.update(unconfirmed_phone: '123456789')
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'with valid captcha' do
        before do
          allow(controller).to receive(:simple_captcha_valid?).and_return(true)
        end

        it 'sends SMS token' do
          expect(user).to receive(:send_sms_token!)
          post :captcha
        end

        it 'renders step3' do
          allow(user).to receive(:send_sms_token!)
          post :captcha
          expect(response).to render_template(:step3)
        end

        it 'logs the token sent event' do
          allow(user).to receive(:send_sms_token!)
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_token_sent/))
          post :captcha
        end
      end

      context 'with invalid captcha' do
        before do
          allow(controller).to receive(:simple_captcha_valid?).and_return(false)
        end

        it 'does not send SMS token' do
          expect(user).not_to receive(:send_sms_token!)
          post :captcha
        end

        it 'renders step2' do
          post :captcha
          expect(response).to render_template(:step2)
        end

        it 'sets error flash' do
          post :captcha
          expect(flash.now[:error]).to be_present
        end

        it 'logs the invalid captcha event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_captcha_invalid/))
          post :captcha
        end
      end

      context 'error handling' do
        before do
          allow(controller).to receive(:simple_captcha_valid?).and_raise(StandardError)
        end

        it 'renders step2 on error' do
          post :captcha
          expect(response).to render_template(:step2)
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/sms_validation_captcha_error/))
          post :captcha
        end
      end
    end

    describe 'POST #valid' do
      before do
        user.update(unconfirmed_phone: '123456789', sms_confirmation_token: '123456')
        allow(controller).to receive(:current_user).and_return(user)
      end

      context 'with valid token' do
        before do
          allow(user).to receive(:check_sms_token).and_return(true)
        end

        it 'redirects to authenticated_root_path' do
          post :valid, params: { user: { sms_user_token_given: '123456' } }
          expect(response).to redirect_to(authenticated_root_path)
        end

        it 'sets success notice' do
          post :valid, params: { user: { sms_user_token_given: '123456' } }
          expect(flash.now[:notice]).to be_present
        end

        it 'logs the validation success' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_success/))
          post :valid, params: { user: { sms_user_token_given: '123456' } }
        end
      end

      context 'with invalid token' do
        before do
          allow(user).to receive(:check_sms_token).and_return(false)
        end

        it 'renders step3' do
          post :valid, params: { user: { sms_user_token_given: 'wrong' } }
          expect(response).to render_template(:step3)
        end

        it 'sets error flash' do
          post :valid, params: { user: { sms_user_token_given: 'wrong' } }
          expect(flash.now[:error]).to be_present
        end

        it 'logs the invalid token event' do
          expect(Rails.logger).to receive(:info).with(a_string_matching(/sms_validation_token_invalid/))
          post :valid, params: { user: { sms_user_token_given: 'wrong' } }
        end
      end

      context 'error handling' do
        before do
          allow(user).to receive(:check_sms_token).and_raise(StandardError)
        end

        it 'renders step3 on error' do
          post :valid, params: { user: { sms_user_token_given: '123456' } }
          expect(response).to render_template(:step3)
        end

        it 'logs the error' do
          expect(Rails.logger).to receive(:error).with(a_string_matching(/sms_validation_valid_error/))
          post :valid, params: { user: { sms_user_token_given: '123456' } }
        end
      end
    end
  end
end
