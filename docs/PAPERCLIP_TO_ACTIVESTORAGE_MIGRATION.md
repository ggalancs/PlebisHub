# Paperclip to ActiveStorage Migration Guide

## Overview

This document describes the migration from Paperclip (deprecated) to ActiveStorage for file uploads in PlebisHub. ActiveStorage is built into Rails 5.2+ and is the recommended solution for file uploads.

## Changes Made

### 1. Gemfile Updates

**Removed:**
```ruby
gem 'paperclip', '~> 5.2.1'
```

**Added:**
```ruby
gem 'image_processing', '~> 1.12' # For image variants
gem 'mini_magick', '~> 4.12'      # Image processing backend
```

### 2. Database Migration

A new migration was created to add ActiveStorage tables:

```bash
db/migrate/20251128000001_create_active_storage_tables.rb
```

### 3. Models Updated

The following models were updated to use ActiveStorage:

#### Election (app/models/election.rb)
```ruby
# Before (Paperclip)
has_attached_file :census_file
validates_attachment_content_type :census_file, content_type: ["text/plain", "text/csv"]
validates_attachment_size :census_file, less_than: 10.megabyte

# After (ActiveStorage)
has_one_attached :census_file
validate :census_file_content_type_validation
validate :census_file_size_validation
```

**API Changes:**
- `census_file.file?` → `census_file.attached?`
- `Paperclip.io_adapters.for(census_file).read` → `census_file.download`

#### PlebisVotes::Election (engines/plebis_votes)
Same changes as above.

#### PlebisImpulsa::ImpulsaEdition (engines/plebis_impulsa)
```ruby
# Before
has_attached_file :schedule_model
has_attached_file :activities_resources_model
has_attached_file :requested_budget_model
has_attached_file :monitoring_evaluation_model

# After
has_one_attached :schedule_model
has_one_attached :activities_resources_model
has_one_attached :requested_budget_model
has_one_attached :monitoring_evaluation_model
```

#### PlebisVerification::UserVerification (engines/plebis_verification)
```ruby
# Before (with Paperclip styles for thumbnails)
has_attached_file :front_vatid, styles: { thumb: ["450x300", :png] }
has_attached_file :back_vatid, styles: { thumb: ["450x300", :png] }

# After (with ActiveStorage variants)
has_one_attached :front_vatid
has_one_attached :back_vatid

def front_vatid_thumb
  front_vatid.variant(resize_to_limit: [450, 300], format: :png)
end
```

#### PlebisMicrocredit::Microcredit (engines/plebis_microcredit)
```ruby
# Before
has_attached_file :renewal_terms
scope :renewables, -> { where.not(renewal_terms_file_name: nil) }

# After
has_one_attached :renewal_terms
scope :renewables, -> { joins(:renewal_terms_attachment) }
```

**API Changes:**
- `renewal_terms.exists?` → `renewal_terms.attached?`

## Migration Steps

### Step 1: Install Dependencies

```bash
bundle install
```

### Step 2: Run Database Migration

```bash
rails db:migrate
```

This creates the ActiveStorage tables:
- `active_storage_blobs`
- `active_storage_attachments`
- `active_storage_variant_records`

### Step 3: Migrate Existing Files

```bash
# Dry run first to see what would be migrated
rails paperclip:migrate:dry_run

# Migrate all attachments
rails paperclip:migrate:all

# Or migrate specific models
rails paperclip:migrate:elections
rails paperclip:migrate:impulsa_editions
rails paperclip:migrate:user_verifications
rails paperclip:migrate:microcredits
```

### Step 4: Verify Migration

Test that files are accessible:

```ruby
# In Rails console
election = Election.first
election.census_file.attached?
election.census_file.download  # Should return file contents

user_verification = PlebisVerification::UserVerification.first
user_verification.front_vatid.attached?
user_verification.front_vatid_thumb  # Returns variant
```

