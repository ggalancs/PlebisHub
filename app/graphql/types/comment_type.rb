# frozen_string_literal: true

module Types
  class CommentType < Types::BaseObject
    description "A comment on a proposal"

    field :id, ID, null: false
    field :body, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :author, Types::UserType, null: false
    field :proposal, Types::ProposalType, null: false
  end
end
