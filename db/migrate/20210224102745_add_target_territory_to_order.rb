class AddTargetTerritoryToOrder < ActiveRecord::Migration[4.2]
  def change
    add_column  :orders, :target_territory, :string
  end
end
