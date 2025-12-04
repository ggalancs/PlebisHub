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
               class_name: 'Vote',
               inverse_of: :paper_authority,
               foreign_key: :paper_authority_id
    end

    # Returns a vote for the given election, creating it if necessary
    # SECURITY FIX SEC-037: Added race condition handling
    #
    # @param election_id [Integer] The election ID
    # @return [Vote] The vote instance
    #
    def get_or_create_vote(election_id)
      votes.find_or_create_by!(election_id: election_id) do |vote|
        vote.created_at = Time.current
      end
    rescue ActiveRecord::RecordNotUnique
      # Race condition occurred - retry with existing record
      votes.find_by!(election_id: election_id)
    end

    # Check if user has already voted in a specific election
    #
    # @param election_id [Integer] The election ID
    # @return [Boolean] Whether the user has voted
    #
    def has_already_voted_in?(election_id)
      # Use exists? instead of present? to avoid loading records (performance)
      Vote.exists?(election_id: election_id, user_id: id)
    end

    # Check if user can vote in a specific election
    # Requires verification and vote circle membership
    #
    # @param election [Election] The election object
    # @return [Boolean] Whether the user can vote
    #
    def can_vote_in?(election)
      verified? && vote_circle.present? && election&.has_valid_location_for?(self)
    end
  end
end
