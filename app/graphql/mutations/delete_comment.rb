# frozen_string_literal: true

module Mutations
  class DeleteComment < BaseMutation
    argument :id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(id:)
      comment = Comment.find(id)
      authorize!(comment)

      if comment.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: comment.errors.full_messages }
      end
    end
  end
end
