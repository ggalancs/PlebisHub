# frozen_string_literal: true

module EngineUser
  # Microcreditor Concern
  #
  # Extends User model with microcredit-related associations and methods.
  # This concern is loaded when the plebis_microcredit engine is active.
  #
  module Microcreditor
    extend ActiveSupport::Concern

    included do
      # Associations for microcredits
      has_many :microcredit_loans, dependent: :destroy
    end

    # Check if user has any renewable microcredit loans
    # Uses document_vatid to find loans
    #
    # @return [Boolean] Whether user has renewable microcredits
    #
    def any_microcredit_renewable?
      MicrocreditLoan.renewables.where(document_vatid: self.document_vatid).exists?
    end
  end
end
