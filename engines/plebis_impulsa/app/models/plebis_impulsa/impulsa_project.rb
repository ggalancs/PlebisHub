# frozen_string_literal: true

# Explicitly require concerns (Zeitwerk workaround for nested concerns directory)
require_relative 'concerns/impulsa_project_states'
require_relative 'concerns/impulsa_project_wizard'
require_relative 'concerns/impulsa_project_evaluation'

module PlebisImpulsa
  class ImpulsaProject < ApplicationRecord
    include PlebisImpulsa::ImpulsaProjectStates
    include PlebisImpulsa::ImpulsaProjectWizard
    include PlebisImpulsa::ImpulsaProjectEvaluation

    self.table_name = 'impulsa_projects'

    belongs_to :impulsa_edition_category, class_name: 'PlebisImpulsa::ImpulsaEditionCategory', optional: false
    belongs_to :user, -> { with_deleted }, optional: false
    has_one :impulsa_edition, through: :impulsa_edition_category
    # Rails 7.2: Disable automatic validation of state_transitions (managed by state_machine gem)
    # Using autosave: false to prevent validation errors during state_machine transitions
    has_many :impulsa_project_state_transitions, class_name: 'PlebisImpulsa::ImpulsaProjectStateTransition',
                                                 dependent: :destroy, validate: false, autosave: false, inverse_of: :impulsa_project
    has_many :impulsa_project_topics, class_name: 'PlebisImpulsa::ImpulsaProjectTopic', dependent: :destroy

    validates :name, :status, presence: true
    validates :user, uniqueness: { scope: :impulsa_edition_category }, allow_blank: false, unless: proc { |project|
      project.user.nil? || project.user.impulsa_author?
    }

    validates :terms_of_service, :data_truthfulness, :content_rights, acceptance: { accept: [true, '1'] }

    scope :by_status, ->(status) { where(status: status) }

    scope :first_phase, -> { where(status: [0, 1, 2, 3]) }
    scope :second_phase, -> { where(status: [4, 6]) }
    scope :no_phase, -> { where status: [5, 7, 10] }
    scope :votable, -> { where status: 6 }
    scope :public_visible, -> { where status: [9, 6, 7] }

    def method_missing(method_sym, *, &)
      ret = wizard_method_missing(method_sym, *, &)
      return ret if ret != :super

      ret = evaluation_method_missing(method_sym, *, &)
      return ret if ret != :super

      super
    end

    def voting_dates
      "#{I18n.l(impulsa_edition.votings_start_at.to_date,
                format: :long)} al #{I18n.l(impulsa_edition.ends_at.to_date, format: :long)}"
    end

    def files_folder
      "#{Rails.application.root}/non-public/system/impulsa_projects/#{id}/"
    end
  end
end
