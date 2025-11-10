class ImpulsaEditionTopic < ApplicationRecord
  belongs_to :impulsa_edition
  has_many :impulsa_projects
  has_many :impulsa_project_topics
end
