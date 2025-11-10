# frozen_string_literal: true

# EngineActivation Model
#
# Manages the activation state and configuration of engines in the application.
# Engines can be enabled/disabled dynamically without redeployment.
#
# Attributes:
#   - engine_name: String - Unique identifier for the engine
#   - enabled: Boolean - Whether the engine is currently active
#   - configuration: JSON - Engine-specific configuration
#   - description: Text - Human-readable description
#   - load_priority: Integer - Loading order (lower loads first)
#
# Usage:
#   EngineActivation.enabled?('plebis_cms')
#   EngineActivation.enable!('plebis_cms')
#   EngineActivation.disable!('plebis_cms')
#
class EngineActivation < ApplicationRecord
  # Validations
  validates :engine_name, presence: true, uniqueness: true

  # Cache para evitar queries repetidas
  # @param engine_name [String] The engine name to check
  # @return [Boolean] Whether the engine is enabled
  #
  def self.enabled?(engine_name)
    Rails.cache.fetch("engine_activation:#{engine_name}", expires_in: 5.minutes) do
      exists?(engine_name: engine_name, enabled: true)
    end
  rescue => e
    # If cache or database fails, assume disabled for safety
    Rails.logger.error "[EngineActivation] Error checking if #{engine_name} is enabled: #{e.message}"
    false
  end

  # Enable an engine
  # @param engine_name [String] The engine name to enable
  # @return [EngineActivation] The activation record
  #
  def self.enable!(engine_name)
    activation = find_or_create_by!(engine_name: engine_name)
    activation.update!(enabled: true)
    clear_cache(engine_name)
    reload_routes!
    activation
  end

  # Disable an engine
  # @param engine_name [String] The engine name to disable
  # @return [EngineActivation, nil] The activation record or nil if not found
  #
  def self.disable!(engine_name)
    activation = find_by(engine_name: engine_name)
    return nil unless activation

    activation.update!(enabled: false)
    clear_cache(engine_name)
    reload_routes!
    activation
  end

  # Clear cache for a specific engine
  # @param engine_name [String] The engine name
  #
  def self.clear_cache(engine_name)
    Rails.cache.delete("engine_activation:#{engine_name}")
  rescue => e
    Rails.logger.error "[EngineActivation] Error clearing cache for #{engine_name}: #{e.message}"
  end

  # Reload application routes
  # This allows dynamic engine loading without server restart
  #
  def self.reload_routes!
    Rails.application.reload_routes!
    Rails.logger.info "[EngineActivation] Routes reloaded"
  rescue => e
    Rails.logger.error "[EngineActivation] Failed to reload routes: #{e.message}"
  end

  # Seed all engines from registry
  # Creates disabled activation records for all available engines
  #
  def self.seed_all
    return unless defined?(PlebisCore::EngineRegistry)

    PlebisCore::EngineRegistry.available_engines.each do |engine_name|
      find_or_create_by!(engine_name: engine_name) do |ea|
        info = PlebisCore::EngineRegistry.info(engine_name)
        ea.description = info[:description]
        ea.enabled = false # Disabled by default
      end
    end
  rescue => e
    Rails.logger.error "[EngineActivation] Error seeding engines: #{e.message}"
  end

  # Get configuration value for a key
  # @param key [String, Symbol] The configuration key
  # @param default [Object] Default value if key not found
  # @return [Object] The configuration value
  #
  def config(key, default = nil)
    configuration.fetch(key.to_s, default)
  end

  # Set configuration value
  # @param key [String, Symbol] The configuration key
  # @param value [Object] The value to set
  #
  def set_config(key, value)
    self.configuration = configuration.merge(key.to_s => value)
    save
  end

  # Check if engine can be enabled based on dependencies
  # @return [Boolean] Whether the engine can be enabled
  #
  def can_enable?
    return true unless defined?(PlebisCore::EngineRegistry)

    PlebisCore::EngineRegistry.can_enable?(engine_name)
  end

  # Human-readable status
  # @return [String] Status string
  #
  def status
    enabled? ? "Active" : "Inactive"
  end
end
