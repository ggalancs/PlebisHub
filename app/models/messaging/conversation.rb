# frozen_string_literal: true

module Messaging
  # ================================================================
  # Messaging::Conversation - Chat Conversations
  # ================================================================
  # Manages 1-on-1 and group chat conversations
  # ================================================================

  class Conversation < ApplicationRecord
    self.table_name = 'messaging_conversations'

    # Associations
    has_many :participants,
             class_name: 'Messaging::ConversationParticipant',
             dependent: :destroy

    has_many :users, through: :participants

    has_many :messages,
             class_name: 'Messaging::Message',
             dependent: :destroy

    belongs_to :organization, optional: true

    # Validations
    validates :conversation_type, presence: true, inclusion: { in: %w[direct group] }
    validate :direct_conversations_must_have_two_participants, on: :create
    validate :group_conversations_must_have_name, if: :group?

    # Serialize metadata as JSON
    serialize :metadata, coder: JSON

    # Scopes
    scope :direct, -> { where(conversation_type: 'direct') }
    scope :group, -> { where(conversation_type: 'group') }
    scope :recent, -> { order(last_message_at: :desc, created_at: :desc) }
    scope :for_user, ->(user) { joins(:participants).where(messaging_conversation_participants: { user_id: user.id }) }

    # Class methods
    def self.between(user1, user2)
      direct
        .joins(:participants)
        .where(messaging_conversation_participants: { user_id: [user1.id, user2.id] })
        .group('messaging_conversations.id')
        .having('COUNT(messaging_conversation_participants.id) = 2')
        .first
    end

    def self.create_between(user1, user2)
      existing = between(user1, user2)
      return existing if existing

      transaction do
        conversation = create!(conversation_type: 'direct')
        conversation.participants.create!(user: user1, joined_at: Time.current)
        conversation.participants.create!(user: user2, joined_at: Time.current)
        conversation
      end
    end

    def self.create_group(name, users, organization: nil)
      transaction do
        conversation = create!(
          conversation_type: 'group',
          name: name,
          organization: organization
        )

        users.each do |user|
          conversation.participants.create!(user: user, joined_at: Time.current)
        end

        conversation
      end
    end

    # Instance methods
    def direct?
      conversation_type == 'direct'
    end

    def group?
      conversation_type == 'group'
    end

    def add_participant(user)
      participants.create!(user: user, joined_at: Time.current)
    end

    def remove_participant(user)
      participant = participants.find_by(user: user)
      participant&.update(left_at: Time.current)
    end

    def participant_for(user)
      participants.find_by(user: user)
    end

    def unread_count_for(user)
      participant = participant_for(user)
      return 0 unless participant

      if participant.last_read_at
        messages.where('created_at > ?', participant.last_read_at).count
      else
        messages.count
      end
    end

    def mark_as_read_for(user)
      participant = participant_for(user)
      participant&.update(last_read_at: Time.current)
    end

    def last_message
      messages.order(created_at: :desc).first
    end

    def other_user(current_user)
      return nil unless direct?

      users.where.not(id: current_user.id).first
    end

    def display_name_for(current_user)
      if direct?
        other_user(current_user)&.full_name || 'Unknown User'
      else
        name || "Group Chat (#{participants.count} members)"
      end
    end

    private

    def direct_conversations_must_have_two_participants
      # This will be validated after participants are added
      # Skip on create, validate on update if needed
    end

    def group_conversations_must_have_name
      errors.add(:name, "is required for group conversations") if name.blank?
    end
  end
end
