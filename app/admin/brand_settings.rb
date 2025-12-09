# frozen_string_literal: true

ActiveAdmin.register BrandSetting do
  menu priority: 2, label: 'Brand Settings'

  permit_params :name, :description, :scope, :organization_id,
                :theme_id, :theme_name, :active,
                :primary_color, :primary_light_color, :primary_dark_color,
                :secondary_color, :secondary_light_color, :secondary_dark_color,
                :font_primary, :font_display,
                :logo_url, :logo_dark_url, :favicon_url,
                :custom_css,
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
        tag_style = "background-color: #{color}; color: white; padding: 8px; " \
                    'border-radius: 4px; text-align: center; font-family: monospace; ' \
                    'font-size: 11px; font-weight: bold;'
        content_tag(:div, color, style: tag_style)
      else
        'Default'
      end
    end
    column 'Secondary' do |setting|
      color = setting.secondary_color || setting.predefined_theme_colors[:secondary]
      if color
        tag_style = "background-color: #{color}; color: white; padding: 8px; " \
                    'border-radius: 4px; text-align: center; font-family: monospace; ' \
                    'font-size: 11px; font-weight: bold;'
        content_tag(:div, color, style: tag_style)
      else
        'Default'
      end
    end
    column :active do |setting|
      status_tag setting.active ? 'Active' : 'Inactive', setting.active ? 'yes' : 'no'
    end
    column 'Fonts' do |setting|
      "#{setting.font_primary || 'Inter'} / #{setting.font_display || 'Montserrat'}"
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
      div class: 'color-preview-grid',
          style: 'display: grid; grid-template-columns: 1fr 1fr; gap: 30px; margin-top: 20px;' do
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
                color_box_style = [
                  "background-color: #{color_data[:value]}",
                  'color: white',
                  'padding: 30px',
                  'border-radius: 8px',
                  'text-align: center',
                  "font-family: 'Monaco', 'Courier New', monospace",
                  'font-size: 14px',
                  'font-weight: bold',
                  'box-shadow: 0 2px 8px rgba(0,0,0,0.1)'
                ].join('; ')
                div style: color_box_style do
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
                color_box_style = [
                  "background-color: #{color_data[:value]}",
                  'color: white',
                  'padding: 30px',
                  'border-radius: 8px',
                  'text-align: center',
                  "font-family: 'Monaco', 'Courier New', monospace",
                  'font-size: 14px',
                  'font-weight: bold',
                  'box-shadow: 0 2px 8px rgba(0,0,0,0.1)'
                ].join('; ')
                div style: color_box_style do
                  text_node color_data[:value]
                end
              end
            end
          end
        end
      end
    end

    panel 'Typography' do
      div class: 'typography-preview', style: 'padding: 20px;' do
        div style: 'display: grid; grid-template-columns: 1fr 1fr; gap: 30px;' do
          div do
            h4 'Primary Font (Body)', style: 'margin-bottom: 10px; color: #555;'
            font_name = brand_setting.font_primary || 'Inter'
            div style: "font-family: '#{font_name}', sans-serif; font-size: 16px; line-height: 1.6;" do
              div font_name, style: 'font-weight: 600; margin-bottom: 10px;'
              para 'The quick brown fox jumps over the lazy dog. 0123456789'
              para 'ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz'
            end
          end
          div do
            h4 'Display Font (Headings)', style: 'margin-bottom: 10px; color: #555;'
            font_name = brand_setting.font_display || 'Montserrat'
            div style: "font-family: '#{font_name}', sans-serif;" do
              div font_name, style: 'font-weight: 600; margin-bottom: 10px;'
              div style: 'font-size: 28px; font-weight: 700; margin-bottom: 8px;' do
                text_node 'Heading Example'
              end
              div style: 'font-size: 20px; font-weight: 600;' do
                text_node 'Subheading Example'
              end
            end
          end
        end
      end
    end

    panel 'Logo & Assets' do
      div class: 'assets-preview', style: 'padding: 20px;' do
        div style: 'display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px;' do
          div do
            h4 'Main Logo', style: 'margin-bottom: 10px; color: #555;'
            if brand_setting.logo_url.present?
              div style: 'background: #f5f5f5; padding: 20px; border-radius: 8px; text-align: center;' do
                image_tag brand_setting.logo_url, style: 'max-height: 80px; max-width: 100%;'
              end
              div brand_setting.logo_url, style: 'font-size: 11px; color: #888; margin-top: 8px; word-break: break-all;'
            else
              div 'Not configured', style: 'color: #999; font-style: italic;'
            end
          end
          div do
            h4 'Dark Mode Logo', style: 'margin-bottom: 10px; color: #555;'
            if brand_setting.logo_dark_url.present?
              div style: 'background: #333; padding: 20px; border-radius: 8px; text-align: center;' do
                image_tag brand_setting.logo_dark_url, style: 'max-height: 80px; max-width: 100%;'
              end
              div brand_setting.logo_dark_url, style: 'font-size: 11px; color: #888; margin-top: 8px; word-break: break-all;'
            else
              div 'Not configured', style: 'color: #999; font-style: italic;'
            end
          end
          div do
            h4 'Favicon', style: 'margin-bottom: 10px; color: #555;'
            if brand_setting.favicon_url.present?
              div style: 'background: #f5f5f5; padding: 20px; border-radius: 8px; text-align: center;' do
                image_tag brand_setting.favicon_url, style: 'max-height: 32px;'
              end
              div brand_setting.favicon_url, style: 'font-size: 11px; color: #888; margin-top: 8px; word-break: break-all;'
            else
              div 'Not configured', style: 'color: #999; font-style: italic;'
            end
          end
        end
      end
    end

    if brand_setting.custom_css.present?
      panel 'Custom CSS' do
        pre brand_setting.custom_css, style: 'background: #f5f5f5; padding: 15px; border-radius: 4px; overflow-x: auto;'
        div do
          strong 'Sanitized Output:'
        end
        pre brand_setting.sanitized_custom_css, style: 'background: #e8f5e9; padding: 15px; border-radius: 4px; overflow-x: auto; margin-top: 10px;'
      end
    end

    panel 'Generated CSS Variables' do
      pre brand_setting.to_css_variables, style: 'background: #e3f2fd; padding: 15px; border-radius: 4px; font-family: monospace;'
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
      scope_hint = '<strong>Global:</strong> Applies to entire platform<br>' \
                   '<strong>Organization:</strong> Specific to one organization'
      f.input :scope,
              as: :select,
              collection: BrandSetting::VALID_SCOPES,
              prompt: 'Select scope',
              hint: scope_hint.html_safe
      f.input :organization,
              as: :select,
              collection: Organization.all.map { |o| [o.name, o.id] },
              include_blank: 'Select organization (required if scope is organization)',
              hint: 'Required when scope is "organization"'
    end

    f.inputs 'Theme Selection' do
      f.input :theme_id,
              as: :select,
              collection: BrandSetting::PREDEFINED_THEMES.map { |id, theme|
                ["#{theme[:name]} - #{theme[:description]}", id]
              },
              prompt: 'Select theme',
              hint: 'Select a predefined theme. You can override individual colors below.'
      f.input :theme_name,
              hint: 'Optional: Custom display name for this theme'
    end

    f.inputs 'Custom Colors (Optional)', id: 'custom_colors' do
      # Get current theme colors (custom or from predefined theme)
      colors = f.object.theme_colors

      para 'Colors are pre-filled from the current theme. Modify to customize.'

      # Auto-generate toggle (using raw HTML for proper rendering)
      text_node '<div class="boolean input" style="margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px;">
        <label style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
          <input type="checkbox" id="auto_generate_variants" style="width: 18px; height: 18px;">
          <span style="font-weight: 500;">Auto-generate light/dark variants when primary or secondary color changes</span>
        </label>
        <div style="color: #666; font-size: 12px; margin-top: 5px; margin-left: 28px;">Light variants are 25% lighter, dark variants are 20% darker</div>
      </div>'.html_safe

      f.input :primary_color,
              as: :string,
              input_html: {
                type: 'color',
                style: 'height: 50px; width: 100%;',
                value: f.object.primary_color.presence || colors[:primary] || '#612d62',
                id: 'brand_setting_primary_color',
                data: { color_source: 'primary' }
              },
              hint: 'Main brand color'

      # Complementary color suggestion (using raw HTML)
      # Calculate initial complementary color for display
      primary_hex = f.object.primary_color.presence || colors[:primary] || '#612d62'
      # Simple complementary calculation for initial display (180 degree hue shift)
      complementary_hex = BrandSetting.complementary_color(primary_hex) rescue '#269283'

      text_node %(<div id="complementary_color_suggestion" style="margin: 10px 0 15px 20%; padding: 12px 15px; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border-radius: 8px; border: 1px solid #dee2e6;">
        <div style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap;">
          <div>
            <span style="font-weight: 500; color: #495057;">Complementary color: </span>
            <span id="complementary_color_value" style="font-family: monospace; font-weight: 600; color: #{complementary_hex};">#{complementary_hex.upcase}</span>
          </div>
          <div id="complementary_color_preview" style="width: 40px; height: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.15); border: 2px solid white; background-color: #{complementary_hex};"></div>
          <button type="button" id="apply_complementary_btn" style="padding: 8px 16px; background: #28a745; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: 500;">Use as Secondary</button>
        </div>
        <div style="color: #6c757d; font-size: 11px; margin-top: 8px;">The complementary color is opposite on the color wheel (180° hue shift)</div>
      </div>).html_safe

      f.input :primary_light_color,
              as: :string,
              input_html: {
                type: 'color',
                style: 'height: 50px; width: 100%;',
                value: f.object.primary_light_color.presence || colors[:primaryLight] || '#8a4f98',
                id: 'brand_setting_primary_light_color',
                data: { color_variant: 'primary-light' }
              },
              hint: 'Lighter variant of primary color'
      f.input :primary_dark_color,
              as: :string,
              input_html: {
                type: 'color',
                style: 'height: 50px; width: 100%;',
                value: f.object.primary_dark_color.presence || colors[:primaryDark] || '#4c244a',
                id: 'brand_setting_primary_dark_color',
                data: { color_variant: 'primary-dark' }
              },
              hint: 'Darker variant of primary color'

      f.input :secondary_color,
              as: :string,
              input_html: {
                type: 'color',
                style: 'height: 50px; width: 100%;',
                value: f.object.secondary_color.presence || colors[:secondary] || '#269283',
                id: 'brand_setting_secondary_color',
                data: { color_source: 'secondary' }
              },
              hint: 'Accent/secondary brand color'
      f.input :secondary_light_color,
              as: :string,
              input_html: {
                type: 'color',
                style: 'height: 50px; width: 100%;',
                value: f.object.secondary_light_color.presence || colors[:secondaryLight] || '#14b8a6',
                id: 'brand_setting_secondary_light_color',
                data: { color_variant: 'secondary-light' }
              },
              hint: 'Lighter variant of secondary color'
      f.input :secondary_dark_color,
              as: :string,
              input_html: {
                type: 'color',
                style: 'height: 50px; width: 100%;',
                value: f.object.secondary_dark_color.presence || colors[:secondaryDark] || '#0f766e',
                id: 'brand_setting_secondary_dark_color',
                data: { color_variant: 'secondary-dark' }
              },
              hint: 'Darker variant of secondary color'

      # JavaScript is loaded from app/assets/javascripts/admin/brand_color_tools.js
      # via ActiveAdmin config.register_javascript
    end

    f.inputs 'Typography' do
      f.input :font_primary,
              as: :select,
              collection: BrandSetting::ALLOWED_FONTS,
              include_blank: 'Default (Inter)',
              hint: 'Font for body text and general content'
      f.input :font_display,
              as: :select,
              collection: BrandSetting::ALLOWED_FONTS,
              include_blank: 'Default (Montserrat)',
              hint: 'Font for headings and titles'
    end

    f.inputs 'Logo & Assets' do
      f.input :logo_url,
              hint: 'URL to main logo image (SVG or PNG recommended, max 2048 characters)'
      f.input :logo_dark_url,
              hint: 'Logo variant for dark backgrounds (optional)'
      f.input :favicon_url,
              hint: 'URL to favicon (32x32 PNG recommended)'

      # Show previews if URLs exist
      if f.object.logo_url.present?
        div class: 'logo-preview', style: 'margin-top: 10px; padding: 15px; background: #f5f5f5; border-radius: 4px;' do
          span 'Current Logo: ', style: 'font-weight: bold;'
          image_tag f.object.logo_url, style: 'max-height: 50px; vertical-align: middle; margin-left: 10px;'
        end
      end
    end

    f.inputs 'Custom CSS (Advanced)' do
      f.input :custom_css,
              as: :text,
              input_html: { rows: 12, style: 'font-family: monospace; font-size: 13px;' },
              hint: 'Additional CSS rules (max 50KB). Security note: url(), @import, expression(), ' \
                    'and javascript: are automatically stripped.'
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
                  notice: 'Brand setting duplicated successfully!'
    else
      redirect_to admin_brand_settings_path,
                  alert: "Failed to duplicate: #{duplicated.errors.full_messages.join(', ')}"
    end
  end

  action_item :duplicate, only: %i[show edit] do
    link_to 'Clone Theme', duplicate_admin_brand_setting_path(brand_setting),
            method: :post,
            data: { confirm: 'Create a copy of this theme?' },
            class: 'button'
  end

  action_item :preview_api, only: :show do
    link_to 'Preview API Response',
            api_v1_brand_setting_path(brand_setting, format: :json),
            target: '_blank',
            class: 'button', rel: 'noopener'
  end

  action_item :preview_theme, only: :show do
    link_to 'Preview Theme',
            preview_admin_brand_setting_path(brand_setting),
            target: '_blank',
            class: 'button', rel: 'noopener'
  end

  member_action :preview, method: :get do
    @brand_setting = BrandSetting.find(params[:id])
    render 'admin/brand_settings/preview', layout: false
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
