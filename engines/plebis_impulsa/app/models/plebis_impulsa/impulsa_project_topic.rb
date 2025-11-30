# frozen_string_literal: true

module PlebisImpulsa
  class ImpulsaProjectTopic < ApplicationRecord
    self.table_name = 'impulsa_project_topics'

    belongs_to :impulsa_project, class_name: 'PlebisImpulsa::ImpulsaProject'
    belongs_to :impulsa_edition_topic, class_name: 'PlebisImpulsa::ImpulsaEditionTopic'

    def slug
      impulsa_edition_topic&.name&.parameterize || "topic-#{id}"
    end
  end
end
