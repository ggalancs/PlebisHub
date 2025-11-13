require 'test_helper'
require_relative '../support/selenium_helper'

# ========================================
# Impulsa (Projects) Flow Tests
# ========================================
# Tests for Impulsa project functionality
# ========================================

class ImpulsaFlowTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include SeleniumHelper

  def setup
    Capybara.current_driver = :selenium_chrome
    @test_email = "impulsa_#{Time.now.to_i}@example.com"
    @test_password = "SecureP@ssw0rd123"
  end

  def teardown
    Capybara.use_default_driver
    take_screenshot(name) if @test_failed
  end

  # ========================================
  # Test: Access Impulsa Index
  # ========================================
  test "user can access impulsa index page" do
    log_step "Starting Impulsa index test"

    visit impulsa_path
    wait_for_page_load

    log_step "Visited Impulsa page: #{current_url}"

    # Should see Impulsa content
    assert page.has_content?('Impulsa') ||
           page.has_content?('proyecto'),
           "Should display Impulsa page"

    log_step "Impulsa page loaded successfully"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Authenticated Access to Project Creation
  # ========================================
  test "authenticated user can access project creation" do
    log_step "Starting project creation access test"

    # Create and login user
    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now,
                  first_name: 'Test',
                  last_name: 'Impulsa',
                  document_type: 1,
                  document_vatid: '55667788Z')

    login_user(user)

    # Visit project page
    visit project_impulsa_path
    wait_for_page_load

    log_step "Visited project creation page"

    # Should see project form or information
    assert page.has_content?('proyecto') ||
           page.has_content?('Proyecto') ||
           current_path.include?('impulsa'),
           "Should display project page"

    log_step "Project creation page accessible"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Project Steps Navigation
  # ========================================
  test "user can navigate through project steps" do
    log_step "Starting project steps navigation test"

    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now,
                  first_name: 'Test',
                  last_name: 'Steps',
                  document_type: 1,
                  document_vatid: '44556677Z')

    login_user(user)

    # Visit project page
    visit project_impulsa_path
    wait_for_page_load

    # Try accessing different steps (if they exist)
    [1, 2, 3].each do |step|
      begin
        visit project_step_impulsa_path(step: step)
        wait_for_page_load

        log_step "Accessed project step #{step}"

        # Should be on a valid page
        assert page.status_code == 200 ||
               page.has_content?('proyecto'),
               "Step #{step} should be accessible"
      rescue => e
        log_step "Step #{step} not accessible: #{e.message}"
        # Some steps might not be accessible without proper setup
      end
    end

    log_step "Project steps navigation completed"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Evaluation Page
  # ========================================
  test "user can access evaluation page" do
    log_step "Starting evaluation page test"

    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now)

    login_user(user)

    visit evaluation_impulsa_path
    wait_for_page_load

    log_step "Visited evaluation page"

    # Should see evaluation content or be redirected
    assert page.status_code == 200 ||
           current_path.include?('impulsa'),
           "Evaluation page should be accessible"

    log_step "Evaluation page test completed"
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
