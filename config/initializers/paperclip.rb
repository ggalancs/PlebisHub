# frozen_string_literal: true

# NOTE: This file is kept for backwards compatibility during migration.
# The Paperclip gem has been replaced with ActiveStorage.
#
# To complete the migration:
# 1. Run: rails db:migrate (to create ActiveStorage tables)
# 2. Run: rails paperclip:migrate:all (to migrate existing files)
# 3. Delete this file after migration is complete
#
# For any custom encryption needs previously handled here,
# use Rails credentials instead: rails credentials:edit
#
# The old encrypt/decrypt methods using hardcoded passwords have been removed
# for security reasons. If you need encryption, use ActiveStorage's built-in
# encryption or Rails credentials.
