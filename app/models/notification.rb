# frozen_string_literal: true

# ================================================================
# Notification - User Notifications System
# ================================================================
# Multi-channel notifications (in-app, email, push, SMS)
# ================================================================

class Notification < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  # Validations
  validates :title, presence: true
  validates :notification_type, presence: true
  validates :channels, presence: true

  # Serialize channels as array
  serialize :channels, coder: JSON
  serialize :metadata, coder: JSON

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :unsent, -> { where(sent_at: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :by_type, ->(type) { where(notification_type: type) }

  # Notification types
  TYPES = %w[
    proposal_created
    proposal_approved
    proposal_rejected
    vote_cast
    comment_received
    mention
    follower_new
    badge_earned
    points_earned
    message_received
    system_announcement
  ].freeze

  # Channel types
  CHANNELS = %w[in_app email push sms].freeze

  # Class methods
  def self.notify!(user, type, options = {})
    create!(
      user: user,
      notification_type: type,
      title: options[:title],
      body: options[:body],
      notifiable: options[:notifiable],
      channels: options[:channels] || ['in_app'],
      metadata: options[:metadata] || {}
    )
  end

  # Instance methods
  def mark_as_read!
    update(read_at: Time.current) unless read?
  end

  def mark_as_unread!
    update(read_at: nil) if read?
  end

  def mark_as_sent!
    update(sent_at: Time.current) unless sent?
  end

  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  def sent?
    sent_at.present?
  end

  def unsent?
    !sent?
  end

  def send_via_email!
    return unless channels.include?('email')

    # TODO: Implement email sending
    NotificationMailer.notify(self).deliver_later
    mark_as_sent!
  rescue StandardError => e
    Rails.logger.error "Failed to send notification email: #{e.message}"
  end

  def send_via_push!
    return unless channels.include?('push')

    # TODO: Implement push notification
    PushNotificationService.send(user, self)
  rescue StandardError => e
    Rails.logger.error "Failed to send push notification: #{e.message}"
  end

  def send_via_sms!
    return unless channels.include?('sms')

    # TODO: Implement SMS sending
    SmsService.send(user.phone, body)
  rescue StandardError => e
    Rails.logger.error "Failed to send SMS notification: #{e.message}"
  end

  def deliver!
    send_via_email! if channels.include?('email')
    send_via_push! if channels.include?('push')
    send_via_sms! if channels.include?('sms')
    mark_as_sent!
  end
end
