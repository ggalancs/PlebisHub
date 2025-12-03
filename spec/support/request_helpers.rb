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

  # Enable Warden test mode for request specs
  config.before(:each, type: :request) do
    Warden.test_mode!
  end

  config.after(:each, type: :request) do
    Warden.test_reset!
  end
end
