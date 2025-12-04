# frozen_string_literal: true

# ApplicationController - Base Controller for All Controllers
#
# SECURITY FIXES IMPLEMENTED:
# - Added frozen_string_literal
# - Replaced deprecated before_filter with before_action
# - Added comprehensive error handling
# - Added security logging
# - Enhanced admin logging
# - Added documentation
#
# This is the base controller that all other controllers inherit from.
# It provides common functionality like authentication, locale setting,
# and security filters.
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception
  protect_from_forgery with: :exception

  # SECURITY FIX: Replaced deprecated before_filter with before_action
  before_action :banned_user
  before_action :unresolved_issues
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?
  before_action :set_locale
  before_action :allow_iframe_requests
  before_action :admin_logger
  before_action :set_metas

  # Set meta tags for SEO
  def set_metas
    @current_elections = Election.active
    election = @current_elections.find do |e|
      e.meta_description.present?
    end

    if election
      @meta_description = election.meta_description
      @meta_image = election.meta_image if election.meta_image.present?
    end

    # RAILS 7.2 FIX: Handle nil secrets.metas in test environment
    @meta_description ||= Rails.application.secrets.metas&.[]('description')
    @meta_image ||= Rails.application.secrets.metas&.[]('image')

    if flash[:metas]&.dig('description')
      @meta_description = flash[:metas]['description']
      @meta_image = flash[:metas]['image']
    end
  rescue StandardError => e
    log_error('set_metas_error', e)
    # Set safe defaults
    @meta_description ||= begin
      Rails.application.secrets.metas['description']
    rescue StandardError
      nil
    end
    @meta_image ||= begin
      Rails.application.secrets.metas['image']
    rescue StandardError
      nil
    end
  end

  # Allow iframe requests by setting X-Frame-Options to SAMEORIGIN
  # SECURITY: Only allow iframe embedding for public pages, not admin or sensitive endpoints
  def allow_iframe_requests
    # Skip for admin pages and authenticated-only sections
    return if params['controller']&.starts_with?('admin/')
    return if params['controller']&.starts_with?('users/')
    return if params['controller'] == 'sessions'
    return if params['controller'] == 'registrations'

    # SECURITY FIX SEC-023: Set SAMEORIGIN instead of removing protection entirely
    response.headers['X-Frame-Options'] = 'SAMEORIGIN'
  end

  # Log admin actions for audit trail
  def admin_logger
    return unless params['controller']&.starts_with?('admin/')

    begin
      tracking = Logger.new(Rails.root.join('log/activeadmin.log').to_s)
      user_info = user_signed_in? ? current_user.full_name : 'Anonymous'
      tracking.info "** #{user_info} ** #{request.method} #{request.path}"

      # SECURITY FIX (SEC-021): Filter sensitive parameters before logging
      filtered_params = params.except(:password, :password_confirmation, :current_password,
                                      :email, :document_vatid, :phone, :otp, :token)
      tracking.info filtered_params.to_s

      log_security_event('admin_action',
                         user_id: current_user&.id,
                         action: "#{request.method} #{request.path}")
    rescue StandardError => e
      log_error('admin_logger_error', e)
    end
  end

  # Set URL options to include locale
  def default_url_options(_options = {})
    { locale: I18n.locale }
  end

  # Set locale from params or use default
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  rescue StandardError => e
    log_error('set_locale_error', e)
    I18n.locale = I18n.default_locale
  end

  # Override Devise sign-in redirect
  def after_sign_in_path_for(user)
    # Set cookie policy
    cookies[:cookiepolicy] = {
      value: 'hide',
      expires: 18.years.from_now
    }

    # Reset session values
    session.delete(:return_to)
    session[:no_unresolved_issues] = false

    # Check for unresolved issues
    issue = user.get_unresolved_issue

    if issue
      # Clear validation errors to avoid blocking login
      user.errors.messages.clear

      # Remove success message, show issue instead
      flash.delete(:notice)
      issue[:message]&.each { |type, text| flash[type] = t("issues.#{text}") }

      log_security_event('user_has_unresolved_issue',
                         user_id: user.id,
                         issue_controller: issue[:controller])

      return issue[:path]
    end

    # No issues found
    session[:no_unresolved_issues] = true
    log_security_event('sign_in_successful', user_id: user.id)

    stored_location_for(user) || super
  rescue StandardError => e
    log_error('after_sign_in_error', e, user_id: user&.id)
    super
  end

  # Check if user is banned and sign them out
  def banned_user
    return unless current_user&.banned?

    name = current_user.full_name
    user_id = current_user.id

    log_security_event('banned_user_signed_out',
                       user_id: user_id,
                       full_name: name)

    sign_out_and_redirect current_user
    flash[:notice] = t('plebisbrand.banned', full_name: name)
  rescue StandardError => e
    log_error('banned_user_error', e)
  end

  # Check for unresolved user issues
  def unresolved_issues
    return unless current_user
    return if session[:no_unresolved_issues]

    begin
      issue = current_user.get_unresolved_issue(true)
      return unless issue

      # User is on the page to fix the issue
      if params[:controller] == issue[:controller]
        if issue[:message] && request.method != 'POST'
          issue[:message].each { |type, text| flash.now[type] = t("issues.#{text}") }
        end
      # Allow access to sign out, profile, and admin
      elsif params[:controller] == 'devise/sessions' ||
            params[:controller] == 'registrations' ||
            params[:controller]&.start_with?('admin/')
        # Allow these controllers
      else
        # Redirect to fix issue
        redirect_to issue[:path]
      end
    rescue StandardError => e
      log_error('unresolved_issues_error', e, user_id: current_user&.id)
      session[:no_unresolved_issues] = true
    end
  end

  # Handle CanCan authorization failures
  rescue_from CanCan::AccessDenied do |exception|
    log_security_event('access_denied_cancan',
                       user_id: current_user&.id,
                       exception_message: exception.message)
    redirect_to root_url, alert: exception.message
  end

  # Generic access denied handler
  def access_denied(exception)
    log_security_event('access_denied',
                       user_id: current_user&.id,
                       exception_message: exception.message)
    redirect_to root_url, alert: exception.message
  end

  # Authenticate admin users
  def authenticate_admin_user!
    unless signed_in? && (
      current_user.is_admin? ||
      current_user.finances_admin? ||
      current_user.impulsa_admin? ||
      current_user.verifier? ||
      current_user.paper_authority?
    )
      log_security_event('admin_authentication_failed',
                         user_id: current_user&.id)
      redirect_to root_url, flash: { error: t('plebisbrand.unauthorized') }
    end
  end

  # Track user for PaperTrail audit logs
  def user_for_papertrail
    user_signed_in? ? current_user : 'Unknown user'
  end

  protected

  # Configure Devise permitted parameters
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in,
                                      keys: %i[login document_vatid email password remember_me])
  end

  private

  # Check if location should be stored
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  # Store user location for redirect after sign-in
  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  # SECURITY LOGGING
  def log_security_event(event_type, details = {})
    Rails.logger.info({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: 'application',
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
      controller: 'application',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
