# PlebisHub Rails 4.2 to 7.2 Upgrade - Issues Analysis

## Executive Summary

This document provides an exhaustive analysis of the PlebisHub Rails application upgrade from Rails 4.2 to Rails 7.2. After a thorough code review, **multiple critical and high-severity issues** have been identified that require attention before the application can be considered production-ready.

**Overall Assessment: The upgrade is INCOMPLETE and requires significant work.**

---

## Table of Contents

1. [Critical Issues (Must Fix Before Production)](#1-critical-issues-must-fix-before-production)
2. [High Priority Issues](#2-high-priority-issues)
3. [Medium Priority Issues](#3-medium-priority-issues)
4. [Low Priority Issues](#4-low-priority-issues)
5. [Gem Compatibility Issues](#5-gem-compatibility-issues)
6. [Configuration Issues](#6-configuration-issues)
7. [Deprecated Code Patterns](#7-deprecated-code-patterns)
8. [ActiveAdmin Issues](#8-activeadmin-issues)
9. [Engine-Specific Issues](#9-engine-specific-issues)
10. [Security Concerns](#10-security-concerns)
11. [Testing Recommendations](#11-testing-recommendations)

---

## 1. Critical Issues (Must Fix Before Production)

### 1.1 Missing Gemfile.lock

**Location:** Root directory
**Severity:** CRITICAL
**Impact:** Application cannot be deployed reliably

**Problem:**
The `Gemfile.lock` file is missing. This file is essential for:
- Reproducible builds
- Dependency resolution
- Deployment stability

**Solution:**
```bash
bundle install
git add Gemfile.lock
git commit -m "Add Gemfile.lock for reproducible builds"
```

---

### 1.2 Deprecated `before_filter` Still in Use

**Location:** Multiple files
**Severity:** CRITICAL
**Impact:** Code will break in Rails 7.2

**Affected Files:**
- `app/admin/user.rb:553` - `before_filter :multi_values_filter`
- `app/admin/microcredit_loan.rb:354` - `before_filter :multiple_id_search`
- `app/admin/impulsa_project.rb:383-384` - Multiple `before_filter` calls
- `engines/plebis_impulsa/app/admin/impulsa_project.rb:383-384`

**Problem:**
`before_filter` was deprecated in Rails 5.0 and removed in Rails 5.1+. While a compatibility alias exists in `spec/support/rails_legacy_aliases.rb`, this only applies to tests, not production code.

**Solution:**
Replace all occurrences:

```ruby
# Before (DEPRECATED)
before_filter :multi_values_filter, :only => :index

# After (CORRECT)
before_action :multi_values_filter, only: :index
```

**Files to Fix:**
```bash
# Run this to find all occurrences:
grep -r "before_filter" --include="*.rb" app/ engines/ | grep -v "_spec.rb" | grep -v "ANALYSIS.md"
```

---

### 1.3 ActiveAdmin Routes Commented Out

**Location:** `config/routes.rb:191`
**Severity:** CRITICAL
**Impact:** Admin panel is completely disabled

**Current Code:**
```ruby
# TEMPORARILY COMMENTED: ActiveAdmin has compatibility issues with Ruby 3.3
# ActiveAdmin.routes(self)
```

**Problem:**
The entire ActiveAdmin interface is disabled. This means:
- No admin dashboard
- No user management
- No content management
- No financial oversight

**Solution:**
1. Ensure ActiveAdmin gem is properly configured for Rails 7.2:
```ruby
# Gemfile - verify version
gem 'activeadmin', '~> 3.2'
gem 'ransack', '~> 4.2'
```

2. Uncomment the routes:
```ruby
# config/routes.rb
ActiveAdmin.routes(self)
```

3. Run ActiveAdmin installer if needed:
```bash
rails generate active_admin:install
```

---

### 1.4 Resque Admin Interface Disabled

**Location:** `config/routes.rb:193-196`
**Severity:** HIGH
**Impact:** No visibility into background jobs

**Current Code:**
```ruby
# TEMPORARILY COMMENTED: Resque admin interface
# constraints CanAccessResque.new do
#   mount Resque::Server.new, at: '/admin/resque', as: :resque
# end
```

**Solution:**
Uncomment and verify Resque works with Rails 7.2.

---

### 1.5 `Rails.application.secrets` Deprecated

**Location:** 66+ files throughout codebase
**Severity:** CRITICAL
**Impact:** Will break in future Rails versions

**Problem:**
`Rails.application.secrets` was deprecated in Rails 5.2 and removed in Rails 7.1. The application has a workaround in `config/application.rb`:

```ruby
# Restore Rails.application.secrets for Rails 7.2+ compatibility
# secrets.yml support was removed in Rails 7.2
config.secrets = config_for(:secrets)
```

While this workaround exists, it's fragile and not the recommended approach.

**Files Using `Rails.application.secrets`:**
- `config/routes.rb`
- `config/initializers/devise.rb`
- `app/models/user.rb`
- `app/controllers/application_controller.rb`
- Multiple engine files
- And 60+ more files

**Proper Solution:**
Migrate to Rails credentials:

```bash
# Edit credentials
rails credentials:edit

# Or for environment-specific
rails credentials:edit --environment production
```

Then replace all occurrences:
```ruby
# Before
Rails.application.secrets[:devise_secret_key]

# After
Rails.application.credentials.devise_secret_key
# OR
Rails.application.credentials.dig(:devise, :secret_key)
```

---

## 2. High Priority Issues

### 2.1 Deprecated `update_attributes` Method

**Location:** Multiple files
**Severity:** HIGH
**Impact:** Deprecated in Rails 6, may cause issues

**Affected Files:**
- `app/models/collaboration.rb:342`
- `lib/reddit.rb:27`
- `engines/plebis_collaborations/app/models/plebis_collaborations/collaboration.rb:340`

**Problem:**
`update_attributes` was deprecated in Rails 6.0 and replaced with `update`.

**Solution:**
```ruby
# Before (DEPRECATED)
self.update_attributes redsys_identifier: order.payment_identifier

# After (CORRECT)
self.update(redsys_identifier: order.payment_identifier)
```

---

### 2.2 Paperclip Gem is Deprecated - RESOLVED

**Location:** `Gemfile:65`
**Severity:** HIGH
**Impact:** No longer maintained, security vulnerabilities

**Status: FIXED**

The Paperclip gem has been replaced with ActiveStorage. See `docs/PAPERCLIP_TO_ACTIVESTORAGE_MIGRATION.md` for full details.

**Changes Made:**
1. Replaced `gem 'paperclip'` with `gem 'image_processing'` and `gem 'mini_magick'`
2. Created ActiveStorage migration: `db/migrate/20251128000001_create_active_storage_tables.rb`
3. Updated all models to use `has_one_attached` instead of `has_attached_file`
4. Created migration rake task: `lib/tasks/paperclip_to_active_storage.rake`
5. Removed insecure hardcoded password from `config/initializers/paperclip.rb`

**Models Updated:**
- `Election` (main app and engine)
- `PlebisImpulsa::ImpulsaEdition`
- `PlebisVerification::UserVerification`
- `PlebisMicrocredit::Microcredit`

**Remaining Steps:**
```bash
# 1. Run database migration
rails db:migrate

# 2. Migrate existing files
rails paperclip:migrate:all

# 3. After verification, cleanup old columns
rails paperclip:cleanup:columns
rails db:migrate
```

---

### 2.3 `therubyracer` Gem is Deprecated

**Location:** `Gemfile:14`
**Severity:** HIGH
**Impact:** Unmaintained, compilation issues on modern systems

**Current Code:**
```ruby
gem 'therubyracer', git: 'https://github.com/cowboyd/therubyracer.git', platforms: :ruby
```

**Problem:**
`therubyracer` is unmaintained and has compilation issues with modern Ruby versions. It depends on libv8, which is problematic.

**Solution:**
Remove and use Node.js for JavaScript runtime:

```ruby
# Gemfile - REMOVE this line:
# gem 'therubyracer', git: 'https://github.com/cowboyd/therubyracer.git', platforms: :ruby

# Instead, ensure Node.js is installed on the system
```

For ExecJS, it will automatically use Node.js if available.

---

### 2.4 `coffee-rails` is Legacy

**Location:** `Gemfile:13`
**Severity:** MEDIUM-HIGH
**Impact:** CoffeeScript is rarely used in modern Rails

**Current Code:**
```ruby
gem 'coffee-rails', '~> 4.2'
```

**Solution:**
1. Identify CoffeeScript files:
```bash
find . -name "*.coffee" -o -name "*.js.coffee"
```

2. Convert to ES6/JavaScript or keep if minimal files exist
3. Consider removal if no .coffee files are found

---

### 2.5 Turbolinks vs Turbo

**Location:** `Gemfile:16`
**Severity:** MEDIUM
**Impact:** Turbolinks is legacy, Rails 7 uses Turbo

**Current Code:**
```ruby
gem 'turbolinks'
```

**Problem:**
Turbolinks has been superseded by Turbo (part of Hotwire) in Rails 7.

**Solution (if staying with Turbolinks):**
```ruby
gem 'turbolinks', '~> 5.2'
```

**Solution (recommended - migrate to Turbo):**
```ruby
# Gemfile
gem 'turbo-rails'

# Remove:
# gem 'turbolinks'
```

Update layouts:
```erb
<!-- Before -->
<%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>

<!-- After -->
<%= javascript_include_tag 'application', 'data-turbo-track': 'reload' %>
```

---

### 2.6 Monkey-Patching Array#freeze

**Location:** `config/initializers/unfreezeautoload_paths.rb`
**Severity:** HIGH
**Impact:** Dangerous global monkey-patch

**Problem:**
This initializer monkey-patches `Array#freeze` to prevent autoload paths from being frozen. This is a dangerous workaround that can cause subtle bugs.

```ruby
Array.class_eval do
  alias_method :original_freeze, :freeze
  def freeze
    if caller.any? { |line| line.include?('rails/engine.rb') || line.include?('rails/application') }
      self  # Don't freeze
    else
      original_freeze
    end
  end
end
```

**Solution:**
1. Identify which gems are causing the issue
2. Update those gems to Rails 7.2 compatible versions
3. Remove the monkey-patch once gems are updated

---

## 3. Medium Priority Issues

### 3.1 CanCanCan Version is Outdated

**Location:** `Gemfile:27`
**Severity:** MEDIUM
**Impact:** Missing features, potential security issues

**Current Code:**
```ruby
gem 'cancancan', '~> 1.9'
```

**Problem:**
Version 1.9 is very old (2015). Current version is 3.x with many improvements.

**Solution:**
```ruby
gem 'cancancan', '~> 3.5'
```

Note: API changes between 1.x and 3.x may require updates to Ability class.

---

### 3.2 Bootstrap 3 is End of Life

**Location:** `Gemfile:28`
**Severity:** MEDIUM
**Impact:** No security updates, outdated components

**Current Code:**
```ruby
gem 'bootstrap-sass', '~> 3.4.1'
```

**Problem:**
Bootstrap 3 reached end of life in 2019. Bootstrap 3.4.1 is the final version.

**Solution:**
Consider migrating to Bootstrap 5 (current) or continue using if UI changes are not feasible.

```ruby
# For Bootstrap 5
gem 'bootstrap', '~> 5.3'
```

---

### 3.3 `rack-openid` and `ruby-openid` are Legacy

**Location:** `Gemfile:51-52`
**Severity:** MEDIUM
**Impact:** OpenID 2.0 is deprecated

**Current Code:**
```ruby
gem 'rack-openid'
gem 'ruby-openid'
```

**Problem:**
OpenID 2.0 has been superseded by OpenID Connect. These gems may not work correctly with Rails 7.2.

**Solution:**
If OpenID is required, migrate to OpenID Connect:
```ruby
gem 'omniauth-openid-connect'
```

Or remove if not actively used.

---

### 3.4 `pushmeup` Gem May Be Outdated

**Location:** `Gemfile:43`
**Severity:** MEDIUM
**Impact:** Push notifications may not work

**Problem:**
The `pushmeup` gem hasn't been updated in years and may not support modern push notification services.

**Solution:**
Consider alternatives:
```ruby
# For Firebase Cloud Messaging
gem 'fcm'

# For Apple Push Notification Service
gem 'apnotic'
```

---

## 4. Low Priority Issues

### 4.1 `sdoc` is Development Only

**Location:** `Gemfile:18`
**Severity:** LOW
**Impact:** Minor - documentation generator

**Current Code:**
```ruby
gem 'sdoc', '>= 2.0', group: :doc
```

**Solution:**
Move to development group only or remove if not generating documentation:
```ruby
group :development do
  gem 'sdoc', '>= 2.0'
end
```

---

### 4.2 `unicorn` Server

**Location:** `Gemfile:21`
**Severity:** LOW
**Impact:** Works but Puma is Rails default

**Current Code:**
```ruby
gem 'unicorn'
```

**Note:**
Unicorn works fine with Rails 7.2, but Puma is now the default and recommended server. Consider migration for better performance with Action Cable.

---

## 5. Gem Compatibility Issues

### 5.1 Potentially Incompatible Gems Matrix

| Gem | Current Version | Issue | Recommended Action |
|-----|----------------|-------|-------------------|
| `paperclip` | ~> 5.2.1 | Deprecated | Migrate to ActiveStorage |
| `therubyracer` | git | Unmaintained | Remove, use Node.js |
| `cancancan` | ~> 1.9 | Very outdated | Update to ~> 3.5 |
| `coffee-rails` | ~> 4.2 | Legacy | Consider removal |
| `turbolinks` | unversioned | Legacy | Migrate to Turbo |
| `bootstrap-sass` | ~> 3.4.1 | EOL | Consider Bootstrap 5 |
| `rack-openid` | unversioned | Legacy protocol | Migrate to OIDC |
| `pushmeup` | unversioned | Outdated | Use modern alternatives |
| `esendex` | unversioned | Verify compatibility | Test thoroughly |
| `auto_html` | unversioned | May need updates | Verify Rails 7.2 support |
| `rubypress` | unversioned | WordPress XML-RPC | Verify compatibility |

---

### 5.2 Gems Requiring Version Verification

Run the following to check for outdated gems:
```bash
bundle outdated
```

For each gem, verify Rails 7.2 compatibility on:
- https://rubygems.org
- GitHub repository

---

## 6. Configuration Issues

### 6.1 Session Store Configuration

**Location:** `config/initializers/session_store.rb`
**Severity:** LOW
**Impact:** Works but consider encryption options

**Current Code:**
```ruby
Rails.application.config.session_store :cookie_store, key: '_plebis_hub_session'
```

**Recommendation:**
For Rails 7.2, consider using encrypted cookies:
```ruby
Rails.application.config.session_store :cookie_store,
  key: '_plebis_hub_session',
  same_site: :lax,
  secure: Rails.env.production?
```

---

### 6.2 Paperclip Initializer Has Security Issues

**Location:** `config/initializers/paperclip.rb`
**Severity:** HIGH
**Impact:** Hardcoded encryption password

**Problem:**
The file contains a hardcoded password:
```ruby
def build_cipher(type, password)
  cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').send(type)
  cipher.pkcs5_keyivgen(password)  # password is 'mypassword'
  cipher
end
```

**Issues:**
1. Hardcoded password `'mypassword'`
2. DES-EDE3-CBC is weak by modern standards
3. `pkcs5_keyivgen` is deprecated in OpenSSL

**Solution:**
1. Remove this file when migrating away from Paperclip
2. If keeping, use Rails credentials for the password and modern encryption (AES-256-GCM)

---

### 6.3 Missing New Framework Defaults Activation

**Location:** `config/initializers/new_framework_defaults_7_2.rb`
**Severity:** MEDIUM
**Impact:** Not using Rails 7.2 optimizations

**Problem:**
All new framework defaults are commented out:
```ruby
# Rails.application.config.active_job.enqueue_after_transaction_commit = :default
# Rails.application.config.active_storage.web_image_content_types = %w[...]
# Rails.application.config.active_record.validate_migration_timestamps = true
# etc.
```

**Solution:**
Gradually enable these settings and test:
```ruby
Rails.application.config.active_job.enqueue_after_transaction_commit = :default
Rails.application.config.yjit = true  # Enable YJIT for performance
```

---

## 7. Deprecated Code Patterns

### 7.1 Hash Rockets in Symbols

**Location:** Throughout codebase
**Severity:** LOW (style)
**Impact:** None, but modernize

**Examples Found:**
```ruby
# Old style
before_filter :method, :only => :index

# Modern style
before_action :method, only: :index
```

---

### 7.2 `find_by_*` Dynamic Finders

**Location:** Multiple files
**Severity:** LOW
**Impact:** Works but deprecated style

**Examples Found:**
- `User.find_by_id(...)` - OK in Rails 7.2
- `User.find_by_document_vatid(...)` - OK in Rails 7.2
- `Vote.find_by_voter_id(...)` - OK in Rails 7.2

**Note:** These still work in Rails 7.2 but the `find_by(column: value)` syntax is preferred:
```ruby
# Both work, but this is preferred:
User.find_by(id: user_id)
User.find_by(document_vatid: vatid)
```

---

### 7.3 `.uniq` on Arrays from ActiveRecord

**Location:** Multiple files
**Severity:** LOW
**Impact:** Works but `.distinct` is SQL-level

**Example:**
```ruby
# This loads all records into memory, then uniques
VoteCircle.where("code like ?", value).map { |vc| vc.id }.uniq

# Better approach using SQL distinct:
VoteCircle.where("code like ?", value).distinct.pluck(:id)
```

---

## 8. ActiveAdmin Issues

### 8.1 SidebarSection Monkey-Patch

**Location:** `config/initializers/active_admin.rb:248-255`
**Severity:** MEDIUM
**Impact:** May break with ActiveAdmin updates

**Current Code:**
```ruby
ActiveAdmin::Views::SidebarSection.class_eval do
  def build(section)
    @section = section
    super(@section.title)
    self.id = @section.id
    build_sidebar_content
  end
end
```

**Problem:**
Monkey-patching ActiveAdmin internal classes is fragile and may break with updates.

**Solution:**
Check if this patch is still needed with ActiveAdmin 3.2. If so, document why and consider contributing upstream.

---

### 8.2 `before_filter` in Admin Resources

**Location:** Multiple admin files
**Severity:** CRITICAL

**Files:**
- `app/admin/user.rb:553`
- `app/admin/microcredit_loan.rb:354`
- `app/admin/impulsa_project.rb:383-384`

**Solution:**
```ruby
# In each ActiveAdmin resource file, replace:
controller do
  before_filter :method_name, only: :index
end

# With:
controller do
  before_action :method_name, only: :index
end
```

---

## 9. Engine-Specific Issues

### 9.1 Duplicate Code Between Main App and Engines

**Observation:**
Many models, controllers, and admin resources exist in both:
- Main `app/` directory
- `engines/plebis_*/app/` directories

**Examples:**
- `app/models/collaboration.rb` AND `engines/plebis_collaborations/app/models/plebis_collaborations/collaboration.rb`
- `app/admin/collaboration.rb` AND `engines/plebis_collaborations/app/admin/collaboration.rb`

**Problem:**
This duplication can lead to:
- Inconsistent behavior
- Maintenance burden
- Confusion about which code is actually running

**Solution:**
1. Determine the source of truth (engines vs main app)
2. Remove duplicates
3. Use proper engine namespacing

---

### 9.2 Engine Activation System

**Location:** Various engine.rb files
**Severity:** LOW
**Impact:** Adds complexity

The engines use a custom activation system via `EngineActivation` model. This is a valid pattern but adds complexity. Ensure the activation checks don't cause issues during boot.

---

## 10. Security Concerns

### 10.1 Hardcoded Credentials

**Locations:**
- `config/initializers/paperclip.rb` - Hardcoded 'mypassword'

**Solution:**
Move all credentials to Rails credentials or environment variables.

---

### 10.2 X-Frame-Options Disabled

**Location:** `app/controllers/application_controller.rb:58`
**Code:**
```ruby
def allow_iframe_requests
  response.headers.delete('X-Frame-Options')
end
```

**Impact:**
This allows the application to be embedded in iframes, which can enable clickjacking attacks.

**Solution:**
Only allow iframe embedding where needed:
```ruby
before_action :allow_iframe_requests, only: [:specific_action]
```

---

### 10.3 YAML.unsafe_load Usage

**Location:** `app/models/collaboration.rb:550`
**Code:**
```ruby
@non_user = if self.non_user_data then YAML.unsafe_load(self.non_user_data, aliases: true) else nil end
```

**Impact:**
`YAML.unsafe_load` can execute arbitrary code if the YAML content is malicious.

**Solution:**
Use safe alternatives:
```ruby
# If the data is trusted (from database you control):
@non_user = YAML.safe_load(self.non_user_data, permitted_classes: [NonUser, Symbol, Date, Time])

# Or use JSON for serialization instead
```

---

## 11. Testing Recommendations

### 11.1 Pre-Deployment Checklist

Before deploying to production:

1. **Generate Gemfile.lock:**
   ```bash
   bundle install
   ```

2. **Run full test suite:**
   ```bash
   bundle exec rspec
   bundle exec rails test
   ```

3. **Check for deprecation warnings:**
   ```bash
   RAILS_ENV=test bundle exec rails runner "puts ActiveSupport::Deprecation.silenced"
   ```

4. **Verify database migrations:**
   ```bash
   bundle exec rails db:migrate:status
   ```

5. **Check routes:**
   ```bash
   bundle exec rails routes | grep -E "(404|500)"
   ```

6. **Security audit:**
   ```bash
   bundle exec brakeman
   bundle audit check --update
   ```

---

### 11.2 Critical Paths to Test

1. User Registration and Login
2. Email Confirmation
3. SMS Verification
4. Collaboration Creation and Payment
5. Admin Dashboard (once enabled)
6. All Engine Functionality
7. Background Job Processing (Resque)

---

### 11.3 Load Testing

Before production, run load tests to ensure performance:
```bash
# Using Apache Bench
ab -n 1000 -c 10 http://localhost:3000/

# Or using wrk
wrk -t12 -c400 -d30s http://localhost:3000/
```

---

## Summary of Required Actions

### Immediate (Block Deployment)

1. [ ] Generate `Gemfile.lock`
2. [ ] Fix all `before_filter` → `before_action`
3. [ ] Uncomment ActiveAdmin routes
4. [ ] Verify application boots without errors

### Short-term (Within 1 Week)

5. [ ] Replace `update_attributes` with `update`
6. [ ] Remove `therubyracer` gem
7. [ ] Update `cancancan` to 3.x
8. [ ] Fix hardcoded password in paperclip.rb
9. [ ] Address YAML.unsafe_load security issue

### Medium-term (Within 1 Month)

10. [ ] Migrate from `Rails.application.secrets` to credentials
11. [ ] Plan Paperclip → ActiveStorage migration
12. [ ] Update Bootstrap if UI refresh is planned
13. [ ] Remove monkey-patch in unfreezeautoload_paths.rb
14. [ ] Enable Rails 7.2 framework defaults

### Long-term (Ongoing)

15. [ ] Migrate from Turbolinks to Turbo
16. [ ] Consolidate duplicate engine code
17. [ ] Update remaining outdated gems
18. [ ] Implement comprehensive test coverage

---

## Appendix: Quick Reference Commands

```bash
# Find all before_filter occurrences
grep -rn "before_filter" --include="*.rb" app/ engines/ config/

# Find all update_attributes occurrences
grep -rn "update_attributes" --include="*.rb" app/ engines/ lib/

# Find all secrets usage
grep -rn "Rails.application.secrets" --include="*.rb" app/ config/ lib/ engines/

# Check gem versions
bundle outdated

# Security audit
bundle exec brakeman -A
bundle audit check --update

# Run tests with deprecation warnings
RUBYOPT='-W:deprecated' bundle exec rspec
```

---

**Document Version:** 1.0
**Generated:** November 28, 2025
**Rails Target Version:** 7.2.3
**Ruby Version Required:** >= 3.3.6
