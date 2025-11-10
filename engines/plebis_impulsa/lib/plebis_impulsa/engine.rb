# frozen_string_literal: true

module PlebisImpulsa
  class Engine < ::Rails::Engine
    isolate_namespace PlebisImpulsa

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    # Hook to check if engine is enabled
    initializer "plebis_impulsa.check_activation", before: :set_routes_reloader do
      unless EngineActivation.enabled?('plebis_impulsa')
        Rails.logger.info "[PlebisImpulsa] Engine disabled, skipping routes"
        config.paths["config/routes.rb"].skip_if { true }
      end
    end
  end
end
