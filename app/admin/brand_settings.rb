# frozen_string_literal: true

ActiveAdmin.register BrandSetting do
  menu parent: 'Branding', priority: 1, label: 'Theme Settings'

  permit_params :name, :description, :scope, :organization_id,
                :theme_id, :theme_name, :active,
                :primary_color, :primary_light_color, :primary_dark_color,
                :secondary_color, :secondary_light_color, :secondary_dark_color,
                :font_primary, :font_display,
                :logo_url, :logo_dark_url, :favicon_url,
                :custom_css, :skip_wcag_validation,
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
      status_tag setting.active ? 'Active' : 'Inactive', class: setting.active ? 'yes' : 'no'
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
        status_tag setting.active ? 'Active' : 'Inactive', class: setting.active ? 'yes' : 'no'
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

      # Skip WCAG validation option - includes hidden field for unchecked state (Rails convention)
      text_node '<div class="boolean input" style="margin-bottom: 20px; padding: 15px; background: #fff3cd; border: 1px solid #ffc107; border-radius: 8px;">
        <label style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
          <input type="hidden" name="brand_setting[skip_wcag_validation]" value="0">
          <input type="checkbox" name="brand_setting[skip_wcag_validation]" value="1" id="skip_wcag_validation" style="width: 18px; height: 18px;">
          <span style="font-weight: 500; color: #856404;">Skip WCAG contrast validation (allow bright colors)</span>
        </label>
        <div style="color: #856404; font-size: 12px; margin-top: 5px; margin-left: 28px;">
          <strong>Important:</strong> WCAG AA requires 4.5:1 contrast ratio for text readability.
          By default, bright colors (like yellow) are automatically darkened to meet accessibility standards.
          Check this box to keep your exact color values without auto-adjustment.
        </div>
      </div>'.html_safe

      # Calculate initial complementary color for display
      primary_hex = f.object.primary_color.presence || colors[:primary] || '#612d62'
      complementary_hex = BrandSetting.complementary_color(primary_hex) rescue '#269283'

      # Primary color with both picker and text input for instant feedback
      text_node %(<div class="input string required" id="brand_setting_primary_color_input">
        <label class="label" for="brand_setting_primary_color">Primary color<abbr title="required">*</abbr></label>
        <div style="display: flex; gap: 10px; align-items: center;">
          <input type="color" id="brand_setting_primary_color" name="brand_setting[primary_color]"
                 value="#{primary_hex}" style="height: 50px; width: 80px; cursor: pointer; border: none; padding: 0;">
          <input type="text" id="brand_setting_primary_color_text"
                 value="#{primary_hex.upcase}"
                 style="width: 100px; font-family: monospace; font-size: 14px; padding: 8px 12px; border: 1px solid #ccc; border-radius: 4px; text-transform: uppercase;"
                 maxlength="7" placeholder="#RRGGBB">
          <span style="color: #666; font-size: 12px;">Type hex value for instant preview</span>
        </div>
        <p class="inline-hints">Main brand color - click picker or type hex value</p>
      </div>).html_safe

      # Complementary color suggestion
      text_node %(<div id="complementary_color_suggestion" style="margin: 10px 0 15px 20%; padding: 12px 15px; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border-radius: 8px; border: 1px solid #dee2e6;">
        <div style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap;">
          <div>
            <span style="font-weight: 500; color: #495057;">Complementary color: </span>
            <span id="complementary_color_value" style="font-family: monospace; font-weight: 600; color: #{complementary_hex};">#{complementary_hex.upcase}</span>
          </div>
          <div id="complementary_color_preview" style="width: 40px; height: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.15); border: 2px solid white; background-color: #{complementary_hex};"></div>
          <button type="button" id="apply_complementary_btn" style="padding: 8px 16px; background: #28a745; color: white; border: none; border-radius: 6px; cursor: pointer; font-weight: 500;">Use as Secondary</button>
        </div>
        <div style="color: #6c757d; font-size: 11px; margin-top: 8px;">The complementary color is opposite on the color wheel (180° hue shift). Type a hex value above to see instant preview.</div>
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

      # Inline JavaScript for color tools - more reliable than external file
      text_node %(<script type="text/javascript">
(function() {
  'use strict';

  // Color conversion utilities
  function hexToHSL(hex) {
    if (!hex || typeof hex !== 'string') return { h: 0, s: 0, l: 50 };
    hex = hex.replace('#', '');
    if (hex.length !== 6) return { h: 0, s: 0, l: 50 };

    var r = parseInt(hex.substring(0, 2), 16) / 255;
    var g = parseInt(hex.substring(2, 4), 16) / 255;
    var b = parseInt(hex.substring(4, 6), 16) / 255;

    var max = Math.max(r, g, b);
    var min = Math.min(r, g, b);
    var h = 0, s = 0, l = (max + min) / 2;

    if (max !== min) {
      var d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      if (max === r) {
        h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
      } else if (max === g) {
        h = ((b - r) / d + 2) / 6;
      } else {
        h = ((r - g) / d + 4) / 6;
      }
    }
    return { h: h * 360, s: s * 100, l: l * 100 };
  }

  function hue2rgb(p, q, t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }

  function hslToHex(h, s, l) {
    h = ((h % 360) + 360) % 360;
    h /= 360;
    s /= 100;
    l /= 100;
    var r, g, b;
    if (s === 0) {
      r = g = b = l;
    } else {
      var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      var p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }
    var toHex = function(x) {
      var hx = Math.round(x * 255).toString(16);
      return hx.length === 1 ? '0' + hx : hx;
    };
    return '#' + toHex(r) + toHex(g) + toHex(b);
  }

  function lightenColor(hex) {
    var hsl = hexToHSL(hex);
    return hslToHex(hsl.h, hsl.s, Math.min(hsl.l + 25, 95));
  }

  function darkenColor(hex) {
    var hsl = hexToHSL(hex);
    return hslToHex(hsl.h, hsl.s, Math.max(hsl.l - 20, 5));
  }

  function complementaryColor(hex) {
    var hsl = hexToHSL(hex);
    return hslToHex(hsl.h + 180, hsl.s, hsl.l);
  }

  function isValidHex(hex) {
    return /^#[0-9A-Fa-f]{6}$/.test(hex);
  }

  function initBrandColorTools() {
    console.log('[BrandColorTools] Initializing...');

    var primaryInput = document.getElementById('brand_setting_primary_color');
    var primaryTextInput = document.getElementById('brand_setting_primary_color_text');
    var autoGenCheckbox = document.getElementById('auto_generate_variants');
    var primaryLightInput = document.getElementById('brand_setting_primary_light_color');
    var primaryDarkInput = document.getElementById('brand_setting_primary_dark_color');
    var secondaryInput = document.getElementById('brand_setting_secondary_color');
    var secondaryLightInput = document.getElementById('brand_setting_secondary_light_color');
    var secondaryDarkInput = document.getElementById('brand_setting_secondary_dark_color');
    var applyComplementaryBtn = document.getElementById('apply_complementary_btn');
    var complementaryPreview = document.getElementById('complementary_color_preview');
    var complementaryValue = document.getElementById('complementary_color_value');

    if (!primaryInput) {
      console.log('[BrandColorTools] Primary input not found');
      return;
    }

    console.log('[BrandColorTools] Found primary input:', primaryInput.value);

    var lastPrimaryValue = primaryInput.value;

    // Update complementary color preview
    function updateComplementary(hex) {
      if (!isValidHex(hex)) return;
      var comp = complementaryColor(hex);
      console.log('[BrandColorTools] Complementary:', hex, '->', comp);
      if (complementaryPreview) {
        complementaryPreview.style.backgroundColor = comp;
      }
      if (complementaryValue) {
        complementaryValue.textContent = comp.toUpperCase();
        complementaryValue.style.color = comp;
      }
      return comp;
    }

    // Handle primary color change
    function handlePrimaryChange(newValue, source) {
      console.log('[BrandColorTools] Primary changed:', newValue, 'from', source);
      if (!isValidHex(newValue)) return;

      lastPrimaryValue = newValue;
      updateComplementary(newValue);

      // Sync picker and text
      if (source === 'picker' && primaryTextInput) {
        primaryTextInput.value = newValue.toUpperCase();
      } else if (source === 'text' && primaryInput) {
        primaryInput.value = newValue.toLowerCase();
      }

      // Auto-generate variants
      if (autoGenCheckbox && autoGenCheckbox.checked) {
        var light = lightenColor(newValue);
        var dark = darkenColor(newValue);
        console.log('[BrandColorTools] Auto-generating primary variants:', light, dark);
        if (primaryLightInput) primaryLightInput.value = light;
        if (primaryDarkInput) primaryDarkInput.value = dark;
      }
    }

    // Handle secondary color change
    function handleSecondaryChange() {
      if (!secondaryInput || !autoGenCheckbox || !autoGenCheckbox.checked) return;
      var light = lightenColor(secondaryInput.value);
      var dark = darkenColor(secondaryInput.value);
      console.log('[BrandColorTools] Auto-generating secondary variants:', light, dark);
      if (secondaryLightInput) secondaryLightInput.value = light;
      if (secondaryDarkInput) secondaryDarkInput.value = dark;
    }

    // Primary color picker events
    primaryInput.addEventListener('input', function() {
      handlePrimaryChange(this.value, 'picker');
    });
    primaryInput.addEventListener('change', function() {
      handlePrimaryChange(this.value, 'picker');
    });

    // Primary text input events
    if (primaryTextInput) {
      primaryTextInput.addEventListener('input', function() {
        var val = this.value.trim();
        if (val && val[0] !== '#') val = '#' + val;
        if (isValidHex(val)) handlePrimaryChange(val, 'text');
      });
      primaryTextInput.addEventListener('change', function() {
        var val = this.value.trim();
        if (val && val[0] !== '#') {
          val = '#' + val;
          this.value = val.toUpperCase();
        }
        if (isValidHex(val)) handlePrimaryChange(val, 'text');
      });
    }

    // Secondary color events
    if (secondaryInput) {
      secondaryInput.addEventListener('input', handleSecondaryChange);
      secondaryInput.addEventListener('change', handleSecondaryChange);
    }

    // Apply complementary button
    if (applyComplementaryBtn) {
      applyComplementaryBtn.addEventListener('click', function(e) {
        e.preventDefault();
        var comp = complementaryColor(primaryInput.value);
        console.log('[BrandColorTools] Applying complementary:', comp);
        if (secondaryInput) {
          secondaryInput.value = comp;
          // Trigger change event for auto-generate
          secondaryInput.dispatchEvent(new Event('change'));
        }
        this.textContent = 'Applied!';
        this.style.background = '#17a2b8';
        var btn = this;
        setTimeout(function() {
          btn.textContent = 'Use as Secondary';
          btn.style.background = '#28a745';
        }, 1500);
      });
    }

    // Polling fallback for color picker
    setInterval(function() {
      if (primaryInput && primaryInput.value !== lastPrimaryValue) {
        console.log('[BrandColorTools] Polling detected change');
        handlePrimaryChange(primaryInput.value, 'picker');
      }
    }, 100);

    // Initial update
    updateComplementary(primaryInput.value);
    console.log('[BrandColorTools] Initialization complete');
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initBrandColorTools);
  } else {
    initBrandColorTools();
  }

  // Also try after a delay for Turbolinks
  setTimeout(initBrandColorTools, 500);
})();
</script>).html_safe
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
