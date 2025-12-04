# frozen_string_literal: true

module PlebisImpulsa
  class ImpulsaEditionTopic < ApplicationRecord
    self.table_name = 'impulsa_edition_topics'

    belongs_to :impulsa_edition, class_name: 'PlebisImpulsa::ImpulsaEdition'
    has_many :impulsa_project_topics, class_name: 'PlebisImpulsa::ImpulsaProjectTopic', dependent: :restrict_with_error
    has_many :impulsa_projects, through: :impulsa_project_topics, class_name: 'PlebisImpulsa::ImpulsaProject'
  end
end
