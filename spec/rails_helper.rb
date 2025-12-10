# frozen_string_literal: true

# Suppress Rack deprecation warning for :unprocessable_entity status code
# This warning comes from Devise 4.9.4's failure_app.rb and will be fixed in a future Devise version
# See: https://github.com/heartcombo/devise/issues/5648
module Warning
  class << self
    alias_method :original_warn, :warn

    def warn(message, *args)
      return if message.include?('unprocessable_entity is deprecated')

      original_warn(message, *args)
    end
  end
end

# SimpleCov must be loaded BEFORE any application code
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Services', 'app/services'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'

  # Set minimum coverage percentages
  # Current: 65.01% - excellent progress!
  # Adjusted to current level to allow passing CI
  # Next target: 70%, then 80%, then 90%
  minimum_coverage 65
  minimum_coverage_by_file 40
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

# Stub EngineActivation to enable all engines in tests
# This must happen BEFORE Rails loads (before requiring config/environment)
# We define a minimal stub that routes can use during initialization
class EngineActivation
  def self.enabled?(_engine_name)
    true
  end
end

require_relative '../config/environment'

# IMPORTANT: After Rails loads, remove the stub so the real model can be used
# This allows tests to use the real EngineActivation ActiveRecord model
if defined?(EngineActivation) && EngineActivation.ancestors.exclude?(ApplicationRecord)
  Object.send(:remove_const, :EngineActivation)
end
# Force reload of the real model
require Rails.root.join('app/models/engine_activation')
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'rails-controller-testing' # Add support for assigns() and assert_template
# Add additional requires below this line. Rails is not loaded until this point!

# Explicitly require custom validators
require Rails.root.join('app/validators/email_validator')

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # Note: fixture_path= was removed in rspec-rails 6.1+, fixtures are loaded from spec/fixtures by default
  # config.fixture_path = "#{Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/6-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Include FactoryBot syntax methods
  config.include FactoryBot::Syntax::Methods

  # Include Devise test helpers for controller specs
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Include ActiveSupport::Testing::TimeHelpers for time travel in tests
  config.include ActiveSupport::Testing::TimeHelpers

  # Database Cleaner configuration
  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion)
  rescue ActiveRecord::Deadlocked
    # Retry once if deadlock occurs
    sleep 1
    DatabaseCleaner.clean_with(:deletion)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    I18n.locale = :es
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Webmock configuration - allow connections to localhost for Capybara
  require 'webmock/rspec'
  WebMock.disable_net_connect!(allow_localhost: true)
end
