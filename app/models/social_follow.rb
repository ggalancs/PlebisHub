# frozen_string_literal: true

# ================================================================
# SocialFollow - Social Following Relationships
# ================================================================
# Manages follower/following relationships between users
# ================================================================

class SocialFollow < ApplicationRecord
  self.table_name = 'social_follows'

  # Associations
  belongs_to :follower, class_name: 'User'
  belongs_to :followee, class_name: 'User'

  # Validations
  validates :follower_id, presence: true
  validates :followee_id, presence: true
  validates :follower_id, uniqueness: { scope: :followee_id, message: "Already following this user" }
  validate :cannot_follow_self

  # Callbacks
  after_create :publish_follow_event
  after_destroy :publish_unfollow_event

  private

  def cannot_follow_self
    if follower_id == followee_id
      errors.add(:base, "You cannot follow yourself")
    end
  end

  def publish_follow_event
    EventBus.instance.publish('user.followed', {
      follower_id: follower_id,
      followee_id: followee_id,
      followed_at: created_at
    })
  end

  def publish_unfollow_event
    EventBus.instance.publish('user.unfollowed', {
      follower_id: follower_id,
      followee_id: followee_id,
      unfollowed_at: Time.current
    })
  end
end
