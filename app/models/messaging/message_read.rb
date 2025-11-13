# frozen_string_literal: true

module Messaging
  # ================================================================
  # Messaging::MessageRead - Message Read Receipts
  # ================================================================
  # Tracks who has read which messages
  # ================================================================

  class MessageRead < ApplicationRecord
    self.table_name = 'messaging_message_reads'

    # Associations
    belongs_to :message, class_name: 'Messaging::Message'
    belongs_to :user

    # Validations
    validates :user_id, uniqueness: { scope: :message_id }
    validates :read_at, presence: true

    # Scopes
    scope :recent, -> { order(read_at: :desc) }
  end
end
