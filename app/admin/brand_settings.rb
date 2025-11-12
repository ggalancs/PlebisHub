# frozen_string_literal: true

ActiveAdmin.register BrandSetting do
  menu priority: 2, label: 'Brand Settings'

  permit_params :name, :description, :scope, :organization_id,
                :theme_id, :theme_name, :active,
                :primary_color, :primary_light_color, :primary_dark_color,
                :secondary_color, :secondary_light_color, :secondary_dark_color,
                metadata: {}

  # ========================================
  # INDEX
  # ========================================
  index do
    selectable_column
    id_column
    column :name do |setting|
      link_to setting.name, admin_brand_setting_path(setting)
    end
    column :scope do |setting|
      status_tag setting.scope, class: setting.scope == 'global' ? 'yes' : 'warning'
    end
    column :theme_id
    column 'Primary' do |setting|
      color = setting.primary_color || setting.predefined_theme_colors[:primary]
      if color
        content_tag(:div, color,
                    style: "background-color: #{color}; color: white; padding: 8px; border-radius: 4px; text-align: center; font-family: monospace; font-size: 11px; font-weight: bold;")
      else
        'Default'
      end
    end
    column 'Secondary' do |setting|
      color = setting.secondary_color || setting.predefined_theme_colors[:secondary]
      if color
        content_tag(:div, color,
                    style: "background-color: #{color}; color: white; padding: 8px; border-radius: 4px; text-align: center; font-family: monospace; font-size: 11px; font-weight: bold;")
      else
        'Default'
      end
    end
    column :active do |setting|
      status_tag setting.active ? 'Active' : 'Inactive', setting.active ? 'yes' : 'no'
    end
    column :version
    column :updated_at
    actions
  end

  # ========================================
  # FILTERS
  # ========================================
  filter :name
  filter :scope, as: :select, collection: BrandSetting::VALID_SCOPES
  filter :theme_id, as: :select, collection: BrandSetting::PREDEFINED_THEMES.keys
  filter :active
  filter :created_at
  filter :updated_at

  # ========================================
  # SHOW
  # ========================================
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :scope do |setting|
        status_tag setting.scope, class: setting.scope == 'global' ? 'yes' : 'warning'
      end
      row :organization
      row :theme_id
      row :theme_name
      row :active do |setting|
        status_tag setting.active ? 'Active' : 'Inactive', setting.active ? 'yes' : 'no'
      end
      row :version
      row :created_at
      row :updated_at
    end

    panel 'Color Preview' do
      div class: 'color-preview-grid', style: 'display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-top: 20px;' do
        # Primary Colors
        div do
          h3 'Primary Colors', style: 'margin-bottom: 15px; color: #333;'
          div do
            colors = brand_setting.theme_colors
            [
              { key: :primary, label: 'Primary', value: colors[:primary] },
              { key: :primaryLight, label: 'Primary Light', value: colors[:primaryLight] },
              { key: :primaryDark, label: 'Primary Dark', value: colors[:primaryDark] }
            ].each do |color_data|
              next unless color_data[:value]

              div style: 'margin-bottom: 15px;' do
                div color_data[:label], style: 'font-weight: 600; margin-bottom: 5px; color: #555; font-size: 13px;'
                div style: "background-color: #{color_data[:value]}; color: white; padding: 30px; border-radius: 8px; text-align: center; font-family: 'Monaco', 'Courier New', monospace; font-size: 14px; font-weight: bold; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" do
                  text_node color_data[:value]
                end
              end
            end
          end
        end

        # Secondary Colors
        div do
          h3 'Secondary Colors', style: 'margin-bottom: 15px; color: #333;'
          div do
            colors = brand_setting.theme_colors
            [
              { key: :secondary, label: 'Secondary', value: colors[:secondary] },
              { key: :secondaryLight, label: 'Secondary Light', value: colors[:secondaryLight] },
              { key: :secondaryDark, label: 'Secondary Dark', value: colors[:secondaryDark] }
            ].each do |color_data|
              next unless color_data[:value]

              div style: 'margin-bottom: 15px;' do
                div color_data[:label], style: 'font-weight: 600; margin-bottom: 5px; color: #555; font-size: 13px;'
                div style: "background-color: #{color_data[:value]}; color: white; padding: 30px; border-radius: 8px; text-align: center; font-family: 'Monaco', 'Courier New', monospace; font-size: 14px; font-weight: bold; box-shadow: 0 2px 8px rgba(0,0,0,0.1);" do
                  text_node color_data[:value]
                end
              end
            end
          end
        end
      end
    end

    panel 'Metadata' do
      pre JSON.pretty_generate(brand_setting.metadata)
    end

    active_admin_comments
  end

  # ========================================
  # FORM
  # ========================================
  form do |f|
    f.semantic_errors

    f.inputs 'Basic Information' do
      f.input :name,
              hint: 'Descriptive name for this brand setting (e.g., "Summer Campaign 2025")'
      f.input :description,
              as: :text,
              rows: 3,
              hint: 'Optional description of when/where this theme is used'
    end

    f.inputs 'Scope & Organization' do
      f.input :scope,
              as: :select,
              collection: BrandSetting::VALID_SCOPES,
              include_blank: false,
              hint: '<strong>Global:</strong> Applies to entire platform<br><strong>Organization:</strong> Specific to one organization'.html_safe
      f.input :organization,
              as: :select,
              collection: Organization.all.map { |o| [o.name, o.id] },
              include_blank: 'Select organization (required if scope is organization)',
              hint: 'Required when scope is "organization"'
    end

    f.inputs 'Theme Selection' do
      f.input :theme_id,
              as: :select,
              collection: BrandSetting::PREDEFINED_THEMES.map { |id, theme| ["#{theme[:name]} - #{theme[:description]}", id] },
              include_blank: false,
              hint: 'Select a predefined theme. You can override individual colors below.'
      f.input :theme_name,
              hint: 'Optional: Custom display name for this theme'
    end

    f.inputs 'Custom Colors (Optional)', id: 'custom_colors' do
      para 'Leave empty to use predefined theme colors. Set individual colors to override.'

      f.input :primary_color,
              as: :string,
              input_html: { type: 'color', style: 'height: 50px; width: 100%;' },
              hint: 'Main brand color. Leave empty to use theme default.'
      f.input :primary_light_color,
              as: :string,
              input_html: { type: 'color', style: 'height: 50px; width: 100%;' },
              hint: 'Lighter variant of primary color'
      f.input :primary_dark_color,
              as: :string,
              input_html: { type: 'color', style: 'height: 50px; width: 100%;' },
              hint: 'Darker variant of primary color'

      f.input :secondary_color,
              as: :string,
              input_html: { type: 'color', style: 'height: 50px; width: 100%;' },
              hint: 'Accent/secondary brand color. Leave empty to use theme default.'
      f.input :secondary_light_color,
              as: :string,
              input_html: { type: 'color', style: 'height: 50px; width: 100%;' },
              hint: 'Lighter variant of secondary color'
      f.input :secondary_dark_color,
              as: :string,
              input_html: { type: 'color', style: 'height: 50px; width: 100%;' },
              hint: 'Darker variant of secondary color'
    end

    f.inputs 'Settings' do
      f.input :active,
              hint: 'Only active brand settings are applied. At least one global setting must be active.'
    end

    f.actions
  end

  # ========================================
  # CONTROLLER ACTIONS
  # ========================================
  controller do
    def create
      @brand_setting = BrandSetting.new(permitted_params[:brand_setting])

      if @brand_setting.save
        redirect_to admin_brand_setting_path(@brand_setting),
                    notice: 'Brand setting created successfully!'
      else
        flash.now[:error] = @brand_setting.errors.full_messages.join(', ')
        render :new
      end
    end

    def update
      @brand_setting = BrandSetting.find(params[:id])

      if @brand_setting.update(permitted_params[:brand_setting])
        redirect_to admin_brand_setting_path(@brand_setting),
                    notice: 'Brand setting updated successfully!'
      else
        flash.now[:error] = @brand_setting.errors.full_messages.join(', ')
        render :edit
      end
    end
  end

  # ========================================
  # MEMBER ACTIONS
  # ========================================
  member_action :duplicate, method: :post do
    original = BrandSetting.find(params[:id])
    duplicated = original.dup
    duplicated.name = "#{original.name} (Copy)"
    duplicated.active = false

    if duplicated.save
      redirect_to admin_brand_setting_path(duplicated),
                  notice: "Brand setting duplicated successfully!"
    else
      redirect_to admin_brand_settings_path,
                  alert: "Failed to duplicate: #{duplicated.errors.full_messages.join(', ')}"
    end
  end

  action_item :duplicate, only: :show do
    link_to 'Duplicate', duplicate_admin_brand_setting_path(brand_setting),
            method: :post,
            data: { confirm: 'Create a copy of this brand setting?' }
  end

  action_item :preview_api, only: :show do
    link_to 'Preview API Response',
            api_v1_brand_setting_path(brand_setting, format: :json),
            target: '_blank',
            class: 'button'
  end

  # ========================================
  # BATCH ACTIONS
  # ========================================
  batch_action :activate do |ids|
    batch_action_collection.find(ids).each do |setting|
      setting.update(active: true)
    end
    redirect_to collection_path, notice: "#{ids.count} brand settings activated!"
  end

  batch_action :deactivate do |ids|
    success_count = 0
    error_messages = []

    batch_action_collection.find(ids).each do |setting|
      if setting.update(active: false)
        success_count += 1
      else
        error_messages << "#{setting.name}: #{setting.errors.full_messages.join(', ')}"
      end
    end

    if error_messages.empty?
      redirect_to collection_path, notice: "#{success_count} brand settings deactivated!"
    else
      redirect_to collection_path,
                  alert: "Some settings could not be deactivated: #{error_messages.join('; ')}"
    end
  end

  batch_action :destroy, false # Disable default destroy
end
