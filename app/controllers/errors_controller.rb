# frozen_string_literal: true

# ErrorsController - Custom Error Pages
#
# SECURITY FIXES IMPLEMENTED:
# - Added frozen_string_literal
# - Added comprehensive error handling
# - Added security logging
# - Whitelist for error codes (already implemented)
# - Added documentation
#
# This controller renders custom error pages for HTTP errors.
# It prevents security issues like symbol table pollution and
# I18n key injection by validating error codes against a whitelist.
class ErrorsController < ApplicationController
  # Override locale detection to extract from path for catch-all routes
  before_action :set_locale_from_path

  # Whitelist of allowed HTTP error codes
  ALLOWED_ERROR_CODES = {
    # 4xx Client Errors
    '400' => :bad_request,
    '401' => :unauthorized,
    '403' => :forbidden,
    '404' => :not_found,
    '405' => :method_not_allowed,
    '406' => :not_acceptable,
    '408' => :request_timeout,
    '409' => :conflict,
    '410' => :gone,
    '422' => :unprocessable_entity,
    '429' => :too_many_requests,

    # 5xx Server Errors
    '500' => :internal_server_error,
    '501' => :not_implemented,
    '502' => :bad_gateway,
    '503' => :service_unavailable,
    '504' => :gateway_timeout
  }.freeze

  # Display custom error page
  def show
    # SECURITY: Validate and sanitize code parameter
    raw_code = params[:code].presence || '500'
    @code = sanitize_error_code(raw_code)

    log_security_event('error_page_displayed',
                       code: @code,
                       raw_code: raw_code,
                       user_id: current_user&.id)

    render status: http_status_code
  rescue StandardError => e
    log_error('error_page_render_error', e,
              code: params[:code])
    render plain: 'Internal Server Error', status: :internal_server_error
  end

  private

  # Sanitize error code against whitelist
  def sanitize_error_code(code)
    code_str = code.to_s

    # If code is in whitelist, use it; otherwise default to 500
    if ALLOWED_ERROR_CODES.key?(code_str)
      code_str
    else
      log_security_event('invalid_error_code_attempt',
                         attempted_code: code_str)
      '500'
    end
  end

  # Convert code to HTTP status code integer
  def http_status_code
    @code.to_i
  end

  # SECURITY LOGGING
  def log_security_event(event_type, details = {})
    Rails.logger.info({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: 'errors',
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
      controller: 'errors',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end

  # Extract locale from request path for catch-all routes
  # This handles cases where params[:locale] is not set (e.g., /es/nonexistent)
  def set_locale_from_path
    # Try to extract locale from the beginning of the path
    path_locale = request.path.match(%r{^/(es|ca|eu)(/|$)})&.captures&.first
    I18n.locale = path_locale || params[:locale] || :es
  rescue StandardError
    I18n.locale = :es
  end
end
