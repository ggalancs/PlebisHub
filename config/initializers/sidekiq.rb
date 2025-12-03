# frozen_string_literal: true

# Configure Sidekiq Redis connection
redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  # Configure unique jobs for server
  require 'sidekiq-unique-jobs'
  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }

  # Configure unique jobs for client
  require 'sidekiq-unique-jobs'
  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end

# Authorization for Sidekiq Web UI
# https://github.com/sidekiq/sidekiq/wiki/Monitoring#rails-http-basic-auth-from-routes
class CanAccessSidekiq
  def matches?(request)
    user = request.env['warden'].user
    return false if user.blank?
    Ability.new(user).can? :manage, Sidekiq::Web
  end
end
