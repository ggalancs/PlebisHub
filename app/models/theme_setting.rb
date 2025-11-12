# frozen_string_literal: true

# == Schema Information
# Table name: theme_settings
#  id               :bigint
#  name             :string
#  primary_color    :string
#  secondary_color  :string
#  accent_color     :string
#  font_primary     :string
#  font_display     :string
#  logo_url         :string
#  favicon_url      :string
#  custom_css       :text
#  is_active        :boolean default(FALSE)
#  created_at       :datetime
#  updated_at       :datetime
#
class ThemeSetting < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :primary_color, :secondary_color, :accent_color,
            format: { with: /\A#[0-9A-F]{6}\z/i },
            allow_blank: true
  validates :logo_url, :favicon_url, length: { maximum: 500 }, allow_blank: true
  validate :sanitize_custom_css

  # Callback para asegurar que solo un tema está activo a la vez
  before_save :deactivate_other_themes, if: :is_active?

  # Genera todas las variantes de color (50-950) a partir de un color base
  def color_variants(hex_color)
    return {} if hex_color.blank?

    rgb = hex_to_rgb(hex_color)
    hsl = rgb_to_hsl(rgb)

    # Genera 11 tonos de color basados en la luminosidad
    {
      50 => hsl_to_hex(hsl[0], hsl[1], 95),
      100 => hsl_to_hex(hsl[0], hsl[1], 90),
      200 => hsl_to_hex(hsl[0], hsl[1], 80),
      300 => hsl_to_hex(hsl[0], hsl[1], 70),
      400 => hsl_to_hex(hsl[0], hsl[1], 60),
      500 => hex_color, # Original
      600 => hsl_to_hex(hsl[0], hsl[1], 40),
      700 => hsl_to_hex(hsl[0], hsl[1], 30),
      800 => hsl_to_hex(hsl[0], hsl[1], 20),
      900 => hsl_to_hex(hsl[0], hsl[1], 10),
      950 => hsl_to_hex(hsl[0], hsl[1], 5)
    }
  end

  # Genera CSS custom properties para el tema
  def to_css
    primary_variants = color_variants(primary_color)
    secondary_variants = color_variants(secondary_color)

    css = ":root[data-theme=\"custom-#{id}\"] {\n"

    # Primary Color Scale
    css += "  /* Primary Color Scale */\n"
    primary_variants.each do |tone, hex|
      css += "  --color-primary-#{tone}: #{hex};\n"
    end

    css += "\n  /* Secondary Color Scale */\n"
    secondary_variants.each do |tone, hex|
      css += "  --color-secondary-#{tone}: #{hex};\n"
    end

    css += "\n  /* Accent Color */\n"
    css += "  --color-accent: #{accent_color};\n" if accent_color.present?

    css += "\n  /* Typography */\n"
    css += "  --font-family-primary: #{font_primary}, sans-serif;\n" if font_primary.present?
    css += "  --font-family-display: #{font_display}, sans-serif;\n" if font_display.present?

    css += "}\n"

    # Agregar custom CSS si existe
    css += "\n#{custom_css}" if custom_css.present?

    css
  end

  # Exporta el tema como JSON
  def to_theme_json
    {
      name: name,
      colors: {
        primary: primary_color,
        secondary: secondary_color,
        accent: accent_color
      },
      typography: {
        fontPrimary: font_primary,
        fontDisplay: font_display
      },
      assets: {
        logo: logo_url,
        favicon: favicon_url
      },
      customCSS: custom_css
    }
  end

  # Importa un tema desde JSON
  def self.from_theme_json(json_data)
    theme = new(
      name: json_data[:name] || json_data['name'],
      primary_color: json_data.dig(:colors, :primary) || json_data.dig('colors', 'primary'),
      secondary_color: json_data.dig(:colors, :secondary) || json_data.dig('colors', 'secondary'),
      accent_color: json_data.dig(:colors, :accent) || json_data.dig('colors', 'accent'),
      font_primary: json_data.dig(:typography, :fontPrimary) || json_data.dig('typography', 'fontPrimary'),
      font_display: json_data.dig(:typography, :fontDisplay) || json_data.dig('typography', 'fontDisplay'),
      logo_url: json_data.dig(:assets, :logo) || json_data.dig('assets', 'logo'),
      favicon_url: json_data.dig(:assets, :favicon) || json_data.dig('assets', 'favicon'),
      custom_css: json_data[:customCSS] || json_data['customCSS']
    )

    raise ArgumentError, "Invalid theme data: #{theme.errors.full_messages.join(', ')}" unless theme.valid?

    theme.save!
    theme
  end

  # Encuentra el tema activo actual
  def self.active
    find_by(is_active: true)
  end

  private

  # Desactiva todos los otros temas cuando éste se activa
  def deactivate_other_themes
    return unless is_active? && persisted?

    self.class.transaction do
      self.class.lock.where.not(id: id).update_all(is_active: false)
    end
  end

  # Sanitiza el CSS personalizado para prevenir XSS
  def sanitize_custom_css
    return if custom_css.blank?

    # Eliminar contenido peligroso
    dangerous_patterns = [
      /javascript:/i,
      /expression\(/i,
      /<script/i,
      /<iframe/i,
      /on\w+\s*=/i,  # onclick, onload, etc
      /url\(\s*['"]?javascript:/i
    ]

    dangerous_patterns.each do |pattern|
      if custom_css.match?(pattern)
        errors.add(:custom_css, 'contiene contenido potencialmente peligroso')
        return
      end
    end

    # Remover automáticamente contenido peligroso
    self.custom_css = custom_css.gsub(/javascript:/i, '')
                                  .gsub(/expression\(/i, '')
                                  .gsub(/<script/i, '')
                                  .gsub(/<iframe/i, '')
  end

  # Convierte hex a RGB
  def hex_to_rgb(hex)
    hex = hex.delete('#')
    r = hex[0..1].to_i(16)
    g = hex[2..3].to_i(16)
    b = hex[4..5].to_i(16)
    [r, g, b]
  end

  # Convierte RGB a HSL
  def rgb_to_hsl(rgb)
    r = rgb[0] / 255.0
    g = rgb[1] / 255.0
    b = rgb[2] / 255.0

    max = [r, g, b].max
    min = [r, g, b].min
    delta = max - min

    # Luminosity
    l = (max + min) / 2.0

    # Si no hay diferencia, es gris
    return [0, 0, (l * 100).round] if delta == 0

    # Saturation
    s = if l < 0.5
          delta / (max + min)
        else
          delta / (2.0 - max - min)
        end

    # Hue
    h = if max == r
          ((g - b) / delta + (g < b ? 6 : 0)) / 6.0
        elsif max == g
          ((b - r) / delta + 2) / 6.0
        else
          ((r - g) / delta + 4) / 6.0
        end

    [(h * 360).round, (s * 100).round, (l * 100).round]
  end

  # Convierte HSL a Hex
  def hsl_to_hex(h, s, l)
    h = h / 360.0
    s = s / 100.0
    l = l / 100.0

    if s == 0
      # Acromático (gris)
      r = g = b = (l * 255).round
    else
      q = l < 0.5 ? l * (1 + s) : l + s - l * s
      p = 2 * l - q

      r = (hue_to_rgb(p, q, h + 1.0/3.0) * 255).round
      g = (hue_to_rgb(p, q, h) * 255).round
      b = (hue_to_rgb(p, q, h - 1.0/3.0) * 255).round
    end

    '#%02x%02x%02x' % [r, g, b]
  end

  # Helper para convertir matiz a RGB
  def hue_to_rgb(p, q, t)
    t += 1 if t < 0
    t -= 1 if t > 1

    return p + (q - p) * 6 * t if t < 1.0/6.0
    return q if t < 1.0/2.0
    return p + (q - p) * (2.0/3.0 - t) * 6 if t < 2.0/3.0
    p
  end
end
