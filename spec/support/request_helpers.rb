# frozen_string_literal: true

# Request Spec Helpers
#
# Provides helper methods for request specs to handle authentication
# and bypass filters that interfere with testing

module RequestHelpers
  # Sign in a user for authenticated request specs
  # Usage: sign_in_for_request_spec(user)
  def sign_in_for_request_spec(user)
    post user_session_path, params: {
      user: { email: user.email, password: user.password }
    }
    follow_redirect! if response.status == 302
  end

  # Bypass rescue to see full error traces
  def bypass_rescue
    Rails.application.env_config['action_dispatch.show_exceptions'] = :none
  end

  # Create and sign in a test user
  def create_and_sign_in_user
    user = FactoryBot.create(:user)
    sign_in user
    user
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :request

  # For request specs, create and sign in a default user to bypass authentication
  # This prevents 302 redirects to login pages for public pages
  config.before(:each, type: :request) do |example|
    # Enable Warden test mode
    Warden.test_mode!

    # Create and sign in a user by default unless explicitly skipped
    unless example.metadata[:skip_auth]
      begin
        # Create a fully validated user to avoid unresolved_issues redirects
        user = FactoryBot.create(:user,
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          confirmed_at: Time.current,
          sms_confirmed_at: Time.current,
          born_at: 25.years.ago,
          # Set required location fields to avoid location validation issues
          town: '28001',  # Valid Madrid postal code
          province: 'Madrid',
          country: 'ES',
          # Skip legacy password check
          has_legacy_password: false
        )
        sign_in user
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        # If user already exists, just sign in
        user = User.find_by(email: 'test@example.com')
        if user
          # Update user to ensure all required fields are set
          user.update_columns(
            sms_confirmed_at: Time.current,
            confirmed_at: Time.current,
            born_at: 25.years.ago,
            town: '28001',
            province: 'Madrid',
            country: 'ES',
            has_legacy_password: false
          )
          sign_in user
        end
      end
    end
  end

  config.after(:each, type: :request) do
    Warden.test_reset!
  end
end
