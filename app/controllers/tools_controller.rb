# frozen_string_literal: true

# ToolsController - User Tools and Elections Dashboard
#
# SECURITY FIXES IMPLEMENTED:
# - Added frozen_string_literal
# - Added comprehensive error handling
# - Added security logging
# - Optimized election filtering (already implemented)
# - Added documentation
#
# This controller provides a dashboard of available tools and
# elections that the current user can participate in.
class ToolsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_elections, only: [:index]
  before_action :get_promoted_forms, only: [:index]

  # Display tools dashboard
  def index
    # Clean up session
    session.delete(:return_to)

    log_security_event('tools_dashboard_viewed',
      user_id: current_user.id,
      elections_count: @elections.size
    )
  rescue StandardError => e
    log_error('tools_index_error', e, user_id: current_user&.id)
    redirect_to root_path, alert: t('errors.messages.generic')
  end

  # Display militant request page
  def militant_request
    log_security_event('militant_request_viewed', user_id: current_user.id)
  rescue StandardError => e
    log_error('militant_request_error', e, user_id: current_user&.id)
    redirect_to root_path, alert: t('errors.messages.generic')
  end

  private

  # Load elections available to user
  def user_elections
    # Get all upcoming/finished elections
    all_elections_candidates = Election.upcoming_finished

    # Single-pass iteration for efficiency
    @all_elections = []
    @elections = []
    @upcoming_elections = []
    @finished_elections = []

    all_elections_candidates.each do |election|
      # Filter elections user can access
      next unless election.has_valid_location_for?(current_user, check_created_at: false)

      @all_elections << election

      # Classify by status
      if election.is_active?
        @elections << election
      elsif election.is_upcoming?
        @upcoming_elections << election
      elsif election.recently_finished?
        @finished_elections << election
      end
    end

    log_security_event('elections_loaded',
      user_id: current_user.id,
      active_count: @elections.size,
      upcoming_count: @upcoming_elections.size,
      finished_count: @finished_elections.size
    )
  rescue StandardError => e
    log_error('user_elections_load_error', e, user_id: current_user&.id)
    # Set safe defaults
    @all_elections = []
    @elections = []
    @upcoming_elections = []
    @finished_elections = []
  end

  # Load promoted forms/pages
  def get_promoted_forms
    @promoted_forms = Page.where(promoted: true).order(priority: :desc)
  rescue StandardError => e
    log_error('promoted_forms_load_error', e, user_id: current_user&.id)
    @promoted_forms = []
  end

  # SECURITY LOGGING
  def log_security_event(event_type, details = {})
    Rails.logger.info({
      event: event_type,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      controller: 'tools',
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
      controller: 'tools',
      **details,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end
