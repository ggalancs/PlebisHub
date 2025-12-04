# frozen_string_literal: true

module EngineUser
  # Collaborator Concern
  #
  # Extends User model with collaboration/donation-related associations and methods.
  # This concern is loaded when the plebis_collaborations engine is active.
  #
  module Collaborator
    extend ActiveSupport::Concern

    included do
      # Associations for collaborations
      has_many :collaborations, dependent: :destroy
      # Orders can be polymorphic (used by collaborations and microcredits)
      # has_many :orders, as: :parent # This might be moved to a shared concern
    end

    # Returns the last recurrent collaboration (monthly/yearly)
    #
    # @return [Collaboration, nil] The last recurrent collaboration
    #
    def recurrent_collaboration
      collaborations.where.not(frequency: 0).last
    end

    # Returns the last single (one-time) collaboration
    #
    # @return [Collaboration, nil] The last single collaboration
    #
    def single_collaboration
      collaborations.where(frequency: 0).last
    end

    # Returns all pending single collaborations
    #
    # @return [ActiveRecord::Relation] Pending single collaborations
    #
    def pending_single_collaborations
      collaborations.where(frequency: 0).where(status: 2)
    end

    # Returns active collaborations (not deleted)
    #
    # @return [ActiveRecord::Relation] Active collaborations
    #
    def active_collaborations
      collaborations.where(deleted_at: nil, status: 3)
    end

    # Check if user has a minimum monthly collaboration (for militant status)
    # MIN_MILITANT_AMOUNT is defined in User model
    #
    # @return [Boolean] Whether user has minimum monthly collaboration
    #
    def has_min_monthly_collaboration?
      min_amount = User::MIN_MILITANT_AMOUNT
      collaborations
        .where.not(frequency: 0)
        .where(amount: min_amount..)
        .exists?(status: 3)
    end

    # Check if user is a collaborator for militant purposes
    # Includes both active collaborations and pending ones
    #
    # @return [Boolean] Whether user is a collaborator for militant status
    #
    def collaborator_for_militant?
      min_amount = User::MIN_MILITANT_AMOUNT
      has_min_monthly_collaboration? ||
        collaborations
          .where.not(frequency: 0)
          .where(amount: min_amount..)
          .exists?(status: 2)
    end
  end
end
