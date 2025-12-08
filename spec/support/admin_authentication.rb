# frozen_string_literal: true

# Admin Authentication Helper for Request Specs
#
# This helper provides a simple sign_in_admin method that just uses Devise's sign_in
# The user should be created with the proper admin flags for the test.

module AdminAuthenticationHelper
  # Sign in an admin user for request specs
  # Uses Devise's sign_in method to authenticate
  # Note: Warden test mode is already configured in spec/support/request_helpers.rb
  def sign_in_admin(user)
    sign_in user
  end
end

RSpec.configure do |config|
  config.include AdminAuthenticationHelper, type: :request
end
