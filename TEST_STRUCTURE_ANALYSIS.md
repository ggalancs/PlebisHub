# PlebisHub Test Structure Analysis - Engine Migration Guide

## Executive Summary

**Testing Framework**: Mixed RSpec (primary) + Minitest
- **Total Test Files**: 151 (119 RSpec specs + 32 Minitest tests)
- **Factory Files**: 27 FactoryBot factories (shared between both frameworks)
- **Support Files**: 3 spec/support helpers + 1 test concern
- **Test Configuration**: 2 RSpec helpers + 1 Minitest helper
- **Coverage Target**: 95% overall, 80% per file minimum

---

## Test Framework Architecture

### Testing Stack
1. **RSpec 3.x** (Primary) - spec/ directory
   - Controllers, Models, Requests, Mailers, Services, Views
   - 119 spec files
   
2. **Minitest** (Secondary) - test/ directory
   - Models, Model concerns
   - 32 test files

3. **FactoryBot** - test/factories/
   - Shared between RSpec and Minitest
   - 27 factory definitions

### Key Test Infrastructure Components

#### RSpec Configuration Files
- `.rspec` - Runner settings (random order, documentation format)
- `spec/spec_helper.rb` - Core RSpec configuration
- `spec/rails_helper.rb` - Rails integration (SimpleCov, DatabaseCleaner, Devise, WebMock)

#### Minitest Configuration Files
- `test/test_helper.rb` - Minitest setup (SimpleCov, WebMock, Warden)

#### Shared Test Support (spec/support/)
- `factory_bot.rb` - Configures FactoryBot to load from test/factories
- `rails_legacy_aliases.rb` - Legacy Rails compatibility (before_filter aliases)
- `blog_helper_stub.rb` - Test doubles for BlogHelper (replaces auto_html)

#### Test Concerns
- `test/models/concerns/safe_condition_evaluator_test.rb` - Security concern for wizard conditions

#### Test Fixtures
- `test/fixtures/collaborations_mailer/` - Email fixtures (4 files)
- `test/lib/juntos_test.csv` - Census data for voting tests

---

## Complete Test Inventory by Functional Area

### 1. VOTING SYSTEM (25 tests)
**Target Engine**: VotingEngine

#### Controllers (1 spec)
- `/home/user/PlebisHub/spec/controllers/vote_controller_spec.rb`

#### Models - RSpec (8 specs)
- `/home/user/PlebisHub/spec/models/election_spec.rb`
- `/home/user/PlebisHub/spec/models/election_location_spec.rb`
- `/home/user/PlebisHub/spec/models/election_location_question_spec.rb`
- `/home/user/PlebisHub/spec/models/proposal_spec.rb`
- `/home/user/PlebisHub/spec/models/support_spec.rb`
- `/home/user/PlebisHub/spec/models/vote_spec.rb`
- `/home/user/PlebisHub/spec/models/vote_circle_spec.rb`
- `/home/user/PlebisHub/spec/models/vote_circle_type_spec.rb`

#### Models - Minitest (8 tests)
- `/home/user/PlebisHub/test/models/election_test.rb`
- `/home/user/PlebisHub/test/models/election_location_test.rb`
- `/home/user/PlebisHub/test/models/election_location_question_test.rb`
- `/home/user/PlebisHub/test/models/proposal_test.rb`
- `/home/user/PlebisHub/test/models/support_test.rb`
- `/home/user/PlebisHub/test/models/vote_test.rb`
- `/home/user/PlebisHub/test/models/vote_circle_test.rb`
- `/home/user/PlebisHub/test/models/vote_circle_type_test.rb`

