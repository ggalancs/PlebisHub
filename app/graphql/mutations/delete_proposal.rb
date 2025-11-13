# frozen_string_literal: true

module Mutations
  class DeleteProposal < BaseMutation
    description "Delete a proposal"

    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      proposal = PlebisProposals::Proposal.find(id)
      authorize!(proposal)

      if proposal.destroy
        publish_event('proposal.deleted', { proposal_id: id })

        { success: true, errors: [] }
      else
        { success: false, errors: proposal.errors.full_messages }
      end
    end
  end
end
