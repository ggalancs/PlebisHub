# frozen_string_literal: true

# Controller Test Helpers
#
# Provides helper methods to bypass ApplicationController filters
# that can interfere with testing

RSpec.configure do |config|
  # For request specs, stub out problematic ApplicationController before_actions
  # This prevents redirects caused by user validation issues
  config.before(:each, type: :request) do
    # Stub the problematic before_actions to prevent redirects
    allow_any_instance_of(ApplicationController).to receive(:unresolved_issues).and_return(nil)
    allow_any_instance_of(ApplicationController).to receive(:banned_user).and_return(nil)
    allow_any_instance_of(ApplicationController).to receive(:admin_logger).and_return(nil)
  end
end
