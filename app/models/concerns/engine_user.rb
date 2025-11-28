# frozen_string_literal: true

# EngineUser Concern
#
# Base concern that provides a common interface for all engine-specific user extensions.
# This allows engines to dynamically extend the User model with their own associations
# and methods when the engine is activated.
#
# Usage:
#   class User < ApplicationRecord
#     include EngineUser
#
#     register_engine_concern('plebis_voting', EngineUser::Votable)
#     register_engine_concern('plebis_collaborations', EngineUser::Collaborator)
#   end
#
module EngineUser
  extend ActiveSupport::Concern

  included do
    # Hook que se ejecuta cuando se incluye el concern
    # Los engines pueden usar este hook para inicializar comportamientos comunes
  end

  class_methods do
    # Registers an engine-specific concern to be included in the User model
    # only if the engine is currently enabled AND all its dependencies are met.
    #
    # @param engine_name [String] The name of the engine (e.g., 'plebis_voting')
    # @param concern_module [Module] The concern module to include (e.g., EngineUser::Votable)
    #
    # @example
    #   register_engine_concern('plebis_voting', EngineUser::Votable)
    #
    def register_engine_concern(engine_name, concern_module)
      # In test environment, include all concerns by default
      # This ensures tests have access to all engine functionality
      if Rails.env.test?
        include concern_module
        Rails.logger.info "[EngineUser] Test mode: loaded #{engine_name} concern"
        return
      end

      # Check if EngineActivation exists before trying to use it
      # During initial migrations, this model might not exist yet
      return unless defined?(EngineActivation)
      return unless EngineActivation.table_exists?

      # Check if the engine is enabled
      return unless EngineActivation.enabled?(engine_name)

      # CRITICAL: Verify dependencies before including concern
      # This prevents NoMethodError when concerns call methods from other concerns
      if defined?(PlebisCore::EngineRegistry)
        deps = PlebisCore::EngineRegistry.dependencies_for(engine_name)
        missing_deps = deps.reject do |dep|
          dep == 'User' || EngineActivation.enabled?(dep)
        end

        if missing_deps.any?
          Rails.logger.error "[EngineUser] Cannot load #{engine_name}: missing dependencies #{missing_deps.join(', ')}"
          Rails.logger.error "[EngineUser] Enable these engines first: #{missing_deps.join(', ')}"
          return
        end
      end

      # All checks passed, include the concern
      include concern_module
      Rails.logger.info "[EngineUser] Successfully loaded #{engine_name} concern"

    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid => e
      # Database doesn't exist yet or table not created
      # This is expected during initial setup
      Rails.logger.warn "[EngineUser] Database not ready (#{e.class}), skipping #{engine_name}"
    end
  end

  # Common interface methods that all engine concerns can rely on
  # These methods should remain minimal and stable

  module_function

  # Returns whether this user can access a specific engine
  # Override this in your application if you have custom access control
  #
  # @param user [User] The user to check
  # @param engine_name [String] The engine name
  # @return [Boolean] Whether the user can access the engine
  #
  def can_access_engine?(user, engine_name)
    return false unless defined?(EngineActivation)

    EngineActivation.enabled?(engine_name)
  end
end
