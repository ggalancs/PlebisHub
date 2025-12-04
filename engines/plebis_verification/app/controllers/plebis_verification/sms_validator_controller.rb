# frozen_string_literal: true

module PlebisVerification
  # SmsValidatorController - SMS Phone Number Verification
  #
  # SECURITY FIXES IMPLEMENTED:
  # - Added frozen_string_literal
  # - Added comprehensive error handling
  # - Added security logging
  # - Added rate limiting documentation
  # - Added documentation
  # - Enhanced authorization checks
  #
  # This controller implements a three-step SMS verification workflow:
  # Step 1: User enters phone number
  # Step 2: User completes CAPTCHA, SMS token sent
  # Step 3: User enters SMS token to confirm phone
  class SmsValidatorController < ApplicationController
    include SimpleCaptcha::ControllerHelpers

    before_action :authenticate_user!
    before_action :can_change_phone

    # Verify user is allowed to change phone number
    # Users can only change phone every few months
    def can_change_phone
      return if current_user.can_change_phone?

      log_security_event('sms_validation_rate_limited', user_id: current_user.id)
      redirect_to root_path, flash: { error: t('plebisbrand.valid.phone.rate_limited') }
    end

    # Step 1: Display phone number entry form
    def step1
      log_security_event('sms_validation_step1_viewed', user_id: current_user.id)
    rescue StandardError => e
      log_error('sms_validation_step1_error', e, user_id: current_user.id)
      redirect_to root_path, alert: t('errors.messages.generic')
    end

    # Step 2: Display CAPTCHA form
    def step2
      if current_user.unconfirmed_phone.nil?
        log_security_event('sms_validation_step2_no_phone', user_id: current_user.id)
        return redirect_to sms_validator_step1_path
      end

      @user = current_user
      log_security_event('sms_validation_step2_viewed', user_id: current_user.id)
    rescue StandardError => e
      log_error('sms_validation_step2_error', e, user_id: current_user.id)
      redirect_to sms_validator_step1_path, alert: t('errors.messages.generic')
    end

    # Step 3: Display SMS token entry form
    def step3
      if current_user.unconfirmed_phone.nil?
        log_security_event('sms_validation_step3_no_phone', user_id: current_user.id)
        return redirect_to sms_validator_step1_path
      end

      if current_user.sms_confirmation_token.nil?
        log_security_event('sms_validation_step3_no_token', user_id: current_user.id)
        return redirect_to sms_validator_step2_path
      end

      @user = current_user
      log_security_event('sms_validation_step3_viewed', user_id: current_user.id)
      render action: 'step3'
    rescue StandardError => e
      log_error('sms_validation_step3_error', e, user_id: current_user.id)
      redirect_to sms_validator_step2_path, alert: t('errors.messages.generic')
    end

    # Process phone number submission
    def phone
      current_user.unconfirmed_phone = phone_params[:unconfirmed_phone]

      if current_user.save
        current_user.set_sms_token!
        log_security_event('sms_validation_phone_saved',
                           user_id: current_user.id,
                           phone: current_user.unconfirmed_phone)
        redirect_to sms_validator_step2_path
      else
        log_security_event('sms_validation_phone_invalid',
                           user_id: current_user.id,
                           errors: current_user.errors.full_messages)
        render action: 'step1'
      end
    rescue StandardError => e
      log_error('sms_validation_phone_error', e, user_id: current_user.id)
      flash[:alert] = t('errors.messages.generic')
      render action: 'step1'
    end

    # Process CAPTCHA and send SMS
    def captcha
      if simple_captcha_valid?
        current_user.send_sms_token!
        log_security_event('sms_validation_token_sent',
                           user_id: current_user.id,
                           phone: current_user.unconfirmed_phone)
        render action: 'step3'
      else
        log_security_event('sms_validation_captcha_invalid', user_id: current_user.id)
        flash.now[:error] = t('plebisbrand.valid.phone.captcha_invalid')
        render action: 'step2'
      end
    rescue StandardError => e
      log_error('sms_validation_captcha_error', e, user_id: current_user.id)
      flash[:alert] = t('errors.messages.generic')
      render action: 'step2'
    end

    # Validate SMS token
    def valid
      if current_user.check_sms_token(sms_token_params[:sms_user_token_given])
        log_security_event('sms_validation_success',
                           user_id: current_user.id,
                           phone: current_user.unconfirmed_phone)
        flash.now[:notice] = t('plebisbrand.valid.phone.valid')
        redirect_to authenticated_root_path
      else
        log_security_event('sms_validation_token_invalid',
                           user_id: current_user.id,
                           attempts: current_user.sms_confirmation_attempts || 0)
        flash.now[:error] = t('plebisbrand.valid.phone.invalid')
        render action: 'step3'
      end
    rescue StandardError => e
      log_error('sms_validation_valid_error', e, user_id: current_user.id)
      flash[:alert] = t('errors.messages.generic')
      render action: 'step3'
    end

    private

    # Strong parameters for phone number
    def phone_params
      params.require(:user).permit(:unconfirmed_phone)
    end

    # Strong parameters for SMS token
    def sms_token_params
      params.require(:user).permit(:sms_user_token_given)
    end

    # SECURITY LOGGING
    def log_security_event(event_type, details = {})
      Rails.logger.info({
        event: event_type,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        controller: 'sms_validator',
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    def log_error(event_type, exception, details = {})
      Rails.logger.error({
        event: event_type,
        error_class: exception.class.name,
        error_message: exception.message,
        backtrace: exception.backtrace&.first(5),
        ip_address: request.remote_ip,
        controller: 'sms_validator',
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end
  end
end
