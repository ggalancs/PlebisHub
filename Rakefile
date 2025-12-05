# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('config/application', __dir__)

# Load Sidekiq tasks (replaces Resque tasks)
# sidekiq/tasks is optional and may not be available in all Sidekiq versions
begin
  require 'sidekiq/tasks' if defined?(Sidekiq)
rescue LoadError
  # Sidekiq tasks not available, continue
end

# Load Paperclip migration helper for legacy migrations
require_relative 'lib/paperclip_migration_helper'

Rails.application.load_tasks
