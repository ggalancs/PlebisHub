# frozen_string_literal: true

module PlebisProposals
  class Support < ApplicationRecord
    self.table_name = 'supports'

    # Associations
    belongs_to :user
    belongs_to :proposal, class_name: 'PlebisProposals::Proposal', counter_cache: true

    # Validations
    validates :user, presence: true
    validates :proposal, presence: true
    validates :user_id, uniqueness: { scope: :proposal_id, message: "has already supported this proposal" }

    # Callbacks
    after_save :update_hotness

    # Instance methods
    def update_hotness
      # Rails 7.2: Use update_column instead of deprecated update_attribute
      proposal.update_column(:hotness, proposal.hotness)
    end
  end
end
