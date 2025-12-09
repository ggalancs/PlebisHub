# frozen_string_literal: true

FactoryBot.define do
  # Gamification Badge Factory
  factory :gamification_badge, class: 'Gamification::Badge' do
    sequence(:key) { |n| "badge_#{n}" }
    sequence(:name) { |n| "Badge #{n}" }
    description { 'A test badge' }
    icon { '🏆' }
    category { 'test' }
    tier { 'bronze' }
    points_reward { 100 }
    criteria { { proposals_created: { gte: 1 } } }

    trait :first_proposal do
      key { 'first_proposal' }
      name { 'Primera Propuesta' }
      description { 'Creaste tu primera propuesta' }
      icon { '📝' }
      category { 'proposals' }
      tier { 'bronze' }
      points_reward { 50 }
      criteria { { proposals_created: { gte: 1 } } }
    end

    trait :active_voter do
      key { 'active_voter' }
      name { 'Votante Activo' }
      description { 'Votaste en 25 propuestas' }
      icon { '✅' }
      category { 'voting' }
      tier { 'silver' }
      points_reward { 150 }
      criteria { { votes_cast: { gte: 25 } } }
    end

    trait :level_10 do
      key { 'level_10' }
      name { 'Líder Emergente' }
      description { 'Alcanzaste el nivel 10' }
      icon { '⭐' }
      category { 'levels' }
      tier { 'silver' }
      points_reward { 200 }
      criteria { { level: { gte: 10 } } }
    end

    trait :week_warrior do
      key { 'week_warrior' }
      name { 'Guerrero Semanal' }
      description { 'Racha de 7 días consecutivos' }
      icon { '🔥' }
      category { 'engagement' }
      tier { 'bronze' }
      points_reward { 100 }
      criteria { { streak_days: { gte: 7 } } }
    end

    trait :early_adopter do
      key { 'early_adopter' }
      name { 'Adoptador Temprano' }
      description { 'Te registraste en el primer mes' }
      icon { '🌟' }
      category { 'special' }
      tier { 'gold' }
      points_reward { 500 }
      criteria { { registered_before: '2024-02-01' } }
    end

    trait :gold_tier do
      tier { 'gold' }
      points_reward { 500 }
    end

    trait :platinum_tier do
      tier { 'platinum' }
      points_reward { 1000 }
    end
  end

  # Gamification Point Factory
  factory :gamification_point, class: 'Gamification::Point' do
    association :user
    amount { 100 }
    reason { 'Test points' }
    source { nil }
    metadata { {} }

    trait :with_source do
      association :source, factory: :proposal
    end

    trait :proposal_creation do
      amount { 50 }
      reason { 'Created a proposal' }
      association :source, factory: :proposal
    end

    trait :vote_cast do
      amount { 10 }
      reason { 'Cast a vote' }
    end

    trait :badge_reward do
      amount { 200 }
      reason { 'Badge earned: Test Badge' }
    end

    trait :large_amount do
      amount { 1000 }
    end
  end

  # Gamification UserBadge Factory
  factory :gamification_user_badge, class: 'Gamification::UserBadge' do
    association :user
    association :badge, factory: :gamification_badge
    earned_at { Time.current }
    metadata { {} }

    trait :with_metadata do
      metadata { { earned_on: 'test', special_note: 'First to earn!' } }
    end

    trait :recent do
      earned_at { 1.hour.ago }
    end

    trait :old do
      earned_at { 6.months.ago }
    end
  end

  # Gamification UserStats Factory
  # Note: Users automatically get gamification_user_stats via after_create callback in Gamifiable concern.
  # When using this factory with an existing user, use user.reload.gamification_user_stats.tap { |s| s.update!(...) }
  # or ensure the user is created without the factory triggering the callback.
  factory :gamification_user_stats, class: 'Gamification::UserStats' do
    # Use transient user to avoid creating a new user when one is provided
    transient do
      for_user { nil }
    end

    user { for_user || association(:user) }
    total_points { 0 }
    level { 1 }
    xp { 0 }
    current_streak { 0 }
    longest_streak { 0 }
    last_active_date { nil }
    stats { {} }

    # Skip creation if stats already exist for this user (from after_create callback)
    to_create do |instance|
      existing = Gamification::UserStats.find_by(user_id: instance.user_id)
      if existing
        # Update existing record with factory attributes
        existing.update!(
          total_points: instance.total_points,
          level: instance.level,
          xp: instance.xp,
          current_streak: instance.current_streak,
          longest_streak: instance.longest_streak,
          last_active_date: instance.last_active_date,
          stats: instance.stats
        )
        # Return the existing record
        instance.id = existing.id
        instance.reload
      else
        instance.save!
      end
    end

    trait :with_points do
      total_points { 500 }
      xp { 500 }
    end

    trait :level_5 do
      level { 5 }
      xp { 1000 }
      total_points { 1000 }
    end

    trait :level_10 do
      level { 10 }
      xp { 2500 }
      total_points { 2500 }
    end

    trait :level_20 do
      level { 20 }
      xp { 10_000 }
      total_points { 10_000 }
    end

    trait :with_streak do
      current_streak { 7 }
      longest_streak { 7 }
      last_active_date { Time.zone.today }
    end

    trait :long_streak do
      current_streak { 30 }
      longest_streak { 45 }
      last_active_date { Time.zone.today }
    end

    trait :active_today do
      last_active_date { Time.zone.today }
      current_streak { 1 }
    end

    trait :active_yesterday do
      last_active_date { Time.zone.yesterday }
      current_streak { 5 }
    end

    trait :inactive do
      last_active_date { 10.days.ago }
      current_streak { 0 }
    end
  end
end
