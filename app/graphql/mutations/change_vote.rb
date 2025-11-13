# frozen_string_literal: true

module Mutations
  class ChangeVote < BaseMutation
    description "Change a vote option"

    argument :vote_id, ID, required: true
    argument :option, String, required: true

    field :vote, Types::ProposalVoteType, null: true
    field :errors, [String], null: false

    def resolve(vote_id:, option:)
      vote = ProposalVote.find(vote_id)
      authorize!(vote)

      old_option = vote.option

      if vote.update(option: option)
        publish_event('vote.changed', {
          vote_id: vote.id,
          old_option: old_option,
          new_option: option
        })

        { vote: vote, errors: [] }
      else
        { vote: nil, errors: vote.errors.full_messages }
      end
    end
  end
end
