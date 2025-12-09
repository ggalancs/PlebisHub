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

  # ========================================
  # BRAND IMAGE HELPERS
  # ========================================

  # Returns the URL for a specific brand image by key
  # Priority: brand_setting > organization > global > fallback
  def brand_image_url(key, fallback: nil)
    image = BrandImage.find_for(
      key,
      brand_setting: current_brand_setting,
      organization: current_organization_for_brand
    )

    if image&.image&.attached?
      url_for(image.image)
    else
      fallback || default_image_fallback(key)
    end
  rescue StandardError => e
    Rails.logger.warn("BrandHelper#brand_image_url error for #{key}: #{e.message}")
    fallback || default_image_fallback(key)
  end

  # Returns an image tag for a brand image with proper alt text
  def brand_image_tag(key, options = {})
    fallback = options.delete(:fallback)
    alt = options.delete(:alt)

    image = BrandImage.find_for(
      key,
      brand_setting: current_brand_setting,
      organization: current_organization_for_brand
    )

    if image&.image&.attached?
      image_tag url_for(image.image),
                options.merge(alt: alt || image.alt_text || image.name)
    elsif fallback
      image_tag fallback, options.merge(alt: alt || key.to_s.humanize)
    else
      default_path = default_image_fallback(key)
      image_tag default_path, options.merge(alt: alt || key.to_s.humanize) if default_path
    end
  rescue StandardError => e
    Rails.logger.warn("BrandHelper#brand_image_tag error for #{key}: #{e.message}")
    fallback_path = fallback || default_image_fallback(key)
    image_tag(fallback_path, options.merge(alt: alt || key.to_s.humanize)) if fallback_path
  end

  # Returns the main logo URL (uses brand_image if available, falls back to URL setting)
  def brand_logo_image_url(dark_mode: false)
    key = dark_mode ? 'logo_dark' : 'logo_main'
    image = BrandImage.find_for(
      key,
      brand_setting: current_brand_setting,
      organization: current_organization_for_brand
    )

    if image&.image&.attached?
      url_for(image.image)
    else
      # Fall back to URL-based logo from BrandSetting
      brand_logo_url(dark_mode: dark_mode)
    end
  rescue StandardError
    brand_logo_url(dark_mode: dark_mode)
  end

  # Returns the favicon URL (uses brand_image if available, falls back to URL setting)
  def brand_favicon_image_url
    image = BrandImage.find_for(
      'favicon',
      brand_setting: current_brand_setting,
      organization: current_organization_for_brand
    )

    if image&.image&.attached?
      url_for(image.image)
    else
      brand_favicon_url
    end
  rescue StandardError
    brand_favicon_url
  end

  # Returns a social media icon URL
  def brand_social_icon_url(platform)
    key = "social_#{platform.to_s.downcase}"
    brand_image_url(key, fallback: nil)
  end

  # Returns a banner image URL
  def brand_banner_url(banner_key)
    key = banner_key.to_s.start_with?('banner_') ? banner_key.to_s : "banner_#{banner_key}"
    brand_image_url(key, fallback: nil)
  end

  # Check if a brand image exists for a given key
  def brand_image_exists?(key)
    image = BrandImage.find_for(
      key,
      brand_setting: current_brand_setting,
      organization: current_organization_for_brand
    )
    image&.image&.attached?
  rescue StandardError
    false
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

  # Safely retrieves current organization object for brand images
  def current_organization_for_brand
    return current_organization if respond_to?(:current_organization) && current_organization
    return current_user.organization if respond_to?(:current_user) && current_user&.respond_to?(:organization)

    nil
  rescue StandardError
    nil
  end

  # Default fallback images based on key
  def default_image_fallback(key)
    fallbacks = {
      'logo_main' => 'brand/logo-horizontal.svg',
      'logo_dark' => 'brand/logo-inverted.svg',
      'logo_white' => 'brand/logo-inverted.svg',
      'logo_square' => 'brand/logo-mark.svg',
      'logo_admin' => 'admin_logo.png',
      'favicon' => 'favicon.png',
      'favicon_large' => 'favicon.png',
      'social_facebook' => 'ico.social45-facebook-on.png',
      'social_twitter' => 'ico.social45-twitter-on.png',
      'social_youtube' => 'ico.social45-youtube-on.png',
      'banner_collaborations' => 'banner_collabs.png',
      'banner_microcredits' => 'microcredits-banner.jpg',
      'icon_menu_hamburger' => 'ico.menu-hamb-on.png',
      'icon_menu_profile' => 'ico.menu-profile-on.png',
      'icon_menu_economics' => 'ico.menu-econ-on.png',
      'icon_menu_teams' => 'ico.menu-team-on.png',
      'icon_menu_tools' => 'ico.menu-tools-on.png',
      'icon_menu_notifications' => 'ico.menu-notif-on.png'
    }

    path = fallbacks[key.to_s]
    path ? asset_path(path) : nil
  rescue StandardError
    nil
  end
end
