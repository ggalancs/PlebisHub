# frozen_string_literal: true

module PlebisGamification
  class Engine < ::Rails::Engine
    # Don't isolate namespace - models are in Gamification:: not PlebisGamification::
    # This allows tests and application code to use Gamification::Badge, etc.

    # Add concerns directory to autoload paths (Zeitwerk compatibility)
    # Use before_initialize to avoid modifying frozen arrays in Rails 7.2+
    config.before_initialize do
      config.autoload_paths += [root.join('app/models/concerns')] if root.join('app/models/concerns').exist?
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    # Hook to check if engine is enabled
    initializer 'plebis_gamification.check_activation', before: :set_routes_reloader do
      # Always enable in test environment for easier testing
      next if Rails.env.test?

      begin
        unless ::EngineActivation.enabled?('plebis_gamification')
          Rails.logger.info '[PlebisGamification] Engine disabled, skipping routes'
          config.paths['config/routes.rb'].skip_if { true }
        end
      rescue StandardError => e
        # If EngineActivation is not available (no DB, table doesn't exist, etc.), enable by default
        Rails.logger.warn "[PlebisGamification] Could not check activation status (#{e.message}), enabling by default"
      end
    end

    # Register event listeners when engine is activated
    initializer 'plebis_gamification.register_listeners', after: :load_config_initializers do
      # Skip in test environment or if not activated
      next if Rails.env.test?
      next unless ::EngineActivation.enabled?('plebis_gamification') rescue true

      Rails.application.config.after_initialize do
        Gamification::UserListener.register! if defined?(Gamification::UserListener)
        Gamification::ProposalListener.register! if defined?(Gamification::ProposalListener)
        Gamification::VoteListener.register! if defined?(Gamification::VoteListener)
        Gamification::LoginListener.register! if defined?(Gamification::LoginListener)
      end
    end
  end
end
