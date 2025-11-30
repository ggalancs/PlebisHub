# frozen_string_literal: true

# Health check controller for Docker/Kubernetes liveness and readiness probes
# Used by: Dockerfile HEALTHCHECK, docker-compose.yml, load balancers
class HealthController < ApplicationController
  # Skip all authentication and security checks for health endpoint
  skip_before_action :verify_authenticity_token, raise: false
  skip_before_action :authenticate_user!, raise: false

  # GET /health
  # Returns 200 OK if application is healthy
  def show
    checks = {
      status: 'ok',
      timestamp: Time.current.iso8601,
      version: Rails.application.class.module_parent_name,
      rails_version: Rails.version,
      ruby_version: RUBY_VERSION,
      environment: Rails.env
    }

    # Check database connection
    begin
      ActiveRecord::Base.connection.execute('SELECT 1')
      checks[:database] = 'connected'
    rescue StandardError => e
      checks[:database] = 'disconnected'
      checks[:database_error] = e.message
      checks[:status] = 'degraded'
    end

    # Check Redis connection (if configured)
    if defined?(Redis) && ENV['REDIS_URL'].present?
      begin
        redis = Redis.new(url: ENV['REDIS_URL'])
        redis.ping
        checks[:redis] = 'connected'
      rescue StandardError => e
        checks[:redis] = 'disconnected'
        checks[:redis_error] = e.message
        checks[:status] = 'degraded'
      end
    end

    # Determine HTTP status
    http_status = checks[:status] == 'ok' ? :ok : :service_unavailable

    respond_to do |format|
      format.html { render plain: "#{checks[:status].upcase}\n", status: http_status }
      format.json { render json: checks, status: http_status }
      format.any { render plain: "#{checks[:status].upcase}\n", status: http_status }
    end
  end
end
