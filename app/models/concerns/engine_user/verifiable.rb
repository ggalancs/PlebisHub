# frozen_string_literal: true

module EngineUser
  # Verifiable Concern
  #
  # Extends User model with verification-related associations and methods.
  # This concern is loaded when the plebis_verification engine is active.
  #
  module Verifiable
    extend ActiveSupport::Concern

    included do
      # Associations for user verification
      has_many :user_verifications, dependent: :destroy
    end

    # Check if user passes VAT ID verification requirements
    # User is verified OR has pending verification
    #
    # @return [Boolean] Whether user passes VAT ID check
    #
    def pass_vatid_check?
      self.verified? || self.user_verifications.pending.any?
    end

    # Check if user has any accepted verification
    #
    # @return [Boolean] Whether user has no accepted verification
    #
    def has_not_verification_accepted?
      UserVerification.where(
        user_id: self.id,
        status: [
          UserVerification::statuses[:accepted],
          UserVerification::statuses[:accepted_by_email]
        ]
      ).blank?
    end

    # Returns pending/imperative verification for user
    # Only if user is not verified but has future verified elections
    #
    # @return [UserVerification, nil] The imperative verification
    #
    def imperative_verification
      return if verified? || !has_future_verified_elections?

      UserVerification.find_by(
        user_id: self.id,
        status: %w(pending issues paused).map { |status| UserVerification::statuses[status] }
      )
    end

    # Check if photos are unnecessary for verification
    # True if user is verified and has email-based verification
    #
    # @return [Boolean] Whether photos are unnecessary
    #
    def photos_unnecessary?
      self.has_future_verified_elections? &&
        self.verified? &&
        (UserVerification.where(user_id: self.id).none? ||
         UserVerification.accepted_by_email.where(user_id: self.id).any?)
    end

    # Check if photos are necessary for verification
    #
    # @return [Boolean] Whether photos are necessary
    #
    def photos_necessary?
      (self.has_future_verified_elections? && !self.verified?) ||
        (UserVerification.where(user_id: self.id).any? &&
         UserVerification.accepted_by_email.where(user_id: self.id).none?)
    end

    # Check if user has future elections requiring verification
    #
    # @return [Boolean] Whether user has future verified elections
    #
    def has_future_verified_elections?
      Election.future.requires_vatid_check.any? { |e| e.has_valid_location_for?(self) }
    end

    # Check if user has no future verified elections
    #
    # @return [Boolean] Inverse of has_future_verified_elections?
    #
    def has_not_future_verified_elections?
      !has_future_verified_elections?
    end

    # Check if user is verified for militant purposes
    # Includes verified flag or pending/accepted verification
    #
    # @return [Boolean] Whether user is verified for militant status
    #
    def verified_for_militant?
      status = self.user_verifications.last&.status
      self.verified? || (self.user_verifications.any? &&
                          (status == "pending" || status == "accepted" || status == "accepted_by_email"))
    end
  end
end
