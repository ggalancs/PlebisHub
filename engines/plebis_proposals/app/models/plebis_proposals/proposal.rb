# frozen_string_literal: true

require 'numeric'

module PlebisProposals
  class Proposal < ApplicationRecord
    self.table_name = 'proposals'

    # Associations
    has_many :supports, class_name: 'PlebisProposals::Support', dependent: :destroy

    # Validations
    validates :title, presence: true
    validates :description, presence: true
    validates :votes, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :supports_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
    validates :hotness, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

    # Scopes
    scope :reddit,  -> { where(reddit_threshold: true) }
    scope :recent,  -> { order(created_at: :desc) }
    scope :popular, -> { order(supports_count: :desc) }
    scope :time,    -> { order(:created_at) }
    scope :hot,     -> { order(hotness: :desc) }
    scope :active,  -> { where('created_at > ?', 3.months.ago) }
    scope :finished, -> { where(created_at: ..3.months.ago) }

    # Callbacks
    before_save :update_threshold

    # Track if reddit_threshold was explicitly set
    attr_accessor :skip_threshold_update

    def update_threshold
      # Set to true if votes meet threshold
      return if skip_threshold_update

      return unless reddit_required_votes?

      if new_record?
        # On create, don't override if explicitly set to false via accessor
        self.reddit_threshold = true unless @reddit_threshold_explicitly_set == false
      else
        # On update, always set to true if threshold met
        self.reddit_threshold = true
      end
    end

    def reddit_threshold=(value)
      @reddit_threshold_explicitly_set = value if value == false
      super
    end

    def support_percentage
      current_supports_count.percent_of(confirmed_users)
    end

    def confirmed_users
      User.confirmed.count
    end

    def remaining_endorsements_for_approval
      (monthly_email_required_votes - votes).to_i
    end

    def reddit_required_votes
      (0.2.percent * confirmed_users).to_i
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
      current_supports_count >= monthly_email_required_votes
    end

    def agoravoting_required_votes?
      current_supports_count >= agoravoting_required_votes
    end

    def finished?
      finishes_at < Time.zone.today
    end

    def discarded?
      finished? && !agoravoting_required_votes?
    end

    def finishes_at
      (created_at || Time.current) + 3.months
    end

    def supported?(user)
      return false unless user

      user.supports.where(proposal: self).any?
    end

    def supportable?(_user)
      !(finished? || discarded?)
    end

    def self.filter(filtering_params)
      results = reddit
      results = results.public_send(filtering_params) if filtering_params.present?
      results
    end

    def hotness
      current_supports_count + (days_since_created * 1000)
    end

    def days_since_created
      return 0 unless created_at

      ((Time.zone.now - created_at) / 60 / 60 / 24).to_i
    end

    # Override the association count to only count supports before finishes_at
    def supports_count
      calculate_supports_count
    end

    # Get the current supports count - either from the column or by counting
    def current_supports_count
      self[:supports_count] || calculate_supports_count
    end

    # Calculate supports count based on supports within the finish date
    def calculate_supports_count
      supports.where('created_at<?', finishes_at).count
    end
  end
end
