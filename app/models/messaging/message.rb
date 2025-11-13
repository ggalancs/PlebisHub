# frozen_string_literal: true

module Messaging
  # ================================================================
  # Messaging::Message - Chat Messages
  # ================================================================
  # Individual messages within conversations
  # ================================================================

  class Message < ApplicationRecord
    self.table_name = 'messaging_messages'

    # Associations
    belongs_to :conversation, class_name: 'Messaging::Conversation'
    belongs_to :sender, class_name: 'User'

    has_many :message_reads,
             class_name: 'Messaging::MessageRead',
             dependent: :destroy

    has_many :message_reactions,
             class_name: 'Messaging::MessageReaction',
             dependent: :destroy

    # Validations
    validates :sender, presence: true
    validates :conversation, presence: true
    validates :message_type, inclusion: { in: %w[text system file image], allow_blank: true }
    validate :must_have_content

    # Serialize metadata as JSON
    serialize :metadata, coder: JSON

    # Scopes
    scope :recent, -> { order(created_at: :desc) }
    scope :oldest_first, -> { order(created_at: :asc) }
    scope :text_messages, -> { where(message_type: 'text') }
    scope :system_messages, -> { where(message_type: 'system') }
    scope :since, ->(timestamp) { where('created_at > ?', timestamp) }

    # Callbacks
    after_create :update_conversation_last_message_at
    after_create :publish_message_event
    after_create :create_read_receipt_for_sender

    # Instance methods
    def read_by?(user)
      message_reads.exists?(user: user)
    end

    def mark_as_read_by!(user)
      return if read_by?(user)

      message_reads.create!(user: user, read_at: Time.current)
    end

    def readers
      message_reads.includes(:user).map(&:user)
    end

    def add_reaction(user, emoji)
      message_reactions.create!(user: user, emoji: emoji)
    end

    def remove_reaction(user, emoji)
      message_reactions.where(user: user, emoji: emoji).destroy_all
    end

    def reactions_summary
      message_reactions.group(:emoji).count
    end

    def text?
      message_type == 'text' || message_type.nil?
    end

    def system?
      message_type == 'system'
    end

    def file?
      message_type == 'file'
    end

    def image?
      message_type == 'image'
    end

    private

    def must_have_content
      if body.blank? && metadata.blank?
        errors.add(:base, "Message must have body or metadata")
      end
    end

    def update_conversation_last_message_at
      conversation.update_column(:last_message_at, created_at)
    end

    def publish_message_event
      EventBus.instance.publish('message.sent', {
        message_id: id,
        conversation_id: conversation_id,
        sender_id: sender_id,
        created_at: created_at
      })
    end

    def create_read_receipt_for_sender
      # Sender automatically "reads" their own message
      mark_as_read_by!(sender)
    end
  end
end
