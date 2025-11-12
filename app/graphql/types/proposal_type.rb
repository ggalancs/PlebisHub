# frozen_string_literal: true

module Types
  class ProposalType < Types::BaseObject
    description "A proposal in the PlebisHub platform"

    field :id, ID, null: false
    field :title, String, null: false
    field :body, String, null: true
    field :summary, String, null: true
    field :category, String, null: true
    field :status, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :published_at, GraphQL::Types::ISO8601DateTime, null: true

    # Author
    field :author, Types::UserType, null: false do
      description "The user who created this proposal"
    end

    # Voting stats
    field :votes_count, Integer, null: false do
      description "Total number of votes"
    end

    field :votes_distribution, GraphQL::Types::JSON, null: false do
      description "Distribution of votes by option"
    end

    field :current_user_vote, Types::ProposalVoteType, null: true do
      description "Current user's vote on this proposal"
    end

    # Comments
    field :comments_count, Integer, null: false do
      description "Number of comments on this proposal"
    end

    field :comments, [Types::ProposalCommentType], null: false do
      description "Comments on this proposal"
      argument :limit, Integer, required: false, default_value: 10
    end

    # Resolvers
    def votes_distribution
      # Calculate vote distribution from proposal_votes (V2)
      object.proposal_votes.group(:option).count
    end

    def current_user_vote
      return nil unless context[:current_user]

      object.proposal_votes.find_by(user: context[:current_user])
    end

    def comments(limit:)
      object.proposal_comments.order(created_at: :desc).limit(limit)
    end
  end
end
