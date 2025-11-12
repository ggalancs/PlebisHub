# frozen_string_literal: true

# ========================================
# Create ProposalVotes Table
# ========================================
# Tracks user votes on proposals (yes/no/abstain)
# Separate from election votes
# ========================================

class CreateProposalVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :proposal_votes do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :proposal, null: false, foreign_key: { to_table: :proposals }, index: true
      t.string :option, null: false # yes, no, abstain
      t.text :comment # Optional comment with vote

      t.timestamps

      # Ensure one vote per user per proposal
      t.index [:user_id, :proposal_id], unique: true, name: 'index_proposal_votes_unique'
      t.index :option
      t.index :created_at
    end
  end
end
