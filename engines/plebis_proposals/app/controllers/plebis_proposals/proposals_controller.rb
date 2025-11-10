# frozen_string_literal: true

module PlebisProposals
  # ProposalsController - Community Proposals Display
  #
  # SECURITY FIXES IMPLEMENTED:
  # - Added frozen_string_literal
  # - Added error handling
  # - Added security logging
  # - Added documentation
  # - Fixed uninitialized instance variable
  #
  # This controller displays community proposals with Reddit-style filtering.
  class ProposalsController < ApplicationController
    # Display filtered list of proposals
    def index
      params[:filter] ||= 'popular'
      @proposals = Proposal.filter(params[:filter])
      @hot = Proposal.reddit.hot.limit(3)

      log_security_event('proposals_index_viewed', filter: params[:filter])
    rescue StandardError => e
      log_error('proposals_index_error', e, filter: params[:filter])
      @proposals = Proposal.none
      @hot = []
      flash.now[:alert] = t('errors.messages.generic')
    end

    # Display individual proposal
    def show
      @proposal = Proposal.reddit.find(params[:id])

      log_security_event('proposal_viewed', proposal_id: @proposal.id)
    rescue ActiveRecord::RecordNotFound
      log_security_event('proposal_not_found', proposal_id: params[:id])
      redirect_to proposals_path, alert: t('errors.messages.not_found')
    rescue StandardError => e
      log_error('proposal_show_error', e, proposal_id: params[:id])
      redirect_to proposals_path, alert: t('errors.messages.generic')
    end

    # Display proposals information page
    def info
      log_security_event('proposals_info_viewed')
    rescue StandardError => e
      log_error('proposals_info_error', e)
      redirect_to proposals_path, alert: t('errors.messages.generic')
    end

    private

    # SECURITY LOGGING
    def log_security_event(event_type, details = {})
      Rails.logger.info({
        event: event_type,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        controller: 'proposals',
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
        controller: 'proposals',
        **details,
        timestamp: Time.current.iso8601
      }.to_json)
    end
  end
end
