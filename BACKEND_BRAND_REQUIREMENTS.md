# 🎨 BACKEND REQUIREMENTS - Brand Customization System

**Document Version:** 1.0
**Date:** November 12, 2025
**For:** Backend Developer / Rails Team
**From:** Frontend Team
**Priority:** HIGH
**Estimated Effort:** 3-5 days

---

## 📋 TABLE OF CONTENTS

1. [Executive Summary](#executive-summary)
2. [Current Frontend Implementation](#current-frontend-implementation)
3. [Backend Requirements Overview](#backend-requirements-overview)
4. [Database Schema](#database-schema)
5. [ActiveAdmin Interface](#activeadmin-interface)
6. [API Endpoints](#api-endpoints)
7. [Validation Requirements](#validation-requirements)
8. [Security Considerations](#security-considerations)
9. [Testing Requirements](#testing-requirements)
10. [Migration Guide](#migration-guide)
11. [Example Implementation](#example-implementation)

---

## 1. EXECUTIVE SUMMARY {#executive-summary}

### Context

The frontend team has implemented a comprehensive brand customization system that allows PlebisHub to be white-labeled with custom colors, logos, and themes. Currently, this customization is stored in the browser's `localStorage`, which means:

❌ **Current Limitations:**
- Customizations are per-browser (not per-organization)
- Lost when browser cache is cleared
- Cannot be managed centrally
- No multi-tenant support

✅ **Goal:**
- Store brand customizations in the database
- Manage them through ActiveAdmin
- Support multi-tenant configurations
- Provide API for frontend to fetch/apply settings

### What We Need from Backend

1. **Database Model:** `BrandSetting` to store brand configurations
2. **ActiveAdmin Resource:** CRUD interface for administrators
3. **API Endpoint:** JSON endpoint for frontend to fetch settings
4. **Validation:** Server-side validation of color values and data integrity
5. **Scoping:** Support for organization-level or global settings

---

## 2. CURRENT FRONTEND IMPLEMENTATION {#current-frontend-implementation}

### 2.1 Frontend Architecture

The frontend uses a composable (`useBrand()`) that manages brand settings:

```typescript
// Frontend: app/frontend/composables/useBrand.ts
export function useBrand() {
  const currentTheme = ref<BrandTheme>(defaultTheme)
  const customColors = ref<PartialBrandColors | null>(null)

  // Currently saves to localStorage
  function saveBrandToStorage(theme: BrandTheme): boolean {
    localStorage.setItem('plebishub-brand', JSON.stringify({
      themeId: theme.id,
      customColors: customColors.value,
    }))
  }

  // ... more methods
}
```

### 2.2 Data Structure (Frontend)

```typescript
// Current frontend type definitions
interface BrandTheme {
  id: string              // 'default' | 'ocean' | 'forest' | 'sunset' | 'monochrome'
  name: string           // Display name
  description?: string   // Optional description
  colors: BrandColors
}

interface BrandColors {
  primary: string        // Hex color: "#612d62"
  primaryLight: string   // Hex color: "#8a4f98"
  primaryDark: string    // Hex color: "#4c244a"
  secondary: string      // Hex color: "#269283"
  secondaryLight: string // Hex color: "#14b8a6"
  secondaryDark: string  // Hex color: "#0f766e"
}

// Export/Import format
interface BrandExportData {
  theme: BrandTheme
  customColors: Partial<BrandColors> | null
  version: string        // "1.0.0"
  exportedAt: string     // ISO 8601 timestamp
}
```

### 2.3 Predefined Themes

The frontend includes 5 predefined themes:

| Theme ID | Name | Primary Color | Secondary Color |
|----------|------|---------------|-----------------|
| `default` | PlebisHub Default | #612d62 | #269283 |
| `ocean` | Ocean Blue | #1e40af | #0891b2 |
| `forest` | Forest Green | #15803d | #0d9488 |
| `sunset` | Sunset Orange | #c2410c | #dc2626 |
| `monochrome` | Monochrome | #1a1a1a | #666666 |

---

## 3. BACKEND REQUIREMENTS OVERVIEW {#backend-requirements-overview}

### 3.1 High-Level Requirements

| Requirement | Priority | Complexity |
|-------------|----------|------------|
| Create `BrandSetting` model | 🔴 Critical | Low |
| Add database migration | 🔴 Critical | Low |
| Create ActiveAdmin resource | 🔴 Critical | Medium |
| Create API endpoint | 🔴 Critical | Low |
| Add server-side validations | 🔴 Critical | Medium |
| Add scoping (multi-tenant) | 🟡 High | Medium |
| Add audit logging | 🟢 Nice-to-have | Low |
| Add caching layer | 🟢 Nice-to-have | Medium |

### 3.2 Technology Stack

- **Framework:** Ruby on Rails 7.x
- **Admin Panel:** ActiveAdmin
- **Database:** PostgreSQL
- **Serialization:** ActiveModel::Serializers or JBuilder
- **Validation:** ActiveRecord validations + custom validators

---

## 4. DATABASE SCHEMA {#database-schema}

### 4.1 Migration

```ruby
# db/migrate/YYYYMMDDHHMMSS_create_brand_settings.rb
class CreateBrandSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :brand_settings do |t|
      # Identification
      t.string :name, null: false, index: true
      t.string :description
      t.string :scope, default: 'global', null: false  # 'global' or 'organization'
      t.references :organization, foreign_key: true, null: true  # For multi-tenant

      # Theme Configuration
      t.string :theme_id, default: 'default', null: false  # 'default', 'ocean', etc.
      t.string :theme_name

      # Custom Colors (can be null if using predefined theme)
      t.string :primary_color         # Hex: "#612d62"
      t.string :primary_light_color   # Hex: "#8a4f98"
      t.string :primary_dark_color    # Hex: "#4c244a"
      t.string :secondary_color       # Hex: "#269283"
      t.string :secondary_light_color # Hex: "#14b8a6"
      t.string :secondary_dark_color  # Hex: "#0f766e"

      # Metadata
      t.boolean :active, default: true, null: false
      t.integer :version, default: 1, null: false  # For versioning
      t.jsonb :metadata, default: {}  # Additional settings (logos, fonts, etc.)

      t.timestamps
    end

    # Indexes
    add_index :brand_settings, [:scope, :organization_id], unique: true,
              where: "scope = 'organization'",
              name: 'index_brand_settings_on_scope_and_org'
    add_index :brand_settings, :active
    add_index :brand_settings, :theme_id
  end
end
```

### 4.2 Default Data Seed

```ruby
# db/seeds.rb or db/seeds/brand_settings.rb
BrandSetting.find_or_create_by!(scope: 'global', organization_id: nil) do |setting|
  setting.name = 'PlebisHub Default Theme'
  setting.description = 'Default brand colors for PlebisHub platform'
  setting.theme_id = 'default'
  setting.theme_name = 'PlebisHub Default'
  setting.primary_color = '#612d62'
  setting.primary_light_color = '#8a4f98'
  setting.primary_dark_color = '#4c244a'
  setting.secondary_color = '#269283'
  setting.secondary_light_color = '#14b8a6'
  setting.secondary_dark_color = '#0f766e'
  setting.active = true
  setting.metadata = {
    version: '1.0.0',
    created_by: 'system',
    notes: 'Original PlebisHub brand colors'
  }
end
```

---

## 5. ACTIVEADMIN INTERFACE {#activeadmin-interface}

### 5.1 ActiveAdmin Resource

```ruby
# app/admin/brand_settings.rb
ActiveAdmin.register BrandSetting do
  menu priority: 10, label: "Brand Settings"

  permit_params :name, :description, :scope, :organization_id,
                :theme_id, :theme_name, :active,
                :primary_color, :primary_light_color, :primary_dark_color,
                :secondary_color, :secondary_light_color, :secondary_dark_color,
                :metadata

  # Index page
  index do
    selectable_column
    id_column
    column :name
    column :scope
    column :theme_id
    column "Primary Color" do |setting|
      if setting.primary_color.present?
        content_tag(:div, setting.primary_color,
                    style: "background-color: #{setting.primary_color};
                            color: white;
                            padding: 5px;
                            border-radius: 4px;")
      else
        "Using theme default"
      end
    end
    column "Secondary Color" do |setting|
      if setting.secondary_color.present?
        content_tag(:div, setting.secondary_color,
                    style: "background-color: #{setting.secondary_color};
                            color: white;
                            padding: 5px;
                            border-radius: 4px;")
      else
        "Using theme default"
      end
    end
    column :active
    column :updated_at
    actions
  end

  # Filters
  filter :name
  filter :scope, as: :select, collection: ['global', 'organization']
  filter :theme_id, as: :select, collection: BrandSetting::PREDEFINED_THEMES.keys
  filter :active
  filter :created_at
  filter :updated_at

  # Show page
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :scope
      row :organization
      row :theme_id
      row :theme_name
      row :active
      row :version

      panel "Color Preview" do
        div style: "display: flex; gap: 20px; flex-wrap: wrap;" do
          # Primary colors
          div style: "flex: 1; min-width: 200px;" do
            h3 "Primary Colors"
            div do
              ['primary_color', 'primary_light_color', 'primary_dark_color'].each do |color_attr|
                color_value = brand_setting.send(color_attr)
                next unless color_value.present?

                div style: "margin: 10px 0;" do
                  div color_attr.humanize, style: "font-weight: bold; margin-bottom: 5px;"
                  div color_value,
                      style: "background-color: #{color_value};
                              color: white;
                              padding: 20px;
                              border-radius: 8px;
                              text-align: center;
                              font-family: monospace;"
                end
              end
            end
          end

          # Secondary colors
          div style: "flex: 1; min-width: 200px;" do
            h3 "Secondary Colors"
            div do
              ['secondary_color', 'secondary_light_color', 'secondary_dark_color'].each do |color_attr|
                color_value = brand_setting.send(color_attr)
                next unless color_value.present?

                div style: "margin: 10px 0;" do
                  div color_attr.humanize, style: "font-weight: bold; margin-bottom: 5px;"
                  div color_value,
                      style: "background-color: #{color_value};
                              color: white;
                              padding: 20px;
                              border-radius: 8px;
                              text-align: center;
                              font-family: monospace;"
                end
              end
            end
          end
        end
      end

      row :metadata do |setting|
        pre JSON.pretty_generate(setting.metadata)
      end

      row :created_at
      row :updated_at
    end
  end

  # Form
  form do |f|
    f.semantic_errors

    f.inputs "Basic Information" do
      f.input :name, hint: "Descriptive name for this brand setting"
      f.input :description, as: :text,
              hint: "Optional description of when/where this theme is used"
      f.input :scope, as: :select, collection: ['global', 'organization'],
              hint: "Global applies to entire platform, Organization is for specific orgs"
      f.input :organization,
              collection: Organization.all.map { |o| [o.name, o.id] },
              include_blank: true,
              hint: "Required if scope is 'organization'"
    end

    f.inputs "Theme Selection" do
      f.input :theme_id, as: :select,
              collection: BrandSetting::PREDEFINED_THEMES.map { |id, theme| [theme[:name], id] },
              hint: "Select a predefined theme or choose 'custom' to set your own colors"
      f.input :theme_name,
              hint: "Custom name for this theme (optional)"
    end

    f.inputs "Custom Colors", id: "custom-colors-section" do
      f.input :primary_color, as: :string,
              input_html: { type: 'color' },
              hint: "Main brand color (e.g., #612d62). Leave empty to use theme default."
      f.input :primary_light_color, as: :string,
              input_html: { type: 'color' },
              hint: "Lighter variant of primary color"
      f.input :primary_dark_color, as: :string,
              input_html: { type: 'color' },
              hint: "Darker variant of primary color"

      f.input :secondary_color, as: :string,
              input_html: { type: 'color' },
              hint: "Accent/secondary brand color (e.g., #269283)"
      f.input :secondary_light_color, as: :string,
              input_html: { type: 'color' },
              hint: "Lighter variant of secondary color"
      f.input :secondary_dark_color, as: :string,
              input_html: { type: 'color' },
              hint: "Darker variant of secondary color"
    end

    f.inputs "Settings" do
      f.input :active,
              hint: "Only active brand settings are applied to the frontend"
      f.input :metadata, as: :text,
              input_html: { rows: 5 },
              hint: "Additional JSON metadata (optional)"
    end

    f.actions
  end

  # Controller actions
  controller do
    def create
      @brand_setting = BrandSetting.new(permitted_params[:brand_setting])
      @brand_setting.version = 1

      if @brand_setting.save
        redirect_to admin_brand_setting_path(@brand_setting),
                    notice: "Brand setting created successfully!"
      else
        render :new
      end
    end

    def update
      @brand_setting = BrandSetting.find(params[:id])
      @brand_setting.version += 1 if @brand_setting.colors_changed?

      if @brand_setting.update(permitted_params[:brand_setting])
        redirect_to admin_brand_setting_path(@brand_setting),
                    notice: "Brand setting updated successfully!"
      else
        render :edit
      end
    end
  end

  # Custom member actions
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
                  alert: "Failed to duplicate brand setting"
    end
  end

  action_item :duplicate, only: :show do
    link_to "Duplicate", duplicate_admin_brand_setting_path(brand_setting),
            method: :post
  end

  # Batch actions
  batch_action :activate do |ids|
    BrandSetting.where(id: ids).update_all(active: true)
    redirect_to collection_path, notice: "Brand settings activated!"
  end

  batch_action :deactivate do |ids|
    BrandSetting.where(id: ids).update_all(active: false)
    redirect_to collection_path, notice: "Brand settings deactivated!"
  end
end
```

### 5.2 Form JavaScript Enhancement (Optional)

```javascript
// app/assets/javascripts/admin/brand_settings.js
$(document).ready(function() {
  // Show/hide custom colors based on theme selection
  $('#brand_setting_theme_id').on('change', function() {
    const selectedTheme = $(this).val();
    const customColorsSection = $('#custom-colors-section');

    if (selectedTheme === 'custom') {
      customColorsSection.show();
    } else {
      customColorsSection.hide();
    }
  });

  // Trigger on page load
  $('#brand_setting_theme_id').trigger('change');

  // Live color preview
  $('input[type="color"]').on('change', function() {
    const colorValue = $(this).val();
    const previewDiv = $(this).closest('.input').find('.inline-hints');
    previewDiv.css('background-color', colorValue);
  });
});
```

---

## 6. API ENDPOINTS {#api-endpoints}

### 6.1 API Controller

```ruby
# app/controllers/api/v1/brand_settings_controller.rb
module Api
  module V1
    class BrandSettingsController < ApiController
      # GET /api/v1/brand_settings/current
      # Returns the active brand setting for current context
      def current
        brand_setting = fetch_brand_setting

        if brand_setting
          render json: BrandSettingSerializer.new(brand_setting).as_json
        else
          render json: default_brand_response, status: :ok
        end
      end

      # GET /api/v1/brand_settings/:id
      # Returns a specific brand setting (admin only)
      def show
        authorize! :read, BrandSetting

        brand_setting = BrandSetting.find(params[:id])
        render json: BrandSettingSerializer.new(brand_setting).as_json
      end

      private

      def fetch_brand_setting
        # Priority order:
        # 1. Organization-specific setting (if user belongs to an org)
        # 2. Global setting

        if current_user&.organization_id.present?
          org_setting = BrandSetting.active
                                    .where(scope: 'organization',
                                           organization_id: current_user.organization_id)
                                    .first
          return org_setting if org_setting
        end

        # Fallback to global setting
        BrandSetting.active.where(scope: 'global').first
      end

      def default_brand_response
        {
          theme: {
            id: 'default',
            name: 'PlebisHub Default',
            description: 'Original PlebisHub brand colors',
            colors: {
              primary: '#612d62',
              primaryLight: '#8a4f98',
              primaryDark: '#4c244a',
              secondary: '#269283',
              secondaryLight: '#14b8a6',
              secondaryDark: '#0f766e'
            }
          },
          customColors: nil,
          version: '1.0.0',
          source: 'default'
        }
      end
    end
  end
end
```

### 6.2 Serializer

```ruby
# app/serializers/brand_setting_serializer.rb
class BrandSettingSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :description, :scope, :theme_id,
             :active, :version, :updated_at

  attribute :theme do |setting|
    {
      id: setting.theme_id,
      name: setting.theme_name || setting.predefined_theme_name,
      description: setting.description,
      colors: setting.theme_colors
    }
  end

  attribute :customColors do |setting|
    if setting.has_custom_colors?
      {
        primary: setting.primary_color,
        primaryLight: setting.primary_light_color,
        primaryDark: setting.primary_dark_color,
        secondary: setting.secondary_color,
        secondaryLight: setting.secondary_light_color,
        secondaryDark: setting.secondary_dark_color
      }
    else
      nil
    end
  end

  attribute :metadata do |setting|
    setting.metadata
  end
end

# Alternative: Using JBuilder
# app/views/api/v1/brand_settings/show.json.jbuilder
json.theme do
  json.id @brand_setting.theme_id
  json.name @brand_setting.theme_name || @brand_setting.predefined_theme_name
  json.description @brand_setting.description
  json.colors @brand_setting.theme_colors
end

json.customColors do
  if @brand_setting.has_custom_colors?
    json.primary @brand_setting.primary_color
    json.primaryLight @brand_setting.primary_light_color
    json.primaryDark @brand_setting.primary_dark_color
    json.secondary @brand_setting.secondary_color
    json.secondaryLight @brand_setting.secondary_light_color
    json.secondaryDark @brand_setting.secondary_dark_color
  else
    json.nil!
  end
end

json.version @brand_setting.version
json.exportedAt @brand_setting.updated_at.iso8601
```

### 6.3 Routes

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :brand_settings, only: [:show] do
      collection do
        get :current
      end
    end
  end
end

# Generates:
# GET /api/v1/brand_settings/current
# GET /api/v1/brand_settings/:id
```

---

## 7. VALIDATION REQUIREMENTS {#validation-requirements}

### 7.1 Model Validations

```ruby
# app/models/brand_setting.rb
class BrandSetting < ApplicationRecord
  belongs_to :organization, optional: true

  # Constants
  PREDEFINED_THEMES = {
    'default' => {
      name: 'PlebisHub Default',
      colors: {
        primary: '#612d62',
        primaryLight: '#8a4f98',
        primaryDark: '#4c244a',
        secondary: '#269283',
        secondaryLight: '#14b8a6',
        secondaryDark: '#0f766e'
      }
    },
    'ocean' => {
      name: 'Ocean Blue',
      colors: {
        primary: '#1e40af',
        primaryLight: '#3b82f6',
        primaryDark: '#1e3a8a',
        secondary: '#0891b2',
        secondaryLight: '#06b6d4',
        secondaryDark: '#0e7490'
      }
    },
    'forest' => {
      name: 'Forest Green',
      colors: {
        primary: '#15803d',
        primaryLight: '#22c55e',
        primaryDark: '#14532d',
        secondary: '#0d9488',
        secondaryLight: '#14b8a6',
        secondaryDark: '#115e59'
      }
    },
    'sunset' => {
      name: 'Sunset Orange',
      colors: {
        primary: '#c2410c',
        primaryLight: '#f97316',
        primaryDark: '#7c2d12',
        secondary: '#dc2626',
        secondaryLight: '#ef4444',
        secondaryDark: '#991b1b'
      }
    },
    'monochrome' => {
      name: 'Monochrome',
      colors: {
        primary: '#1a1a1a',
        primaryLight: '#404040',
        primaryDark: '#000000',
        secondary: '#666666',
        secondaryLight: '#999999',
        secondaryDark: '#333333'
      }
    }
  }.freeze

  HEX_COLOR_REGEX = /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :scope, presence: true, inclusion: { in: %w[global organization] }
  validates :theme_id, presence: true

  # Scope-specific validations
  validates :organization_id, presence: true, if: -> { scope == 'organization' }
  validates :organization_id, absence: true, if: -> { scope == 'global' }

  # Color format validations
  validates :primary_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true
  validates :primary_light_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true
  validates :primary_dark_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true
  validates :secondary_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true
  validates :secondary_light_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true
  validates :secondary_dark_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true

  # Custom validations
  validate :organization_id_uniqueness_per_scope
  validate :at_least_one_active_global_setting
  validate :color_contrast_validation

  # Scopes
  scope :active, -> { where(active: true) }
  scope :global_settings, -> { where(scope: 'global') }
  scope :organization_settings, -> { where(scope: 'organization') }

  # Callbacks
  before_validation :set_theme_name_from_predefined, if: -> { theme_name.blank? }
  after_commit :clear_cache

  # Instance methods
  def predefined_theme_name
    PREDEFINED_THEMES.dig(theme_id, :name)
  end

  def predefined_theme_colors
    PREDEFINED_THEMES.dig(theme_id, :colors) || {}
  end

  def theme_colors
    if has_custom_colors?
      {
        primary: primary_color,
        primaryLight: primary_light_color,
        primaryDark: primary_dark_color,
        secondary: secondary_color,
        secondaryLight: secondary_light_color,
        secondaryDark: secondary_dark_color
      }
    else
      predefined_theme_colors
    end
  end

  def has_custom_colors?
    [
      primary_color,
      primary_light_color,
      primary_dark_color,
      secondary_color,
      secondary_light_color,
      secondary_dark_color
    ].any?(&:present?)
  end

  def colors_changed?
    saved_change_to_primary_color? ||
      saved_change_to_primary_light_color? ||
      saved_change_to_primary_dark_color? ||
      saved_change_to_secondary_color? ||
      saved_change_to_secondary_light_color? ||
      saved_change_to_secondary_dark_color?
  end

  private

  def organization_id_uniqueness_per_scope
    if scope == 'organization' && organization_id.present?
      existing = BrandSetting.where(
        scope: 'organization',
        organization_id: organization_id
      ).where.not(id: id).exists?

      if existing
        errors.add(:organization_id,
                   'already has a brand setting. Only one per organization allowed.')
      end
    end
  end

  def at_least_one_active_global_setting
    if scope == 'global' && !active
      other_active_global = BrandSetting.global_settings
                                       .active
                                       .where.not(id: id)
                                       .exists?

      unless other_active_global
        errors.add(:active,
                   'at least one global brand setting must be active')
      end
    end
  end

  def color_contrast_validation
    return unless has_custom_colors?

    # Validate primary color contrast with white background
    if primary_color.present?
      contrast = calculate_contrast_ratio(primary_color, '#ffffff')
      if contrast < 4.5
        errors.add(:primary_color,
                   "has insufficient contrast ratio (#{contrast.round(2)}:1). " \
                   "WCAG AA requires at least 4.5:1 for normal text.")
      end
    end

    # Validate secondary color contrast with white background
    if secondary_color.present?
      contrast = calculate_contrast_ratio(secondary_color, '#ffffff')
      if contrast < 4.5
        errors.add(:secondary_color,
                   "has insufficient contrast ratio (#{contrast.round(2)}:1). " \
                   "WCAG AA requires at least 4.5:1 for normal text.")
      end
    end
  end

  def calculate_contrast_ratio(color1, color2)
    luminance1 = relative_luminance(color1)
    luminance2 = relative_luminance(color2)

    lighter = [luminance1, luminance2].max
    darker = [luminance1, luminance2].min

    (lighter + 0.05) / (darker + 0.05)
  end

  def relative_luminance(hex_color)
    rgb = hex_color.match(HEX_COLOR_REGEX)[1]
    r, g, b = if rgb.length == 3
                rgb.chars.map { |c| (c * 2).to_i(16) }
              else
                [rgb[0..1], rgb[2..3], rgb[4..5]].map { |c| c.to_i(16) }
              end

    r_srgb = r / 255.0
    g_srgb = g / 255.0
    b_srgb = b / 255.0

    r_linear = r_srgb <= 0.03928 ? r_srgb / 12.92 : ((r_srgb + 0.055) / 1.055)**2.4
    g_linear = g_srgb <= 0.03928 ? g_srgb / 12.92 : ((g_srgb + 0.055) / 1.055)**2.4
    b_linear = b_srgb <= 0.03928 ? b_srgb / 12.92 : ((b_srgb + 0.055) / 1.055)**2.4

    0.2126 * r_linear + 0.7152 * g_linear + 0.0722 * b_linear
  end

  def set_theme_name_from_predefined
    self.theme_name = predefined_theme_name if theme_id.present?
  end

  def clear_cache
    Rails.cache.delete(['brand_setting', scope, organization_id])
  end
end
```

---

## 8. SECURITY CONSIDERATIONS {#security-considerations}

### 8.1 Authorization

```ruby
# app/models/ability.rb (CanCanCan)
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    if user.admin?
      # Admins can manage all brand settings
      can :manage, BrandSetting
    elsif user.organization_admin?
      # Organization admins can only manage their org's settings
      can :read, BrandSetting, scope: 'global'
      can :manage, BrandSetting, scope: 'organization',
                                 organization_id: user.organization_id
    else
      # Regular users can only read active settings
      can :read, BrandSetting, active: true
    end
  end
end
```

### 8.2 Rate Limiting

```ruby
# config/initializers/rack_attack.rb
Rack::Attack.throttle('api/brand_settings', limit: 10, period: 1.minute) do |req|
  req.ip if req.path == '/api/v1/brand_settings/current'
end
```

### 8.3 Input Sanitization

All color inputs are validated against `HEX_COLOR_REGEX` to prevent XSS attacks through color values.

---

## 9. TESTING REQUIREMENTS {#testing-requirements}

### 9.1 Model Tests

```ruby
# spec/models/brand_setting_spec.rb
require 'rails_helper'

RSpec.describe BrandSetting, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:scope) }
    it { should validate_presence_of(:theme_id) }

    context 'color format validation' do
      it 'accepts valid hex colors' do
        setting = build(:brand_setting, primary_color: '#612d62')
        expect(setting).to be_valid
      end

      it 'accepts short hex colors' do
        setting = build(:brand_setting, primary_color: '#fff')
        expect(setting).to be_valid
      end

      it 'rejects invalid hex colors' do
        setting = build(:brand_setting, primary_color: 'invalid')
        expect(setting).not_to be_valid
        expect(setting.errors[:primary_color]).to be_present
      end

      it 'rejects hex without hash' do
        setting = build(:brand_setting, primary_color: '612d62')
        expect(setting).not_to be_valid
      end
    end

    context 'contrast validation' do
      it 'rejects colors with insufficient contrast' do
        setting = build(:brand_setting, primary_color: '#f0f0f0')
        expect(setting).not_to be_valid
        expect(setting.errors[:primary_color]).to include(/insufficient contrast/)
      end

      it 'accepts colors with sufficient contrast' do
        setting = build(:brand_setting, primary_color: '#612d62')
        expect(setting).to be_valid
      end
    end

    context 'scope validations' do
      it 'requires organization_id for organization scope' do
        setting = build(:brand_setting, scope: 'organization', organization_id: nil)
        expect(setting).not_to be_valid
      end

      it 'forbids organization_id for global scope' do
        setting = build(:brand_setting, scope: 'global', organization_id: 1)
        expect(setting).not_to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:active_setting) { create(:brand_setting, active: true) }
    let!(:inactive_setting) { create(:brand_setting, active: false) }

    it 'returns only active settings' do
      expect(BrandSetting.active).to include(active_setting)
      expect(BrandSetting.active).not_to include(inactive_setting)
    end
  end

  describe '#has_custom_colors?' do
    it 'returns true when custom colors are present' do
      setting = build(:brand_setting, primary_color: '#612d62')
      expect(setting.has_custom_colors?).to be true
    end

    it 'returns false when no custom colors' do
      setting = build(:brand_setting,
                     primary_color: nil,
                     secondary_color: nil)
      expect(setting.has_custom_colors?).to be false
    end
  end

  describe '#theme_colors' do
    it 'returns custom colors when present' do
      setting = build(:brand_setting,
                     primary_color: '#612d62',
                     primary_light_color: '#8a4f98')

      colors = setting.theme_colors
      expect(colors[:primary]).to eq('#612d62')
      expect(colors[:primaryLight]).to eq('#8a4f98')
    end

    it 'returns predefined theme colors when no custom colors' do
      setting = build(:brand_setting, theme_id: 'ocean')
      colors = setting.theme_colors
      expect(colors[:primary]).to eq('#1e40af')
    end
  end
end
```

### 9.2 Controller Tests

```ruby
# spec/controllers/api/v1/brand_settings_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::BrandSettingsController, type: :controller do
  describe 'GET #current' do
    context 'with global brand setting' do
      let!(:global_setting) { create(:brand_setting, scope: 'global', active: true) }

      it 'returns the active global setting' do
        get :current
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['theme']['id']).to eq(global_setting.theme_id)
      end
    end

    context 'with organization-specific setting' do
      let(:organization) { create(:organization) }
      let(:user) { create(:user, organization: organization) }
      let!(:org_setting) do
        create(:brand_setting,
               scope: 'organization',
               organization: organization,
               active: true)
      end

      before { sign_in user }

      it 'returns the organization setting' do
        get :current
        json = JSON.parse(response.body)
        expect(json['theme']['id']).to eq(org_setting.theme_id)
      end
    end

    context 'without any brand settings' do
      it 'returns default brand configuration' do
        get :current
        json = JSON.parse(response.body)
        expect(json['theme']['id']).to eq('default')
        expect(json['source']).to eq('default')
      end
    end
  end
end
```

### 9.3 Feature/Integration Tests

```ruby
# spec/features/admin/brand_settings_spec.rb
require 'rails_helper'

RSpec.describe 'Admin Brand Settings', type: :feature do
  let(:admin) { create(:admin_user) }

  before { login_as(admin, scope: :admin_user) }

  scenario 'Admin creates a new brand setting' do
    visit admin_brand_settings_path
    click_link 'New Brand Setting'

    fill_in 'Name', with: 'Custom Theme'
    select 'global', from: 'Scope'
    select 'ocean', from: 'Theme'

    click_button 'Create Brand setting'

    expect(page).to have_content('Brand setting created successfully')
    expect(page).to have_content('Custom Theme')
  end

  scenario 'Admin sets custom colors with color picker' do
    visit new_admin_brand_setting_path

    fill_in 'Name', with: 'Custom Colors'
    fill_in 'Primary color', with: '#ff0000'
    fill_in 'Secondary color', with: '#00ff00'

    click_button 'Create Brand setting'

    expect(page).to have_content('Brand setting created successfully')
  end
end
```

---

## 10. MIGRATION GUIDE {#migration-guide}

### 10.1 Step-by-Step Implementation

**Phase 1: Database & Models (Day 1)**
1. Create migration file
2. Run migration: `rails db:migrate`
3. Create BrandSetting model with validations
4. Add seed data: `rails db:seed`
5. Run model tests: `rspec spec/models/brand_setting_spec.rb`

**Phase 2: API Endpoints (Day 2)**
1. Create API controller
2. Create serializer or jbuilder views
3. Add routes
4. Run controller tests
5. Test API manually with curl/Postman

**Phase 3: ActiveAdmin Interface (Day 3)**
1. Create ActiveAdmin resource
2. Add custom form fields
3. Add color preview functionality
4. Test in browser

**Phase 4: Integration & Testing (Day 4)**
1. Integration testing
2. Manual UAT with frontend team
3. Performance testing
4. Security audit

**Phase 5: Documentation & Deployment (Day 5)**
1. Update API documentation
2. Update README
3. Create deployment runbook
4. Deploy to staging
5. Deploy to production

### 10.2 Rollback Plan

If issues arise, the system degrades gracefully:
1. Frontend continues using `localStorage` if API fails
2. Database can be rolled back with `rails db:rollback`
3. ActiveAdmin resource can be disabled without affecting API

---

## 11. EXAMPLE IMPLEMENTATION {#example-implementation}

### 11.1 Complete Example Request/Response

**Request:**
```bash
GET /api/v1/brand_settings/current HTTP/1.1
Host: plebishub.com
Accept: application/json
Authorization: Bearer <token>
```

**Response:**
```json
{
  "theme": {
    "id": "ocean",
    "name": "Ocean Blue",
    "description": "Cool blue tones for coastal organizations",
    "colors": {
      "primary": "#1e40af",
      "primaryLight": "#3b82f6",
      "primaryDark": "#1e3a8a",
      "secondary": "#0891b2",
      "secondaryLight": "#06b6d4",
      "secondaryDark": "#0e7490"
    }
  },
  "customColors": {
    "primary": "#0055cc",
    "primaryLight": "#3377dd",
    "primaryDark": "#003388",
    "secondary": "#00aa88",
    "secondaryLight": "#33ccaa",
    "secondaryDark": "#008866"
  },
  "version": "1.0.0",
  "metadata": {
    "lastModifiedBy": "admin@plebishub.com",
    "notes": "Updated for summer campaign"
  },
  "updatedAt": "2025-11-12T15:30:00Z"
}
```

### 11.2 Frontend Integration Example

```typescript
// Frontend: app/frontend/composables/useBrand.ts

// NEW: Load from API instead of localStorage
async function loadBrandFromAPI(): Promise<boolean> {
  try {
    isLoading.value = true
    const response = await fetch('/api/v1/brand_settings/current')

    if (!response.ok) {
      throw new Error('Failed to fetch brand settings')
    }

    const data: BrandExportData = await response.json()

    if (data.theme) {
      currentTheme.value = data.theme
    }

    if (data.customColors) {
      customColors.value = data.customColors
    }

    applyBrandColorsToDOM(brandColors.value)
    error.value = null
    isLoading.value = false

    return true
  } catch (err) {
    error.value = new BrandError(
      BrandErrorType.STORAGE_ERROR,
      'Failed to load brand from API',
      err
    )

    // Fallback to localStorage
    return loadBrandFromStorage()
  }
}
```

---

## 📞 SUPPORT & QUESTIONS

### Frontend Team Contacts

- **Lead Developer:** frontend-lead@plebishub.com
- **Slack Channel:** #frontend-team
- **Documentation:** See `REFACTORING_REPORT.md` for technical details

### Questions to Address

1. **Multi-tenancy:** Should we support multiple active organization settings?
2. **Caching:** What's the preferred caching strategy? (Redis, Memcached, Rails.cache)
3. **Versioning:** Should we track full history of brand changes?
4. **Assets:** Will we also need to store logo files? (Not in scope now, but future consideration)

### Timeline & Milestones

| Milestone | Target Date | Dependencies |
|-----------|-------------|--------------|
| Database migration | Day 1 | None |
| Model implementation | Day 1-2 | Database |
| API endpoints | Day 2-3 | Model |
| ActiveAdmin resource | Day 3 | Model |
| Testing | Day 4 | All above |
| Staging deployment | Day 5 | Testing complete |
| Production deployment | Day 6 | Staging validated |

---

## ✅ ACCEPTANCE CRITERIA

### Must Have
- ✅ Database table created with proper indexes
- ✅ BrandSetting model with all validations
- ✅ ActiveAdmin CRUD interface working
- ✅ API endpoint `/api/v1/brand_settings/current` returning correct JSON
- ✅ Color format validation (hex colors)
- ✅ WCAG contrast validation
- ✅ Multi-tenant support (global + organization scopes)
- ✅ At least 80% test coverage

### Should Have
- ✅ Duplicate brand setting action in ActiveAdmin
- ✅ Batch activate/deactivate actions
- ✅ Color preview in ActiveAdmin
- ✅ Audit logging of changes

### Nice to Have
- 🟢 Redis caching layer
- 🟢 Version history tracking
- 🟢 Import/export functionality in ActiveAdmin
- 🟢 Webhook notifications on brand changes

---

**Document Status:** ✅ Ready for Implementation
**Last Updated:** November 12, 2025
**Version:** 1.0
**Approved By:** Frontend Team Lead
