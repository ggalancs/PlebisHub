# frozen_string_literal: true

# SessionsController - User Authentication (Login/Logout)
#
# SECURITY FIXES IMPLEMENTED:
# - Removed unnecessary CSRF skip on destroy (logout) for better security
# - Added comprehensive error handling in after_login hook
# - Added security logging for all authentication events
# - Added error recovery to ensure login succeeds even if verification update fails
# - Optimized election query with caching
#
# This controller extends Devise::SessionsController to customize
# the login flow and handle post-login verification priority updates.
class SessionsController < Devise::SessionsController
  after_action :after_login, only: :create

  # SECURITY NOTE: CSRF protection is enabled on all actions including destroy (logout)
  # If API/mobile clients need to logout without CSRF token, use a separate API endpoint
  # with token authentication instead of disabling CSRF protection.
  #
  # Previous code had: skip_before_action :verify_authenticity_token, only: [:destroy]
  # This was removed because:
  # 1. Enables CSRF forced logout attacks
  # 2. Can be used for session fixation preparation
  # 3. No valid use case for skipping CSRF on logout in web application
  # 4. Devise handles logout properly with CSRF protection

  # Override new action to load election data for login page
  # Caches election query to avoid database hit on every page load
  def new
    @upcoming_election = Rails.cache.fetch('upcoming_election_for_login', expires_in: 5.minutes) do
      Election.upcoming_finished.show_on_index.first
    end

    log_security_event('login_page_viewed')
    super
  end

  # Override create to log successful logins
  def create
    super do |resource|
      if resource.persisted?
        log_security_event('login_success', user_id: resource.id, email: resource.email)
      end
    end
  end

  # Override destroy to log logouts
  def destroy
    log_security_event('logout', user_id: current_user&.id) if current_user
    super
  end

  private

  # After successful login, update imperative verification priority
  #
  # This is called after user successfully authenticates but before redirect.
  # Updates the priority of any pending imperative verification to 1 (highest).
  #
  # SECURITY: Error handling ensures login succeeds even if verification update fails
  def after_login
    return unless current_user

    # Update verification priority if it exists
    verification = current_user.imperative_verification

    if verification
      unless verification.update(priority: 1)
        # Log error but don't fail login
        log_error('verification_priority_update_failed',
          StandardError.new('Update returned false'),
          user_id: current_user.id,
          verification_id: verification.id,
          errors: verification.errors.full_messages
        )
      end
    end
  rescue StandardError => e
    # CRITICAL: Rescue any errors to ensure login succeeds
    # Verification priority update is not critical enough to fail login
    log_error('after_login_hook_error', e,
      user_id: current_user&.id,
      error_context: 'imperative_verification_update'
    )
    # Don't re-raise - allow login to proceed
  end

  # SECURITY LOGGING: Log authentication events
  def log_security_event(event_type, details = {})
    Rails.logger.info({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: 'sessions',
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
      controller: 'sessions',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
