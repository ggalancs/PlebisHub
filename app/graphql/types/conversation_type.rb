# frozen_string_literal: true

module Types
  class ConversationType < Types::BaseObject
    description "A messaging conversation"

    field :id, ID, null: false
    field :name, String, null: true
    field :conversation_type, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :last_message_at, GraphQL::Types::ISO8601DateTime, null: true

    field :participants, [Types::UserType], null: false
    field :messages, [Types::MessageType], null: false do
      argument :limit, Integer, required: false, default_value: 50
    end

    field :unread_count, Integer, null: false do
      description "Number of unread messages for the current user"
    end

    def participants
      object.participants.map(&:user)
    end

    def messages(limit:)
      object.messages.order(created_at: :desc).limit(limit)
    end

    def unread_count
      return 0 unless context[:current_user]

      participant = object.participants.find_by(user: context[:current_user])
      return 0 unless participant

      object.messages
            .where('created_at > ?', participant.last_read_at || object.created_at)
            .count
    end
  end
end
