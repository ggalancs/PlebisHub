# frozen_string_literal: true

# ========================================
# Event Bus - Core Event-Driven Architecture
# ========================================
# Centralized event publishing and subscription system
# Enables loose coupling between engines
# ========================================

require 'singleton'

class EventBus
  include Singleton

  def initialize
    @subscribers = Hash.new { |h, k| h[k] = [] }
    @async_subscribers = Hash.new { |h, k| h[k] = [] }
  end

  # Publish event synchronously
  # @param event_name [String, Symbol] Event name (e.g., 'user.created')
  # @param payload [Hash] Event data
  def publish(event_name, payload = {})
    event = Event.new(event_name.to_s, payload)

    Rails.logger.info "[EventBus] Publishing: #{event_name} with payload: #{payload.inspect}"

    # Persist event for audit trail
    persist_event(event) if PlebisConfig.event_persistence_enabled?

    # Execute synchronous subscribers
    @subscribers[event_name.to_s].each do |subscriber|
      execute_subscriber(subscriber, event)
    end

    # Execute async subscribers via background jobs
    @async_subscribers[event_name.to_s].each do |subscriber|
      EventBusWorker.perform_async(subscriber.name, event.to_h)
    end

    event
  end

  # Subscribe to event synchronously
  # @param event_name [String, Symbol] Event to subscribe to
  # @param callable [Proc, Class] Subscriber (proc or class with #call method)
  def subscribe(event_name, callable = nil, &block)
    subscriber = callable || block
    raise ArgumentError, "Subscriber must respond to #call" unless subscriber.respond_to?(:call)

    @subscribers[event_name.to_s] << subscriber
    Rails.logger.info "[EventBus] Subscribed to: #{event_name}"
  end

  # Subscribe to event asynchronously (background job)
  # @param event_name [String, Symbol] Event to subscribe to
  # @param listener_class [Class] Class with .call class method
  def subscribe_async(event_name, listener_class)
    raise ArgumentError, "Listener must respond to .call" unless listener_class.respond_to?(:call)

    @async_subscribers[event_name.to_s] << listener_class
    Rails.logger.info "[EventBus] Async subscribed to: #{event_name}"
  end

  # Clear all subscribers (mainly for testing)
  def clear!
    @subscribers.clear
    @async_subscribers.clear
  end

  private

  def execute_subscriber(subscriber, event)
    subscriber.call(event)
  rescue StandardError => e
    Rails.logger.error "[EventBus] Subscriber error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    # Report to error tracking (Airbrake, Sentry, etc.)
    Airbrake.notify(e, event: event.to_h) if defined?(Airbrake)
  end

  def persist_event(event)
    PersistedEvent.create!(
      event_type: event.name,
      payload: event.payload,
      metadata: {
        user_id: Current.user&.id,
        ip: Current.ip,
        user_agent: Current.user_agent
      },
      occurred_at: event.occurred_at
    )
  rescue StandardError => e
    Rails.logger.error "[EventBus] Failed to persist event: #{e.message}"
  end

  # Event value object
  class Event
    attr_reader :name, :payload, :occurred_at, :id

    def initialize(name, payload = {})
      @id = SecureRandom.uuid
      @name = name
      @payload = payload.deep_symbolize_keys
      @occurred_at = Time.current
    end

    def to_h
      {
        id: id,
        name: name,
        payload: payload,
        occurred_at: occurred_at.iso8601
      }
    end

    def [](key)
      payload[key.to_sym]
    end
  end
end

# Configuration
class PlebisConfig
  class << self
    def event_persistence_enabled?
      Rails.env.production? || ENV['EVENT_PERSISTENCE'] == 'true'
    end
  end
end

# Background worker for async event processing
class EventBusWorker
  include Resque::Plugins::UniqueJob

  @queue = :events

  def self.perform(listener_class_name, event_hash)
    listener_class = listener_class_name.constantize
    event = EventBus::Event.new(event_hash['name'], event_hash['payload'])

    listener_class.call(event)
  rescue StandardError => e
    Rails.logger.error "[EventBusWorker] Error: #{e.class} - #{e.message}"
    raise # Re-raise to retry via Resque
  end
end

# Convenience methods
def publish_event(event_name, payload = {})
  EventBus.instance.publish(event_name, payload)
end

def subscribe_to_event(event_name, &block)
  EventBus.instance.subscribe(event_name, &block)
end
