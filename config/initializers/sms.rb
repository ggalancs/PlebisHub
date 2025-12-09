# frozen_string_literal: true

# Load SMS module at app startup
# The file defines SMS (all caps) instead of Sms (CamelCase), which doesn't
# match Zeitwerk's naming conventions, so we need to load it explicitly
load Rails.root.join('lib', 'sms.rb')