#### Request Specs (8 specs)
- `/home/user/PlebisHub/spec/requests/proposals_index_spec.rb`
- `/home/user/PlebisHub/spec/requests/proposals_info_spec.rb`
- `/home/user/PlebisHub/spec/requests/proposals_show_spec.rb`
- `/home/user/PlebisHub/spec/requests/vote_check_spec.rb`
- `/home/user/PlebisHub/spec/requests/vote_create_spec.rb`
- `/home/user/PlebisHub/spec/requests/vote_paper_vote_spec.rb`
- `/home/user/PlebisHub/spec/requests/vote_sms_check_spec.rb`
- `/home/user/PlebisHub/spec/requests/vote_votes_count_spec.rb`

#### Factories (7 files)
- `/home/user/PlebisHub/test/factories/elections.rb`
- `/home/user/PlebisHub/test/factories/election_locations.rb`
- `/home/user/PlebisHub/test/factories/election_location_questions.rb`
- `/home/user/PlebisHub/test/factories/proposals.rb`
- `/home/user/PlebisHub/test/factories/supports.rb`
- `/home/user/PlebisHub/test/factories/votes.rb`
- `/home/user/PlebisHub/test/factories/vote_circles.rb`

#### Test Data
- `/home/user/PlebisHub/test/lib/juntos_test.csv` - Census data

---

### 2. MICROCREDIT SYSTEM (13 tests)
**Target Engine**: MicrocreditEngine

#### Controllers (1 spec)
- `/home/user/PlebisHub/spec/controllers/microcredit_controller_spec.rb`

#### Models - RSpec (3 specs)
- `/home/user/PlebisHub/spec/models/microcredit_spec.rb`
- `/home/user/PlebisHub/spec/models/microcredit_loan_spec.rb`
- `/home/user/PlebisHub/spec/models/microcredit_option_spec.rb`

#### Models - Minitest (3 tests)
- `/home/user/PlebisHub/test/models/microcredit_test.rb`
- `/home/user/PlebisHub/test/models/microcredit_loan_test.rb`
- `/home/user/PlebisHub/test/models/microcredit_option_test.rb`

#### Request Specs (6 specs)
- `/home/user/PlebisHub/spec/requests/microcredit_index_spec.rb`
- `/home/user/PlebisHub/spec/requests/microcredit_info_spec.rb`
- `/home/user/PlebisHub/spec/requests/microcredit_info_mailing_spec.rb`
- `/home/user/PlebisHub/spec/requests/microcredit_new_loan_spec.rb`
- `/home/user/PlebisHub/spec/requests/microcredit_renewal_spec.rb`
- `/home/user/PlebisHub/spec/requests/microcredit_loans_renewal_spec.rb`

#### Factories (3 files)
- `/home/user/PlebisHub/test/factories/microcredits.rb`
- `/home/user/PlebisHub/test/factories/microcredit_loans.rb`
- `/home/user/PlebisHub/test/factories/microcredit_options.rb`

---

### 3. COLLABORATIONS/DONATIONS SYSTEM (13 tests)
**Target Engine**: CollaborationsEngine

#### Controllers (2 specs)
- `/home/user/PlebisHub/spec/controllers/collaborations_controller_spec.rb`
- `/home/user/PlebisHub/spec/controllers/orders_controller_spec.rb`

#### Models - RSpec (2 specs)
- `/home/user/PlebisHub/spec/models/collaboration_spec.rb`
- `/home/user/PlebisHub/spec/models/order_spec.rb`

#### Models - Minitest (2 tests)
- `/home/user/PlebisHub/test/models/collaboration_test.rb`
- `/home/user/PlebisHub/test/models/order_test.rb`

#### Request Specs (6 specs)
- `/home/user/PlebisHub/spec/requests/collaborations_confirm_spec.rb`
- `/home/user/PlebisHub/spec/requests/collaborations_edit_spec.rb`
- `/home/user/PlebisHub/spec/requests/collaborations_ko_spec.rb`
- `/home/user/PlebisHub/spec/requests/collaborations_new_spec.rb`
- `/home/user/PlebisHub/spec/requests/collaborations_ok_spec.rb`
- `/home/user/PlebisHub/spec/requests/collaborations_occasional_spec.rb`

#### Mailers (1 spec)
- `/home/user/PlebisHub/spec/mailers/collaborations_mailer_spec.rb`

