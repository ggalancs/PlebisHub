# frozen_string_literal: true

# Health Check Endpoint for Docker
# Allows Docker healthcheck and load balancers to verify app status
Rails.application.routes.prepend do
  get '/health', to: proc { |_env|
    begin
      # Check database connection
      ActiveRecord::Base.connection.execute('SELECT 1')

      # Check Redis connection (if configured)
      if defined?(Resque)
        Resque.redis.ping
      end

      [200, { 'Content-Type' => 'text/plain' }, ['OK']]
    rescue => e
      Rails.logger.error "Health check failed: #{e.message}"
      [503, { 'Content-Type' => 'text/plain' }, ['Service Unavailable']]
    end
  }
end
