# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
#
# This file contained migration options from Rails 5.0 upgrade.
# Most options have been removed as they are now the default in Rails 7.2
# or have been deprecated/removed.
#
# DEPRECATED OPTIONS REMOVED (Rails 7.2 incompatible):
# - raise_on_unfiltered_parameters (removed in Rails 7.2)
# - halt_callback_chains_on_return_false (removed in Rails 5.2)
#
# The following are kept for backward compatibility but should be
# reviewed and potentially updated to modern defaults:

# Enable per-form CSRF tokens (modern default is true)
Rails.application.config.action_controller.per_form_csrf_tokens = true

# Enable origin-checking CSRF mitigation (modern default is true)
Rails.application.config.action_controller.forgery_protection_origin_check = true

# NOTE: `to_time_preserves_timezone` moved to config/application.rb. Framework
# defaults have to be set before initialization; assigning them here is a no-op
# because the Active Support railtie has already run.

# Require `belongs_to` associations by default (modern default is true)
# Set to false here for backward compatibility with existing data
Rails.application.config.active_record.belongs_to_required_by_default = false
