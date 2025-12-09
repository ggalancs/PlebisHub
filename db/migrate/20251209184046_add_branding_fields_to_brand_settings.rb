# frozen_string_literal: true

class AddBrandingFieldsToBrandSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :brand_settings, :font_primary, :string, default: 'Inter'
    add_column :brand_settings, :font_display, :string, default: 'Montserrat'
    add_column :brand_settings, :logo_url, :string
    add_column :brand_settings, :logo_dark_url, :string
    add_column :brand_settings, :favicon_url, :string
    add_column :brand_settings, :custom_css, :text
  end
end
