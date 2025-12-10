# frozen_string_literal: true

require 'capybara/rspec'
require 'selenium-webdriver'

# Configure Capybara for system tests
Capybara.configure do |config|
  config.default_max_wait_time = 5
  config.default_normalize_ws = true
  config.test_id = 'data-testid'
  config.automatic_label_click = true
end

# Register headless Chrome driver
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1400,1000')
  options.add_argument('--disable-features=VizDisplayCompositor')
  options.add_argument('--disable-extensions')

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

# Register visible Chrome driver for debugging
Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--window-size=1400,1000')
  options.add_argument('--disable-extensions')

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

# Set default driver
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless

# Configure server
Capybara.server = :puma, { Silent: true }
Capybara.app_host = nil
Capybara.server_host = '127.0.0.1'

RSpec.configure do |config|
  config.include Capybara::DSL, type: :system

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end

  # Include Devise integration helpers for system specs
  config.include Devise::Test::IntegrationHelpers, type: :system

  # Take screenshots on failure (optional)
  config.after(:each, type: :system) do |example|
    if example.exception && page.driver.browser.respond_to?(:save_screenshot)
      screenshot_path = Rails.root.join('tmp', 'screenshots', "#{example.full_description.parameterize}.png")
      FileUtils.mkdir_p(File.dirname(screenshot_path))
      page.save_screenshot(screenshot_path) # rubocop:disable Lint/Debugger
    end
  end
end
