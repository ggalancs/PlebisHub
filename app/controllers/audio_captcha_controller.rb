class AudioCaptchaController < ApplicationController
  LETTERS = {
    "A"=>"A", "B"=>"Be", "C"=>"Ce", "D"=>"De", "E"=>"E", "F"=>"Efe", "G"=>"Ge", "H"=>"Hache", "I"=>"I", "J"=>"Jota", "K"=>"Ka", "L"=>"Ele", "M"=>"Eme", "N"=>"Ene",
    "O"=>"O", "P"=>"Pe", "Q"=>"Cu", "R"=>"Erre", "S"=>"Ese", "T"=>"Te", "U"=>"U", "V"=>"Uve", "W"=>"Uve doble", "X"=>"Equis", "Y"=>"Y griega", "Z"=>"Zeta"
  }.freeze

  def index
    # HIGH PRIORITY FIX: Validate captcha_value exists before generating audio
    unless captcha_value.present?
      head :not_found
      return
    end

    FileUtils.mkdir_p file_dir

    # Clean up old audio files to prevent disk space issues
    cleanup_old_audio_files

    speech.save file_path

    send_file file_path, type: 'audio/mp3', disposition: :inline
  end

  private

  def speech
    @speech ||= ESpeak::Speech.new(
      captcha_value_spelling,
      voice: "es+#{Random.rand(2) > 0 ? 'f' : 'm'}#{Random.rand(4)+1}",
      speed: 90 + Random.rand(40),
      pitch: Random.rand(30),
      capital: Random.rand(30) + 3
    )
  end

  def captcha_value_spelling
    return unless captcha_value
    # MEDIUM PRIORITY FIX: Add fallback for missing I18n translations
    @captcha_value_spelling ||= captcha_value.chars.map do |letter|
      I18n.t("simple_captcha.letters.#{letter}", default: letter)
    end.join(" ")
  end

  def captcha_value
    @captcha_value ||= SimpleCaptcha::Utils::simple_captcha_value(captcha_key)
  end

  def captcha_key
    @captcha_key ||= params[:captcha_key]
  end

  # HIGH PRIORITY FIX: Sanitize captcha_key to prevent path traversal attacks
  def sanitized_captcha_key
    return nil unless captcha_key.present?
    # Use File.basename to strip any directory components
    File.basename(captcha_key.to_s)
  end

  def file_path
    @file_path ||= "#{file_dir}/#{sanitized_captcha_key}.mp3"
  end

  def file_dir
    @file_dir ||= "#{Rails.root}/tmp/audios"
  end

  # LOW PRIORITY FIX: Clean up audio files older than 1 hour to prevent disk space issues
  def cleanup_old_audio_files
    return unless File.directory?(file_dir)

    # Delete files older than 1 hour
    cutoff_time = Time.now - 1.hour
    Dir.glob("#{file_dir}/*.mp3").each do |file|
      File.delete(file) if File.mtime(file) < cutoff_time
    rescue StandardError => e
      # Log error but don't fail the request
      Rails.logger.warn("Failed to delete old audio file #{file}: #{e.message}")
    end
  end
end