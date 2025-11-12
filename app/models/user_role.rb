# frozen_string_literal: true

# ================================================================
# UserRole - Join table for users and roles
# ================================================================
# Assigns roles to users with optional organization scoping
# Supports role expiration
# ================================================================

class UserRole < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :role
  belongs_to :organization, optional: true

  # Validations
  validates :user_id, uniqueness: { scope: [:role_id, :organization_id] }

  # Scopes
  scope :active, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at IS NOT NULL AND expires_at <= ?', Time.current) }
  scope :for_organization, ->(org) { where(organization: org) }
  scope :global, -> { where(organization_id: nil) }

  # Check if role assignment is active
  def active?
    expires_at.nil? || expires_at > Time.current
  end

  # Check if role assignment is expired
  def expired?
    !active?
  end
end
