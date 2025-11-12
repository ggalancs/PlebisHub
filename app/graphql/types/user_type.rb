# frozen_string_literal: true

module Types
  class UserType < Types::BaseObject
    description "A user in the PlebisHub platform"

    field :id, ID, null: false
    field :email, String, null: false
    field :full_name, String, null: true
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :username, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Gamification fields
    field :level, Integer, null: true do
      description "User's gamification level"
    end

    field :total_points, Integer, null: true do
      description "User's total gamification points"
    end

    field :badges, [Types::BadgeType], null: false do
      description "User's earned badges"
    end

    field :current_streak, Integer, null: true do
      description "User's current activity streak in days"
    end

    # Associations
    field :proposals, [Types::ProposalType], null: false do
      description "Proposals created by this user"
    end

    field :votes, [Types::VoteType], null: false do
      description "Votes cast by this user"
    end

    # Social fields
    field :followers_count, Integer, null: false do
      description "Number of followers"
    end

    field :following_count, Integer, null: false do
      description "Number of users being followed"
    end

    field :is_following, Boolean, null: false do
      description "Whether the current user is following this user"
    end

    # Resolvers
    def level
      object.gamification_stats&.level || 1
    end

    def total_points
      object.gamification_stats&.total_points || 0
    end

    def badges
      object.user_badges.includes(:badge).map(&:badge)
    end

    def current_streak
      object.gamification_stats&.current_streak || 0
    end

    def followers_count
      object.followers.count
    end

    def following_count
      object.following.count
    end

    def is_following
      return false unless context[:current_user]

      context[:current_user].following?(object)
    end
  end
end
