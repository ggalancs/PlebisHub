# frozen_string_literal: true

module PlebisVerification
  class Engine < ::Rails::Engine
    isolate_namespace PlebisVerification

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer 'plebis_verification.load_abilities' do
      config.to_prepare do
        if defined?(Ability) && defined?(PlebisVerification::Ability)
          Ability.register_abilities(PlebisVerification::Ability)
        end
      end
    end

    initializer 'plebis_verification.check_activation', before: :set_routes_reloader do
      # Always enable in test environment for easier testing
      next if Rails.env.test?

      begin
        unless ::EngineActivation.enabled?('plebis_verification')
          Rails.logger.info '[PlebisVerification] Engine disabled, skipping routes'
          config.paths['config/routes.rb'].skip_if { true }
        end
      rescue StandardError => e
        # If EngineActivation is not available (no DB, table doesn't exist, etc.), enable by default
        Rails.logger.warn "[PlebisVerification] Could not check activation status (#{e.message}), enabling by default"
      end
    end
  end
end
