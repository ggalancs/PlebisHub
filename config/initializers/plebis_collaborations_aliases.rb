# frozen_string_literal: true

# Backward compatibility aliases for PLEBIS_COLLABORATIONS engine
# These aliases allow existing code to reference models without the namespace
# After full migration, these can be removed

# Wrap in to_prepare to ensure classes are loaded after initialization
Rails.application.config.to_prepare do
  # Models
  Object.const_set(:Collaboration, PlebisCollaborations::Collaboration) unless defined?(Collaboration)
  Object.const_set(:Order, PlebisCollaborations::Order) unless defined?(Order)

  # Services
  Object.const_set(:RedsysPaymentProcessor, PlebisCollaborations::RedsysPaymentProcessor) unless defined?(RedsysPaymentProcessor)

  # Mailers
  Object.const_set(:CollaborationsMailer, PlebisCollaborations::CollaborationsMailer) unless defined?(CollaborationsMailer)

  # Controllers
  Object.const_set(:CollaborationsController, PlebisCollaborations::CollaborationsController) unless defined?(CollaborationsController)
end
