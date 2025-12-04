# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThemeHelper, type: :helper do
  let(:active_theme) do
    ThemeSetting.new(
      id: 1,
      name: 'Custom Theme',
      primary_color: '#612d62',
      secondary_color: '#269283',
      accent_color: '#954e99',
      font_primary: 'Inter',
      font_display: 'Montserrat',
      logo_url: 'https://example.com/logo.png',
      favicon_url: 'https://example.com/favicon.ico',
      is_active: true
    )
  end

  let(:default_theme) do
    ThemeSetting.new(
      name: 'Default',
      primary_color: '#612d62',
      secondary_color: '#269283',
      accent_color: '#954e99',
      font_primary: 'Inter',
      font_display: 'Montserrat'
    )
  end

  before do
    # Reset instance variable
    helper.instance_variable_set(:@current_theme, nil)
  end

  describe '#current_theme' do
    context 'when there is an active theme' do
      it 'returns the active theme' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        expect(helper.current_theme).to eq(active_theme)
      end

      it 'caches the result' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.current_theme
        helper.current_theme
        expect(ThemeSetting).to have_received(:active).once
      end
    end

    context 'when there is no active theme' do
      it 'returns the default theme' do
        allow(ThemeSetting).to receive(:active).and_return(nil)
        theme = helper.current_theme
        expect(theme.name).to eq('Default')
        expect(theme.primary_color).to eq('#612d62')
      end
    end
  end

  describe '#theme_css_variables' do
    context 'when current theme is nil' do
      it 'returns nil' do
        allow(ThemeSetting).to receive(:active).and_return(nil)
        helper.instance_variable_set(:@current_theme, nil)
        # Make default_theme return nil for this test
        allow(helper).to receive(:default_theme).and_return(nil)
        expect(helper.theme_css_variables).to be_nil
      end
    end

    context 'when current theme exists' do
      before do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        allow(active_theme).to receive(:to_css).and_return(':root { --color: #612d62; }')
      end

      it 'generates a style tag with CSS' do
        result = helper.theme_css_variables
        expect(result).to include('<style')
        expect(result).to include('id="custom-theme-styles"')
      end

      it 'includes CSS from theme' do
        allow(active_theme).to receive(:to_css).and_return(':root { --color: #000; }')
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_css_variables
        expect(result).to include('--color: #000')
      end

      it 'sanitizes the CSS' do
        allow(active_theme).to receive(:to_css)
          .and_return('body { color: red; javascript:alert(1); }')
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_css_variables
        expect(result).not_to include('javascript:')
      end

      it 'marks the CSS as html_safe' do
        result = helper.theme_css_variables
        expect(result).to be_html_safe
      end

      it 'actually calls sanitize_theme_css' do
        allow(active_theme).to receive(:to_css).and_return('body { expression(test); }')
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_css_variables
        expect(result).not_to include('expression(')
      end
    end
  end

  describe '#theme_data_attribute' do
    context 'when current theme is persisted' do
      it 'returns custom theme identifier' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        allow(active_theme).to receive(:persisted?).and_return(true)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_data_attribute).to eq('custom-1')
      end
    end

    context 'when current theme is not persisted' do
      it 'returns default' do
        allow(ThemeSetting).to receive(:active).and_return(default_theme)
        allow(default_theme).to receive(:persisted?).and_return(false)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_data_attribute).to eq('default')
      end
    end

    context 'when current theme is nil' do
      it 'returns default' do
        allow(ThemeSetting).to receive(:active).and_return(nil)
        allow(helper).to receive(:default_theme).and_return(nil)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_data_attribute).to eq('default')
      end
    end
  end

  describe '#theme_logo_url' do
    context 'when current theme has logo_url' do
      it 'returns the theme logo URL' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_logo_url).to eq('https://example.com/logo.png')
      end
    end

    context 'when current theme has no logo_url' do
      it 'returns default logo asset path' do
        theme_without_logo = ThemeSetting.new(name: 'Test')
        allow(ThemeSetting).to receive(:active).and_return(theme_without_logo)
        allow(helper).to receive(:asset_path).with('logo.png').and_return('/assets/logo.png')
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_logo_url
        expect(result).to eq('/assets/logo.png')
      end
    end

    context 'when current theme is nil' do
      it 'returns default logo asset path' do
        allow(ThemeSetting).to receive(:active).and_return(nil)
        allow(helper).to receive(:default_theme).and_return(nil)
        allow(helper).to receive(:asset_path).with('logo.png').and_return('/assets/logo.png')
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_logo_url
        expect(result).to eq('/assets/logo.png')
      end
    end
  end

  describe '#theme_favicon_url' do
    context 'when current theme has favicon_url' do
      it 'returns the theme favicon URL' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_favicon_url).to eq('https://example.com/favicon.ico')
      end
    end

    context 'when current theme has no favicon_url' do
      it 'returns default favicon asset path' do
        theme_without_favicon = ThemeSetting.new(name: 'Test')
        allow(ThemeSetting).to receive(:active).and_return(theme_without_favicon)
        allow(helper).to receive(:asset_path).with('favicon.ico').and_return('/assets/favicon.ico')
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_favicon_url
        expect(result).to eq('/assets/favicon.ico')
      end
    end

    context 'when current theme is nil' do
      it 'returns default favicon asset path' do
        allow(ThemeSetting).to receive(:active).and_return(nil)
        allow(helper).to receive(:default_theme).and_return(nil)
        allow(helper).to receive(:asset_path).with('favicon.ico').and_return('/assets/favicon.ico')
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_favicon_url
        expect(result).to eq('/assets/favicon.ico')
      end
    end
  end

  describe '#theme_color' do
    context 'when current theme is nil' do
      it 'returns nil' do
        allow(ThemeSetting).to receive(:active).and_return(nil)
        allow(helper).to receive(:default_theme).and_return(nil)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_color(:primary)).to be_nil
      end
    end

    context 'when requesting primary color' do
      it 'returns primary color' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_color(:primary)).to eq('#612d62')
      end

      it 'defaults to primary when no argument' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_color).to eq('#612d62')
      end
    end

    context 'when requesting secondary color' do
      it 'returns secondary color' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_color(:secondary)).to eq('#269283')
      end
    end

    context 'when requesting accent color' do
      it 'returns accent color' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_color(:accent)).to eq('#954e99')
      end
    end

    context 'when requesting unknown color type' do
      it 'returns nil' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_color(:unknown)).to be_nil
      end
    end
  end

  describe '#theme_meta_tags' do
    context 'when current theme is nil' do
      it 'returns nil' do
        allow(ThemeSetting).to receive(:active).and_return(nil)
        allow(helper).to receive(:default_theme).and_return(nil)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_meta_tags).to be_nil
      end
    end

    context 'when current theme exists with primary color' do
      before do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
      end

      it 'generates theme-color meta tag' do
        result = helper.theme_meta_tags
        expect(result).to include('name="theme-color"')
        expect(result).to include('content="#612d62"')
      end

      it 'generates msapplication-TileColor meta tag' do
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_meta_tags
        expect(result).to include('name="msapplication-TileColor"')
        expect(result).to include('content="#612d62"')
      end

      it 'returns html_safe content' do
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_meta_tags
        expect(result).to be_html_safe
      end

      it 'separates tags with newlines' do
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_meta_tags
        expect(result).to include("\n")
      end
    end

    context 'when current theme has no primary color' do
      it 'returns empty safe_join' do
        theme_no_color = ThemeSetting.new(name: 'No Color', primary_color: nil)
        allow(ThemeSetting).to receive(:active).and_return(theme_no_color)
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_meta_tags
        expect(result).to be_html_safe
        expect(result.to_s).to be_empty
      end
    end

    context 'when current theme has blank primary color' do
      it 'returns empty safe_join' do
        theme_blank_color = ThemeSetting.new(name: 'Blank', primary_color: '')
        allow(ThemeSetting).to receive(:active).and_return(theme_blank_color)
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_meta_tags
        expect(result).to be_html_safe
        expect(result.to_s).to be_empty
      end
    end
  end

  describe '#theme_font_primary' do
    context 'when current theme has font_primary' do
      it 'returns the font name' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_font_primary).to eq('Inter')
      end
    end

    context 'when current theme has no font_primary' do
      it 'returns default Inter' do
        theme_no_font = ThemeSetting.new(name: 'Test')
        allow(ThemeSetting).to receive(:active).and_return(theme_no_font)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_font_primary).to eq('Inter')
      end
    end

    context 'when current theme is nil' do
      it 'returns default Inter' do
        allow(ThemeSetting).to receive(:active).and_return(nil)
        allow(helper).to receive(:default_theme).and_return(nil)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_font_primary).to eq('Inter')
      end
    end
  end

  describe '#theme_font_display' do
    context 'when current theme has font_display' do
      it 'returns the font name' do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_font_display).to eq('Montserrat')
      end
    end

    context 'when current theme has no font_display' do
      it 'returns default Montserrat' do
        theme_no_font = ThemeSetting.new(name: 'Test')
        allow(ThemeSetting).to receive(:active).and_return(theme_no_font)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_font_display).to eq('Montserrat')
      end
    end

    context 'when current theme is nil' do
      it 'returns default Montserrat' do
        allow(ThemeSetting).to receive(:active).and_return(nil)
        allow(helper).to receive(:default_theme).and_return(nil)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_font_display).to eq('Montserrat')
      end
    end
  end

  describe '#theme_fonts_link_tag' do
    context 'when fonts are present' do
      before do
        allow(ThemeSetting).to receive(:active).and_return(active_theme)
        helper.instance_variable_set(:@current_theme, nil)
      end

      it 'generates a link tag for Google Fonts' do
        result = helper.theme_fonts_link_tag
        expect(result).to include('rel="stylesheet"')
        expect(result).to include('fonts.googleapis.com')
      end

      it 'includes both fonts' do
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_fonts_link_tag
        expect(result).to include('Inter')
        expect(result).to include('Montserrat')
      end

      it 'includes font weights' do
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_fonts_link_tag
        expect(result).to include('wght@400;500;600;700')
      end

      it 'URL encodes font names' do
        custom_theme = ThemeSetting.new(
          name: 'Custom',
          font_primary: 'Open Sans',
          font_display: 'Roboto Slab'
        )
        allow(ThemeSetting).to receive(:active).and_return(custom_theme)
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_fonts_link_tag
        # ERB::Util.url_encode encodes spaces as %20, not +
        expect(result).to include('Open%20Sans')
        expect(result).to include('Roboto%20Slab')
      end

      it 'removes duplicate fonts' do
        same_fonts_theme = ThemeSetting.new(
          name: 'Same',
          font_primary: 'Inter',
          font_display: 'Inter'
        )
        allow(ThemeSetting).to receive(:active).and_return(same_fonts_theme)
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_fonts_link_tag
        # Should only include Inter once
        expect(result.scan(/Inter/).length).to eq(1)
      end

      it 'includes display=swap parameter' do
        helper.instance_variable_set(:@current_theme, nil)
        result = helper.theme_fonts_link_tag
        expect(result).to include('display=swap')
      end
    end

    context 'when no fonts are present' do
      it 'returns nil' do
        theme_no_fonts = ThemeSetting.new(name: 'NoFonts')
        allow(ThemeSetting).to receive(:active).and_return(theme_no_fonts)
        allow(helper).to receive(:theme_font_primary).and_return(nil)
        allow(helper).to receive(:theme_font_display).and_return(nil)
        helper.instance_variable_set(:@current_theme, nil)
        expect(helper.theme_fonts_link_tag).to be_nil
      end
    end

    context 'when only primary font is present' do
      it 'includes primary font and default display font' do
        theme_one_font = ThemeSetting.new(
          name: 'One',
          font_primary: 'Roboto'
        )
        allow(ThemeSetting).to receive(:active).and_return(theme_one_font)
        helper.instance_variable_set(:@current_theme, nil)
        # theme_font_display will return 'Montserrat' as default
        result = helper.theme_fonts_link_tag
        expect(result).to include('Roboto')
        expect(result).to include('Montserrat') # Default display font
      end
    end

    context 'when only display font is present' do
      it 'includes display font and default primary font' do
        theme_display_only = ThemeSetting.new(
          name: 'Display',
          font_display: 'Lato'
        )
        allow(ThemeSetting).to receive(:active).and_return(theme_display_only)
        helper.instance_variable_set(:@current_theme, nil)
        # theme_font_primary will return 'Inter' as default
        result = helper.theme_fonts_link_tag
        expect(result).to include('Lato')
        expect(result).to include('Inter') # Default primary font
      end
    end
  end

  describe '#sanitize_theme_css (private)' do
    it 'removes javascript: protocol' do
      css = 'body { background: url(javascript:alert(1)); }'
      result = helper.send(:sanitize_theme_css, css)
      expect(result).not_to include('javascript:')
    end

    it 'removes expression() calls' do
      css = 'div { width: expression(alert(1)); }'
      result = helper.send(:sanitize_theme_css, css)
      expect(result).not_to include('expression(')
    end

    it 'removes <script tags' do
      css = 'body { } <script>alert(1)</script>'
      result = helper.send(:sanitize_theme_css, css)
      expect(result).not_to include('<script')
    end

    it 'removes <iframe tags' do
      css = 'body { } <iframe src="evil.com"></iframe>'
      result = helper.send(:sanitize_theme_css, css)
      expect(result).not_to include('<iframe')
    end

    it 'removes event handlers like onclick' do
      css = 'body { } onclick="alert(1)"'
      result = helper.send(:sanitize_theme_css, css)
      expect(result).not_to include('onclick=')
    end

    it 'removes onload handler' do
      css = 'body { } onload="alert(1)"'
      result = helper.send(:sanitize_theme_css, css)
      expect(result).not_to include('onload=')
    end

    it 'handles blank CSS' do
      expect(helper.send(:sanitize_theme_css, nil)).to eq('')
      expect(helper.send(:sanitize_theme_css, '')).to eq('')
    end

    it 'preserves safe CSS' do
      css = 'body { color: red; font-size: 16px; }'
      result = helper.send(:sanitize_theme_css, css)
      expect(result).to eq(css)
    end

    it 'is case insensitive for javascript' do
      css = 'body { background: url(JAVASCRIPT:alert(1)); }'
      result = helper.send(:sanitize_theme_css, css)
      expect(result).not_to include('JAVASCRIPT:')
    end

    it 'is case insensitive for Expression' do
      css = 'div { width: Expression(alert(1)); }'
      result = helper.send(:sanitize_theme_css, css)
      expect(result).not_to include('Expression(')
    end

    it 'is case insensitive for script tags' do
      css = '<SCRIPT>alert(1)</SCRIPT>'
      result = helper.send(:sanitize_theme_css, css)
      expect(result).not_to include('<SCRIPT')
    end
  end

  describe '#default_theme (private)' do
    it 'returns a ThemeSetting instance' do
      theme = helper.send(:default_theme)
      expect(theme).to be_a(ThemeSetting)
    end

    it 'has correct default values' do
      theme = helper.send(:default_theme)
      expect(theme.name).to eq('Default')
      expect(theme.primary_color).to eq('#612d62')
      expect(theme.secondary_color).to eq('#269283')
      expect(theme.accent_color).to eq('#954e99')
      expect(theme.font_primary).to eq('Inter')
      expect(theme.font_display).to eq('Montserrat')
    end

    it 'is not persisted' do
      theme = helper.send(:default_theme)
      expect(theme).not_to be_persisted
    end
  end
end
