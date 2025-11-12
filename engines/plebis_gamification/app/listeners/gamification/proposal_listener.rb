# frozen_string_literal: true

module Gamification
  module Listeners
    # ==================================
    # Proposal Event Listener
    # ==================================
    # Awards points for proposal-related actions
    # ==================================

    class ProposalListener
      POINTS_CONFIG = {
        created: 50,
        approved: 100,
        featured: 200,
        implemented: 500
      }.freeze

      class << self
        def register!
          EventBus.instance.subscribe('proposal.created', method(:on_proposal_created))
          EventBus.instance.subscribe('proposal.approved', method(:on_proposal_approved))
          EventBus.instance.subscribe('proposal.featured', method(:on_proposal_featured))
          EventBus.instance.subscribe('proposal.implemented', method(:on_proposal_implemented))
        end

        def on_proposal_created(event)
          user = User.find(event[:user_id])
          stats = UserStats.for_user(user)

          stats.earn_points!(
            POINTS_CONFIG[:created],
            reason: 'Propuesta creada',
            source: Proposal.find(event[:proposal_id])
          )

          # Check for badges
          BadgeAwarder.check_and_award!(user)
        end

        def on_proposal_approved(event)
          proposal = Proposal.find(event[:proposal_id])
          stats = UserStats.for_user(proposal.author)

          stats.earn_points!(
            POINTS_CONFIG[:approved],
            reason: 'Propuesta aprobada',
            source: proposal
          )

          BadgeAwarder.check_and_award!(proposal.author)
        end

        def on_proposal_featured(event)
          proposal = Proposal.find(event[:proposal_id])
          stats = UserStats.for_user(proposal.author)

          stats.earn_points!(
            POINTS_CONFIG[:featured],
            reason: 'Propuesta destacada',
            source: proposal
          )
        end

        def on_proposal_implemented(event)
          proposal = Proposal.find(event[:proposal_id])
          stats = UserStats.for_user(proposal.author)

          stats.earn_points!(
            POINTS_CONFIG[:implemented],
            reason: '¡Propuesta implementada!',
            source: proposal
          )

          BadgeAwarder.check_and_award!(proposal.author)
        end
      end
    end
  end
end
