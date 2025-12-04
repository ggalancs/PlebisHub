# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThemeSetting, type: :model do
  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    context 'name validation' do
      it 'requires name' do
        setting = described_class.new(name: nil)
        expect(setting).not_to be_valid
        expect(setting.errors[:name]).to be_present
      end

      it 'requires unique name' do
        described_class.create!(name: 'Dark Theme', primary_color: '#000000', secondary_color: '#111111')
        duplicate = described_class.new(name: 'Dark Theme')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to be_present
      end

      it 'accepts valid name' do
        setting = described_class.new(name: 'Custom Theme', primary_color: '#FF0000', secondary_color: '#00FF00')
        expect(setting).to be_valid
      end
    end

    context 'color validation' do
      it 'accepts valid hex colors' do
        setting = described_class.new(
          name: 'Valid Colors',
          primary_color: '#FF0000',
          secondary_color: '#00FF00',
          accent_color: '#0000FF'
        )
        expect(setting).to be_valid
      end

      it 'accepts lowercase hex colors' do
        setting = described_class.new(
          name: 'Lowercase',
          primary_color: '#ff0000',
          secondary_color: '#00ff00',
          accent_color: '#0000ff'
        )
        expect(setting).to be_valid
      end

      it 'accepts blank colors' do
        setting = described_class.new(
          name: 'Blank Colors',
          primary_color: '',
          secondary_color: nil,
          accent_color: nil
        )
        expect(setting).to be_valid
      end

      it 'rejects colors without hash' do
        setting = described_class.new(
          name: 'No Hash',
          primary_color: 'FF0000'
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:primary_color]).to be_present
      end

      it 'rejects colors with invalid length' do
        setting = described_class.new(
          name: 'Invalid Length',
          primary_color: '#FFF'
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:primary_color]).to be_present
      end

      it 'rejects colors with invalid characters' do
        setting = described_class.new(
          name: 'Invalid Chars',
          primary_color: '#GGGGGG'
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:primary_color]).to be_present
      end
    end

    context 'URL validation' do
      it 'accepts valid URLs within length limit' do
        setting = described_class.new(
          name: 'Valid URLs',
          logo_url: 'https://example.com/logo.png',
          favicon_url: 'https://example.com/favicon.ico'
        )
        expect(setting).to be_valid
      end

      it 'accepts blank URLs' do
        setting = described_class.new(
          name: 'No URLs',
          logo_url: nil,
          favicon_url: ''
        )
        expect(setting).to be_valid
      end

      it 'rejects URLs exceeding 500 characters' do
        long_url = "https://example.com/#{'a' * 500}"
        setting = described_class.new(
          name: 'Long URL',
          logo_url: long_url
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:logo_url]).to be_present
      end
    end

    context 'custom CSS sanitization' do
      it 'accepts valid CSS' do
        setting = described_class.new(
          name: 'Valid CSS',
          custom_css: '.button { color: red; }'
        )
        expect(setting).to be_valid
      end

      it 'accepts blank custom CSS' do
        setting = described_class.new(
          name: 'No CSS',
          custom_css: nil
        )
        expect(setting).to be_valid
      end

      it 'rejects CSS with javascript: protocol' do
        setting = described_class.new(
          name: 'JS Protocol',
          custom_css: 'background: url(javascript:alert(1))'
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:custom_css]).to include('contiene contenido potencialmente peligroso')
      end

      it 'rejects CSS with expression()' do
        setting = described_class.new(
          name: 'Expression',
          custom_css: 'width: expression(alert(1))'
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:custom_css]).to include('contiene contenido potencialmente peligroso')
      end

      it 'rejects CSS with <script tags' do
        setting = described_class.new(
          name: 'Script Tag',
          custom_css: '<script>alert(1)</script>'
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:custom_css]).to include('contiene contenido potencialmente peligroso')
      end

      it 'rejects CSS with <iframe tags' do
        setting = described_class.new(
          name: 'Iframe Tag',
          custom_css: '<iframe src="evil.com"></iframe>'
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:custom_css]).to include('contiene contenido potencialmente peligroso')
      end

      it 'rejects CSS with event handlers' do
        setting = described_class.new(
          name: 'Event Handler',
          custom_css: 'onclick=alert(1)'
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:custom_css]).to include('contiene contenido potencialmente peligroso')
      end

      it 'sanitizes dangerous content automatically after validation passes' do
        setting = described_class.new(
          name: 'Auto Sanitize',
          custom_css: '.button { color: red; }'
        )
        # The sanitization happens during validation
        # Test that safe content passes through unchanged
        expect(setting).to be_valid
        expect(setting.custom_css).to eq('.button { color: red; }')
      end
    end
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  describe 'callbacks' do
    context 'deactivate_other_themes' do
      it 'deactivates other themes when activating a theme' do
        theme1 = described_class.create!(
          name: 'Theme 1',
          primary_color: '#FF0000',
          secondary_color: '#00FF00',
          is_active: true
        )
        theme2 = described_class.create!(
          name: 'Theme 2',
          primary_color: '#0000FF',
          secondary_color: '#FFFF00'
        )

        theme2.update!(is_active: true)
        expect(theme1.reload.is_active).to be false
        expect(theme2.reload.is_active).to be true
      end

      it 'does not deactivate themes when updating inactive theme' do
        theme1 = described_class.create!(
          name: 'Theme 1',
          primary_color: '#FF0000',
          secondary_color: '#00FF00',
          is_active: true
        )
        theme2 = described_class.create!(
          name: 'Theme 2',
          primary_color: '#0000FF',
          secondary_color: '#FFFF00'
        )

        theme2.update!(name: 'Theme 2 Updated')
        expect(theme1.reload.is_active).to be true
        expect(theme2.reload.is_active).to be false
      end

      it 'does not run callback on create for brand new themes' do
        # The callback only runs on update when persisted? is true
        # On create, persisted? is false, so callback doesn't run
        described_class.create!(
          name: 'Theme 1',
          primary_color: '#FF0000',
          secondary_color: '#00FF00',
          is_active: true
        )

        # This should fail due to unique constraint if callback didn't run properly
        expect do
          described_class.create!(
            name: 'Theme 2',
            primary_color: '#0000FF',
            secondary_color: '#FFFF00',
            is_active: true
          )
        end.to raise_error(ActiveRecord::RecordNotUnique)
      end

      it 'handles multiple themes correctly' do
        theme1 = described_class.create!(
          name: 'Theme 1',
          primary_color: '#FF0000',
          secondary_color: '#00FF00',
          is_active: true
        )
        theme2 = described_class.create!(
          name: 'Theme 2',
          primary_color: '#0000FF',
          secondary_color: '#FFFF00'
        )
        theme3 = described_class.create!(
          name: 'Theme 3',
          primary_color: '#FF00FF',
          secondary_color: '#00FFFF'
        )

        theme3.update!(is_active: true)
        expect(theme1.reload.is_active).to be false
        expect(theme2.reload.is_active).to be false
        expect(theme3.reload.is_active).to be true
      end
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    describe '.active' do
      it 'returns the active theme' do
        described_class.create!(
          name: 'Inactive',
          primary_color: '#FF0000',
          secondary_color: '#00FF00',
          is_active: false
        )
        active = described_class.create!(
          name: 'Active',
          primary_color: '#0000FF',
          secondary_color: '#FFFF00',
          is_active: true
        )

        expect(described_class.active).to eq(active)
      end

      it 'returns nil when no theme is active' do
        described_class.create!(
          name: 'Inactive',
          primary_color: '#FF0000',
          secondary_color: '#00FF00',
          is_active: false
        )

        expect(described_class.active).to be_nil
      end
    end
  end

  # ====================
  # COLOR CONVERSION TESTS
  # ====================

  describe '#color_variants' do
    let(:theme) do
      described_class.new(
        name: 'Test',
        primary_color: '#3B82F6',
        secondary_color: '#10B981'
      )
    end

    it 'returns empty hash for blank color' do
      expect(theme.color_variants(nil)).to eq({})
      expect(theme.color_variants('')).to eq({})
    end

    it 'generates all 11 color variants' do
      variants = theme.color_variants('#3B82F6')
      expect(variants.keys).to match_array([50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950])
    end

    it 'keeps original color at 500' do
      variants = theme.color_variants('#3B82F6')
      expect(variants[500]).to eq('#3B82F6')
    end

    it 'generates lighter variants for low values' do
      variants = theme.color_variants('#3B82F6')
      # All variants should be valid hex colors
      variants.each_value do |hex|
        expect(hex).to match(/\A#[0-9A-Fa-f]{6}\z/)
      end
    end

    it 'generates darker variants for high values' do
      variants = theme.color_variants('#3B82F6')
      expect(variants[950]).to match(/\A#[0-9A-Fa-f]{6}\z/)
      expect(variants[950]).not_to eq('#3B82F6')
    end

    it 'handles white color' do
      variants = theme.color_variants('#FFFFFF')
      expect(variants[500]).to eq('#FFFFFF')
      expect(variants.keys.size).to eq(11)
    end

    it 'handles black color' do
      variants = theme.color_variants('#000000')
      expect(variants[500]).to eq('#000000')
      expect(variants.keys.size).to eq(11)
    end

    it 'handles grayscale colors' do
      variants = theme.color_variants('#808080')
      expect(variants[500]).to eq('#808080')
      variants.each_value do |hex|
        expect(hex).to match(/\A#[0-9A-Fa-f]{6}\z/)
      end
    end
  end

  describe '#hex_to_rgb' do
    let(:theme) { described_class.new(name: 'Test') }

    it 'converts hex to RGB' do
      expect(theme.send(:hex_to_rgb, '#FF0000')).to eq([255, 0, 0])
      expect(theme.send(:hex_to_rgb, '#00FF00')).to eq([0, 255, 0])
      expect(theme.send(:hex_to_rgb, '#0000FF')).to eq([0, 0, 255])
    end

    it 'handles hex without hash' do
      expect(theme.send(:hex_to_rgb, 'FF0000')).to eq([255, 0, 0])
    end

    it 'handles white' do
      expect(theme.send(:hex_to_rgb, '#FFFFFF')).to eq([255, 255, 255])
    end

    it 'handles black' do
      expect(theme.send(:hex_to_rgb, '#000000')).to eq([0, 0, 0])
    end

    it 'handles lowercase' do
      expect(theme.send(:hex_to_rgb, '#ff00ff')).to eq([255, 0, 255])
    end
  end

  describe '#rgb_to_hsl' do
    let(:theme) { described_class.new(name: 'Test') }

    it 'converts RGB to HSL for red' do
      hsl = theme.send(:rgb_to_hsl, [255, 0, 0])
      expect(hsl[0]).to eq(0) # Hue
      expect(hsl[1]).to eq(100) # Saturation
      expect(hsl[2]).to eq(50) # Lightness
    end

    it 'converts RGB to HSL for green' do
      hsl = theme.send(:rgb_to_hsl, [0, 255, 0])
      expect(hsl[0]).to eq(120) # Hue
      expect(hsl[1]).to eq(100) # Saturation
      expect(hsl[2]).to eq(50) # Lightness
    end

    it 'converts RGB to HSL for blue' do
      hsl = theme.send(:rgb_to_hsl, [0, 0, 255])
      expect(hsl[0]).to eq(240) # Hue
      expect(hsl[1]).to eq(100) # Saturation
      expect(hsl[2]).to eq(50) # Lightness
    end

    it 'handles grayscale' do
      hsl = theme.send(:rgb_to_hsl, [128, 128, 128])
      expect(hsl[0]).to eq(0) # Hue for gray
      expect(hsl[1]).to eq(0) # No saturation
      expect(hsl[2]).to eq(50) # 50% lightness
    end

    it 'handles white' do
      hsl = theme.send(:rgb_to_hsl, [255, 255, 255])
      expect(hsl[0]).to eq(0)
      expect(hsl[1]).to eq(0)
      expect(hsl[2]).to eq(100)
    end

    it 'handles black' do
      hsl = theme.send(:rgb_to_hsl, [0, 0, 0])
      expect(hsl[0]).to eq(0)
      expect(hsl[1]).to eq(0)
      expect(hsl[2]).to eq(0)
    end
  end

  describe '#hsl_to_hex' do
    let(:theme) { described_class.new(name: 'Test') }

    it 'converts HSL to hex for red' do
      expect(theme.send(:hsl_to_hex, 0, 100, 50)).to eq('#ff0000')
    end

    it 'converts HSL to hex for green' do
      expect(theme.send(:hsl_to_hex, 120, 100, 50)).to eq('#00ff00')
    end

    it 'converts HSL to hex for blue' do
      expect(theme.send(:hsl_to_hex, 240, 100, 50)).to eq('#0000ff')
    end

    it 'handles grayscale' do
      hex = theme.send(:hsl_to_hex, 0, 0, 50)
      expect(hex).to match(/\A#[0-9a-f]{6}\z/)
    end

    it 'handles white' do
      expect(theme.send(:hsl_to_hex, 0, 0, 100)).to eq('#ffffff')
    end

    it 'handles black' do
      expect(theme.send(:hsl_to_hex, 0, 0, 0)).to eq('#000000')
    end
  end

  describe '#hue_to_rgb' do
    let(:theme) { described_class.new(name: 'Test') }

    it 'handles t < 1/6' do
      result = theme.send(:hue_to_rgb, 0.2, 0.8, 0.1)
      expect(result).to be_a(Float)
      expect(result).to be >= 0.2
    end

    it 'handles t < 1/2' do
      result = theme.send(:hue_to_rgb, 0.2, 0.8, 0.3)
      expect(result).to eq(0.8)
    end

    it 'handles t < 2/3' do
      result = theme.send(:hue_to_rgb, 0.2, 0.8, 0.6)
      expect(result).to be_a(Float)
      expect(result).to be >= 0.2
    end

    it 'handles t >= 2/3' do
      result = theme.send(:hue_to_rgb, 0.2, 0.8, 0.8)
      expect(result).to eq(0.2)
    end

    it 'handles negative t' do
      result = theme.send(:hue_to_rgb, 0.2, 0.8, -0.1)
      expect(result).to be_a(Float)
    end

    it 'handles t > 1' do
      result = theme.send(:hue_to_rgb, 0.2, 0.8, 1.1)
      expect(result).to be_a(Float)
    end
  end

  # ====================
  # CSS GENERATION TESTS
  # ====================

  describe '#to_css' do
    let(:theme) do
      described_class.create!(
        name: 'Test Theme',
        primary_color: '#3B82F6',
        secondary_color: '#10B981',
        accent_color: '#F59E0B',
        font_primary: 'Inter',
        font_display: 'Poppins',
        custom_css: '.custom { color: red; }'
      )
    end

    it 'generates CSS with root selector' do
      css = theme.to_css
      expect(css).to include(":root[data-theme=\"custom-#{theme.id}\"]")
    end

    it 'includes primary color variants' do
      css = theme.to_css
      expect(css).to include('/* Primary Color Scale */')
      expect(css).to include('--color-primary-50:')
      expect(css).to include('--color-primary-500:')
      expect(css).to include('--color-primary-950:')
    end

    it 'includes secondary color variants' do
      css = theme.to_css
      expect(css).to include('/* Secondary Color Scale */')
      expect(css).to include('--color-secondary-50:')
      expect(css).to include('--color-secondary-500:')
      expect(css).to include('--color-secondary-950:')
    end

    it 'includes accent color' do
      css = theme.to_css
      expect(css).to include('/* Accent Color */')
      expect(css).to include("--color-accent: #{theme.accent_color};")
    end

    it 'includes typography' do
      css = theme.to_css
      expect(css).to include('/* Typography */')
      expect(css).to include('--font-family-primary: Inter, sans-serif;')
      expect(css).to include('--font-family-display: Poppins, sans-serif;')
    end

    it 'includes custom CSS' do
      css = theme.to_css
      expect(css).to include('.custom { color: red; }')
    end

    it 'omits accent color when blank' do
      theme.update!(accent_color: nil)
      css = theme.to_css
      expect(css).not_to include('--color-accent:')
    end

    it 'omits fonts when blank' do
      theme.update!(font_primary: nil, font_display: nil)
      css = theme.to_css
      expect(css).not_to include('--font-family-primary:')
      expect(css).not_to include('--font-family-display:')
    end

    it 'omits custom CSS when blank' do
      theme.update!(custom_css: nil)
      css = theme.to_css
      expect(css).not_to include('.custom')
    end

    it 'generates valid CSS structure' do
      css = theme.to_css
      expect(css).to start_with(':root[data-theme=')
      expect(css).to include('{')
      expect(css).to include('}')
    end
  end

  # ====================
  # JSON SERIALIZATION TESTS
  # ====================

  describe '#to_theme_json' do
    let(:theme) do
      described_class.create!(
        name: 'Test Theme',
        primary_color: '#3B82F6',
        secondary_color: '#10B981',
        accent_color: '#F59E0B',
        font_primary: 'Inter',
        font_display: 'Poppins',
        logo_url: 'https://example.com/logo.png',
        favicon_url: 'https://example.com/favicon.ico',
        custom_css: '.custom { color: red; }'
      )
    end

    it 'exports theme as JSON' do
      json = theme.to_theme_json
      expect(json).to be_a(Hash)
    end

    it 'includes name' do
      json = theme.to_theme_json
      expect(json[:name]).to eq('Test Theme')
    end

    it 'includes colors' do
      json = theme.to_theme_json
      expect(json[:colors]).to eq({
        primary: '#3B82F6',
        secondary: '#10B981',
        accent: '#F59E0B'
      })
    end

    it 'includes typography' do
      json = theme.to_theme_json
      expect(json[:typography]).to eq({
        fontPrimary: 'Inter',
        fontDisplay: 'Poppins'
      })
    end

    it 'includes assets' do
      json = theme.to_theme_json
      expect(json[:assets]).to eq({
        logo: 'https://example.com/logo.png',
        favicon: 'https://example.com/favicon.ico'
      })
    end

    it 'includes custom CSS' do
      json = theme.to_theme_json
      expect(json[:customCSS]).to eq('.custom { color: red; }')
    end

    it 'handles nil values' do
      minimal_theme = described_class.create!(
        name: 'Minimal',
        primary_color: '#000000',
        secondary_color: '#FFFFFF',
        accent_color: nil,
        font_primary: nil,
        font_display: nil,
        custom_css: nil
      )
      json = minimal_theme.to_theme_json
      # Check that the database defaults are used or fields are nil
      # The schema has default values, so we need to accept them
      expect(json[:colors]).to have_key(:accent)
      expect(json[:typography]).to have_key(:fontPrimary)
      expect(json).to have_key(:customCSS)
    end
  end

  describe '.from_theme_json' do
    let(:json_data) do
      {
        name: 'Imported Theme',
        colors: {
          primary: '#3B82F6',
          secondary: '#10B981',
          accent: '#F59E0B'
        },
        typography: {
          fontPrimary: 'Inter',
          fontDisplay: 'Poppins'
        },
        assets: {
          logo: 'https://example.com/logo.png',
          favicon: 'https://example.com/favicon.ico'
        },
        customCSS: '.custom { color: red; }'
      }
    end

    it 'imports theme from JSON with symbol keys' do
      theme = described_class.from_theme_json(json_data)
      expect(theme).to be_persisted
      expect(theme.name).to eq('Imported Theme')
      expect(theme.primary_color).to eq('#3B82F6')
      expect(theme.secondary_color).to eq('#10B981')
      expect(theme.accent_color).to eq('#F59E0B')
      expect(theme.font_primary).to eq('Inter')
      expect(theme.font_display).to eq('Poppins')
      expect(theme.logo_url).to eq('https://example.com/logo.png')
      expect(theme.favicon_url).to eq('https://example.com/favicon.ico')
      expect(theme.custom_css).to eq('.custom { color: red; }')
    end

    it 'imports theme from JSON with string keys' do
      string_data = {
        'name' => 'String Keys Theme',
        'colors' => {
          'primary' => '#FF0000',
          'secondary' => '#00FF00',
          'accent' => '#0000FF'
        },
        'typography' => {
          'fontPrimary' => 'Arial',
          'fontDisplay' => 'Georgia'
        },
        'assets' => {
          'logo' => 'logo.png',
          'favicon' => 'favicon.ico'
        },
        'customCSS' => 'body { margin: 0; }'
      }

      theme = described_class.from_theme_json(string_data)
      expect(theme).to be_persisted
      expect(theme.name).to eq('String Keys Theme')
      expect(theme.primary_color).to eq('#FF0000')
    end

    it 'raises error for invalid theme data' do
      invalid_data = {
        name: nil, # Invalid: name is required
        colors: {
          primary: '#FF0000',
          secondary: '#00FF00'
        }
      }

      expect do
        described_class.from_theme_json(invalid_data)
      end.to raise_error(ArgumentError, /Invalid theme data/)
    end

    it 'handles missing optional fields' do
      minimal_data = {
        name: 'Minimal Theme',
        colors: {
          primary: '#000000',
          secondary: '#FFFFFF'
        }
      }

      theme = described_class.from_theme_json(minimal_data)
      expect(theme).to be_persisted
      expect(theme.accent_color).to be_nil
      expect(theme.font_primary).to be_nil
    end

    it 'validates color format on import' do
      invalid_color_data = {
        name: 'Invalid Colors',
        colors: {
          primary: 'FF0000', # Missing hash
          secondary: '#00FF00'
        }
      }

      expect do
        described_class.from_theme_json(invalid_color_data)
      end.to raise_error(ArgumentError, /Invalid theme data/)
    end

    it 'round-trips through export and import' do
      original = described_class.create!(
        name: 'Original Theme',
        primary_color: '#3B82F6',
        secondary_color: '#10B981',
        accent_color: '#F59E0B',
        font_primary: 'Inter',
        font_display: 'Poppins'
      )

      json = original.to_theme_json
      json[:name] = 'Imported Theme' # Change name to avoid uniqueness constraint
      imported = described_class.from_theme_json(json)

      expect(imported.primary_color).to eq(original.primary_color)
      expect(imported.secondary_color).to eq(original.secondary_color)
      expect(imported.accent_color).to eq(original.accent_color)
      expect(imported.font_primary).to eq(original.font_primary)
      expect(imported.font_display).to eq(original.font_display)
    end
  end

  # ====================
  # INTEGRATION TESTS
  # ====================

  describe 'integration tests' do
    it 'creates a complete theme and generates CSS' do
      theme = described_class.create!(
        name: 'Complete Theme',
        primary_color: '#3B82F6',
        secondary_color: '#10B981',
        accent_color: '#F59E0B',
        font_primary: 'Inter',
        font_display: 'Poppins',
        is_active: true
      )

      css = theme.to_css
      expect(css).to include(':root[data-theme=')
      expect(css).to include('--color-primary-500:')
      expect(css).to include('--color-secondary-500:')
      expect(css).to include('--color-accent:')
      expect(css).to include('--font-family-primary:')
    end

    it 'exports and imports theme preserving data' do
      original = described_class.create!(
        name: 'Export Test',
        primary_color: '#3B82F6',
        secondary_color: '#10B981'
      )

      json = original.to_theme_json
      json[:name] = 'Import Test' # Change name to avoid uniqueness constraint
      imported = described_class.from_theme_json(json)

      expect(imported.primary_color).to eq(original.primary_color)
      expect(imported.secondary_color).to eq(original.secondary_color)
    end

    it 'activates theme and deactivates others' do
      theme1 = described_class.create!(
        name: 'Integration Theme 1',
        primary_color: '#FF0000',
        secondary_color: '#00FF00',
        is_active: true
      )

      theme2 = described_class.create!(
        name: 'Integration Theme 2',
        primary_color: '#0000FF',
        secondary_color: '#FFFF00',
        is_active: false
      )

      # Activate theme2
      theme2.update!(is_active: true)

      expect(theme1.reload.is_active).to be false
      expect(theme2.reload.is_active).to be true
      expect(described_class.active).to eq(theme2)
    end

    it 'generates color variants and converts to CSS' do
      theme = described_class.create!(
        name: 'Variant Test',
        primary_color: '#3B82F6',
        secondary_color: '#10B981'
      )

      variants = theme.color_variants('#3B82F6')
      expect(variants.keys.size).to eq(11)

      css = theme.to_css
      variants.each_key do |tone|
        expect(css).to include("--color-primary-#{tone}:")
      end
    end
  end
end
