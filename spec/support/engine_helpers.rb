# frozen_string_literal: true

# Engine Test Helpers
#
# Utilities for testing engine activation and behavior
#
module EngineHelpers
  # Temporarily enable an engine for the duration of a test
  #
  # @param engine_name [String] The engine name to enable
  # @yield Block to execute with engine enabled
  #
  # Example:
  #   with_engine_enabled('plebis_cms') do
  #     # Test code that requires CMS engine
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
