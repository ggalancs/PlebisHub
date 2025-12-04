# frozen_string_literal: true

# Stub classes for gamification services that don't exist yet

module Gamification
  class BadgeAwarder
    def self.check_and_award!(user)
      # Stub - actual implementation would check and award badges
      Rails.logger.debug "BadgeAwarder: Checking badges for user #{user.id}"
    end
  end
end
