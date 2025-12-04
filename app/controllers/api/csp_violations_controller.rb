# frozen_string_literal: true

# API::CspViolationsController - Content Security Policy Violation Reporting
#
# This endpoint receives and logs CSP violation reports sent automatically by browsers
# when content violates the Content Security Policy defined in config/initializers/secure_headers.rb
#
# SECURITY CONSIDERATIONS:
# - No authentication required (browsers send these automatically)
# - CSRF protection skipped (POST requests from browser CSP engine)
# - Input validation to prevent log injection attacks
# - Rate limiting via Rack::Attack to prevent abuse
#
# CSP Violation Report Format:
# {
#   "csp-report": {
#     "document-uri": "https://example.com/page",
#     "violated-directive": "script-src 'self'",
#     "blocked-uri": "https://evil.com/script.js",
#     "original-policy": "default-src 'self'; script-src 'self'",
#     "disposition": "report",
#     "status-code": 200
#   }
# }
class Api::CspViolationsController < ApplicationController
  # Skip CSRF verification - CSP reports are sent by browser's CSP engine
  skip_before_action :verify_authenticity_token

  # POST /api/csp-violations
  # Receives CSP violation reports from browsers
  def create
    violation_report = parse_csp_report

    return head :bad_request unless violation_report

    # Log violation for security monitoring
    log_csp_violation(violation_report)

    # Optionally send to monitoring service (Airbrake, Sentry, etc.)
    notify_monitoring_service(violation_report) if Rails.env.production?

    # Return 204 No Content (standard for CSP reporting)
    head :no_content
  rescue JSON::ParserError => e
    Rails.logger.warn("[CSP Violation] Invalid JSON format: #{e.message}")
    head :bad_request
  rescue StandardError => e
    Rails.logger.error("[CSP Violation] Unexpected error: #{e.message}")
    Airbrake.notify(e, component: 'CSP Violations API') if defined?(Airbrake)
    head :internal_server_error
  end

  private

  # Parse and validate CSP report from request body
  def parse_csp_report
    body = request.body.read
    return nil if body.blank?

    report = JSON.parse(body)

    # CSP reports are wrapped in a "csp-report" key
    csp_report = report['csp-report'] || report

    # Basic validation - must have required fields
    return nil unless csp_report['violated-directive']

    csp_report
  end

  # Log CSP violation with structured data
  def log_csp_violation(report)
    # Sanitize URIs to prevent log injection
    document_uri = sanitize_for_log(report['document-uri'])
    blocked_uri = sanitize_for_log(report['blocked-uri'])
    violated_directive = sanitize_for_log(report['violated-directive'])

    Rails.logger.warn(
      '[CSP Violation] ' \
      "Document: #{document_uri} | " \
      "Blocked: #{blocked_uri} | " \
      "Directive: #{violated_directive} | " \
      "IP: #{request.remote_ip} | " \
      "User Agent: #{sanitize_for_log(request.user_agent)}"
    )
  end

  # Send violation to monitoring service for alerting
  def notify_monitoring_service(report)
    return unless defined?(Airbrake)

    # Only notify on repeated violations or high-risk directives
    return unless critical_violation?(report)

    Airbrake.notify(
      "CSP Violation: #{report['violated-directive']}",
      parameters: {
        document_uri: report['document-uri'],
        blocked_uri: report['blocked-uri'],
        violated_directive: report['violated-directive'],
        disposition: report['disposition'],
        ip: request.remote_ip,
        user_agent: request.user_agent
      },
      component: 'Content Security Policy',
      action: 'csp_violation'
    )
  end

  # Check if violation is critical (indicates potential attack)
  def critical_violation?(report)
    violated = report['violated-directive'] || ''

    # Critical directives that may indicate attacks
    critical_directives = [
      'script-src',      # Script injection attempts
      'base-uri',        # Base tag hijacking
      'form-action',     # Form submission hijacking
      'frame-ancestors'  # Clickjacking attempts
    ]

    critical_directives.any? { |directive| violated.start_with?(directive) }
  end

  # Sanitize string for safe logging (prevent log injection)
  def sanitize_for_log(value)
    return 'N/A' if value.blank?

    # Remove newlines and control characters
    value.to_s
         .gsub(/[\r\n\t]/, ' ')
         .gsub(/[[:cntrl:]]/, '')
         .truncate(500) # Limit length to prevent log flooding
  end
end
