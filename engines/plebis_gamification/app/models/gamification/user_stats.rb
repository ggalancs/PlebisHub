# frozen_string_literal: true

module Gamification
  # ==================================
  # User Gamification Statistics
  # ==================================
  # Tracks points, level, XP, streaks for each user
  # ==================================

  class UserStats < ApplicationRecord
    self.table_name = 'gamification_user_stats'

    belongs_to :user
    has_many :points, class_name: 'Gamification::Point', foreign_key: :user_id, primary_key: :user_id
    has_many :user_badges, class_name: 'Gamification::UserBadge', foreign_key: :user_id, primary_key: :user_id
    has_many :badges, through: :user_badges

    # Validations
    validates :user_id, uniqueness: true
    validates :total_points, :level, :xp, :current_streak, :longest_streak,
              numericality: { greater_than_or_equal_to: 0 }

    # Scopes
    scope :top_users, ->(limit = 10) { order(total_points: :desc).limit(limit) }
    scope :by_level, ->(level) { where(level: level) }
    scope :active_today, -> { where(last_active_date: Time.zone.today) }

    # Level configuration
    LEVELS = {
      1 => { name: 'Novato', xp: 0 },
      2 => { name: 'Participante', xp: 100 },
      3 => { name: 'Colaborador', xp: 250 },
      4 => { name: 'Activista', xp: 500 },
      5 => { name: 'Defensor', xp: 1000 },
      10 => { name: 'Líder Comunitario', xp: 2500 },
      15 => { name: 'Agente de Cambio', xp: 5000 },
      20 => { name: 'Visionario', xp: 10_000 },
      25 => { name: 'Leyenda', xp: 25_000 }
    }.freeze

    # Earn points
    def earn_points!(amount, reason:, source: nil)
      raise ArgumentError, 'Amount must be positive' if amount <= 0

      transaction do
        # Create point record
        point = Gamification::Point.create!(
          user_id: user_id,
          amount: amount,
          reason: reason,
          source: source
        )

        # Update totals
        self.total_points += amount
        self.xp += amount

        # Check for level up
        check_level_up!

        # Update streak
        update_streak!

        save!

        # Publish event
        publish_event('gamification.points_earned', {
                        user_id: user_id,
                        amount: amount,
                        reason: reason,
                        total_points: total_points,
                        level: level
                      })

        # Check for new badges
        Gamification::BadgeAwarder.check_and_award!(user)

        point
      end
    end

    # Get level name
    def level_name
      LEVELS[level][:name] || "Nivel #{level}"
    end

    # XP needed for next level
    def xp_to_next_level
      next_level_config = LEVELS[level + 1]
      return 0 unless next_level_config

      next_level_config[:xp] - xp
    end

    # Progress to next level (0-100%)
    def level_progress_percentage
      return 100 if xp_to_next_level <= 0

      current_level_xp = LEVELS[level][:xp]
      next_level_xp = LEVELS[level + 1][:xp]
      level_range = next_level_xp - current_level_xp
      progress = xp - current_level_xp

      ((progress.to_f / level_range) * 100).round(2)
    end

    # Check if user should level up
    def check_level_up!
      while should_level_up?
        self.level += 1
        publish_event('gamification.level_up', {
                        user_id: user_id,
                        new_level: level,
                        level_name: level_name
                      })
      end
    end

    def should_level_up?
      next_level_config = LEVELS[level + 1]
      return false unless next_level_config

      xp >= next_level_config[:xp]
    end

    # Update streak
    def update_streak!
      today = Time.zone.today

      if last_active_date.nil?
        # First activity
        self.current_streak = 1
        self.last_active_date = today
      elsif last_active_date == today
        # Already active today, no change
      elsif last_active_date == today - 1.day
        # Consecutive day
        self.current_streak += 1
        self.last_active_date = today
        self.longest_streak = [longest_streak, current_streak].max

        # Streak milestone rewards
        award_streak_bonus! if (current_streak % 7).zero?
      else
        # Streak broken
        self.current_streak = 1
        self.last_active_date = today
      end
    end

    def award_streak_bonus!
      bonus_points = current_streak / 7 * 50
      earn_points!(bonus_points, reason: "Racha de #{current_streak} días")
    end

    # Leaderboard position
    def leaderboard_position
      UserStats.where('total_points > ?', total_points).count + 1
    end

    # Stats summary
    def summary
      {
        level: level,
        level_name: level_name,
        total_points: total_points,
        xp: xp,
        xp_to_next_level: xp_to_next_level,
        level_progress: level_progress_percentage,
        current_streak: current_streak,
        longest_streak: longest_streak,
        badges_count: user_badges.count,
        leaderboard_position: leaderboard_position
      }
    end

    # Class methods
    class << self
      # Get or create stats for user
      def for_user(user)
        find_or_create_by!(user_id: user.id)
      end

      # Leaderboard
      def leaderboard(scope: :global, period: :all_time, limit: 100)
        query = all

        case period
        when :today
          query = query.active_today
        when :week
          query = query.where(last_active_date: 1.week.ago..)
        when :month
          query = query.where(last_active_date: 1.month.ago..)
        end

        query.includes(:user)
             .order(total_points: :desc)
             .limit(limit)
             .map.with_index(1) do |stats, index|
               {
                 rank: index,
                 user: stats.user.as_json(only: %i[id first_name last_name]),
                 stats: stats.summary
               }
             end
      end
    end
  end
end
