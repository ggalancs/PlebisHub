# frozen_string_literal: true

module Gamification
  # ==================================
  # Badge Awarder Service
  # ==================================
  # Checks and awards badges to users automatically
  # ==================================

  class BadgeAwarder
    class << self
      # Check and award all eligible badges for user
      def check_and_award!(user)
        UserStats.for_user(user)
        awarded_badges = []

        Badge.find_each do |badge|
          next if user_has_badge?(user, badge)
          next unless badge.criteria_met?(user)

          awarded_badge = award_badge!(user, badge)
          awarded_badges << awarded_badge if awarded_badge
        end

        awarded_badges
      end

      # Award specific badge to user
      def award_badge!(user, badge)
        return nil if user_has_badge?(user, badge)

        user_badge = UserBadge.create!(
          user: user,
          badge: badge,
          earned_at: Time.current
        )

        # Award bonus points
        if badge.points_reward.positive?
          stats = UserStats.for_user(user)
          stats.earn_points!(
            badge.points_reward,
            reason: "Badge earned: #{badge.name}",
            source: badge
          )
        end

        # Publish event
        publish_event('gamification.badge_earned', {
                        user_id: user.id,
                        badge_id: badge.id,
                        badge_name: badge.name,
                        points_reward: badge.points_reward
                      })

        # Send notification
        Notification.create!(
          user: user,
          notification_type: 'badge_earned',
          title: "¡Badge desbloqueado! #{badge.icon}",
          body: "Has ganado el badge '#{badge.name}': #{badge.description}",
          notifiable: user_badge,
          channels: %w[push in_app]
        )

        user_badge
      end

      private

      def user_has_badge?(user, badge)
        UserBadge.exists?(user_id: user.id, badge_id: badge.id)
      end

      def publish_event(event_name, payload = {})
        EventBus.instance.publish(event_name, payload)
      end
    end
  end
end
