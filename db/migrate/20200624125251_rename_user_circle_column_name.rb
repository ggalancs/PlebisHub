class RenameUserCircleColumnName < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :circle, :old_circle_data
  end
end
