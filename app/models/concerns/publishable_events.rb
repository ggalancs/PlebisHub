# frozen_string_literal: true

# ================================================================
# PublishableEvents - Concern for models that publish domain events
# ================================================================
# Include this in models to automatically publish events on lifecycle hooks
# ================================================================

module PublishableEvents
  extend ActiveSupport::Concern

  included do
    # Callbacks for publishing events
    after_create :publish_created_event
    after_update :publish_updated_event
    after_destroy :publish_destroyed_event
  end

  private

  def publish_created_event
    event_name = "#{model_name.element}.created"
    publish_event(event_name, event_payload)
  end

  def publish_updated_event
    return unless saved_changes?

    event_name = "#{model_name.element}.updated"
    publish_event(event_name, event_payload.merge(changes: saved_changes))
  end

  def publish_destroyed_event
    event_name = "#{model_name.element}.deleted"
    publish_event(event_name, event_payload)
  end

  def event_payload
    # Override in including class to customize payload
    attributes.symbolize_keys
  end

  def publish_event(event_name, payload)
    EventBus.instance.publish(event_name, payload)
  end
end
