# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
#
# Rails 7.2 Framework Defaults
#
# These settings are the Rails 7.2 defaults. Since config.load_defaults 7.2
# is set in application.rb, these are already active. They are explicitly
# enabled here for documentation and clarity.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.
# https://guides.rubyonrails.org/upgrading_ruby_on_rails.html

# Controls whether Active Job's `#perform_later` and similar methods automatically defer
# the job queuing to after the current Active Record transaction is committed.
# This prevents jobs from being enqueued before the transaction commits.
Rails.application.config.active_job.enqueue_after_transaction_commit = :default

# Adds image/webp to the list of content types Active Storage considers as an image.
# Prevents automatic conversion to a fallback PNG for WebP images.
Rails.application.config.active_storage.web_image_content_types = %w[image/png image/jpeg image/gif image/webp]

# Enable validation of migration timestamps to prevent forward-dating of migration files.
Rails.application.config.active_record.validate_migration_timestamps = true

# Controls whether PostgreSQL adapter should decode dates automatically with manual queries.
Rails.application.config.active_record.postgresql_adapter_decode_dates = true

# Enable YJIT for Ruby 3.3+ for performance improvements.
# Disable if deploying to a memory-constrained environment.
Rails.application.config.yjit = true
