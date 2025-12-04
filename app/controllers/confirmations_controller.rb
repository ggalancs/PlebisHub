# frozen_string_literal: true

# ConfirmationsController - Email Confirmation Functionality
#
# SECURITY FIXES IMPLEMENTED:
# - Added frozen_string_literal for performance
# - Added comprehensive error handling
# - Added security logging for confirmation events
# - Enhanced error responses
# - Added documentation
#
# This controller extends Devise::ConfirmationsController to customize
# email confirmation behavior and automatically sign in users after confirmation.
class ConfirmationsController < Devise::ConfirmationsController
  # Override show action to confirm user and automatically sign them in
  #
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      # Confirmation successful
      set_flash_message(:notice, :confirmed) if is_flashing_format?

      # Automatically sign in the user
      sign_in(resource)

      log_security_event('email_confirmed',
                         user_id: resource.id,
                         email: resource.email)

      respond_with_navigational(resource) do
        redirect_to after_confirmation_path_for(resource_name, resource)
      end
    else
      # Confirmation failed
      log_security_event('email_confirmation_failed',
                         errors: resource.errors.full_messages,
                         token_present: params[:confirmation_token].present?)

      respond_with_navigational(resource.errors, status: :unprocessable_entity) do
        render :new
      end
    end
  rescue StandardError => e
    log_error('confirmation_error', e,
              token_present: params[:confirmation_token].present?)

    # Show user-friendly error
    flash[:alert] = I18n.t('devise.confirmations.invalid_token')
    redirect_to new_user_session_path
  end

  # Override set_flash_message to include resource params
  def set_flash_message(key, kind, options = {})
    options.merge! resource_params.deep_symbolize_keys
    message = find_message(kind, options)
    flash[key] = message if message.present?
  rescue StandardError => e
    log_error('flash_message_error', e)
    # Set default message if custom logic fails
    flash[key] = I18n.t("devise.confirmations.#{kind}") if flash[key].blank?
  end

  # Override create to log confirmation email requests
  def create
    log_security_event('confirmation_email_requested',
                       email: params.dig(:user, :email))
    super
  end

  private

  # SECURITY LOGGING: Log confirmation events
  def log_security_event(event_type, details = {})
    Rails.logger.info({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: 'confirmations',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end

  # ERROR LOGGING: Log errors with context
  def log_error(event_type, exception, details = {})
    Rails.logger.error({
      event: event_type,
      error_class: exception.class.name,
      error_message: exception.message,
      backtrace: exception.backtrace&.first(5),
      ip_address: request.remote_ip,
      controller: 'confirmations',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
