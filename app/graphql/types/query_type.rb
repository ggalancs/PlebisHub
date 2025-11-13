# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    description "The query root of PlebisHub's GraphQL schema"

    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # ==================== User Queries ====================

    field :me, Types::UserType, null: true do
      description "Get the currently authenticated user"
    end

    def me
      context[:current_user]
    end

    field :user, Types::UserType, null: true do
      description "Find a user by ID"
      argument :id, ID, required: true
    end

    def user(id:)
      User.find(id)
    end

    field :users, [Types::UserType], null: false do
      description "Get all users"
      argument :limit, Integer, required: false, default_value: 20
      argument :offset, Integer, required: false, default_value: 0
    end

    def users(limit:, offset:)
      User.limit(limit).offset(offset)
    end

    # ==================== Proposal Queries ====================

    field :proposal, Types::ProposalType, null: true do
      description "Find a proposal by ID"
      argument :id, ID, required: true
    end

    def proposal(id:)
      Proposal.find(id)
    end

    field :proposals, [Types::ProposalType], null: false do
      description "Get proposals with optional filters"
      argument :category, String, required: false
      argument :status, String, required: false
      argument :limit, Integer, required: false, default_value: 20
      argument :offset, Integer, required: false, default_value: 0
    end

    def proposals(category: nil, status: nil, limit: 20, offset: 0)
      scope = Proposal.all
      scope = scope.where(category: category) if category.present?
      scope = scope.where(status: status) if status.present?
      scope.order(created_at: :desc).limit(limit).offset(offset)
    end

    # ==================== Gamification Queries ====================

    field :badges, [Types::BadgeType], null: false do
      description "Get all available badges"
      argument :category, String, required: false
    end

    def badges(category: nil)
      scope = Gamification::Badge.all
      scope = scope.where(category: category) if category.present?
      scope
    end

    field :leaderboard, [Types::UserType], null: false do
      description "Get leaderboard of top users"
      argument :period, String, required: false, default_value: "all_time"
      argument :limit, Integer, required: false, default_value: 100
    end

    def leaderboard(period:, limit:)
      # Get users ordered by total points
      User.joins(:gamification_stats)
          .order('gamification_user_stats.total_points DESC')
          .limit(limit)
    end

    # ==================== Analytics Queries ====================

    field :analytics_metrics, GraphQL::Types::JSON, null: false do
      description "Get analytics metrics"
      argument :metric_name, String, required: true
      argument :start_date, GraphQL::Types::ISO8601Date, required: false
      argument :end_date, GraphQL::Types::ISO8601Date, required: false
    end

    def analytics_metrics(metric_name:, start_date: nil, end_date: nil)
      # Placeholder for analytics implementation
      {
        metric: metric_name,
        data: [],
        period: { start: start_date, end: end_date }
      }
    end
  end
end
