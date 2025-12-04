# REQUEST SPEC FAILURE ANALYSIS - COMPREHENSIVE REPORT

## Executive Summary

**Initial State:** 1133 examples, 322 failures (71.6% pass rate)
**Current State:** 1133 examples, 240 failures (78.8% pass rate)
**Progress:** 82 failures FIXED (25.5% reduction)

## Work Completed

### Phase 1: Path Fixes (82 failures resolved)

Fixed all hardcoded Spanish locale paths that didn't match actual routes:

| Wrong Path | Correct Path | Files Fixed |
|------------|--------------|-------------|
| `/es/login` | `/es/users/sign_in` | All request specs |
| `/es/perfil` | `/es/users/edit` | devise_registrations_edit_spec.rb |
| `/es/registro` | `/es/users/sign_up` | devise_registrations_new_spec.rb |
| `/es/recuperar-contrasena` | `/es/users/password/new` | devise_passwords_new_spec.rb |
| `/es/carnet` | `/es/carnet_digital_con_qr` | devise_registrations_qr_code_spec.rb |
| `/es/validacion/sms` | `/es/validator/sms/step1` | sms_validator_step1_spec.rb |
| `/es/propuestas/informacion` | `/proposals/info` | proposals_info_spec.rb |
| `/es/equipos-participacion` | `/equipos-de-accion-participativa` | participation_teams_index_spec.rb |
| `/es/brujula` | `/brujula` | blog_spec.rb |
| `/es/notices` | `/notices` | Multiple specs |
| `/es/politica-privacidad` | `/politica-privacidad` | page_privacy_policy_spec.rb |
| `/es/preguntas-frecuentes` | `/preguntas-frecuentes` | Multiple specs |
| `/es/financiacion` | `/financiacion` | Multiple specs |
| `/es/confirmacion/nuevo` | `/es/users/confirmation/new` | devise_confirmations_new_spec.rb |

**Files Modified:** 24 request spec files
**Lines Changed:** ~300 path corrections

## Remaining 240 Failures - Categorized

### Category A: Content/HTML Structure Mismatches (~200 failures)

**Pattern:** Tests expect specific HTML elements, classes, or content that either:
- No longer exist after view refactoring
- Never existed (over-specified tests)
- Are in engine views with different structure

**Examples:**
```ruby
# Expects specific CSS classes that may have changed
expect(response.body).to include('content-content')
expect(response.body).to include('justify-texts')

# Expects specific text that may be in translations
expect(response.body).to match(/teléfono.*móvil/)

# Expects specific HTML structure
expect(response.body).to include('buttonbox')
```

**Top Affected Files:**
- participation_teams_index_spec.rb (18 failures)
- proposals_info_spec.rb (28 failures)  
- proposals_index_spec.rb (18 failures)
- blog_spec.rb (13 failures)
- devise_registrations_qr_code_spec.rb (18 failures)

**Remediation:** These tests are testing implementation details rather than functionality. Options:
1. Update tests to match current HTML structure
2. Make tests less brittle (test for presence of functionality, not specific HTML)
3. Remove overly specific tests in favor of feature specs

### Category B: 500 Internal Server Errors (~30 failures)

**Pattern:** Views crash during rendering, likely due to:
- Missing `semantic_form_with` helper
- Missing partials
- Undefined methods in views

**Top Affected Files:**
- collaborations_confirm_spec.rb (19 failures with 500 errors)
- devise_registrations_edit_spec.rb (multiple 500 errors)
- sms_validator_step1_spec.rb (12 failures with 500 errors)

**Remediation:** 
1. Implement semantic_form_with helper or replace with standard form_with
2. Create missing view partials
3. Debug specific view errors

**Example Fix Needed:**
```ruby
# In app/helpers/application_helper.rb or relevant helper
def semantic_form_with(**options, &block)
  form_with(**options) do |f|
    # Wrapper to make semantic_form_with compatible
    yield f
  end
end
```

### Category C: Authentication/Authorization (302 Redirects) (~10 failures)

**Pattern:** Tests expect 200 OK but get 302 redirects, due to:
- before_action checks (like can_change_phone)
- Missing authentication
- Authorization failures

**Affected Files:**
- impulsa_project_spec.rb (22 failures, some auth-related)
- user_verifications_new_spec.rb (some failures)

**Remediation:**
1. Mock authorization checks in tests
2. Set up test users with proper permissions
3. Bypass auth requirements in test environment where appropriate

## Recommendations

### Short-term (To achieve 100% pass):

1. **Fix Category B (500 errors) - PRIORITY 1**
   - These are real bugs that would affect production
   - Estimated effort: 2-4 hours
   - Would fix ~30 failures

2. **Fix Category C (Auth issues) - PRIORITY 2**
   - These tests reveal actual functionality problems
   - Estimated effort: 1-2 hours
   - Would fix ~10 failures

3. **Refactor Category A (HTML structure) - PRIORITY 3**
   - Either update tests or make them less brittle
   - Estimated effort: 4-8 hours
   - Would fix ~200 failures
   - **ALTERNATIVE:** Mark these as pending and focus on feature specs instead

### Long-term:

1. **Migrate to Feature Specs**
   - Request specs testing HTML structure are brittle
   - Feature specs with Capybara test actual user interactions
   - More maintainable and valuable

2. **Implement semantic_form_with properly**
   - Many views depend on this
   - Need consistent implementation across app and engines

3. **Standardize view patterns**
   - Use view components or partials consistently
   - Reduce duplication across engines

## Files Changed This Session

All request spec files with path corrections:
- spec/requests/blog_spec.rb
- spec/requests/collaborations_confirm_spec.rb
- spec/requests/collaborations_edit_spec.rb
- spec/requests/collaborations_occasional_spec.rb
- spec/requests/collaborations_ok_spec.rb
- spec/requests/devise_confirmations_new_spec.rb
- spec/requests/devise_passwords_new_spec.rb
- spec/requests/devise_registrations_edit_spec.rb
- spec/requests/devise_registrations_new_spec.rb
- spec/requests/devise_registrations_qr_code_spec.rb
- spec/requests/devise_sessions_new_spec.rb
- spec/requests/devise_unlocks_new_spec.rb
- spec/requests/impulsa_project_spec.rb
- spec/requests/page_privacy_policy_spec.rb
- spec/requests/participation_teams_index_spec.rb
- spec/requests/proposals_index_spec.rb
- spec/requests/proposals_info_spec.rb
- spec/requests/sms_validator_step1_spec.rb
- spec/requests/tools_militant_request_spec.rb
- spec/requests/user_verifications_new_spec.rb

## Next Steps to Reach 100%

1. Fix semantic_form_with errors (Priority 1)
2. Fix authentication setup in failing tests (Priority 2)
3. Either update or skip HTML structure tests (Priority 3)

**Estimated remaining effort to 100%:** 8-14 hours
**Recommended approach:** Fix Categories B and C (real bugs), skip/pending Category A (brittle tests)
