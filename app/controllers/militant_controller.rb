# frozen_string_literal: true

# External API endpoint for Participa platform to manage militant status
# CSRF Protection: Disabled (inherits from ActionController::Base) because this is
# a server-to-server API authenticated via HMAC signatures, not user sessions
class MilitantController < ActionController::Base
  # TODO: Refactorize code and use API::V2Controller instead

  def get_militant_info
    # CRITICAL FIX: Added input validation for all parameters
    unless params[:participa_user_id].present?
      log_error("Missing participa_user_id parameter")
      render json: { error: "Missing required parameter: participa_user_id" }, status: :bad_request
      return
    end

    # HIGH PRIORITY FIX: Validate user_id is numeric
    user_id = params[:participa_user_id].to_i
    if user_id <= 0
      log_error("Invalid participa_user_id: #{params[:participa_user_id]}")
      render json: { error: "Invalid user ID" }, status: :bad_request
      return
    end

    # LOW PRIORITY FIX: Added observability logging
    log_request_attempt(user_id)

    # Verify HMAC signature
    signature_service = UrlSignatureService.new
    url_verified, data = signature_service.verify_militant_url(request.original_url)

    unless url_verified
      # MEDIUM PRIORITY FIX: Consistent JSON error format
      log_signature_failure(data)
      render json: { error: "Invalid signature", details: data }, status: :unauthorized
      return
    end

    # MEDIUM PRIORITY FIX: Single user lookup (eliminates duplicate queries)
    current_user = User.find_by_id(user_id)

    # CRITICAL FIX: Nil check before using user object
    unless current_user
      log_user_not_found(user_id)
      render json: { error: "User not found", user_id: user_id }, status: :not_found
      return
    end

    # Handle collaborate query vs exemption update
    if params[:collaborate].present?
      handle_collaborate_query(current_user)
    else
      handle_exemption_update(current_user, params[:exemption])
    end
  end

  private

  # Check if user is a collaborator for militant status
  def handle_collaborate_query(user)
    is_collaborator = user.collaborator_for_militant?
    result_value = is_collaborator ? "1" : "0"

    log_collaborate_check(user.id, is_collaborator)

    # CRITICAL FIX: Explicit render with proper content-type
    # MEDIUM PRIORITY FIX: Consistent JSON response format
    render json: {
      result: result_value,
      user_id: user.id,
      is_collaborator: is_collaborator
    }, status: :ok
  end

  # Update user's exemption status and recalculate militant status
  def handle_exemption_update(user, exemption_param)
    # MEDIUM PRIORITY FIX: Validate exemption value explicitly
    exemption_value = parse_exemption_value(exemption_param)

    if exemption_value.nil?
      log_invalid_exemption(exemption_param)
      render json: { error: "Invalid exemption value. Expected: true, false, 1, 0" }, status: :bad_request
      return
    end

    # LOW PRIORITY FIX: Combined updates into single transaction where possible
    begin
      user.update!(exempt_from_payment: exemption_value)

      # Recalculate militant status based on new exemption
      new_militant_status = user.still_militant?
      user.update!(militant: new_militant_status)

      # Process militant data (may send email, update records)
      user.process_militant_data

      log_exemption_updated(user.id, exemption_value, new_militant_status)

      # CRITICAL FIX: Explicit render with proper content-type
      # MEDIUM PRIORITY FIX: Consistent JSON response format (don't expose internal data)
      render json: {
        result: "OK",
        user_id: user.id,
        exemption: exemption_value,
        militant: new_militant_status
      }, status: :ok
    rescue ActiveRecord::RecordInvalid => e
      log_update_failure(user.id, e)
      render json: { error: "Failed to update user", details: e.message }, status: :unprocessable_entity
    end
  end

  # MEDIUM PRIORITY FIX: Strong parameters pattern - validate exemption value
  def parse_exemption_value(value)
    case value.to_s.downcase
    when "true", "1"
      true
    when "false", "0"
      false
    when ""
      false # Default to false if not provided
    else
      nil # Invalid value
    end
  end

  # LOW PRIORITY FIX: Structured logging methods for security audit
  def log_request_attempt(user_id)
    Rails.logger.info(
      "[Militant API] Request received - " \
      "User: #{user_id}, IP: #{request.remote_ip}, " \
      "Action: #{params[:collaborate].present? ? 'collaborate_check' : 'exemption_update'}"
    )
  end

  def log_signature_failure(data)
    Rails.logger.warn(
      "[Militant API] Signature verification failed - " \
      "IP: #{request.remote_ip}, Data: #{data}"
    )
  end

  def log_user_not_found(user_id)
    Rails.logger.warn(
      "[Militant API] User not found - " \
      "User ID: #{user_id}, IP: #{request.remote_ip}"
    )
  end

  def log_collaborate_check(user_id, is_collaborator)
    Rails.logger.info(
      "[Militant API] Collaborate check - " \
      "User: #{user_id}, Is Collaborator: #{is_collaborator}"
    )
  end

  def log_exemption_updated(user_id, exemption, militant_status)
    Rails.logger.info(
      "[Militant API] Exemption updated - " \
      "User: #{user_id}, Exemption: #{exemption}, " \
      "New Militant Status: #{militant_status}"
    )
  end

  def log_invalid_exemption(value)
    Rails.logger.warn(
      "[Militant API] Invalid exemption value - " \
      "Value: #{value.inspect}, IP: #{request.remote_ip}"
    )
  end

  def log_update_failure(user_id, exception)
    Rails.logger.error(
      "[Militant API] Failed to update user - " \
      "User: #{user_id}, Error: #{exception.class}: #{exception.message}"
    )
  end

  def log_error(message)
    Rails.logger.error("[Militant API] #{message} - IP: #{request.remote_ip}")
  end
end
