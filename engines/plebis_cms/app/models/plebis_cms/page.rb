# frozen_string_literal: true

# http://codeconnoisseur.org/ramblings/creating-dynamic-routes-at-runtime-in-rails-4
module PlebisCms
  class Page < ApplicationRecord
    self.table_name = 'pages'

    validates :id_form, presence: true, :numericality => { :greater_than_or_equal_to => 0 }
    validates :slug, uniqueness: { case_sensitive: false, scope: :deleted_at }, presence: true
    validates :title, presence: true

    acts_as_paranoid

    # Scopes
    scope :promoted, -> { where(promoted: true) }
    scope :ordered_by_priority, -> { order(priority: :desc) }
    scope :promoted_ordered, -> { promoted.ordered_by_priority }

    # Instance methods
    def external_plebisbrand_link?
      return false if link.blank?
      /https:\/\/[^\/]*\.plebisbrand.info\/.*/.match?(link)
    end
  end
end
