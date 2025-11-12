# frozen_string_literal: true

module Types
  class VoteType < Types::BaseObject
    description "A vote on a proposal"

    field :id, ID, null: false
    field :option, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :user, Types::UserType, null: false
    field :proposal, Types::ProposalType, null: false
  end
end
