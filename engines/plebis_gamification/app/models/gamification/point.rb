# frozen_string_literal: true

module Gamification
  # ==================================
  # Gamification Points Record
  # ==================================
  # Individual point transaction record
  # ==================================

  class Point < ApplicationRecord
    self.table_name = 'gamification_points'

    belongs_to :user
    belongs_to :source, polymorphic: true, optional: true

    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :reason, presence: true

    scope :recent, -> { order(created_at: :desc) }
    scope :by_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
    scope :for_reason, ->(reason) { where(reason: reason) }

    # Get point history for user
    def self.history_for(user, limit: 50)
      where(user_id: user.id)
        .includes(:source)
        .order(created_at: :desc)
        .limit(limit)
        .map(&:as_json_detailed)
    end

    def as_json_detailed
      {
        id: id,
        amount: amount,
        reason: reason,
        source: source_summary,
        earned_at: created_at.iso8601
      }
    end

    private

    def source_summary
      return nil unless source

      {
        type: source_type,
        id: source_id,
        name: source.try(:title) || source.try(:name) || source.to_s
      }
    end
  end
end
