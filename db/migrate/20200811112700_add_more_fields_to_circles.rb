class AddMoreFieldsToCircles < ActiveRecord::Migration[4.2]
  def change
    add_column :circles, :code, :string
    add_column :circles, :name, :string
    add_column :circles, :island_code, :string
    add_column :circles, :region_area_id, :integer
    add_column :circles, :town, :string
  end
end
