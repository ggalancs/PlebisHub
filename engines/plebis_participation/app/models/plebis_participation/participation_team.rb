# frozen_string_literal: true

module PlebisParticipation
  class ParticipationTeam < ApplicationRecord
    self.table_name = 'participation_teams'

    # HABTM relationship with User (from main app)
    # Join table: participation_teams_users
    has_and_belongs_to_many :users

    # Scopes
    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }
  end
end
