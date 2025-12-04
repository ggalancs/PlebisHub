# frozen_string_literal: true

module PlebisMicrocredit
  class Engine < ::Rails::Engine
    isolate_namespace PlebisMicrocredit

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer 'plebis_microcredit.load_abilities' do
      config.to_prepare do
        if defined?(Ability) && defined?(PlebisMicrocredit::Ability)
          Ability.register_abilities(PlebisMicrocredit::Ability)
        end
      end
    end

    initializer 'plebis_microcredit.check_activation', before: :set_routes_reloader do
      # Always enable in test environment for easier testing
      next if Rails.env.test?

      begin
        unless ::EngineActivation.enabled?('plebis_microcredit')
          Rails.logger.info '[PlebisMicrocredit] Engine disabled, skipping routes'
          config.paths['config/routes.rb'].skip_if { true }
        end
      rescue StandardError => e
        # If EngineActivation is not available (no DB, table doesn't exist, etc.), enable by default
        Rails.logger.warn "[PlebisMicrocredit] Could not check activation status (#{e.message}), enabling by default"
      end
    end

    # Make main app route helpers available in engine views
    # This allows views to use routes like new_collaboration_path defined in the main app
    initializer 'plebis_microcredit.include_main_app_route_helpers' do
      config.to_prepare do
        # Include main app route helpers in all controllers within this engine
        if defined?(PlebisMicrocredit::MicrocreditController)
          PlebisMicrocredit::MicrocreditController.helper(Rails.application.routes.url_helpers)
        end
      end
    end
  end
end
