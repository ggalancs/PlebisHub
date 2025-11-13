# frozen_string_literal: true

module Mutations
  class CastVote < BaseMutation
    description "Cast a vote on a proposal"

    argument :proposal_id, ID, required: true
    argument :option, String, required: true

    field :vote, Types::ProposalVoteType, null: true
    field :errors, [String], null: false

    def resolve(proposal_id:, option:)
      authorize!

      proposal = PlebisProposals::Proposal.find(proposal_id)

      vote = proposal.proposal_votes.build(
        user: current_user,
        option: option
      )

      if vote.save
        # Publish event
        publish_event('vote.cast', { vote_id: vote.id, proposal_id: proposal.id })

        { vote: vote, errors: [] }
      else
        { vote: nil, errors: vote.errors.full_messages }
      end
    end
  end
end
