# frozen_string_literal: true

# Admin Authentication Helper for Request Specs
#
# This helper ensures admin users are properly authenticated in request specs
# by bypassing the authenticate_admin_user! filter that would otherwise redirect.

module AdminAuthenticationHelper
  # Sign in an admin user for request specs
  # Uses Devise's sign_in and stubs authentication method
  def sign_in_admin(user)
    # Use Devise's sign_in helper for request specs
    sign_in user

    # Stub the authenticate_admin_user! method on both ApplicationController
    # and ActiveAdmin::ResourceController (which all admin controllers inherit from)
    [ApplicationController, ActiveAdmin::ResourceController].each do |klass|
      allow_any_instance_of(klass)
        .to receive(:authenticate_admin_user!).and_return(true)

      # Also stub current_admin_user for ActiveAdmin
      allow_any_instance_of(klass)
        .to receive(:current_admin_user).and_return(user)
    end
  end
end

RSpec.configure do |config|
  config.include AdminAuthenticationHelper, type: :request

  # For admin request specs, set up Warden test mode
  config.before(:each, type: :request) do |example|
    # Check if this is an admin spec by looking at the file path
    if example.metadata[:file_path]&.include?('spec/admin/')
      # Enable Warden test mode for all admin specs
      Warden.test_mode!
    end
  end

  config.after(:each, type: :request) do |example|
    if example.metadata[:file_path]&.include?('spec/admin/')
      Warden.test_reset!
    end
  end
end
