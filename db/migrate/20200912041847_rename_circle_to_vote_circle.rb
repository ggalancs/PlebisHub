class RenameCircleToVoteCircle < ActiveRecord::Migration[4.2]
  def change
    rename_table :circles, :vote_circles
  end
end
