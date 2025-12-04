# frozen_string_literal: true

module PlebisCms
  class Engine < ::Rails::Engine
    isolate_namespace PlebisCms

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer 'plebis_cms.load_abilities' do
      config.to_prepare do
        Ability.register_abilities(PlebisCms::Ability) if defined?(Ability) && defined?(PlebisCms::Ability)
      end
    end

    initializer 'plebis_cms.check_activation', before: :set_routes_reloader do
      # Always enable in test environment for easier testing
      next if Rails.env.test?

      begin
        unless ::EngineActivation.enabled?('plebis_cms')
          Rails.logger.info '[PlebisCms] Engine disabled, skipping routes'
          config.paths['config/routes.rb'].skip_if { true }
        end
      rescue StandardError => e
        # If EngineActivation is not available (no DB, table doesn't exist, etc.), enable by default
        Rails.logger.warn "[PlebisCms] Could not check activation status (#{e.message}), enabling by default"
      end
    end
  end
end
