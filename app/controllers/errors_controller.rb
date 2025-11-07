class ErrorsController < ApplicationController
  # HIGH PRIORITY FIX: Whitelist of allowed HTTP error codes to prevent:
  # 1. Symbol table pollution (memory leak)
  # 2. I18n key injection attacks
  # 3. Invalid HTTP status code errors
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

  def show
    # HIGH PRIORITY FIX: Validate and sanitize code parameter
    raw_code = params[:code].presence || '500'
    @code = sanitize_error_code(raw_code)
    render status: http_status_code
  end

  private

  def sanitize_error_code(code)
    # Convert to string and check if it's in our whitelist
    code_str = code.to_s

    # If code is in whitelist, use it; otherwise default to 500
    ALLOWED_ERROR_CODES.key?(code_str) ? code_str : '500'
  end

  def http_status_code
    # Convert to integer (all whitelisted codes are numeric strings)
    @code.to_i
  end
end