#### Factories (2 files)
- `/home/user/PlebisHub/test/factories/collaborations.rb`
- `/home/user/PlebisHub/test/factories/orders.rb`

#### Fixtures (4 mailer fixtures)
- `/home/user/PlebisHub/test/fixtures/collaborations_mailer/creditcard_error`
- `/home/user/PlebisHub/test/fixtures/collaborations_mailer/creditcard_expired`
- `/home/user/PlebisHub/test/fixtures/collaborations_mailer/receipt_returned`
- `/home/user/PlebisHub/test/fixtures/collaborations_mailer/receipt_suspended`

---

### 4. IMPULSA PROJECTS (19 tests)
**Target Engine**: ImpulsaEngine

#### Controllers (1 spec)
- `/home/user/PlebisHub/spec/controllers/impulsa_controller_spec.rb`

#### Models - RSpec (6 specs)
- `/home/user/PlebisHub/spec/models/impulsa_edition_spec.rb`
- `/home/user/PlebisHub/spec/models/impulsa_edition_category_spec.rb`
- `/home/user/PlebisHub/spec/models/impulsa_edition_topic_spec.rb`
- `/home/user/PlebisHub/spec/models/impulsa_project_spec.rb`
- `/home/user/PlebisHub/spec/models/impulsa_project_state_transition_spec.rb`
- `/home/user/PlebisHub/spec/models/impulsa_project_topic_spec.rb`

#### Models - Minitest (6 tests)
- `/home/user/PlebisHub/test/models/impulsa_edition_test.rb`
- `/home/user/PlebisHub/test/models/impulsa_edition_category_test.rb`
- `/home/user/PlebisHub/test/models/impulsa_edition_topic_test.rb`
- `/home/user/PlebisHub/test/models/impulsa_project_test.rb`
- `/home/user/PlebisHub/test/models/impulsa_project_state_transition_test.rb`
- `/home/user/PlebisHub/test/models/impulsa_project_topic_test.rb`

#### Request Specs (5 specs)
- `/home/user/PlebisHub/spec/requests/impulsa_evaluation_spec.rb`
- `/home/user/PlebisHub/spec/requests/impulsa_inactive_spec.rb`
- `/home/user/PlebisHub/spec/requests/impulsa_index_spec.rb`
- `/home/user/PlebisHub/spec/requests/impulsa_project_spec.rb`
- `/home/user/PlebisHub/spec/requests/impulsa_project_step_spec.rb`

#### Mailers (1 spec)
- `/home/user/PlebisHub/spec/mailers/impulsa_mailer_spec.rb`

#### Factories (6 files)
- `/home/user/PlebisHub/test/factories/impulsa_editions.rb`
- `/home/user/PlebisHub/test/factories/impulsa_edition_categories.rb`
- `/home/user/PlebisHub/test/factories/impulsa_edition_topics.rb`
- `/home/user/PlebisHub/test/factories/impulsa_projects.rb`
- `/home/user/PlebisHub/test/factories/impulsa_project_state_transitions.rb`
- `/home/user/PlebisHub/test/factories/impulsa_project_topics.rb`

---

### 5. USER VERIFICATION SYSTEM (15 tests)
**Target Engine**: UserVerificationEngine (or part of Core)

#### Controllers (1 spec)
- `/home/user/PlebisHub/spec/controllers/user_verifications_controller_spec.rb`

#### Models - RSpec (1 spec)
- `/home/user/PlebisHub/spec/models/user_verification_spec.rb`

#### Models - Minitest (1 test)
- `/home/user/PlebisHub/test/models/user_verification_test.rb`

