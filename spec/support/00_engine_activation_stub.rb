# frozen_string_literal: true

# EngineActivation stub configuration for tests
#
# The actual stub class is defined in rails_helper.rb BEFORE Rails loads.
# This is necessary because routes check EngineActivation.enabled? during initialization.
#
# After Rails loads, rails_helper.rb removes the stub and loads the real model.
# Individual tests can stub EngineActivation.enabled? as needed.
#
# Note: We don't stub globally here because RSpec mocks don't work outside individual tests.
# Tests that need EngineActivation to return specific values should stub in their before blocks.
