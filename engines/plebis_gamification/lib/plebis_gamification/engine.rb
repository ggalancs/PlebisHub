# frozen_string_literal: true

module PlebisGamification
  class Engine < ::Rails::Engine
    isolate_namespace PlebisGamification

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    # Load engine when activated
    initializer 'plebis_gamification.load_engine', before: :load_config_initializers do
      next unless EngineActivation.active?('plebis_gamification')

      # Add engine paths
      config.paths.add 'app/models/concerns', eager_load: true
      config.paths.add 'app/services', eager_load: true
      config.paths.add 'app/listeners', eager_load: true

      # Register event listeners
      Rails.application.config.after_initialize do
        PlebisGamification::Listeners::UserListener.register!
        PlebisGamification::Listeners::ProposalListener.register!
        PlebisGamification::Listeners::VoteListener.register!
        PlebisGamification::Listeners::LoginListener.register!
      end
    end
  end
end
