# frozen_string_literal: true

# ================================================================
# HasPermissions - Concern for User model
# ================================================================
# Provides permission checking methods for RBAC + ABAC
# ================================================================

module HasPermissions
  extend ActiveSupport::Concern

  included do
    # Associations
    has_many :user_roles, dependent: :destroy
    has_many :roles, through: :user_roles

    # Scopes
    scope :with_role, ->(role_name) {
      joins(:roles).where(roles: { name: role_name })
    }
    scope :with_any_role, ->(role_names) {
      joins(:roles).where(roles: { name: role_names })
    }
  end

  # Check if user has a specific role
  # @param role_name [String, Symbol] Name of the role
  # @param organization [Organization, nil] Optional organization context
  # @return [Boolean]
  def has_role?(role_name, organization: nil)
    scope = user_roles.joins(:role).where(roles: { name: role_name.to_s })
    scope = scope.where(organization: organization) if organization.present?
    scope.active.exists?
  end

  # Add a role to user
  # @param role_name [String, Symbol] Name of the role
  # @param organization [Organization, nil] Optional organization context
  # @param expires_at [DateTime, nil] Optional expiration
  def add_role(role_name, organization: nil, expires_at: nil)
    role = if organization
             Role.find_by(name: role_name.to_s, organization: organization)
           else
             Role.find_by(name: role_name.to_s, scope: 'global')
           end

    return false unless role

    user_roles.find_or_create_by!(
      role: role,
      organization: organization,
      expires_at: expires_at
    )
  end

  # Remove a role from user
  def remove_role(role_name, organization: nil)
    scope = user_roles.joins(:role).where(roles: { name: role_name.to_s })
    scope = scope.where(organization: organization) if organization.present?
    scope.destroy_all
  end

  # Check if user can perform an action on a resource
  # @param action [Symbol] The action (e.g., :read, :edit, :delete)
  # @param resource [Object, String] The resource instance or class name
  # @param context [Hash] Additional context for ABAC
  # @return [Boolean]
  def can?(action, resource, context: {})
    # Superadmin can do everything
    return true if superadmin?

    resource_type = extract_resource_type(resource)
    scope_level = determine_scope_level(resource, context)

    # Get all active roles for the user
    active_roles = user_roles.active.includes(role: :permissions)

    # Check if any role has the required permission
    active_roles.any? do |user_role|
      user_role.role.permissions.any? do |permission|
        permission.matches?(
          resource: resource_type,
          action: action.to_s,
          scope: scope_level
        ) && permission.evaluate_conditions(build_permission_context(resource, context))
      end
    end
  end

  # Check if user is superadmin (legacy support)
  def superadmin?
    has_role?('superadmin') || super_admin?
  end

  # Check if user is admin
  def admin?
    has_role?('admin') || has_role?('superadmin')
  end

  # Check if user is moderator
  def moderator?
    has_role?('moderator') || admin?
  end

  # Get all permissions for user across all roles
  def all_permissions
    Permission.where(role_id: roles.pluck(:id))
  end

  private

  def extract_resource_type(resource)
    case resource
    when String, Symbol
      resource.to_s.pluralize
    when Class
      resource.name.underscore.pluralize
    else
      resource.class.name.underscore.pluralize
    end
  end

  def determine_scope_level(resource, context)
    return 'global' if superadmin?

    case resource
    when String, Symbol, Class
      'global'
    else
      # Check if user owns the resource
      if resource.respond_to?(:user_id) && resource.user_id == id
        'own'
      elsif resource.respond_to?(:author_id) && resource.author_id == id
        'own'
      elsif resource.respond_to?(:organization_id) && resource.organization_id == organization_id
        'organization'
      else
        'global'
      end
    end
  end

  def build_permission_context(resource, additional_context)
    {
      user: self,
      resource: resource,
      organization: organization
    }.merge(additional_context)
  end
end
