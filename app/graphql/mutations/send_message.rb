# frozen_string_literal: true

module Mutations
  class SendMessage < BaseMutation
    description "Send a message in a conversation"

    argument :conversation_id, ID, required: true
    argument :body, String, required: true

    field :message, Types::MessageType, null: true
    field :errors, [String], null: false

    def resolve(conversation_id:, body:)
      authorize!

      conversation = Messaging::Conversation.find(conversation_id)

      message = conversation.messages.build(
        sender: current_user,
        body: body
      )

      if message.save
        # Publish event
        publish_event('message.sent', {
          message_id: message.id,
          conversation_id: conversation.id
        })

        # Trigger subscription
        PlebishubSchema.subscriptions.trigger(
          'messageReceived',
          { conversation_id: conversation_id },
          message
        )

        { message: message, errors: [] }
      else
        { message: nil, errors: message.errors.full_messages }
      end
    end
  end
end
