# frozen_string_literal: true

# ========================================
# Add V2 Fields to Proposals Table
# ========================================
# Extends proposals table with v2.0 fields:
# - author_id: User who created the proposal
# - category: Categorization (e.g., 'economy', 'environment', 'social')
# - status: Proposal status ('draft', 'published', 'approved', 'rejected', 'active', 'finished', 'discarded')
# - organization_id: Multi-tenancy support
# - votes_count: Counter cache for proposal_votes
# - published_at: When the proposal was published
# ========================================

class AddV2FieldsToProposals < ActiveRecord::Migration[7.2]
  def change
    # V2.0 Fields
    add_reference :proposals, :author, foreign_key: { to_table: :users }, null: true, index: true
    add_column :proposals, :category, :string, null: true
    add_column :proposals, :status, :string, null: true, default: 'active'
    add_reference :proposals, :organization, foreign_key: { to_table: :vote_circles }, null: true, index: true
    add_column :proposals, :votes_count, :integer, default: 0, null: false
    add_column :proposals, :published_at, :datetime, null: true

    # Add indexes for common queries
    add_index :proposals, :category
    add_index :proposals, :status
    add_index :proposals, :votes_count
    add_index :proposals, :published_at
    add_index :proposals, [:author_id, :created_at], name: 'index_proposals_on_author_and_date'
    add_index :proposals, [:organization_id, :status], name: 'index_proposals_on_org_and_status'
  end
end
