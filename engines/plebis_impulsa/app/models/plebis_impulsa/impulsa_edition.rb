# frozen_string_literal: true

module PlebisImpulsa
  class ImpulsaEdition < ApplicationRecord
    self.table_name = 'impulsa_editions'

    store :legal, accessors: I18n.available_locales.map { |l| "legal_#{l}" }, coder: YAML

    has_many :impulsa_edition_categories, class_name: 'PlebisImpulsa::ImpulsaEditionCategory'
    has_many :impulsa_projects, through: :impulsa_edition_categories
    has_many :impulsa_edition_topics, class_name: 'PlebisImpulsa::ImpulsaEditionTopic'

    # ActiveStorage attachments (replaces Paperclip)
    has_one_attached :schedule_model
    has_one_attached :activities_resources_model
    has_one_attached :requested_budget_model
    has_one_attached :monitoring_evaluation_model

    validates :name, :email, presence: true
    validates :email, email: true

    validates(*I18n.available_locales.map { |l| :"legal_#{l}" }, allow_blank: true, url: true)

    # Content type validations for attachments
    SPREADSHEET_CONTENT_TYPES = [
      'application/vnd.ms-excel', 'application/msexcel', 'application/x-msexcel',
      'application/x-ms-excel', 'application/x-excel', 'application/x-dos_ms_excel',
      'application/xls', 'application/x-xls',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.oasis.opendocument.spreadsheet'
    ].freeze

    DOCUMENT_CONTENT_TYPES = [
      'application/vnd.ms-word', 'application/msword', 'application/x-msword',
      'application/x-ms-word', 'application/x-word', 'application/x-dos_ms_word',
      'application/doc', 'application/x-doc',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.oasis.opendocument.text'
    ].freeze

    validate :validate_attachment_content_types

    private

    def validate_attachment_content_types
      validate_spreadsheet_attachment(:schedule_model)
      validate_document_attachment(:activities_resources_model)
      validate_spreadsheet_attachment(:requested_budget_model)
      validate_spreadsheet_attachment(:monitoring_evaluation_model)
    end

    def validate_spreadsheet_attachment(attachment_name)
      attachment = send(attachment_name)
      return unless attachment.attached?

      return if SPREADSHEET_CONTENT_TYPES.include?(attachment.content_type)

      errors.add(attachment_name, 'debe ser un archivo de hoja de cálculo (Excel, ODS)')
    end

    def validate_document_attachment(attachment_name)
      attachment = send(attachment_name)
      return unless attachment.attached?

      return if DOCUMENT_CONTENT_TYPES.include?(attachment.content_type)

      errors.add(attachment_name, 'debe ser un documento (Word, ODT)')
    end

    public

    scope :active, -> { where('start_at < ? and ends_at > ?', DateTime.now, DateTime.now).order(start_at: :asc) }
    scope :upcoming, -> { where('start_at > ?', DateTime.now).order(start_at: :asc) }
    scope :previous, -> { where(ends_at: ...DateTime.now).order(start_at: :desc) }

    def self.current
      active.first || previous.first
    end

    def active?
      current_phase != EDITION_PHASES[:ended]
    end

    EDITION_PHASES = {
      not_started: 0,
      new_projects: 1,
      review_projects: 2,
      validation_projects: 3,
      prevotings: 4,
      votings: 5,
      ended: 6,
      publish_results: 7
    }.freeze

    def current_phase
      now = DateTime.now
      if now < start_at
        EDITION_PHASES[:not_started]
      elsif now < new_projects_until
        EDITION_PHASES[:new_projects]
      elsif now < review_projects_until
        EDITION_PHASES[:review_projects]
      elsif now < validation_projects_until
        EDITION_PHASES[:validation_projects]
      elsif now < votings_start_at
        EDITION_PHASES[:prevotings]
      elsif now < ends_at
        EDITION_PHASES[:votings]
      elsif now < publish_results_at
        EDITION_PHASES[:publish_results]
      else
        EDITION_PHASES[:ended]
      end
    end

    def allow_creation?
      current_phase == EDITION_PHASES[:new_projects]
    end

    def publish_results?
      current_phase < EDITION_PHASES[:publish_results]
    end

    def allow_edition?
      current_phase < EDITION_PHASES[:review_projects]
    end

    def allow_fixes?
      current_phase < EDITION_PHASES[:validation_projects]
    end

    def allow_validation?
      current_phase == EDITION_PHASES[:validation_projects]
    end

    def show_projects?
      current_phase > EDITION_PHASES[:validation_projects]
    end

    def legal_link
      self[:legal]["legal_#{I18n.locale}"] || self[:legal]["legal_#{I18n.default_locale}"]
    end

    def create_election(base_url)
      Election.transaction do
        e = Election.create! title: name, starts_at: votings_start_at, ends_at: ends_at, info_url: URI.join(base_url, Rails.application.routes.url_helpers.impulsa_categories_path),
                             scope: 1, priority: 0, info_text: 'Ver proyectos', flags: 0, agora_election_id: (Election.maximum(:agora_election_id) || 0) + 1

        states = impulsa_edition_categories.state

        impulsa_edition_categories.territorial.each do |category|
          next if category.impulsa_projects.votable.none?

          territories = category.territories.map { |t| t[-2..] }
          first_territory = territories.shift

          next if first_territory.nil?

          el = e.election_locations.create! title: name, layout: 'simple', description: 'Elige los mejores proyectos para construir el cambio', location: first_territory,
                                            agora_version: 0, share_text: 'Ya he votado en la votación de proyectos IMPULSA en participa.plebisbrand.info #ImpulsaTusIdeas'

          states.each do |state|
            next if state.impulsa_projects.votable.none?

            el.election_location_questions.create! winners: state.winners, minimum: 1, maximum: state.winners,
                                                   voting_system: 'plurality-at-large', totals: 'over-total-valid-votes', random_order: true,
                                                   title: state.name, description: 'Elige los mejores proyectos para construir el cambio en el país',
                                                   options_headers: ['Text', 'Image URL', 'URL', 'Description'], options: state.options(base_url)
          end

          el.election_location_questions.create! winners: category.winners, minimum: 1, maximum: category.winners,
                                                 voting_system: 'pairwise-beta', totals: 'over-total-valid-votes', random_order: true,
                                                 title: category.name, description: 'Elige los mejores proyectos de tu territorio para construir el cambio',
                                                 options_headers: ['Text', 'Image URL', 'URL', 'Description'], options: category.options(base_url)

          territories.each do |territory|
            e.election_locations.create location: territory, override: first_territory, agora_version: 0
          end
        end
      end
    end
  end
end
