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

    validates :earned_at, presence: true
    validates :user_id, uniqueness: { scope: :badge_id }

    scope :recent, -> { order(earned_at: :desc) }
    scope :by_category, ->(category) { joins(:badge).where(gamification_badges: { category: category }) }
    scope :by_tier, ->(tier) { joins(:badge).where(gamification_badges: { tier: tier }) }

    after_create :notify_user

    def as_json_summary
      badge_hash = {}
      badge_hash[:key] = badge.key
      badge_hash[:name] = badge.name
      badge_hash[:description] = badge.description
      badge_hash[:icon] = badge.icon
      badge_hash[:tier] = badge.tier
      badge_hash[:category] = badge.category

      summary = {}
      summary[:id] = id
      summary[:badge] = badge_hash
      summary[:earned_at] = earned_at.iso8601
      summary[:metadata] = metadata
      summary
    end

    private

    def notify_user
      # Notification already sent by BadgeAwarder service
    end
  end
end