#### Request Specs (8 specs)
- `/home/user/PlebisHub/spec/requests/sms_validator_step1_spec.rb`
- `/home/user/PlebisHub/spec/requests/sms_validator_step2_spec.rb`
- `/home/user/PlebisHub/spec/requests/sms_validator_step3_spec.rb`
- `/home/user/PlebisHub/spec/requests/user_verifications_new_spec.rb`
- `/home/user/PlebisHub/spec/requests/user_verifications_report_spec.rb`
- `/home/user/PlebisHub/spec/requests/user_verifications_report_exterior_spec.rb`
- `/home/user/PlebisHub/spec/requests/user_verifications_report_town_spec.rb`
- `/home/user/PlebisHub/spec/requests/vote_sms_check_spec.rb` (shared with voting)

#### Mailers (1 spec)
- `/home/user/PlebisHub/spec/mailers/user_verification_mailer_spec.rb`

#### Services (3 specs)
- `/home/user/PlebisHub/spec/services/user_verification_report_service_spec.rb`
- `/home/user/PlebisHub/spec/services/town_verification_report_service_spec.rb`
- `/home/user/PlebisHub/spec/services/exterior_verification_report_service_spec.rb`

#### Factories (1 file)
- `/home/user/PlebisHub/test/factories/user_verifications.rb`

---

### 6. PARTICIPATION TEAMS (4 tests)
**Target**: Core or separate engine

#### Controllers (1 spec)
- `/home/user/PlebisHub/spec/controllers/participation_teams_controller_spec.rb`

#### Models - RSpec (1 spec)
- `/home/user/PlebisHub/spec/models/participation_team_spec.rb`

#### Models - Minitest (1 test)
- `/home/user/PlebisHub/test/models/participation_team_test.rb`

#### Request Specs (1 spec)
- `/home/user/PlebisHub/spec/requests/participation_teams_index_spec.rb`

#### Factories (1 file)
- `/home/user/PlebisHub/test/factories/participation_teams.rb`

---

### 7. NOTICE/ANNOUNCEMENTS (6 tests)
**Target**: Core or shared

#### Controllers (1 spec)
- `/home/user/PlebisHub/spec/controllers/notice_controller_spec.rb`

#### Models - RSpec (2 specs)
- `/home/user/PlebisHub/spec/models/notice_spec.rb`
- `/home/user/PlebisHub/spec/models/notice_registrar_spec.rb`

#### Models - Minitest (2 tests)
- `/home/user/PlebisHub/test/models/notice_test.rb`
- `/home/user/PlebisHub/test/models/notice_registrar_test.rb`

#### Request Specs (1 spec)
- `/home/user/PlebisHub/spec/requests/notice_spec.rb`

#### Views (1 spec)
- `/home/user/PlebisHub/spec/views/notice/index.html.erb_spec.rb`

#### Factories (2 files)
- `/home/user/PlebisHub/test/factories/notices.rb`
- `/home/user/PlebisHub/test/factories/notice_registrars.rb`

---

### 8. BLOG/CONTENT (15 tests)
**Target**: Core CMS functionality

#### Controllers (1 spec)
- `/home/user/PlebisHub/spec/controllers/page_controller_spec.rb`

#### Models - RSpec (2 specs)
- `/home/user/PlebisHub/spec/models/category_spec.rb`
- `/home/user/PlebisHub/spec/models/page_spec.rb`
- `/home/user/PlebisHub/spec/models/post_spec.rb`

#### Models - Minitest (3 tests)
- `/home/user/PlebisHub/test/models/category_test.rb`
- `/home/user/PlebisHub/test/models/page_test.rb`
- `/home/user/PlebisHub/test/models/post_test.rb`

#### Request Specs (10 specs)
- `/home/user/PlebisHub/spec/requests/blog_spec.rb`
- `/home/user/PlebisHub/spec/requests/blog_category_spec.rb`
- `/home/user/PlebisHub/spec/requests/blog_post_spec.rb`
- `/home/user/PlebisHub/spec/requests/page_closed_form_spec.rb`
- `/home/user/PlebisHub/spec/requests/page_faq_spec.rb`
- `/home/user/PlebisHub/spec/requests/page_form_iframe_spec.rb`
- `/home/user/PlebisHub/spec/requests/page_formview_iframe_spec.rb`
- `/home/user/PlebisHub/spec/requests/page_funding_spec.rb`
- `/home/user/PlebisHub/spec/requests/page_guarantees_spec.rb`
- `/home/user/PlebisHub/spec/requests/page_privacy_policy_spec.rb`

