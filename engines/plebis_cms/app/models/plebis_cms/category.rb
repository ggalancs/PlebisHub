# frozen_string_literal: true

module PlebisCms
  class Category < ApplicationRecord
    self.table_name = 'categories'

    extend FriendlyId
    friendly_id :slug_candidates, use: [:slugged, :finders]

    # Associations
    has_and_belongs_to_many :posts, class_name: 'PlebisCms::Post'

    # Validations
    validates :name, presence: true, uniqueness: { case_sensitive: false }
    validates :slug, uniqueness: { case_sensitive: false }, allow_blank: true

    # Scopes
    scope :active, -> { joins(:posts).distinct }
    scope :inactive, -> { where.missing(:posts) }
    scope :alphabetical, -> { order(name: :asc) }
    scope :by_post_count, -> { left_joins(:posts).group(:id).order('COUNT(posts.id) DESC') }

    # Instance methods
    def active?
      posts.exists?
    end

    def inactive?
      !active?
    end

    def posts_count
      posts.count
    end

    def slug_candidates
      [
        :name,
        [:name, :id]
      ]
    end
  end
end
