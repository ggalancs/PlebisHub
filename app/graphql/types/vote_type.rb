# frozen_string_literal: true

module Types
  class ProposalVoteType < Types::BaseObject
    description "A vote on a proposal (yes/no/abstain)"

    field :id, ID, null: false
    field :option, String, null: false do
      description "Vote option: yes, no, or abstain"
    end
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :user, Types::UserType, null: false
    field :proposal, Types::ProposalType, null: false

    # Helper methods
    def proposal
      object.proposal
    end
  end
end
