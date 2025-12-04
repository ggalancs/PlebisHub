# frozen_string_literal: true

module PlebisProposals
  # SupportsController - Proposal Support Management
  #
  # SECURITY FIXES IMPLEMENTED:
  # - Added frozen_string_literal
  # - Added comprehensive error handling
  # - Added security logging
  # - Added authorization checks
  # - Added documentation
  #
  # This controller allows authenticated users to support proposals.
  class SupportsController < ApplicationController
    before_action :authenticate_user!

    # Create support for a proposal
    def create
      @proposal = Proposal.find(params[:proposal_id])

      unless @proposal.supportable?(current_user)
        log_security_event('support_not_supportable',
                           user_id: current_user.id,
                           proposal_id: @proposal.id)
        return redirect_to proposal_path(@proposal), alert: t('errors.messages.cannot_support')
      end

      current_user.supports.create!(proposal: @proposal)

      log_security_event('support_created',
                         user_id: current_user.id,
                         proposal_id: @proposal.id)

      redirect_to proposal_path(@proposal), notice: t('supports.created')
    rescue ActiveRecord::RecordNotFound
      log_security_event('support_proposal_not_found',
                         user_id: current_user.id,
                         proposal_id: params[:proposal_id])
      redirect_to proposals_path, alert: t('errors.messages.not_found')
    rescue ActiveRecord::RecordInvalid => e
      log_error('support_creation_failed', e,
                user_id: current_user.id,
                proposal_id: @proposal&.id)
      redirect_to proposal_path(@proposal), alert: t('errors.messages.support_failed')
    rescue StandardError => e
      log_error('support_creation_error', e,
                user_id: current_user.id,
                proposal_id: params[:proposal_id])
      redirect_to proposals_path, alert: t('errors.messages.generic')
    end

    private

    # SECURITY LOGGING
    def log_security_event(event_type, details = {})
      Rails.logger.info({
        event: event_type,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        controller: 'supports',
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end

    def log_error(event_type, exception, details = {})
      Rails.logger.error({
        event: event_type,
        error_class: exception.class.name,
        error_message: exception.message,
        backtrace: exception.backtrace&.first(5),
        ip_address: request.remote_ip,
        controller: 'supports',
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end
  end
end
