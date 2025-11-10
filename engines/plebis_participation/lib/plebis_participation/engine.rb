# frozen_string_literal: true

module PlebisParticipation
  class Engine < ::Rails::Engine
    isolate_namespace PlebisParticipation

    # Only load routes when engine is activated
    initializer "plebis_participation.check_activation", before: :set_routes_reloader do
      unless EngineActivation.enabled?('plebis_participation')
        Rails.logger.info "[PlebisParticipation] Engine disabled, skipping routes"
        config.paths["config/routes.rb"].skip_if { true }
      end
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end
  end
end
