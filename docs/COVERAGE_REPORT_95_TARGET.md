# PlebisHub Test Coverage Report

## Target: 95%+ Code Coverage

**Generated:** December 2024
**Current Coverage:** ~17.7% (2,257 / 12,759 lines)
**Target Coverage:** 95% (12,121 lines)
**Lines Needed:** ~9,864 additional lines to cover

---

## Executive Summary

The current SimpleCov analysis reveals significant coverage gaps across the application. To reach 95% coverage, we need to add approximately **9,864 lines** of coverage through new tests and expanding existing test suites.

### Coverage by Category

| Category | Total Lines | Covered | Coverage % | Priority |
|----------|-------------|---------|------------|----------|
| Controllers (app/controllers) | 2,571 | 29 | 1.1% | 🔴 Critical |
| Services (app/services) | 120 | 0 | 0.0% | 🔴 Critical |
| Mailers (app/mailers) | 203 | 0 | 0.0% | 🔴 Critical |
| Admin (app/admin) | 3,406 | 516 | 15.1% | 🔴 Critical |
| Models (app/models) | 3,480 | 803 | 23.1% | 🟠 High |
| Lib Files (lib/) | ~850 | ~130 | 15.3% | 🟠 High |
| Engine Models | ~550 | ~210 | 38.2% | 🟡 Medium |
| Validators (app/validators) | 100 | 7 | 7.0% | 🟠 High |
| Helpers (app/helpers) | 138 | 52 | 37.7% | 🟡 Medium |

---

## Priority 1: Critical (0-15% Coverage) - Est. ~5,800 lines

### 1.1 Controllers - 0% Coverage Files

These controller files have **0% coverage** and need comprehensive test suites:

| File | Lines | Tests Needed |
|------|-------|--------------|
| `app/controllers/vote_controller.rb` | 313 | Full action coverage (index, show, create, paper voting, admin) |
| `app/controllers/registrations_controller.rb` | 229 | Registration flow, validation, paranoid mode |
| `app/controllers/open_id_controller.rb` | 204 | OpenID authentication flow |
| `app/controllers/collaborations_controller.rb` | 194 | CRUD operations, payment flows |
| `app/controllers/api/v2_controller.rb` | 326 | All API endpoints |
| `app/controllers/api/v1_controller.rb` | 144 | All API v1 endpoints |
| `app/controllers/militant_controller.rb` | 128 | Militant registration/management |
| `app/controllers/audio_captcha_controller.rb` | 92 | Audio CAPTCHA generation |
| `app/controllers/api/v1/themes_controller.rb` | 91 | Theme API endpoints |
| `app/controllers/tools_controller.rb` | 78 | Tools page actions |
| `app/controllers/errors_controller.rb` | 69 | Error pages (404, 500, etc.) |
| `app/controllers/passwords_controller.rb` | 62 | Password reset flow |
| `app/controllers/legacy_password_controller.rb` | 59 | Legacy password migration |
| `app/controllers/sessions_controller.rb` | 57 | Login/logout, session management |
| `app/controllers/orders_controller.rb` | 55 | Order processing |
| `app/controllers/supports_controller.rb` | 55 | Support submissions |
| `app/controllers/proposals_controller.rb` | 52 | Proposal viewing |

**Recommended Tests for Controllers:**

```ruby
# Example test structure for each controller:
RSpec.describe VoteController, type: :controller do
  describe 'GET #index'
  describe 'GET #show'
  describe 'POST #create'
  describe 'authentication' do
    context 'when user is not logged in'
    context 'when user is logged in'
  end
  describe 'authorization' do
    context 'when user has permission'
    context 'when user lacks permission'
  end
  describe 'error handling'
end
```

### 1.2 Services - 0% Coverage

All service classes need complete test suites:

