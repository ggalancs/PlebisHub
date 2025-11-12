# frozen_string_literal: true

# ========================================
# Gamifiable Concern
# ========================================
# Adds gamification features to User model
# ========================================

module Gamifiable
  extend ActiveSupport::Concern

  included do
    # Associations
    has_one :gamification_user_stats,
            class_name: 'Gamification::UserStats',
            dependent: :destroy

    has_many :gamification_points,
             class_name: 'Gamification::Point',
             dependent: :destroy

    has_many :gamification_user_badges,
             class_name: 'Gamification::UserBadge',
             dependent: :destroy

    has_many :gamification_badges,
             through: :gamification_user_badges,
             source: :badge,
             class_name: 'Gamification::Badge'

    # Callbacks
    after_create :initialize_gamification_stats
  end

  # Instance methods

  def gamification_stats
    @gamification_stats ||= gamification_user_stats || initialize_gamification_stats
  end

  # Shortcut methods
  def total_points
    gamification_stats.total_points
  end

  def level
    gamification_stats.level
  end

  def level_name
    gamification_stats.level_name
  end

  def current_streak
    gamification_stats.current_streak
  end

  def badges
    gamification_badges
  end

  def badges_count
    gamification_user_badges.count
  end

  def leaderboard_position
    gamification_stats.leaderboard_position
  end

  # Earn points
  def earn_points!(amount, reason:, source: nil)
    gamification_stats.earn_points!(amount, reason: reason, source: source)
  end

  # Check if user has specific badge
  def has_badge?(badge_key)
    gamification_badges.exists?(key: badge_key)
  end

  # Get all badges by category
  def badges_by_category
    gamification_badges.group_by(&:category)
  end

  # Gamification summary
  def gamification_summary
    {
      level: level,
      level_name: level_name,
      total_points: total_points,
      xp: gamification_stats.xp,
      xp_to_next_level: gamification_stats.xp_to_next_level,
      level_progress: gamification_stats.level_progress_percentage,
      current_streak: current_streak,
      longest_streak: gamification_stats.longest_streak,
      badges_count: badges_count,
      leaderboard_position: leaderboard_position,
      recent_badges: gamification_user_badges.recent.limit(5).map(&:as_json_summary)
    }
  end

  private

  def initialize_gamification_stats
    Gamification::UserStats.create!(user_id: id)
  end
end
