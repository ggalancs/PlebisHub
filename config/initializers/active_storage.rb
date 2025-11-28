# frozen_string_literal: true

# ActiveStorage Configuration
# Replaces Paperclip gem for file uploads
#
# Documentation: https://edgeguides.rubyonrails.org/active_storage_overview.html

Rails.application.config.after_initialize do
  # Set the service to use (configured in config/storage.yml)
  # Rails.application.config.active_storage.service = :local

  # Configure variant processor (uses MiniMagick by default)
  # Rails.application.config.active_storage.variant_processor = :mini_magick

  # Configure default URL options for direct uploads
  # Rails.application.config.active_storage.draw_routes = true

  # Purge unattached blobs after 2 days (default)
  # Rails.application.config.active_storage.replace_on_assign_to_many = false
end

# Note: Make sure config/storage.yml is properly configured
# Example storage.yml:
#
# local:
#   service: Disk
#   root: <%= Rails.root.join("storage") %>
#
# amazon:
#   service: S3
#   access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
#   secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
#   region: us-east-1
#   bucket: your_bucket
