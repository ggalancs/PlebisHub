# frozen_string_literal: true

# PasswordsController - Password Reset Functionality
#
# SECURITY FIXES IMPLEMENTED:
# - Added frozen_string_literal for performance
# - Added comprehensive error handling
# - Added security logging for password reset events
# - Enhanced legacy password clearing logic
# - Added documentation
#
# This controller extends Devise::PasswordsController to customize
# password reset behavior and handle legacy password clearing.
class PasswordsController < Devise::PasswordsController
  # Override set_flash_message to include resource params
  def set_flash_message(key, kind, options = {})
    options.merge! resource_params.deep_symbolize_keys
    message = find_message(kind, options)
    flash[key] = message if message.present?
  rescue StandardError => e
    log_error('flash_message_error', e)
    # Set default message if custom logic fails
    flash[key] = I18n.t("devise.passwords.#{kind}") if flash[key].blank?
  end

  # Override create to log password reset requests
  def create
    log_security_event('password_reset_requested', email: params.dig(:user, :email))
    super
  end

  # Override Devise PasswordsController update action
  # If user has a legacy password, clear the flag when they reset via email
  #
  # This ensures users who reset their password via "Forgot your password?"
  # won't be prompted for legacy password on next login.
  #
  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    # Check if password was successfully reset
    if resource.errors.exclude?(:password) && resource.errors.exclude?(:password_confirmation)
      # Clear legacy password flag if user had one
      if resource.has_legacy_password?
        # Rails 7.2: Use update_column instead of deprecated update_attribute
        resource.update_column(:has_legacy_password, false)
        log_security_event('legacy_password_cleared', user_id: resource.id)
      end

      # Unlock account if it was locked
      resource.unlock_access! if unlockable?(resource)

      # Set appropriate flash message
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?

      # Sign in user and redirect
      sign_in(resource_name, resource)
      log_security_event('password_reset_success', user_id: resource.id, email: resource.email)
      redirect_to after_resetting_password_path_for(resource)
    else
      # Password reset failed - respond with errors
      log_security_event('password_reset_failed',
                         errors: resource.errors.full_messages,
                         token_present: params.dig(:user, :reset_password_token).present?)
      respond_with resource
    end
  rescue StandardError => e
    log_error('password_reset_error', e)
    # Ensure we don't expose error details to user
    flash[:alert] = I18n.t('devise.passwords.updated_not_active')
    redirect_to new_user_session_path
  end

  private

  # SECURITY LOGGING: Log password reset events
  def log_security_event(event_type, details = {})
    Rails.logger.info({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: 'passwords',
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
      controller: 'passwords',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
