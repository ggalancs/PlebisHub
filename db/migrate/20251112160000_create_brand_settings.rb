# frozen_string_literal: true

class CreateBrandSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :brand_settings do |t|
      # Identification
      t.string :name, null: false
      t.text :description
      t.string :scope, default: 'global', null: false
      t.references :organization, null: true # Foreign key omitted - organizations table may not exist yet

      # Theme Configuration
      t.string :theme_id, default: 'default', null: false
      t.string :theme_name

      # Custom Colors (nullable - uses predefined theme if null)
      t.string :primary_color, limit: 7
      t.string :primary_light_color, limit: 7
      t.string :primary_dark_color, limit: 7
      t.string :secondary_color, limit: 7
      t.string :secondary_light_color, limit: 7
      t.string :secondary_dark_color, limit: 7

      # Metadata
      t.boolean :active, default: true, null: false
      t.integer :version, default: 1, null: false
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end

    # Indexes for performance
    add_index :brand_settings, :name
    add_index :brand_settings, [:scope, :organization_id],
              unique: true,
              where: "scope = 'organization'",
              name: 'idx_brand_settings_org_unique'
    add_index :brand_settings, :active
    add_index :brand_settings, :theme_id
    add_index :brand_settings, :created_at
  end
end
