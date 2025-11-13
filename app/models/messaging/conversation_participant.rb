# frozen_string_literal: true

module Messaging
  # ================================================================
  # Messaging::ConversationParticipant - Conversation Members
  # ================================================================
  # Tracks who is in each conversation
  # ================================================================

  class ConversationParticipant < ApplicationRecord
    self.table_name = 'messaging_conversation_participants'

    # Associations
    belongs_to :conversation, class_name: 'Messaging::Conversation'
    belongs_to :user

    # Validations
    validates :user_id, uniqueness: { scope: :conversation_id }
    validates :joined_at, presence: true

    # Scopes
    scope :active, -> { where(left_at: nil) }
    scope :left, -> { where.not(left_at: nil) }

    # Instance methods
    def active?
      left_at.nil?
    end

    def left?
      left_at.present?
    end

    def leave!
      update(left_at: Time.current)
    end

    def rejoin!
      update(left_at: nil, joined_at: Time.current)
    end
  end
end
