# frozen_string_literal: true

# EngineActivation Model
#
# Manages the activation state and configuration of engines in the application.
# Engines can be enabled/disabled, but requires application restart for concerns to load.
# Routes will reload automatically, but model concerns require: touch tmp/restart.txt
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
  validates :engine_name, format: {
    with: /\A[a-z][a-z0-9_]*\z/,
    message: "must start with a letter and contain only lowercase letters, numbers, and underscores"
  }
  validates :engine_name, length: { minimum: 3, maximum: 50 }
  validate :engine_must_exist_in_registry, on: :create

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
    # Use find_or_initialize_by to avoid race condition with find_or_create_by!
    activation = find_or_initialize_by(engine_name: engine_name)
    activation.enabled = true
    activation.save!
    clear_cache(engine_name)
    reload_routes!
    activation
  rescue ActiveRecord::RecordNotUnique
    # Race condition: another thread created the record, retry
    retry
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
  # NOTE: Routes are reloaded, but concerns require application restart.
  # After enabling/disabling engines, run: touch tmp/restart.txt
  # or restart your Rails server manually.
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
      # Use find_or_initialize_by to avoid race condition
      activation = find_or_initialize_by(engine_name: engine_name)

      if activation.new_record?
        info = PlebisCore::EngineRegistry.info(engine_name)
        activation.description = info[:description]
        activation.enabled = false # Disabled by default

        begin
          activation.save!
        rescue ActiveRecord::RecordNotUnique
          # Race condition: another process created it, skip
          Rails.logger.debug "[EngineActivation] #{engine_name} already seeded by another process"
        end
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

  private

  # Custom validation: ensure engine exists in registry
  # Only applies on create to allow seeding before registry is loaded
  #
  def engine_must_exist_in_registry
    return unless defined?(PlebisCore::EngineRegistry)

    available_engines = PlebisCore::EngineRegistry.available_engines
    unless available_engines.include?(engine_name)
      errors.add(:engine_name, "is not a registered engine. Available: #{available_engines.join(', ')}")
    end
  rescue => e
    # If registry fails to load, skip validation
    Rails.logger.warn "[EngineActivation] Could not validate engine_name against registry: #{e.message}"
  end
end
