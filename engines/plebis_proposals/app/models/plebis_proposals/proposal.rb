# frozen_string_literal: true

require 'numeric'

module PlebisProposals
  class Proposal < ApplicationRecord
    self.table_name = 'proposals'

    # Associations
    has_many :supports, class_name: 'PlebisProposals::Support', dependent: :destroy

    # V2.0 Associations
    belongs_to :author, class_name: 'User', optional: true # V2 author field
    has_many :proposal_votes, dependent: :destroy, foreign_key: :proposal_id
    has_many :proposal_comments, dependent: :destroy, foreign_key: :proposal_id
    has_many :voters, through: :proposal_votes, source: :user

    # Validations
    validates :title, presence: true
    validates :description, presence: true
    validates :votes, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :supports_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :hotness, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    # Scopes
    scope :reddit,  -> { where(reddit_threshold: true) }
    scope :recent,  -> { order('created_at desc') }
    scope :popular, -> { order('supports_count desc') }
    scope :time,    -> { order('created_at asc') }
    scope :hot,     -> { order('hotness desc') }
    scope :active,  -> { where('created_at > ?', 3.months.ago) }
    scope :finished, -> { where('created_at <= ?', 3.months.ago) }

    # Callbacks
    before_save :update_threshold

    def update_threshold
      self.reddit_threshold = true if reddit_required_votes?
    end

    def support_percentage
      supports_count.percent_of(confirmed_users)
    end

    def confirmed_users
      User.confirmed.count
    end

    def remaining_endorsements_for_approval
      (monthly_email_required_votes - votes).to_i
    end

    def reddit_required_votes
      ((0.2).percent * confirmed_users).to_i
    end

    def monthly_email_required_votes
      (2.percent * confirmed_users).to_i
    end

    def agoravoting_required_votes
      (10.percent * confirmed_users).to_i
    end

    def reddit_required_votes?
      votes >= reddit_required_votes
    end

    def monthly_email_required_votes?
      supports_count >= monthly_email_required_votes
    end

    def agoravoting_required_votes?
      supports_count >= agoravoting_required_votes
    end

    def finished?
      finishes_at<Date.today
    end

    def discarded?
      finished? && !agoravoting_required_votes?
    end

    def finishes_at
      created_at + 3.months
    end

    def supported?(user)
      return false unless user
      user.supports.where(proposal: self).any?
    end

    def supportable? user
      not (finished? || discarded?)
    end

    def self.filter(filtering_params)
      results = self.reddit
      results = results.public_send(filtering_params) if filtering_params.present?
      results
    end

    def hotness
      supports_count + (days_since_created * 1000)
    end

    def days_since_created
      ((Time.now - created_at)/60/60/24).to_i
    end

    def supports_count
      supports.where("created_at<?", finishes_at).count
    end

    # ================================================================
    # V2.0 Methods - Backward Compatibility & New Features
    # ================================================================

    # Alias for GraphQL compatibility (body maps to description for V1)
    def body
      description
    end

    def body=(value)
      self.description = value
    end

    # V2 Category handling (will use actual column when migration is run)
    def category
      read_attribute(:category) if has_attribute?(:category)
    end

    # V2 Status handling (will use actual column when migration is run)
    def status
      return read_attribute(:status) if has_attribute?(:status)

      # Fallback to calculated status based on V1 logic
      return 'finished' if finished?
      return 'discarded' if discarded?
      'active'
    end

    # V2 Organization handling (will use actual column when migration is run)
    def organization_id
      read_attribute(:organization_id) if has_attribute?(:organization_id)
    end

    # V2 Published date handling (will use actual column when migration is run)
    def published_at
      read_attribute(:published_at) || created_at if has_attribute?(:published_at)
    end

    # V2 Votes counter cache (will use actual column when migration is run)
    def votes_count
      return read_attribute(:votes_count) if has_attribute?(:votes_count)
      proposal_votes.count
    end

    # V2 Comments counter cache (will use actual column when migration is run)
    def comments_count
      return read_attribute(:comments_count) if has_attribute?(:comments_count)
      proposal_comments.count
    end

    # Check if attribute exists in schema
    def has_attribute?(attr_name)
      self.class.column_names.include?(attr_name.to_s)
    end
  end
end
