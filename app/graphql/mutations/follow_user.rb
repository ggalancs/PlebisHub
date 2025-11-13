# frozen_string_literal: true

module Mutations
  class FollowUser < BaseMutation
    argument :user_id, ID, required: true

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(user_id:)
      authorize!

      user_to_follow = User.find(user_id)

      if current_user.follow!(user_to_follow)
        { user: user_to_follow, errors: [] }
      else
        { user: nil, errors: ["Failed to follow user"] }
      end
    end
  end
end
