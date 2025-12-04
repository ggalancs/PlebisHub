# frozen_string_literal: true

# User concern for phone verification and SMS functionality
module User::PhoneVerification
  extend ActiveSupport::Concern

  included do
    # Validations
    validate :validates_phone_format
    validate :validates_unconfirmed_phone_format
    validate :validates_unconfirmed_phone_uniqueness

    # Callbacks
    before_validation :check_unconfirmed_phone

    # Scopes
    scope :confirmed_phone, -> { where.not(sms_confirmed_at: nil) }
  end

  # Phone validation methods
  def validates_unconfirmed_phone_uniqueness
    return if unconfirmed_phone.blank?
    return unless User.confirmed_phone.exists?(phone: unconfirmed_phone)

    errors.add(:phone, 'Ya hay alguien con ese número de teléfono')
  end

  def validates_phone_format
    return if phone.blank?

    _phone = Phonelib.parse phone.sub(/^00+/, '+')
    if _phone.invalid? || _phone.impossible?
      errors.add(:phone, 'Revisa el formato de tu teléfono')
    elsif !_phone.possible_types.intersect?(%i[fixed_line mobile fixed_or_mobile])
      errors.add(:phone, 'Debes utilizar un teléfono móvil')
    else
      self.phone = "00#{_phone.international(false)}"
    end
  end

  def validates_unconfirmed_phone_format
    return if unconfirmed_phone.blank?

    _phone = Phonelib.parse unconfirmed_phone.sub(/^00+/, '+')

    if _phone.invalid? || _phone.impossible?
      errors.add(:unconfirmed_phone, 'Revisa el formato de tu teléfono')
    elsif _phone.invalid_for_country?('ES') && _phone.invalid_for_country?(country)
      errors.add(:unconfirmed_phone, 'Debes utilizar un teléfono de España o del país donde vives')
    elsif !_phone.possible_types.intersect?(%i[mobile fixed_or_mobile])
      errors.add(:unconfirmed_phone, 'Debes utilizar un teléfono móvil')
    else
      self.unconfirmed_phone = "00#{_phone.international(false)}"
    end
  end

  # Phone status methods
  def is_valid_phone?
    phone? && confirmation_sms_sent_at? && sms_confirmed_at? && sms_confirmed_at > confirmation_sms_sent_at
  end

  def can_change_phone?
    sms_confirmed_at.nil? || sms_confirmed_at < DateTime.now - 3.months
  end

  # SMS token generation and verification
  def generate_sms_token
    SecureRandom.hex(4).upcase
  end

  def set_sms_token!
    # Rails 7.2: Use update_column instead of deprecated update_attribute
    update_column(:sms_confirmation_token, generate_sms_token)
  end

  def send_sms_token!
    require 'sms'
    # Rails 7.2: Use update_column instead of deprecated update_attribute
    update_column(:confirmation_sms_sent_at, DateTime.current)
    SMS::Sender.send_message(unconfirmed_phone, sms_confirmation_token)
  end

  def check_sms_token(token)
    if token == sms_confirmation_token
      # Rails 7.2: Use update_column instead of deprecated update_attribute
      update_column(:sms_confirmed_at, DateTime.current)
      if unconfirmed_phone?
        # Rails 7.2: Use update_column instead of deprecated update_attribute
        update_column(:phone, unconfirmed_phone)
        update_column(:unconfirmed_phone, nil)

        if !verified? && !is_admin?
          filter = SpamFilter.any? self
          if filter
            # Rails 7.2: Use update_column instead of deprecated update_attribute
            update_column(:banned, true)
            add_comment("Usuario baneado automáticamente por el filtro: #{filter}")
          end
        end
      end
      true
    else
      false
    end
  end

  # SMS check methods
  def can_request_sms_check?
    DateTime.now > next_sms_check_request_at
  end

  def can_check_sms_check?
    sms_check_at.present? && (DateTime.now < (sms_check_at + parse_duration_config('sms_check_valid_interval')))
  end

  def next_sms_check_request_at
    if sms_check_at.present?
      sms_check_at + parse_duration_config('sms_check_request_interval')
    else
      DateTime.now - 1.second
    end
  end

  def send_sms_check!
    require 'sms'
    if can_request_sms_check?
      # Rails 7.2: Use update_column instead of deprecated update_attribute
      # This bypasses validations/callbacks and directly updates the database
      update_column(:sms_check_at, DateTime.current)
      SMS::Sender.send_message(phone, sms_check_token)
      true
    else
      false
    end
  end

  def valid_sms_check?(value)
    sms_check_at && value.upcase == sms_check_token
  end

  def sms_check_token
    # SECURITY FIX: Use SHA256 instead of SHA1
    return unless sms_check_at

    Digest::SHA256.digest("#{sms_check_at}#{id}#{Rails.application.secrets.users['sms_secret_key']}")[0..3].codepoints.map do |c|
      format('%02X', c)
    end.join
  end

  # Phone setter and formatting
  def unconfirmed_phone=(value)
    _phone = Phonelib.parse(value, country)
    _phone = Phonelib.parse(value, 'ES') if (_phone.invalid? || !_phone.possible_types.intersect?(%i[mobile
                                                                                                     fixed_or_mobile])) && country != 'ES'
    if _phone.valid? && _phone.possible_types.intersect?(%i[mobile fixed_or_mobile])
      self[:unconfirmed_phone] = "00#{_phone.international(false)}"
    else
      self[:unconfirmed_phone] = value
      errors.add(:unconfirmed_phone, 'Debes utilizar un teléfono móvil de España o del país donde vives')
    end
  end

  def unconfirmed_phone_national_part
    extract_national_part(unconfirmed_phone) if unconfirmed_phone.present?
  end

  def phone_national_part
    extract_national_part(phone) if phone.present?
  end

  def country_phone_prefix
    Phonelib.phone_data[country][:country_code]
  rescue StandardError
    '34'
  end

  def phone_prefix
    ret = country_phone_prefix
    if phone.present?
      _phone = Phonelib.parse(phone.sub(/^00+/, '+'))
      ret = _phone.country_code.to_s if _phone&.country_code
    end
    ret
  end

  def phone_country_name
    _phone = Phonelib.parse(phone)
    begin
      _code = _phone.country
      Carmen::Country.coded(_code.upcase).name
    rescue StandardError
      country_name
    end
  end

  private

  def extract_national_part(the_phone)
    phone_obj = Phonelib.parse(the_phone)
    phone_obj.international(false).sub(/^#{phone_obj.country_code}/, '')
  end

  def check_unconfirmed_phone
    self[:unconfirmed_phone] = nil if unconfirmed_phone.present? && country_changed?
  end

  # Safely parse duration configuration strings without using eval()
  # Supports ActiveSupport duration formats: "5.minutes", "1.hour", "1.year"
  def parse_duration_config(key)
    config_value = Rails.application.secrets.users[key]

    # If config value is already a duration (integer seconds), return it
    return config_value.seconds if config_value.is_a?(Integer)

    # Parse string like "1.year", "5.minutes", "1.hour"
    # This safely evaluates only ActiveSupport duration methods
    case config_value.to_s.strip
    when /^(\d+)\.second(s)?$/
      ::Regexp.last_match(1).to_i.seconds
    when /^(\d+)\.minute(s)?$/
      ::Regexp.last_match(1).to_i.minutes
    when /^(\d+)\.hour(s)?$/
      ::Regexp.last_match(1).to_i.hours
    when /^(\d+)\.day(s)?$/
      ::Regexp.last_match(1).to_i.days
    when /^(\d+)\.week(s)?$/
      ::Regexp.last_match(1).to_i.weeks
    when /^(\d+)\.month(s)?$/
      ::Regexp.last_match(1).to_i.months
    when /^(\d+)\.year(s)?$/
      ::Regexp.last_match(1).to_i.years
    else
      # Fallback to safe default for invalid input
      5.minutes
    end
  rescue StandardError => e
    Rails.logger.error("Failed to parse duration config '#{key}': #{config_value} - #{e.message}")
    # Safe default fallback
    5.minutes
  end
end
