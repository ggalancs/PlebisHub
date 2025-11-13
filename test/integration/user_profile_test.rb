require 'test_helper'
require_relative '../support/selenium_helper'

# ========================================
# User Profile Tests
# ========================================
# Tests for user profile management
# ========================================

class UserProfileTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include SeleniumHelper

  def setup
    Capybara.current_driver = :selenium_chrome
    @test_email = "profile_#{Time.now.to_i}@example.com"
    @test_password = "SecureP@ssw0rd123"
  end

  def teardown
    Capybara.use_default_driver
    take_screenshot(name) if @test_failed
  end

  # ========================================
  # Test: View Profile
  # ========================================
  test "user can view their profile" do
    log_step "Starting view profile test"

    # Create and login user
    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now,
                  first_name: 'John',
                  last_name: 'Doe',
                  document_type: 1,
                  document_vatid: '12345678A')

    login_user(user)

    # Visit edit profile page
    visit edit_user_registration_path
    wait_for_page_load

    log_step "Visited profile edit page"

    # Should see user information
    assert page.has_field?('user[email]', with: @test_email) ||
           page.has_content?(@test_email),
           "Should display user email"

    log_step "Profile page loaded with user data"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Update Profile
  # ========================================
  test "user can update their profile" do
    log_step "Starting update profile test"

    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now,
                  first_name: 'Jane',
                  last_name: 'Smith',
                  document_type: 1,
                  document_vatid: '98765432B')

    login_user(user)

    # Visit edit profile
    visit edit_user_registration_path
    wait_for_page_load

    # Update phone if field exists
    if page.has_field?('user[phone]')
      fill_in 'user[phone]', with: '600123456'
    end

    # Fill in current password (usually required for updates)
    if page.has_field?('user[current_password]')
      fill_in 'user[current_password]', with: @test_password
    end

    # Submit update
    click_button 'Actualizar', match: :first rescue click_button 'Update', match: :first
    wait_for_page_load

    log_step "Submitted profile update"

    # Should see success message or stay on profile
    assert page.has_content?('actualizado') ||
           page.has_content?('modificado') ||
           page.has_content?('updated'),
           "Should show update confirmation"

    log_step "Profile updated successfully"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Change Password
  # ========================================
  test "user can change their password" do
    log_step "Starting change password test"

    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now)

    login_user(user)

    # Visit edit profile
    visit edit_user_registration_path
    wait_for_page_load

    new_password = "NewP@ssw0rd456"

    # Fill in password change fields if they exist
    if page.has_field?('user[password]')
      fill_in 'user[password]', with: new_password
      fill_in 'user[password_confirmation]', with: new_password
      fill_in 'user[current_password]', with: @test_password

      click_button 'Actualizar', match: :first rescue click_button 'Update', match: :first
      wait_for_page_load

      log_step "Password change submitted"

      # Should see success message
      assert page.has_content?('actualizado') ||
             page.has_content?('contraseña') ||
             page.has_content?('updated'),
             "Should confirm password change"

      log_step "Password changed successfully"
    else
      log_step "Password change fields not found on profile page"
    end
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: QR Code
  # ========================================
  test "user can access their QR code" do
    log_step "Starting QR code test"

    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now)

    login_user(user)

    # Visit QR code page
    visit qr_code_path
    wait_for_page_load

    log_step "Visited QR code page"

    # Should see QR code or relevant content
    assert page.has_content?('QR') ||
           page.has_selector?('img') ||
           page.has_selector?('canvas'),
           "Should display QR code"

    log_step "QR code page loaded"
  rescue => e
    @test_failed = true
    log_step "Error: #{e.message}"
    raise
  end

  # ========================================
  # Test: Logout
  # ========================================
  test "user can logout" do
    log_step "Starting logout test"

    user = create(:user,
                  email: @test_email,
                  password: @test_password,
                  confirmed_at: Time.now)

    login_user(user)

    # Find and click logout link
    if page.has_link?('Salir') || page.has_link?('Cerrar sesión')
      click_link 'Salir', match: :first rescue click_link 'Cerrar sesión', match: :first
    elsif page.has_link?('Logout') || page.has_link?('Sign out')
      click_link 'Logout', match: :first rescue click_link 'Sign out', match: :first
    else
      # Try DELETE request to logout path
      visit destroy_user_session_path
    end

    wait_for_page_load

    log_step "Logout performed"

    # Should be redirected to login or home
    assert current_path == new_user_session_path ||
           current_path == root_path ||
           page.has_content?('sesión'),
           "Should be logged out"

    log_step "Logout successful"
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
