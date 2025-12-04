# frozen_string_literal: true

# LegacyPasswordController - Legacy Password Migration
#
# SECURITY FIXES IMPLEMENTED:
# - Added frozen_string_literal for performance
# - Added comprehensive error handling
# - Added security logging for legacy password changes
# - Enhanced authorization checks
# - Added input validation
# - Added documentation
#
# This controller handles migration from legacy passwords to new password format.
# Users with legacy passwords are required to update their password before
# accessing the application.
class LegacyPasswordController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_has_legacy_password, only: %i[new update]

  # GET /users/legacy_password/new
  # Show form for updating legacy password
  def new
    log_security_event('legacy_password_form_viewed', user_id: current_user.id)
  end

  # PATCH/PUT /users/legacy_password
  # Update user password and clear legacy flag
  def update
    if current_user.update(change_pass_params)
      # Password updated successfully
      # Rails 7.2: Use update_column instead of deprecated update_attribute
      current_user.update_column(:has_legacy_password, false)

      log_security_event('legacy_password_updated',
                         user_id: current_user.id,
                         email: current_user.email)

      # Re-authenticate user with new password
      # Devise: Use bypass_sign_in instead of deprecated bypass option
      bypass_sign_in(current_user)

      redirect_to root_path, notice: t('plebisbrand.legacy.password.changed')
    else
      # Password update failed
      log_security_event('legacy_password_update_failed',
                         user_id: current_user.id,
                         errors: current_user.errors.full_messages)

      render action: 'new'
    end
  rescue StandardError => e
    log_error('legacy_password_update_error', e, user_id: current_user&.id)

    flash[:alert] = t('plebisbrand.legacy.password.error')
    render action: 'new'
  end

  private

  # Verify user has legacy password before allowing access
  def verify_has_legacy_password
    return if current_user.has_legacy_password?

    log_security_event('legacy_password_unauthorized_access',
                       user_id: current_user.id,
                       has_legacy_password: false)
    redirect_to root_path
  end

  # Strong parameters for password change
  def change_pass_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # SECURITY LOGGING: Log legacy password events
  def log_security_event(event_type, details = {})
    Rails.logger.info({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: 'legacy_password',
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
      controller: 'legacy_password',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
