# frozen_string_literal: true

module PlebisHub
  module Events
    module Publishers
      # ================================================================
      # ProposalEvents - Publisher for proposal-related domain events
      # ================================================================
      # Emits events for proposal lifecycle:
      # - proposal.created
      # - proposal.updated
      # - proposal.published
      # - proposal.approved
      # - proposal.rejected
      # - proposal.deleted
      # ================================================================

      module ProposalEvents
        extend ApplicationEvent

        # Register all proposal events
        register_event('proposal.created')
        register_event('proposal.updated')
        register_event('proposal.published')
        register_event('proposal.approved')
        register_event('proposal.rejected')
        register_event('proposal.deleted')
        register_event('proposal.commented')
        register_event('proposal.shared')

        class << self
          def proposal_created(proposal)
            publish_event('proposal.created', proposal_payload(proposal))
          end

          def proposal_updated(proposal, changes = {})
            publish_event('proposal.updated', proposal_payload(proposal).merge(changes: changes))
          end

          def proposal_published(proposal)
            publish_event('proposal.published', proposal_payload(proposal))
          end

          def proposal_approved(proposal, approved_by:)
            publish_event('proposal.approved', proposal_payload(proposal).merge(
              approved_by_id: approved_by&.id
            ))
          end

          def proposal_rejected(proposal, rejected_by:, reason: nil)
            publish_event('proposal.rejected', proposal_payload(proposal).merge(
              rejected_by_id: rejected_by&.id,
              reason: reason
            ))
          end

          def proposal_deleted(proposal)
            publish_event('proposal.deleted', proposal_payload(proposal))
          end

          def proposal_commented(proposal, comment)
            publish_event('proposal.commented', proposal_payload(proposal).merge(
              comment_id: comment.id,
              comment_author_id: comment.author_id
            ))
          end

          def proposal_shared(proposal, shared_by:, platform:)
            publish_event('proposal.shared', proposal_payload(proposal).merge(
              shared_by_id: shared_by.id,
              platform: platform
            ))
          end

          private

          def proposal_payload(proposal)
            {
              proposal_id: proposal.id,
              title: proposal.title,
              author_id: proposal.author_id,
              organization_id: proposal.organization_id,
              category: proposal.category,
              status: proposal.status,
              created_at: proposal.created_at
            }
          end
        end
      end
    end
  end
end
