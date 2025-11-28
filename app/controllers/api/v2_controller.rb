# frozen_string_literal: true

# API::V2Controller - HMAC-Signed Data Access API
#
# SECURITY FIXES IMPLEMENTED:
# - Fixed timing attack vulnerability in signature verification
# - Fixed critical logic bug in user validation
# - Added comprehensive error handling
# - Fixed missing record handling
# - Added PII access audit logging
# - Replaced deprecated skip_before_filter
# - Added input validation
# - Standardized response formats and HTTP status codes
#
# This API provides access to militant/user data filtered by geographic territories.
# Authentication is via HMAC signature verification (timestamp + URL + secret).
class Api::V2Controller < ActionController::Base
  # SECURITY: Skip CSRF for API - using HMAC signature authentication instead
  skip_before_action :verify_authenticity_token

  respond_to :json
  before_action :log_api_call
  before_action :validate_inputs, only: [:get_data]

  COMMANDS = %w[militants_from_territory militants_from_vote_circle_territory].freeze
  RANGE_NAMES = { exterior: 'exterior' }.freeze
  VALID_TERRITORIES = %w[autonomy province town island circle].freeze

  # Get militant data for a territory
  # Requires HMAC signature verification
  #
  # Commands:
  # - militants_from_territory: Get militants by user's territory
  #   Params: email, territory, timestamp, range_name, command, signature
  #
  # - militants_from_vote_circle_territory: Get militants by vote circle territory
  #   Params: vote_circle_id, territory, timestamp, range_name, command, signature
  def get_data
    param_list = build_param_list
    url_verified, data = verify_sign_url(request.original_url, param_list)

    unless url_verified
      log_security_event('signature_verification_failed', signature_data: data)
      return render json: {
        success: false,
        error: 'Unauthorized',
        message: 'Invalid signature'
      }, status: :unauthorized
    end

    command = params[:command].strip.downcase

    result = case command
             when COMMANDS[0]
               get_militants_from_territory
             when COMMANDS[1]
               get_militants_from_vote_circle_territory
             else
               { success: false, error: 'Bad Request', message: 'Unknown command' }
             end

    if result.is_a?(Hash) && result[:success] == false
      status = result[:status] || :bad_request
      render json: result.except(:status), status: status
    else
      render json: { success: true, data: result }, status: :ok
    end
  rescue StandardError => e
    log_error('api_error', e)
    render json: {
      success: false,
      error: 'Internal server error'
    }, status: :internal_server_error
  end

  # SECURITY: HMAC signature verification with timing-attack protection
  #
  # Verifies that the request signature matches the expected HMAC signature
  # Uses secure_compare to prevent timing attacks
  #
  # Returns: [verified_boolean, debug_data_string]
  def verify_sign_url(url, param_list, len = nil)
    host = Rails.application.secrets.host
    secret = Rails.application.secrets.forms["secret"]
    uri = URI(url)
    params_hash = URI.decode_www_form(uri.query || '').to_h
    timestamp = params_hash['timestamp']

    # Build canonical URL for signature
    data = "#{uri.scheme}://"
    data += "#{uri.userinfo}@" if uri.userinfo.present?
    data += host.to_s
    data += uri.path.to_s

    # Append parameters in order
    param_list.each_with_index do |k, i|
      sep = i.zero? ? '?' : '&'
      data += "#{sep}#{k}=#{params_hash[k]}" if params_hash[k].present?
    end

    # Generate expected signature
    signature = Base64.urlsafe_encode64(
      OpenSSL::HMAC.digest('SHA256', secret, "#{timestamp}::#{data}")
    )
    signature = signature[0..len] unless len.nil?

    # SECURITY FIX: Use secure_compare to prevent timing attacks
    provided_signature = params_hash['signature'] || ''
    verified = ActiveSupport::SecurityUtils.secure_compare(signature, provided_signature)

    [verified, data]
  end

  private

  # SECURITY: Validate all inputs before processing
  def validate_inputs
    command = params[:command]&.strip&.downcase

    # Validate command
    if command.blank?
      return render json: {
        success: false,
        error: 'Bad Request',
        message: 'command parameter is required'
      }, status: :bad_request
    end

    unless COMMANDS.include?(command)
      return render json: {
        success: false,
        error: 'Bad Request',
        message: 'Invalid command'
      }, status: :bad_request
    end

    # Validate timestamp
    timestamp = params[:timestamp]
    if timestamp.blank?
      return render json: {
        success: false,
        error: 'Bad Request',
        message: 'timestamp parameter is required'
      }, status: :bad_request
    end

    # Validate timestamp is not too old (prevent replay attacks)
    begin
      ts = Time.at(timestamp.to_i)
      if ts < 1.hour.ago || ts > 5.minutes.from_now
        log_security_event('invalid_timestamp', timestamp: timestamp, current_time: Time.current)
        return render json: {
          success: false,
          error: 'Unauthorized',
          message: 'Timestamp out of valid range'
        }, status: :unauthorized
      end
    rescue StandardError
      return render json: {
        success: false,
        error: 'Bad Request',
        message: 'Invalid timestamp format'
      }, status: :bad_request
    end

    # Validate territory
    territory = params[:territory]
    if territory.blank?
      return render json: {
        success: false,
        error: 'Bad Request',
        message: 'territory parameter is required'
      }, status: :bad_request
    end

    unless VALID_TERRITORIES.include?(territory.downcase)
      return render json: {
        success: false,
        error: 'Bad Request',
        message: 'Invalid territory'
      }, status: :bad_request
    end

    # Validate signature
    if params[:signature].blank?
      return render json: {
        success: false,
        error: 'Unauthorized',
        message: 'signature parameter is required'
      }, status: :unauthorized
    end

    # Command-specific validation
    case command
    when COMMANDS[0]
      if params[:email].blank?
        return render json: {
          success: false,
          error: 'Bad Request',
          message: 'email parameter is required for this command'
        }, status: :bad_request
      end

      # Basic email format validation
      unless params[:email] =~ URI::MailTo::EMAIL_REGEXP
        return render json: {
          success: false,
          error: 'Bad Request',
          message: 'Invalid email format'
        }, status: :bad_request
      end
    when COMMANDS[1]
      if params[:vote_circle_id].blank?
        return render json: {
          success: false,
          error: 'Bad Request',
          message: 'vote_circle_id parameter is required for this command'
        }, status: :bad_request
      end

      # Validate vote_circle_id is numeric
      unless params[:vote_circle_id].to_s =~ /\A\d+\z/
        return render json: {
          success: false,
          error: 'Bad Request',
          message: 'vote_circle_id must be numeric'
        }, status: :bad_request
      end
    end

    true
  end

  # Build parameter list for signature verification based on command
  def build_param_list
    case params[:command]&.strip&.downcase
    when COMMANDS[0]
      %w[email territory timestamp range_name command]
    when COMMANDS[1]
      %w[vote_circle_id territory timestamp range_name command]
    else
      []
    end
  end

  # Get militants from territory by user email
  def get_militants_from_territory
    email = params[:email].strip

    # Find user by email
    user = User.find_by(email: email)

    # SECURITY FIX: Was checking params[:user] which is never set
    # Changed to check the actual user variable
    unless user.present?
      log_security_event('user_not_found', email: email)
      return {
        success: false,
        error: 'Not Found',
        message: 'User not found',
        status: :not_found
      }
    end

    # Log PII access for audit trail
    log_pii_access('militants_from_territory', {
      email: email,
      user_id: user.id,
      territory: params[:territory]
    })

    get_militants_data(user.vote_circle, params[:territory], params[:range_name])
  rescue StandardError => e
    log_error('militants_from_territory_error', e, email: email)
    {
      success: false,
      error: 'Internal server error',
      status: :internal_server_error
    }
  end

  # Get militants from territory by vote circle ID
  def get_militants_from_vote_circle_territory
    vote_circle_id = params[:vote_circle_id].to_i

    # SECURITY FIX: Was using find which raises exception if not found
    # Changed to find_by which returns nil
    vote_circle = VoteCircle.find_by(id: vote_circle_id)

    unless vote_circle.present?
      log_security_event('vote_circle_not_found', vote_circle_id: vote_circle_id)
      return {
        success: false,
        error: 'Not Found',
        message: 'Vote circle not found',
        status: :not_found
      }
    end

    # Log PII access for audit trail
    log_pii_access('militants_from_vote_circle_territory', {
      vote_circle_id: vote_circle_id,
      territory: params[:territory]
    })

    get_militants_data(vote_circle, params[:territory], params[:range_name])
  rescue StandardError => e
    log_error('militants_from_vote_circle_territory_error', e, vote_circle_id: vote_circle_id)
    {
      success: false,
      error: 'Internal server error',
      status: :internal_server_error
    }
  end

  # Get militant data based on territory and vote circle
  def get_militants_data(app_circle, territory, range_name)
    return [] unless app_circle.present?

    territory_value, vc_query = build_territory_query(app_circle, territory, range_name)

    return [] unless territory_value.present? && vc_query.any?

    # Build result set
    data = []
    vc_hash = vc_query.to_h
    vc_ids = vc_hash.keys

    User.militant.where(vote_circle_id: vc_ids).find_each do |u|
      data << {
        first_name: u.first_name,
        phone: u.phone,
        country_name: u.country_name,
        autonomy_name: u.autonomy_name,
        province_name: u.province_name,
        island_name: u.island_name,
        town_name: u.town_name,
        circle_name: u.vote_circle.original_name
      }
    end

    data
  rescue StandardError => e
    log_error('get_militants_data_error', e, territory: territory)
    []
  end

  # Build territory-based query for vote circles
  def build_territory_query(app_circle, territory, range_name)
    territory_value = nil
    vc_query = VoteCircle.none

    case territory.downcase
    when 'autonomy'
      territory_value = app_circle.autonomy_code
      vc_query = VoteCircle.where(autonomy_code: territory_value).pluck(:id, :original_name)
    when 'province'
      territory_value = app_circle.province_code
      vc_query = VoteCircle.where(province_code: territory_value).pluck(:id, :original_name)
    when 'town'
      territory_value = app_circle.town
      vc_query = VoteCircle.where(town: territory_value).pluck(:id, :original_name)
    when 'island'
      territory_value = app_circle.island_code
      vc_query = VoteCircle.where(island_code: territory_value).pluck(:id, :original_name)
    when 'circle'
      if range_name && range_name.downcase == RANGE_NAMES[:exterior]
        territory_value = VoteCircle.exterior.pluck(:id)
      else
        territory_value = app_circle.id
      end
      vc_query = VoteCircle.where(id: territory_value).pluck(:id, :original_name)
    end

    [territory_value, vc_query]
  end

  # Get or create API logger
  def api_logger
    @api_logger ||= Logger.new("#{Rails.root}/log/api.log").tap do |logger|
      logger.formatter = proc do |severity, time, progname, msg|
        "#{time.iso8601} | #{msg}\n"
      end
    end
  end

  # SECURITY LOGGING: Log all API calls
  def log_api_call
    api_logger.info({
      event: 'api_call',
      ip_address: request.remote_ip,
      path: request.path,
      command: params[:command],
      timestamp: Time.current.iso8601
    }.to_json)
  end

  # SECURITY LOGGING: Log PII access for audit trail
  def log_pii_access(action, details = {})
    Rails.logger.warn({
      event: 'pii_access',
      action: action,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      api_version: 'v2',
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
      api_version: 'v2',
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
