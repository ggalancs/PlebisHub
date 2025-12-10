# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Brand Settings Color Picker', type: :system, js: true do
  let!(:admin_user) { create(:user, :admin) }
  let!(:brand_setting) { BrandSetting.create!(name: 'Test Theme', scope: 'global', theme_id: 'default', active: true) }

  before do
    driven_by(:selenium_chrome_headless)
    login_as(admin_user, scope: :user)
  end

  describe 'complementary color preview' do
    it 'shows the correct initial complementary color' do
      visit edit_admin_brand_setting_path(brand_setting)

      # Wait for JavaScript to initialize
      sleep 1

      # Check that complementary color preview exists
      expect(page).to have_css('#complementary_color_preview')
      expect(page).to have_css('#complementary_color_value')

      # The default purple #612d62 should have green #2E622D as complementary
      complementary_value = find('#complementary_color_value').text
      expect(complementary_value.downcase).to eq('#2e622d')
    end

    it 'updates complementary color when primary color changes' do
      visit edit_admin_brand_setting_path(brand_setting)

      # Wait for JavaScript to initialize
      sleep 1

      # Find the primary color input
      find('#brand_setting_primary_color', visible: :all)

      # Change to yellow (#FFFF00)
      # For color inputs, we need to use JavaScript to set the value
      page.execute_script("document.getElementById('brand_setting_primary_color').value = '#ffff00'")
      page.execute_script("document.getElementById('brand_setting_primary_color').dispatchEvent(new Event('input'))")

      # Wait for JavaScript to process
      sleep 0.5

      # Yellow's complementary should be blue (#0000FF)
      complementary_value = find('#complementary_color_value').text
      expect(complementary_value.downcase).to eq('#0000ff')
    end

    it 'updates complementary color to cyan when primary is red' do
      visit edit_admin_brand_setting_path(brand_setting)

      sleep 1

      # Change to red (#FF0000)
      page.execute_script("document.getElementById('brand_setting_primary_color').value = '#ff0000'")
      page.execute_script("document.getElementById('brand_setting_primary_color').dispatchEvent(new Event('input'))")

      sleep 0.5

      # Red's complementary should be cyan (#00FFFF)
      complementary_value = find('#complementary_color_value').text
      expect(complementary_value.downcase).to eq('#00ffff')
    end

    it 'updates complementary color to yellow when primary is blue' do
      visit edit_admin_brand_setting_path(brand_setting)

      sleep 1

      # Change to blue (#0000FF)
      page.execute_script("document.getElementById('brand_setting_primary_color').value = '#0000ff'")
      page.execute_script("document.getElementById('brand_setting_primary_color').dispatchEvent(new Event('input'))")

      sleep 0.5

      # Blue's complementary should be yellow (#FFFF00)
      complementary_value = find('#complementary_color_value').text
      expect(complementary_value.downcase).to eq('#ffff00')
    end

    it 'applies complementary color to secondary when button is clicked' do
      visit edit_admin_brand_setting_path(brand_setting)

      sleep 1

      # Set primary to yellow
      page.execute_script("document.getElementById('brand_setting_primary_color').value = '#ffff00'")
      page.execute_script("document.getElementById('brand_setting_primary_color').dispatchEvent(new Event('input'))")

      sleep 0.5

      # Click "Use as Secondary" button
      click_button 'Use as Secondary'

      sleep 0.5

      # Secondary color should now be blue (#0000FF)
      secondary_value = page.evaluate_script("document.getElementById('brand_setting_secondary_color').value")
      expect(secondary_value.downcase).to eq('#0000ff')
    end

    it 'auto-generates light and dark variants when checkbox is checked' do
      visit edit_admin_brand_setting_path(brand_setting)

      sleep 1

      # Check the auto-generate checkbox
      check 'auto_generate_variants'

      # Set primary to a specific color
      page.execute_script("document.getElementById('brand_setting_primary_color').value = '#ff0000'")
      page.execute_script("document.getElementById('brand_setting_primary_color').dispatchEvent(new Event('input'))")

      sleep 0.5

      # Light and dark variants should be auto-generated
      light_value = page.evaluate_script("document.getElementById('brand_setting_primary_light_color').value")
      dark_value = page.evaluate_script("document.getElementById('brand_setting_primary_dark_color').value")

      # Light should be lighter than #ff0000
      # Dark should be darker than #ff0000
      expect(light_value).not_to eq('#ff0000')
      expect(dark_value).not_to eq('#ff0000')
      expect(light_value).to be_present
      expect(dark_value).to be_present
    end
  end

  describe 'JavaScript color tools availability' do
    it 'exposes BrandColorTools on window object' do
      visit edit_admin_brand_setting_path(brand_setting)

      sleep 1

      # Check that BrandColorTools is available
      tools_available = page.evaluate_script("typeof window.BrandColorTools !== 'undefined'")
      expect(tools_available).to be true
    end

    it 'calculates complementary colors correctly via JavaScript' do
      visit edit_admin_brand_setting_path(brand_setting)

      sleep 1

      # Test yellow -> blue
      yellow_comp = page.evaluate_script("window.BrandColorTools.complementaryColor('#ffff00')")
      expect(yellow_comp.downcase).to eq('#0000ff')

      # Test red -> cyan
      red_comp = page.evaluate_script("window.BrandColorTools.complementaryColor('#ff0000')")
      expect(red_comp.downcase).to eq('#00ffff')

      # Test blue -> yellow
      blue_comp = page.evaluate_script("window.BrandColorTools.complementaryColor('#0000ff')")
      expect(blue_comp.downcase).to eq('#ffff00')

      # Test green -> magenta
      green_comp = page.evaluate_script("window.BrandColorTools.complementaryColor('#00ff00')")
      expect(green_comp.downcase).to eq('#ff00ff')
    end
  end
end
