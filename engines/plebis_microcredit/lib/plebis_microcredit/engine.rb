# frozen_string_literal: true

module PlebisMicrocredit
  class Engine < ::Rails::Engine
    isolate_namespace PlebisMicrocredit

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer "plebis_microcredit.load_abilities" do
      config.to_prepare do
        if defined?(Ability)
          Ability.register_abilities(PlebisMicrocredit::Ability) if defined?(PlebisMicrocredit::Ability)
        end
      end
    end

    initializer "plebis_microcredit.check_activation", before: :set_routes_reloader do
      unless EngineActivation.enabled?('plebis_microcredit')
        Rails.logger.info "[PlebisMicrocredit] Engine disabled, skipping routes"
        config.paths["config/routes.rb"].skip_if { true }
      end
    end
  end
end
