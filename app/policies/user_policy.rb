# frozen_string_literal: true

# ================================================================
# UserPolicy - Authorization policy for Users
# ================================================================
# Defines who can view and manage user accounts
# ================================================================

class UserPolicy < ApplicationPolicy
  def index?
    return false unless user

    admin? || moderator?
  end

  def show?
    return false unless user

    # Users can view their own profile
    return true if own_record?

    # Moderators and admins can view any user
    moderator? || admin?
  end

  def create?
    admin? # Only admins can create users directly
  end

  def update?
    return false unless user

    # Users can update their own profile
    return true if own_record?

    # Admins can update any user
    admin?
  end

  def destroy?
    return false unless user

    # Users cannot delete themselves
    return false if own_record?

    # Only admins can delete users
    admin?
  end

  def ban?
    return false unless user

    admin? || moderator?
  end

  def unban?
    ban?
  end

  def verify?
    admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user&.moderator?
        scope.where(organization_id: user.organization_id)
      else
        scope.where(id: user&.id)
      end
    end
  end
end
