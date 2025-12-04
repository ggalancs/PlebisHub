# frozen_string_literal: true

# Stub EngineActivation to enable all engines in tests
# This file is loaded early (00_ prefix) so it happens before Rails loads engine routes

# Only define the stub if EngineActivation hasn't been loaded yet
unless defined?(EngineActivation)
  class EngineActivation
    def self.enabled?(_engine_name)
      true
    end

    def self.active?(_engine_name)
      true
    end
  end
end
