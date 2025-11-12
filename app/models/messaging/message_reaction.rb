# frozen_string_literal: true

module Messaging
  # ================================================================
  # Messaging::MessageReaction - Message Emoji Reactions
  # ================================================================
  # Allows users to react to messages with emojis
  # ================================================================

  class MessageReaction < ApplicationRecord
    self.table_name = 'messaging_message_reactions'

    # Associations
    belongs_to :message, class_name: 'Messaging::Message'
    belongs_to :user

    # Validations
    validates :emoji, presence: true
    validates :user_id, uniqueness: { scope: [:message_id, :emoji] }

    # Scopes
    scope :by_emoji, ->(emoji) { where(emoji: emoji) }
    scope :recent, -> { order(created_at: :desc) }
  end
end