| File | Lines | Tests Needed |
|------|-------|--------------|
| `app/services/redsys_payment_processor.rb` | 43 | Payment processing, error handling |
| `app/services/census_file_parser.rb` | 35 | File parsing, validation |
| `app/services/paper_vote_service.rb` | 32 | Paper vote processing |
| `app/services/url_signature_service.rb` | 2 | URL signing/verification |
| `app/services/loan_renewal_service.rb` | 2 | Loan renewal logic |
| `app/services/exterior_verification_report_service.rb` | 2 | Report generation |
| `app/services/town_verification_report_service.rb` | 2 | Report generation |
| `app/services/user_verification_report_service.rb` | 2 | Report generation |

**Recommended Tests:**

```ruby
# spec/services/redsys_payment_processor_spec.rb
RSpec.describe RedsysPaymentProcessor do
  describe '#process_payment' do
    context 'with valid parameters'
    context 'with invalid card'
    context 'with expired card'
    context 'when Redsys returns error'
  end
  describe '#verify_signature'
  describe '#handle_callback'
end
```

### 1.3 Mailers - 0% Coverage

| File | Lines | Tests Needed |
|------|-------|--------------|
| `app/mailers/collaborations_mailer.rb` | 90 | All collaboration emails |
| `app/mailers/users_mailer.rb` | 47 | User notification emails |
| `app/mailers/impulsa_mailer.rb` | 45 | Impulsa project emails |
| `app/mailers/user_verification_mailer.rb` | 18 | Verification emails |
| `app/mailers/application_mailer.rb` | 3 | Base mailer config |

**Recommended Tests:**

```ruby
# spec/mailers/collaborations_mailer_spec.rb
RSpec.describe CollaborationsMailer, type: :mailer do
  describe '#confirmation_email' do
    it 'renders the headers'
    it 'renders the body'
    it 'includes collaboration details'
  end
  describe '#receipt_email'
  describe '#cancellation_email'
  describe '#renewal_reminder'
end
```

### 1.4 Validators - 7% Coverage

| File | Lines | Tests Needed |
|------|-------|--------------|
| `app/validators/valid_nif_validator.rb` | 25 | NIF validation (Spanish ID) |
| `app/validators/valid_nie_validator.rb` | 27 | NIE validation (Foreign ID) |
| `app/validators/bank_ccc_validator.rb` | 19 | Bank account validation |
| `app/validators/email_validator.rb` | 29 | Email format validation |

**Recommended Tests:**

```ruby
# spec/validators/valid_nif_validator_spec.rb
RSpec.describe ValidNifValidator do
  describe '#validate_each' do
    context 'with valid NIF' do
      it 'does not add errors' # Test various valid formats
    end
    context 'with invalid NIF' do
      it 'adds error for wrong checksum'
      it 'adds error for invalid format'
      it 'adds error for too short'
    end
  end
end
```

---

## Priority 2: High Priority (15-40% Coverage) - Est. ~3,000 lines

### 2.1 Admin Pages - 15.1% Average Coverage

| File | Lines | Current % | Tests Needed |
|------|-------|-----------|--------------|
| `app/admin/collaboration.rb` | 759 | 9.4% | Index filters, batch actions, forms |
| `app/admin/user.rb` | 460 | 21.5% | User management, filters, exports |
| `app/admin/impulsa_project.rb` | 322 | 8.7% | Project management, state transitions |
| `app/admin/microcredit_loan.rb` | 247 | 20.6% | Loan management, payments |
| `app/admin/microcredit.rb` | 198 | 13.6% | Microcredit campaigns |
| `app/admin/user_verification.rb` | 177 | 18.1% | Verification workflow |
| `app/admin/theme_settings.rb` | 163 | 11.0% | Theme configuration |
| `app/admin/election.rb` | 152 | 15.1% | Election management |
| `app/admin/brand_settings.rb` | 141 | 14.9% | Brand configuration |
| `app/admin/order.rb` | 151 | 18.5% | Order management |

**Recommended Tests:**

```ruby
# spec/admin/collaboration_spec.rb additions
RSpec.describe 'Admin::Collaboration', type: :request do
  # Add tests for:
  describe 'filters' do
    it 'filters by status'
    it 'filters by payment_type'
    it 'filters by date range'
  end
  describe 'batch actions' do
    it 'confirms selected collaborations'
    it 'exports selected to CSV'
  end
  describe 'member actions' do
    it 'processes payment'
    it 'sends reminder'
  end
end
```

