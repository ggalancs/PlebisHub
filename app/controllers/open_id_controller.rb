# frozen_string_literal: true

require 'pathname'
require 'openid'
require 'openid/consumer/discovery'
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'

# DEPRECATION NOTICE: OpenID 2.0 Authentication Provider
# OpenID 2.0 was deprecated by the OpenID Foundation in February 2014.
# This implementation is maintained for legacy compatibility only.
#
# SECURITY RECOMMENDATIONS:
# 1. Migrate consuming applications to OAuth 2.0 / OpenID Connect (OIDC)
# 2. Monitor usage logs for active consumers
# 3. Set sunset date for OpenID 2.0 support
# 4. Notify users before deprecation
#
# Reference: https://openid.net/2014/02/26/the-openid-foundation-launches-the-openid-connect-standard/

# OpenIdController - OpenID 2.0 Authentication Provider
#
# SECURITY FIXES IMPLEMENTED:
# - Added frozen_string_literal
# - Added comprehensive error handling
# - Added security logging for authentication events
# - Replaced deprecated render :text
# - Added documentation
# - Enhanced CSRF protection documentation
#
# This controller implements an OpenID 2.0 identity provider allowing users
# to authenticate with external services using their application credentials.
class OpenIdController < ApplicationController
  include OpenID::Server
  layout nil

  SERVER_APPROVALS = [].freeze

  # SECURITY NOTE: CSRF protection disabled only for create action
  # This is required for OpenID protocol which doesn't support CSRF tokens
  # The OpenID protocol itself provides protection via signed requests
  protect_from_forgery except: :create
  before_action :authenticate_user!, except: [:create, :discover, :user, :xrds]

  # OpenID discovery endpoint
  def discover
    types = [
      OpenID::OPENID_IDP_2_0_TYPE,
      OpenID::OPENID_2_0_TYPE
    ]

    render_xrds(types)
  rescue StandardError => e
    log_error('openid_discover_error', e)
    head :internal_server_error
  end

  # Main OpenID authentication endpoint
  def create
    oidreq = server.decode_request(params)
    oidresp = process_openid_request(oidreq)
    render_response(oidresp)
  rescue ProtocolError => e
    log_error('openid_protocol_error', e)
    render plain: e.to_s, status: :internal_server_error
  rescue StandardError => e
    log_error('openid_create_error', e)
    render plain: 'OpenID authentication error', status: :internal_server_error
  end

  # Alternative OpenID endpoint
  def index
    oidreq = server.decode_request(params)
    oidresp = process_openid_request(oidreq)
    render_response(oidresp)
  rescue ProtocolError => e
    log_error('openid_protocol_error', e)
    render plain: e.to_s, status: :internal_server_error
  rescue StandardError => e
    log_error('openid_index_error', e)
    render plain: 'OpenID authentication error', status: :internal_server_error
  end

  # XRDS discovery document
  def xrds
    types = [
      OpenID::OPENID_2_0_TYPE,
      OpenID::OPENID_1_0_TYPE,
      OpenID::SREG_URI
    ]

    render_xrds(types)
  rescue StandardError => e
    log_error('openid_xrds_error', e)
    head :internal_server_error
  end

  # User identity page with XRDS discovery
  def user
    # Yadis content-negotiation: return xrds if requested
    accept = request.env['HTTP_ACCEPT']

    if accept&.include?('application/xrds+xml')
      xrds
      return
    end

    # Content negotiation failed, render user identity page
    identity_page = <<~HTML
      <html><head>
      <meta http-equiv="X-XRDS-Location" content="#{open_id_xrds_url}" />
      <link rel="openid.server" href="#{open_id_create_url}" />
      </head><body></body></html>
    HTML

    response.headers['X-XRDS-Location'] = open_id_xrds_url
    render plain: identity_page
  rescue StandardError => e
    log_error('openid_user_error', e)
    head :internal_server_error
  end

  protected

  def process_openid_request(oidreq)
    unless oidreq
      return OpenID::Server::WebResponse.new(200, {}, 'This is an OpenID server endpoint.')
    end

    return handle_check_id_request(oidreq) if oidreq.kind_of?(CheckIDRequest)

    server.handle_request(oidreq)
  end

  def handle_check_id_request(oidreq)
    identity = oidreq.identity

    if oidreq.id_select
      if oidreq.immediate
        log_security_event('openid_immediate_request_denied')
        return oidreq.answer(false)
      elsif current_user.nil?
        log_security_event('openid_unauthenticated_request')
        return nil  # Will trigger redirect in create/index
      else
        identity = url_for_user
      end
    end

    if is_authorized(identity, oidreq.trust_root)
      log_security_event('openid_authentication_approved',
        user_id: current_user&.id,
        trust_root: oidreq.trust_root
      )

      oidresp = oidreq.answer(true, nil, identity)
      add_sreg(oidreq, oidresp)
      add_pape(oidreq, oidresp)
      oidresp
    else
      log_security_event('openid_authentication_denied',
        identity: identity,
        trust_root: oidreq.trust_root
      )
      oidreq.answer(false, open_id_create_url)
    end
  end

  def url_for_user
    open_id_user_url current_user.id
  end

  def server
    @server ||= begin
      dir = Rails.root.join('db', 'openid-store')
      store = OpenID::Store::Filesystem.new(dir)
      Server.new(store, open_id_create_url)
    end
  end

  def approved(trust_root)
    true
    # Could implement trust_root whitelist: SERVER_APPROVALS.member?(trust_root)
  end

  def is_authorized(identity_url, trust_root)
    current_user && (identity_url == url_for_user) && approved(trust_root)
  end

  def render_xrds(types)
    type_str = types.map { |uri| "<Type>#{uri}</Type>" }.join("\n      ")

    yadis = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <xrds:XRDS
          xmlns:xrds="xri://$xrds"
          xmlns="xri://$xrd*($v*2.0)">
        <XRD>
          <Service priority="0">
            #{type_str}
            <URI>#{open_id_create_url}</URI>
          </Service>
        </XRD>
      </xrds:XRDS>
    XML

    render plain: yadis, content_type: 'application/xrds+xml'
  end

  def add_sreg(oidreq, oidresp)
    sregreq = OpenID::SReg::Request.from_openid_request(oidreq)
    return if sregreq.nil?

    # SECURITY FIX (SEC-018): Only provide basic identity fields, not sensitive PII
    available_data = {
      'email' => current_user.email,
      'fullname' => current_user.full_name,
      'nickname' => current_user.first_name,
      'first_name' => current_user.first_name,
      'last_name' => current_user.last_name
      # REMOVED: dob, guid (document_vatid), address, phone - too sensitive
    }

    # Only return fields that were actually requested
    requested_fields = (sregreq.required.to_a + sregreq.optional.to_a).map(&:to_s)
    filtered_data = available_data.select { |k, _| requested_fields.include?(k) }

    # Log PII disclosure for audit
    Rails.logger.warn({
      event: 'openid_pii_disclosure',
      user_id: current_user.id,
      trust_root: oidreq.trust_root,
      disclosed_fields: filtered_data.keys,
      timestamp: Time.current.iso8601
    }.to_json)

    sregresp = OpenID::SReg::Response.extract_response(sregreq, filtered_data)
    oidresp.add_extension(sregresp)
  end

  def add_pape(oidreq, oidresp)
    papereq = OpenID::PAPE::Request.from_openid_request(oidreq)
    return if papereq.nil?

    paperesp = OpenID::PAPE::Response.new
    paperesp.nist_auth_level = 0
    oidresp.add_extension(paperesp)
  end

  def render_response(oidresp)
    return redirect_to root_path, notice: I18n.t('devise.failure.unauthenticated') if oidresp.nil?

    signed_response = server.signatory.sign(oidresp) if oidresp.needs_signing
    web_response = server.encode_response(oidresp)

    case web_response.code
    when HTTP_OK
      render plain: web_response.body, status: :ok
    when HTTP_REDIRECT
      redirect_to web_response.headers['location'], allow_other_host: true
    else
      render plain: web_response.body, status: :bad_request
    end
  end

  # SECURITY LOGGING
  def log_security_event(event_type, details = {})
    Rails.logger.info({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: 'open_id',
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
      controller: 'open_id',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
