# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'resque/tasks'
task 'resque:setup' => :environment

# Load Paperclip migration helper for legacy migrations
require_relative 'lib/paperclip_migration_helper'

Rails.application.load_tasks
