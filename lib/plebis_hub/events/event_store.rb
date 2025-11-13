# frozen_string_literal: true

module PlebisHub
  module Events
    # ================================================================
    # EventStore - Persistent storage for all domain events
    # ================================================================
    # Provides:
    # - Immutable event log for audit trail
    # - Event sourcing capabilities
    # - Event replay for debugging
    # - Compliance and transparency
    # ================================================================

    class EventStore
      class << self
        # Append an event to the store
        # @param event_type [String] The type of event (e.g., 'user.created')
        # @param payload [Hash] The event payload
        # @return [Event] The stored event record
        def append(event_type:, payload:)
          Event.create!(
            event_type: event_type,
            payload: payload,
            metadata: extract_metadata(payload),
            occurred_at: Time.current
          )
        end

        # Retrieve all events of a specific type
        # @param event_type [String] Event type to filter by
        # @return [ActiveRecord::Relation] Events of the specified type
        def by_type(event_type)
          Event.where(event_type: event_type).order(occurred_at: :asc)
        end

        # Retrieve events within a time range
        # @param start_time [Time] Start of time range
        # @param end_time [Time] End of time range
        # @return [ActiveRecord::Relation] Events in the time range
        def in_time_range(start_time, end_time)
          Event.where(occurred_at: start_time..end_time).order(occurred_at: :asc)
        end

        # Get event stream for analytics
        # @param filter [Hash] Optional filters (event_type, user_id, etc.)
        # @return [ActiveRecord::Relation] Filtered event stream
        def stream(filter = {})
          scope = Event.all

          scope = scope.where(event_type: filter[:event_type]) if filter[:event_type]
          scope = scope.where("metadata->>'user_id' = ?", filter[:user_id].to_s) if filter[:user_id]

          scope.order(occurred_at: :asc)
        end

        private

        def extract_metadata(payload)
          payload[:metadata] || {}
        end
      end

      # Event Model
      class Event < ApplicationRecord
        self.table_name = 'persisted_events'

        # Validations
        validates :event_type, presence: true
        validates :payload, presence: true
        validates :occurred_at, presence: true

        # Scopes
        scope :recent, -> { order(occurred_at: :desc).limit(100) }
        scope :for_user, ->(user_id) { where("metadata->>'user_id' = ?", user_id.to_s) }

        # Make events immutable after creation
        before_update :prevent_update
        before_destroy :prevent_destroy

        private

        def prevent_update
          raise ActiveRecord::ReadOnlyRecord, 'Events are immutable and cannot be updated'
        end

        def prevent_destroy
          raise ActiveRecord::ReadOnlyRecord, 'Events are immutable and cannot be deleted'
        end
      end
    end
  end
end
