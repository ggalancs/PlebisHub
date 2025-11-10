class AddVoteCircleFieldsToOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :vote_circle_autonomy_code, :string
    add_column :orders, :vote_circle_town_code, :string
    add_column :orders, :vote_circle_island_code, :string
    add_column :orders, :vote_circle_id, :integer
  end
end
