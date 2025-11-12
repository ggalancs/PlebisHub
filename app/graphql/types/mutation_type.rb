# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    description "The mutation root of PlebisHub's GraphQL schema"

    # ==================== Proposal Mutations ====================

    field :create_proposal, mutation: Mutations::CreateProposal
    field :update_proposal, mutation: Mutations::UpdateProposal
    field :delete_proposal, mutation: Mutations::DeleteProposal

    # ==================== Vote Mutations ====================

    field :cast_vote, mutation: Mutations::CastVote
    field :change_vote, mutation: Mutations::ChangeVote

    # ==================== Comment Mutations ====================

    field :create_comment, mutation: Mutations::CreateComment
    field :update_comment, mutation: Mutations::UpdateComment
    field :delete_comment, mutation: Mutations::DeleteComment

    # ==================== Social Mutations ====================

    field :follow_user, mutation: Mutations::FollowUser
    field :unfollow_user, mutation: Mutations::UnfollowUser

    # ==================== Messaging Mutations ====================

    field :send_message, mutation: Mutations::SendMessage
    field :create_conversation, mutation: Mutations::CreateConversation
  end
end
