class Support < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :proposal, counter_cache: true

  # Validations
  validates :user, presence: true
  validates :proposal, presence: true
  validates :user_id, uniqueness: { scope: :proposal_id, message: "has already supported this proposal" }

  # Callbacks
  after_save :update_hotness

  # Instance methods
  def update_hotness
    proposal.update_attribute(:hotness, proposal.hotness)
  end
end
