# frozen_string_literal: true

module ThemeHelper
  # Obtiene el tema activo actual
  def current_theme
    @current_theme ||= ThemeSetting.active || default_theme
  end

  # Genera el tag de estilo con las CSS variables del tema
  def theme_css_variables
    return if current_theme.nil?

    # Sanitizar el CSS antes de marcarlo como seguro
    css = sanitize_theme_css(current_theme.to_css)
    content_tag(:style, css.html_safe, id: 'custom-theme-styles')
  end

  # Retorna el atributo data-theme para el HTML tag
  def theme_data_attribute
    if current_theme&.persisted?
      "custom-#{current_theme.id}"
    else
      'default'
    end
  end

  # Retorna la URL del logo del tema actual
  def theme_logo_url
    current_theme&.logo_url || asset_path('logo.png')
  end

  # Retorna la URL del favicon del tema actual
  def theme_favicon_url
    current_theme&.favicon_url || asset_path('favicon.ico')
  end

  # Obtiene un color específico del tema actual
  def theme_color(color_type = :primary)
    return unless current_theme

    case color_type
    when :primary
      current_theme.primary_color
    when :secondary
      current_theme.secondary_color
    when :accent
      current_theme.accent_color
    end
  end

  # Genera meta tags para colores del tema (útil para navegadores móviles)
  def theme_meta_tags
    return if current_theme.nil?

    tags = []
    tags << tag.meta(name: 'theme-color', content: current_theme.primary_color) if current_theme.primary_color.present?
    if current_theme.primary_color.present?
      tags << tag.meta(name: 'msapplication-TileColor',
                       content: current_theme.primary_color)
    end
    safe_join(tags, "\n")
  end

  # Retorna el nombre de la fuente principal
  def theme_font_primary
    current_theme&.font_primary || 'Inter'
  end

  # Retorna el nombre de la fuente de display
  def theme_font_display
    current_theme&.font_display || 'Montserrat'
  end

  # Genera el link tag para Google Fonts si es necesario
  def theme_fonts_link_tag
    fonts = []
    fonts << theme_font_primary if theme_font_primary.present?
    fonts << theme_font_display if theme_font_display.present?

    return if fonts.empty?

    # Construir URL de Google Fonts con encoding correcto
    font_families = fonts.uniq.map do |font|
      "#{ERB::Util.url_encode(font)}:wght@400;500;600;700"
    end.join('&family=')

    tag.link(
      rel: 'stylesheet',
      href: "https://fonts.googleapis.com/css2?family=#{font_families}&display=swap"
    )
  end

  private

  # Sanitiza el CSS para prevenir XSS
  def sanitize_theme_css(css)
    return '' if css.blank?

    # Remover patrones peligrosos
    css.gsub(/javascript:/i, '')
       .gsub(/expression\(/i, '')
       .gsub(/<script/i, '')
       .gsub(/<iframe/i, '')
       .gsub(/on\w+\s*=/i, '')
  end

  # Tema por defecto cuando no hay ninguno activo
  def default_theme
    ThemeSetting.new(
      name: 'Default',
      primary_color: '#612d62',
      secondary_color: '#269283',
      accent_color: '#954e99',
      font_primary: 'Inter',
      font_display: 'Montserrat'
    )
  end
end
