# frozen_string_literal: true

# Unicorn Configuration for Docker
# Optimized for containerized environments

# Set environment
rails_env = ENV['RAILS_ENV'] || 'production'

# Worker processes
worker_processes ENV.fetch('WEB_CONCURRENCY', 2).to_i

# Listen on port 3000
listen ENV.fetch('PORT', 3000).to_i, backlog: 64

# Working directory
working_directory '/app'

# Timeout
timeout 30

# Preload application for faster worker spawn
preload_app true

# Logging
stderr_path '/dev/stderr'
stdout_path '/dev/stdout'

# Before fork
before_fork do |server, worker|
  # Disconnect from database
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Terminate old master process (zero-downtime deployments)
  old_pid = '/app/tmp/pids/unicorn.pid.oldbin'
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      Process.kill('QUIT', File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # Old process already gone
    end
  end
end

# After fork
after_fork do |server, worker|
  # Reconnect to database
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end

  # Reconnect to Redis
  if defined?(Resque)
    Resque.redis.client.reconnect
  end
end
