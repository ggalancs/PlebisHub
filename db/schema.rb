# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_11_30_085841) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "analytics_dashboards", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.jsonb "config", default: {}, null: false
    t.bigint "user_id", null: false
    t.bigint "organization_id"
    t.boolean "shared", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_analytics_dashboards_on_organization_id"
    t.index ["user_id"], name: "index_analytics_dashboards_on_user_id"
  end

  create_table "analytics_metrics", force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
    t.decimal "value", precision: 20, scale: 5, null: false
    t.jsonb "dimensions", default: {}, null: false
    t.bigint "organization_id"
    t.date "date", null: false
    t.datetime "timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "date", "organization_id"], name: "index_analytics_category_lookup"
    t.index ["category"], name: "index_analytics_metrics_on_category"
    t.index ["date"], name: "index_analytics_metrics_on_date"
    t.index ["dimensions"], name: "index_analytics_metrics_on_dimensions", using: :gin
    t.index ["name", "date", "organization_id"], name: "index_analytics_metrics_on_name_date_org"
    t.index ["name"], name: "index_analytics_metrics_on_name"
    t.index ["organization_id"], name: "index_analytics_metrics_on_organization_id"
    t.index ["timestamp"], name: "index_analytics_metrics_on_timestamp"
  end

  create_table "brand_settings", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "scope", default: "global", null: false
    t.bigint "organization_id"
    t.string "theme_id", default: "default", null: false
    t.string "theme_name"
    t.string "primary_color", limit: 7
    t.string "primary_light_color", limit: 7
    t.string "primary_dark_color", limit: 7
    t.string "secondary_color", limit: 7
    t.string "secondary_light_color", limit: 7
    t.string "secondary_dark_color", limit: 7
    t.boolean "active", default: true, null: false
    t.integer "version", default: 1, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_brand_settings_on_active"
    t.index ["created_at"], name: "index_brand_settings_on_created_at"
    t.index ["name"], name: "index_brand_settings_on_name"
    t.index ["organization_id"], name: "index_brand_settings_on_organization_id"
    t.index ["scope", "organization_id"], name: "idx_brand_settings_org_unique", unique: true, where: "((scope)::text = 'organization'::text)"
    t.index ["theme_id"], name: "index_brand_settings_on_theme_id"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "categories_posts", id: :serial, force: :cascade do |t|
    t.integer "post_id"
    t.integer "category_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["category_id"], name: "index_categories_posts_on_category_id"
    t.index ["post_id"], name: "index_categories_posts_on_post_id"
  end

  create_table "collaborations", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "amount"
    t.integer "frequency"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "payment_type"
    t.integer "ccc_entity"
    t.integer "ccc_office"
    t.integer "ccc_dc"
    t.bigint "ccc_account"
    t.string "iban_account"
    t.string "iban_bic"
    t.datetime "deleted_at", precision: nil
    t.integer "status", default: 2
    t.string "redsys_identifier"
    t.datetime "redsys_expiration", precision: nil
    t.string "non_user_document_vatid"
    t.string "non_user_email"
    t.text "non_user_data"
    t.boolean "for_autonomy_cc"
    t.boolean "for_town_cc"
    t.boolean "for_island_cc"
    t.date "mail_send_at"
    t.index ["deleted_at"], name: "index_collaborations_on_deleted_at"
    t.index ["non_user_document_vatid"], name: "index_collaborations_on_non_user_document_vatid"
    t.index ["non_user_email"], name: "index_collaborations_on_non_user_email"
  end

  create_table "election_location_questions", id: :serial, force: :cascade do |t|
    t.integer "election_location_id"
    t.text "title"
    t.text "description"
    t.string "voting_system"
    t.string "layout"
    t.integer "winners"
    t.integer "minimum"
    t.integer "maximum"
    t.boolean "random_order"
    t.string "totals"
    t.string "options_headers"
    t.text "options"
  end

  create_table "election_locations", id: :serial, force: :cascade do |t|
    t.integer "election_id"
    t.string "location"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "agora_version"
    t.string "override"
    t.text "title"
    t.string "layout"
    t.text "description"
    t.string "share_text"
    t.string "theme"
    t.integer "new_agora_version"
  end

  create_table "elections", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "agora_election_id"
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "close_message"
    t.integer "scope"
    t.string "info_url"
    t.string "server"
    t.datetime "user_created_at_max", precision: nil
    t.integer "priority"
    t.string "info_text"
    t.integer "flags"
    t.string "meta_description"
    t.string "meta_image"
    t.string "counter_key"
    t.string "external_link"
    t.string "voter_id_template"
    t.integer "election_type", default: 0, null: false
    t.string "census_file_file_name"
    t.string "census_file_content_type"
    t.integer "census_file_file_size"
    t.datetime "census_file_updated_at", precision: nil
  end

  create_table "engine_activations", force: :cascade do |t|
    t.string "engine_name", null: false
    t.boolean "enabled", default: false, null: false
    t.jsonb "configuration", default: {}
    t.text "description"
    t.integer "load_priority", default: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enabled"], name: "index_engine_activations_on_enabled"
    t.index ["engine_name"], name: "index_engine_activations_on_engine_name", unique: true
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at", precision: nil
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "gamification_badges", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description"
    t.string "icon"
    t.integer "points_reward", default: 0
    t.jsonb "criteria", default: {}, null: false
    t.string "category"
    t.string "tier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_gamification_badges_on_key", unique: true
  end

  create_table "gamification_challenges", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "challenge_type"
    t.jsonb "requirements", default: {}, null: false
    t.integer "points_reward"
    t.bigint "badge_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_gamification_challenges_on_badge_id"
    t.index ["challenge_type"], name: "index_gamification_challenges_on_challenge_type"
    t.index ["starts_at", "ends_at"], name: "index_gamification_challenges_on_starts_at_and_ends_at"
  end

  create_table "gamification_levels", force: :cascade do |t|
    t.integer "level", null: false
    t.string "name", null: false
    t.integer "xp_required", null: false
    t.jsonb "rewards", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["level"], name: "index_gamification_levels_on_level", unique: true
  end

  create_table "gamification_points", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "amount", null: false
    t.string "reason", null: false
    t.string "source_type"
    t.bigint "source_id"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type", "source_id"], name: "index_gamification_points_on_source_type_and_source_id"
    t.index ["user_id"], name: "index_gamification_points_on_user_id"
  end

  create_table "gamification_user_badges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "badge_id", null: false
    t.datetime "earned_at", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_gamification_user_badges_on_badge_id"
    t.index ["user_id", "badge_id"], name: "index_gamification_user_badges_on_user_id_and_badge_id", unique: true
    t.index ["user_id"], name: "index_gamification_user_badges_on_user_id"
  end

  create_table "gamification_user_stats", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "total_points", default: 0, null: false
    t.integer "level", default: 1, null: false
    t.integer "xp", default: 0, null: false
    t.integer "current_streak", default: 0, null: false
    t.integer "longest_streak", default: 0, null: false
    t.date "last_active_date"
    t.jsonb "stats", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["level", "total_points"], name: "index_leaderboard"
    t.index ["level"], name: "index_gamification_user_stats_on_level"
    t.index ["total_points"], name: "index_gamification_user_stats_on_total_points"
    t.index ["user_id"], name: "index_gamification_user_stats_on_user_id", unique: true
  end

  create_table "impulsa_edition_categories", id: :serial, force: :cascade do |t|
    t.integer "impulsa_edition_id"
    t.string "name", null: false
    t.integer "category_type", null: false
    t.integer "winners"
    t.integer "prize"
    t.string "territories"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "only_authors"
    t.string "coofficial_language"
    t.string "schedule_model_override_file_name"
    t.string "schedule_model_override_content_type"
    t.integer "schedule_model_override_file_size"
    t.datetime "schedule_model_override_updated_at", precision: nil
    t.string "activities_resources_model_override_file_name"
    t.string "activities_resources_model_override_content_type"
    t.integer "activities_resources_model_override_file_size"
    t.datetime "activities_resources_model_override_updated_at", precision: nil
    t.string "requested_budget_model_override_file_name"
    t.string "requested_budget_model_override_content_type"
    t.integer "requested_budget_model_override_file_size"
    t.datetime "requested_budget_model_override_updated_at", precision: nil
    t.string "monitoring_evaluation_model_override_file_name"
    t.string "monitoring_evaluation_model_override_content_type"
    t.integer "monitoring_evaluation_model_override_file_size"
    t.datetime "monitoring_evaluation_model_override_updated_at", precision: nil
    t.text "wizard"
    t.text "evaluation"
    t.integer "flags"
    t.index ["impulsa_edition_id"], name: "index_impulsa_edition_categories_on_impulsa_edition_id"
  end

  create_table "impulsa_edition_topics", id: :serial, force: :cascade do |t|
    t.integer "impulsa_edition_id"
    t.string "name"
    t.index ["impulsa_edition_id"], name: "index_impulsa_edition_topics_on_impulsa_edition_id"
  end

  create_table "impulsa_editions", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "start_at", precision: nil
    t.datetime "new_projects_until", precision: nil
    t.datetime "review_projects_until", precision: nil
    t.datetime "validation_projects_until", precision: nil
    t.datetime "ends_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "schedule_model_file_name"
    t.string "schedule_model_content_type"
    t.integer "schedule_model_file_size"
    t.datetime "schedule_model_updated_at", precision: nil
    t.string "activities_resources_model_file_name"
    t.string "activities_resources_model_content_type"
    t.integer "activities_resources_model_file_size"
    t.datetime "activities_resources_model_updated_at", precision: nil
    t.string "requested_budget_model_file_name"
    t.string "requested_budget_model_content_type"
    t.integer "requested_budget_model_file_size"
    t.datetime "requested_budget_model_updated_at", precision: nil
    t.string "monitoring_evaluation_model_file_name"
    t.string "monitoring_evaluation_model_content_type"
    t.integer "monitoring_evaluation_model_file_size"
    t.datetime "monitoring_evaluation_model_updated_at", precision: nil
    t.text "legal"
    t.datetime "votings_start_at", precision: nil
    t.datetime "publish_results_at", precision: nil
    t.text "description"
    t.string "email"
  end

  create_table "impulsa_project_state_transitions", id: :serial, force: :cascade do |t|
    t.integer "impulsa_project_id"
    t.string "namespace"
    t.string "event"
    t.string "from"
    t.string "to"
    t.datetime "created_at", precision: nil
    t.index ["impulsa_project_id"], name: "index_impulsa_project_state_transitions_on_impulsa_project_id"
  end

  create_table "impulsa_project_topics", id: :serial, force: :cascade do |t|
    t.integer "impulsa_project_id"
    t.integer "impulsa_edition_topic_id"
    t.index ["impulsa_edition_topic_id"], name: "index_impulsa_project_topics_on_impulsa_edition_topic_id"
    t.index ["impulsa_project_id"], name: "index_impulsa_project_topics_on_impulsa_project_id"
  end

  create_table "impulsa_projects", id: :serial, force: :cascade do |t|
    t.integer "impulsa_edition_category_id"
    t.integer "user_id"
    t.integer "status", default: 0, null: false
    t.string "review_fields"
    t.text "additional_contact"
    t.text "counterpart_information"
    t.string "name", null: false
    t.string "authority"
    t.string "authority_name"
    t.string "authority_phone"
    t.string "authority_email"
    t.string "organization_name"
    t.text "organization_address"
    t.string "organization_web"
    t.string "organization_nif"
    t.integer "organization_year"
    t.string "organization_legal_name"
    t.string "organization_legal_nif"
    t.text "organization_mission"
    t.text "career"
    t.string "counterpart"
    t.text "territorial_context"
    t.text "short_description"
    t.text "long_description"
    t.text "aim"
    t.text "metodology"
    t.text "population_segment"
    t.string "video_link"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at", precision: nil
    t.string "endorsement_file_name"
    t.string "endorsement_content_type"
    t.integer "endorsement_file_size"
    t.datetime "endorsement_updated_at", precision: nil
    t.string "register_entry_file_name"
    t.string "register_entry_content_type"
    t.integer "register_entry_file_size"
    t.datetime "register_entry_updated_at", precision: nil
    t.string "statutes_file_name"
    t.string "statutes_content_type"
    t.integer "statutes_file_size"
    t.datetime "statutes_updated_at", precision: nil
    t.string "responsible_nif_file_name"
    t.string "responsible_nif_content_type"
    t.integer "responsible_nif_file_size"
    t.datetime "responsible_nif_updated_at", precision: nil
    t.string "fiscal_obligations_certificate_file_name"
    t.string "fiscal_obligations_certificate_content_type"
    t.integer "fiscal_obligations_certificate_file_size"
    t.datetime "fiscal_obligations_certificate_updated_at", precision: nil
    t.string "labor_obligations_certificate_file_name"
    t.string "labor_obligations_certificate_content_type"
    t.integer "labor_obligations_certificate_file_size"
    t.datetime "labor_obligations_certificate_updated_at", precision: nil
    t.string "last_fiscal_year_report_of_activities_file_name"
    t.string "last_fiscal_year_report_of_activities_content_type"
    t.integer "last_fiscal_year_report_of_activities_file_size"
    t.datetime "last_fiscal_year_report_of_activities_updated_at", precision: nil
    t.string "last_fiscal_year_annual_accounts_file_name"
    t.string "last_fiscal_year_annual_accounts_content_type"
    t.integer "last_fiscal_year_annual_accounts_file_size"
    t.datetime "last_fiscal_year_annual_accounts_updated_at", precision: nil
    t.string "schedule_file_name"
    t.string "schedule_content_type"
    t.integer "schedule_file_size"
    t.datetime "schedule_updated_at", precision: nil
    t.string "activities_resources_file_name"
    t.string "activities_resources_content_type"
    t.integer "activities_resources_file_size"
    t.datetime "activities_resources_updated_at", precision: nil
    t.string "requested_budget_file_name"
    t.string "requested_budget_content_type"
    t.integer "requested_budget_file_size"
    t.datetime "requested_budget_updated_at", precision: nil
    t.string "monitoring_evaluation_file_name"
    t.string "monitoring_evaluation_content_type"
    t.integer "monitoring_evaluation_file_size"
    t.datetime "monitoring_evaluation_updated_at", precision: nil
    t.integer "organization_type"
    t.string "scanned_nif_file_name"
    t.string "scanned_nif_content_type"
    t.integer "scanned_nif_file_size"
    t.datetime "scanned_nif_updated_at", precision: nil
    t.string "home_certificate_file_name"
    t.string "home_certificate_content_type"
    t.integer "home_certificate_file_size"
    t.datetime "home_certificate_updated_at", precision: nil
    t.string "bank_certificate_file_name"
    t.string "bank_certificate_content_type"
    t.integer "bank_certificate_file_size"
    t.datetime "bank_certificate_updated_at", precision: nil
    t.boolean "coofficial_translation"
    t.string "coofficial_name"
    t.text "coofficial_short_description"
    t.string "coofficial_video_link"
    t.integer "total_budget"
    t.text "coofficial_territorial_context"
    t.text "coofficial_long_description"
    t.text "coofficial_aim"
    t.text "coofficial_metodology"
    t.text "coofficial_population_segment"
    t.text "coofficial_organization_mission"
    t.text "coofficial_career"
    t.integer "evaluator1_id"
    t.text "evaluator1_invalid_reasons"
    t.string "evaluator1_analysis_file_name"
    t.string "evaluator1_analysis_content_type"
    t.integer "evaluator1_analysis_file_size"
    t.datetime "evaluator1_analysis_updated_at", precision: nil
    t.integer "evaluator2_id"
    t.text "evaluator2_invalid_reasons"
    t.string "evaluator2_analysis_file_name"
    t.string "evaluator2_analysis_content_type"
    t.integer "evaluator2_analysis_file_size"
    t.datetime "evaluator2_analysis_updated_at", precision: nil
    t.integer "votes", default: 0
    t.text "wizard_values"
    t.string "state"
    t.string "wizard_step"
    t.text "wizard_review"
    t.text "evaluator1_evaluation"
    t.text "evaluator2_evaluation"
    t.string "evaluation_result"
    t.index ["impulsa_edition_category_id"], name: "index_impulsa_projects_on_impulsa_edition_category_id"
    t.index ["user_id"], name: "index_impulsa_projects_on_user_id"
  end

  create_table "messaging_conversation_participants", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "user_id", null: false
    t.datetime "last_read_at"
    t.datetime "joined_at", null: false
    t.datetime "left_at"
    t.boolean "notifications_enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "user_id"], name: "index_conversation_participants_unique", unique: true
    t.index ["conversation_id"], name: "index_messaging_conversation_participants_on_conversation_id"
    t.index ["user_id"], name: "index_messaging_conversation_participants_on_user_id"
  end

  create_table "messaging_conversations", force: :cascade do |t|
    t.string "conversation_type", default: "direct", null: false
    t.string "name"
    t.bigint "organization_id"
    t.datetime "last_message_at"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_type"], name: "index_messaging_conversations_on_conversation_type"
    t.index ["last_message_at"], name: "index_messaging_conversations_on_last_message_at"
    t.index ["organization_id"], name: "index_messaging_conversations_on_organization_id"
  end

  create_table "messaging_message_reactions", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "user_id", null: false
    t.string "emoji", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "user_id", "emoji"], name: "index_message_reactions_unique", unique: true
    t.index ["message_id"], name: "index_messaging_message_reactions_on_message_id"
    t.index ["user_id"], name: "index_messaging_message_reactions_on_user_id"
  end

  create_table "messaging_message_reads", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "user_id", null: false
    t.datetime "read_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "user_id"], name: "index_messaging_message_reads_on_message_id_and_user_id", unique: true
    t.index ["message_id"], name: "index_messaging_message_reads_on_message_id"
    t.index ["user_id"], name: "index_messaging_message_reads_on_user_id"
  end

  create_table "messaging_messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "sender_id", null: false
    t.text "body"
    t.string "message_type", default: "text"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messaging_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messaging_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messaging_messages_on_sender_id"
  end

  create_table "microcredit_loans", id: :serial, force: :cascade do |t|
    t.integer "microcredit_id"
    t.integer "amount"
    t.integer "user_id"
    t.text "user_data"
    t.datetime "confirmed_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "counted_at", precision: nil
    t.string "ip"
    t.string "document_vatid"
    t.datetime "discarded_at", precision: nil
    t.datetime "returned_at", precision: nil
    t.integer "transferred_to_id"
    t.string "iban_account"
    t.string "iban_bic"
    t.integer "microcredit_option_id"
    t.boolean "wants_information_by_email", default: true
    t.index ["document_vatid"], name: "index_microcredit_loans_on_document_vatid"
    t.index ["ip"], name: "index_microcredit_loans_on_ip"
    t.index ["microcredit_id"], name: "index_MicrocreditLoan_on_microcredit_id"
  end

  create_table "microcredit_options", id: :serial, force: :cascade do |t|
    t.integer "microcredit_id"
    t.string "name"
    t.integer "parent_id"
    t.string "intern_code"
    t.index ["microcredit_id"], name: "index_microcredit_options_on_microcredit_id"
  end

  create_table "microcredits", id: :serial, force: :cascade do |t|
    t.string "title"
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.datetime "reset_at", precision: nil
    t.text "limits"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "account_number"
    t.string "agreement_link"
    t.string "contact_phone"
    t.integer "total_goal"
    t.string "slug"
    t.text "subgoals"
    t.string "renewal_terms_file_name"
    t.string "renewal_terms_content_type"
    t.integer "renewal_terms_file_size"
    t.datetime "renewal_terms_updated_at", precision: nil
    t.string "budget_link"
    t.integer "flags", default: 0
    t.integer "priority", default: 0
    t.integer "bank_counted_amount", default: 0
    t.boolean "remarked", default: false
    t.index ["slug"], name: "index_microcredits_on_slug", unique: true
  end

  create_table "militant_records", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "begin_verified", precision: nil
    t.datetime "end_verified", precision: nil
    t.datetime "begin_payment", precision: nil
    t.datetime "end_payment", precision: nil
    t.integer "payment_type"
    t.integer "amount"
    t.boolean "is_militant"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "vote_circle_name"
    t.datetime "begin_in_vote_circle", precision: nil
    t.datetime "end_in_vote_circle", precision: nil
  end

  create_table "notice_registrars", id: :serial, force: :cascade do |t|
    t.string "registration_id"
    t.boolean "status"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "notices", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.string "link"
    t.datetime "final_valid_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "sent_at", precision: nil
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notification_type", null: false
    t.string "title", null: false
    t.text "body"
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.datetime "read_at"
    t.datetime "sent_at"
    t.jsonb "channels", default: [], null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.integer "status"
    t.datetime "payable_at", precision: nil
    t.datetime "payed_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.integer "parent_id"
    t.string "parent_type"
    t.string "reference"
    t.integer "amount"
    t.boolean "first"
    t.integer "payment_type"
    t.string "payment_identifier"
    t.text "payment_response"
    t.string "town_code"
    t.string "autonomy_code"
    t.string "island_code"
    t.string "vote_circle_autonomy_code"
    t.string "vote_circle_town_code"
    t.string "vote_circle_island_code"
    t.integer "vote_circle_id"
    t.string "target_territory"
    t.index ["parent_id"], name: "index_Order_on_parent_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "id_form"
    t.string "slug"
    t.boolean "require_login"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.string "link"
    t.string "meta_description"
    t.string "meta_image"
    t.boolean "promoted", default: false
    t.string "text_button"
    t.integer "priority", default: 0, null: false
    t.index ["deleted_at"], name: "index_pages_on_deleted_at"
  end

  create_table "participation_teams", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "active"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "participation_teams_users", id: false, force: :cascade do |t|
    t.integer "participation_team_id"
    t.integer "user_id"
    t.index ["participation_team_id"], name: "index_participation_teams_users_on_participation_team_id"
    t.index ["user_id"], name: "index_participation_teams_users_on_user_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.string "resource", null: false
    t.string "action", null: false
    t.string "scope", null: false
    t.jsonb "conditions", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id", "resource", "action", "scope"], name: "index_permissions_on_role_resource_action_scope"
    t.index ["role_id"], name: "index_permissions_on_role_id"
  end

  create_table "persisted_events", force: :cascade do |t|
    t.string "event_type", null: false
    t.jsonb "payload", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_persisted_events_on_event_type"
    t.index ["metadata"], name: "index_persisted_events_on_metadata", using: :gin
    t.index ["occurred_at"], name: "index_persisted_events_on_occurred_at"
    t.index ["payload"], name: "index_persisted_events_on_payload", using: :gin
  end

  create_table "posts", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "slug"
    t.integer "status"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "media_url"
  end

  create_table "proposals", id: :serial, force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.integer "votes", default: 0
    t.string "reddit_url"
    t.string "reddit_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "reddit_threshold", default: false
    t.string "image_url"
    t.integer "supports_count", default: 0
    t.integer "hotness", default: 0
    t.string "author"
  end

  create_table "report_groups", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "proc"
    t.integer "width"
    t.string "label"
    t.string "data_label"
    t.text "whitelist"
    t.text "blacklist"
    t.integer "minimum"
    t.string "minimum_label"
    t.string "visualization"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.jsonb "transformation_rules"
    t.string "transform_type"
    t.index ["transform_type"], name: "index_report_groups_on_transform_type"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "query"
    t.text "main_group"
    t.text "groups"
    t.text "results"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "version_at", precision: nil
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "scope", default: "organization", null: false
    t.bigint "organization_id"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "organization_id"], name: "index_roles_on_name_and_organization_id", unique: true
    t.index ["organization_id"], name: "index_roles_on_organization_id"
  end

  create_table "simple_captcha_data", id: :serial, force: :cascade do |t|
    t.string "key", limit: 40
    t.string "value", limit: 6
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["key"], name: "idx_key"
  end

  create_table "social_activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.string "trackable_type", null: false
    t.bigint "trackable_id", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trackable_type", "trackable_id"], name: "index_social_activities_on_trackable_type_and_trackable_id"
    t.index ["user_id", "created_at"], name: "index_social_activities_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_social_activities_on_user_id"
  end

  create_table "social_follows", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followee_id", "follower_id"], name: "index_social_follows_on_followee_id_and_follower_id"
    t.index ["followee_id"], name: "index_social_follows_on_followee_id"
    t.index ["follower_id", "followee_id"], name: "index_social_follows_on_follower_id_and_followee_id", unique: true
    t.index ["follower_id"], name: "index_social_follows_on_follower_id"
  end

  create_table "spam_filters", id: :serial, force: :cascade do |t|
    t.string "name"
    t.text "code"
    t.text "data"
    t.string "query"
    t.boolean "active"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.jsonb "rules_json"
    t.string "filter_type"
    t.index ["filter_type"], name: "index_spam_filters_on_filter_type"
  end

  create_table "supports", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "proposal_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "theme_settings", force: :cascade do |t|
    t.string "name", null: false
    t.string "primary_color", limit: 7, default: "#612d62"
    t.string "secondary_color", limit: 7, default: "#269283"
    t.string "accent_color", limit: 7, default: "#954e99"
    t.string "font_primary", default: "Inter"
    t.string "font_display", default: "Montserrat"
    t.string "logo_url", limit: 500
    t.string "favicon_url", limit: 500
    t.text "custom_css"
    t.boolean "is_active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_theme_settings_on_active_unique", unique: true, where: "(is_active = true)"
    t.index ["name"], name: "index_theme_settings_on_name", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.bigint "organization_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_user_roles_on_organization_id"
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id", "organization_id"], name: "index_user_roles_unique", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "user_verifications", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "author_id"
    t.datetime "processed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "front_vatid_file_name"
    t.string "front_vatid_content_type"
    t.integer "front_vatid_file_size"
    t.datetime "front_vatid_updated_at", precision: nil
    t.string "back_vatid_file_name"
    t.string "back_vatid_content_type"
    t.integer "back_vatid_file_size"
    t.datetime "back_vatid_updated_at", precision: nil
    t.boolean "wants_card"
    t.integer "status", default: 0
    t.text "comment"
    t.date "born_at"
    t.integer "priority", default: 0, null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "first_name"
    t.string "last_name"
    t.date "born_at"
    t.boolean "wants_newsletter"
    t.integer "document_type"
    t.string "document_vatid"
    t.boolean "admin"
    t.string "address"
    t.string "town"
    t.string "province"
    t.string "postal_code"
    t.string "country"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "phone"
    t.string "sms_confirmation_token"
    t.datetime "confirmation_sms_sent_at", precision: nil
    t.datetime "sms_confirmed_at", precision: nil
    t.boolean "has_legacy_password"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.string "old_circle_data"
    t.datetime "deleted_at", precision: nil
    t.string "unconfirmed_phone"
    t.boolean "wants_participation"
    t.string "vote_town"
    t.integer "flags", default: 0, null: false
    t.datetime "participation_team_at", precision: nil
    t.datetime "sms_check_at", precision: nil
    t.string "vote_district"
    t.string "gender"
    t.boolean "wants_information_by_sms", default: true
    t.integer "vote_circle_id"
    t.datetime "vote_circle_changed_at", precision: nil
    t.string "qr_hash"
    t.string "qr_secret"
    t.datetime "qr_created_at", precision: nil
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at", "document_vatid"], name: "index_users_on_deleted_at_and_document_vatid", unique: true
    t.index ["deleted_at", "email"], name: "index_users_on_deleted_at_and_email", unique: true
    t.index ["deleted_at", "phone"], name: "index_users_on_deleted_at_and_phone", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["document_vatid"], name: "index_users_on_document_vatid"
    t.index ["email"], name: "index_users_on_email"
    t.index ["flags"], name: "index_users_on_flags"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["sms_confirmation_token"], name: "index_users_on_sms_confirmation_token", unique: true
    t.index ["vote_town"], name: "index_User_on_vote_town"
  end

  create_table "versions", id: :serial, force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "vote_circles", id: :serial, force: :cascade do |t|
    t.string "original_name"
    t.string "original_code"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "code"
    t.string "name"
    t.string "island_code"
    t.integer "region_area_id"
    t.string "town"
    t.integer "kind"
    t.string "country_code"
    t.string "autonomy_code"
    t.string "province_code"
  end

  create_table "votes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "election_id"
    t.string "voter_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "deleted_at", precision: nil
    t.integer "agora_id"
    t.integer "paper_authority_id"
    t.index ["deleted_at"], name: "index_votes_on_deleted_at"
    t.index ["user_id", "election_id"], name: "index_votes_on_user_election_unique", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "analytics_dashboards", "users"
  add_foreign_key "gamification_challenges", "gamification_badges", column: "badge_id"
  add_foreign_key "gamification_points", "users"
  add_foreign_key "gamification_user_badges", "gamification_badges", column: "badge_id"
  add_foreign_key "gamification_user_badges", "users"
  add_foreign_key "gamification_user_stats", "users"
  add_foreign_key "impulsa_edition_categories", "impulsa_editions"
  add_foreign_key "impulsa_edition_topics", "impulsa_editions"
  add_foreign_key "impulsa_project_state_transitions", "impulsa_projects"
  add_foreign_key "impulsa_project_topics", "impulsa_edition_topics"
  add_foreign_key "impulsa_project_topics", "impulsa_projects"
  add_foreign_key "impulsa_projects", "impulsa_edition_categories"
  add_foreign_key "impulsa_projects", "users"
  add_foreign_key "messaging_conversation_participants", "messaging_conversations", column: "conversation_id"
  add_foreign_key "messaging_conversation_participants", "users"
  add_foreign_key "messaging_message_reactions", "messaging_messages", column: "message_id"
  add_foreign_key "messaging_message_reactions", "users"
  add_foreign_key "messaging_message_reads", "messaging_messages", column: "message_id"
  add_foreign_key "messaging_message_reads", "users"
  add_foreign_key "messaging_messages", "messaging_conversations", column: "conversation_id"
  add_foreign_key "messaging_messages", "users", column: "sender_id"
  add_foreign_key "microcredit_loans", "microcredit_options"
  add_foreign_key "notifications", "users"
  add_foreign_key "permissions", "roles"
  add_foreign_key "social_activities", "users"
  add_foreign_key "social_follows", "users", column: "followee_id"
  add_foreign_key "social_follows", "users", column: "follower_id"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "user_verifications", "users", column: "author_id"
end