### 2.2 Models with Low Coverage

| File | Lines | Current % | Tests Needed |
|------|-------|-----------|--------------|
| `app/models/collaboration.rb` | 412 | 29.9% | Payment methods, state machine |
| `app/models/user.rb` | 342 | 37.1% | Associations, validations, methods |
| `app/models/order.rb` | 270 | 27.8% | Order processing, payments |
| `app/models/election.rb` | 208 | 22.6% | Election logic, voting |
| `app/models/concerns/user/location_helpers.rb` | 196 | 26.5% | Location lookups |
| `app/models/concerns/impulsa_project_wizard.rb` | 262 | 0.0% | Wizard steps |
| `app/models/concerns/impulsa_project_evaluation.rb` | 187 | 0.0% | Evaluation logic |
| `app/models/report.rb` | 128 | 9.4% | Report generation |
| `app/models/report_group.rb` | 104 | 24.0% | Report grouping |
| `app/models/ability.rb` | 94 | 0.0% | CanCanCan abilities |
| `app/models/vote.rb` | 77 | 0.0% | Vote model |

**Recommended Tests:**

```ruby
# spec/models/collaboration_spec.rb additions
describe 'payment processing' do
  describe '#process_bank_transfer'
  describe '#process_credit_card'
  describe '#calculate_amount'
end

describe 'state machine' do
  describe '#confirm!'
  describe '#cancel!'
  describe '#mark_as_paid!'
end
```

### 2.3 Lib Files - Variable Coverage

| File | Lines | Current % | Tests Needed |
|------|-------|-----------|--------------|
| `lib/plebis_core/engine_registry.rb` | 154 | 0.0% | Engine registration, lookup |
| `lib/plebisbrand_import_collaborations2017.rb` | 163 | 0.0% | Import logic |
| `lib/plebisbrand_import_collaborations.rb` | 91 | 0.0% | Import logic |
| `lib/plebisbrand_export.rb` | 71 | 7.0% | Export logic |
| `lib/plebisbrand_import.rb` | 65 | 10.8% | Import logic |
| `lib/collaborations_on_paper.rb` | 98 | 26.5% | PDF generation |
| `lib/diff.rb` | 48 | 0.0% | Diff utilities |
| `lib/plebis_core/event_bus.rb` | 39 | 0.0% | Event system |
| `lib/reddit.rb` | 32 | 0.0% | Reddit integration |
| `lib/sms.rb` | 15 | 0.0% | SMS sending |

---

## Priority 3: Medium Priority (40-70% Coverage) - Est. ~1,000 lines

### 3.1 Engine Models

| File | Lines | Current % | Tests Needed |
|------|-------|-----------|--------------|
| `engines/plebis_microcredit/.../microcredit_loan.rb` | 209 | 36.4% | Loan validation, payments |
| `engines/plebis_microcredit/.../microcredit.rb` | 199 | 39.2% | Campaign logic |
| `engines/plebis_impulsa/.../impulsa_edition.rb` | 90 | 41.1% | Edition management |
| `engines/plebis_verification/.../user_verification.rb` | 88 | 44.3% | Verification workflow |
| `engines/plebis_gamification/.../user_stats.rb` | 80 | 35.0% | Stats calculation |

### 3.2 Helpers

| File | Lines | Current % | Tests Needed |
|------|-------|-----------|--------------|
| `app/helpers/theme_helper.rb` | 46 | 30.4% | Theme methods |
| `app/helpers/application_helper.rb` | 40 | 35.0% | Common helpers |
| `app/helpers/registrations_helper.rb` | 21 | 33.3% | Registration helpers |

---

## Currently Skipped Tests (Need Implementation)

### Files with `skip:` annotations