#### Factories (2 files)
- `/home/user/PlebisHub/test/factories/categories.rb`
- `/home/user/PlebisHub/test/factories/pages.rb`
- `/home/user/PlebisHub/test/factories/posts.rb`

---

### 9. MILITANT/MEMBER MANAGEMENT (5 tests)
**Target**: Core user management

#### Controllers (1 spec)
- `/home/user/PlebisHub/spec/controllers/militant_controller_spec.rb`

#### Models - RSpec (1 spec)
- `/home/user/PlebisHub/spec/models/militant_record_spec.rb`

#### Models - Minitest (1 test)
- `/home/user/PlebisHub/test/models/militant_record_test.rb`

#### Request Specs (2 specs)
- `/home/user/PlebisHub/spec/requests/militant_get_militant_info_spec.rb`
- `/home/user/PlebisHub/spec/requests/tools_militant_request_spec.rb`

#### Factories (1 file)
- `/home/user/PlebisHub/test/factories/militant_records.rb`

---

### 10. USER AUTHENTICATION & DEVISE (18 tests)
**Target**: Core authentication (Devise)

#### Controllers (5 specs)
- `/home/user/PlebisHub/spec/controllers/confirmations_controller_spec.rb`
- `/home/user/PlebisHub/spec/controllers/legacy_password_controller_spec.rb`
- `/home/user/PlebisHub/spec/controllers/passwords_controller_spec.rb`
- `/home/user/PlebisHub/spec/controllers/registrations_controller_spec.rb`
- `/home/user/PlebisHub/spec/controllers/sessions_controller_spec.rb`

#### Models - Minitest (1 test)
- `/home/user/PlebisHub/test/models/user_test.rb`

#### Request Specs (9 specs)
- `/home/user/PlebisHub/spec/requests/devise_confirmations_new_spec.rb`
- `/home/user/PlebisHub/spec/requests/devise_passwords_edit_spec.rb`
- `/home/user/PlebisHub/spec/requests/devise_passwords_new_spec.rb`
- `/home/user/PlebisHub/spec/requests/devise_registrations_edit_spec.rb`
- `/home/user/PlebisHub/spec/requests/devise_registrations_new_spec.rb`
- `/home/user/PlebisHub/spec/requests/devise_registrations_qr_code_spec.rb`
- `/home/user/PlebisHub/spec/requests/devise_sessions_new_spec.rb`
- `/home/user/PlebisHub/spec/requests/devise_unlocks_new_spec.rb`
- `/home/user/PlebisHub/spec/requests/legacy_password_new_spec.rb`

#### Mailers (3 specs)
- `/home/user/PlebisHub/spec/mailers/devise_mailer_spec.rb`
- `/home/user/PlebisHub/spec/mailers/users_mailer_spec.rb`
- `/home/user/PlebisHub/spec/mailers/user_verification_mailer_spec.rb` (shared)

#### Factories (1 file)
- `/home/user/PlebisHub/test/factories/users.rb`

---

### 11. API (3 tests)
**Target**: Core API

#### Controllers (2 specs)
- `/home/user/PlebisHub/spec/controllers/api/v1_controller_spec.rb`
- `/home/user/PlebisHub/spec/controllers/api/v2_controller_spec.rb`

#### Request Specs (1 spec)
- `/home/user/PlebisHub/spec/requests/api_v2_get_data_spec.rb`

---

### 12. UTILITIES & INFRASTRUCTURE (12 tests)
**Target**: Core shared utilities

#### Controllers (3 specs)
- `/home/user/PlebisHub/spec/controllers/audio_captcha_controller_spec.rb`
- `/home/user/PlebisHub/spec/controllers/errors_controller_spec.rb`
- `/home/user/PlebisHub/spec/controllers/tools_controller_spec.rb`

