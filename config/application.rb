require_relative "boot"

# Selectively require Rails frameworks (excluding ActionText to avoid frozen array issues)
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
# require "action_text/engine"  # Disabled - causes FrozenError in Rails 7.2 test environment
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

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
    # 8.0 brings: to_time_preserves_timezone = :zone, strict_freshness = true
    # and Regexp.timeout = 1. All three were verified against this codebase
    # before switching (see RAILS_8_UPGRADE_PLAN.md).
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    # Files under lib/ that Zeitwerk must not manage: they either reopen core
    # classes / define bare methods instead of a matching constant, or use a
    # constant name that does not match the file name. All of them are loaded
    # explicitly (config/initializers/date_extensions.rb, sms.rb, or an explicit
    # `require` at the call site).
    config.autoload_lib(ignore: %w[
      assets
      tasks
      generators
      paperclip
      add_unique_month_to_dates.rb
      plebisbrand_export.rb
      plebisbrand_import.rb
      plebisbrand_import_collaborations.rb
      plebisbrand_import_collaborations2017.rb
      sms.rb
    ])

    # app/workers/plebisbrand_*.rb define PlebisBrand… (capital B) while Zeitwerk
    # would infer Plebisbrand…. Override the inflection for just those files
    # rather than registering a global `PlebisBrand` acronym, which would also
    # change `underscore` everywhere and collide with the PlebisBrand = Podemos
    # alias in config/initializers/plebis_brand_alias.rb.
    # Engines expose app/admin as an autoload path, but those files are
    # ActiveAdmin DSL (`ActiveAdmin.register…`) and define no constants, so
    # eager loading them raises. ActiveAdmin already excludes the main app's
    # app/admin for the same reason; do the same for the engines.
    Rails.autoloaders.main.ignore(Rails.root.glob('engines/*/app/admin'))

    Rails.autoloaders.each do |autoloader|
      autoloader.inflector.inflect(
        'plebisbrand_collaboration_worker' => 'PlebisBrandCollaborationWorker',
        'plebisbrand_import_worker' => 'PlebisBrandImportWorker',
        'plebisbrand_report_worker' => 'PlebisBrandReportWorker'
      )
    end

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

    # Paper Trail / YAML Serialization Compatibility (Rails 7+)
    # Required for Paper Trail changesets to work properly with YAML serialization
    # See: https://github.com/paper-trail-gem/paper_trail/blob/master/CHANGELOG.md
    config.active_record.yaml_column_permitted_classes = [
      Symbol, Date, Time, DateTime,
      ActiveSupport::TimeWithZone,
      ActiveSupport::TimeZone,
      BigDecimal
    ]

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