1. **Request specs skipped for HTML structure:**
   - `spec/requests/participation_teams_index_spec.rb`
   - `spec/requests/page_guarantees_spec.rb`
   - `spec/requests/blog_spec.rb`
   - `spec/requests/notice_spec.rb`
   - `spec/requests/page_funding_spec.rb`
   - `spec/requests/devise_registrations_qr_code_spec.rb`
   - `spec/requests/proposals_info_spec.rb`
   - `spec/requests/microcredit_info_spec.rb`
   - `spec/requests/page_faq_spec.rb`

2. **Feature not enabled:**
   - `spec/requests/devise_unlocks_new_spec.rb` - Unlock routes disabled
   - `spec/controllers/open_id_controller_spec.rb` - OpenID disabled in test

3. **Route disabled (handled by engines):**
   - `spec/controllers/supports_controller_spec.rb`
   - `spec/controllers/proposals_controller_spec.rb`

4. **Infrastructure requirements:**
   - `spec/lib/generators/plebis/engine/engine_generator_spec.rb` - Needs Rails::Generators::TestCase

5. **Pending feature:**
   - `spec/controllers/api/v1/brand_settings_controller_spec.rb:47` - User.organization_id

### `xit` tests (Devise Mailer unlock)

```ruby
# spec/mailers/devise_mailer_spec.rb - 6 tests
# These need implementation when unlock feature is enabled
```

---

## Test Implementation Plan

### Phase 1: Critical Controllers (Week 1-2)
1. Create comprehensive controller specs for:
   - `vote_controller_spec.rb` - Add action coverage
   - `registrations_controller_spec.rb` - Full registration flow
   - `api/v2_controller_spec.rb` - All API endpoints
   - `collaborations_controller_spec.rb` - CRUD + payment

### Phase 2: Services & Mailers (Week 2-3)
1. Create service specs for all 8 service classes
2. Create mailer specs for all 5 mailers
3. Create validator specs for all 4 validators

### Phase 3: Admin Coverage (Week 3-4)
1. Expand admin specs with:
   - Filter tests
   - Batch action tests
   - Member action tests
   - Form submission tests

### Phase 4: Model Deep Coverage (Week 4-5)
1. Add tests for uncovered model methods
2. Cover all concerns (wizard, evaluation, etc.)
3. Test all state machines and callbacks

### Phase 5: Lib & Engines (Week 5-6)
1. Create specs for lib files
2. Expand engine model coverage
3. Test all helper methods

---

## Estimated Effort

| Phase | Files | Tests Est. | Coverage Gain |
|-------|-------|------------|---------------|
| Phase 1 | 17 controllers | ~500 tests | +20% |
| Phase 2 | 17 services/mailers/validators | ~200 tests | +5% |
| Phase 3 | 23 admin files | ~400 tests | +20% |
| Phase 4 | 37 models/concerns | ~600 tests | +30% |
| Phase 5 | 15 lib/engines | ~200 tests | +10% |
| **Total** | **109 files** | **~1,900 tests** | **+85%** |

---

## Quick Wins (High Impact, Low Effort)

1. **Ability Model** (94 lines, 0%) - Test authorization rules
2. **Vote Model** (77 lines, 0%) - Test vote record creation
3. **Small Services** (all < 5 lines) - Quick stub tests
4. **Validators** (100 lines total) - Edge case testing

---

## Configuration Needed

### SimpleCov Setup
Ensure `.simplecov` is configured properly:

```ruby
SimpleCov.start 'rails' do
  enable_coverage :branch
  minimum_coverage 95
  minimum_coverage_by_file 80

  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Services', 'app/services'
  add_group 'Admin', 'app/admin'
  add_group 'Mailers', 'app/mailers'
  add_group 'Engines', 'engines'
  add_group 'Libraries', 'lib'
end
```

---

## Conclusion

Reaching 95% coverage requires substantial test additions across the codebase:

1. **Controllers** are the biggest gap with 1.1% coverage
2. **Services and Mailers** have 0% coverage
3. **Admin pages** need significant expansion
4. **Model concerns** (especially Impulsa) need full coverage

The recommended approach is to tackle high-traffic, business-critical code first (authentication, payments, voting) before moving to administrative features.

**Estimated timeline:** 5-6 weeks of focused development
**Estimated tests needed:** ~1,900 additional test cases
