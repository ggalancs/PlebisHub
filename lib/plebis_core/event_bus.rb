# frozen_string_literal: true

module PlebisCore
  # EventBus
  #
  # Provides a simple event bus for decoupling engines.
  # Engines can publish events and subscribe to events from other engines
  # without direct dependencies.
  #
  # Built on top of ActiveSupport::Notifications for reliability and performance.
  #
  # Usage:
  #
  #   # Publishing an event
  #   PlebisCore::EventBus.publish('collaboration.created', {
  #     user_id: 123,
  #     amount: 10,
  #     frequency: 1
  #   })
  #
  #   # Subscribing to an event
  #   PlebisCore::EventBus.subscribe('collaboration.created') do |event|
  #     payload = event.payload
  #     PlebisMilitant::StatusUpdater.call(user_id: payload[:user_id])
  #   end
  #
  class EventBus
    # Publish an event to all subscribers
    #
    # @param event_name [String] The name of the event (will be prefixed with 'plebis.')
    # @param payload [Hash] The event data to pass to subscribers
    #
    # @example
    #   EventBus.publish('user.registered', { user_id: 123, email: 'user@example.com' })
    #
    def self.publish(event_name, payload = {})
      full_event_name = "plebis.#{event_name}"

      ActiveSupport::Notifications.instrument(full_event_name, payload) do
        Rails.logger.debug "[EventBus] Publishing: #{full_event_name} with payload: #{payload.inspect}"
      end
    rescue StandardError => e
      Rails.logger.error "[EventBus] Error publishing #{event_name}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end

    # Subscribe to an event
    #
    # @param event_name [String] The name of the event (will be prefixed with 'plebis.')
    # @yield [event] Yields the event object to the block
    # @yieldparam event [ActiveSupport::Notifications::Event] The event object with payload
    #
    # @example
    #   EventBus.subscribe('user.registered') do |event|
    #     user_id = event.payload[:user_id]
    #     puts "User #{user_id} registered!"
    #   end
    #
    def self.subscribe(event_name, &block)
      full_event_name = "plebis.#{event_name}"

      ActiveSupport::Notifications.subscribe(full_event_name) do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        Rails.logger.debug { "[EventBus] Received: #{full_event_name}" }

        begin
          block.call(event)
        rescue StandardError => e
          Rails.logger.error "[EventBus] Error in subscriber for #{event_name}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          # Don't re-raise to prevent one subscriber from affecting others
        end
      end

      Rails.logger.info "[EventBus] Subscribed to: #{full_event_name}"
    end

    # Unsubscribe from an event
    #
    # @param event_name [String] The name of the event
    # @param subscriber [Object] The subscriber object returned from subscribe
    #
    def self.unsubscribe(event_name, subscriber = nil)
      full_event_name = "plebis.#{event_name}"

      ActiveSupport::Notifications.unsubscribe(subscriber || full_event_name)

      Rails.logger.info "[EventBus] Unsubscribed from: #{full_event_name}"
    end

    # Clear all subscriptions (useful for testing)
    #
    def self.clear_all_subscriptions!
      Rails.logger.warn '[EventBus] Clearing all subscriptions'
      ActiveSupport::Notifications.notifier.listeners_for('plebis.*').each do |listener|
        ActiveSupport::Notifications.unsubscribe(listener)
      end
    end
  end
end
