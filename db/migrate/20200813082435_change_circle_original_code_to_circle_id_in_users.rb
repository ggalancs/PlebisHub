class ChangeCircleOriginalCodeToCircleIdInUsers < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :circle_original_code, :string
    add_column :users, :circle_id, :integer
  end
end
