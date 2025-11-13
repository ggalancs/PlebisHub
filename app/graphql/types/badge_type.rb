# frozen_string_literal: true

module Types
  class BadgeType < Types::BaseObject
    description "A gamification badge"

    field :id, ID, null: false
    field :key, String, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :icon, String, null: true
    field :tier, String, null: true
    field :category, String, null: true
    field :points_reward, Integer, null: false

    field :earned_at, GraphQL::Types::ISO8601DateTime, null: true do
      description "When the current user earned this badge (if earned)"
    end

    def earned_at
      return nil unless context[:current_user]

      user_badge = object.user_badges.find_by(user: context[:current_user])
      user_badge&.earned_at
    end
  end
end
