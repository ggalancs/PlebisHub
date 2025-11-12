class CreateThemeSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :theme_settings do |t|
      t.string :name, null: false
      t.string :primary_color, default: '#612d62', limit: 7
      t.string :secondary_color, default: '#269283', limit: 7
      t.string :accent_color, default: '#954e99', limit: 7
      t.string :font_primary, default: 'Inter'
      t.string :font_display, default: 'Montserrat'
      t.string :logo_url, limit: 500
      t.string :favicon_url, limit: 500
      t.text :custom_css
      t.boolean :is_active, default: false

      t.timestamps
    end

    # Índice único en nombre
    add_index :theme_settings, :name, unique: true

    # Índice único condicional para is_active
    # Solo puede haber un tema con is_active = true
    # Esto funciona en PostgreSQL
    if adapter_name == 'PostgreSQL'
      add_index :theme_settings, :is_active,
                unique: true,
                where: "is_active = true",
                name: 'index_theme_settings_on_active_unique'
    else
      # Para otras bases de datos, usar índice normal
      add_index :theme_settings, :is_active
    end
  end

  private

  def adapter_name
    connection.adapter_name
  end
end
