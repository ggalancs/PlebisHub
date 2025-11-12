# frozen_string_literal: true

#
# Secure Headers Configuration
#
# This configuration integrates with the CSP headers defined in:
#   app/frontend/config/security-headers.ts (for Vite dev server)
#
# Documentation: https://github.com/github/secure_headers
#

SecureHeaders::Configuration.default do |config|
  # ========================================
  # COOKIES CONFIGURATION
  # ========================================

  config.cookies = {
    secure: Rails.env.production?,  # Mark all cookies as "Secure" in production (HTTPS only)
    httponly: true,                  # Mark all cookies as "HttpOnly" (no JavaScript access)
    samesite: {
      lax: true                      # Mark all cookies as SameSite=Lax (CSRF protection)
    }
  }

  # ========================================
  # CONTENT SECURITY POLICY (CSP)
  # ========================================

  # Build trusted sources list (preserve existing logic)
  trusted_src = ["'self'"]

  # Add forms domain if present
  trusted_src.push Rails.application.secrets.forms['domain'] if Rails.application.secrets.forms.present?

  # Add secure sites
  Rails.application.secrets[:secure_sites].each do |site|
    trusted_src.push site
  end if Rails.application.secrets[:secure_sites].present?

  # Add agora servers
  if Rails.application.secrets.agora.present? && Rails.application.secrets.agora["servers"].present?
    Rails.application.secrets.agora["servers"].each do |id, server|
      trusted_src.push server['url'].gsub('https://', '').gsub('http://','').gsub('/','')
    end
  end

  trusted_src.uniq!

  config.csp = {
    # Enforcement mode (report-only in development)
    report_only: Rails.env.development?,

    # CSP violation reporting endpoint (uncomment to enable)
    # report_uri: %w[/api/csp-violations],

    # Preserve schemes
    preserve_schemes: true,

    # CSP Directives
    default_src: %w['self' data:],

    script_src: if Rails.env.development?
      # Development: Allow unsafe-inline and unsafe-eval for HMR
      (trusted_src + ["'unsafe-eval'"]).uniq
    else
      # Production: Strict policy
      trusted_src
    end,

    style_src: (trusted_src + ["'unsafe-inline'"]).uniq, # unsafe-inline needed for Tailwind/inline styles

    img_src: %w['self' data: blob: https:],

    font_src: %w['self' data: https://fonts.gstatic.com],

    connect_src: if Rails.env.development?
      # Development: Allow WebSocket for HMR
      (trusted_src + %w[ws://localhost:* http://localhost:* wss://localhost:*]).uniq
    else
      # Production: Only trusted sources
      trusted_src
    end,

    media_src: %w['self' blob:],

    object_src: %w['none'],

    frame_src: trusted_src,

    base_uri: %w['self'],

    form_action: (trusted_src + %w[github.com]).uniq, # Allow GitHub OAuth

    frame_ancestors: %w['none'], # Prevent clickjacking

    # Upgrade insecure requests (HTTP -> HTTPS) in production
    upgrade_insecure_requests: Rails.env.production?,
  }

  # ========================================
  # ADDITIONAL SECURITY HEADERS
  # ========================================

  # X-Content-Type-Options
  # Prevents MIME type sniffing
  config.x_content_type_options = 'nosniff'

  # X-XSS-Protection
  # Legacy XSS protection (mostly superseded by CSP)
  config.x_xss_protection = '1; mode=block'

  # X-Frame-Options
  # Prevent clickjacking (SAMEORIGIN allows framing from same origin)
  config.x_frame_options = 'SAMEORIGIN'

  # X-Download-Options
  # Prevent Internet Explorer from executing downloads in site's context
  config.x_download_options = 'noopen'

  # X-Permitted-Cross-Domain-Policies
  # Restrict Adobe Flash and PDF cross-domain requests
  config.x_permitted_cross_domain_policies = 'none'

  # Referrer-Policy
  # Control referrer information
  config.referrer_policy = 'strict-origin-when-cross-origin'

  # Clear-Site-Data
  # Clear browser data on logout (storage only, not cookies to preserve login on mobile)
  config.clear_site_data = %w[storage]

  # ========================================
  # HSTS (HTTP Strict Transport Security)
  # ========================================

  if Rails.env.production?
    # Production: Enforce HTTPS for 1 year
    config.hsts = "max-age=#{1.year.to_i}; includeSubDomains; preload"
  else
    # Development: Don't enforce HTTPS
    config.hsts = "max-age=0"
  end

  # ========================================
  # EXPECT-CT (Certificate Transparency)
  # ========================================

  if Rails.env.production?
    config.expect_ct = {
      max_age: 86_400, # 24 hours
      enforce: true,
    }
  else
    config.expect_ct = SecureHeaders::OPT_OUT
  end
end

# ========================================
# CUSTOM CONFIGURATIONS FOR SPECIFIC CONTROLLERS
# ========================================

# Example: Disable CSP for API endpoints
# SecureHeaders::Configuration.override(:api) do |config|
#   config.csp = SecureHeaders::OPT_OUT
# end
#
# Usage in controller:
# class ApiController < ApplicationController
#   before_action do
#     use_secure_headers_override(:api)
#   end
# end
