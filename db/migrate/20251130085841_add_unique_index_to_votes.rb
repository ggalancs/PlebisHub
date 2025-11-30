# frozen_string_literal: true

class AddUniqueIndexToVotes < ActiveRecord::Migration[7.2]
  def change
    # SECURITY FIX SEC-037: Add unique constraint to prevent duplicate votes via race conditions
    # This provides database-level protection in addition to application-level find_or_create_by
    add_index :votes, [:user_id, :election_id], unique: true,
              name: 'index_votes_on_user_election_unique',
              if_not_exists: true
  end
end
