# frozen_string_literal: true

# ================================================================
# ProposalPolicy - Authorization policy for Proposals
# ================================================================
# Defines who can view, create, edit, and delete proposals
# ================================================================

class ProposalPolicy < ApplicationPolicy
  def index?
    true # Everyone can view proposal list
  end

  def show?
    true # Everyone can view individual proposals
  end

  def create?
    user.present? && user.can?(:create, 'proposals')
  end

  def update?
    return false unless user

    # Owner can edit own proposals
    return true if own_record? && user.can?(:edit, record)

    # Moderators can edit any proposal in their organization
    return true if moderator? && same_organization?

    # Admin can edit any proposal
    admin?
  end

  def destroy?
    return false unless user

    # Owner can delete own proposals
    return true if own_record? && user.can?(:delete, record)

    # Moderators can delete proposals in their organization
    return true if moderator? && same_organization?

    # Admin can delete any proposal
    admin?
  end

  def approve?
    return false unless user

    moderator? || admin?
  end

  def reject?
    approve?
  end

  def publish?
    return false unless user

    own_record? || moderator? || admin?
  end

  class Scope < Scope
    def resolve
      if user&.superadmin?
        scope.all
      elsif user&.moderator?
        scope.where(organization_id: user.organization_id)
      else
        scope.published # Regular users see only published proposals
      end
    end
  end
end
