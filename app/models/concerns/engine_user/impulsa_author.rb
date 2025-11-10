# frozen_string_literal: true

module EngineUser
  # ImpulsaAuthor Concern
  #
  # Extends User model with Impulsa project-related methods.
  # This concern is loaded when the plebis_impulsa engine is active.
  #
  # Impulsa is a citizen project submission and evaluation platform.
  #
  module ImpulsaAuthor
    extend ActiveSupport::Concern

    included do
      # Note: ImpulsaProject has author_id field
      # We don't define has_many here to avoid coupling
      # The relationship is managed through the engine
    end

    # Check if user is an Impulsa author
    # Uses the impulsa_author flag
    #
    # @return [Boolean] Whether user is an Impulsa author
    #
    def impulsa_author?
      self.impulsa_author
    end
  end
end
