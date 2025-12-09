# frozen_string_literal: true

# == Schema Information
#
# Table name: brand_settings
#
#  id                     :bigint           not null, primary key
#  name                   :string           not null
#  description            :text
#  scope                  :string           default("global"), not null
#  organization_id        :bigint
#  theme_id               :string           default("default"), not null
#  theme_name             :string
#  primary_color          :string(7)
#  primary_light_color    :string(7)
#  primary_dark_color     :string(7)
#  secondary_color        :string(7)
#  secondary_light_color  :string(7)
#  secondary_dark_color   :string(7)
#  active                 :boolean          default(TRUE), not null
#  version                :integer          default(1), not null
#  metadata               :jsonb            default({}), not null
#  font_primary           :string           default("Inter")
#  font_display           :string           default("Montserrat")
#  logo_url               :string
#  logo_dark_url          :string
#  favicon_url            :string
#  custom_css             :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class BrandSetting < ApplicationRecord
  # Associations
  belongs_to :organization, optional: true

  # Constants - Predefined Themes (matches frontend exactly)
  PREDEFINED_THEMES = {
    'default' => {
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
    'ocean' => {
      name: 'Ocean Blue',
      description: 'Cool blue tones',
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
      description: 'Natural green palette',
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
      description: 'Warm orange and red tones',
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
      description: 'Black and white',
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

  # Hex color regex (supports #RGB and #RRGGBB)
  HEX_COLOR_REGEX = /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/

  # Valid scopes
  VALID_SCOPES = %w[global organization].freeze

  # Allowed fonts (Google Fonts whitelist for security)
  ALLOWED_FONTS = [
    'Inter',
    'Montserrat',
    'Roboto',
    'Open Sans',
    'Lato',
    'Poppins',
    'Source Sans Pro',
    'Nunito',
    'Raleway',
    'Work Sans'
  ].freeze

  # Validations - Basic
  validates :name, presence: true, length: { maximum: 255 }
  validates :scope, presence: true, inclusion: { in: VALID_SCOPES }
  validates :theme_id, presence: true
  validates :version, numericality: { only_integer: true, greater_than: 0 }

  # Validations - Scope-specific
  validates :organization_id, presence: true, if: :organization_scope?
  validates :organization_id, absence: true, if: :global_scope?

  # Validations - Color format
  validates :primary_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true
  validates :primary_light_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true
  validates :primary_dark_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true
  validates :secondary_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true
  validates :secondary_light_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true
  validates :secondary_dark_color, format: { with: HEX_COLOR_REGEX }, allow_blank: true

  # Validations - Typography and assets
  validates :font_primary, inclusion: { in: ALLOWED_FONTS }, allow_blank: true
  validates :font_display, inclusion: { in: ALLOWED_FONTS }, allow_blank: true
  validates :logo_url, length: { maximum: 2048 }, allow_blank: true
  validates :logo_dark_url, length: { maximum: 2048 }, allow_blank: true
  validates :favicon_url, length: { maximum: 2048 }, allow_blank: true
  validates :custom_css, length: { maximum: 50_000 }, allow_blank: true

  # Virtual attribute to skip WCAG validation
  attr_accessor :skip_wcag_validation

  # Custom validations
  validate :unique_organization_setting
  validate :at_least_one_active_global
  validate :wcag_contrast_validation, if: :should_validate_wcag?

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :global_settings, -> { where(scope: 'global') }
  scope :organization_settings, -> { where(scope: 'organization') }
  scope :for_organization, ->(org_id) { where(scope: 'organization', organization_id: org_id) }

  # Callbacks
  before_validation :set_theme_name_from_predefined, if: -> { theme_name.blank? }
  before_save :increment_version_if_colors_changed
  after_commit :clear_cache

  # Class methods
  def self.current_for_organization(organization_id)
    setting = active.for_organization(organization_id).first if organization_id.present?
    setting || active.global_settings.first || BrandSetting.default_setting
  end

  def self.default_setting
    new(
      name: 'Default Theme',
      scope: 'global',
      theme_id: 'default',
      active: true
    )
  end

  # Calculate complementary color (180 degree hue shift)
  def self.complementary_color(hex)
    return '#269283' unless hex.present? && hex.match?(HEX_COLOR_REGEX)

    # Parse hex to RGB
    hex = hex.gsub('#', '')
    r = hex[0..1].to_i(16) / 255.0
    g = hex[2..3].to_i(16) / 255.0
    b = hex[4..5].to_i(16) / 255.0

    # RGB to HSL
    max = [r, g, b].max
    min = [r, g, b].min
    l = (max + min) / 2.0
    h = 0
    s = 0

    if max != min
      d = max - min
      s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min)
      case max
      when r then h = ((g - b) / d + (g < b ? 6 : 0)) / 6.0
      when g then h = ((b - r) / d + 2) / 6.0
      when b then h = ((r - g) / d + 4) / 6.0
      end
    end

    # Shift hue by 180 degrees (0.5)
    h = (h + 0.5) % 1.0

    # HSL to RGB
    if s == 0
      r = g = b = l
    else
      q = l < 0.5 ? l * (1 + s) : l + s - l * s
      p = 2 * l - q
      r = hue_to_rgb(p, q, h + 1.0 / 3.0)
      g = hue_to_rgb(p, q, h)
      b = hue_to_rgb(p, q, h - 1.0 / 3.0)
    end

    # RGB to hex
    format('#%02x%02x%02x', (r * 255).round, (g * 255).round, (b * 255).round)
  end

  def self.hue_to_rgb(p, q, t)
    t += 1 if t < 0
    t -= 1 if t > 1
    return p + (q - p) * 6 * t if t < 1.0 / 6.0
    return q if t < 1.0 / 2.0
    return p + (q - p) * (2.0 / 3.0 - t) * 6 if t < 2.0 / 3.0

    p
  end

  # Instance methods
  def predefined_theme_name
    PREDEFINED_THEMES.dig(theme_id, :name)
  end

  def predefined_theme_description
    PREDEFINED_THEMES.dig(theme_id, :description)
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
      }.compact
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
    primary_color_changed? ||
      primary_light_color_changed? ||
      primary_dark_color_changed? ||
      secondary_color_changed? ||
      secondary_light_color_changed? ||
      secondary_dark_color_changed?
  end

  # Check if WCAG validation should run
  def should_validate_wcag?
    has_custom_colors? && !skip_wcag_validation_enabled?
  end

  def skip_wcag_validation_enabled?
    ActiveModel::Type::Boolean.new.cast(skip_wcag_validation)
  end

  # Public method to get contrast ratio (for display in admin)
  def contrast_ratio_for(color)
    return nil unless color.present? && color.match?(HEX_COLOR_REGEX)

    calculate_contrast_ratio(color, '#ffffff')
  end

  def global_scope?
    scope == 'global'
  end

  def organization_scope?
    scope == 'organization'
  end

  def cache_key_with_version
    "brand_setting/#{scope}/#{organization_id || 'global'}/v#{version}"
  end

  # Serialize to JSON format expected by frontend
  def to_brand_json
    {
      theme: {
        id: theme_id,
        name: theme_name || predefined_theme_name,
        description: predefined_theme_description,
        colors: theme_colors
      },
      scope: scope,
      organizationId: organization_id,
      active: active,
      version: version,
      customColors: if has_custom_colors?
                      {
                        primary: primary_color,
                        primaryLight: primary_light_color,
                        primaryDark: primary_dark_color,
                        secondary: secondary_color,
                        secondaryLight: secondary_light_color,
                        secondaryDark: secondary_dark_color
                      }.compact
                    end,
      metadata: metadata,
      createdAt: created_at&.iso8601,
      updatedAt: updated_at&.iso8601
    }
  end

  # Generate CSS custom properties for theme injection
  def to_css_variables
    colors = theme_colors
    defaults = predefined_theme_colors

    <<~CSS.squish
      --color-primary: #{colors[:primary] || defaults[:primary]};
      --color-primary-light: #{colors[:primaryLight] || defaults[:primaryLight]};
      --color-primary-dark: #{colors[:primaryDark] || defaults[:primaryDark]};
      --color-secondary: #{colors[:secondary] || defaults[:secondary]};
      --color-secondary-light: #{colors[:secondaryLight] || defaults[:secondaryLight]};
      --color-secondary-dark: #{colors[:secondaryDark] || defaults[:secondaryDark]};
      --font-primary: '#{effective_font_primary}', sans-serif;
      --font-display: '#{effective_font_display}', sans-serif;
    CSS
  end

  # Generate complete style tag for layout injection
  def to_style_tag
    css = ":root { #{to_css_variables} }"
    css += " #{sanitized_custom_css}" if custom_css.present?
    "<style id=\"brand-theme\">#{css}</style>"
  end

  # Sanitize custom CSS to prevent XSS attacks
  def sanitized_custom_css
    return '' if custom_css.blank?

    # Remove potentially dangerous CSS patterns
    custom_css
      .gsub(%r{url\s*\([^)]*\)}i, '') # Remove url() to prevent external resource loading
      .gsub(/expression\s*\([^)]*\)/i, '') # Remove IE expression()
      .gsub(/javascript:/i, '') # Remove javascript: protocol
      .gsub(/@import/i, '') # Remove @import to prevent external stylesheet loading
      .gsub(/behavior\s*:/i, '') # Remove IE behavior property
      .gsub(/-moz-binding/i, '') # Remove Firefox XBL binding
      .strip
  end

  # Get effective font with fallback
  def effective_font_primary
    font_primary.presence || 'Inter'
  end

  def effective_font_display
    font_display.presence || 'Montserrat'
  end

  # Get effective logo URL with fallback
  def effective_logo_url(dark_mode: false)
    if dark_mode
      logo_dark_url.presence || logo_url.presence
    else
      logo_url.presence
    end
  end

  def effective_favicon_url
    favicon_url.presence
  end

  private

  def unique_organization_setting
    return unless organization_scope? && organization_id.present?

    existing = self.class.where(
      scope: 'organization',
      organization_id: organization_id
    ).where.not(id: id).exists?

    return unless existing

    errors.add(:organization_id, 'already has a brand setting. Only one per organization allowed.')
  end

  def at_least_one_active_global
    return unless global_scope? && !active

    other_active_global = self.class.global_settings
                              .active
                              .where.not(id: id)
                              .exists?

    return if other_active_global

    errors.add(:active, 'cannot be disabled. At least one global brand setting must be active.')
  end

  def wcag_contrast_validation
    # Validate primary color contrast with white background (WCAG AA requires 4.5:1)
    if primary_color.present? && primary_color.match?(HEX_COLOR_REGEX)
      ratio = calculate_contrast_ratio(primary_color, '#ffffff')
      if ratio < 4.5
        errors.add(:primary_color,
                   "has insufficient contrast (#{ratio.round(2)}:1). WCAG AA requires ≥ 4.5:1.")
      end
    end

    # Validate secondary color contrast
    return unless secondary_color.present? && secondary_color.match?(HEX_COLOR_REGEX)

    ratio = calculate_contrast_ratio(secondary_color, '#ffffff')
    return unless ratio < 4.5

    errors.add(:secondary_color,
               "has insufficient contrast (#{ratio.round(2)}:1). WCAG AA requires ≥ 4.5:1.")
  end

  def calculate_contrast_ratio(color1, color2)
    luminance1 = relative_luminance(color1)
    luminance2 = relative_luminance(color2)

    lighter = [luminance1, luminance2].max
    darker = [luminance1, luminance2].min

    (lighter + 0.05) / (darker + 0.05)
  end

  def relative_luminance(hex_color)
    # Parse hex color
    rgb = hex_color.match(HEX_COLOR_REGEX)[1]
    r, g, b = if rgb.length == 3
                # Short format: #RGB -> #RRGGBB
                rgb.chars.map { |c| (c * 2).to_i(16) }
              else
                # Long format: #RRGGBB
                [rgb[0..1], rgb[2..3], rgb[4..5]].map { |c| c.to_i(16) }
              end

    # Convert to sRGB
    r_srgb = r / 255.0
    g_srgb = g / 255.0
    b_srgb = b / 255.0

    # Apply gamma correction
    r_linear = r_srgb <= 0.03928 ? r_srgb / 12.92 : ((r_srgb + 0.055) / 1.055)**2.4
    g_linear = g_srgb <= 0.03928 ? g_srgb / 12.92 : ((g_srgb + 0.055) / 1.055)**2.4
    b_linear = b_srgb <= 0.03928 ? b_srgb / 12.92 : ((b_srgb + 0.055) / 1.055)**2.4

    # Calculate relative luminance using WCAG formula
    (0.2126 * r_linear) + (0.7152 * g_linear) + (0.0722 * b_linear)
  end

  def set_theme_name_from_predefined
    self.theme_name = predefined_theme_name if theme_id.present?
  end

  def increment_version_if_colors_changed
    self.version += 1 if colors_changed? && persisted?
  end

  def clear_cache
    Rails.cache.delete(cache_key_with_version)
    Rails.cache.delete("brand_setting/#{scope}/#{organization_id || 'global'}")
  end
end
