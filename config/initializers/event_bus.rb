# frozen_string_literal: true

# ========================================
# Event Bus Initialization
# ========================================
# Loads event bus and registers listeners
# ========================================

require 'event_bus'

Rails.application.config.after_initialize do
  # Ensure EventBus is initialized
  EventBus.instance

  Rails.logger.info "[EventBus] Initialized"

  # Register core event listeners (skip if tables don't exist yet)
  begin
    if defined?(EngineActivation) && EngineActivation.table_exists? && EngineActivation.active?('plebis_gamification')
      require_dependency Rails.root.join('engines/plebis_gamification/app/listeners/gamification/proposal_listener')

      Gamification::Listeners::ProposalListener.register!
      Rails.logger.info "[EventBus] Registered Gamification listeners"
    end

    # Future listeners will be registered here
    # if EngineActivation.active?('plebis_analytics')
    #   Analytics::Listeners::MetricListener.register!
    # end

    # if EngineActivation.active?('plebis_messaging')
    #   Messaging::Listeners::NotificationListener.register!
    # end
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid => e
    # Database/tables don't exist yet (e.g., during migrations)
    Rails.logger.warn "[EventBus] Skipping listener registration: #{e.message}"
  end
end

# Cleanup on app reload (development)
if Rails.env.development?
  Rails.application.reloader.to_prepare do
    EventBus.instance.clear!
  end
end