### Step 5: Cleanup (After Verification)

Once migration is verified in production:

```bash
# Generate migration to remove Paperclip columns
rails paperclip:cleanup:columns
rails db:migrate

# Remove old files (DANGER: irreversible)
rails paperclip:cleanup:files
```

## API Reference Changes

### Checking if File Exists

```ruby
# Paperclip
record.attachment.file?
record.attachment.exists?

# ActiveStorage
record.attachment.attached?
```

### Reading File Content

```ruby
# Paperclip
Paperclip.io_adapters.for(record.attachment).read

# ActiveStorage
record.attachment.download
record.attachment.open { |file| file.read }
```

### File URL

```ruby
# Paperclip
record.attachment.url

# ActiveStorage
url_for(record.attachment)  # In views/controllers
rails_blob_url(record.attachment)  # Anywhere
```

### Image Variants (Thumbnails)

```ruby
# Paperclip
record.image.url(:thumb)

# ActiveStorage
record.image.variant(resize_to_limit: [100, 100])
record.image.variant(resize_to_limit: [100, 100]).processed  # Process immediately
```

### Content Type Validation

```ruby
# Paperclip
validates_attachment_content_type :file, content_type: ['image/png']

# ActiveStorage
validate :validate_content_type

def validate_content_type
  return unless file.attached?
  errors.add(:file, 'must be PNG') unless file.content_type == 'image/png'
end
```

### Size Validation

```ruby
# Paperclip
validates_attachment_size :file, less_than: 5.megabytes

# ActiveStorage
validate :validate_file_size

def validate_file_size
  return unless file.attached?
  errors.add(:file, 'is too large') if file.byte_size > 5.megabytes
end
```

## Troubleshooting

### MiniMagick not found

```bash
# macOS
brew install imagemagick

# Ubuntu/Debian
sudo apt-get install imagemagick
```

### Files not found during migration

The migration task tries multiple path patterns. If files are in a custom location:

1. Check the actual file paths in your Paperclip columns
2. Update the `possible_paths` array in the rake task

### Variants not generating

Ensure `image_processing` gem is installed and ImageMagick/Vips is available:

```ruby
# Check processor
Rails.application.config.active_storage.variant_processor
# Should be :mini_magick or :vips
```

## Rollback Plan

If issues occur, you can temporarily keep both systems running:

1. Keep Paperclip columns in database
2. Add a feature flag to switch between systems
3. Gradually migrate files

```ruby
def attachment_url
  if use_active_storage?
    url_for(attachment) if attachment.attached?
  else
    attachment_file_name.present? ? legacy_paperclip_url : nil
  end
end
```

## Files Modified

- `Gemfile` - Updated dependencies
- `config/initializers/paperclip.rb` - Deprecated, contains migration notes
- `config/initializers/active_storage.rb` - New configuration
- `db/migrate/20251128000001_create_active_storage_tables.rb` - New migration
- `lib/tasks/paperclip_to_active_storage.rake` - Migration rake tasks
- `app/models/election.rb` - Updated to ActiveStorage
- `engines/plebis_votes/app/models/plebis_votes/election.rb` - Updated
- `engines/plebis_impulsa/app/models/plebis_impulsa/impulsa_edition.rb` - Updated
- `engines/plebis_verification/app/models/plebis_verification/user_verification.rb` - Updated
- `engines/plebis_microcredit/app/models/plebis_microcredit/microcredit.rb` - Updated

## Security Improvements

The old Paperclip initializer contained hardcoded passwords for file encryption:

```ruby
# REMOVED - Security risk
cipher.pkcs5_keyivgen('mypassword')
```

If encryption is needed, use:
1. Rails credentials: `rails credentials:edit`
2. ActiveStorage encryption (Rails 7.0+)

---

**Migration Status:** Complete (code changes)
**Data Migration:** Pending (run `rails paperclip:migrate:all`)
**Cleanup:** Pending (after verification)
