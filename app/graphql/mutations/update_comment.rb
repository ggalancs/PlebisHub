# frozen_string_literal: true

module Mutations
  class UpdateComment < BaseMutation
    description "Update a comment"

    argument :id, ID, required: true
    argument :body, String, required: true

    field :comment, Types::ProposalCommentType, null: true
    field :errors, [String], null: false

    def resolve(id:, body:)
      comment = ProposalComment.find(id)
      authorize!(comment)

      if comment.update(body: body)
        { comment: comment, errors: [] }
      else
        { comment: nil, errors: comment.errors.full_messages }
      end
    end
  end
end
