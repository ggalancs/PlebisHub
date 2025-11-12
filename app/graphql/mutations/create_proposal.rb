# frozen_string_literal: true

module Mutations
  class CreateProposal < BaseMutation
    description "Create a new proposal"

    argument :title, String, required: true
    argument :body, String, required: true
    argument :category, String, required: false
    argument :summary, String, required: false

    field :proposal, Types::ProposalType, null: true
    field :errors, [String], null: false

    def resolve(title:, body:, category: nil, summary: nil)
      authorize!

      proposal = current_user.proposals.build(
        title: title,
        body: body,
        category: category,
        summary: summary
      )

      if proposal.save
        # Publish event
        publish_event('proposal.created', { proposal_id: proposal.id })

        { proposal: proposal, errors: [] }
      else
        { proposal: nil, errors: proposal.errors.full_messages }
      end
    end
  end
end
