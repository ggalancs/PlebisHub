require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PlebisHub
  class Application < Rails::Application
    # Restore secrets method for Rails 7.2+ compatibility
    # Rails.application.secrets was removed in Rails 7.2
    def secrets
      @secrets ||= config.secrets
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Restore Rails.application.secrets for Rails 7.2+ compatibility
    # secrets.yml support was removed in Rails 7.2
    config.secrets = config_for(:secrets)

    # Rails 7.2 compatibility: Allow engines to modify autoload_paths
    # Some legacy engines attempt to modify autoload_paths during initialization
    # This prevents FrozenError by keeping paths mutable
    config.add_autoload_paths_to_load_path = true

    # ========================================
    # SECURITY & PERFORMANCE MIDDLEWARES
    # ========================================

    # Rack::Attack - Rate limiting and throttling
    # Configuration in config/initializers/rack_attack.rb
    config.middleware.use Rack::Attack

    # Note: SecureHeaders configuration is in config/initializers/secure_headers.rb
    # It's automatically applied when the gem is loaded
  end
end
