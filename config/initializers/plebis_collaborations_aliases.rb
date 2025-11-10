# frozen_string_literal: true

# Backward compatibility aliases for PLEBIS_COLLABORATIONS engine
# These aliases allow existing code to reference models without the namespace
# After full migration, these can be removed

# Models
Collaboration = PlebisCollaborations::Collaboration unless defined?(Collaboration)
Order = PlebisCollaborations::Order unless defined?(Order)

# Services
RedsysPaymentProcessor = PlebisCollaborations::RedsysPaymentProcessor unless defined?(RedsysPaymentProcessor)

# Mailers
CollaborationsMailer = PlebisCollaborations::CollaborationsMailer unless defined?(CollaborationsMailer)

# Controllers
CollaborationsController = PlebisCollaborations::CollaborationsController unless defined?(CollaborationsController)
