# frozen_string_literal: true

# ========================================
# V2.0 Infrastructure Migration
# ========================================
# Creates tables for new v2.0 features:
# - Event sourcing
# - Advanced permissions
# - Analytics
# - Gamification
# - Messaging
# ========================================

class CreateV2Infrastructure < ActiveRecord::Migration[7.2]
  def change
    # ==================== Event Sourcing ====================
    create_table :persisted_events do |t|
      t.string :event_type, null: false, index: true
      t.jsonb :payload, null: false, default: {}
      t.jsonb :metadata, null: false, default: {}
      t.datetime :occurred_at, null: false, index: true

      t.timestamps

      t.index :payload, using: :gin
      t.index :metadata, using: :gin
    end

    # ==================== Advanced Permissions ====================
    create_table :roles do |t|
      t.string :name, null: false
      t.string :description
      t.string :scope, default: 'organization', null: false # global, organization, custom
      t.references :organization, foreign_key: true, null: true
      t.jsonb :metadata, default: {}, null: false

      t.timestamps

      t.index [:name, :organization_id], unique: true
    end

    create_table :permissions do |t|
      t.references :role, foreign_key: true, null: false
      t.string :resource, null: false  # proposals, users, votes, etc.
      t.string :action, null: false    # read, create, edit, delete, etc.
      t.string :scope, null: false     # own, organization, global
      t.jsonb :conditions, default: {} # Additional ABAC conditions

      t.timestamps

      t.index [:role_id, :resource, :action, :scope], name: 'index_permissions_on_role_resource_action_scope'
    end

    create_table :user_roles do |t|
      t.references :user, foreign_key: true, null: false
      t.references :role, foreign_key: true, null: false
      t.references :organization, foreign_key: true, null: true
      t.datetime :expires_at

      t.timestamps

      t.index [:user_id, :role_id, :organization_id], unique: true, name: 'index_user_roles_unique'
    end

    # ==================== Analytics ====================
    create_table :analytics_metrics do |t|
      t.string :name, null: false, index: true
      t.string :category, null: false, index: true
      t.decimal :value, precision: 20, scale: 5, null: false
      t.jsonb :dimensions, default: {}, null: false
      t.references :organization, foreign_key: true, null: true
      t.date :date, null: false, index: true
      t.datetime :timestamp, null: false, index: true

      t.timestamps

      t.index :dimensions, using: :gin
      t.index [:name, :date, :organization_id], name: 'index_analytics_metrics_on_name_date_org'
    end

    create_table :analytics_dashboards do |t|
      t.string :name, null: false
      t.text :description
      t.jsonb :config, default: {}, null: false
      t.references :user, foreign_key: true, null: false
      t.references :organization, foreign_key: true, null: true
      t.boolean :shared, default: false

      t.timestamps
    end

    # ==================== Gamification ====================
    create_table :gamification_points do |t|
      t.references :user, foreign_key: true, null: false, index: true
      t.integer :amount, null: false
      t.string :reason, null: false
      t.string :source_type
      t.bigint :source_id
      t.jsonb :metadata, default: {}

      t.timestamps

      t.index [:source_type, :source_id]
    end

    create_table :gamification_badges do |t|
      t.string :key, null: false, unique: true, index: true
      t.string :name, null: false
      t.text :description
      t.string :icon
      t.integer :points_reward, default: 0
      t.jsonb :criteria, default: {}, null: false
      t.string :category
      t.string :tier # bronze, silver, gold, platinum

      t.timestamps
    end

    create_table :gamification_user_badges do |t|
      t.references :user, foreign_key: true, null: false
      t.references :badge, foreign_key: { to_table: :gamification_badges }, null: false
      t.datetime :earned_at, null: false
      t.jsonb :metadata, default: {}

      t.timestamps

      t.index [:user_id, :badge_id], unique: true
    end

    create_table :gamification_levels do |t|
      t.integer :level, null: false, unique: true, index: true
      t.string :name, null: false
      t.integer :xp_required, null: false
      t.jsonb :rewards, default: {}

      t.timestamps
    end

    create_table :gamification_user_stats do |t|
      t.references :user, foreign_key: true, null: false, unique: true, index: true
      t.integer :total_points, default: 0, null: false
      t.integer :level, default: 1, null: false
      t.integer :xp, default: 0, null: false
      t.integer :current_streak, default: 0, null: false
      t.integer :longest_streak, default: 0, null: false
      t.date :last_active_date
      t.jsonb :stats, default: {}, null: false

      t.timestamps

      t.index :total_points
      t.index :level
    end

    create_table :gamification_challenges do |t|
      t.string :name, null: false
      t.text :description
      t.string :challenge_type # daily, weekly, monthly, special
      t.jsonb :requirements, default: {}, null: false
      t.integer :points_reward
      t.references :badge, foreign_key: { to_table: :gamification_badges }, null: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :active, default: true

      t.timestamps

      t.index :challenge_type
      t.index [:starts_at, :ends_at]
    end

    # ==================== Messaging ====================
    create_table :messaging_conversations do |t|
      t.string :conversation_type, null: false, default: 'direct' # direct, group
      t.string :name # For group conversations
      t.references :organization, foreign_key: true, null: true
      t.datetime :last_message_at
      t.jsonb :metadata, default: {}

      t.timestamps

      t.index :conversation_type
      t.index :last_message_at
    end

    create_table :messaging_conversation_participants do |t|
      t.references :conversation, foreign_key: { to_table: :messaging_conversations }, null: false
      t.references :user, foreign_key: true, null: false
      t.datetime :last_read_at
      t.datetime :joined_at, null: false
      t.datetime :left_at
      t.boolean :notifications_enabled, default: true

      t.timestamps

      t.index [:conversation_id, :user_id], unique: true, name: 'index_conversation_participants_unique'
    end

    create_table :messaging_messages do |t|
      t.references :conversation, foreign_key: { to_table: :messaging_conversations }, null: false
      t.references :sender, foreign_key: { to_table: :users }, null: false
      t.text :body
      t.string :message_type, default: 'text' # text, system, file
      t.jsonb :metadata, default: {}

      t.timestamps

      t.index [:conversation_id, :created_at]
    end

    create_table :messaging_message_reads do |t|
      t.references :message, foreign_key: { to_table: :messaging_messages }, null: false
      t.references :user, foreign_key: true, null: false
      t.datetime :read_at, null: false

      t.timestamps

      t.index [:message_id, :user_id], unique: true
    end

    create_table :messaging_message_reactions do |t|
      t.references :message, foreign_key: { to_table: :messaging_messages }, null: false
      t.references :user, foreign_key: true, null: false
      t.string :emoji, null: false

      t.timestamps

      t.index [:message_id, :user_id, :emoji], unique: true, name: 'index_message_reactions_unique'
    end

    # ==================== Social Features ====================
    create_table :social_follows do |t|
      t.references :follower, foreign_key: { to_table: :users }, null: false
      t.references :followee, foreign_key: { to_table: :users }, null: false

      t.timestamps

      t.index [:follower_id, :followee_id], unique: true
      t.index [:followee_id, :follower_id]
    end

    create_table :social_activities do |t|
      t.references :user, foreign_key: true, null: false
      t.string :action, null: false # created, updated, voted, commented, etc.
      t.string :trackable_type, null: false
      t.bigint :trackable_id, null: false
      t.jsonb :metadata, default: {}

      t.timestamps

      t.index [:trackable_type, :trackable_id]
      t.index [:user_id, :created_at]
    end

    # ==================== Notifications ====================
    create_table :notifications do |t|
      t.references :user, foreign_key: true, null: false, index: true
      t.string :notification_type, null: false
      t.string :title, null: false
      t.text :body
      t.string :notifiable_type
      t.bigint :notifiable_id
      t.datetime :read_at
      t.datetime :sent_at
      t.jsonb :channels, default: [], null: false # ['push', 'email', 'in_app']
      t.jsonb :metadata, default: {}

      t.timestamps

      t.index [:notifiable_type, :notifiable_id]
      t.index [:user_id, :read_at]
      t.index :notification_type
    end

    # ==================== Performance Indexes ====================
    # Add additional composite indexes for common queries
    add_index :gamification_user_stats, [:level, :total_points], name: 'index_leaderboard'
    add_index :analytics_metrics, [:category, :date, :organization_id], name: 'index_analytics_category_lookup'
  end
end
