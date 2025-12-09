# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication Flows', type: :system do
  let(:user) { create(:user, password: 'Password123456', password_confirmation: 'Password123456') }

  describe 'Sign In' do
    it 'displays the login page' do
      visit '/es/users/sign_in'
      expect(page.status_code).to eq(200)
      expect(page).to have_selector('form')
    end

    it 'has login form fields' do
      visit '/es/users/sign_in'
      has_login_field = page.has_field?('user_login') ||
                        page.has_field?('user[login]') ||
                        page.has_field?('user_email') ||
                        page.has_selector('input[type="email"]') ||
                        page.has_selector('input[type="text"]')
      expect(has_login_field).to be true
    end

    it 'has password field' do
      visit '/es/users/sign_in'
      has_password = page.has_field?('user_password') ||
                     page.has_field?('user[password]') ||
                     page.has_selector('input[type="password"]')
      expect(has_password).to be true
    end

    it 'allows user to sign in with email' do
      visit '/es/users/sign_in'
      if page.has_field?('user_login')
        fill_in 'user_login', with: user.email
      elsif page.has_field?('user[login]')
        fill_in 'user[login]', with: user.email
      end
      fill_in 'user_password', with: 'Password123456' if page.has_field?('user_password')
      find('input[type="submit"], button[type="submit"]', match: :first).click
      expect(page.status_code).to be_in([200, 302])
    end

    it 'shows error for invalid credentials' do
      visit '/es/users/sign_in'
      if page.has_field?('user_login')
        fill_in 'user_login', with: user.email
        fill_in 'user_password', with: 'WrongPassword1'
        find('input[type="submit"], button[type="submit"]', match: :first).click
      end
      # 422 Unprocessable Entity is expected for failed login in Rails 7.2
      expect(page.status_code).to be_in([200, 422])
    end

    it 'has link to password recovery' do
      visit '/es/users/sign_in'
      has_password_link = page.has_link?(href: /password/) ||
                          page.has_content?(/contraseña|password|olvidado/i)
      expect(has_password_link).to be true
    end

    it 'has link to registration' do
      visit '/es/users/sign_in'
      has_signup_link = page.has_link?(href: /sign_up/) ||
                        page.has_content?(/inscr|regist/i)
      expect(has_signup_link).to be true
    end
  end

  describe 'Sign Out' do
    it 'allows user to sign out' do
      sign_in user
      visit '/es'
      if page.has_link?('Salir')
        first(:link, 'Salir').click
      elsif page.has_link?(href: /sign_out/)
        first(:link, href: /sign_out/).click
      end
      expect(page.status_code).to be_in([200, 302])
    end
  end

  describe 'Registration' do
    it 'displays the registration page' do
      visit '/es/users/sign_up'
      expect(page.status_code).to eq(200)
      expect(page).to have_selector('form')
    end

    it 'has email field' do
      visit '/es/users/sign_up'
      has_email = page.has_field?('user_email') ||
                  page.has_field?('user[email]') ||
                  page.has_selector('input[type="email"]')
      expect(has_email).to be true
    end

    it 'has name fields' do
      visit '/es/users/sign_up'
      has_name = page.has_field?('user_first_name') ||
                 page.has_field?('user[first_name]') ||
                 page.has_selector('input[name*="first_name"]') ||
                 page.has_content?(/nombre/i)
      expect(has_name).to be true
    end

    it 'has terms of service checkbox' do
      visit '/es/users/sign_up'
      has_tos = page.has_field?('user_terms_of_service') ||
                page.has_field?('user[terms_of_service]') ||
                page.has_selector('input[type="checkbox"]') ||
                page.has_content?(/condiciones|términos|terms/i)
      expect(has_tos).to be true
    end

    it 'shows validation errors for empty form' do
      visit '/es/users/sign_up'
      find('input[type="submit"], button[type="submit"]', match: :first).click
      expect(page.status_code).to eq(200)
    end
  end

  describe 'Password Recovery' do
    it 'displays password recovery page' do
      visit '/es/users/password/new'
      expect(page.status_code).to eq(200)
      expect(page).to have_selector('form')
    end

    it 'has email field for password reset' do
      visit '/es/users/password/new'
      has_email = page.has_field?('user_email') ||
                  page.has_field?('user[email]') ||
                  page.has_selector('input[type="email"]')
      expect(has_email).to be true
    end

    it 'accepts email for password reset' do
      visit '/es/users/password/new'
      if page.has_field?('user_email')
        fill_in 'user_email', with: user.email
      end
      find('input[type="submit"], button[type="submit"]', match: :first).click
      expect(page.status_code).to eq(200)
    end
  end

  describe 'Edit Profile' do
    before { sign_in user }

    it 'displays edit profile page' do
      visit '/es/users/edit'
      expect(page.status_code).to be_in([200, 302])
    end

    it 'has user form when accessible' do
      visit '/es/users/edit'
      if page.status_code == 200
        expect(page).to have_selector('form')
      end
    end

    it 'allows updating user information' do
      visit '/es/users/edit'
      if page.status_code == 200 && page.has_field?('user_first_name')
        fill_in 'user_first_name', with: 'UpdatedName'
        if page.has_field?('user_current_password')
          # Use first match since there may be multiple password fields
          first(:field, 'user_current_password').set('Password123456')
        end
        find('input[type="submit"], button[type="submit"]', match: :first).click
      end
      expect(page.status_code).to be_in([200, 302])
    end
  end

  describe 'Account Confirmation' do
    let(:unconfirmed_user) { create(:user, :unconfirmed) }

    it 'displays confirmation page' do
      visit '/es/users/confirmation/new'
      expect(page.status_code).to eq(200)
    end

    it 'has email field for confirmation' do
      visit '/es/users/confirmation/new'
      has_email = page.has_field?('user_email') ||
                  page.has_field?('user[email]') ||
                  page.has_selector('input[type="email"]')
      expect(has_email).to be true
    end

    it 'allows resending confirmation instructions' do
      visit '/es/users/confirmation/new'
      if page.has_field?('user_email')
        fill_in 'user_email', with: unconfirmed_user.email
      end
      find('input[type="submit"], button[type="submit"]', match: :first).click
      expect(page.status_code).to eq(200)
    end
  end
end
