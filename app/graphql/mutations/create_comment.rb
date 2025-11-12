# frozen_string_literal: true

module Mutations
  class CreateComment < BaseMutation
    description "Create a comment on a proposal"

    argument :proposal_id, ID, required: true
    argument :body, String, required: true
    argument :parent_id, ID, required: false

    field :comment, Types::ProposalCommentType, null: true
    field :errors, [String], null: false

    def resolve(proposal_id:, body:, parent_id: nil)
      authorize!

      proposal = PlebisProposals::Proposal.find(proposal_id)
      comment = proposal.proposal_comments.build(
        author: current_user,
        body: body,
        parent_id: parent_id
      )

      if comment.save
        # Publish event
        publish_event('proposal.commented', {
          proposal_id: proposal.id,
          comment_id: comment.id,
          comment_author_id: current_user.id
        })

        { comment: comment, errors: [] }
      else
        { comment: nil, errors: comment.errors.full_messages }
      end
    end
  end
end
