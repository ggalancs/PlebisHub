# frozen_string_literal: true

# ================================================================
# Permission - Granular permissions for RBAC/ABAC
# ================================================================
# Defines what actions can be performed on resources
# Supports attribute-based conditions for ABAC
# ================================================================

class Permission < ApplicationRecord
  # Associations
  belongs_to :role

  # Validations
  validates :resource, presence: true
  validates :action, presence: true
  validates :scope, presence: true, inclusion: { in: %w[own organization global] }

  # Scopes
  scope :for_resource, ->(resource) { where(resource: resource.to_s) }
  scope :for_action, ->(action) { where(action: action.to_s) }
  scope :for_scope, ->(scope) { where(scope: scope.to_s) }
  scope :global, -> { where(scope: 'global') }
  scope :organization, -> { where(scope: 'organization') }
  scope :own, -> { where(scope: 'own') }

  # Common resources
  RESOURCES = %w[
    users
    proposals
    votes
    comments
    collaborations
    organizations
    teams
    campaigns
    microcredits
    verifications
  ].freeze

  # Common actions
  ACTIONS = %w[
    read
    create
    edit
    update
    delete
    destroy
    approve
    reject
    publish
    moderate
    manage
  ].freeze

  # Check if permission matches given criteria
  # @param resource [String] Resource type
  # @param action [String] Action
  # @param scope [String] Scope
  # @return [Boolean]
  def matches?(resource:, action:, scope: 'own')
    self.resource == resource.to_s &&
      self.action == action.to_s &&
      (self.scope == scope.to_s || self.scope == 'global')
  end

  # Evaluate ABAC conditions
  # @param context [Hash] Context with user, object, etc.
  # @return [Boolean]
  def evaluate_conditions(context = {})
    return true if conditions.blank?

    conditions.all? do |key, value|
      evaluate_condition(key, value, context)
    end
  end

  private

  def evaluate_condition(key, expected_value, context)
    actual_value = context.dig(*key.split('.'))

    case expected_value
    when Hash
      # Support operators like { gte: 18 }
      evaluate_operator_condition(actual_value, expected_value)
    else
      actual_value == expected_value
    end
  end

  def evaluate_operator_condition(actual_value, operator_hash)
    operator_hash.all? do |op, expected|
      case op.to_sym
      when :eq then actual_value == expected
      when :ne then actual_value != expected
      when :gt then actual_value > expected
      when :gte then actual_value >= expected
      when :lt then actual_value < expected
      when :lte then actual_value <= expected
      when :in then expected.include?(actual_value)
      when :nin then !expected.include?(actual_value)
      else false
      end
    end
  end
end
