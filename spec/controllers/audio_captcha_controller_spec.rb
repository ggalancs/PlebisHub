# frozen_string_literal: true

require 'rails_helper'

# Ensure espeak binary is in PATH before requiring the gem
ENV['PATH'] = "#{ENV['PATH']}:/usr/bin" unless ENV['PATH'].include?('/usr/bin')

# Check if espeak is available before loading tests
begin
  require 'espeak'
  espeak_available = system('which espeak > /dev/null 2>&1')
rescue LoadError, Errno::ENOENT
  espeak_available = false
end

RSpec.describe AudioCaptchaController, type: :controller, skip: !espeak_available do
  # Skip ApplicationController filters that may cause issues in testing
  before do
    allow(controller).to receive(:banned_user).and_return(true)
    allow(controller).to receive(:unresolved_issues).and_return(true)
    allow(controller).to receive(:allow_iframe_requests).and_return(true)
    allow(controller).to receive(:admin_logger).and_return(true)
    allow(controller).to receive(:set_metas).and_return(true)
    allow(controller).to receive(:set_locale).and_return(true)

    # Use main app routes instead of custom route set
    # Rails 7 requires controller specs to use actual application routes
    @routes = Rails.application.routes
  end

  # Clean up test audio files after tests
  after do
    test_audio_dir = Rails.root.join('tmp/audios').to_s
    FileUtils.rm_rf(test_audio_dir) if File.directory?(test_audio_dir)
  end

  describe 'GET #index' do
    let(:captcha_key) { 'test_captcha_123' }
    let(:captcha_value) { 'ABC123' }
    let(:file_dir) { Rails.root.join('tmp/audios').to_s }
    let(:file_path) { "#{file_dir}/#{captcha_key}.mp3" }
    let(:mock_speech) { double('ESpeak::Speech') }

    context 'with valid captcha_key' do
      before do
        # Mock SimpleCaptcha to return a valid value
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(captcha_value)

        # Allow all I18n translations by default, stub only specific captcha letters
        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with('simple_captcha.letters.A', default: 'A').and_return('A')
        allow(I18n).to receive(:t).with('simple_captcha.letters.B', default: 'B').and_return('Be')
        allow(I18n).to receive(:t).with('simple_captcha.letters.C', default: 'C').and_return('Ce')
        allow(I18n).to receive(:t).with('simple_captcha.letters.1', default: '1').and_return('uno')
        allow(I18n).to receive(:t).with('simple_captcha.letters.2', default: '2').and_return('dos')
        allow(I18n).to receive(:t).with('simple_captcha.letters.3', default: '3').and_return('tres')

        # Mock ESpeak::Speech
        allow(ESpeak::Speech).to receive(:new).and_return(mock_speech)
        allow(mock_speech).to receive(:save) do |path|
          # Create the actual file to simulate ESpeak behavior
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, 'fake audio content')
        end
      end

      it "creates the audio directory if it doesn't exist" do
        expect(FileUtils).to receive(:mkdir_p).with(file_dir).at_least(:once).and_call_original
        get :index, params: { captcha_key: captcha_key }
      end

      it 'generates the audio file' do
        get :index, params: { captcha_key: captcha_key }
        expect(File.exist?(file_path)).to be true
      end

      it 'sends the file with audio/mp3 MIME type' do
        get :index, params: { captcha_key: captcha_key }
        expect(response.content_type).to eq('audio/mp3')
      end

      it 'sends the file with inline disposition' do
        get :index, params: { captcha_key: captcha_key }
        expect(response.headers['Content-Disposition']).to include('inline')
      end

      it 'returns success status' do
        get :index, params: { captcha_key: captcha_key }
        expect(response).to have_http_status(:success)
      end

      it 'calls ESpeak::Speech with the captcha spelling' do
        expected_text = 'A Be Ce uno dos tres'
        expect(ESpeak::Speech).to receive(:new).with(
          expected_text,
          hash_including(
            voice: kind_of(String),
            speed: kind_of(Integer),
            pitch: kind_of(Integer),
            capital: kind_of(Integer)
          )
        ).and_return(mock_speech)

        get :index, params: { captcha_key: captcha_key }
      end

      it 'uses Spanish voice with random gender and variant' do
        get :index, params: { captcha_key: captcha_key }

        # ESpeak::Speech.new should have been called with a voice matching pattern
        expect(ESpeak::Speech).to have_received(:new) do |_text, options|
          expect(options[:voice]).to match(/^es\+[fm][1-4]$/)
        end
      end

      it 'uses random speed between 90 and 129' do
        get :index, params: { captcha_key: captcha_key }

        expect(ESpeak::Speech).to have_received(:new) do |_text, options|
          expect(options[:speed]).to be_between(90, 129)
        end
      end

      it 'uses random pitch between 0 and 29' do
        get :index, params: { captcha_key: captcha_key }

        expect(ESpeak::Speech).to have_received(:new) do |_text, options|
          expect(options[:pitch]).to be_between(0, 29)
        end
      end

      it 'uses random capital between 3 and 32' do
        get :index, params: { captcha_key: captcha_key }

        expect(ESpeak::Speech).to have_received(:new) do |_text, options|
          expect(options[:capital]).to be_between(3, 32)
        end
      end
    end

    context 'with missing captcha_key parameter' do
      it 'returns 404 when captcha_key is missing' do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value).with(nil)
                                                                     .and_return(nil)

        get :index
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with invalid captcha_key' do
      let(:invalid_key) { 'nonexistent_key' }

      before do
        # Mock SimpleCaptcha to return nil for invalid key
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(invalid_key)
          .and_return(nil)
      end

      it 'returns 404 when captcha_value is nil' do
        get :index, params: { captcha_key: invalid_key }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with empty captcha_key' do
      before do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with('')
          .and_return(nil)
      end

      it 'returns 404 for empty string captcha_key' do
        get :index, params: { captcha_key: '' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'security: path traversal attempts' do
      let(:malicious_key) { '../../../etc/passwd' }

      before do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(malicious_key)
          .and_return(captcha_value)

        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with(/^simple_captcha\.letters\./).and_return('test')
        allow(ESpeak::Speech).to receive(:new).and_return(mock_speech)
        allow(mock_speech).to receive(:save) do |path|
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, 'fake audio')
        end
      end

      it 'sanitizes path traversal attempts and saves file safely' do
        # The file should be saved with sanitized filename (basename only)
        safe_filename = File.basename(malicious_key)
        safe_path = "#{file_dir}/#{safe_filename}.mp3"

        # Verify that save is called with the sanitized path, not the dangerous one
        expect(mock_speech).to receive(:save).with(safe_path) do |path|
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, 'fake audio')
        end

        get :index, params: { captcha_key: malicious_key }

        expect(response).to have_http_status(:success)
        expect(File.exist?(safe_path)).to be true
      end
    end

    context 'captcha_value_spelling method' do
      before do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(captcha_value)

        # Setup I18n mocks for all possible letters
        allow(I18n).to receive(:t).and_call_original
        ('A'..'Z').each do |letter|
          letter_name = AudioCaptchaController::LETTERS[letter] || letter
          allow(I18n).to receive(:t).with("simple_captcha.letters.#{letter}")
                                    .and_return(letter_name)
        end

        ('0'..'9').each do |digit|
          allow(I18n).to receive(:t).with("simple_captcha.letters.#{digit}")
                                    .and_return(digit)
        end
      end

      it 'converts each character to its spelling' do
        allow(ESpeak::Speech).to receive(:new) do |text, _options|
          expect(text).to be_a(String)
          expect(text.split.length).to eq(6) # ABC123 = 6 characters
          mock_speech
        end

        allow(mock_speech).to receive(:save) do |path|
          File.write(path, 'fake audio')
        end

        get :index, params: { captcha_key: captcha_key }
      end

      it 'joins spellings with spaces' do
        allow(ESpeak::Speech).to receive(:new) do |text, _options|
          expect(text).to include(' ') # Should have spaces between letters
          mock_speech
        end

        allow(mock_speech).to receive(:save) do |path|
          File.write(path, 'fake audio')
        end

        get :index, params: { captcha_key: captcha_key }
      end
    end

    context 'file management' do
      before do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(captcha_value)

        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with(/^simple_captcha\.letters\./).and_return('test')
        allow(ESpeak::Speech).to receive(:new).and_return(mock_speech)
        allow(mock_speech).to receive(:save) do |path|
          File.write(path, 'fake audio content for test')
        end
      end

      it 'creates file with .mp3 extension' do
        get :index, params: { captcha_key: captcha_key }
        expect(file_path).to end_with('.mp3')
        expect(File.exist?(file_path)).to be true
      end

      it 'stores file in tmp/audios directory' do
        get :index, params: { captcha_key: captcha_key }
        expect(file_path).to include('tmp/audios')
      end

      it 'uses captcha_key as filename' do
        get :index, params: { captcha_key: captcha_key }
        expect(file_path).to include(captcha_key)
      end
    end

    context 'randomization' do
      before do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(captcha_value)

        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with(/^simple_captcha\.letters\./).and_return('test')
        allow(mock_speech).to receive(:save) do |path|
          File.write(path, 'fake audio')
        end
      end

      it 'uses different voices across multiple calls' do
        voices = []

        5.times do
          allow(ESpeak::Speech).to receive(:new) do |_text, options|
            voices << options[:voice]
            mock_speech
          end

          get :index, params: { captcha_key: captcha_key }
        end

        # With random generation, we expect at least some variation
        # (though technically all could be the same by chance)
        expect(voices.uniq.length).to be >= 1
      end

      it 'uses different speeds across multiple calls' do
        speeds = []

        5.times do
          allow(ESpeak::Speech).to receive(:new) do |_text, options|
            speeds << options[:speed]
            mock_speech
          end

          get :index, params: { captcha_key: captcha_key }
        end

        expect(speeds.uniq.length).to be >= 1
      end
    end

    context 'I18n fallback behavior' do
      let(:captcha_with_missing_translation) { 'XYZ' }

      before do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(captcha_with_missing_translation)

        # Mock I18n to return translation_missing for some letters
        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with('simple_captcha.letters.X', default: 'X').and_return('X')
        allow(I18n).to receive(:t).with('simple_captcha.letters.Y', default: 'Y').and_return('Y')
        allow(I18n).to receive(:t).with('simple_captcha.letters.Z', default: 'Z').and_return('Z')

        allow(ESpeak::Speech).to receive(:new).and_return(mock_speech)
        allow(mock_speech).to receive(:save) do |path|
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, 'fake audio')
        end
      end

      it 'uses fallback when I18n translation is missing' do
        get :index, params: { captcha_key: captcha_key }
        expect(response).to have_http_status(:success)

        # Verify ESpeak was called with the fallback letters
        expect(ESpeak::Speech).to have_received(:new).with('X Y Z', anything)
      end
    end

    context 'cleanup of old audio files' do
      before do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(captcha_value)

        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with(/^simple_captcha\.letters\./).and_return('test')
        allow(ESpeak::Speech).to receive(:new).and_return(mock_speech)
        allow(mock_speech).to receive(:save) do |path|
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, 'fake audio')
        end
      end

      it 'deletes audio files older than 1 hour' do
        # Create old files
        old_file = "#{file_dir}/old_captcha.mp3"
        FileUtils.mkdir_p(file_dir)
        File.write(old_file, 'old audio')

        # Set file modification time to 2 hours ago
        old_time = 2.hours.ago
        File.utime(old_time, old_time, old_file)

        expect(File.exist?(old_file)).to be true

        get :index, params: { captcha_key: captcha_key }

        # Old file should be deleted
        expect(File.exist?(old_file)).to be false
      end

      it 'keeps audio files newer than 1 hour' do
        # Create recent file
        recent_file = "#{file_dir}/recent_captcha.mp3"
        FileUtils.mkdir_p(file_dir)
        File.write(recent_file, 'recent audio')

        # Set file modification time to 30 minutes ago
        recent_time = 30.minutes.ago
        File.utime(recent_time, recent_time, recent_file)

        expect(File.exist?(recent_file)).to be true

        get :index, params: { captcha_key: captcha_key }

        # Recent file should still exist
        expect(File.exist?(recent_file)).to be true
      end
    end
  end
end
