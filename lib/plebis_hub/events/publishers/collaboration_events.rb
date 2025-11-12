# frozen_string_literal: true

module PlebisHub
  module Events
    module Publishers
      # ================================================================
      # CollaborationEvents - Publisher for collaboration/donation events
      # ================================================================
      # Emits events for collaboration actions:
      # - collaboration.created
      # - collaboration.confirmed
      # - collaboration.cancelled
      # ================================================================

      module CollaborationEvents
        extend ApplicationEvent

        # Register all collaboration events
        register_event('collaboration.created')
        register_event('collaboration.confirmed')
        register_event('collaboration.cancelled')
        register_event('collaboration.refunded')

        class << self
          def collaboration_created(collaboration)
            publish_event('collaboration.created', collaboration_payload(collaboration))
          end

          def collaboration_confirmed(collaboration)
            publish_event('collaboration.confirmed', collaboration_payload(collaboration))
          end

          def collaboration_cancelled(collaboration, reason: nil)
            publish_event('collaboration.cancelled', collaboration_payload(collaboration).merge(
              reason: reason
            ))
          end

          def collaboration_refunded(collaboration, amount:)
            publish_event('collaboration.refunded', collaboration_payload(collaboration).merge(
              refunded_amount: amount
            ))
          end

          private

          def collaboration_payload(collaboration)
            {
              collaboration_id: collaboration.id,
              user_id: collaboration.user_id,
              amount: collaboration.amount,
              frequency: collaboration.frequency,
              payment_method: collaboration.payment_method,
              created_at: collaboration.created_at
            }
          end
        end
      end
    end
  end
end
