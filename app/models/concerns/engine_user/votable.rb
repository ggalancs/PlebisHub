# frozen_string_literal: true

module EngineUser
  # Votable Concern
  #
  # Extends User model with voting-related associations and methods.
  # This concern is loaded when the plebis_voting engine is active.
  #
  module Votable
    extend ActiveSupport::Concern

    included do
      # Associations for voting system
      has_many :votes, dependent: :destroy
      has_many :paper_authority_votes,
               dependent: :nullify,
               class_name: "Vote",
               inverse_of: :paper_authority,
               foreign_key: :paper_authority_id
    end

    # Returns a vote for the given election, creating it if necessary
    #
    # @param election_id [Integer] The election ID
    # @return [Vote] The vote instance
    #
    def get_or_create_vote(election_id)
      v = Vote.new(election_id: election_id, user_id: self.id)
      if Vote.find_by_voter_id(v.generate_message)
        return v
      else
        v.save
        return v
      end
    end

    # Check if user has already voted in a specific election
    #
    # @param election_id [Integer] The election ID
    # @return [Boolean] Whether the user has voted
    #
    def has_already_voted_in?(election_id)
      # Use exists? instead of present? to avoid loading records (performance)
      Vote.where(election_id: election_id, user_id: self.id).exists?
    end

    # Check if user can vote in a specific election
    # Requires verification and vote circle membership
    #
    # @param election [Election] The election object
    # @return [Boolean] Whether the user can vote
    #
    def can_vote_in?(election)
      verified? && vote_circle&.present? && election&.has_valid_location_for?(self)
    end
  end
end