#### Models - RSpec (3 specs)
- `/home/user/PlebisHub/spec/models/report_spec.rb`
- `/home/user/PlebisHub/spec/models/report_group_spec.rb`
- `/home/user/PlebisHub/spec/models/spam_filter_spec.rb`

#### Models - Minitest (3 tests)
- `/home/user/PlebisHub/test/models/report_test.rb`
- `/home/user/PlebisHub/test/models/report_group_test.rb`
- `/home/user/PlebisHub/test/models/spam_filter_test.rb`

#### Request Specs (3 specs)
- `/home/user/PlebisHub/spec/requests/errors_show_spec.rb`
- `/home/user/PlebisHub/spec/requests/tools_index_spec.rb`
- `/home/user/PlebisHub/spec/requests/tools_militant_request_spec.rb` (shared)

---

## Test Coverage Patterns

### Coverage by Functional Area

| Area | Controllers | Models (RSpec) | Models (Test) | Requests | Mailers | Services | Total |
|------|-------------|----------------|---------------|----------|---------|----------|-------|
| Voting | 1 | 8 | 8 | 8 | 0 | 0 | 25 |
| Microcredit | 1 | 3 | 3 | 6 | 0 | 0 | 13 |
| Collaborations | 2 | 2 | 2 | 6 | 1 | 0 | 13 |
| Impulsa | 1 | 6 | 6 | 5 | 1 | 0 | 19 |
| Verification | 1 | 1 | 1 | 8 | 1 | 3 | 15 |
| Teams | 1 | 1 | 1 | 1 | 0 | 0 | 4 |
| Notice | 1 | 2 | 2 | 1 | 0 | 0 | 6 |
| Blog/Content | 1 | 3 | 3 | 10 | 0 | 0 | 17 |
| Militant | 1 | 1 | 1 | 2 | 0 | 0 | 5 |
| Auth/Devise | 5 | 0 | 1 | 9 | 3 | 0 | 18 |
| API | 2 | 0 | 0 | 1 | 0 | 0 | 3 |
| Utilities | 3 | 3 | 3 | 3 | 0 | 0 | 12 |
| **TOTAL** | **20** | **30** | **31** | **60** | **6** | **3** | **150** |

### Test Type Distribution
- **Unit Tests (Models)**: 61 tests (30 RSpec + 31 Minitest + 1 concern)
- **Controller Tests**: 20 tests (all RSpec)
- **Integration Tests (Requests)**: 60 tests (all RSpec)
- **Mailer Tests**: 6 tests (all RSpec)
- **Service Tests**: 3 tests (all RSpec)
- **View Tests**: 1 test (RSpec)

### Test Coverage Strength
**Strong Coverage** (>15 tests):
- Voting (25) - Comprehensive coverage
- Impulsa (19) - Well tested
- Auth/Devise (18) - Solid authentication testing
- Blog/Content (17) - Good CMS coverage

**Moderate Coverage** (10-15 tests):
- Verification (15) - Good service coverage
- Collaborations (13) - Adequate
- Microcredit (13) - Adequate
- Utilities (12) - Basic infrastructure coverage

**Light Coverage** (<10 tests):
- Notice (6)
- Militant (5)
- Teams (4)
- API (3) - May need expansion

---

## Shared Test Utilities & Dependencies

### Utilities Needed by ALL Engines

#### 1. FactoryBot Configuration
**Location**: `spec/support/factory_bot.rb`
**Purpose**: Loads factories from both test/factories and spec/factories
**Action**: Keep in core, engines will reference core factories

#### 2. Test Helpers
**SimpleCov**: Coverage reporting (95% target)
**DatabaseCleaner**: Transaction management between tests
**WebMock**: HTTP request stubbing
**Warden**: Authentication helpers (Devise)

