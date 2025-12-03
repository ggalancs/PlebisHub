require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  # NOTE: Set to false to prevent FrozenError with Rails 7.2+ engines modifying autoload_paths
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{1.hour.to_i}" }

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Compile assets on the fly in test environment
  config.assets.compile = true
  config.assets.check_precompiled_asset = false

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # Disable caching for Action Mailer templates even if Action Controller
  # caching is enabled.
  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Unlike controllers, the mailer instance doesn't have any context about the
  # incoming request so you'll need to provide the :host parameter yourself.
  config.action_mailer.default_url_options = { host: "www.example.com" }

  # Set default URL options for controllers (needed for url_for in views/controllers)
  config.action_controller.default_url_options = { host: "www.example.com" }

  # Set default URL options for routes (needed for URL helpers called from models)
  config.after_initialize do
    Rails.application.routes.default_url_options = { host: "www.example.com" }
  end

  # RAILS 7.2 FIX: Set default from address for test mailers
  # Rails 7.2 requires a from address to be set, raising ArgumentError otherwise
  config.action_mailer.default_options = { from: 'test@example.com' }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  # RACK 3.x FIX: Disable host authorization in test environment
  # Rails 7.2 + Rack 3.x enforces host matching which causes issues with test requests
  # that use default hosts like 'example.com' instead of the configured 'www.example.com'
  # This prevents 301 redirects in tests due to host mismatch
  config.hosts.clear
end
