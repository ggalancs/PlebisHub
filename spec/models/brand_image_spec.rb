# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrandImage, type: :model do
  # == Associations ==
  describe 'associations' do
    it 'belongs to brand_setting optionally' do
      brand_setting = create(:brand_setting)
      image = create(:brand_image, brand_setting: brand_setting)
      expect(image.brand_setting).to eq(brand_setting)
    end

    it 'belongs to organization optionally' do
      image = create(:brand_image, organization: nil)
      expect(image.organization).to be_nil
    end

    it 'has one attached image' do
      image = create(:brand_image)
      expect(image).to respond_to(:image)
      expect(image.image).to respond_to(:attach)
    end
  end

  # == Constants ==
  describe 'constants' do
    it 'defines CATEGORIES' do
      expect(BrandImage::CATEGORIES).to eq(%w[logo favicon social banner icon background misc])
    end

    it 'defines IMAGE_DEFINITIONS with expected keys' do
      expect(BrandImage::IMAGE_DEFINITIONS).to include(
        'logo_main',
        'logo_dark',
        'favicon',
        'social_facebook',
        'banner_home',
        'icon_menu_hamburger',
        'bg_header'
      )
    end

    it 'has proper structure for IMAGE_DEFINITIONS entries' do
      definition = BrandImage::IMAGE_DEFINITIONS['logo_main']
      expect(definition).to include(:category, :name, :description, :recommended_size)
      expect(definition[:category]).to eq('logo')
    end
  end

  # == Validations ==
  describe 'validations' do
    it 'requires name when key is not in IMAGE_DEFINITIONS' do
      image = BrandImage.new(key: 'custom_unknown_key', category: 'misc', name: nil)
      expect(image).not_to be_valid
      expect(image.errors[:name]).to be_present
    end

    it 'requires key' do
      image = BrandImage.new(name: 'Test', category: 'logo', key: nil)
      expect(image).not_to be_valid
      expect(image.errors[:key]).to be_present
    end

    it 'requires category when key is not in IMAGE_DEFINITIONS' do
      image = BrandImage.new(key: 'custom_unknown_key', name: 'Test', category: nil)
      expect(image).not_to be_valid
      expect(image.errors[:category]).to be_present
    end

    it 'validates category inclusion' do
      image = BrandImage.new(key: 'custom_key', name: 'Test', category: 'invalid_category')
      expect(image).not_to be_valid
      expect(image.errors[:category]).to be_present
    end

    describe 'key uniqueness' do
      let!(:existing_image) { create(:brand_image, key: 'logo_main') }

      it 'allows same key for different brand_settings' do
        brand_setting = create(:brand_setting)
        new_image = build(:brand_image, key: 'logo_main', brand_setting: brand_setting)
        expect(new_image).to be_valid
      end

      it 'prevents duplicate key within same brand_setting' do
        brand_setting = create(:brand_setting)
        create(:brand_image, key: 'logo_main', brand_setting: brand_setting)
        duplicate = build(:brand_image, key: 'logo_main', brand_setting: brand_setting)
        expect(duplicate).not_to be_valid
      end
    end
  end

  # == Scopes ==
  describe 'scopes' do
    describe '.active' do
      let!(:active_image) { create(:brand_image, active: true) }
      let!(:inactive_image) { create(:brand_image, active: false, key: 'logo_dark') }

      it 'returns only active images' do
        expect(BrandImage.active).to include(active_image)
        expect(BrandImage.active).not_to include(inactive_image)
      end
    end

    describe '.by_category' do
      let!(:logo_image) { create(:brand_image, category: 'logo') }
      let!(:favicon_image) { create(:brand_image, category: 'favicon', key: 'favicon') }

      it 'filters by category' do
        expect(BrandImage.by_category('logo')).to include(logo_image)
        expect(BrandImage.by_category('logo')).not_to include(favicon_image)
      end
    end

    describe '.by_key' do
      let!(:logo_main) { create(:brand_image, key: 'logo_main') }
      let!(:logo_dark) { create(:brand_image, key: 'logo_dark') }

      it 'filters by key' do
        expect(BrandImage.by_key('logo_main')).to include(logo_main)
        expect(BrandImage.by_key('logo_main')).not_to include(logo_dark)
      end
    end

    describe '.global' do
      let!(:global_image) { create(:brand_image, brand_setting: nil, organization: nil) }
      let!(:brand_image) { create(:brand_image, key: 'logo_dark', brand_setting: create(:brand_setting)) }

      it 'returns only global images' do
        expect(BrandImage.global).to include(global_image)
        expect(BrandImage.global).not_to include(brand_image)
      end
    end

    describe 'category-specific scopes' do
      let!(:logo) { create(:brand_image, category: 'logo') }
      let!(:favicon) { create(:brand_image, category: 'favicon', key: 'favicon') }
      let!(:social) { create(:brand_image, category: 'social', key: 'social_facebook') }
      let!(:banner) { create(:brand_image, category: 'banner', key: 'banner_home') }
      let!(:icon) { create(:brand_image, category: 'icon', key: 'icon_menu_hamburger') }
      let!(:background) { create(:brand_image, category: 'background', key: 'bg_header') }

      it '.logos returns logo category' do
        expect(BrandImage.logos).to include(logo)
        expect(BrandImage.logos).not_to include(favicon)
      end

      it '.favicons returns favicon category' do
        expect(BrandImage.favicons).to include(favicon)
        expect(BrandImage.favicons).not_to include(logo)
      end

      it '.social_icons returns social category' do
        expect(BrandImage.social_icons).to include(social)
      end

      it '.banners returns banner category' do
        expect(BrandImage.banners).to include(banner)
      end

      it '.icons returns icon category' do
        expect(BrandImage.icons).to include(icon)
      end

      it '.backgrounds returns background category' do
        expect(BrandImage.backgrounds).to include(background)
      end
    end
  end

  # == Class Methods ==
  describe '.find_for' do
    let(:brand_setting) { create(:brand_setting) }
    let!(:global_image) { create(:brand_image, key: 'logo_main', brand_setting: nil) }
    let!(:brand_image) { create(:brand_image, key: 'logo_main', brand_setting: brand_setting) }

    context 'with brand_setting' do
      it 'returns brand_setting specific image when available' do
        # Need to attach an image for it to be returned
        brand_image.image.attach(
          io: StringIO.new('fake image content'),
          filename: 'test.png',
          content_type: 'image/png'
        )
        result = BrandImage.find_for('logo_main', brand_setting: brand_setting)
        expect(result).to eq(brand_image)
      end

      it 'falls back to global when brand_setting image not attached' do
        global_image.image.attach(
          io: StringIO.new('fake image content'),
          filename: 'test.png',
          content_type: 'image/png'
        )
        result = BrandImage.find_for('logo_main', brand_setting: brand_setting)
        expect(result).to eq(global_image)
      end
    end

    context 'without brand_setting' do
      it 'returns global image' do
        result = BrandImage.find_for('logo_main')
        expect(result).to eq(global_image)
      end
    end
  end

  describe '.create_defaults_for' do
    let(:brand_setting) { create(:brand_setting) }

    it 'creates entries for all IMAGE_DEFINITIONS' do
      expect {
        BrandImage.create_defaults_for(brand_setting: brand_setting)
      }.to change(BrandImage, :count).by(BrandImage::IMAGE_DEFINITIONS.count)
    end

    it 'does not duplicate on second call' do
      BrandImage.create_defaults_for(brand_setting: brand_setting)
      expect {
        BrandImage.create_defaults_for(brand_setting: brand_setting)
      }.not_to change(BrandImage, :count)
    end

    it 'sets correct attributes from definition' do
      BrandImage.create_defaults_for(brand_setting: brand_setting)
      logo = BrandImage.find_by(key: 'logo_main', brand_setting: brand_setting)
      expect(logo.name).to eq('Main Logo')
      expect(logo.category).to eq('logo')
    end
  end

  describe '.available_keys_by_category' do
    it 'groups keys by category' do
      result = BrandImage.available_keys_by_category
      expect(result).to be_a(Hash)
      expect(result.keys).to include('logo', 'favicon', 'social')
    end

    it 'includes key details in each category' do
      result = BrandImage.available_keys_by_category
      logo_keys = result['logo']
      expect(logo_keys).to be_an(Array)
      expect(logo_keys.first).to include(:key, :name, :description, :recommended_size)
    end
  end

  # == Instance Methods ==
  describe '#recommended_size' do
    it 'returns size from IMAGE_DEFINITIONS' do
      image = build(:brand_image, key: 'logo_main')
      expect(image.recommended_size).to eq('260x64')
    end

    it 'returns nil for unknown key' do
      image = build(:brand_image, key: 'unknown_key', name: 'Unknown', category: 'misc')
      expect(image.recommended_size).to be_nil
    end
  end

  describe '#definition' do
    it 'returns definition hash for known key' do
      image = build(:brand_image, key: 'logo_main')
      expect(image.definition).to include(:category, :name)
    end

    it 'returns empty hash for unknown key' do
      image = build(:brand_image, key: 'unknown_key', name: 'Unknown', category: 'misc')
      expect(image.definition).to eq({})
    end
  end

  describe '#global?' do
    it 'returns true when no brand_setting or organization' do
      image = build(:brand_image, brand_setting: nil, organization: nil)
      expect(image.global?).to be true
    end

    it 'returns false when brand_setting is set' do
      image = build(:brand_image, brand_setting: create(:brand_setting))
      expect(image.global?).to be false
    end
  end

  # == Callbacks ==
  describe 'callbacks' do
    describe 'before_validation :set_defaults_from_key' do
      it 'sets name from IMAGE_DEFINITIONS when key is known' do
        image = BrandImage.new(key: 'logo_main', category: 'logo')
        image.valid?
        expect(image.name).to eq('Main Logo')
      end

      it 'sets category from IMAGE_DEFINITIONS when key is known' do
        image = BrandImage.new(key: 'favicon', name: 'Test')
        image.valid?
        expect(image.category).to eq('favicon')
      end

      it 'does not override existing values' do
        image = BrandImage.new(key: 'logo_main', name: 'Custom Name', category: 'logo')
        image.valid?
        expect(image.name).to eq('Custom Name')
      end
    end
  end

  # == Image Validations ==
  describe 'image validations' do
    let(:image) { create(:brand_image) }

    describe '#image_format_validation' do
      it 'accepts PNG files' do
        image.image.attach(
          io: StringIO.new('fake png'),
          filename: 'test.png',
          content_type: 'image/png'
        )
        expect(image).to be_valid
      end

      it 'accepts JPEG files' do
        image.image.attach(
          io: StringIO.new('fake jpeg'),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
        expect(image).to be_valid
      end

      it 'accepts SVG files' do
        image.image.attach(
          io: StringIO.new('<svg></svg>'),
          filename: 'test.svg',
          content_type: 'image/svg+xml'
        )
        expect(image).to be_valid
      end

      it 'rejects non-image files' do
        image.image.attach(
          io: StringIO.new('not an image'),
          filename: 'test.txt',
          content_type: 'text/plain'
        )
        expect(image).not_to be_valid
        expect(image.errors[:image]).to include('must be a PNG, JPEG, GIF, SVG, WebP, or ICO file')
      end
    end
  end
end
