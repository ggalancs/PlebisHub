# frozen_string_literal: true

module Types
  class MessageType < Types::BaseObject
    description "A message in a conversation"

    field :id, ID, null: false
    field :body, String, null: false
    field :message_type, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :sender, Types::UserType, null: false
    field :conversation_id, ID, null: false

    field :read_by, [Types::UserType], null: false do
      description "Users who have read this message"
    end

    def read_by
      object.message_reads.includes(:user).map(&:user)
    end
  end
end
