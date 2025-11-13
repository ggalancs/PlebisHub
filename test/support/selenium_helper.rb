# ========================================
# Selenium WebDriver Helper
# ========================================
# Helper methods and configuration for Selenium tests
# ========================================

require 'selenium-webdriver'
require 'capybara'
require 'capybara/dsl'

module SeleniumHelper
  # Configure Capybara for Selenium tests
  def self.configure_capybara
    Capybara.register_driver :selenium_chrome do |app|
      options = Selenium::WebDriver::Chrome::Options.new

      # Headless mode for CI/CD environments
      if ENV['HEADLESS'] == 'true' || ENV['CI']
        options.add_argument('--headless')
        options.add_argument('--disable-gpu')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
      end

      # Window size
      options.add_argument('--window-size=1920,1080')

      # Additional options
      options.add_argument('--disable-blink-features=AutomationControlled')
      options.add_argument('--disable-extensions')

      Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
    end

    # Firefox alternative
    Capybara.register_driver :selenium_firefox do |app|
      options = Selenium::WebDriver::Firefox::Options.new

      if ENV['HEADLESS'] == 'true' || ENV['CI']
        options.add_argument('-headless')
      end

      Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
    end

    # Default driver
    Capybara.default_driver = :selenium_chrome
    Capybara.javascript_driver = :selenium_chrome

    # Configuration
    Capybara.default_max_wait_time = 10
    Capybara.app_host = ENV.fetch('APP_HOST', 'http://localhost:3000')
    Capybara.server_port = ENV.fetch('APP_PORT', 3000).to_i
  end

  # Take screenshot on failure
  def take_screenshot(name)
    return unless Capybara.current_driver == :selenium_chrome ||
                  Capybara.current_driver == :selenium_firefox

    screenshot_dir = Rails.root.join('tmp', 'screenshots')
    FileUtils.mkdir_p(screenshot_dir)

    timestamp = Time.now.strftime('%Y%m%d_%H%M%S')
    filename = "#{name}_#{timestamp}.png"
    filepath = screenshot_dir.join(filename)

    page.save_screenshot(filepath)
    puts "Screenshot saved: #{filepath}"
  end

  # Wait for element to be visible
  def wait_for_element(selector, timeout: 10)
    Timeout.timeout(timeout) do
      loop do
        break if page.has_selector?(selector, visible: true)
        sleep 0.1
      end
    end
  rescue Timeout::Error
    raise "Element '#{selector}' not found after #{timeout} seconds"
  end

  # Wait for page load
  def wait_for_page_load
    Timeout.timeout(30) do
      loop do
        ready_state = page.evaluate_script('document.readyState')
        break if ready_state == 'complete'
        sleep 0.1
      end
    end
  end

  # Accept alert if present
  def accept_alert_if_present
    page.driver.browser.switch_to.alert.accept
  rescue Selenium::WebDriver::Error::NoSuchAlertError
    # No alert present, continue
  end

  # Log test step
  def log_step(message)
    timestamp = Time.now.strftime('%H:%M:%S.%L')
    puts "[#{timestamp}] #{message}"
  end
end

# Configure Capybara on load
SeleniumHelper.configure_capybara
