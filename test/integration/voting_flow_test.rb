require 'test_helper'
require_relative '../support/selenium_helper'

# ========================================
# Voting Flow Tests
# ========================================
# Tests for voting/elections functionality
# ========================================

class VotingFlowTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include SeleniumHelper

  def setup
    Capybara.current_driver = :selenium_chrome
    @test_email = "voter_#{Time.now.to_i}@example.com"
    @test_password = "SecureP@ssw0rd123"
  end

  def teardown
    Capybara.use_default_driver
    take_screenshot(name) if @test_failed
  end

  # ========================================
  # Test: SMS Verification Flow
  # ========================================
  test "authenticated user can access SMS verification" do
    log_step "Starting SMS verification test"

    # Create and login user
    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now,
                  first_name: 'Test',
                  last_name: 'Voter',
                  document_type: 1,
                  document_vatid: '22334455Z')

    login_user(user)

    # Visit SMS validator step 1
    visit sms_validator_step1_path
    wait_for_page_load

    log_step "Visited SMS validator step 1"

    # Should see SMS validation form
    assert page.has_content?('teléfono') ||
           page.has_content?('SMS') ||
           page.has_content?('verificación'),
           "Should display SMS verification page"

    log_step "SMS verification page loaded"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Identity Verification
  # ========================================
  test "authenticated user can access identity verification" do
    log_step "Starting identity verification test"

    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now,
                  first_name: 'Test',
                  last_name: 'Identity',
                  document_type: 1,
                  document_vatid: '66778899Z')

    login_user(user)

    # Visit identity verification
    visit new_user_verification_path
    wait_for_page_load

    log_step "Visited identity verification page"

    # Should see verification form
    assert page.has_content?('verificación') ||
           page.has_content?('identidad') ||
           page.has_content?('documento'),
           "Should display identity verification page"

    log_step "Identity verification page loaded"
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
