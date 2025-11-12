# frozen_string_literal: true

module Mutations
  class CreateComment < BaseMutation
    description "Create a comment"

    argument :proposal_id, ID, required: true
    argument :body, String, required: true

    field :comment, Types::CommentType, null: true
    field :errors, [String], null: false

    def resolve(proposal_id:, body:)
      authorize!

      proposal = Proposal.find(proposal_id)
      comment = proposal.comments.build(
        author: current_user,
        body: body
      )

      if comment.save
        { comment: comment, errors: [] }
      else
        { comment: nil, errors: comment.errors.full_messages }
      end
    end
  end
end
