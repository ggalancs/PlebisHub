# frozen_string_literal: true

# Explicitly require custom validators to ensure they're loaded
# Rails 7 with Zeitwerk may not auto-load validators in some cases
require Rails.root.join('app', 'validators', 'email_validator.rb')
