# frozen_string_literal: true

module PlebisImpulsa
  class Engine < ::Rails::Engine
    isolate_namespace PlebisImpulsa

    # NOTE: the concerns used to live in app/models/plebis_impulsa/concerns with
    # an extra autoload root. They now sit in app/models/concerns/plebis_impulsa,
    # which Rails already treats as an autoload root and which maps directly to
    # the PlebisImpulsa::… constants the files define, so no override is needed.

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    # Hook to check if engine is enabled
    initializer 'plebis_impulsa.check_activation', before: :set_routes_reloader do
      # Always enable in test environment for easier testing
      next if Rails.env.test?

      begin
        unless ::EngineActivation.enabled?('plebis_impulsa')
          Rails.logger.info '[PlebisImpulsa] Engine disabled, skipping routes'
          config.paths['config/routes.rb'].skip_if { true }
        end
      rescue StandardError => e
        # If EngineActivation is not available (no DB, table doesn't exist, etc.), enable by default
        Rails.logger.warn "[PlebisImpulsa] Could not check activation status (#{e.message}), enabling by default"
      end
    end
  end
end
