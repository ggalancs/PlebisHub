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
    # only if the engine is currently enabled.
    #
    # @param engine_name [String] The name of the engine (e.g., 'plebis_voting')
    # @param concern_module [Module] The concern module to include (e.g., EngineUser::Votable)
    #
    # @example
    #   register_engine_concern('plebis_voting', EngineUser::Votable)
    #
    def register_engine_concern(engine_name, concern_module)
      # Check if EngineActivation exists before trying to use it
      # During initial migrations, this model might not exist yet
      if defined?(EngineActivation) && EngineActivation.table_exists?
        include concern_module if EngineActivation.enabled?(engine_name)
      end
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
      # Database doesn't exist yet or table not created
      # This is expected during initial setup
      Rails.logger.debug "[EngineUser] Database not ready, skipping engine concern registration for #{engine_name}"
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
