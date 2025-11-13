# frozen_string_literal: true

# Backward compatibility aliases for PLEBIS_COLLABORATIONS engine
# These aliases allow existing code to reference models without the namespace
# After full migration, these can be removed

# Use to_prepare to ensure engines are loaded before creating aliases
Rails.application.config.to_prepare do
  # Models
  Collaboration = PlebisCollaborations::Collaboration unless defined?(Collaboration)
  Order = PlebisCollaborations::Order unless defined?(Order)

  # Services
  RedsysPaymentProcessor = PlebisCollaborations::RedsysPaymentProcessor unless defined?(RedsysPaymentProcessor)

  # Mailers
  CollaborationsMailer = PlebisCollaborations::CollaborationsMailer unless defined?(CollaborationsMailer)

  # Controllers
  CollaborationsController = PlebisCollaborations::CollaborationsController unless defined?(CollaborationsController)
rescue NameError => e
  # If classes don't exist, log warning but don't fail
  Rails.logger.warn "[PlebisCollaborations] Could not create aliases: #{e.message}" if defined?(Rails.logger)
end
