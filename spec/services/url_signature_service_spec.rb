# frozen_string_literal: true

require 'rails_helper'
require 'base64'
require 'openssl'

RSpec.describe UrlSignatureService do
  # This is a backward compatibility alias class that inherits from
  # PlebisVerification::UrlSignatureService. Tests here exercise the parent class.

  let(:secret_key) { 'test_secret_key_12345' }
  let(:url) { 'https://example.com/page?param=value' }

  subject { described_class.new(secret_key) }

  describe 'class definition' do
    it 'is defined as a class' do
      expect(described_class).to be_a(Class)
    end

    it 'has correct class name' do
      expect(described_class.name).to eq('UrlSignatureService')
    end

    it 'is properly namespaced (no namespace)' do
      expect(described_class.name).not_to include('::')
    end

    it 'inherits from PlebisVerification::UrlSignatureService' do
      expect(described_class.superclass).to eq(PlebisVerification::UrlSignatureService)
    end
  end

  describe '#initialize' do
    context 'with secret_key parameter' do
      it 'uses provided secret key' do
        service = described_class.new('custom_secret')
        expect(service.instance_variable_get(:@secret)).to eq('custom_secret')
      end
    end

    context 'without secret_key parameter' do
      before do
        allow(Rails.application.secrets).to receive(:forms).and_return({ 'secret' => 'rails_secret' })
      end

      it 'uses Rails secret from configuration' do
        service = described_class.new
        expect(service.instance_variable_get(:@secret)).to eq('rails_secret')
      end

      it 'handles nil forms configuration' do
        allow(Rails.application.secrets).to receive(:forms).and_return(nil)
        service = described_class.new
        expect(service.instance_variable_get(:@secret)).to be_nil
      end
    end
  end

  describe '#sign_url' do
    it 'adds signature parameter to URL' do
      result = subject.sign_url(url)
      expect(result).to include('signature=')
    end

    it 'adds timestamp parameter to URL' do
      result = subject.sign_url(url)
      expect(result).to include('timestamp=')
    end

    it 'preserves original URL' do
      result = subject.sign_url(url)
      expect(result).to start_with(url)
    end

    it 'uses current timestamp' do
      freeze_time = Time.now.to_i
      allow(Time).to receive(:now).and_return(Time.at(freeze_time))

      result = subject.sign_url(url)
      expect(result).to include("timestamp=#{freeze_time}")
    end

    it 'generates URL-safe base64 signature' do
      result = subject.sign_url(url)
      signature = result.match(/signature=([^&]+)/)[1]
      # URL-safe base64 should not contain + or /
      expect(signature).not_to include('+')
      expect(signature).not_to include('/')
    end

    it 'generates consistent signatures for same inputs' do
      freeze_time = Time.now.to_i
      allow(Time).to receive(:now).and_return(Time.at(freeze_time))

      result1 = subject.sign_url(url)
      result2 = subject.sign_url(url)
      expect(result1).to eq(result2)
    end

    it 'generates different signatures for different URLs' do
      freeze_time = Time.now.to_i
      allow(Time).to receive(:now).and_return(Time.at(freeze_time))

      result1 = subject.sign_url(url)
      result2 = subject.sign_url('https://example.com/different')

      sig1 = result1.match(/signature=([^&]+)/)[1]
      sig2 = result2.match(/signature=([^&]+)/)[1]
      expect(sig1).not_to eq(sig2)
    end

    it 'generates different signatures with different secrets' do
      freeze_time = Time.now.to_i
      allow(Time).to receive(:now).and_return(Time.at(freeze_time))

      service1 = described_class.new('secret1')
      service2 = described_class.new('secret2')

      result1 = service1.sign_url(url)
      result2 = service2.sign_url(url)

      sig1 = result1.match(/signature=([^&]+)/)[1]
      sig2 = result2.match(/signature=([^&]+)/)[1]
      expect(sig1).not_to eq(sig2)
    end
  end

  describe '#verify_signed_url' do
    # Note: sign_url and verify_signed_url use DIFFERENT signature formats
    # sign_url uses 21-byte truncation, verify_signed_url uses 28-char truncation
    # Tests must construct signatures manually for verification

    let(:timestamp) { Time.now.to_i.to_s }
    let(:canonical_url) { 'https://example.com/page' }

    def generate_verification_signature(ts, data)
      Base64.urlsafe_encode64(
        OpenSSL::HMAC.digest('SHA256', secret_key, "#{ts}::#{data}")
      )[0..27]
    end

    context 'with valid signature' do
      let(:signed_url) do
        signature = generate_verification_signature(timestamp, canonical_url)
        "#{canonical_url}?signature=#{signature}&timestamp=#{timestamp}"
      end

      it 'returns true for valid signature' do
        result, = subject.verify_signed_url(signed_url, [])
        expect(result).to be true
      end

      it 'returns canonical data' do
        _, canonical_data = subject.verify_signed_url(signed_url, [])
        expect(canonical_data).to eq(canonical_url)
      end
    end

    context 'with invalid signature' do
      let(:invalid_url) do
        "#{canonical_url}?signature=invalid_signature_here&timestamp=#{timestamp}"
      end

      it 'returns false for invalid signature' do
        result, = subject.verify_signed_url(invalid_url, [])
        expect(result).to be false
      end
    end

    context 'with allowed parameters' do
      let(:canonical_with_params) { "#{canonical_url}?user_id=123" }
      let(:signed_url_with_params) do
        signature = generate_verification_signature(timestamp, canonical_with_params)
        "#{canonical_url}?user_id=123&signature=#{signature}&timestamp=#{timestamp}"
      end

      it 'includes allowed params in canonical URL' do
        result, canonical_data = subject.verify_signed_url(signed_url_with_params, ['user_id'])
        expect(result).to be true
        expect(canonical_data).to eq(canonical_with_params)
      end
    end

    context 'with modified parameters' do
      let(:signed_url) do
        signature = generate_verification_signature(timestamp, canonical_url)
        "#{canonical_url}?signature=#{signature}&timestamp=#{timestamp}"
      end

      it 'returns false when timestamp is modified' do
        modified_url = signed_url.gsub(/timestamp=\d+/, 'timestamp=9999999999')
        result, = subject.verify_signed_url(modified_url, [])
        expect(result).to be false
      end
    end
  end

  describe '#verify_militant_url' do
    let(:timestamp) { Time.now.to_i.to_s }
    let(:user_id) { '12345' }
    let(:host) { 'test.example.com' }

    before do
      allow(Rails.application.secrets).to receive(:host).and_return(host)
    end

    def generate_verification_signature(ts, data)
      Base64.urlsafe_encode64(
        OpenSSL::HMAC.digest('SHA256', secret_key, "#{ts}::#{data}")
      )[0..27]
    end

    context 'with valid militant URL' do
      let(:canonical_data) { "https://#{host}/militant/update?participa_user_id=#{user_id}" }
      let(:signed_militant_url) do
        signature = generate_verification_signature(timestamp, canonical_data)
        "https://#{host}/militant/update?participa_user_id=#{user_id}&signature=#{signature}&timestamp=#{timestamp}"
      end

      it 'returns true for valid signature' do
        result, = subject.verify_militant_url(signed_militant_url)
        expect(result).to be true
      end

      it 'returns canonical data' do
        _, canonical_data = subject.verify_militant_url(signed_militant_url)
        expect(canonical_data).to include("participa_user_id=#{user_id}")
      end
    end

    context 'with exemption parameter' do
      let(:canonical_data) { "https://#{host}/militant/update?participa_user_id=#{user_id}&exemption=true" }
      let(:signed_url_with_exemption) do
        signature = generate_verification_signature(timestamp, canonical_data)
        "https://#{host}/militant/update?participa_user_id=#{user_id}&exemption=true&signature=#{signature}&timestamp=#{timestamp}"
      end

      it 'includes exemption in canonical data' do
        result, canonical = subject.verify_militant_url(signed_url_with_exemption)
        expect(result).to be true
        expect(canonical).to include('exemption=true')
      end
    end

    context 'with collaborate parameter' do
      let(:canonical_data) { "https://#{host}/militant/update?participa_user_id=#{user_id}&collaborate=yes" }
      let(:signed_url_with_collaborate) do
        signature = generate_verification_signature(timestamp, canonical_data)
        "https://#{host}/militant/update?participa_user_id=#{user_id}&collaborate=yes&signature=#{signature}&timestamp=#{timestamp}"
      end

      it 'includes collaborate in canonical data' do
        result, canonical = subject.verify_militant_url(signed_url_with_collaborate)
        expect(result).to be true
        expect(canonical).to include('collaborate=yes')
      end
    end

    context 'with both exemption and collaborate' do
      let(:canonical_data) { "https://#{host}/militant/update?participa_user_id=#{user_id}&exemption=true&collaborate=yes" }
      let(:signed_url_with_both) do
        signature = generate_verification_signature(timestamp, canonical_data)
        "https://#{host}/militant/update?participa_user_id=#{user_id}&exemption=true&collaborate=yes&signature=#{signature}&timestamp=#{timestamp}"
      end

      it 'includes both parameters in canonical data' do
        result, canonical = subject.verify_militant_url(signed_url_with_both)
        expect(result).to be true
        expect(canonical).to include('exemption=true')
        expect(canonical).to include('collaborate=yes')
      end
    end

    context 'with invalid signature' do
      let(:invalid_militant_url) do
        "https://#{host}/militant/update?participa_user_id=#{user_id}&signature=invalid&timestamp=#{timestamp}"
      end

      it 'returns false for invalid signature' do
        result, = subject.verify_militant_url(invalid_militant_url)
        expect(result).to be false
      end
    end

    context 'with userinfo in URL' do
      let(:canonical_data) { "https://user:pass@#{host}/militant/update?participa_user_id=#{user_id}" }
      let(:signed_url_with_userinfo) do
        signature = generate_verification_signature(timestamp, canonical_data)
        "https://user:pass@#{host}/militant/update?participa_user_id=#{user_id}&signature=#{signature}&timestamp=#{timestamp}"
      end

      it 'includes userinfo in canonical data' do
        result, canonical = subject.verify_militant_url(signed_url_with_userinfo)
        expect(result).to be true
        expect(canonical).to include('user:pass@')
      end
    end
  end

  describe 'edge cases' do
    it 'handles URLs without query parameters' do
      simple_url = 'https://example.com/page'
      result = subject.sign_url(simple_url)
      expect(result).to include('signature=')
      expect(result).to include('timestamp=')
    end

    it 'handles URLs with multiple existing parameters' do
      complex_url = 'https://example.com/page?a=1&b=2&c=3'
      result = subject.sign_url(complex_url)
      expect(result).to include('a=1')
      expect(result).to include('b=2')
      expect(result).to include('c=3')
    end

    it 'handles URLs with special characters' do
      special_url = 'https://example.com/page?name=Test%20User&email=test%40example.com'
      result = subject.sign_url(special_url)
      expect(result).to include('name=Test%20User')
    end

    it 'handles empty allowed_params array in verify_signed_url' do
      timestamp = Time.now.to_i.to_s
      canonical = 'https://example.com/page'
      sig = Base64.urlsafe_encode64(
        OpenSSL::HMAC.digest('SHA256', secret_key, "#{timestamp}::#{canonical}")
      )[0..27]
      url_to_verify = "#{canonical}?signature=#{sig}&timestamp=#{timestamp}"

      result, data = subject.verify_signed_url(url_to_verify, [])
      expect(result).to be true
      expect(data).to eq(canonical)
    end
  end

  describe 'backward compatibility alias' do
    it 'has minimal code footprint' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      line_count = file_content.lines.reject { |l| l.strip.empty? || l.strip.start_with?('#') }.count
      expect(line_count).to be <= 3
    end

    it 'documents backward compatibility purpose' do
      file_content = File.read(Rails.root.join('app/services/url_signature_service.rb'))
      expect(file_content).to match(/backward compatibility/i)
    end
  end
end
