require 'test_helper'
require_relative '../support/selenium_helper'

# ========================================
# Microcredit Flow Tests
# ========================================
# Tests for microcredit functionality
# ========================================

class MicrocreditFlowTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include SeleniumHelper

  def setup
    Capybara.current_driver = :selenium_chrome
    @test_email = "microcredit_#{Time.now.to_i}@example.com"
    @test_password = "SecureP@ssw0rd123"
  end

  def teardown
    Capybara.use_default_driver
    take_screenshot(name) if @test_failed
  end

  # ========================================
  # Test: View Microcredit Information
  # ========================================
  test "user can view microcredit information" do
    log_step "Starting microcredit information test"

    visit microcredit_path
    wait_for_page_load

    # Should see microcredit content
    assert page.has_content?('microcrédito') ||
           page.has_content?('Microcrédito') ||
           page.has_content?('préstamo'),
           "Should display microcredit information"

    log_step "Microcredit information page loaded successfully"

    # Check for information link
    if page.has_link?('información') || page.has_link?('Información')
      click_link 'información', match: :first rescue click_link 'Información', match: :first
      wait_for_page_load

      assert page.has_content?('microcrédito'),
             "Should display detailed information"
      log_step "Microcredit detailed information loaded"
    end
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Microcredit Registration Flow
  # ========================================
  test "authenticated user can access microcredit registration" do
    log_step "Starting microcredit registration test"

    # Create and login user
    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now,
                  first_name: 'Test',
                  last_name: 'Microcredit',
                  document_type: 1,
                  document_vatid: '12345678Z')

    login_user(user)

    # Visit microcredit page
    visit microcredit_path
    wait_for_page_load

    log_step "Visited microcredit page as authenticated user"

    # Look for registration or campaign links
    if page.has_selector?('a[href*="/microcreditos/"]')
      first('a[href*="/microcreditos/"]').click
      wait_for_page_load

      # Should be on a microcredit form or detail page
      assert current_path.include?('microcredito'),
             "Should navigate to microcredit detail"
      log_step "Navigated to microcredit detail page"
    end
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Microcredit Provinces and Towns
  # ========================================
  test "can load provinces and towns for microcredit" do
    log_step "Starting provinces/towns test"

    visit microcredit_path
    wait_for_page_load

    # Test provinces endpoint
    visit '/es/microcreditos/provincias'
    assert page.status_code == 200 || page.has_content?('provincia'),
           "Provinces endpoint should respond"
    log_step "Provinces endpoint working"

    # Test towns endpoint
    visit '/es/microcreditos/municipios'
    assert page.status_code == 200,
           "Towns endpoint should respond"
    log_step "Towns endpoint working"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  private

  def login_user(user)
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: @test_password
    click_button 'Entrar', match: :first rescue click_button 'Log in', match: :first
    wait_for_page_load
  end
end
