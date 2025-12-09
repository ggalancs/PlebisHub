# frozen_string_literal: true

module BrandHelper
  # Fetches the active brand setting for the current organization context
  # Uses caching to avoid repeated database queries
  def current_brand_setting
    @current_brand_setting ||= Rails.cache.fetch(brand_cache_key, expires_in: 1.hour) do
      org_id = current_organization_id
      BrandSetting.current_for_organization(org_id)
    end
  end

  # Generates and returns the complete style tag for brand theme injection
  # Includes CSS custom properties and optional custom CSS
  def brand_style_tag
    current_brand_setting.to_style_tag.html_safe
  end

  # Returns the appropriate logo URL based on dark mode preference
  # Falls back to default logo if none configured
  def brand_logo_url(dark_mode: false)
    setting = current_brand_setting
    url = setting.effective_logo_url(dark_mode: dark_mode)
    url.presence || asset_path('brand/logo-horizontal.svg')
  rescue StandardError
    asset_path('brand/logo-horizontal.svg')
  end

  # Returns the favicon URL with fallback to default
  def brand_favicon_url
    setting = current_brand_setting
    setting.effective_favicon_url.presence || asset_path('favicon.png')
  rescue StandardError
    asset_path('favicon.png')
  end

  # Generates Google Fonts link tag for the configured fonts
  # Only loads fonts that differ from browser defaults
  def brand_font_link_tag
    setting = current_brand_setting
    fonts = [setting.effective_font_primary, setting.effective_font_display].compact.uniq

    return ''.html_safe if fonts.empty?

    # Build Google Fonts URL with proper encoding
    font_families = fonts.map do |font|
      "#{ERB::Util.url_encode(font)}:wght@300;400;500;600;700"
    end.join('&family=')

    tag.link(
      rel: 'stylesheet',
      href: "https://fonts.googleapis.com/css2?family=#{font_families}&display=swap"
    )
  end

  # Generates meta tags for browser theme color (mobile address bar, etc.)
  def brand_meta_tags
    setting = current_brand_setting
    colors = setting.theme_colors

    return ''.html_safe if colors.blank?

    primary_color = colors[:primary]
    return ''.html_safe if primary_color.blank?

    tags = []
    tags << tag.meta(name: 'theme-color', content: primary_color)
    tags << tag.meta(name: 'msapplication-TileColor', content: primary_color)
    safe_join(tags, "\n")
  end

  # Returns a specific color from the current brand theme
  def brand_color(color_type = :primary)
    colors = current_brand_setting.theme_colors
    case color_type.to_sym
    when :primary then colors[:primary]
    when :primary_light then colors[:primaryLight]
    when :primary_dark then colors[:primaryDark]
    when :secondary then colors[:secondary]
    when :secondary_light then colors[:secondaryLight]
    when :secondary_dark then colors[:secondaryDark]
    end
  end

  # Returns the current theme name for display purposes
  def brand_theme_name
    setting = current_brand_setting
    setting.theme_name.presence || setting.predefined_theme_name || 'Default'
  end

  # Check if custom branding is active (vs. default theme)
  def custom_brand_active?
    setting = current_brand_setting
    setting.persisted? && (setting.has_custom_colors? || setting.theme_id != 'default')
  end

  # Generates preload hint for critical fonts
  def brand_font_preload_tags
    setting = current_brand_setting
    fonts = [setting.effective_font_primary, setting.effective_font_display].compact.uniq

    return ''.html_safe if fonts.empty?

    # Preload the font CSS file
    font_families = fonts.map do |font|
      "#{ERB::Util.url_encode(font)}:wght@400;500;600"
    end.join('&family=')

    tag.link(
      rel: 'preload',
      href: "https://fonts.googleapis.com/css2?family=#{font_families}&display=swap",
      as: 'style'
    )
  end

  private

  # Generates cache key for brand setting based on organization context
  def brand_cache_key
    org_id = current_organization_id || 'global'
    "brand_setting/active/#{org_id}"
  end

  # Safely retrieves current organization ID
  # Returns nil if no organization context or method not available
  def current_organization_id
    return current_organization.id if respond_to?(:current_organization) && current_organization
    return current_user.organization_id if respond_to?(:current_user) && current_user&.respond_to?(:organization_id)

    nil
  rescue StandardError
    nil
  end
end
