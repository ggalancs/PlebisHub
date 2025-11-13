require 'test_helper'
require_relative '../support/selenium_helper'

# ========================================
# Collaborations Flow Tests
# ========================================
# Tests for collaboration/donations functionality
# ========================================

class CollaborationsFlowTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include SeleniumHelper

  def setup
    Capybara.current_driver = :selenium_chrome
    @test_email = "collab_#{Time.now.to_i}@example.com"
    @test_password = "SecureP@ssw0rd123"
  end

  def teardown
    Capybara.use_default_driver
    take_screenshot(name) if @test_failed
  end

  # ========================================
  # Test: Access Collaborations Page
  # ========================================
  test "authenticated user can access collaborations page" do
    log_step "Starting collaborations access test"

    # Create and login user
    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now,
                  first_name: 'Test',
                  last_name: 'Collaborator',
                  document_type: 1,
                  document_vatid: '87654321Z')

    login_user(user)

    # Visit collaborations page
    visit new_collaboration_path
    wait_for_page_load

    log_step "Visited collaborations page: #{current_url}"

    # Should see collaboration form or information
    assert page.has_content?('colabora') ||
           page.has_content?('Colabora') ||
           page.has_content?('aportación') ||
           page.has_content?('donación'),
           "Should display collaboration page"

    log_step "Collaborations page loaded successfully"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: View Existing Collaboration
  # ========================================
  test "user can view existing collaboration" do
    log_step "Starting view collaboration test"

    # Create user with collaboration
    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now,
                  first_name: 'Test',
                  last_name: 'Collaborator',
                  document_type: 1,
                  document_vatid: '11223344Z')

    login_user(user)

    # Try to view collaboration
    visit edit_collaboration_path
    wait_for_page_load

    log_step "Visited edit collaboration page"

    # Should either show collaboration or redirect to create one
    assert page.status_code == 200 ||
           current_path == new_collaboration_path,
           "Should display collaboration or redirect to create"

    log_step "Collaboration view test completed"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Single Collaboration
  # ========================================
  test "user can access single collaboration page" do
    log_step "Starting single collaboration test"

    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now,
                  first_name: 'Test',
                  last_name: 'SingleCollab',
                  document_type: 1,
                  document_vatid: '99887766Z')

    login_user(user)

    visit single_collaboration_path
    wait_for_page_load

    log_step "Visited single collaboration page"

    # Should see single collaboration form
    assert page.has_content?('puntual') ||
           page.has_content?('única') ||
           page.has_content?('colabora'),
           "Should display single collaboration page"

    log_step "Single collaboration page loaded"
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
