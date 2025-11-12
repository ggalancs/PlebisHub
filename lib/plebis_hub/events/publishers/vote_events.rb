# frozen_string_literal: true

module PlebisHub
  module Events
    module Publishers
      # ================================================================
      # VoteEvents - Publisher for vote-related domain events
      # ================================================================
      # Emits events for voting actions:
      # - vote.cast
      # - vote.changed
      # - vote.deleted
      # ================================================================

      module VoteEvents
        extend ApplicationEvent

        # Register all vote events
        register_event('vote.cast')
        register_event('vote.changed')
        register_event('vote.deleted')

        class << self
          def vote_cast(vote)
            publish_event('vote.cast', vote_payload(vote))
          end

          def vote_changed(vote, old_option:)
            publish_event('vote.changed', vote_payload(vote).merge(
              old_option: old_option,
              new_option: vote.option
            ))
          end

          def vote_deleted(vote)
            publish_event('vote.deleted', vote_payload(vote))
          end

          private

          def vote_payload(vote)
            {
              vote_id: vote.id,
              user_id: vote.user_id,
              proposal_id: vote.proposal_id,
              option: vote.option,
              created_at: vote.created_at
            }
          end
        end
      end
    end
  end
end
