class CreateThemeSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :theme_settings do |t|
      t.string :name, null: false
      t.string :primary_color, default: '#612d62'
      t.string :secondary_color, default: '#269283'
      t.string :accent_color, default: '#954e99'
      t.string :font_primary, default: 'Inter'
      t.string :font_display, default: 'Montserrat'
      t.string :logo_url
      t.string :favicon_url
      t.text :custom_css
      t.boolean :is_active, default: false

      t.timestamps
    end

    add_index :theme_settings, :is_active
  end
end
