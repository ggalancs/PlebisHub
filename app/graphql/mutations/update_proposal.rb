# frozen_string_literal: true

module Mutations
  class UpdateProposal < BaseMutation
    description "Update a proposal"

    argument :id, ID, required: true
    argument :title, String, required: false
    argument :body, String, required: false
    argument :category, String, required: false

    field :proposal, Types::ProposalType, null: true
    field :errors, [String], null: false

    def resolve(id:, **attributes)
      proposal = Proposal.find(id)
      authorize!(proposal)

      if proposal.update(attributes.compact)
        { proposal: proposal, errors: [] }
      else
        { proposal: nil, errors: proposal.errors.full_messages }
      end
    end
  end
end
