# frozen_string_literal: true

module EngineUser
  # Proposer Concern
  #
  # Extends User model with citizen proposal-related associations and methods.
  # This concern is loaded when the plebis_proposals engine is active.
  #
  module Proposer
    extend ActiveSupport::Concern

    included do
      # Associations for proposals
      has_many :supports, dependent: :destroy
      # Note: Proposal model has user_id for author
      # has_many :proposals # This could be added if needed
    end

    # Get user's proposals (as author)
    # This is a convenience method
    #
    # @return [ActiveRecord::Relation] User's proposals
    #
    def proposals
      Proposal.where(user_id: self.id)
    end

    # Check if user has supported a proposal
    #
    # @param proposal [Proposal] The proposal to check
    # @return [Boolean] Whether user has supported the proposal
    #
    def has_supported?(proposal)
      self.supports.where(proposal_id: proposal.id).exists?
    end
  end
end
