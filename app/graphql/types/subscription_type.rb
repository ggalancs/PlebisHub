# frozen_string_literal: true

module Types
  class SubscriptionType < Types::BaseObject
    description "The subscription root for real-time updates"

    # ==================== Proposal Subscriptions ====================

    field :proposal_updated, Types::ProposalType, null: false do
      description "Subscribe to updates on a specific proposal"
      argument :proposal_id, ID, required: true
    end

    def proposal_updated(proposal_id:)
      # This will be triggered by Action Cable when a proposal is updated
      # The implementation uses GraphQL subscriptions over Action Cable
    end

    # ==================== Messaging Subscriptions ====================

    field :message_received, Types::MessageType, null: false do
      description "Subscribe to new messages in a conversation"
      argument :conversation_id, ID, required: true
    end

    def message_received(conversation_id:)
      # Triggered when a new message is sent to the conversation
    end

    # ==================== Notification Subscriptions ====================

    field :notification_received, Types::NotificationType, null: false do
      description "Subscribe to notifications for the current user"
    end

    def notification_received
      # Triggered when the current user receives a notification
    end

    # ==================== Vote Subscriptions ====================

    field :vote_cast, Types::VoteType, null: false do
      description "Subscribe to new votes on a proposal"
      argument :proposal_id, ID, required: true
    end

    def vote_cast(proposal_id:)
      # Triggered when a vote is cast on the proposal
    end
  end
end
