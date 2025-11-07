class ToolsController < ApplicationController
  before_action :authenticate_user!
  before_action :user_elections
  before_action :get_promoted_forms

  def index
    # LOW PRIORITY FIX: Simplified session cleanup
    # session.delete returns nil if key doesn't exist, no need for conditional check
    session.delete(:return_to)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def user_elections
    # Get all upcoming/finished elections
    all_elections_candidates = Election.upcoming_finished

    # LOW PRIORITY FIX: Single-pass iteration instead of multiple selects
    # This reduces iterations from 4 to 1 (filter + 3 selects = 4 total)
    @all_elections = []
    @elections = []
    @upcoming_elections = []
    @finished_elections = []

    all_elections_candidates.each do |election|
      # MEDIUM PRIORITY FIX: Filter elections in single iteration
      # Previously this called has_valid_location_for? in map, potentially causing N+1 queries
      next unless election.has_valid_location_for?(current_user, check_created_at: false)

      @all_elections << election

      # Classify elections by status in same iteration
      if election.is_active?
        @elections << election
      elsif election.is_upcoming?
        @upcoming_elections << election
      elsif election.recently_finished?
        @finished_elections << election
      end
    end
  end

  def get_promoted_forms
    @promoted_forms = Page.where(promoted: true).order(priority: :desc)
  end
end