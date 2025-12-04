# frozen_string_literal: true

module EngineUser
  # Militant Concern
  #
  # Extends User model with militant status-related associations and methods.
  # This concern is loaded when the plebis_militant engine is active.
  #
  # A militant is a verified user who is in a vote circle and has an active
  # economic collaboration (or is exempt from payment).
  #
  module Militant
    extend ActiveSupport::Concern

    # Minimum amount for militant status (defined in User model)
    # MIN_MILITANT_AMOUNT = 3 (by default)

    included do
      # Associations for militant records
      has_many :militant_records, dependent: :destroy
    end

    # Check if user still meets militant requirements
    # - Must be verified (or have pending/accepted verification)
    # - Must be in a vote circle
    # - Must have economic collaboration OR be exempt from payment
    #
    # @return [Boolean] Whether user is still a militant
    #
    def still_militant?
      verified_for_militant? &&
        in_vote_circle? &&
        (exempt_from_payment? || collaborator_for_militant?)
    end

    # Check if user was a militant at a specific date
    # Verifies all conditions were met at that time
    #
    # @param date [Date, String] The date to check
    # @return [Boolean] Whether user was militant at that date
    #
    def militant_at?(date)
      in_circle_at = nil
      verified_at = nil
      collaborator_at = nil

      # Check vote circle
      if vote_circle_id.present? && vote_circle_changed_at.present?
        in_circle_at = Time.zone.parse(vote_circle_changed_at.to_s)
      end

      # Check verification
      if user_verifications.any?
        last_verification = user_verifications.last
        status = last_verification.status
        if verified? || %w[pending accepted].include?(status)
          verified_at = Time.zone.parse(last_verification.updated_at.to_s)
        end
      end

      # Check collaboration
      min_amount = User::MIN_MILITANT_AMOUNT
      valid_collaboration = collaborations
                            .where.not(frequency: 0)
                            .where(amount: min_amount..)
                            .where(status: [0, 2, 3])

      if valid_collaboration.exists?
        last_collab = valid_collaboration.last
        collaborator_at = Time.zone.parse(last_collab.created_at.to_s) if last_collab
      end

      # Check exempt from payment
      if exempt_from_payment?
        last_record = MilitantRecord.where(user_id: id)
                                    .where(payment_type: 0)
                                    .where.not(begin_payment: nil)
                                    .last
        if last_record.present? && last_record.begin_payment.present?
          exempt_at = Time.zone.parse(last_record.begin_payment.to_s)
          collaborator_at = [collaborator_at, exempt_at].compact.min
        end
      end

      # All three conditions must be met
      return false unless in_circle_at.present? && verified_at.present? && collaborator_at.present?

      min_date = Time.zone.parse(date.to_s)
      [in_circle_at, collaborator_at].min <= min_date
    end

    # Get explanation of why user is not militant
    # Returns nil if user is already militant
    #
    # @return [String, nil] Explanation or nil
    #
    def get_not_militant_detail
      is_militant = still_militant?
      return if militant? && is_militant
      update(militant: is_militant) && return if is_militant

      result = []
      result.push('No esta verificado') unless verified_for_militant?
      result.push('No esta inscrito en un circulo') unless in_vote_circle?
      result.push('No tiene colaboración económica periódica suscrita, no está exento de pago') unless
        exempt_from_payment? || collaborator_for_militant?

      result.compact.flatten.join(', ').sub(/.*\K, /, ' y ')
    end

    # Process militant data updates
    # Creates militant records and sends notification emails
    # Called when vote circle changes
    #
    def process_militant_data
      is_militant = still_militant?
      lmr = militant_records.last

      # Send email if becoming militant
      if is_militant && (lmr.blank? || (lmr.present? && lmr.is_militant == false))
        UsersMailer.new_militant_email(id).deliver_now
      end

      # Update militant records
      militant_records_management(is_militant)
    end

    # Manages militant record creation and updates
    # Creates historical records of militant status changes
    #
    # @param is_militant [Boolean] Current militant status
    #
    def militant_records_management(is_militant)
      last_record = militant_records.last || MilitantRecord.new
      new_record = MilitantRecord.new
      new_record.user_id = id
      now = DateTime.now

      # Track verification period
      if verified_for_militant?
        new_record.begin_verified = last_record.begin_verified if last_record.end_verified.blank?
        new_record.begin_verified ||= user_verifications.pluck(:updated_at).last
        new_record.end_verified = nil
      else
        new_record.begin_verified = last_record.begin_verified || nil
        new_record.end_verified = now if new_record.begin_verified.present?
      end

      # Track vote circle membership
      if in_vote_circle?
        if vote_circle&.name.present? &&
           last_record.vote_circle_name.present? &&
           vote_circle.name.downcase.strip == last_record.vote_circle_name.downcase.strip
          new_record.begin_in_vote_circle = last_record.begin_in_vote_circle if
            last_record.end_in_vote_circle.blank?
          new_record.begin_in_vote_circle ||= vote_circle_changed_at
          new_record.vote_circle_name = last_record.vote_circle_name if
            last_record.vote_circle_name.present? && last_record.end_in_vote_circle.nil?
          new_record.vote_circle_name ||= vote_circle&.name
        else
          last_record.update(end_in_vote_circle: vote_circle_changed_at) if vote_circle_changed_at.present?
          new_record.begin_in_vote_circle = vote_circle_changed_at
          new_record.vote_circle_name = vote_circle&.name
        end
        new_record.end_in_vote_circle = nil
      else
        new_record.begin_in_vote_circle = last_record.begin_in_vote_circle if
          last_record.begin_in_vote_circle.present?
        new_record.vote_circle_name = last_record.vote_circle_name if
          last_record.vote_circle_name.present?
        new_record.end_in_vote_circle = now if new_record.begin_in_vote_circle.present?
      end

      # Track payment/collaboration
      if exempt_from_payment? || collaborator_for_militant?
        date_collaboration = last_record.begin_payment if last_record.end_payment.blank?
        new_record.payment_type = last_record.payment_type if last_record.end_payment.blank?

        if exempt_from_payment?
          date_collaboration ||= now
          new_record.payment_type ||= 0
          new_record.amount = 0
        else
          min_amount = User::MIN_MILITANT_AMOUNT
          last_valid_collaboration = collaborations
                                     .where.not(frequency: 0)
                                     .where(amount: min_amount..)
                                     .where(status: 3)
                                     .last
          last_valid_collaboration ||= collaborations
                                       .where.not(frequency: 0)
                                       .where(status: [0, 2])
                                       .last
          date_collaboration ||= last_valid_collaboration&.created_at
          new_record.payment_type ||= 1
          new_record.amount = last_valid_collaboration&.amount || 0
        end

        new_record.begin_payment = date_collaboration
        new_record.end_payment = nil
      else
        new_record.begin_payment = last_record.begin_payment if last_record.begin_payment.present?
        new_record.end_payment = now if new_record.begin_payment.present?
      end

      new_record.is_militant = is_militant
      new_record.save if new_record.diff?(last_record)
    end
  end
end
