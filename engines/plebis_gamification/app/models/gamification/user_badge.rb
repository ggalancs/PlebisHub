# frozen_string_literal: true

module Gamification
  # ==================================
  # User Badge Association
  # ==================================
  # Records when a user earns a badge
  # ==================================

  class UserBadge < ApplicationRecord
    self.table_name = 'gamification_user_badges'

    belongs_to :user
    belongs_to :badge, class_name: 'Gamification::Badge'

    validates :user_id, presence: true
    validates :badge_id, presence: true
    validates :earned_at, presence: true
    validates :user_id, uniqueness: { scope: :badge_id }

    scope :recent, -> { order(earned_at: :desc) }
    scope :by_category, ->(category) { joins(:badge).where(gamification_badges: { category: category }) }
    scope :by_tier, ->(tier) { joins(:badge).where(gamification_badges: { tier: tier }) }

    after_create :notify_user

    def as_json_summary
      {
        id: id,
        badge: {
          key: badge.key,
          name: badge.name,
          description: badge.description,
          icon: badge.icon,
          tier: badge.tier,
          category: badge.category
        },
        earned_at: earned_at.iso8601,
        metadata: metadata
      }
    end

    private

    def notify_user
      # Notification already sent by BadgeAwarder service
    end
  end
end
