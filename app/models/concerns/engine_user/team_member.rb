# frozen_string_literal: true

module EngineUser
  # TeamMember Concern
  #
  # Extends User model with participation team-related associations and methods.
  # This concern is loaded when the plebis_participation engine is active.
  #
  module TeamMember
    extend ActiveSupport::Concern

    included do
      # Associations for participation teams
      # Rails 7.2: Explicitly specify class_name for namespaced engine models
      has_and_belongs_to_many :participation_teams, class_name: 'PlebisParticipation::ParticipationTeam'
    end

    # Check if user is member of a specific team
    #
    # @param team_id [Integer] The team ID to check
    # @return [Boolean] Whether user is in the team
    #
    def in_participation_team?(team_id)
      self.participation_team_ids.member?(team_id)
    end
  end
end
