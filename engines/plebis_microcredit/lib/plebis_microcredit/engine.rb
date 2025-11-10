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
      begin
        unless ::EngineActivation.enabled?('plebis_microcredit')
          Rails.logger.info "[PlebisMicrocredit] Engine disabled, skipping routes"
          config.paths["config/routes.rb"].skip_if { true }
        end
      rescue => e
        # If EngineActivation is not available (no DB, table doesn't exist, etc.), enable by default
        Rails.logger.warn "[PlebisMicrocredit] Could not check activation status (#{e.message}), enabling by default"
      end
    end
  end
end
