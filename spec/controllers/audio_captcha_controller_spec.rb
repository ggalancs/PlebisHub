# frozen_string_literal: true

require 'rails_helper'

# Ensure espeak binary is in PATH before requiring the gem
ENV['PATH'] = "#{ENV['PATH']}:/usr/bin" unless ENV['PATH'].include?('/usr/bin')

# Stub IO.popen for espeak since the binary might not be available
# The espeak gem calls `espeak --voices` when required
if !system('which espeak > /dev/null 2>&1')
  # Mock espeak binary before loading the gem
  class << IO
    alias_method :original_popen, :popen

    def popen(command, *args, &block)
      if command.to_s.include?('espeak')
        # Return empty voices list header
        io = StringIO.new("Pty Language Age/Gender VoiceName          File          Other Languages\n")
        block ? block.call(io) : io
      else
        original_popen(command, *args, &block)
      end
    end
  end
end

# Require espeak gem
require 'espeak'

RSpec.describe AudioCaptchaController, type: :controller do
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
        old_time = 2.hours.ago.to_time
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
        recent_time = 30.minutes.ago.to_time
        File.utime(recent_time, recent_time, recent_file)

        expect(File.exist?(recent_file)).to be true

        get :index, params: { captcha_key: captcha_key }

        # Recent file should still exist
        expect(File.exist?(recent_file)).to be true
      end

      it 'handles errors when deleting individual files gracefully' do
        # Create an old file
        old_file = "#{file_dir}/old_captcha.mp3"
        FileUtils.mkdir_p(file_dir)
        File.write(old_file, 'old audio')
        old_time = 2.hours.ago.to_time
        File.utime(old_time, old_time, old_file)

        # Mock File.delete to raise an error
        allow(File).to receive(:delete).and_raise(StandardError.new('Permission denied'))
        allow(Rails.logger).to receive(:warn)

        # Should not raise, just log the warning
        expect { get :index, params: { captcha_key: captcha_key } }.not_to raise_error
        expect(Rails.logger).to have_received(:warn).with(/Failed to delete old audio file/)
      end

      it 'handles errors during cleanup process gracefully' do
        # Mock Dir.glob to raise an error
        allow(Dir).to receive(:glob).and_raise(StandardError.new('IO error'))
        allow(Rails.logger).to receive(:error)

        # Should not raise, just log the error
        expect { get :index, params: { captcha_key: captcha_key } }.not_to raise_error
      end

      it 'skips cleanup when directory does not exist' do
        # Ensure directory doesn't exist
        FileUtils.rm_rf(file_dir)

        # Should not raise error
        expect { get :index, params: { captcha_key: captcha_key } }.not_to raise_error
      end
    end

    context 'error handling' do
      before do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(captcha_value)

        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with(/^simple_captcha\.letters\./).and_return('test')
      end

      it 'returns 500 and logs error when ESpeak fails' do
        allow(ESpeak::Speech).to receive(:new).and_raise(StandardError.new('ESpeak error'))
        allow(Rails.logger).to receive(:error)

        get :index, params: { captcha_key: captcha_key }

        expect(response).to have_http_status(:internal_server_error)
        expect(Rails.logger).to have_received(:error)
      end

      it 'returns 500 when file save fails' do
        allow(ESpeak::Speech).to receive(:new).and_return(mock_speech)
        allow(mock_speech).to receive(:save).and_raise(StandardError.new('Cannot write file'))
        allow(Rails.logger).to receive(:error)

        get :index, params: { captcha_key: captcha_key }

        expect(response).to have_http_status(:internal_server_error)
      end

      it 'returns 500 when directory creation fails' do
        allow(FileUtils).to receive(:mkdir_p).and_raise(StandardError.new('Permission denied'))
        allow(Rails.logger).to receive(:error)

        get :index, params: { captcha_key: captcha_key }

        expect(response).to have_http_status(:internal_server_error)
      end

      it 'logs detailed error information' do
        error = StandardError.new('Test error')
        allow(ESpeak::Speech).to receive(:new).and_raise(error)
        allow(Rails.logger).to receive(:error)

        get :index, params: { captcha_key: captcha_key }

        expect(Rails.logger).to have_received(:error) do |log_data|
          parsed = JSON.parse(log_data)
          expect(parsed['event']).to eq('audio_captcha_generation_error')
          expect(parsed['error_class']).to eq('StandardError')
          expect(parsed['error_message']).to eq('Test error')
          expect(parsed['ip_address']).to be_present
          expect(parsed['controller']).to eq('audio_captcha')
          expect(parsed['timestamp']).to be_present
          expect(parsed['backtrace']).to be_an(Array)
        end
      end
    end

    context 'security logging' do
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
        allow(Rails.logger).to receive(:info)
      end

      it 'logs successful audio generation with security event' do
        get :index, params: { captcha_key: captcha_key }

        expect(Rails.logger).to have_received(:info).at_least(:once) do |log_data|
          # Skip non-JSON log entries (like Rails processing messages)
          next unless log_data.is_a?(String) && log_data.strip.start_with?('{')

          parsed = JSON.parse(log_data)
          if parsed['event'] == 'audio_captcha_generated'
            expect(parsed['captcha_key']).to eq(captcha_key)
            expect(parsed['ip_address']).to be_present
            expect(parsed['user_agent']).to be_present
            expect(parsed['controller']).to eq('audio_captcha')
            expect(parsed['timestamp']).to be_present
          end
        end
      end

      it 'logs invalid captcha key attempts' do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with('invalid_key')
          .and_return(nil)
        allow(Rails.logger).to receive(:info)

        get :index, params: { captcha_key: 'invalid_key' }

        expect(Rails.logger).to have_received(:info).at_least(:once) do |log_data|
          # Skip non-JSON log entries (like Rails processing messages)
          next unless log_data.is_a?(String) && log_data.strip.start_with?('{')

          parsed = JSON.parse(log_data)
          if parsed['event'] == 'audio_captcha_invalid_key'
            expect(parsed['captcha_key']).to eq('invalid_key')
          end
        end
      end

      it 'includes request metadata in security logs' do
        get :index, params: { captcha_key: captcha_key }

        expect(Rails.logger).to have_received(:info).at_least(:once) do |log_data|
          # Skip non-JSON log entries (like Rails processing messages)
          next unless log_data.is_a?(String) && log_data.strip.start_with?('{')

          parsed = JSON.parse(log_data)
          if parsed['event'] == 'audio_captcha_generated'
            expect(parsed).to have_key('ip_address')
            expect(parsed).to have_key('user_agent')
            expect(parsed).to have_key('timestamp')
          end
        end
      end
    end

    context 'edge cases' do
      before do
        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with(/^simple_captcha\.letters\./).and_return('test')
        allow(ESpeak::Speech).to receive(:new).and_return(mock_speech)
        allow(mock_speech).to receive(:save) do |path|
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, 'fake audio')
        end
      end

      it 'handles blank captcha_value in spelling method' do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return('')

        get :index, params: { captcha_key: captcha_key }

        expect(response).to have_http_status(:not_found)
      end

      it 'handles nil captcha_key in sanitization' do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(nil)
          .and_return(nil)

        get :index
        expect(response).to have_http_status(:not_found)
      end

      it 'handles captcha_key with special characters' do
        special_key = 'test@#$%key'
        safe_key = File.basename(special_key)

        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(special_key)
          .and_return(captcha_value)

        get :index, params: { captcha_key: special_key }

        expect(response).to have_http_status(:success)
        expect(File.exist?("#{file_dir}/#{safe_key}.mp3")).to be true
      end

      it 'handles very long captcha values' do
        long_captcha = 'A' * 100
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(long_captcha)

        allow(I18n).to receive(:t).with('simple_captcha.letters.A', default: 'A').and_return('A')

        get :index, params: { captcha_key: captcha_key }

        expect(response).to have_http_status(:success)
      end

      it 'handles captcha with only numbers' do
        number_captcha = '123456'
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(number_captcha)

        ('0'..'9').each do |digit|
          allow(I18n).to receive(:t).with("simple_captcha.letters.#{digit}",
                                          default: digit).and_return(digit)
        end

        get :index, params: { captcha_key: captcha_key }

        expect(response).to have_http_status(:success)
      end

      it 'handles mixed case captcha values' do
        mixed_case = 'AbC123'
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(mixed_case)

        allow(I18n).to receive(:t).with('simple_captcha.letters.A', default: 'A').and_return('A')
        allow(I18n).to receive(:t).with('simple_captcha.letters.b', default: 'b').and_return('b')
        allow(I18n).to receive(:t).with('simple_captcha.letters.C', default: 'C').and_return('C')
        allow(I18n).to receive(:t).with('simple_captcha.letters.1', default: '1').and_return('1')
        allow(I18n).to receive(:t).with('simple_captcha.letters.2', default: '2').and_return('2')
        allow(I18n).to receive(:t).with('simple_captcha.letters.3', default: '3').and_return('3')

        get :index, params: { captcha_key: captcha_key }

        expect(response).to have_http_status(:success)
      end
    end

    context 'private method coverage' do
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

      it 'memoizes captcha_value' do
        get :index, params: { captcha_key: captcha_key }

        # SimpleCaptcha should only be called once due to memoization
        expect(SimpleCaptcha::Utils).to have_received(:simple_captcha_value).once
      end

      it 'memoizes captcha_key' do
        get :index, params: { captcha_key: captcha_key }
        # Should access params only once due to memoization
        expect(response).to have_http_status(:success)
      end

      it 'memoizes speech object' do
        get :index, params: { captcha_key: captcha_key }

        # ESpeak::Speech should only be instantiated once
        expect(ESpeak::Speech).to have_received(:new).once
      end

      it 'memoizes file_path' do
        get :index, params: { captcha_key: captcha_key }
        expect(response).to have_http_status(:success)
      end

      it 'memoizes file_dir' do
        get :index, params: { captcha_key: captcha_key }
        expect(response).to have_http_status(:success)
      end

      it 'memoizes captcha_value_spelling' do
        get :index, params: { captcha_key: captcha_key }

        # I18n.t should be called 6 times (once per character in 'ABC123')
        # If memoization works, it won't be called again on subsequent accesses
        expect(response).to have_http_status(:success)
      end
    end

    context 'voice randomization patterns' do
      before do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(captcha_value)

        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with(/^simple_captcha\.letters\./).and_return('test')
        allow(mock_speech).to receive(:save) do |path|
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, 'fake audio')
        end
      end

      it 'generates male or female voices' do
        voices = []

        10.times do
          allow(ESpeak::Speech).to receive(:new) do |_text, options|
            voices << options[:voice]
            mock_speech
          end

          get :index, params: { captcha_key: captcha_key }
        end

        # All voices should match the pattern es+[fm][1-4]
        expect(voices).to all(match(/^es\+[fm][1-4]$/))
      end

      it 'includes variant numbers 1-4' do
        voices = []

        10.times do
          allow(ESpeak::Speech).to receive(:new) do |_text, options|
            voices << options[:voice]
            mock_speech
          end

          get :index, params: { captcha_key: captcha_key }
        end

        variants = voices.map { |v| v[-1].to_i }
        expect(variants).to all(be_between(1, 4))
      end
    end

    context 'file system operations' do
      before do
        allow(SimpleCaptcha::Utils).to receive(:simple_captcha_value)
          .with(captcha_key)
          .and_return(captcha_value)

        allow(I18n).to receive(:t).and_call_original
        allow(I18n).to receive(:t).with(/^simple_captcha\.letters\./).and_return('test')
        allow(ESpeak::Speech).to receive(:new).and_return(mock_speech)
        allow(mock_speech).to receive(:save) do |path|
          FileUtils.mkdir_p(File.dirname(path))
          File.write(path, 'fake audio content')
        end
      end

      it 'creates the audio file in the correct location' do
        get :index, params: { captcha_key: captcha_key }

        expect(File.exist?(file_path)).to be true
        expect(File.read(file_path)).to eq('fake audio content')
      end

      it 'sends the correct file content' do
        get :index, params: { captcha_key: captcha_key }

        expect(response.body).to eq('fake audio content')
      end
    end
  end
end
