# frozen_string_literal: true

# UserVerificationsController - Identity Verification System
#
# SECURITY FIXES IMPLEMENTED:
# - Added authentication for report actions (authenticate_admin_user!)
# - Added report_code validation with whitelist
# - Added comprehensive error handling with structured logging
# - Fixed flash message HTML safety
# - Added session[:return_to] validation (open redirect fix)
# - Extracted business logic to model
# - Added security audit logging
class UserVerificationsController < ApplicationController
  include Redirectable

  before_action :check_valid_and_verified, only: [:new, :create]
  before_action :authenticate_admin_user!, only: [:report, :report_town, :report_exterior]
  before_action :validate_report_code, only: [:report, :report_town, :report_exterior]

  def new
    @user_verification = UserVerification.for current_user
  rescue StandardError => e
    log_error("user_verification_new_failed", e)
    redirect_to root_path, flash: { alert: t('plebisbrand.errors.generic_error') }
  end

  def create
    @user_verification = UserVerification.for current_user, user_verification_params

    # Apply status determination logic (extracted to model)
    @user_verification.apply_initial_status!

    if @user_verification.save
      log_verification_created
      handle_successful_verification
    else
      render :new
    end
  rescue StandardError => e
    log_error("user_verification_create_failed", e, user_id: current_user&.id)
    redirect_to root_path, flash: { alert: t('plebisbrand.errors.generic_error') }
  end

  def report
    @report = UserVerificationReportService.new(params[:report_code]).generate
    log_report_access('province_report')
  rescue StandardError => e
    log_error("user_verification_report_failed", e, report_code: params[:report_code])
    redirect_to root_path, flash: { alert: t('plebisbrand.errors.report_generation_failed') }
  end

  def report_town
    @report_town = TownVerificationReportService.new(params[:report_code]).generate
    log_report_access('town_report')
  rescue StandardError => e
    log_error("town_verification_report_failed", e, report_code: params[:report_code])
    redirect_to root_path, flash: { alert: t('plebisbrand.errors.report_generation_failed') }
  end

  def report_exterior
    @report_exterior = ExteriorVerificationReportService.new(params[:report_code]).generate
    log_report_access('exterior_report')
  rescue StandardError => e
    log_error("exterior_verification_report_failed", e, report_code: params[:report_code])
    redirect_to root_path, flash: { alert: t('plebisbrand.errors.report_generation_failed') }
  end

  private

  def check_valid_and_verified
    if current_user.has_not_future_verified_elections?
      redirect_to safe_return_path, flash: { notice: t('plebisbrand.user_verification.user_not_valid_to_verify') }
    elsif current_user.verified? && current_user.photos_necessary?
      redirect_to safe_return_path, flash: { notice: t('plebisbrand.user_verification.user_already_verified') }
    end
  end

  def user_verification_params
    params.require(:user_verification).permit(:procesed_at, :front_vatid, :back_vatid, :terms_of_service, :wants_card)
  end

  # SECURITY FIX: Validate report_code against whitelist
  def validate_report_code
    return if params[:report_code].blank?

    valid_codes = Rails.application.secrets.user_verifications&.keys || []

    unless valid_codes.include?(params[:report_code])
      log_security_event('invalid_report_code_attempt', report_code: params[:report_code])
      redirect_to root_path, flash: { alert: t('plebisbrand.errors.invalid_report_code') }
    end
  rescue StandardError => e
    log_error("report_code_validation_failed", e)
    redirect_to root_path, flash: { alert: t('plebisbrand.errors.generic_error') }
  end

  # SECURITY FIX: Validate return_to is internal path (prevent open redirect)
  def safe_return_path
    return_to = session.delete(:return_to)

    # If no return_to or it's external, use root_path
    return root_path if return_to.blank?

    # Parse the URL to check if it's internal
    begin
      uri = URI.parse(return_to)

      # If it has a host and it's not our host, it's external
      if uri.host.present? && uri.host != request.host
        log_security_event('open_redirect_attempt', attempted_url: return_to)
        return root_path
      end

      # If it's a relative path or same host, it's safe
      return_to
    rescue URI::InvalidURIError
      log_security_event('invalid_redirect_url', attempted_url: return_to)
      root_path
    end
  end

  def handle_successful_verification
    if @user_verification.wants_card
      # Use array for multiple messages, view can handle formatting safely
      redirect_to edit_user_registration_path, flash: {
        notice: [
          t('plebisbrand.user_verification.documentation_received'),
          t('plebisbrand.user_verification.please_check_details')
        ]
      }
    else
      # Handle election_id redirect if present
      if params[:election_id].present?
        redirect_to create_vote_path(election_id: params[:election_id])
        return
      end

      redirect_to safe_return_path, flash: { notice: t('plebisbrand.user_verification.documentation_received') }
    end
  end

  # SECURITY LOGGING: Log verification creation
  def log_verification_created
    Rails.logger.info({
      event: "user_verification_created",
      user_id: current_user.id,
      verification_id: @user_verification.id,
      status: @user_verification.status,
      wants_card: @user_verification.wants_card,
      has_front_vatid: @user_verification.front_vatid.present?,
      has_back_vatid: @user_verification.back_vatid.present?,
      timestamp: Time.current.iso8601
    }.to_json)
  end

  # SECURITY LOGGING: Log report access
  def log_report_access(report_type)
    Rails.logger.info({
      event: "verification_report_accessed",
      report_type: report_type,
      report_code: params[:report_code],
      user_id: current_user&.id,
      timestamp: Time.current.iso8601
    }.to_json)
  end

  # SECURITY LOGGING: Log security events
  def log_security_event(event_type, details = {})
    Rails.logger.warn({
      event: event_type,
      user_id: current_user&.id,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
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
      user_id: current_user&.id,
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
