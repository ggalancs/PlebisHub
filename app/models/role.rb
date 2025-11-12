# frozen_string_literal: true

# ================================================================
# Role - RBAC (Role-Based Access Control) Model
# ================================================================
# Manages roles for users with granular permissions
# Supports organization-scoped roles and global roles
# ================================================================

class Role < ApplicationRecord
  # Associations
  has_many :permissions, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  belongs_to :organization, optional: true

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization_id }
  validates :scope, inclusion: { in: %w[global organization custom] }

  # Scopes
  scope :global, -> { where(scope: 'global', organization_id: nil) }
  scope :for_organization, ->(org) { where(organization: org) }
  scope :by_scope, ->(scope) { where(scope: scope) }

  # Predefined global roles
  GLOBAL_ROLES = %w[
    superadmin
    admin
    moderator
    user
  ].freeze

  # Organization-level roles
  ORGANIZATION_ROLES = %w[
    org_admin
    org_moderator
    org_member
  ].freeze

  # Check if this role has a specific permission
  # @param resource [String] The resource type (e.g., 'proposals', 'users')
  # @param action [String] The action (e.g., 'read', 'create', 'edit', 'delete')
  # @param scope [String] The scope (e.g., 'own', 'organization', 'global')
  # @return [Boolean]
  def can?(resource, action, permission_scope = :own)
    permissions.exists?(
      resource: resource.to_s,
      action: action.to_s,
      scope: [permission_scope.to_s, 'global']
    )
  end

  # Add a permission to this role
  # @param resource [String] The resource type
  # @param action [String] The action
  # @param scope [String] The permission scope
  # @param conditions [Hash] Optional ABAC conditions
  def add_permission(resource, action, scope: 'own', conditions: {})
    permissions.find_or_create_by!(
      resource: resource.to_s,
      action: action.to_s,
      scope: scope.to_s,
      conditions: conditions
    )
  end

  # Remove a permission from this role
  def remove_permission(resource, action, scope: 'own')
    permissions.where(
      resource: resource.to_s,
      action: action.to_s,
      scope: scope.to_s
    ).destroy_all
  end

  # Seed default global roles
  def self.seed_global_roles!
    seed_superadmin_role!
    seed_admin_role!
    seed_moderator_role!
    seed_user_role!
  end

  def self.seed_superadmin_role!
    role = find_or_create_by!(name: 'superadmin', scope: 'global') do |r|
      r.description = 'Super Administrator - Full system access'
    end

    # Superadmin has ALL permissions
    %w[users proposals votes collaborations organizations].each do |resource|
      %w[read create edit delete approve manage].each do |action|
        role.add_permission(resource, action, scope: 'global')
      end
    end

    role
  end

  def self.seed_admin_role!
    role = find_or_create_by!(name: 'admin', scope: 'global') do |r|
      r.description = 'Administrator - Organization management'
    end

    # Admin permissions
    %w[users proposals votes collaborations].each do |resource|
      %w[read create edit delete].each do |action|
        role.add_permission(resource, action, scope: 'organization')
      end
    end

    role
  end

  def self.seed_moderator_role!
    role = find_or_create_by!(name: 'moderator', scope: 'global') do |r|
      r.description = 'Moderator - Content moderation'
    end

    # Moderator permissions
    %w[proposals comments].each do |resource|
      %w[read edit delete].each do |action|
        role.add_permission(resource, action, scope: 'organization')
      end
    end

    role.add_permission('users', 'read', scope: 'organization')

    role
  end

  def self.seed_user_role!
    role = find_or_create_by!(name: 'user', scope: 'global') do |r|
      r.description = 'Regular User - Basic permissions'
    end

    # User permissions
    role.add_permission('proposals', 'read', scope: 'global')
    role.add_permission('proposals', 'create', scope: 'own')
    role.add_permission('proposals', 'edit', scope: 'own')
    role.add_permission('proposals', 'delete', scope: 'own')

    role.add_permission('votes', 'create', scope: 'own')
    role.add_permission('votes', 'read', scope: 'global')

    role.add_permission('comments', 'create', scope: 'own')
    role.add_permission('comments', 'edit', scope: 'own')
    role.add_permission('comments', 'delete', scope: 'own')

    role
  end
end
