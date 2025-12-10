# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BrandSetting, type: :model do
  # ====================
  # CONSTANT TESTS
  # ====================

  describe 'constants' do
    it 'defines PREDEFINED_THEMES with all required themes' do
      expect(BrandSetting::PREDEFINED_THEMES).to be_a(Hash)
      expect(BrandSetting::PREDEFINED_THEMES.keys).to match_array(%w[default ocean forest sunset monochrome])
    end

    it 'each predefined theme has required structure' do
      BrandSetting::PREDEFINED_THEMES.each_value do |theme|
        expect(theme).to have_key(:name)
        expect(theme).to have_key(:description)
        expect(theme).to have_key(:colors)
        expect(theme[:colors].keys).to match_array(%i[primary primaryLight primaryDark secondary secondaryLight secondaryDark])
      end
    end

    it 'defines HEX_COLOR_REGEX' do
      expect(BrandSetting::HEX_COLOR_REGEX).to be_a(Regexp)
      expect('#612d62').to match(BrandSetting::HEX_COLOR_REGEX)
      expect('#fff').to match(BrandSetting::HEX_COLOR_REGEX)
      expect('612d62').not_to match(BrandSetting::HEX_COLOR_REGEX)
    end

    it 'defines VALID_SCOPES' do
      expect(BrandSetting::VALID_SCOPES).to eq(%w[global organization])
    end
  end

  # ====================
  # ASSOCIATION TESTS
  # ====================

  describe 'associations' do
    it 'belongs to organization (optional)' do
      brand_setting = BrandSetting.new(scope: 'global')
      expect(brand_setting).to respond_to(:organization)
    end
  end

  # ====================
  # VALIDATION TESTS
  # ====================

  describe 'validations' do
    context 'basic validations' do
      it 'requires name' do
        setting = BrandSetting.new(name: nil, scope: 'global', theme_id: 'default')
        expect(setting).not_to be_valid
        expect(setting.errors[:name]).to be_present
      end

      it 'validates name length' do
        setting = BrandSetting.new(name: 'a' * 256, scope: 'global', theme_id: 'default')
        expect(setting).not_to be_valid
        expect(setting.errors[:name]).to be_present
      end

      it 'requires scope' do
        setting = BrandSetting.new(name: 'Test', scope: nil, theme_id: 'default')
        expect(setting).not_to be_valid
        expect(setting.errors[:scope]).to be_present
      end

      it 'validates scope inclusion' do
        setting = BrandSetting.new(name: 'Test', scope: 'invalid', theme_id: 'default')
        expect(setting).not_to be_valid
        expect(setting.errors[:scope]).to include('no está incluido en la lista')
      end

      it 'requires theme_id' do
        setting = BrandSetting.new(name: 'Test', scope: 'global', theme_id: nil)
        expect(setting).not_to be_valid
        expect(setting.errors[:theme_id]).to be_present
      end

      it 'validates version is positive integer' do
        setting = BrandSetting.create!(name: 'Test', scope: 'global', theme_id: 'default')
        setting.version = 0
        expect(setting).not_to be_valid
        expect(setting.errors[:version]).to be_present
      end
    end

    context 'scope-specific validations' do
      it 'requires organization_id when scope is organization' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'organization',
          theme_id: 'default',
          organization_id: nil
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:organization_id]).to include('no puede estar en blanco')
      end

      it 'rejects organization_id when scope is global' do
        organization = Organization.create!(name: 'Test Org')
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          organization_id: organization.id
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:organization_id]).to include('must be blank')
      end
    end

    context 'color format validations' do
      it 'validates primary_color hex format' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: 'invalid'
        )
        expect(setting).not_to be_valid
        expect(setting.errors[:primary_color]).to be_present
      end

      it 'accepts valid hex color formats' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#612d62',
          secondary_color: '#fff'
        )
        expect(setting.errors[:primary_color]).to be_empty
        expect(setting.errors[:secondary_color]).to be_empty
      end

      it 'validates all color fields' do
        color_fields = %i[
          primary_color
          primary_light_color
          primary_dark_color
          secondary_color
          secondary_light_color
          secondary_dark_color
        ]

        color_fields.each do |field|
          setting = BrandSetting.new(
            name: 'Test',
            scope: 'global',
            theme_id: 'default',
            field => 'invalid'
          )
          expect(setting).not_to be_valid, "#{field} should validate hex format"
          expect(setting.errors[field]).to be_present
        end
      end
    end

    context 'unique organization setting validation' do
      it 'allows only one brand setting per organization' do
        organization = Organization.create!(name: 'Test Org')

        BrandSetting.create!(
          name: 'First Setting',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'default'
        )

        second_setting = BrandSetting.new(
          name: 'Second Setting',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'ocean'
        )

        expect(second_setting).not_to be_valid
        expect(second_setting.errors[:organization_id]).to include('already has a brand setting. Only one per organization allowed.')
      end

      it 'allows updating existing organization setting' do
        organization = Organization.create!(name: 'Test Org')

        setting = BrandSetting.create!(
          name: 'Original',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'default'
        )

        setting.name = 'Updated'
        expect(setting).to be_valid
      end

      it 'allows multiple global settings' do
        first = BrandSetting.create!(name: 'Global 1', scope: 'global', theme_id: 'default')
        second = BrandSetting.create!(name: 'Global 2', scope: 'global', theme_id: 'ocean')

        expect(first).to be_valid
        expect(second).to be_valid
      end
    end

    context 'at least one active global validation' do
      it 'prevents deactivating the last active global setting' do
        # Create and activate one global setting
        setting = BrandSetting.create!(
          name: 'Only Global',
          scope: 'global',
          theme_id: 'default',
          active: true
        )

        setting.active = false
        expect(setting).not_to be_valid
        expect(setting.errors[:active]).to include('cannot be disabled. At least one global brand setting must be active.')
      end

      it 'allows deactivating global setting when another is active' do
        first = BrandSetting.create!(name: 'Global 1', scope: 'global', theme_id: 'default', active: true)
        BrandSetting.create!(name: 'Global 2', scope: 'global', theme_id: 'ocean', active: true)

        first.active = false
        expect(first).to be_valid
      end

      it 'allows deactivating organization settings freely' do
        organization = Organization.create!(name: 'Test Org')
        setting = BrandSetting.create!(
          name: 'Org Setting',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'default',
          active: true
        )

        setting.active = false
        expect(setting).to be_valid
      end
    end

    context 'WCAG contrast validation' do
      it 'auto-adjusts primary_color to meet WCAG requirements' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#f0f0f0' # Very light color, poor contrast
        )

        setting.valid?
        # The color should be auto-adjusted to meet WCAG requirements
        expect(setting.primary_color).not_to eq('#f0f0f0')
        expect(setting.contrast_ratio_for(setting.primary_color)).to be >= 4.5
      end

      it 'auto-adjusts secondary_color to meet WCAG requirements' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          secondary_color: '#eeeeee' # Very light color, poor contrast
        )

        setting.valid?
        # The color should be auto-adjusted to meet WCAG requirements
        expect(setting.secondary_color).not_to eq('#eeeeee')
        expect(setting.contrast_ratio_for(setting.secondary_color)).to be >= 4.5
      end

      it 'accepts colors with good contrast' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#612d62', # Good contrast (5.02:1)
          secondary_color: '#1a7568' # Good contrast (4.58:1)
        )

        setting.valid?
        expect(setting.errors[:primary_color]).to be_empty
        expect(setting.errors[:secondary_color]).to be_empty
      end

      it 'skips contrast validation when no custom colors' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default'
        )

        expect(setting).to be_valid
      end
    end
  end

  # ====================
  # SCOPE TESTS
  # ====================

  describe 'scopes' do
    before do
      BrandSetting.destroy_all
    end

    describe '.active' do
      it 'returns only active settings' do
        active = BrandSetting.create!(name: 'Active', scope: 'global', theme_id: 'default', active: true)
        inactive = BrandSetting.create!(name: 'Inactive', scope: 'global', theme_id: 'ocean', active: false)

        expect(BrandSetting.active).to include(active)
        expect(BrandSetting.active).not_to include(inactive)
      end
    end

    describe '.inactive' do
      it 'returns only inactive settings' do
        active = BrandSetting.create!(name: 'Active', scope: 'global', theme_id: 'default', active: true)
        inactive = BrandSetting.create!(name: 'Inactive', scope: 'global', theme_id: 'ocean', active: false)

        expect(BrandSetting.inactive).to include(inactive)
        expect(BrandSetting.inactive).not_to include(active)
      end
    end

    describe '.global_settings' do
      it 'returns only global scope settings' do
        organization = Organization.create!(name: 'Test Org')
        global = BrandSetting.create!(name: 'Global', scope: 'global', theme_id: 'default')
        org_setting = BrandSetting.create!(
          name: 'Org',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'ocean'
        )

        expect(BrandSetting.global_settings).to include(global)
        expect(BrandSetting.global_settings).not_to include(org_setting)
      end
    end

    describe '.organization_settings' do
      it 'returns only organization scope settings' do
        organization = Organization.create!(name: 'Test Org')
        global = BrandSetting.create!(name: 'Global', scope: 'global', theme_id: 'default')
        org_setting = BrandSetting.create!(
          name: 'Org',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'ocean'
        )

        expect(BrandSetting.organization_settings).to include(org_setting)
        expect(BrandSetting.organization_settings).not_to include(global)
      end
    end

    describe '.for_organization' do
      it 'returns settings for specific organization' do
        org1 = Organization.create!(name: 'Org 1')
        org2 = Organization.create!(name: 'Org 2')

        setting1 = BrandSetting.create!(
          name: 'Org 1 Setting',
          scope: 'organization',
          organization_id: org1.id,
          theme_id: 'default'
        )

        setting2 = BrandSetting.create!(
          name: 'Org 2 Setting',
          scope: 'organization',
          organization_id: org2.id,
          theme_id: 'ocean'
        )

        expect(BrandSetting.for_organization(org1.id)).to include(setting1)
        expect(BrandSetting.for_organization(org1.id)).not_to include(setting2)
      end
    end
  end

  # ====================
  # CALLBACK TESTS
  # ====================

  describe 'callbacks' do
    describe 'set_theme_name_from_predefined' do
      it 'sets theme_name from predefined theme if blank' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'ocean',
          theme_name: nil
        )

        expect(setting.theme_name).to eq('Ocean Blue')
      end

      it 'preserves custom theme_name if provided' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'ocean',
          theme_name: 'Custom Name'
        )

        expect(setting.theme_name).to eq('Custom Name')
      end
    end

    describe 'increment_version_if_colors_changed' do
      it 'increments version when colors change' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#612d62'
        )

        original_version = setting.version
        setting.update!(primary_color: '#8a4f98')

        expect(setting.version).to eq(original_version + 1)
      end

      it 'does not increment version when other fields change' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default'
        )

        original_version = setting.version
        setting.update!(name: 'Updated Name')

        expect(setting.version).to eq(original_version)
      end

      it 'does not increment version on create' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#612d62'
        )

        expect(setting.version).to eq(1)
      end
    end

    describe 'clear_cache' do
      it 'clears cache after commit' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default'
        )

        # Allow all cache delete calls (clear_cache deletes multiple keys)
        allow(Rails.cache).to receive(:delete).and_call_original
        expect(Rails.cache).to receive(:delete).with(setting.cache_key_with_version).at_least(:once)
        expect(Rails.cache).to receive(:delete).with('brand_setting/global/global').at_least(:once)

        setting.update!(name: 'Updated')
      end
    end
  end

  # ====================
  # CLASS METHOD TESTS
  # ====================

  describe 'class methods' do
    describe '.current_for_organization' do
      it 'returns active organization setting when available' do
        organization = Organization.create!(name: 'Test Org')
        org_setting = BrandSetting.create!(
          name: 'Org Setting',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'ocean',
          active: true
        )

        BrandSetting.create!(
          name: 'Global',
          scope: 'global',
          theme_id: 'default',
          active: true
        )

        result = BrandSetting.current_for_organization(organization.id)
        expect(result).to eq(org_setting)
      end

      it 'returns global setting when no organization setting' do
        organization = Organization.create!(name: 'Test Org')
        global_setting = BrandSetting.create!(
          name: 'Global',
          scope: 'global',
          theme_id: 'default',
          active: true
        )

        result = BrandSetting.current_for_organization(organization.id)
        expect(result).to eq(global_setting)
      end

      it 'returns global setting when organization_id is nil' do
        global_setting = BrandSetting.create!(
          name: 'Global',
          scope: 'global',
          theme_id: 'default',
          active: true
        )

        result = BrandSetting.current_for_organization(nil)
        expect(result).to eq(global_setting)
      end

      it 'returns default setting when no settings exist' do
        result = BrandSetting.current_for_organization(nil)
        expect(result).to be_a(BrandSetting)
        expect(result.new_record?).to be true
        expect(result.theme_id).to eq('default')
      end
    end

    describe '.default_setting' do
      it 'returns new instance with default values' do
        setting = BrandSetting.default_setting

        expect(setting).to be_a(BrandSetting)
        expect(setting.new_record?).to be true
        expect(setting.name).to eq('Default Theme')
        expect(setting.scope).to eq('global')
        expect(setting.theme_id).to eq('default')
        expect(setting.active).to be true
      end
    end
  end

  # ====================
  # INSTANCE METHOD TESTS
  # ====================

  describe 'instance methods' do
    describe '#predefined_theme_name' do
      it 'returns name from predefined theme' do
        setting = BrandSetting.new(theme_id: 'ocean')
        expect(setting.predefined_theme_name).to eq('Ocean Blue')
      end

      it 'returns nil for invalid theme_id' do
        setting = BrandSetting.new(theme_id: 'invalid')
        expect(setting.predefined_theme_name).to be_nil
      end
    end

    describe '#predefined_theme_description' do
      it 'returns description from predefined theme' do
        setting = BrandSetting.new(theme_id: 'forest')
        expect(setting.predefined_theme_description).to eq('Natural green palette')
      end
    end

    describe '#predefined_theme_colors' do
      it 'returns colors hash from predefined theme' do
        setting = BrandSetting.new(theme_id: 'default')
        colors = setting.predefined_theme_colors

        expect(colors).to be_a(Hash)
        expect(colors[:primary]).to eq('#612d62')
        expect(colors[:secondary]).to eq('#269283')
      end

      it 'returns empty hash for invalid theme_id' do
        setting = BrandSetting.new(theme_id: 'invalid')
        expect(setting.predefined_theme_colors).to eq({})
      end
    end

    describe '#theme_colors' do
      it 'returns custom colors when present' do
        setting = BrandSetting.new(
          theme_id: 'default',
          primary_color: '#ff0000',
          secondary_color: '#00ff00'
        )

        colors = setting.theme_colors
        expect(colors[:primary]).to eq('#ff0000')
        expect(colors[:secondary]).to eq('#00ff00')
      end

      it 'returns predefined theme colors when no custom colors' do
        setting = BrandSetting.new(theme_id: 'ocean')
        colors = setting.theme_colors

        expect(colors[:primary]).to eq('#1e40af')
        expect(colors[:secondary]).to eq('#0891b2')
      end

      it 'compacts nil values in custom colors' do
        setting = BrandSetting.new(
          theme_id: 'default',
          primary_color: '#ff0000',
          primary_light_color: nil
        )

        colors = setting.theme_colors
        expect(colors).to have_key(:primary)
        expect(colors).not_to have_key(:primaryLight)
      end
    end

    describe '#has_custom_colors?' do
      it 'returns true when any custom color is set' do
        setting = BrandSetting.new(primary_color: '#ff0000')
        expect(setting.has_custom_colors?).to be true
      end

      it 'returns false when no custom colors' do
        setting = BrandSetting.new(theme_id: 'default')
        expect(setting.has_custom_colors?).to be false
      end
    end

    describe '#colors_changed?' do
      it 'returns true when any color changed' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#0066cc'
        )

        setting.primary_color = '#006600'
        expect(setting.colors_changed?).to be true
      end

      it 'returns false when no colors changed' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default'
        )

        setting.name = 'Updated'
        expect(setting.colors_changed?).to be false
      end
    end

    describe '#global_scope?' do
      it 'returns true for global scope' do
        setting = BrandSetting.new(scope: 'global')
        expect(setting.global_scope?).to be true
      end

      it 'returns false for organization scope' do
        setting = BrandSetting.new(scope: 'organization')
        expect(setting.global_scope?).to be false
      end
    end

    describe '#organization_scope?' do
      it 'returns true for organization scope' do
        setting = BrandSetting.new(scope: 'organization')
        expect(setting.organization_scope?).to be true
      end

      it 'returns false for global scope' do
        setting = BrandSetting.new(scope: 'global')
        expect(setting.organization_scope?).to be false
      end
    end

    describe '#cache_key_with_version' do
      it 'generates correct cache key for global scope' do
        setting = BrandSetting.new(scope: 'global', version: 1)
        expect(setting.cache_key_with_version).to eq('brand_setting/global/global/v1')
      end

      it 'generates correct cache key for organization scope' do
        organization = Organization.create!(name: 'Test Org')
        setting = BrandSetting.new(
          scope: 'organization',
          organization_id: organization.id,
          version: 2
        )

        expect(setting.cache_key_with_version).to eq("brand_setting/organization/#{organization.id}/v2")
      end
    end

    describe '#to_brand_json' do
      it 'serializes to correct JSON structure' do
        setting = BrandSetting.create!(
          name: 'Test Theme',
          description: 'Test description',
          scope: 'global',
          theme_id: 'ocean',
          active: true,
          metadata: { custom: 'data' }
        )

        json = setting.to_brand_json

        expect(json[:theme][:id]).to eq('ocean')
        expect(json[:theme][:name]).to eq('Ocean Blue')
        expect(json[:theme][:description]).to eq('Cool blue tones')
        expect(json[:theme][:colors][:primary]).to eq('#1e40af')
        expect(json[:scope]).to eq('global')
        expect(json[:active]).to be true
        expect(json[:version]).to eq(1)
        expect(json[:metadata]).to eq({ 'custom' => 'data' })
        expect(json[:customColors]).to be_nil
      end

      it 'includes custom colors when present' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#0066cc',
          secondary_color: '#006600'
        )

        json = setting.to_brand_json

        expect(json[:customColors]).not_to be_nil
        expect(json[:customColors][:primary]).to eq('#0066cc')
        expect(json[:customColors][:secondary]).to eq('#006600')
      end

      it 'includes timestamps' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default'
        )

        json = setting.to_brand_json

        expect(json[:createdAt]).to be_present
        expect(json[:updatedAt]).to be_present
        expect(json[:createdAt]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
      end
    end
  end

  # ====================
  # WCAG CONTRAST CALCULATION TESTS
  # ====================

  describe 'WCAG contrast calculation' do
    describe '#calculate_contrast_ratio' do
      let(:setting) { BrandSetting.new }

      it 'calculates correct contrast ratio for known colors' do
        # Black on white should be 21:1 (maximum contrast)
        ratio = setting.send(:calculate_contrast_ratio, '#000000', '#ffffff')
        expect(ratio).to be_within(0.1).of(21.0)
      end

      it 'calculates lower contrast for similar colors' do
        # Light gray on white
        ratio = setting.send(:calculate_contrast_ratio, '#cccccc', '#ffffff')
        expect(ratio).to be < 4.5
      end
    end

    describe '#relative_luminance' do
      let(:setting) { BrandSetting.new }

      it 'calculates luminance for white' do
        luminance = setting.send(:relative_luminance, '#ffffff')
        expect(luminance).to be_within(0.01).of(1.0)
      end

      it 'calculates luminance for black' do
        luminance = setting.send(:relative_luminance, '#000000')
        expect(luminance).to be_within(0.01).of(0.0)
      end

      it 'handles short hex format' do
        # #fff should equal #ffffff
        luminance_short = setting.send(:relative_luminance, '#fff')
        luminance_long = setting.send(:relative_luminance, '#ffffff')
        expect(luminance_short).to eq(luminance_long)
      end
    end
  end

  # ====================
  # COMBINED SCENARIO TESTS
  # ====================

  describe 'combined scenarios' do
    it 'handles complete brand setting lifecycle' do
      # Create setting (must be active initially)
      setting = BrandSetting.create!(
        name: 'Campaign Theme',
        description: 'Special campaign colors',
        scope: 'global',
        theme_id: 'ocean',
        active: true
      )

      expect(setting).to be_valid
      expect(setting.version).to eq(1)

      # Update with custom colors (version should increment)
      setting.update!(
        primary_color: '#0066cc',
        secondary_color: '#006600'
      )

      expect(setting.version).to eq(2)
      expect(setting.has_custom_colors?).to be true

      # Verify still active
      expect(setting.active).to be true

      # Verify JSON serialization works
      json = setting.to_brand_json
      expect(json[:theme][:colors][:primary]).to eq('#0066cc')
      expect(json[:customColors][:primary]).to eq('#0066cc')
    end

    it 'handles organization-specific branding' do
      organization = Organization.create!(name: 'Special Org')

      # Create organization-specific theme
      org_setting = BrandSetting.create!(
        name: 'Organization Brand',
        scope: 'organization',
        organization_id: organization.id,
        theme_id: 'sunset',
        active: true
      )

      # Verify it's returned for that organization
      result = BrandSetting.current_for_organization(organization.id)
      expect(result).to eq(org_setting)

      # Verify global setting is used for other organizations
      result_other = BrandSetting.current_for_organization(nil)
      expect(result_other).not_to eq(org_setting)
    end
  end

  # ====================
  # ADDITIONAL EDGE CASES
  # ====================

  describe 'additional edge cases' do
    describe '#increment_version_if_colors_changed' do
      it 'increments version when secondary_light_color changes' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          secondary_light_color: '#14b8a6'
        )

        original_version = setting.version
        setting.update!(secondary_light_color: '#00ff00')

        expect(setting.version).to eq(original_version + 1)
      end

      it 'increments version when secondary_dark_color changes' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          secondary_dark_color: '#0f766e'
        )

        original_version = setting.version
        setting.update!(secondary_dark_color: '#006600')

        expect(setting.version).to eq(original_version + 1)
      end

      it 'increments version when primary_light_color changes' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_light_color: '#8a4f98'
        )

        original_version = setting.version
        setting.update!(primary_light_color: '#ff00ff')

        expect(setting.version).to eq(original_version + 1)
      end

      it 'increments version when primary_dark_color changes' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_dark_color: '#4c244a'
        )

        original_version = setting.version
        setting.update!(primary_dark_color: '#330033')

        expect(setting.version).to eq(original_version + 1)
      end
    end

    describe '#to_brand_json' do
      it 'includes organization_id when present' do
        organization = Organization.create!(name: 'Test Org')
        setting = BrandSetting.create!(
          name: 'Org Setting',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'default'
        )

        json = setting.to_brand_json
        expect(json[:organizationId]).to eq(organization.id)
      end

      it 'includes custom theme_name when provided' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          theme_name: 'My Custom Theme'
        )

        json = setting.to_brand_json
        expect(json[:theme][:name]).to eq('My Custom Theme')
      end

      it 'compacts custom colors to exclude nil values' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#0066cc',
          primary_light_color: nil,
          secondary_color: nil
        )

        json = setting.to_brand_json
        expect(json[:customColors][:primary]).to eq('#0066cc')
        expect(json[:customColors]).not_to have_key(:primaryLight)
        expect(json[:customColors]).not_to have_key(:secondary)
      end
    end

    describe 'color validation edge cases' do
      it 'allows blank color values' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: '',
          secondary_color: nil
        )

        setting.valid?
        expect(setting.errors[:primary_color]).to be_empty
        expect(setting.errors[:secondary_color]).to be_empty
      end

      it 'rejects short hex format without hash' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: 'fff'
        )

        expect(setting).not_to be_valid
        expect(setting.errors[:primary_color]).to be_present
      end

      it 'rejects long hex format without hash' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: 'ffffff'
        )

        expect(setting).not_to be_valid
        expect(setting.errors[:primary_color]).to be_present
      end
    end

    describe 'WCAG contrast edge cases' do
      it 'only validates contrast when custom colors are present' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: nil,
          secondary_color: nil
        )

        expect(setting.has_custom_colors?).to be false
        expect(setting).to be_valid
      end

      it 'validates contrast only for valid hex colors' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: 'invalid'
        )

        setting.valid?
        # Should have format error but not contrast error
        expect(setting.errors[:primary_color]).to include(match(/invalid/i))
      end

      it 'calculates correct contrast for 3-char hex codes' do
        setting = BrandSetting.new(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          primary_color: '#000' # Black in short format
        )

        expect(setting).to be_valid
        expect(setting.errors[:primary_color]).to be_empty
      end
    end

    describe '.current_for_organization with empty string' do
      it 'treats empty string as nil' do
        global_setting = BrandSetting.create!(
          name: 'Global',
          scope: 'global',
          theme_id: 'default',
          active: true
        )

        result = BrandSetting.current_for_organization('')
        expect(result).to eq(global_setting)
      end
    end

    describe '#predefined_theme_description edge case' do
      it 'returns nil for invalid theme_id' do
        setting = BrandSetting.new(theme_id: 'nonexistent')
        expect(setting.predefined_theme_description).to be_nil
      end
    end

    describe 'clear_cache for organization scope' do
      it 'clears cache with organization_id' do
        organization = Organization.create!(name: 'Test Org')
        setting = BrandSetting.create!(
          name: 'Org Setting',
          scope: 'organization',
          organization_id: organization.id,
          theme_id: 'default'
        )

        # Allow all cache delete calls (clear_cache deletes multiple keys)
        allow(Rails.cache).to receive(:delete).and_call_original
        expect(Rails.cache).to receive(:delete).with(setting.cache_key_with_version).at_least(:once)
        expect(Rails.cache).to receive(:delete).with("brand_setting/organization/#{organization.id}").at_least(:once)

        setting.update!(name: 'Updated')
      end
    end

    describe 'theme_colors with all custom colors' do
      it 'returns all custom colors when all are set' do
        setting = BrandSetting.new(
          theme_id: 'default',
          primary_color: '#111111',
          primary_light_color: '#222222',
          primary_dark_color: '#000000',
          secondary_color: '#333333',
          secondary_light_color: '#444444',
          secondary_dark_color: '#111111'
        )

        colors = setting.theme_colors
        expect(colors[:primary]).to eq('#111111')
        expect(colors[:primaryLight]).to eq('#222222')
        expect(colors[:primaryDark]).to eq('#000000')
        expect(colors[:secondary]).to eq('#333333')
        expect(colors[:secondaryLight]).to eq('#444444')
        expect(colors[:secondaryDark]).to eq('#111111')
      end
    end

    describe 'version validation' do
      it 'rejects negative version' do
        setting = BrandSetting.create!(name: 'Test', scope: 'global', theme_id: 'default')
        setting.version = -1
        expect(setting).not_to be_valid
        expect(setting.errors[:version]).to be_present
      end

      it 'rejects decimal version' do
        setting = BrandSetting.create!(name: 'Test', scope: 'global', theme_id: 'default')
        setting.version = 1.5
        expect(setting).not_to be_valid
        expect(setting.errors[:version]).to be_present
      end
    end

    describe 'metadata handling' do
      it 'defaults to empty hash' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default'
        )

        expect(setting.metadata).to eq({})
      end

      it 'preserves custom metadata in JSON' do
        setting = BrandSetting.create!(
          name: 'Test',
          scope: 'global',
          theme_id: 'default',
          metadata: { foo: 'bar', nested: { key: 'value' } }
        )

        json = setting.to_brand_json
        expect(json[:metadata]).to eq({ 'foo' => 'bar', 'nested' => { 'key' => 'value' } })
      end
    end
  end
end
