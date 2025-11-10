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
    initializer "plebis_proposals.check_activation", before: :set_routes_reloader do
      unless EngineActivation.enabled?('plebis_proposals')
        Rails.logger.info "[PlebisProposals] Engine disabled, skipping routes"
        config.paths["config/routes.rb"].skip_if { true }
      end
    end
  end
end
