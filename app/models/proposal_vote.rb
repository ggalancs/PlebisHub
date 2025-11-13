# frozen_string_literal: true

# ================================================================
# ProposalVote - Votes on Proposals
# ================================================================
# Separate from Vote model (which is for elections)
# Handles voting on proposals with yes/no/abstain options
# ================================================================

class ProposalVote < ApplicationRecord
  self.table_name = 'proposal_votes'

  # Associations
  belongs_to :user
  belongs_to :proposal, class_name: 'PlebisProposals::Proposal'

  # Validations
  validates :user_id, presence: true
  validates :proposal_id, presence: true
  validates :user_id, uniqueness: { scope: :proposal_id, message: "You have already voted on this proposal" }
  validates :option, presence: true, inclusion: { in: %w[yes no abstain], message: "%{value} is not a valid option" }

  # Scopes
  scope :yes_votes, -> { where(option: 'yes') }
  scope :no_votes, -> { where(option: 'no') }
  scope :abstain_votes, -> { where(option: 'abstain') }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  after_create :publish_vote_cast_event
  after_update :publish_vote_changed_event
  after_destroy :publish_vote_deleted_event

  # Counter cache update
  after_create :increment_votes_count
  after_destroy :decrement_votes_count

  # Instance methods
  def yes?
    option == 'yes'
  end

  def no?
    option == 'no'
  end

  def abstain?
    option == 'abstain'
  end

  private

  def publish_vote_cast_event
    EventBus.instance.publish('vote.cast', {
      vote_id: id,
      user_id: user_id,
      proposal_id: proposal_id,
      option: option,
      created_at: created_at
    })
  end

  def publish_vote_changed_event
    return unless saved_change_to_option?

    EventBus.instance.publish('vote.changed', {
      vote_id: id,
      user_id: user_id,
      proposal_id: proposal_id,
      old_option: option_before_last_save,
      new_option: option,
      changed_at: updated_at
    })
  end

  def publish_vote_deleted_event
    EventBus.instance.publish('vote.deleted', {
      vote_id: id,
      user_id: user_id,
      proposal_id: proposal_id,
      option: option,
      deleted_at: Time.current
    })
  end

  def increment_votes_count
    proposal.increment!(:votes_count) if proposal.respond_to?(:votes_count)
  rescue StandardError => e
    Rails.logger.error "Failed to increment votes_count: #{e.message}"
  end

  def decrement_votes_count
    proposal.decrement!(:votes_count) if proposal.respond_to?(:votes_count)
  rescue StandardError => e
    Rails.logger.error "Failed to decrement votes_count: #{e.message}"
  end
end