#### 3. Shared Factories (User-related)
**Critical shared factories needed by most engines**:
- `users.rb` - Used by nearly all engines
- `categories.rb` - Used by multiple areas
- `militant_records.rb` - User extension data

**Action**: Keep these in core app's test/factories, engines can reference via path

#### 4. Test Support Files
- `rails_legacy_aliases.rb` - Needed if engines use legacy before_filter syntax
- `blog_helper_stub.rb` - Only needed by Blog/Content engine

---

## Engine Test Organization Strategy

### Recommended Approach

Each engine should have its own complete test suite structure:

```
engines/voting_engine/
  spec/
    rails_helper.rb          # Extends main app's rails_helper
    controllers/
    models/
    requests/
    services/
  test/
    test_helper.rb           # Extends main app's test_helper
    models/
    factories/               # Engine-specific factories
```

### Migration Checklist Per Engine

#### Phase 1: Setup Engine Test Infrastructure
- [ ] Create engine's spec/rails_helper.rb (inherits from main app)
- [ ] Create engine's test/test_helper.rb (inherits from main app)
- [ ] Configure engine to load main app's test support files
- [ ] Set up engine-specific FactoryBot paths

#### Phase 2: Move Test Files
- [ ] Move controller specs to engine's spec/controllers/
- [ ] Move model specs to engine's spec/models/
- [ ] Move model tests to engine's test/models/
- [ ] Move request specs to engine's spec/requests/
- [ ] Move mailer specs to engine's spec/mailers/
- [ ] Move service specs to engine's spec/services/
- [ ] Move view specs to engine's spec/views/ (if any)

#### Phase 3: Move Factories
- [ ] Move engine-specific factories to engine's test/factories/
- [ ] Update factory references for shared factories (User, etc.)
- [ ] Ensure FactoryBot can find both engine and main app factories

#### Phase 4: Verify & Fix
- [ ] Run engine's test suite in isolation
- [ ] Fix factory dependencies
- [ ] Fix test helper dependencies
- [ ] Update any hardcoded paths
- [ ] Verify coverage reporting works

---

## Critical Considerations for Engine Migration

### 1. Factory Dependencies
**Challenge**: Many factories depend on User factory
**Solution**: 
- Keep User factory in main app
- Configure engines to load main app's factories
- Document factory dependencies

### 2. Test Helper Inheritance
**Challenge**: Engines need shared test configuration
**Solution**:
```ruby
# engines/voting_engine/spec/rails_helper.rb
require File.expand_path('../../../spec/rails_helper', __FILE__)

# Engine-specific test configuration here
```

### 3. Shared Test Data
**Challenge**: `test/lib/juntos_test.csv` used by voting
**Solution**: Keep in main app or copy to voting engine

### 4. Mailer Fixtures
**Challenge**: Collaborations mailer fixtures
**Solution**: Move to collaborations engine's test/fixtures/

### 5. Model Concerns Tests
**Challenge**: `safe_condition_evaluator_test.rb` is a shared concern
**Solution**: Keep in main app since it's used across engines

### 6. RSpec vs Minitest Duplication
**Challenge**: Many models have both RSpec and Minitest tests
**Decision Needed**: 
- Option A: Keep both (dual coverage)
- Option B: Standardize on RSpec, remove Minitest
- Option C: Keep Minitest for model tests, RSpec for integration

**Recommendation**: Keep both during migration, consolidate later

---

## Recommendations

### 1. Test Organization for Engines

**Keep in Main App** (Core):
- User authentication tests (Devise controllers, user model tests)
- Shared factories (users, categories)
- Test infrastructure (support files, helpers)
- API tests (cross-engine functionality)
- Utilities tests (errors, captcha, tools)
- Blog/Content tests (CMS functionality)
- Model concern tests

