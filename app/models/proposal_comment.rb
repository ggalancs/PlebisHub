# frozen_string_literal: true

# ================================================================
# ProposalComment - Comments on Proposals
# ================================================================
# Allows users to comment on proposals with threading support
# ================================================================

class ProposalComment < ApplicationRecord
  self.table_name = 'proposal_comments'

  # Associations
  belongs_to :proposal, class_name: 'PlebisProposals::Proposal'
  belongs_to :author, class_name: 'User'
  belongs_to :parent, class_name: 'ProposalComment', optional: true
  has_many :replies, class_name: 'ProposalComment', foreign_key: :parent_id, dependent: :destroy

  # Validations
  validates :body, presence: true, length: { minimum: 1, maximum: 5000 }
  validates :author, presence: true
  validates :proposal, presence: true
  validate :parent_must_be_on_same_proposal

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }
  scope :top_level, -> { where(parent_id: nil) }
  scope :replies_to, ->(comment) { where(parent_id: comment.id) }
  scope :not_flagged, -> { where(flagged: false) }
  scope :flagged, -> { where(flagged: true) }

  # Callbacks
  after_create :publish_comment_created_event
  after_create :increment_comments_count
  after_destroy :decrement_comments_count

  # Instance methods
  def top_level?
    parent_id.nil?
  end

  def reply?
    parent_id.present?
  end

  def has_replies?
    replies.any?
  end

  def replies_count
    replies.count
  end

  def flag!
    update(flagged: true, flagged_at: Time.current)
  end

  def unflag!
    update(flagged: false, flagged_at: nil)
  end

  def upvote!
    increment!(:upvotes_count)
  end

  def thread_depth
    return 0 if top_level?

    depth = 0
    current = self
    while current.parent.present?
      depth += 1
      current = current.parent
      break if depth > 10 # Prevent infinite loops
    end
    depth
  end

  private

  def parent_must_be_on_same_proposal
    if parent.present? && parent.proposal_id != proposal_id
      errors.add(:parent, "must be on the same proposal")
    end
  end

  def publish_comment_created_event
    EventBus.instance.publish('proposal.commented', {
      comment_id: id,
      proposal_id: proposal_id,
      author_id: author_id,
      parent_id: parent_id,
      is_reply: reply?,
      created_at: created_at
    })
  end

  def increment_comments_count
    proposal.increment!(:comments_count) if proposal.respond_to?(:comments_count)
  rescue StandardError => e
    Rails.logger.error "Failed to increment comments_count: #{e.message}"
  end

  def decrement_comments_count
    proposal.decrement!(:comments_count) if proposal.respond_to?(:comments_count)
  rescue StandardError => e
    Rails.logger.error "Failed to decrement comments_count: #{e.message}"
  end
end
