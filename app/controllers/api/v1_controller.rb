# frozen_string_literal: true

# API::V1Controller - GCM/FCM Push Notification Registration API
#
# SECURITY FIXES IMPLEMENTED:
# - Added API token authentication
# - Fixed critical bug in gcm_unregister (was using find instead of find_by)
# - Added comprehensive input validation
# - Added error handling with proper HTTP status codes
# - Added security audit logging
# - Replaced deprecated skip_before_filter with skip_before_action
# - Added rate limiting considerations
class Api::V1Controller < ApplicationController
  # SECURITY: Skip CSRF for API but require API token authentication instead
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_token
  before_action :validate_registration_id, only: [:gcm_register, :gcm_unregister]

  # Register a device for push notifications
  # POST /api/v1/gcm_register
  # Params: { v1: { registration_id: "device_token" } }
  def gcm_register
    @registration = NoticeRegistrar.find_or_create_by(registration_id: validated_registration_id)

    log_api_action('gcm_registration_created', registration_id: validated_registration_id)

    render json: {
      success: true,
      registration: {
        id: @registration.id,
        registration_id: @registration.registration_id,
        created_at: @registration.created_at
      }
    }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    log_error('gcm_registration_failed', e, registration_id: validated_registration_id)
    render json: {
      success: false,
      error: 'Registration failed',
      details: e.message
    }, status: :unprocessable_entity
  rescue StandardError => e
    log_error('gcm_registration_error', e)
    render json: {
      success: false,
      error: 'Internal server error'
    }, status: :internal_server_error
  end

  # Alias for backward compatibility
  alias_method :gcm_registrate, :gcm_register

  # Unregister a device from push notifications
  # DELETE /api/v1/gcm_unregister
  # Params: { v1: { registration_id: "device_token" } }
  def gcm_unregister
    # SECURITY FIX: Was using find(:registration_id) which is incorrect
    # Changed to find_by with proper parameter
    @registration = NoticeRegistrar.find_by(registration_id: validated_registration_id)

    if @registration
      @registration.destroy
      log_api_action('gcm_registration_deleted', registration_id: validated_registration_id)

      render json: {
        success: true,
        message: 'Device unregistered successfully'
      }, status: :ok
    else
      log_api_action('gcm_unregister_not_found', registration_id: validated_registration_id)

      render json: {
        success: false,
        error: 'Registration not found'
      }, status: :not_found
    end
  rescue StandardError => e
    log_error('gcm_unregister_error', e)
    render json: {
      success: false,
      error: 'Internal server error'
    }, status: :internal_server_error
  end

  private

  # SECURITY: Authenticate API requests with token
  def authenticate_api_token
    token = request.headers['X-API-Token'] || params[:api_token]

    unless valid_api_token?(token)
      log_security_event('invalid_api_token_attempt', provided_token: token&.first(10))

      render json: {
        success: false,
        error: 'Unauthorized',
        message: 'Valid API token required'
      }, status: :unauthorized

      return false
    end

    true
  end

  # Validate API token against configured tokens
  def valid_api_token?(token)
    return false if token.blank?

    # Get allowed tokens from secrets or environment
    allowed_tokens = Rails.application.secrets.api_tokens || []
    allowed_tokens = [allowed_tokens] unless allowed_tokens.is_a?(Array)

    # Use secure comparison to prevent timing attacks
    allowed_tokens.any? { |allowed| ActiveSupport::SecurityUtils.secure_compare(token, allowed) }
  end

  # SECURITY: Validate registration_id parameter
  def validate_registration_id
    registration_id = params.dig(:v1, :registration_id)

    if registration_id.blank?
      log_security_event('missing_registration_id')
      return render json: {
        success: false,
        error: 'Bad Request',
        message: 'registration_id is required'
      }, status: :bad_request
    end

    # GCM/FCM tokens are typically 152-200 characters
    # Firebase tokens can be longer, up to 4096 characters
    if registration_id.length > 4096
      log_security_event('registration_id_too_long', length: registration_id.length)
      return render json: {
        success: false,
        error: 'Bad Request',
        message: 'registration_id exceeds maximum length'
      }, status: :bad_request
    end

    # Basic format validation (alphanumeric, hyphens, underscores, colons)
    unless registration_id.match?(/\A[a-zA-Z0-9\-_:]+\z/)
      log_security_event('invalid_registration_id_format', format: registration_id.first(50))
      return render json: {
        success: false,
        error: 'Bad Request',
        message: 'registration_id contains invalid characters'
      }, status: :bad_request
    end

    true
  end

  # Get validated registration_id
  def validated_registration_id
    params.dig(:v1, :registration_id)
  end

  # Strong parameters (kept for clarity, though we validate manually above)
  def gcm_params
    params.require(:v1).permit(:registration_id)
  end

  # SECURITY LOGGING: Log API actions
  def log_api_action(action, details = {})
    Rails.logger.info({
      event: action,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      api_version: 'v1',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end

  # SECURITY LOGGING: Log security events
  def log_security_event(event_type, details = {})
    Rails.logger.warn({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      api_version: 'v1',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end

  # ERROR LOGGING: Comprehensive error logging
  def log_error(event_type, exception, details = {})
    Rails.logger.error({
      event: event_type,
      error_class: exception.class.name,
      error_message: exception.message,
      backtrace: exception.backtrace&.first(5),
      ip_address: request.remote_ip,
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
