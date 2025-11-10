class ChangeColumnDefaultStatusInCollaborations < ActiveRecord::Migration[4.2]
  def change
    change_column_default(:collaborations,:status,2)
  end
end
