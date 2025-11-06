class ParticipationTeam < ApplicationRecord
  has_and_belongs_to_many :users

  scope :active, -> { where(active: true) }
end
