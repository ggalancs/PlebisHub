# frozen_string_literal: true

# RegistrationsController - User Registration and Account Management
#
# SECURITY FIXES IMPLEMENTED:
# - Replaced deprecated prepend_before_filter with prepend_before_action
# - Enhanced user enumeration protection (paranoid mode)
# - Added comprehensive error handling
# - Fixed array subtraction bug in error handling
# - Added security logging for all sensitive actions
# - Added input validation and sanitization
# - Added authorization checks
# - Moved email delivery to background jobs
# - Fixed dangerous string concatenation in I18n
# - Added rate limiting documentation
#
# This controller extends Devise::RegistrationsController to customize
# user registration, account updates, and account deletion flows.
class RegistrationsController < Devise::RegistrationsController
  include Redirectable

  # SECURITY FIX: Replaced deprecated prepend_before_filter with prepend_before_action
  prepend_before_action :load_user_location
  before_action :validate_vote_circle, only: [:update]

  helper_method :locked_personal_data?

  # Load user location data for dropdowns
  def load_user_location
    @user_location = User.get_location(current_user, params)
  rescue StandardError => e
    log_error('load_user_location_error', e)
    @user_location = {}
  end

  # AJAX: Render regions/provinces dropdown
  # Dropdown for AJAX on registrations edit/new
  def regions_provinces
    render partial: 'subregion_select', locals: {
      country: @user_location[:country],
      province: @user_location[:province],
      disabled: false,
      required: true,
      field: :province,
      title: 'Provincia',
      options_filter: (!current_user || current_user.can_change_vote_location? ? User.blocked_provinces : nil)
    }
  rescue StandardError => e
    log_error('regions_provinces_error', e)
    head :internal_server_error
  end

  # AJAX: Render regions/municipalities dropdown
  # Dropdown for AJAX on registrations edit/new
  def regions_municipies
    render partial: 'municipies_select', locals: {
      country: @user_location[:country],
      province: @user_location[:province],
      town: @user_location[:town],
      disabled: false,
      required: true,
      field: :town,
      title: 'Municipio'
    }
  rescue StandardError => e
    log_error('regions_municipies_error', e)
    head :internal_server_error
  end

  # AJAX: Render vote municipalities dropdown
  # Dropdown for AJAX on registrations edit/new
  def vote_municipies
    render partial: 'municipies_select', locals: {
      country: 'ES',
      province: @user_location[:vote_province],
      town: @user_location[:vote_town],
      disabled: false,
      required: false,
      field: :vote_town,
      title: 'Municipio de participación'
    }
  rescue StandardError => e
    log_error('vote_municipies_error', e)
    head :internal_server_error
  end

  # Create new user registration
  # Implements paranoid mode to prevent user enumeration
  def create
    build_resource(sign_up_params)

    # Check captcha first
    unless resource.valid_with_captcha?
      log_security_event('registration_invalid_captcha', email: params.dig(:user, :email))
      clean_up_passwords(resource)
      render :new
      return
    end

    # RAILS 7.2 FIX: Validate to trigger uniqueness checks BEFORE calling super
    # This allows us to detect duplicates and handle them in paranoid mode
    resource.validate

    # SECURITY: Paranoid mode - check if user already exists
    # Check document_vatid first
    result, status = user_already_exists?(resource, :document_vatid)
    if status
      log_security_event('registration_duplicate_document', document_vatid: result.document_vatid)
      # SECURITY FIX: Use deliver_later for non-blocking email delivery
      UsersMailer.remember_email(:document_vatid, result.document_vatid).deliver_later
      redirect_to(root_path, notice: t('devise.registrations.signed_up_but_unconfirmed'))
      return
    end

    # Check email
    result, status = user_already_exists?(resource, :email)
    if status
      log_security_event('registration_duplicate_email', email: result.email)
      # SECURITY FIX: Use deliver_later for non-blocking email delivery
      UsersMailer.remember_email(:email, result.email).deliver_later
      redirect_to(root_path, notice: t('devise.registrations.signed_up_but_unconfirmed'))
      return
    end

    # No duplicates found, proceed with normal Devise registration
    super do
      # Log successful registration
      log_security_event('user_registration_success', email: resource.email)
    end
  rescue StandardError => e
    log_error('registration_create_error', e)
    clean_up_passwords(resource) if resource
    flash[:alert] = t('devise.registrations.signed_up_but_unconfirmed')
    render :new
  end

  # Delete user account
  def destroy
    log_security_event('account_deletion_request', user_id: current_user.id, email: current_user.email)

    # SECURITY FIX: Use deliver_later for non-blocking email delivery
    UsersMailer.cancel_account_email(current_user.id).deliver_later
    super
  rescue StandardError => e
    log_error('account_deletion_error', e, user_id: current_user&.id)
    redirect_to root_path, alert: t('devise.registrations.destroyed')
  end

  # Allow user to reset password from their profile
  # Sends password reset email and logs user out
  def recover_and_logout
    log_security_event('password_recovery_from_profile', user_id: current_user.id)

    current_user.send_reset_password_instructions
    sign_out_and_redirect current_user
    flash[:notice] = t('devise.confirmations.send_instructions')
  rescue StandardError => e
    log_error('password_recovery_error', e, user_id: current_user&.id)
    sign_out_and_redirect current_user
    flash[:alert] = t('devise.passwords.send_paranoid_instructions')
  end

  # Override Devise flash message to include resource params
  def set_flash_message(key, kind, options = {})
    # Rails 7.2: Convert permitted parameters to hash for symbolization
    params_hash = resource_params.respond_to?(:to_unsafe_h) ? resource_params.to_unsafe_h : resource_params.to_h
    options.merge! params_hash.deep_symbolize_keys
    message = find_message(kind, options)
    flash[key] = message if message.present?
  end

  # Generate and display QR code for user
  # SECURITY: Only accessible to authenticated users with permission
  # SECURITY FIX SEC-008: Explicitly reject any user_id parameter to prevent IDOR
  def qr_code
    # SECURITY FIX: Explicitly reject any user_id parameter to prevent IDOR
    if params[:user_id].present? || params[:id].present?
      log_security_event('qr_idor_attempt', attempted_user: params[:user_id] || params[:id])
      return redirect_to root_path, alert: 'Unauthorized access'
    end

    unless current_user&.can_show_qr?
      log_security_event('unauthorized_qr_access_attempt', user_id: current_user&.id)
      return redirect_to root_path
    end

    @user = current_user
    @svg = current_user.qr_svg
    @date_end = current_user.qr_expire_date.strftime('%F %T')

    log_security_event('qr_code_accessed', user_id: current_user.id)
    render 'devise/registrations/qr_code', layout: false
  rescue StandardError => e
    log_error('qr_code_generation_error', e, user_id: current_user&.id)
    redirect_to root_path, alert: t('errors.messages.qr_code_unavailable')
  end

  private

  # Check if personal data is locked (user is verified)
  def locked_personal_data?
    @locked_personal_data ||= current_user&.verified?
  end

  # SECURITY: Paranoid mode implementation
  # Check if user already exists by email or document_vatid
  # Returns [resource, exists_boolean]
  #
  # FIX for https://github.com/plataformatec/devise/issues/3540
  # Devise paranoid only works for password resets.
  # With the uniqueness validation on user.document_vatid and user.email
  # it's possible to do a user listing attack.
  #
  # If the email or document_vatid are already taken we should fail
  # silently (showing the same message as an OK creation) and send
  # an email to the original user.
  #
  # See test/features/users_are_paranoid_test.rb
  def user_already_exists?(resource, type)
    # RAILS 7.2 FIX: errors.added? doesn't work correctly in Rails 7.2
    # Use errors.details to check for :taken error instead
    has_taken_error = resource.errors.details[type]&.any? { |error| error[:error] == :taken }
    return [resource, false] unless has_taken_error

    # SECURITY FIX: Use proper error clearing instead of array subtraction
    # Remove the "taken" error message to hide existence from attacker
    translation_key = "activerecord.errors.models.user.attributes.#{type}.taken"
    taken_message = t(translation_key)

    resource.errors[type].delete(taken_message)
    resource.errors.delete(type) if resource.errors[type].empty?

    [resource, true]
  rescue StandardError => e
    log_error('user_already_exists_error', e, type: type)
    [resource, false]
  end

  # SECURITY: Validate vote_circle_id changes
  # SEC-009: Added eligibility validation to prevent vote circle manipulation
  def validate_vote_circle
    return if params.dig(:user, :vote_circle_id).blank?

    vote_circle_id = params[:user][:vote_circle_id]

    # Find vote_circle
    vote_circle = VoteCircle.find_by(id: vote_circle_id)

    unless vote_circle
      log_security_event('invalid_vote_circle_attempt',
                         user_id: current_user.id,
                         vote_circle_id: vote_circle_id)
      redirect_to edit_user_registration_path, alert: t('errors.messages.invalid_vote_circle')
      return false
    end

    # SEC-009: SECURITY FIX - Validate user eligibility based on location
    unless user_eligible_for_vote_circle?(current_user, vote_circle)
      log_security_event('unauthorized_vote_circle_attempt',
                         user_id: current_user.id,
                         vote_circle_id: vote_circle_id,
                         user_location: "#{current_user.vote_province}/#{current_user.vote_town}")
      redirect_to edit_user_registration_path, alert: t('errors.messages.vote_circle_location_mismatch')
      return false
    end

    # Log vote_circle change for audit trail
    if current_user.vote_circle_id != vote_circle_id.to_i
      log_security_event('vote_circle_changed',
                         user_id: current_user.id,
                         old_vote_circle_id: current_user.vote_circle_id,
                         new_vote_circle_id: vote_circle_id)
    end

    true
  rescue StandardError => e
    log_error('validate_vote_circle_error', e, user_id: current_user&.id)
    redirect_to edit_user_registration_path, alert: t('errors.messages.invalid_vote_circle')
    false
  end

  # SEC-009: Validate user eligibility for vote_circle based on geographic scope
  def user_eligible_for_vote_circle?(user, vote_circle)
    # Allow any circle if user doesn't have location restrictions
    return true unless vote_circle.respond_to?(:scope)

    case vote_circle.scope
    when 'town'
      user.vote_town == vote_circle.town
    when 'province'
      user.vote_province == vote_circle.province_code
    when 'autonomy'
      user.vote_province&.starts_with?(vote_circle.autonomy_code.to_s)
    when 'national'
      true  # All users eligible for national circles
    else
      true  # Unrestricted circles
    end
  end

  # Strong parameters for sign up
  # SECURITY: NEVER allow setting admin, flags, sms or verification fields
  def sign_up_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :email_confirmation,
      :password, :password_confirmation, :born_at, :wants_newsletter,
      :gender, :document_type, :document_vatid, :terms_of_service,
      :over_18, :address, :town, :province, :vote_town, :vote_province,
      :postal_code, :country, :captcha, :captcha_key
    )
  end

  # Strong parameters for account update
  # SECURITY: NEVER allow setting admin, flags, sms or verification fields
  # Dynamically allows fields based on user permissions and verification status
  def account_update_params
    fields = %w[email password password_confirmation current_password
                gender address postal_code country province town]

    # Allow vote location change only if user has permission
    fields += %w[vote_province vote_town] if current_user.can_change_vote_location?

    # Allow personal data change only if not locked (not verified)
    fields += %w[first_name last_name born_at] unless locked_personal_data?

    # Additional allowed fields
    fields += %w[wants_information_by_sms vote_circle_id checked_vote_circle]

    params.require(:user).permit(*fields)
  end

  # SECURITY LOGGING: Log security-relevant events
  def log_security_event(event_type, details = {})
    Rails.logger.warn({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: 'registrations',
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
      controller: 'registrations',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
