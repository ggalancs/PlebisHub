# frozen_string_literal: true

module PlebisImpulsa
  class ImpulsaProjectStateTransition < ApplicationRecord
    self.table_name = 'impulsa_project_state_transitions'

    belongs_to :impulsa_project, class_name: 'PlebisImpulsa::ImpulsaProject'
  end
end
