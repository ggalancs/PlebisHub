class CreateBrandImages < ActiveRecord::Migration[7.2]
  def change
    create_table :brand_images do |t|
      t.string :name, null: false
      t.string :key, null: false  # unique identifier (e.g., 'logo_main', 'favicon', 'social_facebook')
      t.string :category, null: false  # 'logo', 'favicon', 'social', 'banner', 'icon', 'background'
      t.text :description
      t.string :alt_text  # accessibility alt text
      t.references :brand_setting, foreign_key: true, null: true  # null means global/default
      t.references :organization, foreign_key: true, null: true
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0  # for ordering within category
      t.jsonb :metadata, default: {}  # dimensions, format, etc.

      t.timestamps
    end

    add_index :brand_images, :key
    add_index :brand_images, :category
    add_index :brand_images, [:key, :brand_setting_id], unique: true, name: 'idx_brand_images_key_brand_setting'
    add_index :brand_images, [:key, :organization_id], unique: true, name: 'idx_brand_images_key_organization', where: 'brand_setting_id IS NULL'
    add_index :brand_images, :active
  end
end
