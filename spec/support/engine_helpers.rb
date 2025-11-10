# frozen_string_literal: true

# Engine Test Helpers
#
# Utilities for testing engine activation and behavior
#
# IMPORTANT LIMITATIONS:
# ----------------------
# These helpers change the activation STATUS in the database, but they
# CANNOT dynamically load/unload concerns at runtime.
#
# WHY: ActiveSupport::Concern modules are included at class definition time
# (when the User class is first loaded), not at runtime. Once a concern is
# included, it cannot be removed without reloading the entire class.
#
# WHAT THIS MEANS FOR TESTS:
# - These helpers are useful for testing ROUTES and CONTROLLERS (which check enabled?)
# - These helpers CANNOT test model concerns being added/removed dynamically
# - If you need to test concerns, separate your test suite by engine and
#   use shared_contexts like "with all engines disabled" to set initial state
#   BEFORE the test suite loads
#
# CORRECT USAGE:
#   # Testing routes (works correctly)
#   with_engine_enabled('plebis_cms') do
#     expect(get: '/blog').to route_to(controller: 'blog', action: 'index')
#   end
#
# INCORRECT USAGE:
#   # Testing concerns (does NOT work as expected)
#   with_engine_enabled('plebis_voting') do
#     user = User.new
#     user.votes # This will fail if concern wasn't loaded at class definition time
#   end
#
module EngineHelpers
  # Temporarily enable an engine for the duration of a test
  #
  # WARNING: This only changes the database state. It does NOT load concerns.
  # Use for testing routes/controllers, not for testing model concerns.
  #
  # @param engine_name [String] The engine name to enable
  # @yield Block to execute with engine enabled
  #
  # Example:
  #   with_engine_enabled('plebis_cms') do
  #     # Test routes/controllers (works correctly)
  #     get '/blog'
  #     expect(response).to be_successful
  #   end
  #
  def with_engine_enabled(engine_name)
    original_state = EngineActivation.enabled?(engine_name)

    begin
      EngineActivation.enable!(engine_name) unless original_state
      yield
    ensure
      EngineActivation.disable!(engine_name) unless original_state
    end
  end

  # Temporarily disable an engine for the duration of a test
  #
  # WARNING: This only changes the database state. It does NOT unload concerns.
  # Use for testing routes/controllers, not for testing model concerns.
  #
  # @param engine_name [String] The engine name to disable
  # @yield Block to execute with engine disabled
  #
  def with_engine_disabled(engine_name)
    original_state = EngineActivation.enabled?(engine_name)

    begin
      EngineActivation.disable!(engine_name) if original_state
      yield
    ensure
      EngineActivation.enable!(engine_name) if original_state
    end
  end

  # Check if an engine is enabled
  #
  # @param engine_name [String] The engine name
  # @return [Boolean] Whether the engine is enabled
  #
  def engine_enabled?(engine_name)
    EngineActivation.enabled?(engine_name)
  end

  # Create an engine activation for testing
  #
  # @param engine_name [String] The engine name
  # @param enabled [Boolean] Whether to enable it
  # @param config [Hash] Configuration options
  # @return [EngineActivation] The created activation
  #
  def create_engine_activation(engine_name, enabled: false, config: {})
    EngineActivation.create!(
      engine_name: engine_name,
      enabled: enabled,
      configuration: config
    )
  end
end

RSpec.configure do |config|
  config.include EngineHelpers, type: :model
  config.include EngineHelpers, type: :controller
  config.include EngineHelpers, type: :request
  config.include EngineHelpers, type: :feature
end
