# frozen_string_literal: true

module Gamification
  # ==================================
  # Gamification Badges/Achievements
  # ==================================
  # Rewards users for accomplishments
  # ==================================

  class Badge < ApplicationRecord
    self.table_name = 'gamification_badges'

    has_many :user_badges, class_name: 'Gamification::UserBadge'
    has_many :users, through: :user_badges

    # Validations
    validates :key, presence: true, uniqueness: true
    validates :name, presence: true
    validates :icon, presence: true
    validates :tier, inclusion: { in: %w[bronze silver gold platinum diamond] }, allow_nil: true

    # Scopes
    scope :by_category, ->(category) { where(category: category) }
    scope :by_tier, ->(tier) { where(tier: tier) }

    # Predefined badges
    PREDEFINED_BADGES = [
      {
        key: 'first_proposal',
        name: 'Primera Propuesta',
        description: 'Creaste tu primera propuesta',
        icon: '📝',
        category: 'proposals',
        tier: 'bronze',
        points_reward: 50,
        criteria: { proposals_created: { gte: 1 } }
      },
      {
        key: 'prolific_proposer',
        name: 'Proponente Prolífico',
        description: 'Creaste 10 propuestas',
        icon: '📋',
        category: 'proposals',
        tier: 'silver',
        points_reward: 200,
        criteria: { proposals_created: { gte: 10 } }
      },
      {
        key: 'proposal_master',
        name: 'Maestro de Propuestas',
        description: 'Creaste 50 propuestas',
        icon: '🎯',
        category: 'proposals',
        tier: 'gold',
        points_reward: 500,
        criteria: { proposals_created: { gte: 50 } }
      },
      {
        key: 'first_vote',
        name: 'Primera Participación',
        description: 'Votaste por primera vez',
        icon: '🗳️',
        category: 'voting',
        tier: 'bronze',
        points_reward: 25,
        criteria: { votes_cast: { gte: 1 } }
      },
      {
        key: 'active_voter',
        name: 'Votante Activo',
        description: 'Votaste en 25 propuestas',
        icon: '✅',
        category: 'voting',
        tier: 'silver',
        points_reward: 150,
        criteria: { votes_cast: { gte: 25 } }
      },
      {
        key: 'voting_champion',
        name: 'Campeón del Voto',
        description: 'Votaste en 100 propuestas',
        icon: '🏆',
        category: 'voting',
        tier: 'gold',
        points_reward: 400,
        criteria: { votes_cast: { gte: 100 } }
      },
      {
        key: 'community_builder',
        name: 'Constructor de Comunidad',
        description: 'Invitaste 5 personas que se registraron',
        icon: '👥',
        category: 'social',
        tier: 'silver',
        points_reward: 300,
        criteria: { referrals_joined: { gte: 5 } }
      },
      {
        key: 'early_adopter',
        name: 'Adoptador Temprano',
        description: 'Te registraste en el primer mes',
        icon: '🌟',
        category: 'special',
        tier: 'gold',
        points_reward: 500,
        criteria: { registered_before: '2024-02-01' }
      },
      {
        key: 'week_warrior',
        name: 'Guerrero Semanal',
        description: 'Racha de 7 días consecutivos',
        icon: '🔥',
        category: 'engagement',
        tier: 'bronze',
        points_reward: 100,
        criteria: { streak_days: { gte: 7 } }
      },
      {
        key: 'consistency_king',
        name: 'Rey de la Consistencia',
        description: 'Racha de 30 días consecutivos',
        icon: '👑',
        category: 'engagement',
        tier: 'gold',
        points_reward: 500,
        criteria: { streak_days: { gte: 30 } }
      },
      {
        key: 'comment_contributor',
        name: 'Contribuidor de Comentarios',
        description: 'Escribiste 50 comentarios constructivos',
        icon: '💬',
        category: 'engagement',
        tier: 'silver',
        points_reward: 150,
        criteria: { comments_posted: { gte: 50 } }
      },
      {
        key: 'level_10',
        name: 'Líder Emergente',
        description: 'Alcanzaste el nivel 10',
        icon: '⭐',
        category: 'levels',
        tier: 'silver',
        points_reward: 200,
        criteria: { level: { gte: 10 } }
      },
      {
        key: 'level_20',
        name: 'Visionario Confirmado',
        description: 'Alcanzaste el nivel 20',
        icon: '💎',
        category: 'levels',
        tier: 'platinum',
        points_reward: 1000,
        criteria: { level: { gte: 20 } }
      }
    ].freeze

    # Check if user meets criteria
    def criteria_met?(user)
      stats = Gamification::UserStats.for_user(user)
      user_metrics = {
        proposals_created: user.proposals.count,
        votes_cast: user.votes.count,
        comments_posted: user.comments.count,
        streak_days: stats.current_streak,
        level: stats.level,
        registered_before: user.created_at
      }

      criteria.all? do |key, condition|
        metric_value = user_metrics[key.to_sym]
        check_condition(metric_value, condition)
      end
    end

    def check_condition(value, condition)
      case condition
      when Hash
        condition.all? do |op, expected|
          case op.to_sym
          when :gte then value >= expected
          when :lte then value <= expected
          when :eq then value == expected
          when :gt then value > expected
          when :lt then value < expected
          else false
          end
        end
      when String
        value < DateTime.parse(condition)
      else
        value == condition
      end
    end

    # Seed predefined badges
    def self.seed!
      PREDEFINED_BADGES.each do |badge_data|
        find_or_create_by!(key: badge_data[:key]) do |badge|
          badge.assign_attributes(badge_data.except(:key))
        end
      end
    end
  end
end
