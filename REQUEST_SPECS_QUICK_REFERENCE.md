# Request Specs - Quick Reference

## Current Status
- **Before:** 1133 examples, 322 failures (71.6% pass)
- **After:** 1133 examples, 240 failures (78.8% pass)
- **Fixed:** 82 failures (25.5% improvement)

## What Was Fixed
All hardcoded locale paths corrected to match actual routes.

## What Remains

### Priority 1: Real Bugs (~30 failures)
**Files with 500 errors:**
- `spec/requests/collaborations_confirm_spec.rb`
- `spec/requests/devise_registrations_edit_spec.rb`
- `spec/requests/sms_validator_step1_spec.rb`

**Root cause:** Missing `semantic_form_with` helper, missing partials

**Fix:**
```ruby
# app/helpers/application_helper.rb
def semantic_form_with(**options, &block)
  form_with(**options) do |f|
    yield f
  end
end
```

### Priority 2: Auth Issues (~10 failures)
**Files:** `impulsa_project_spec.rb`, `user_verifications_new_spec.rb`

**Root cause:** before_action auth checks failing

**Fix:** Mock auth checks or setup test users properly

### Priority 3: Brittle Tests (~200 failures)
**Files:** Most request specs

**Root cause:** Tests check specific HTML structure/classes

**Recommendation:** Mark as pending, migrate to feature specs

## How to Fix Remaining Failures

### Option A: Quick Win (3-6 hours)
Fix Priority 1 and 2 only = real bugs fixed

### Option B: Complete (8-14 hours)  
Fix all three priorities = 100% pass rate

### Option C: Long-term (recommended)
1. Fix Priority 1 and 2
2. Migrate request specs to feature specs
3. Remove brittle HTML structure tests

## Modified Files
All request spec files with path corrections (24 files total)

See REQUEST_SPEC_ANALYSIS.md for full details.
