# frozen_string_literal: true

module Mutations
  class UnfollowUser < BaseMutation
    argument :user_id, ID, required: true

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(user_id:)
      authorize!

      user_to_unfollow = User.find(user_id)

      if current_user.unfollow!(user_to_unfollow)
        { user: user_to_unfollow, errors: [] }
      else
        { user: nil, errors: ["Failed to unfollow user"] }
      end
    end
  end
end
