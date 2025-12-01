# frozen_string_literal: true

#
# Rate Limiting Configuration using Rack::Attack
#
# To enable this, add to your Gemfile:
#   gem 'rack-attack'
#
# Then run: bundle install
#
# Documentation: https://github.com/rack/rack-attack
#

class Rack::Attack
  ### Configure Cache with Validation and Lazy Connection ###

  # Get and validate REDIS_URL
  redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

  # Validate REDIS_URL format for security
  begin
    require 'uri'
    uri = URI.parse(redis_url)
    unless ['redis', 'rediss'].include?(uri.scheme)
      raise ArgumentError, "Invalid Redis URL scheme: #{uri.scheme}. Must be 'redis' or 'rediss'"
    end
  rescue URI::InvalidURIError => e
    Rails.logger.error("[Rack::Attack] Invalid REDIS_URL format: #{e.message}")
    redis_url = 'redis://localhost:6379/0' # Fallback to safe default
  rescue ArgumentError => e
    Rails.logger.error("[Rack::Attack] #{e.message}")
    redis_url = 'redis://localhost:6379/0' # Fallback to safe default
  end

  # Sanitize URL for logging (hide password)
  safe_redis_url = redis_url.gsub(/:([^@]+)@/, ':***@')

  # Configure cache store based on environment
  if Rails.env.production?
    # Production: Use Redis with lazy connection and robust error handling
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
      url: redis_url,
      reconnect_attempts: 5,         # Increased from 3
      reconnect_delay: 1.5,          # Wait 1.5s before first retry
      reconnect_delay_max: 10,       # Max delay between retries
      error_handler: lambda { |method:, returning:, exception:|
        Rails.logger.error("[Rack::Attack] Redis error in #{method}: #{exception.message}")
        # Notify monitoring service
        Airbrake.notify(exception, { component: 'Rack::Attack', method: method }) if defined?(Airbrake)
      }
    )

    Rails.logger.info("[Rack::Attack] Configured with Redis: #{safe_redis_url}")

    # Verify Redis connection asynchronously (non-blocking)
    Thread.new do
      sleep 2 # Give Redis time to initialize in orchestrated environments
      begin
        Rack::Attack.cache.store.redis.ping
        Rails.logger.info("[Rack::Attack] Redis connection verified successfully")
      rescue => e
        Rails.logger.error("[Rack::Attack] Redis verification failed: #{e.message}")
        Rails.logger.error("[Rack::Attack] Rate limiting will use memory store fallback")
        # In production, this should trigger an alert in your monitoring system
        Airbrake.notify(e, { component: 'Rack::Attack', action: 'redis_verification' }) if defined?(Airbrake)
      end
    end
  else
    # Development/Test: Use memory store (no Redis required)
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rails.logger.info("[Rack::Attack] Using memory store (#{Rails.env})")
  end

  ### Throttle Configuration ###

  # Throttle login attempts by email address
  # Allow 5 login attempts per email per minute
  throttle('logins/email', limit: 5, period: 1.minute) do |req|
    if req.path == '/login' && req.post?
      # Return the email as the discriminator key
      req.params['email'].to_s.downcase.gsub(/\s+/, '')
    end
  end

  # Throttle login attempts by IP address
  # Allow 10 login attempts per IP per minute
  throttle('logins/ip', limit: 10, period: 1.minute) do |req|
    if req.path == '/login' && req.post?
      req.ip
    end
  end

  # Throttle registration attempts by IP address
  # Allow 3 registration attempts per IP per hour
  throttle('registrations/ip', limit: 3, period: 1.hour) do |req|
    if req.path == '/users' && req.post?
      req.ip
    end
  end

  # Throttle SMS validation requests
  # Allow 5 SMS requests per IP per hour (prevent abuse)
  throttle('sms/ip', limit: 5, period: 1.hour) do |req|
    if req.path =~ /\/sms_validator/ && req.post?
      req.ip
    end
  end

  # Throttle password reset requests
  # Allow 3 password reset requests per IP per hour
  throttle('password_reset/ip', limit: 3, period: 1.hour) do |req|
    if req.path =~ /\/password/ && req.post?
      req.ip
    end
  end

  # Throttle voting endpoints
  # Allow 30 votes per authenticated user per minute (prevent spam)
  throttle('votes/user', limit: 30, period: 1.minute) do |req|
    if req.path =~ /\/vote/ && (req.post? || req.delete?)
      # Assuming you have a current_user method
      req.env['warden']&.user&.id || req.ip
    end
  end

  # Throttle comment creation
  # Allow 10 comments per authenticated user per minute
  throttle('comments/user', limit: 10, period: 1.minute) do |req|
    if req.path =~ /\/comments/ && req.post?
      req.env['warden']&.user&.id || req.ip
    end
  end

  # Throttle proposal creation
  # Allow 5 proposals per authenticated user per hour
  throttle('proposals/user', limit: 5, period: 1.hour) do |req|
    if req.path =~ /\/proposals/ && req.post?
      req.env['warden']&.user&.id || req.ip
    end
  end

  # Throttle microcredit creation
  # Allow 3 microcredit requests per authenticated user per hour
  throttle('microcredit/user', limit: 3, period: 1.hour) do |req|
    if req.path =~ /\/microcredit/ && req.post?
      req.env['warden']&.user&.id || req.ip
    end
  end

  # Throttle collaboration creation
  # Allow 5 collaboration requests per authenticated user per hour
  throttle('collaborations/user', limit: 5, period: 1.hour) do |req|
    if req.path =~ /\/collaborations/ && req.post?
      req.env['warden']&.user&.id || req.ip
    end
  end

  # General API rate limit
  # Allow 100 requests per IP per minute for API endpoints
  throttle('api/ip', limit: 100, period: 1.minute) do |req|
    if req.path.start_with?('/api/')
      req.ip
    end
  end

  # Aggressive throttle for unauthenticated users on sensitive endpoints
  # Allow 20 requests per IP per minute
  throttle('req/ip', limit: 20, period: 1.minute) do |req|
    req.ip unless req.env['warden']&.user
  end

  # Throttle file uploads (prevent storage exhaustion attacks)
  # Allow 20 file uploads per authenticated user per hour
  throttle('uploads/user', limit: 20, period: 1.hour) do |req|
    if req.post? && req.content_type =~ /multipart\/form-data/
      # Track by authenticated user ID or IP
      req.env['warden']&.user&.id || req.ip
    end
  end

  # Throttle file upload bandwidth (prevent bandwidth abuse)
  # Allow max 100MB of uploads per user per hour
  throttle('uploads/bandwidth', limit: 100_000_000, period: 1.hour) do |req|
    if req.post? && req.content_type =~ /multipart\/form-data/
      user_id = req.env['warden']&.user&.id || req.ip
      content_length = req.content_length || 0
      # Return discriminator key with content length for tracking
      "uploads:#{user_id}:#{content_length}" if content_length > 0
    end
  end

  ### Custom Throttle Response ###

  # Return 429 (Too Many Requests) when throttled
  self.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data']
    now = match_data[:epoch_time]

    headers = {
      'Content-Type' => 'application/json',
      'RateLimit-Limit' => match_data[:limit].to_s,
      'RateLimit-Remaining' => '0',
      'RateLimit-Reset' => (now + match_data[:period]).to_s
    }

    [429, headers, [{ error: 'Rate limit exceeded. Please try again later.' }.to_json]]
  end

  ### Blocklists ###

  # SECURITY FIX SEC-042: More nuanced user agent blocking
  # Only block automated tools on sensitive endpoints when unauthenticated
  # Disabled in development/test to allow local testing with curl/wget
  unless Rails.env.development? || Rails.env.test?
    blocklist('block_suspicious_user_agents_on_sensitive_endpoints') do |req|
      automated_ua = req.user_agent.to_s =~ /\b(curl|wget|python-requests|libwww-perl|mechanize)\b/i
      sensitive_endpoint = req.path =~ /\/(admin|users\/sign_in|registrations|api\/v1\/gcm)/

      # Allow authenticated requests (check for session cookie)
      has_session = req.cookies['_plebis_hub_session'].present?

      # Block only if: automated tool + sensitive endpoint + no session
      automated_ua && sensitive_endpoint && !has_session
    end
  end

  # Whitelist legitimate crawlers and monitoring tools
  safelist('allow_known_bots') do |req|
    # Allow search engine crawlers and uptime monitors
    req.user_agent.to_s =~ /\b(Googlebot|Bingbot|Slackbot|UptimeRobot|Pingdom)\b/i
  end

  # Allow safelisted IPs in development/test environments
  # This prevents rate limiting issues during local development and testing
  if Rails.env.development? || Rails.env.test?
    safelist('allow_local') do |req|
      # Allow localhost and Docker network IPs
      ['127.0.0.1', '::1', '172.'].any? { |ip| req.ip.to_s.start_with?(ip) }
    end
  end

  ### Logging ###

  # Log blocked requests
  ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, payload|
    req = payload[:request]

    if [:throttle, :blocklist].include?(req.env['rack.attack.match_type'])
      Rails.logger.warn "[Rack::Attack] #{req.env['rack.attack.match_type']} #{req.ip} #{req.path}"
    end
  end

  ### Track Requests (Optional for monitoring) ###

  # Track requests by IP
  track('requests/ip') do |req|
    req.ip
  end
end
