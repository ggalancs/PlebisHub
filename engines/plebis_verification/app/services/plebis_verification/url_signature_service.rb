# frozen_string_literal: true

require 'base64'
require 'openssl'

module PlebisVerification
  # Service object to handle URL signing and verification with HMAC
  # Used to secure form URLs and API callbacks
  # Extracts signature logic from PageController and MilitantController
  class UrlSignatureService
    def initialize(secret_key = nil)
      # RAILS 7.2 FIX: Use safe navigation to handle nil forms in test environment
      @secret = secret_key || Rails.application.secrets.forms&.[]('secret')
    end

    # Sign a URL with timestamp and HMAC signature
    # @param url [String] The URL to sign
    # @return [String] The signed URL with signature and timestamp parameters
    def sign_url(url)
      timestamp = Time.now.to_i
      signature = generate_signature(timestamp, url)
      "#{url}&signature=#{signature}&timestamp=#{timestamp}"
    end

    # Verify a signed URL's authenticity
    # @param full_url [String] The complete URL to verify
    # @param allowed_params [Array<String>] List of allowed parameters in the signature
    # @return [Array<Boolean, String>] [verification_result, canonical_data]
    def verify_signed_url(full_url, allowed_params = [])
      uri = URI(full_url)
      params_hash = URI.decode_www_form(uri.query).to_h

      timestamp = params_hash['timestamp']
      received_signature = params_hash['signature']

      # Build canonical URL for verification
      canonical_data = build_canonical_url(uri, params_hash, allowed_params)

      # Generate expected signature
      expected_signature = generate_signature_for_verification(timestamp, canonical_data)

      [expected_signature == received_signature, canonical_data]
    end

    # Verify a signed URL specifically for militant updates
    # Includes specific parameters: participa_user_id, exemption, collaborate
    def verify_militant_url(full_url)
      host = Rails.application.secrets.host
      uri = URI(full_url)
      params_hash = URI.decode_www_form(uri.query).to_h

      timestamp = params_hash['timestamp']
      current_user_id = params_hash['participa_user_id']

      # Build canonical URL with specific parameters
      data = "#{uri.scheme}://"
      data += "#{uri.userinfo}@" if uri.userinfo.present?
      data += host.to_s
      data += uri.path.to_s
      data += "?participa_user_id=#{current_user_id}"
      data += "&exemption=#{params_hash['exemption']}" if params_hash['exemption'].present?
      data += "&collaborate=#{params_hash['collaborate']}" if params_hash['collaborate'].present?

      expected_signature = generate_signature_for_verification(timestamp, data)

      [expected_signature == params_hash['signature'], data]
    end

    private

    def generate_signature(timestamp, url)
      Base64.urlsafe_encode64(
        OpenSSL::HMAC.digest('SHA256', @secret, "#{timestamp}::#{url}")[0..20]
      )
    end

    def generate_signature_for_verification(timestamp, data)
      Base64.urlsafe_encode64(
        OpenSSL::HMAC.digest('SHA256', @secret, "#{timestamp}::#{data}")
      )[0..27]
    end

    def build_canonical_url(uri, params_hash, allowed_params)
      data = "#{uri.scheme}://#{uri.host}#{uri.path}"

      if allowed_params.any?
        query_params = allowed_params.select { |param| params_hash[param].present? }
                                     .map { |param| "#{param}=#{params_hash[param]}" }
                                     .join('&')
        data += "?#{query_params}" if query_params.present?
      end

      data
    end
  end
end
