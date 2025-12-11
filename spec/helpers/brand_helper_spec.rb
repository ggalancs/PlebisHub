# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrandHelper, type: :helper do
  let(:brand_setting) { create(:brand_setting) }
  let(:user) { create(:user) }

  before do
    allow(helper).to receive(:current_user).and_return(user)
    allow(Rails.cache).to receive(:fetch).and_yield
    allow(BrandSetting).to receive(:current_for_organization).and_return(brand_setting)
    # Stub asset_path to avoid asset pipeline errors in test
    allow(helper).to receive(:asset_path) { |path| "/assets/#{path}" }
  end

  describe '#current_brand_setting' do
    it 'returns the brand setting from cache' do
      expect(helper.current_brand_setting).to eq(brand_setting)
    end

    it 'caches the result' do
      2.times { helper.current_brand_setting }
      expect(BrandSetting).to have_received(:current_for_organization).once
    end
  end

  describe '#brand_style_tag' do
    it 'returns a style tag from brand setting' do
      allow(brand_setting).to receive(:to_style_tag).and_return('<style>:root { --color: red; }</style>')
      result = helper.brand_style_tag
      expect(result).to include('<style>')
      expect(result).to be_html_safe
    end
  end

  describe '#brand_logo_url' do
    context 'when brand setting has logo URL' do
      before do
        allow(brand_setting).to receive(:effective_logo_url).and_return('/custom/logo.png')
      end

      it 'returns the custom logo URL' do
        expect(helper.brand_logo_url).to eq('/custom/logo.png')
      end
    end

    context 'when brand setting has no logo URL' do
      before do
        allow(brand_setting).to receive(:effective_logo_url).and_return(nil)
      end

      it 'returns the default logo path' do
        expect(helper.brand_logo_url).to include('brand/logo-horizontal')
      end
    end

    context 'with dark_mode parameter' do
      before do
        allow(brand_setting).to receive(:effective_logo_url).with(dark_mode: true).and_return('/dark/logo.png')
      end

      it 'passes dark_mode to effective_logo_url' do
        expect(helper.brand_logo_url(dark_mode: true)).to eq('/dark/logo.png')
      end
    end
  end

  describe '#brand_favicon_url' do
    context 'when brand setting has favicon URL' do
      before do
        allow(brand_setting).to receive(:effective_favicon_url).and_return('/custom/favicon.ico')
      end

      it 'returns the custom favicon URL' do
        expect(helper.brand_favicon_url).to eq('/custom/favicon.ico')
      end
    end

    context 'when brand setting has no favicon URL' do
      before do
        allow(brand_setting).to receive(:effective_favicon_url).and_return(nil)
      end

      it 'returns the default favicon path' do
        expect(helper.brand_favicon_url).to include('favicon')
      end
    end
  end

  describe '#brand_font_link_tag' do
    context 'when fonts are configured' do
      before do
        allow(brand_setting).to receive(:effective_font_primary).and_return('Roboto')
        allow(brand_setting).to receive(:effective_font_display).and_return('Open Sans')
      end

      it 'returns a Google Fonts link tag' do
        result = helper.brand_font_link_tag
        expect(result).to include('fonts.googleapis.com')
        expect(result).to include('Roboto')
        expect(result).to include('Open%20Sans')
      end
    end

    context 'when no fonts are configured' do
      before do
        allow(brand_setting).to receive(:effective_font_primary).and_return(nil)
        allow(brand_setting).to receive(:effective_font_display).and_return(nil)
      end

      it 'returns an empty string' do
        expect(helper.brand_font_link_tag).to eq('')
      end
    end
  end

  describe '#brand_meta_tags' do
    context 'when theme colors are present' do
      before do
        allow(brand_setting).to receive(:theme_colors).and_return({ primary: '#FF0000' })
      end

      it 'returns meta tags with theme color' do
        result = helper.brand_meta_tags
        expect(result).to include('theme-color')
        expect(result).to include('#FF0000')
        expect(result).to include('msapplication-TileColor')
      end
    end

    context 'when theme colors are blank' do
      before do
        allow(brand_setting).to receive(:theme_colors).and_return({})
      end

      it 'returns an empty string' do
        expect(helper.brand_meta_tags).to eq('')
      end
    end
  end

  describe '#brand_color' do
    before do
      allow(brand_setting).to receive(:theme_colors).and_return(
        {
          primary: '#FF0000',
          primaryLight: '#FF5555',
          primaryDark: '#AA0000',
          secondary: '#00FF00',
          secondaryLight: '#55FF55',
          secondaryDark: '#00AA00'
        }
      )
    end

    it 'returns primary color by default' do
      expect(helper.brand_color).to eq('#FF0000')
    end

    it 'returns primary color when specified' do
      expect(helper.brand_color(:primary)).to eq('#FF0000')
    end

    it 'returns primary_light color' do
      expect(helper.brand_color(:primary_light)).to eq('#FF5555')
    end

    it 'returns secondary color' do
      expect(helper.brand_color(:secondary)).to eq('#00FF00')
    end
  end

  describe '#brand_theme_name' do
    context 'when theme_name is set' do
      before do
        allow(brand_setting).to receive(:theme_name).and_return('Custom Theme')
        allow(brand_setting).to receive(:predefined_theme_name).and_return('Predefined')
      end

      it 'returns the theme_name' do
        expect(helper.brand_theme_name).to eq('Custom Theme')
      end
    end

    context 'when theme_name is blank' do
      before do
        allow(brand_setting).to receive(:theme_name).and_return('')
        allow(brand_setting).to receive(:predefined_theme_name).and_return('Predefined Theme')
      end

      it 'returns the predefined_theme_name' do
        expect(helper.brand_theme_name).to eq('Predefined Theme')
      end
    end

    context 'when both are blank' do
      before do
        allow(brand_setting).to receive(:theme_name).and_return(nil)
        allow(brand_setting).to receive(:predefined_theme_name).and_return(nil)
      end

      it 'returns Default' do
        expect(helper.brand_theme_name).to eq('Default')
      end
    end
  end

  describe '#custom_brand_active?' do
    context 'when brand setting has custom colors' do
      before do
        allow(brand_setting).to receive(:persisted?).and_return(true)
        allow(brand_setting).to receive(:has_custom_colors?).and_return(true)
        allow(brand_setting).to receive(:theme_id).and_return('default')
      end

      it 'returns true' do
        expect(helper.custom_brand_active?).to be true
      end
    end

    context 'when brand setting has non-default theme' do
      before do
        allow(brand_setting).to receive(:persisted?).and_return(true)
        allow(brand_setting).to receive(:has_custom_colors?).and_return(false)
        allow(brand_setting).to receive(:theme_id).and_return('purple')
      end

      it 'returns true' do
        expect(helper.custom_brand_active?).to be true
      end
    end

    context 'when brand setting is default' do
      before do
        allow(brand_setting).to receive(:persisted?).and_return(true)
        allow(brand_setting).to receive(:has_custom_colors?).and_return(false)
        allow(brand_setting).to receive(:theme_id).and_return('default')
      end

      it 'returns false' do
        expect(helper.custom_brand_active?).to be false
      end
    end
  end

  describe '#brand_image_url' do
    context 'when brand image exists with attachment' do
      let(:brand_image) { create(:brand_image, :with_image) }

      before do
        allow(BrandImage).to receive(:find_for).and_return(brand_image)
      end

      it 'returns the image URL' do
        result = helper.brand_image_url('logo_main')
        expect(result).to be_present
      end
    end

    context 'when brand image does not exist' do
      before do
        allow(BrandImage).to receive(:find_for).and_return(nil)
      end

      it 'returns the fallback URL' do
        result = helper.brand_image_url('logo_main', fallback: '/fallback/logo.png')
        expect(result).to eq('/fallback/logo.png')
      end

      it 'returns default fallback when no fallback provided' do
        result = helper.brand_image_url('logo_main')
        expect(result).to include('brand/logo-horizontal')
      end
    end
  end

  describe '#brand_social_icon_url' do
    it 'builds the correct key for social platforms' do
      expect(BrandImage).to receive(:find_for).with(
        'social_facebook',
        brand_setting: brand_setting,
        organization: anything
      )
      helper.brand_social_icon_url(:facebook)
    end
  end

  describe '#brand_banner_url' do
    it 'adds banner_ prefix if not present' do
      expect(BrandImage).to receive(:find_for).with(
        'banner_home',
        brand_setting: brand_setting,
        organization: anything
      )
      helper.brand_banner_url(:home)
    end

    it 'uses key as-is if already prefixed' do
      expect(BrandImage).to receive(:find_for).with(
        'banner_home',
        brand_setting: brand_setting,
        organization: anything
      )
      helper.brand_banner_url('banner_home')
    end
  end

  describe '#brand_image_exists?' do
    context 'when image exists with attachment' do
      let(:brand_image) { create(:brand_image, :with_image) }

      before do
        allow(BrandImage).to receive(:find_for).and_return(brand_image)
      end

      it 'returns true' do
        expect(helper.brand_image_exists?('logo_main')).to be true
      end
    end

    context 'when image does not exist' do
      before do
        allow(BrandImage).to receive(:find_for).and_return(nil)
      end

      it 'returns falsy' do
        expect(helper.brand_image_exists?('logo_main')).to be_falsy
      end
    end
  end

  describe '#brand_font_preload_tags' do
    context 'when fonts are configured' do
      before do
        allow(brand_setting).to receive(:effective_font_primary).and_return('Roboto')
        allow(brand_setting).to receive(:effective_font_display).and_return('Lato')
      end

      it 'returns preload link tags' do
        result = helper.brand_font_preload_tags
        expect(result).to include('preload')
        expect(result).to include('fonts.googleapis.com')
      end
    end

    context 'when no fonts are configured' do
      before do
        allow(brand_setting).to receive(:effective_font_primary).and_return(nil)
        allow(brand_setting).to receive(:effective_font_display).and_return(nil)
      end

      it 'returns empty string' do
        expect(helper.brand_font_preload_tags).to eq('')
      end
    end
  end

  describe 'private methods' do
    describe '#brand_cache_key' do
      it 'returns a cache key string' do
        key = helper.send(:brand_cache_key)
        expect(key).to match(%r{^brand_setting/active/})
      end

      it 'defaults to global when no organization context' do
        # User model does not have organization_id in this app
        key = helper.send(:brand_cache_key)
        expect(key).to eq('brand_setting/active/global')
      end
    end

    describe '#default_image_fallback' do
      it 'returns correct fallback for known keys' do
        result = helper.send(:default_image_fallback, 'logo_main')
        expect(result).to include('brand/logo-horizontal')
      end

      it 'returns correct fallback for favicon' do
        result = helper.send(:default_image_fallback, 'favicon')
        expect(result).to include('favicon')
      end

      it 'returns nil for unknown keys' do
        result = helper.send(:default_image_fallback, 'unknown_key')
        expect(result).to be_nil
      end
    end
  end
end
