# frozen_string_literal: true

module PlebisProposals
  class Engine < ::Rails::Engine
    isolate_namespace PlebisProposals

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    # Hook to check if engine is enabled
    initializer 'plebis_proposals.check_activation', before: :set_routes_reloader do
      # Always enable in test environment for easier testing
      next if Rails.env.test?

      begin
        unless ::EngineActivation.enabled?('plebis_proposals')
          Rails.logger.info '[PlebisProposals] Engine disabled, skipping routes'
          config.paths['config/routes.rb'].skip_if { true }
        end
      rescue StandardError => e
        # If EngineActivation is not available (no DB, table doesn't exist, etc.), enable by default
        Rails.logger.warn "[PlebisProposals] Could not check activation status (#{e.message}), enabling by default"
      end
    end
  end
end
