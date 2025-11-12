# frozen_string_literal: true

module Mutations
  class CreateConversation < BaseMutation
    argument :participant_ids, [ID], required: true
    argument :name, String, required: false

    field :conversation, Types::ConversationType, null: true
    field :errors, [String], null: false

    def resolve(participant_ids:, name: nil)
      authorize!

      # Implementation placeholder
      { conversation: nil, errors: ["Not implemented yet"] }
    end
  end
end
