# frozen_string_literal: true

module Types
  class ProposalCommentType < Types::BaseObject
    description "A comment on a proposal with threading support"

    field :id, ID, null: false
    field :body, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :flagged, Boolean, null: false
    field :upvotes, Integer, null: false

    field :author, Types::UserType, null: false
    field :proposal, Types::ProposalType, null: false
    field :parent, Types::ProposalCommentType, null: true do
      description "Parent comment for threaded replies"
    end
    field :replies, [Types::ProposalCommentType], null: false do
      description "Child comments (replies)"
    end

    # Helper methods
    def flagged
      object.flagged || false
    end

    def upvotes
      object.upvotes || 0
    end
  end
end