**Move to Engines**:
- Voting → VotingEngine (25 tests + 7 factories)
- Microcredit → MicrocreditEngine (13 tests + 3 factories)
- Collaborations → CollaborationsEngine (13 tests + 2 factories + fixtures)
- Impulsa → ImpulsaEngine (19 tests + 6 factories)
- Verification → UserVerificationEngine or Core (15 tests + 1 factory)
- Participation Teams → Core or separate engine (4 tests + 1 factory)
- Notice → Core (6 tests + 2 factories)
- Militant → Core (5 tests + 1 factory)

### 2. Shared Test Utilities Strategy

Create `test_support` directory in main app:
```
app/
  test_support/
    factory_bot_helper.rb
    shared_factories/
      users.rb
      categories.rb
    shared_examples/
      (any shared RSpec examples)
```

Engines require these via their test helpers.

### 3. FactoryBot Configuration

**Main App** (`spec/support/factory_bot.rb`):
```ruby
FactoryBot.definition_file_paths = [
  'test/factories',                    # Main app factories
  'engines/*/test/factories'           # Engine factories
]
```

### 4. Coverage Reporting

Configure SimpleCov to track engine code:
```ruby
SimpleCov.start 'rails' do
  add_group 'Engines', 'engines'
  add_group 'Voting Engine', 'engines/voting_engine'
  add_group 'Microcredit Engine', 'engines/microcredit_engine'
  # ... etc
end
```

### 5. Test Execution Strategy

- Run all tests: `bundle exec rspec && bundle exec rake test`
- Run engine tests: `bundle exec rspec engines/voting_engine/spec`
- Run specific area: `bundle exec rspec spec/models/vote_spec.rb`

### 6. Priority Order for Moving Tests

1. **Impulsa** (19 tests) - Self-contained, clear boundaries
2. **Microcredit** (13 tests) - Well-defined domain
3. **Collaborations** (13 tests) - Has mailer fixtures to move
4. **Voting** (25 tests) - Largest, has census data dependency
5. **Verification** (15 tests) - Has service objects
6. **Others** - Decide based on engine strategy

---

## Test Coverage Analysis

### Current Coverage Target
- Overall: 95%
- Per file: 80%

### Areas with Strong Test Coverage
1. Voting system (comprehensive)
2. Impulsa projects (includes services)
3. User verification (includes services)
4. Authentication (Devise integration)

### Areas Needing More Tests
1. API endpoints (only 3 tests)
2. Participation Teams (only 4 tests)
3. Notice system (only 6 tests)

### Test Quality Indicators
- **Good**: Uses FactoryBot (not fixtures) for test data
- **Good**: Mix of unit and integration tests
- **Good**: Service objects are tested
- **Good**: Mailers are tested
- **Needs Work**: Some model duplication (RSpec + Minitest)
- **Needs Work**: View testing is minimal (1 view spec)

---

## Next Steps

### Immediate Actions
1. Document factory dependencies between areas
2. Create test migration order based on engine priorities
3. Set up first engine test structure as template
4. Create shared test utilities extraction plan

### Before Each Engine Migration
1. Inventory all test dependencies for that engine
2. Identify shared factories needed
3. Plan test helper configuration
4. Create engine test directory structure

### During Engine Migration
1. Copy tests to engine
2. Update require paths
3. Configure FactoryBot paths
4. Run tests in isolation
5. Fix dependencies
6. Verify coverage

### After Engine Migration
1. Remove tests from main app
2. Update CI/CD to run engine tests
3. Document engine test patterns
4. Update developer documentation

---

## Conclusion

The PlebisHub test suite is well-structured with:
- **151 total tests** covering major functionality
- **27 FactoryBot factories** for test data
- **Dual framework support** (RSpec + Minitest)
- **95% coverage target** enforced
- **Clear separation** by functional area

The tests are well-organized for migration to engines, with clear boundaries between functional areas. The main challenges will be:
1. Managing shared factory dependencies (especially User)
2. Ensuring test helpers are properly inherited
3. Maintaining coverage reporting across engines
4. Handling the RSpec/Minitest duplication

Recommended approach: Migrate tests incrementally, one engine at a time, starting with self-contained engines like Impulsa and Microcredit.

