# frozen_string_literal: true

module PlebisImpulsa
  class ImpulsaProjectStateTransition < ApplicationRecord
    self.table_name = 'impulsa_project_state_transitions'

    # Rails 7.2: Add inverse_of to match parent association
    belongs_to :impulsa_project, class_name: 'PlebisImpulsa::ImpulsaProject', inverse_of: :impulsa_project_state_transitions
  end
end
