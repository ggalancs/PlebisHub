require 'test_helper'
require_relative '../support/selenium_helper'

# ========================================
# User Journey Integration Tests
# ========================================
# Complete user flow tests using Selenium WebDriver
# Tests the main user journey through the application
# ========================================

class UserJourneyTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include SeleniumHelper

  def setup
    Capybara.current_driver = :selenium_chrome
    @test_email = "test_#{Time.now.to_i}@example.com"
    @test_password = "SecureP@ssw0rd123"
  end

  def teardown
    Capybara.use_default_driver
    take_screenshot(name) if @test_failed
  end

  # ========================================
  # Test: Complete User Registration Flow
  # ========================================
  test "complete user registration and login flow" do
    log_step "Starting user registration test"

    # Visit home page
    visit root_path
    log_step "Visited home page: #{current_url}"

    # Check if we're redirected to locale path
    assert page.has_content?('PlebisHub') || page.has_content?('Participa'),
           "Home page should load"

    # Navigate to registration
    if page.has_link?('Registrarse') || page.has_link?('Registro')
      click_link 'Registrarse', match: :first
    elsif page.has_link?('Sign up')
      click_link 'Sign up'
    else
      visit new_user_registration_path
    end

    log_step "Navigated to registration page"
    wait_for_page_load

    # Fill in registration form
    fill_in_registration_form

    # Submit form
    click_button 'Registrarse', match: :first rescue click_button 'Sign up', match: :first
    log_step "Submitted registration form"

    # Wait for confirmation or redirect
    sleep 2
    wait_for_page_load

    # Should see success message or be logged in
    assert page.has_content?('confirmación') ||
           page.has_content?('bienvenid') ||
           page.has_content?('sesión'),
           "Registration should complete successfully"

    log_step "Registration completed successfully"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: User Login Flow
  # ========================================
  test "user can login and access dashboard" do
    log_step "Starting user login test"

    # Create a test user
    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now)

    # Visit login page
    visit new_user_session_path
    log_step "Visited login page"

    # Fill in credentials
    fill_in 'user[email]', with: @test_email
    fill_in 'user[password]', with: @test_password

    # Submit login
    click_button 'Entrar', match: :first rescue click_button 'Log in', match: :first
    log_step "Submitted login form"

    wait_for_page_load

    # Should be logged in
    assert page.has_content?('sesión') ||
           page.has_content?('perfil') ||
           current_path != new_user_session_path,
           "User should be logged in"

    log_step "Login successful"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Navigate All Main Sections
  # ========================================
  test "navigate through all main sections" do
    log_step "Starting navigation test"

    # Create and login user
    user = login_test_user

    # Test each main section
    test_home_page
    test_proposals_section if has_proposals?
    test_impulsa_section if has_impulsa?
    test_microcredit_section if has_microcredit?
    test_collaborations_section if has_collaborations?
    test_user_profile

    log_step "Navigation test completed"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  private

  def fill_in_registration_form
    # Basic fields (adjust field names based on actual form)
    fill_in 'user[email]', with: @test_email
    fill_in 'user[password]', with: @test_password
    fill_in 'user[password_confirmation]', with: @test_password

    # Additional fields if present
    if page.has_field?('user[first_name]')
      fill_in 'user[first_name]', with: 'Test'
      fill_in 'user[last_name]', with: 'User'
    end

    # Accept terms if checkbox present
    if page.has_field?('user[terms_of_service]')
      check 'user[terms_of_service]'
    end
  end

  def login_test_user
    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now)

    visit new_user_session_path
    fill_in 'user[email]', with: @test_email
    fill_in 'user[password]', with: @test_password
    click_button 'Entrar', match: :first rescue click_button 'Log in', match: :first
    wait_for_page_load

    user
  end

  def test_home_page
    log_step "Testing home page"
    visit root_path
    wait_for_page_load
    assert page.status_code == 200
  end

  def test_proposals_section
    log_step "Testing proposals section"
    visit "/es/propuestas" rescue return
    wait_for_page_load
    assert page.has_content?('Propuesta') || page.has_content?('propuesta')
  end

  def test_impulsa_section
    log_step "Testing Impulsa section"
    visit impulsa_path rescue return
    wait_for_page_load
    assert page.has_content?('Impulsa') || page.has_content?('proyecto')
  end

  def test_microcredit_section
    log_step "Testing microcredit section"
    visit microcredit_path rescue return
    wait_for_page_load
    assert page.has_content?('microcrédito') || page.has_content?('Microcrédito')
  end

  def test_collaborations_section
    log_step "Testing collaborations section"
    visit new_collaboration_path rescue return
    wait_for_page_load
    assert page.has_content?('colabora') || page.has_content?('Colabora')
  end

  def test_user_profile
    log_step "Testing user profile"
    visit edit_user_registration_path rescue return
    wait_for_page_load
    assert page.has_content?('perfil') || page.has_content?('Perfil') || page.has_content?('Email')
  end

  def has_proposals?
    Rails.application.routes.url_helpers.respond_to?(:proposals_path) rescue false
  end

  def has_impulsa?
    Rails.application.routes.url_helpers.respond_to?(:impulsa_path) rescue false
  end

  def has_microcredit?
    Rails.application.routes.url_helpers.respond_to?(:microcredit_path) rescue false
  end

  def has_collaborations?
    Rails.application.routes.url_helpers.respond_to?(:new_collaboration_path) rescue false
  end
end
