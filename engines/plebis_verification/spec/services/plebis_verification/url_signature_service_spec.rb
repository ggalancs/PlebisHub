# frozen_string_literal: true

require 'rails_helper'
require 'base64'
require 'openssl'

module PlebisVerification
  RSpec.describe UrlSignatureService, type: :service do
    let(:secret_key) { 'test_secret_key_12345' }
    let(:url) { 'https://example.com/page?param=value' }

    subject { described_class.new(secret_key) }

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

      it 'preserves original URL and parameters' do
        result = subject.sign_url(url)
        expect(result).to start_with(url)
        expect(result).to include('param=value')
      end

      it 'appends parameters with ampersand' do
        result = subject.sign_url(url)
        expect(result).to match(/&signature=/)
        expect(result).to match(/&timestamp=/)
      end

      it 'generates different signatures for different timestamps' do
        result1 = subject.sign_url(url)
        sleep(1)
        result2 = subject.sign_url(url)

        expect(result1).not_to eq(result2)
      end

      it 'uses current timestamp' do
        freeze_time = Time.now.to_i
        allow(Time).to receive(:now).and_return(double(to_i: freeze_time))

        result = subject.sign_url(url)
        expect(result).to include("timestamp=#{freeze_time}")
      end

      it 'generates URL-safe base64 signature' do
        result = subject.sign_url(url)
        signature = result.match(/signature=([^&]+)/)[1]
        expect(signature).not_to include('+', '/', '=')
      end
    end

    describe '#verify_signed_url' do
      let(:signed_url) { subject.sign_url(url) }

      context 'with valid signature' do
        it 'returns true for valid signature' do
          result, _data = subject.verify_signed_url(signed_url)
          expect(result).to be true
        end

        it 'returns canonical data' do
          result, data = subject.verify_signed_url(signed_url)
          expect(data).to be_a(String)
          expect(data).to include('example.com')
        end
      end

      context 'with tampered signature' do
        it 'returns false for modified signature' do
          tampered_url = signed_url.sub(/signature=[^&]+/, 'signature=invalid')
          result, _data = subject.verify_signed_url(tampered_url)
          expect(result).to be false
        end

        it 'returns false for modified parameters' do
          tampered_url = signed_url.sub('param=value', 'param=changed')
          result, _data = subject.verify_signed_url(tampered_url)
          expect(result).to be false
        end
      end

      context 'with allowed parameters' do
        let(:url_with_params) { 'https://example.com/page?user_id=123&token=abc' }
        let(:signed_url) { subject.sign_url(url_with_params) }

        it 'includes allowed parameters in verification' do
          result, data = subject.verify_signed_url(signed_url, %w[user_id])
          expect(data).to include('user_id=123')
        end

        it 'excludes non-allowed parameters' do
          result, data = subject.verify_signed_url(signed_url, %w[user_id])
          expect(data).not_to include('token=')
        end

        it 'verifies with multiple allowed parameters' do
          result, data = subject.verify_signed_url(signed_url, %w[user_id token])
          expect(data).to include('user_id=123')
          expect(data).to include('token=abc')
        end
      end

      context 'with empty allowed parameters' do
        it 'excludes all parameters from canonical URL' do
          result, data = subject.verify_signed_url(signed_url, [])
          expect(data).not_to include('param=')
          expect(data).to match(%r{^https://example\.com/page$})
        end
      end
    end

    describe '#verify_militant_url' do
      let(:host) { 'example.com' }
      let(:militant_url) { 'https://example.com/militant?participa_user_id=123' }
      let(:signed_militant_url) do
        timestamp = Time.now.to_i
        data = "https://#{host}/militant?participa_user_id=123"
        signature = Base64.urlsafe_encode64(
          OpenSSL::HMAC.digest('SHA256', secret_key, "#{timestamp}::#{data}")
        )[0..27]
        "#{militant_url}&signature=#{signature}&timestamp=#{timestamp}"
      end

      before do
        allow(Rails.application.secrets).to receive(:host).and_return(host)
      end

      it 'verifies valid militant URL' do
        result, _data = subject.verify_militant_url(signed_militant_url)
        expect(result).to be true
      end

      it 'includes participa_user_id in canonical data' do
        result, data = subject.verify_militant_url(signed_militant_url)
        expect(data).to include('participa_user_id=123')
      end

      context 'with exemption parameter' do
        let(:militant_url) { 'https://example.com/militant?participa_user_id=123&exemption=true' }
        let(:signed_militant_url) do
          timestamp = Time.now.to_i
          data = "https://#{host}/militant?participa_user_id=123&exemption=true"
          signature = Base64.urlsafe_encode64(
            OpenSSL::HMAC.digest('SHA256', secret_key, "#{timestamp}::#{data}")
          )[0..27]
          "#{militant_url}&signature=#{signature}&timestamp=#{timestamp}"
        end

        it 'includes exemption parameter' do
          result, data = subject.verify_militant_url(signed_militant_url)
          expect(data).to include('exemption=true')
        end
      end

      context 'with collaborate parameter' do
        let(:militant_url) { 'https://example.com/militant?participa_user_id=123&collaborate=yes' }
        let(:signed_militant_url) do
          timestamp = Time.now.to_i
          data = "https://#{host}/militant?participa_user_id=123&collaborate=yes"
          signature = Base64.urlsafe_encode64(
            OpenSSL::HMAC.digest('SHA256', secret_key, "#{timestamp}::#{data}")
          )[0..27]
          "#{militant_url}&signature=#{signature}&timestamp=#{timestamp}"
        end

        it 'includes collaborate parameter' do
          result, data = subject.verify_militant_url(signed_militant_url)
          expect(data).to include('collaborate=yes')
        end
      end

      context 'with both exemption and collaborate parameters' do
        let(:militant_url) { 'https://example.com/militant?participa_user_id=123&exemption=false&collaborate=yes' }
        let(:signed_militant_url) do
          timestamp = Time.now.to_i
          data = "https://#{host}/militant?participa_user_id=123&exemption=false&collaborate=yes"
          signature = Base64.urlsafe_encode64(
            OpenSSL::HMAC.digest('SHA256', secret_key, "#{timestamp}::#{data}")
          )[0..27]
          "#{militant_url}&signature=#{signature}&timestamp=#{timestamp}"
        end

        it 'includes both parameters' do
          result, data = subject.verify_militant_url(signed_militant_url)
          expect(data).to include('exemption=false')
          expect(data).to include('collaborate=yes')
        end
      end

      it 'uses configured host from Rails secrets' do
        result, data = subject.verify_militant_url(signed_militant_url)
        expect(data).to include(host)
      end

      it 'returns false for tampered militant URL' do
        tampered_url = signed_militant_url.sub('participa_user_id=123', 'participa_user_id=456')
        result, _data = subject.verify_militant_url(tampered_url)
        expect(result).to be false
      end
    end

    describe '#generate_signature' do
      let(:timestamp) { Time.now.to_i }

      it 'generates consistent signature for same input' do
        sig1 = subject.send(:generate_signature, timestamp, url)
        sig2 = subject.send(:generate_signature, timestamp, url)
        expect(sig1).to eq(sig2)
      end

      it 'generates different signatures for different URLs' do
        sig1 = subject.send(:generate_signature, timestamp, url)
        sig2 = subject.send(:generate_signature, timestamp, 'https://different.com')
        expect(sig1).not_to eq(sig2)
      end

      it 'generates different signatures for different timestamps' do
        sig1 = subject.send(:generate_signature, timestamp, url)
        sig2 = subject.send(:generate_signature, timestamp + 1, url)
        expect(sig1).not_to eq(sig2)
      end

      it 'uses HMAC SHA256' do
        expected = Base64.urlsafe_encode64(
          OpenSSL::HMAC.digest('SHA256', secret_key, "#{timestamp}::#{url}")[0..20]
        )
        result = subject.send(:generate_signature, timestamp, url)
        expect(result).to eq(expected)
      end

      it 'truncates to 21 bytes' do
        signature = subject.send(:generate_signature, timestamp, url)
        decoded = Base64.urlsafe_decode64(signature)
        expect(decoded.length).to eq(21)
      end
    end

    describe '#generate_signature_for_verification' do
      let(:timestamp) { Time.now.to_i }
      let(:data) { 'https://example.com/page' }

      it 'generates consistent signature for same input' do
        sig1 = subject.send(:generate_signature_for_verification, timestamp, data)
        sig2 = subject.send(:generate_signature_for_verification, timestamp, data)
        expect(sig1).to eq(sig2)
      end

      it 'uses HMAC SHA256' do
        expected = Base64.urlsafe_encode64(
          OpenSSL::HMAC.digest('SHA256', secret_key, "#{timestamp}::#{data}")
        )[0..27]
        result = subject.send(:generate_signature_for_verification, timestamp, data)
        expect(result).to eq(expected)
      end

      it 'truncates to 28 characters' do
        signature = subject.send(:generate_signature_for_verification, timestamp, data)
        expect(signature.length).to eq(28)
      end
    end

    describe '#build_canonical_url' do
      let(:uri) { URI('https://example.com/page?param1=value1&param2=value2&signature=sig&timestamp=123') }
      let(:params_hash) do
        {
          'param1' => 'value1',
          'param2' => 'value2',
          'signature' => 'sig',
          'timestamp' => '123'
        }
      end

      it 'builds canonical URL without parameters when none allowed' do
        result = subject.send(:build_canonical_url, uri, params_hash, [])
        expect(result).to eq('https://example.com/page')
      end

      it 'includes allowed parameters' do
        result = subject.send(:build_canonical_url, uri, params_hash, %w[param1])
        expect(result).to include('param1=value1')
      end

      it 'excludes non-allowed parameters' do
        result = subject.send(:build_canonical_url, uri, params_hash, %w[param1])
        expect(result).not_to include('param2=')
      end

      it 'includes multiple allowed parameters' do
        result = subject.send(:build_canonical_url, uri, params_hash, %w[param1 param2])
        expect(result).to include('param1=value1')
        expect(result).to include('param2=value2')
      end

      it 'skips empty parameters' do
        params_with_empty = params_hash.merge('empty' => '')
        result = subject.send(:build_canonical_url, uri, params_with_empty, %w[empty])
        expect(result).to eq('https://example.com/page')
      end

      it 'joins parameters with ampersand' do
        result = subject.send(:build_canonical_url, uri, params_hash, %w[param1 param2])
        expect(result).to match(/param1=value1&param2=value2/)
      end
    end

    describe 'integration scenarios' do
      context 'complete signing and verification flow' do
        it 'signs and verifies URL successfully' do
          signed = subject.sign_url(url)
          verified, _data = subject.verify_signed_url(signed)
          expect(verified).to be true
        end

        it 'handles complex URLs with multiple parameters' do
          complex_url = 'https://example.com/api/endpoint?id=123&type=test&filter=active'
          signed = subject.sign_url(complex_url)
          verified, _data = subject.verify_signed_url(signed)
          expect(verified).to be true
        end

        it 'preserves URL parameters through signing' do
          complex_url = 'https://example.com/page?user=john&id=456'
          signed = subject.sign_url(complex_url)
          expect(signed).to include('user=john')
          expect(signed).to include('id=456')
        end
      end

      context 'security scenarios' do
        it 'detects URL tampering' do
          signed = subject.sign_url(url)
          tampered = signed.gsub('param=value', 'param=hacked')
          verified, _data = subject.verify_signed_url(tampered)
          expect(verified).to be false
        end

        it 'detects signature tampering' do
          signed = subject.sign_url(url)
          tampered = signed.sub(/signature=[^&]+/, 'signature=fakesignature123')
          verified, _data = subject.verify_signed_url(tampered)
          expect(verified).to be false
        end

        it 'detects timestamp tampering' do
          signed = subject.sign_url(url)
          tampered = signed.sub(/timestamp=\d+/, 'timestamp=9999999999')
          verified, _data = subject.verify_signed_url(tampered)
          expect(verified).to be false
        end
      end

      context 'with different secret keys' do
        it 'fails verification with different secret' do
          signed = subject.sign_url(url)
          other_service = described_class.new('different_secret')
          verified, _data = other_service.verify_signed_url(signed)
          expect(verified).to be false
        end

        it 'succeeds with same secret key' do
          service1 = described_class.new('shared_secret')
          service2 = described_class.new('shared_secret')

          signed = service1.sign_url(url)
          verified, _data = service2.verify_signed_url(signed)
          expect(verified).to be true
        end
      end
    end

    describe 'edge cases' do
      it 'handles URLs with existing query parameters' do
        url_with_params = 'https://example.com/page?existing=param'
        signed = subject.sign_url(url_with_params)
        expect(signed).to include('existing=param')
        expect(signed).to include('signature=')
      end

      it 'handles URLs without query parameters' do
        simple_url = 'https://example.com/page'
        signed = subject.sign_url(simple_url)
        expect(signed).to match(/\?signature=/)
      end

      it 'handles URLs with fragments' do
        url_with_fragment = 'https://example.com/page#section'
        expect { subject.sign_url(url_with_fragment) }.not_to raise_error
      end

      it 'handles special characters in parameters' do
        special_url = 'https://example.com/page?name=John+Doe&email=test%40example.com'
        signed = subject.sign_url(special_url)
        verified, _data = subject.verify_signed_url(signed)
        expect(verified).to be true
      end
    end
  end
end
