# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)

    # SECURITY FIX SEC-007: Implement granular role-based permissions
    # Replace overly broad 'can :manage, :all' with specific permissions
    if user.is_admin?
      if user.superadmin?
        # Only superadmins get full access
        can :manage, :all
      else
        # Regular admins - specific permissions only
        define_regular_admin_abilities(user)
      end
    elsif user.finances_admin?
      define_finances_admin_abilities(user)
    elsif user.impulsa_admin?
      define_impulsa_admin_abilities(user)
    elsif user.verifier?
      define_verifier_abilities(user)
    elsif user.paper_authority?
      define_paper_authority_abilities(user)
    end

    # All authenticated users
    define_user_abilities(user) if user.persisted?

    # Guest users
    define_guest_abilities

    # SECURITY FIX SEC-007: Apply restrictive rules LAST to ensure they can't be overridden
    # by define_user_abilities
    apply_security_restrictions(user)
  end

  private

  # SECURITY FIX SEC-007: Granular permissions for regular admins
  def define_regular_admin_abilities(_user)
    # Content management
    can :manage, Notice
    can :manage, Post
    can :manage, Page if defined?(Page)
    can :manage, Category if defined?(Category)
    can :manage, Sidekiq::Web if defined?(Sidekiq::Web)
    can :manage, Report
    can :manage, ActiveAdmin
    can :read, ActiveAdmin::Page, name: 'Dashboard'
    can %i[read create], ActiveAdmin::Comment

    # Brand/Theme customization
    can :manage, BrandSetting
    can :manage, BrandImage

    # User management (limited - no destroy to prevent accidental deletions)
    can :admin, User
    can %i[read create update], User
    cannot :destroy, User

    # Financial management (limited - read-only for non-finance admins)
    can :admin, Microcredit
    can :admin, MicrocreditLoan
    can [:read], Microcredit
    can [:read], MicrocreditLoan
    can [:read], Order if defined?(Order)
    can [:read], Collaboration if defined?(Collaboration)

    # Impulsa project management
    can :admin, ImpulsaProject if defined?(ImpulsaProject)
    can :admin, ImpulsaEdition if defined?(ImpulsaEdition)
    can %i[read update], ImpulsaProject if defined?(ImpulsaProject)
    can %i[read update], ImpulsaEdition if defined?(ImpulsaEdition)
    can %i[read update], ImpulsaEditionTopic if defined?(ImpulsaEditionTopic)

    # Restrict sensitive operations (only for superadmins)
    cannot :manage, Election
    cannot :manage, ReportGroup
    cannot :manage, SpamFilter
    can :read, Election # Allow read-only access to elections
    cannot %i[destroy update], Vote if defined?(Vote)
  end

  # SECURITY FIX SEC-007: Granular permissions for finances admins
  def define_finances_admin_abilities(_user)
    can :manage, Microcredit if defined?(Microcredit)
    can :manage, MicrocreditLoan if defined?(MicrocreditLoan)
    can :manage, Order if defined?(Order)
    can :manage, Collaboration if defined?(Collaboration)
    can %i[read create], ActiveAdmin::Comment

    # Preserve financial records - no destructive operations
    cannot :destroy, Order if defined?(Order)
    cannot :destroy, Collaboration if defined?(Collaboration)

    # Read-only access for verification
    can :read, User
    can :read, ActiveAdmin::Page, name: 'Envios de Credenciales'
  end

  # SECURITY FIX SEC-007: Granular permissions for impulsa admins
  def define_impulsa_admin_abilities(_user)
    can :manage, ImpulsaProject if defined?(ImpulsaProject)
    can :manage, ImpulsaEdition if defined?(ImpulsaEdition)
    can :manage, ImpulsaEditionTopic if defined?(ImpulsaEditionTopic)
    can %i[read create], ActiveAdmin::Comment

    # Read-only access to user data
    can :read, User
  end

  # SECURITY FIX SEC-007: Granular permissions for verifiers
  def define_verifier_abilities(user)
    can %i[show read update], UserVerification if defined?(UserVerification)
    can :read, ActiveAdmin::Page, name: 'Envios de Credenciales'
    can %i[read create], ActiveAdmin::Comment

    # Can create/update their own verifications
    can %i[create update], UserVerification, user_id: user.id if defined?(UserVerification)

    # Read-only access to users
    can :read, User
  end

  # SECURITY FIX SEC-007: Granular permissions for paper authorities
  def define_paper_authority_abilities(_user)
    can :manage, ActiveAdmin::Page, name: 'CensusTool'

    # Read-only access to users
    can :read, User
  end

  # SECURITY FIX SEC-007: Permissions for all authenticated users
  def define_user_abilities(user)
    can %i[show read update], User, id: user.id
    can :show, Notice
    can %i[create update], UserVerification, user_id: user.id if defined?(UserVerification)
    can :manage, Collaboration, user_id: user.id if defined?(Collaboration)
  end

  # SECURITY FIX SEC-007: Permissions for guest users
  def define_guest_abilities
    can :show, Notice
    can :read, Page, public: true if defined?(Page)
    can :read, Post, status: 'published' if defined?(Post)
  end

  # SECURITY FIX SEC-007: Apply security restrictions that should NEVER be overridden
  # These rules are applied LAST to ensure they take precedence over all other rules
  def apply_security_restrictions(user)
    return if user.is_admin? && user.superadmin? # Superadmins bypass all restrictions

    # Regular admins: restrict sensitive operations
    if user.is_admin? && !user.superadmin?
      cannot :destroy, User
      cannot :manage, Election
      can :read, Election # Preserve read-only access to elections
      cannot :manage, ReportGroup
      cannot :manage, SpamFilter
      cannot %i[destroy update], Vote if defined?(Vote)
    end

    # Finances admins: preserve financial records
    if user.finances_admin?
      cannot :destroy, Order if defined?(Order)
      cannot :destroy, Collaboration if defined?(Collaboration)
    end
  end
end
