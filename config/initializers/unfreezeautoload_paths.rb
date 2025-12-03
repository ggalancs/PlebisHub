# frozen_string_literal: true

# Rails 7.2 Autoload Paths Fix
#
# Problem: Rails 7.2 freezes autoload_paths after initialization, but some legacy
# engines (esendex, inherited_resources, etc.) attempt to modify these paths during
# their initialization, causing FrozenError.
#
# Solution: Monkey-patch Array#freeze to prevent autoload_paths from being frozen
# in test environment. This allows legacy engines to modify paths as needed.
#
# This is a temporary workaround for gems that haven't been updated for Rails 7.2.
#
if Rails.env.test?
  # Store original freeze method
  Array.class_eval do
    alias_method :original_freeze, :freeze

    def freeze
      # Don't freeze if this is an autoload_paths, eager_load_paths, or helpers array
      # This prevents FrozenError when ActionText or other engines try to modify these
      if caller.any? { |line|
        line.include?('rails/engine.rb') ||
        line.include?('rails/application') ||
        line.include?('actiontext') ||
        line.include?('autoload_paths') ||
        line.include?('eager_load_paths')
      }
        # Return self without freezing to prevent FrozenError
        self
      else
        original_freeze
      end
    end
  end
end
