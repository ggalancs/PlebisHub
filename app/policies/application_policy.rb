# frozen_string_literal: true

# ================================================================
# ApplicationPolicy - Base policy for all Pundit policies
# ================================================================
# Provides default authorization logic using RBAC + ABAC
# ================================================================

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user&.can?(:read, record.class)
  end

  def show?
    user&.can?(:read, record)
  end

  def create?
    user&.can?(:create, record.class)
  end

  def new?
    create?
  end

  def update?
    user&.can?(:edit, record) || own_record?
  end

  def edit?
    update?
  end

  def destroy?
    user&.can?(:delete, record) || own_record?
  end

  # Additional common methods
  def approve?
    user&.can?(:approve, record)
  end

  def reject?
    user&.can?(:reject, record)
  end

  def publish?
    user&.can?(:publish, record)
  end

  def moderate?
    user&.moderator? || user&.can?(:moderate, record)
  end

  protected

  # Check if user owns the record
  def own_record?
    return false unless user

    if record.respond_to?(:user_id)
      record.user_id == user.id
    elsif record.respond_to?(:author_id)
      record.author_id == user.id
    else
      false
    end
  end

  # Check if user is in the same organization as the record
  def same_organization?
    return false unless user && record.respond_to?(:organization_id)

    user.organization_id == record.organization_id
  end

  # Check if user is admin
  def admin?
    user&.admin?
  end

  # Check if user is moderator
  def moderator?
    user&.moderator?
  end

  # Scope for listing records
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user&.superadmin?
        scope.all
      elsif user&.admin?
        scope.where(organization_id: user.organization_id)
      else
        scope.where(user_id: user&.id)
      end
    end
  end
end
