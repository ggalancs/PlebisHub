# frozen_string_literal: true

module PlebisHub
  module Events
    # ================================================================
    # ApplicationEvent - Base class for all domain events
    # ================================================================
    # Provides event bus infrastructure using Dry::Events
    # Supports multiple backends: :action_cable, :redis, or :kafka
    # ================================================================

    class ApplicationEvent
      include Dry::Events::Publisher[:plebishub]

      class << self
        # Configure event backend (default: action_cable)
        # In production, use :redis or :kafka for scalability
        def backend
          @backend ||= Rails.env.production? ? :redis : :action_cable
        end

        def backend=(value)
          @backend = value
        end

        # Register an event type
        # @param event_name [String] Namespaced event name (e.g., 'user.created')
        # @param payload_schema [Hash] Optional schema for validation
        def register_event(event_name, payload_schema: nil)
          register_event_type(event_name)

          # Store schema for validation if provided
          if payload_schema
            event_schemas[event_name] = payload_schema
          end

          Rails.logger.info "[Events] Registered event: #{event_name}"
        end

        # Publish an event
        # @param event_name [String] Event name
        # @param payload [Hash] Event payload
        def publish_event(event_name, payload = {})
          enriched_payload = enrich_payload(payload)

          # Validate payload if schema exists
          validate_payload!(event_name, enriched_payload) if event_schemas[event_name]

          # Publish to event bus
          publish(event_name, enriched_payload)

          # Store in event store for audit trail
          store_event(event_name, enriched_payload)

          Rails.logger.debug "[Events] Published: #{event_name} with payload: #{enriched_payload.inspect}"
        rescue StandardError => e
          Rails.logger.error "[Events] Failed to publish #{event_name}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          raise
        end

        private

        def event_schemas
          @event_schemas ||= {}
        end

        def enrich_payload(payload)
          payload.merge(
            event_id: SecureRandom.uuid,
            timestamp: Time.current.to_i,
            environment: Rails.env,
            metadata: {
              ip: Current.ip,
              user_id: Current.user&.id,
              user_agent: Current.user_agent,
              request_id: Current.request_id
            }
          )
        end

        def validate_payload!(event_name, payload)
          schema = event_schemas[event_name]
          # Basic validation - can be extended with dry-validation
          schema.each do |key, type|
            unless payload.key?(key)
              raise ArgumentError, "Missing required field: #{key} for event #{event_name}"
            end
          end
        end

        def store_event(event_name, payload)
          # Store in EventStore for event sourcing and audit
          EventStore.append(
            event_type: event_name,
            payload: payload
          )
        rescue StandardError => e
          Rails.logger.error "[Events] Failed to store event in EventStore: #{e.message}"
          # Don't fail the event publication if storage fails
        end
      end
    end
  end
end
