# frozen_string_literal: true

module PlebisImpulsa
  class ImpulsaEditionTopic < ApplicationRecord
    self.table_name = 'impulsa_edition_topics'

    belongs_to :impulsa_edition, class_name: 'PlebisImpulsa::ImpulsaEdition'
    has_many :impulsa_project_topics, class_name: 'PlebisImpulsa::ImpulsaProjectTopic', foreign_key: 'impulsa_edition_topic_id', dependent: :restrict_with_error
  end
end
