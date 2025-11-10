# frozen_string_literal: true

module PlebisVerification
  class Engine < ::Rails::Engine
    isolate_namespace PlebisVerification

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer "plebis_verification.load_abilities" do
      config.to_prepare do
        if defined?(Ability)
          Ability.register_abilities(PlebisVerification::Ability) if defined?(PlebisVerification::Ability)
        end
      end
    end

    initializer "plebis_verification.check_activation", before: :set_routes_reloader do
      unless EngineActivation.enabled?('plebis_verification')
        Rails.logger.info "[PlebisVerification] Engine disabled, skipping routes"
        config.paths["config/routes.rb"].skip_if { true }
      end
    end
  end
end
