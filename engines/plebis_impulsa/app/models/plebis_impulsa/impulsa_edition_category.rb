# frozen_string_literal: true

module PlebisImpulsa
  class ImpulsaEditionCategory < ApplicationRecord
    include FlagShihTzu

    self.table_name = 'impulsa_edition_categories'

    # FlagShihTzu: check_for_column: false prevents startup warnings before migrations run
    has_flags 1 => :has_votings, check_for_column: false

    belongs_to :impulsa_edition, class_name: 'PlebisImpulsa::ImpulsaEdition'
    has_many :impulsa_projects, class_name: 'PlebisImpulsa::ImpulsaProject'

    validates :name, :category_type, :winners, :prize, presence: true

    store :wizard, coder: YAML
    store :evaluation, coder: YAML
    attr_accessor :wizard_raw, :evaluation_raw

    scope :non_authors, -> { where.not only_authors: true }
    scope :state, -> { where category_type: CATEGORY_TYPES[:state] }
    scope :territorial, -> { where category_type: CATEGORY_TYPES[:territorial] }
    scope :internal, -> { where category_type: CATEGORY_TYPES[:internal] }

    CATEGORY_TYPES = {
      internal: 0,
      state: 1,
      territorial: 2
    }.freeze

    def wizard_raw
      wizard.to_yaml.gsub(' !ruby/hash:ActiveSupport::HashWithIndifferentAccess', '')
    end

    def wizard_raw=(value)
      self.wizard = YAML.load(value)
    end

    def evaluation_raw
      evaluation.to_yaml.gsub(' !ruby/hash:ActiveSupport::HashWithIndifferentAccess', '')
    end

    def evaluation_raw=(value)
      self.evaluation = YAML.load(value)
    end

    def category_type_name
      CATEGORY_TYPES.invert[category_type]
    end

    def has_territory?
      category_type == CATEGORY_TYPES[:territorial]
    end

    def translatable?
      coofficial_language.present?
    end

    def coofficial_language_name
      I18n.name_for_locale(self[:coofficial_language].to_sym) if self[:coofficial_language]
    end

    def territories
      if self[:territories]
        self[:territories].split('|').compact
      else
        []
      end
    end

    def territories=(values)
      self[:territories] = values.select(&:present?).join('|')
    end

    def territories_names
      names = PlebisBrand::GeoExtra::AUTONOMIES.values.to_h
      territories.map { |t| names[t] }
    end

    def prewinners
      winners * 2
    end
  end
end
