# frozen_string_literal: true

# Backward compatibility alias for PlebisGamification::Gamification
# This allows Gamifiable concern and other parts of the app to reference
# Gamification::UserStats instead of PlebisGamification::Gamification::UserStats

# Only define aliases if the engine is loaded
if defined?(PlebisGamification::Gamification)
  module Gamification
    # Explicit class aliases for common gamification classes
    UserStats = PlebisGamification::Gamification::UserStats
    Point = PlebisGamification::Gamification::Point
    Badge = PlebisGamification::Gamification::Badge
    UserBadge = PlebisGamification::Gamification::UserBadge
  end
else
  # If gamification engine is not loaded, create stub classes to prevent errors
  module Gamification
    class UserStats < ApplicationRecord
      self.table_name = 'gamification_user_stats'
      belongs_to :user
    end

    class Point < ApplicationRecord
      self.table_name = 'gamification_points'
      belongs_to :user
    end

    class Badge < ApplicationRecord
      self.table_name = 'gamification_badges'
    end

    class UserBadge < ApplicationRecord
      self.table_name = 'gamification_user_badges'
      belongs_to :user
      belongs_to :badge, class_name: 'Gamification::Badge'
    end
  end
end
