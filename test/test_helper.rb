# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'
require 'simplecov'
require 'webmock/minitest'
require 'minitest/reporters'
require 'mocha/minitest'

# Explicitly require validators to ensure they're loaded before models
require Rails.root.join('app/validators/email_validator')

# Configure SimpleCov for 95% coverage target
SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'

  minimum_coverage 95

  track_files '{app,lib}/**/*.rb'
end

WebMock.disable_net_connect!(allow_localhost: true)
Minitest::Reporters.use!
include Warden::Test::Helpers

Warden.test_mode!

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionController
  class TestCase
    include Devise::TestHelpers
    include FactoryBot::Syntax::Methods
  end
end

def with_blocked_change_location
  Rails.application.secrets.users['allows_location_change'] = false
  yield
ensure
  Rails.application.secrets.users['allows_location_change'] = true
end

# FIX Capybara error: SQLite3::BusyException: database is locked
# http://atlwendy.ghost.io/capybara-database-locked/
module ActiveRecord
  class Base
    mattr_accessor :shared_connection
    @@shared_connection = nil

    def self.connection
      @@shared_connection || retrieve_connection
    end
  end
end

ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# Capybara::Webkit configuration disabled (webkit not installed)
# Capybara::Webkit.configure do |config|
#   config.block_unknown_urls
# end

def with_versioning
  was_enabled = PaperTrail.enabled?
  was_enabled_for_controller = PaperTrail.enabled_for_controller?
  PaperTrail.enabled = true
  PaperTrail.enabled_for_controller = true
  begin
    yield
  ensure
    PaperTrail.enabled = was_enabled
    PaperTrail.enabled_for_controller = was_enabled_for_controller
  end
end
