# frozen_string_literal: true

module Types
  class NotificationType < Types::BaseObject
    description "A notification for a user"

    field :id, ID, null: false
    field :title, String, null: false
    field :body, String, null: true
    field :notification_type, String, null: false
    field :read_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :user, Types::UserType, null: false

    field :is_read, Boolean, null: false do
      description "Whether this notification has been read"
    end

    def is_read
      object.read_at.present?
    end
  end
end
