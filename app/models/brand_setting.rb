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

  # Custom validations
  validate :unique_organization_setting
  validate :at_least_one_active_global
  validate :wcag_contrast_validation, if: :has_custom_colors?

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
      customColors: has_custom_colors? ? {
        primary: primary_color,
        primaryLight: primary_light_color,
        primaryDark: primary_dark_color,
        secondary: secondary_color,
        secondaryLight: secondary_light_color,
        secondaryDark: secondary_dark_color
      }.compact : nil,
      metadata: metadata,
      createdAt: created_at&.iso8601,
      updatedAt: updated_at&.iso8601
    }
  end

  private

  def unique_organization_setting
    return unless organization_scope? && organization_id.present?

    existing = self.class.where(
      scope: 'organization',
      organization_id: organization_id
    ).where.not(id: id).exists?

    if existing
      errors.add(:organization_id, 'already has a brand setting. Only one per organization allowed.')
    end
  end

  def at_least_one_active_global
    return unless global_scope? && !active

    other_active_global = self.class.global_settings
                              .active
                              .where.not(id: id)
                              .exists?

    unless other_active_global
      errors.add(:active, 'cannot be disabled. At least one global brand setting must be active.')
    end
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
    if secondary_color.present? && secondary_color.match?(HEX_COLOR_REGEX)
      ratio = calculate_contrast_ratio(secondary_color, '#ffffff')
      if ratio < 4.5
        errors.add(:secondary_color,
                   "has insufficient contrast (#{ratio.round(2)}:1). WCAG AA requires ≥ 4.5:1.")
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
    0.2126 * r_linear + 0.7152 * g_linear + 0.0722 * b_linear
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
