# frozen_string_literal: true

# AudioCaptchaController - Audio CAPTCHA Generation
#
# SECURITY FIXES IMPLEMENTED:
# - Added frozen_string_literal
# - Added comprehensive error handling
# - Added security logging
# - Fixed path traversal vulnerability (already had sanitization)
# - Added validation for captcha_key
# - Added documentation
#
# This controller generates audio versions of visual CAPTCHAs
# to support accessibility for visually impaired users.
class AudioCaptchaController < ApplicationController
  LETTERS = {
    'A' => 'A', 'B' => 'Be', 'C' => 'Ce', 'D' => 'De', 'E' => 'E',
    'F' => 'Efe', 'G' => 'Ge', 'H' => 'Hache', 'I' => 'I', 'J' => 'Jota',
    'K' => 'Ka', 'L' => 'Ele', 'M' => 'Eme', 'N' => 'Ene', 'O' => 'O',
    'P' => 'Pe', 'Q' => 'Cu', 'R' => 'Erre', 'S' => 'Ese', 'T' => 'Te',
    'U' => 'U', 'V' => 'Uve', 'W' => 'Uve doble', 'X' => 'Equis',
    'Y' => 'Y griega', 'Z' => 'Zeta'
  }.freeze

  # Generate and serve audio CAPTCHA
  def index
    # Validate captcha exists
    if captcha_value.blank?
      log_security_event('audio_captcha_invalid_key', captcha_key: params[:captcha_key])
      head :not_found
      return
    end

    # Ensure directory exists
    FileUtils.mkdir_p(file_dir)

    # Clean up old files
    cleanup_old_audio_files

    # Generate audio
    speech.save(file_path)

    log_security_event('audio_captcha_generated',
                       captcha_key: sanitized_captcha_key)

    send_file file_path, type: 'audio/mp3', disposition: :inline
  rescue StandardError => e
    log_error('audio_captcha_generation_error', e,
              captcha_key: params[:captcha_key])
    head :internal_server_error
  end

  private

  # Generate speech from CAPTCHA text
  def speech
    @speech ||= ESpeak::Speech.new(
      captcha_value_spelling,
      voice: "es+#{Random.rand(2).positive? ? 'f' : 'm'}#{Random.rand(1..4)}",
      speed: Random.rand(90..129),
      pitch: Random.rand(30),
      capital: Random.rand(3..32)
    )
  end

  # Convert CAPTCHA to spelled-out version
  def captcha_value_spelling
    return unless captcha_value

    @captcha_value_spelling ||= captcha_value.chars.map do |letter|
      I18n.t("simple_captcha.letters.#{letter}", default: letter)
    end.join(' ')
  end

  # Get CAPTCHA value from session
  def captcha_value
    @captcha_value ||= SimpleCaptcha::Utils.simple_captcha_value(captcha_key)
  end

  # Get CAPTCHA key from params
  def captcha_key
    @captcha_key ||= params[:captcha_key]
  end

  # SECURITY: Sanitize captcha_key to prevent path traversal attacks
  def sanitized_captcha_key
    return nil if captcha_key.blank?

    # Use File.basename to strip directory components
    File.basename(captcha_key.to_s)
  end

  # Generate file path for audio
  def file_path
    @file_path ||= "#{file_dir}/#{sanitized_captcha_key}.mp3"
  end

  # Get directory for audio files
  def file_dir
    @file_dir ||= Rails.root.join('tmp/audios').to_s
  end

  # Clean up old audio files to prevent disk space issues
  def cleanup_old_audio_files
    return unless File.directory?(file_dir)

    cutoff_time = 1.hour.ago
    Dir.glob("#{file_dir}/*.mp3").each do |file|
      File.delete(file) if File.mtime(file) < cutoff_time
    rescue StandardError => e
      Rails.logger.warn("Failed to delete old audio file #{file}: #{e.message}")
    end
  rescue StandardError => e
    log_error('audio_captcha_cleanup_error', e)
  end

  # SECURITY LOGGING
  def log_security_event(event_type, details = {})
    Rails.logger.info({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: 'audio_captcha',
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
      controller: 'audio_captcha',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
