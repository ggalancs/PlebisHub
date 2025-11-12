# frozen_string_literal: true

# ================================================================
# VotePolicy - Authorization policy for Votes
# ================================================================
# Defines who can vote and manage votes
# ================================================================

class VotePolicy < ApplicationPolicy
  def create?
    return false unless user

    user.can?(:create, 'votes')
  end

  def update?
    return false unless user

    # Users can only update their own votes
    own_record?
  end

  def destroy?
    return false unless user

    # Users can delete their own votes
    # Admins can delete any vote
    own_record? || admin?
  end

  def show?
    # Vote details are private unless you're the voter or an admin
    return false unless user

    own_record? || admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.where(user_id: user&.id)
      end
    end
  end
end
