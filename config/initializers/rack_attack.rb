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
  ### Configure Cache ###

  # Configure Redis connection with fallback to memory store
  redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

  begin
    if Rails.env.production?
      # Production: Use Redis for distributed rate limiting
      Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
        url: redis_url,
        reconnect_attempts: 3,
        error_handler: lambda { |method:, returning:, exception:|
          Rails.logger.error("[Rack::Attack] Redis error: #{exception.message}")
          Rails.logger.error("[Rack::Attack] Falling back to memory store")
        }
      )
      Rails.logger.info("[Rack::Attack] Configured with Redis cache store")
    else
      # Development/Test: Use memory store
      Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
      Rails.logger.info("[Rack::Attack] Configured with memory store (development)")
    end
  rescue => e
    # Fallback to memory store if Redis connection fails
    Rails.logger.warn("[Rack::Attack] Failed to connect to Redis: #{e.message}")
    Rails.logger.warn("[Rack::Attack] Falling back to memory store")
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
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

  # Block suspicious requests
  # Block requests with suspicious user agents
  blocklist('block_bad_user_agents') do |req|
    # Block known bad user agents
    req.user_agent =~ /curl|wget|python-requests/i
  end

  # Allow safelisted IPs (optional)
  # safelist('allow_local') do |req|
  #   # Allow localhost
  #   req.ip == '127.0.0.1' || req.ip == '::1'
  # end

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
