# frozen_string_literal: true

# ========================================
# Persisted Event Model
# ========================================
# Stores events for audit trail and event sourcing
# ========================================

class PersistedEvent < ApplicationRecord
  # Validations
  validates :event_type, presence: true
  validates :payload, presence: true
  validates :occurred_at, presence: true

  # Scopes
  scope :by_type, ->(type) { where(event_type: type) }
  scope :recent, -> { order(occurred_at: :desc) }
  scope :today, -> { where('occurred_at >= ?', Time.current.beginning_of_day) }
  scope :this_week, -> { where('occurred_at >= ?', Time.current.beginning_of_week) }
  scope :this_month, -> { where('occurred_at >= ?', Time.current.beginning_of_month) }

  # Indexes on JSONB columns for fast queries
  # Examples:
  #   PersistedEvent.where("payload->>'user_id' = ?", user_id.to_s)
  #   PersistedEvent.where("metadata->>'ip' = ?", ip_address)

  # Get event stream for aggregate
  def self.stream_for(aggregate_type, aggregate_id)
    where("payload->>'aggregate_type' = ? AND payload->>'aggregate_id' = ?",
          aggregate_type, aggregate_id.to_s)
      .order(:occurred_at)
  end

  # Event replay (event sourcing)
  def self.replay(event_type, &block)
    by_type(event_type).find_each do |event|
      yield event.payload.deep_symbolize_keys
    end
  end

  # Statistics
  def self.event_counts_by_type(period: :today)
    scope = case period
            when :today then today
            when :week then this_week
            when :month then this_month
            else all
            end

    scope.group(:event_type).count
  end
end
