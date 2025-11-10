# frozen_string_literal: true

module PlebisImpulsa
  class ImpulsaEditionTopic < ApplicationRecord
    self.table_name = 'impulsa_edition_topics'

    belongs_to :impulsa_edition, class_name: 'PlebisImpulsa::ImpulsaEdition'
  end
end
