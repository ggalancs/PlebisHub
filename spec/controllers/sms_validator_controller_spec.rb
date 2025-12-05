# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SmsValidatorController, type: :controller do
  let(:user) { create(:user, :with_dni) }

  before do
    allow(controller).to receive(:unresolved_issues).and_return(nil)
  end

  describe 'authentication and authorization' do
    it 'requires user to be logged in for step1' do
      get :step1
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'requires user to be logged in for step2' do
      get :step2
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'requires user to be logged in for step3' do
      get :step3
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'requires user to be logged in for phone' do
      post :phone, params: { user: { unconfirmed_phone: '123456789' } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'requires user to be logged in for captcha' do
      post :captcha
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'requires user to be logged in for valid' do
      post :valid, params: { user: { sms_user_token_given: '123456' } }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe '#can_change_phone' do
    context 'when user can change phone' do
      before do
        sign_in user
        allow(user).to receive(:can_change_phone?).and_return(true)
      end

      it 'allows access to step1' do
        get :step1
        expect(response).to have_http_status(:success)
      end
    end

    context 'when user cannot change phone (rate limited)' do
      before do
        sign_in user
        allow(user).to receive(:can_change_phone?).and_return(false)
      end

      it 'redirects to root with error message' do
        get :step1
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to be_present
      end

      it 'logs security event' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_rate_limited')
          expect(log_data['user_id']).to eq(user.id)
        end
        get :step1
      end
    end
  end

  describe 'GET #step1' do
    before { sign_in user }

    it 'renders step1 template' do
      get :step1
      expect(response).to render_template(:step1)
    end

    it 'logs security event' do
      expect(Rails.logger).to receive(:info) do |log_msg|
        log_data = JSON.parse(log_msg)
        expect(log_data['event']).to eq('sms_validation_step1_viewed')
        expect(log_data['user_id']).to eq(user.id)
      end
      get :step1
    end

    context 'when error occurs' do
      before do
        allow(controller).to receive(:log_security_event).and_raise(StandardError, 'Test error')
      end

      it 'rescues error and redirects to root' do
        get :step1
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be_present
      end

      it 'logs error' do
        expect(Rails.logger).to receive(:error)
        get :step1
      end
    end
  end

  describe 'GET #step2' do
    before { sign_in user }

    context 'when user has unconfirmed_phone' do
      before do
        user.update(unconfirmed_phone: '123456789')
      end

      it 'renders step2 template' do
        get :step2
        expect(response).to render_template(:step2)
      end

      it 'assigns @user' do
        get :step2
        expect(assigns(:user)).to eq(user)
      end

      it 'logs security event' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_step2_viewed')
          expect(log_data['user_id']).to eq(user.id)
        end
        get :step2
      end
    end

    context 'when user has no unconfirmed_phone' do
      before do
        user.update(unconfirmed_phone: nil)
      end

      it 'redirects to step1' do
        get :step2
        expect(response).to redirect_to(sms_validator_step1_path)
      end

      it 'logs security event' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_step2_no_phone')
          expect(log_data['user_id']).to eq(user.id)
        end
        get :step2
      end
    end

    context 'when error occurs' do
      before do
        user.update(unconfirmed_phone: '123456789')
        allow(controller).to receive(:log_security_event).and_raise(StandardError, 'Test error')
      end

      it 'rescues error and redirects to step1' do
        get :step2
        expect(response).to redirect_to(sms_validator_step1_path)
        expect(flash[:alert]).to be_present
      end

      it 'logs error' do
        expect(Rails.logger).to receive(:error)
        get :step2
      end
    end
  end

  describe 'GET #step3' do
    before { sign_in user }

    context 'when user has no unconfirmed_phone' do
      before do
        user.update(unconfirmed_phone: nil)
      end

      it 'redirects to step1' do
        get :step3
        expect(response).to redirect_to(sms_validator_step1_path)
      end

      it 'logs security event' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_step3_no_phone')
          expect(log_data['user_id']).to eq(user.id)
        end
        get :step3
      end
    end

    context 'when user has unconfirmed_phone but no sms_confirmation_token' do
      before do
        user.update(unconfirmed_phone: '123456789', sms_confirmation_token: nil)
      end

      it 'redirects to step2' do
        get :step3
        expect(response).to redirect_to(sms_validator_step2_path)
      end

      it 'logs security event' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_step3_no_token')
          expect(log_data['user_id']).to eq(user.id)
        end
        get :step3
      end
    end

    context 'when user has both unconfirmed_phone and sms_confirmation_token' do
      before do
        user.update(unconfirmed_phone: '123456789', sms_confirmation_token: 'token123')
      end

      it 'renders step3 template' do
        get :step3
        expect(response).to render_template(:step3)
      end

      it 'assigns @user' do
        get :step3
        expect(assigns(:user)).to eq(user)
      end

      it 'logs security event' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_step3_viewed')
          expect(log_data['user_id']).to eq(user.id)
        end
        get :step3
      end
    end

    context 'when error occurs' do
      before do
        user.update(unconfirmed_phone: '123456789', sms_confirmation_token: 'token123')
        allow(controller).to receive(:log_security_event).and_raise(StandardError, 'Test error')
      end

      it 'rescues error and redirects to step2' do
        get :step3
        expect(response).to redirect_to(sms_validator_step2_path)
        expect(flash[:alert]).to be_present
      end

      it 'logs error' do
        expect(Rails.logger).to receive(:error)
        get :step3
      end
    end
  end

  describe 'POST #phone' do
    before { sign_in user }

    context 'with valid phone number' do
      it 'updates unconfirmed_phone' do
        post :phone, params: { user: { unconfirmed_phone: '987654321' } }
        expect(user.reload.unconfirmed_phone).to eq('987654321')
      end

      it 'sets SMS token' do
        expect(user).to receive(:set_sms_token!)
        post :phone, params: { user: { unconfirmed_phone: '987654321' } }
      end

      it 'redirects to step2' do
        post :phone, params: { user: { unconfirmed_phone: '987654321' } }
        expect(response).to redirect_to(sms_validator_step2_path)
      end

      it 'logs security event' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_phone_saved')
          expect(log_data['user_id']).to eq(user.id)
          expect(log_data['phone']).to eq('987654321')
        end
        post :phone, params: { user: { unconfirmed_phone: '987654321' } }
      end
    end

    context 'with invalid phone number' do
      before do
        allow_any_instance_of(User).to receive(:save).and_return(false)
        allow_any_instance_of(User).to receive(:errors).and_return(
          double(full_messages: ['Phone is invalid'])
        )
      end

      it 'renders step1 template' do
        post :phone, params: { user: { unconfirmed_phone: 'invalid' } }
        expect(response).to render_template(:step1)
      end

      it 'logs security event with errors' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_phone_invalid')
          expect(log_data['user_id']).to eq(user.id)
          expect(log_data['errors']).to eq(['Phone is invalid'])
        end
        post :phone, params: { user: { unconfirmed_phone: 'invalid' } }
      end
    end

    context 'when error occurs' do
      before do
        allow(controller).to receive(:log_security_event).and_raise(StandardError, 'Test error')
      end

      it 'rescues error and renders step1' do
        post :phone, params: { user: { unconfirmed_phone: '987654321' } }
        expect(response).to render_template(:step1)
        expect(flash[:alert]).to be_present
      end

      it 'logs error' do
        expect(Rails.logger).to receive(:error)
        post :phone, params: { user: { unconfirmed_phone: '987654321' } }
      end
    end
  end

  describe 'POST #captcha' do
    before do
      sign_in user
      user.update(unconfirmed_phone: '123456789')
    end

    context 'with valid captcha' do
      before do
        allow(controller).to receive(:simple_captcha_valid?).and_return(true)
      end

      it 'sends SMS token' do
        expect(user).to receive(:send_sms_token!)
        post :captcha
      end

      it 'renders step3 template' do
        post :captcha
        expect(response).to render_template(:step3)
      end

      it 'logs security event' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_token_sent')
          expect(log_data['user_id']).to eq(user.id)
          expect(log_data['phone']).to eq('123456789')
        end
        post :captcha
      end
    end

    context 'with invalid captcha' do
      before do
        allow(controller).to receive(:simple_captcha_valid?).and_return(false)
      end

      it 'renders step2 template' do
        post :captcha
        expect(response).to render_template(:step2)
      end

      it 'sets error flash message' do
        post :captcha
        expect(flash.now[:error]).to be_present
      end

      it 'logs security event' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_captcha_invalid')
          expect(log_data['user_id']).to eq(user.id)
        end
        post :captcha
      end
    end

    context 'when error occurs' do
      before do
        allow(controller).to receive(:simple_captcha_valid?).and_raise(StandardError, 'Test error')
      end

      it 'rescues error and renders step2' do
        post :captcha
        expect(response).to render_template(:step2)
        expect(flash[:alert]).to be_present
      end

      it 'logs error' do
        expect(Rails.logger).to receive(:error)
        post :captcha
      end
    end
  end

  describe 'POST #valid' do
    before do
      sign_in user
      user.update(unconfirmed_phone: '123456789', sms_confirmation_token: 'token123')
    end

    context 'with valid SMS token' do
      before do
        allow(user).to receive(:check_sms_token).and_return(true)
      end

      it 'redirects to authenticated_root_path' do
        post :valid, params: { user: { sms_user_token_given: '123456' } }
        expect(response).to redirect_to(authenticated_root_path)
      end

      it 'sets success flash message' do
        post :valid, params: { user: { sms_user_token_given: '123456' } }
        expect(flash.now[:notice]).to be_present
      end

      it 'calls check_sms_token with provided token' do
        expect(user).to receive(:check_sms_token).with('123456')
        post :valid, params: { user: { sms_user_token_given: '123456' } }
      end

      it 'logs security event' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_success')
          expect(log_data['user_id']).to eq(user.id)
          expect(log_data['phone']).to eq('123456789')
        end
        post :valid, params: { user: { sms_user_token_given: '123456' } }
      end
    end

    context 'with invalid SMS token' do
      before do
        allow(user).to receive(:check_sms_token).and_return(false)
        user.update(sms_confirmation_attempts: 2)
      end

      it 'renders step3 template' do
        post :valid, params: { user: { sms_user_token_given: 'wrong' } }
        expect(response).to render_template(:step3)
      end

      it 'sets error flash message' do
        post :valid, params: { user: { sms_user_token_given: 'wrong' } }
        expect(flash.now[:error]).to be_present
      end

      it 'logs security event with attempts' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_token_invalid')
          expect(log_data['user_id']).to eq(user.id)
          expect(log_data['attempts']).to eq(2)
        end
        post :valid, params: { user: { sms_user_token_given: 'wrong' } }
      end
    end

    context 'when error occurs' do
      before do
        allow(user).to receive(:check_sms_token).and_raise(StandardError, 'Test error')
      end

      it 'rescues error and renders step3' do
        post :valid, params: { user: { sms_user_token_given: '123456' } }
        expect(response).to render_template(:step3)
        expect(flash[:alert]).to be_present
      end

      it 'logs error' do
        expect(Rails.logger).to receive(:error)
        post :valid, params: { user: { sms_user_token_given: '123456' } }
      end
    end
  end

  describe 'private methods' do
    before { sign_in user }

    describe '#phone_params' do
      it 'permits unconfirmed_phone' do
        post :phone, params: { user: { unconfirmed_phone: '123456789', other_field: 'hacker' } }
        expect(user.reload.unconfirmed_phone).to eq('123456789')
      end
    end

    describe '#sms_token_params' do
      before do
        user.update(unconfirmed_phone: '123456789', sms_confirmation_token: 'token123')
        allow(user).to receive(:check_sms_token).and_return(true)
      end

      it 'permits sms_user_token_given' do
        post :valid, params: { user: { sms_user_token_given: '123456', other_field: 'hacker' } }
        expect(response).to redirect_to(authenticated_root_path)
      end
    end

    describe '#log_security_event' do
      it 'logs event with IP address and user agent' do
        expect(Rails.logger).to receive(:info) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_step1_viewed')
          expect(log_data['ip_address']).to be_present
          expect(log_data['user_agent']).to be_present
          expect(log_data['controller']).to eq('sms_validator')
          expect(log_data['timestamp']).to be_present
        end
        get :step1
      end
    end

    describe '#log_error' do
      before do
        allow(controller).to receive(:log_security_event).and_raise(StandardError, 'Test error')
      end

      it 'logs error with exception details' do
        expect(Rails.logger).to receive(:error) do |log_msg|
          log_data = JSON.parse(log_msg)
          expect(log_data['event']).to eq('sms_validation_step1_error')
          expect(log_data['error_class']).to eq('StandardError')
          expect(log_data['error_message']).to eq('Test error')
          expect(log_data['backtrace']).to be_present
          expect(log_data['ip_address']).to be_present
          expect(log_data['controller']).to eq('sms_validator')
          expect(log_data['timestamp']).to be_present
        end
        get :step1
      end
    end
  end
end
