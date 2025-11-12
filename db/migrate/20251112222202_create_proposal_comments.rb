# frozen_string_literal: true

# ========================================
# Create ProposalComments Table
# ========================================
# Comments on proposals with threading support
# ========================================

class CreateProposalComments < ActiveRecord::Migration[7.2]
  def change
    create_table :proposal_comments do |t|
      t.references :proposal, null: false, foreign_key: { to_table: :proposals }, index: true
      t.references :author, null: false, foreign_key: { to_table: :users }, index: true
      t.references :parent, null: true, foreign_key: { to_table: :proposal_comments }, index: true

      t.text :body, null: false
      t.boolean :flagged, default: false, null: false
      t.integer :upvotes, default: 0, null: false
      t.jsonb :metadata, default: {}, null: false

      t.timestamps

      # Indexes for common queries
      t.index [:proposal_id, :created_at], name: 'index_proposal_comments_on_proposal_and_date'
      t.index [:author_id, :created_at], name: 'index_proposal_comments_on_author_and_date'
      t.index :flagged
      t.index :upvotes
    end

    # Add counter cache to proposals
    add_column :proposals, :comments_count, :integer, default: 0, null: false
    add_index :proposals, :comments_count
  end
end
