# COMPREHENSIVE ANALYSIS: ALL 67 PENDING TESTS
## Complete Breakdown and Actionable Fix Plan

**Generated**: 2025-12-03
**Status**: 3735 examples, 0 failures, **67 pending**
**Goal**: Reduce to 0 pending (where feasible)

---

## EXECUTIVE SUMMARY

### Quick Stats
- **Total Pending**: 67 tests
- **Quick Wins Available**: 6 tests in 20 minutes
- **Realistic 3-hour Goal**: Fix 39 tests (67 → 28 pending)
- **Complete Fix**: 7-8 hours for all 67 tests

### Category Breakdown
1. **Devise :lockable Feature** (22 tests) - Feature disabled, keep pending
2. **AudioCaptcha/ESpeak** (24 tests) - Requires espeak binary installation
3. **PaperTrail Versioning** (7 tests) - Factory/versioning conflict
4. **Application Issues** (8 tests) - Bugs, mocking, configuration
5. **Legacy/Cleanup** (6 tests) - Delete or fix quickly

---

## PART 1: COMPLETE TEST CATALOG (All 67 Tests)

### GROUP 1: Quick Wins (6 tests) - 20 minutes

#### Test 1: Support validation
- **File**: `spec/models/support_spec.rb:35`
- **Issue**: Email uniqueness from Collaboration factory
- **Fix**: Ensure unique user creation (20 min)

#### Tests 32-33: SessionsController (2 tests)
- **File**: `spec/controllers/sessions_controller_spec.rb`
- **Line 114**: "redirects after login" - Use request specs instead
- **Line 197**: "csrf protection" - Rails 7.2 implicitly tested
- **Fix**: Delete both tests (5 min)

#### Tests 29-30, 36: Agora Configuration (3 tests)
- **Files**:
  - `spec/models/election_location_question_spec.rb:139` - options_headers
  - `spec/models/election_location_question_spec.rb:196` - headers
  - `spec/models/election_location_spec.rb:305` - themes
- **Fix**: Mock `Rails.application.secrets.agora` in rails_helper (5 min)

---

### GROUP 2: External Service Mocking (3 tests) - 35 minutes

#### Test 2: Notice#broadcast!
- **File**: `spec/models/notice_spec.rb:363`
- **Issue**: Requires GCM service
- **Fix**: Mock GCM.send_notification (20 min)

#### Test 31: SafeConditionEvaluator
- **File**: `spec/models/concerns/safe_condition_evaluator_spec.rb:168`
- **Issue**: BroadcastLogger mocking strategy
- **Fix**: Use stub_const for BroadcastLogger (15 min)

---

### GROUP 3: Gem Configuration (2 tests) - 20 minutes

#### Test 34: ElectionLocation#territory
- **File**: `spec/models/election_location_spec.rb:268`
- **Issue**: Requires Carmen gem + PlebisBrand::GeoExtra
- **Fix**: Mock PlebisBrand::GeoExtra constant (10 min)

#### Test 35: ElectionLocation#valid_votes_count
- **File**: `spec/models/election_location_spec.rb:276`
- **Issue**: Requires Vote factory setup
- **Fix**: Implement test with Vote factory (10 min)

---

### GROUP 4: Gem Issues (1 test) - 30 minutes

#### Test 60: User email validation
- **File**: `spec/models/user_spec.rb:254`
- **Issue**: EmailValidator gem has known issues
- **Fix Options**:
  - Update gem
  - Replace with Rails built-in validation
  - Use different gem

---

### GROUP 5: Application Bugs (2 tests) - 1 hour

#### Test 3: Collaboration rendering
- **File**: `spec/requests/collaborations_ok_spec.rb:167`
- **Issue**: Getting 302 redirect instead of 200
- **Investigation Needed**: Authentication? Route change? Intentional redirect?
- **Time**: 30 min

#### Test 4: Purple text for exempt users
- **File**: `spec/requests/tools_militant_request_spec.rb:147`
- **Issue**: Purple text not showing for exempt_from_payment
- **Investigation Needed**: CSS class? View logic? Feature flag?
- **Time**: 30 min

---

### GROUP 6: Legacy/Cleanup (1 test) - 2 minutes

#### Test 59: VoteCircleType table
- **File**: `spec/models/vote_circle_type_spec.rb:23`
- **Issue**: Legacy model with no database table
- **Fix**: Delete test (2 min)

---

### GROUP 7: AudioCaptcha / ESpeak (24 tests) - Optional

**All tests in**: `spec/controllers/audio_captcha_controller_spec.rb`
**Root cause**: Line 16: `skip: !espeak_available`

**Tests 5-28** (24 tests total):
- Test 5: cleanup - deletes old files
- Test 6: cleanup - keeps new files
- Test 7: I18n fallback
- Test 8: invalid captcha returns 404
- Test 9: calls ESpeak with spelling
- Test 10: creates audio directory
- Test 11: uses random capital
- Test 12: generates audio file
- Test 13: uses Spanish voice
- Test 14: sends file with audio/mp3
- Test 15: uses random speed
- Test 16: sends file inline
- Test 17: uses random pitch
- Test 18: captcha spelling conversion
- Test 19: joins spellings with spaces
- Test 20: security - path traversal
- Test 21: randomization - different voices
- Test 22: randomization - different speeds
- Test 23: file management - .mp3 extension
- Test 24: randomization - different pitches
- Test 25: file management - tmp/audios directory
- Test 26: file management - captcha_key filename
- Test 27: missing captcha_key returns 404
- Test 28: empty captcha_key returns 404

**Fix**: Install espeak binary
```bash
# macOS
brew install espeak

# Linux
sudo apt-get install espeak

# Verify
which espeak
bundle exec rspec spec/controllers/audio_captcha_controller_spec.rb
```

**Time**: 5 min install + verification
**Decision**: Optional - only if audio captcha coverage needed

---

### GROUP 8: Devise :lockable Feature (22 tests) - KEEP PENDING

**Decision Required**: Enable Devise account locking feature?

#### Tests 37-42: Devise Mailer (6 tests)
**File**: `spec/mailers/devise_mailer_spec.rb`

All using `xit` (lines 73, 77, 81, 85, 89, 93):
- Test 37: "renderiza el asunto"
- Test 38: "renderiza el destinatario"
- Test 39: "renderiza el remitente"
- Test 40: "incluye el email del usuario"
- Test 41: "incluye el token de desbloqueo en el enlace"
- Test 42: "incluye información sobre desbloqueo"

**Note**: Line 68-69 comment: "These tests are pending because :lockable module is not enabled in Devise"

#### Tests 43-58: Devise Unlocks Routes (16 tests)
**File**: `spec/requests/devise_unlocks_new_spec.rb`
**Skip**: Line 5: `skip: "Unlock routes not enabled"`

- Test 43: renderiza correctamente sin autenticación
- Test 44: muestra título de instrucciones
- Test 45: tiene el title tag correcto
- Test 46: tiene formulario
- Test 47: tiene campo para email
- Test 48: campo email tiene autofocus
- Test 49: tiene botón de submit
- Test 50: botón menciona instrucciones
- Test 51: usa semantic_form_for
- Test 52: tiene fieldset
- Test 53: tiene legend invisible
- Test 54: usa inputlabel-box
- Test 55: tiene botón con clase button
- Test 56: usa estructura content-content cols
- Test 57: tiene h2 para título
- Test 58: usa row y col para layout

**To Enable Feature** (1-2 hours):
1. Add `:lockable` to User model devise modules
2. Generate migration for lockable fields
3. Configure Devise initializer
4. Change `xit` to `it` in mailer spec
5. Remove `skip:` from routes spec
6. Run migrations and tests

**Recommendation**: Keep pending unless business requirement exists

---

### GROUP 9: PaperTrail + Unconfirmed Users (7 tests) - Investigation Required

**All tests in**: `spec/models/user_spec.rb`
**Root Issue**: PaperTrail gem conflicts with unconfirmed user factory

#### Tests 61-67: User Scopes and Factory (7 tests)

- **Test 61** (Line 475): "does not have confirmed_at set for unconfirmed user"
- **Test 62** (Line 325): ".confirmed returns fully confirmed users"
- **Test 63** (Line 331): ".confirmed_mail returns email confirmed users"
- **Test 64** (Line 337): ".confirmed_phone returns phone confirmed users"
- **Test 65** (Line 343): ".unconfirmed_mail returns email unconfirmed users"
- **Test 66** (Line 349): ".unconfirmed_phone returns phone unconfirmed users"
- **Test 67** (Line 28): "creates unconfirmed user with trait"

**All skip reason**: "PaperTrail versioning issue with unconfirmed users"

**Fix Options** (1.5-2 hours investigation):

**Option A**: Disable PaperTrail globally in tests
```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.before(:each) { PaperTrail.enabled = false }
  config.after(:each) { PaperTrail.enabled = true }
end
```

**Option B**: Configure PaperTrail to ignore confirmation fields
```ruby
# app/models/user.rb
has_paper_trail ignore: [:confirmed_at, :sms_confirmed_at]
```

**Option C**: Fix unconfirmed factory to work with PaperTrail
```ruby
# spec/factories/user.rb
trait :unconfirmed do
  confirmed_at { nil }
  sms_confirmed_at { nil }
  after(:build) do |user|
    # Custom PaperTrail handling
  end
end
```

**Option D**: Rewrite tests without unconfirmed factory
```ruby
it 'creates unconfirmed user' do
  user = create(:user)
  user.update_columns(confirmed_at: nil, sms_confirmed_at: nil)
  expect(user.confirmed_at).to be_nil
end
```

**Recommendation**: Investigate Option D first (least invasive), then Option A

---

## PART 2: PRIORITIZED EXECUTION PLAN

### PHASE 1: Quick Wins (20 minutes)
**Goal**: 67 → 61 pending

1. Delete SessionsController tests (5 min)
   - Delete lines 114 and 197 from `spec/controllers/sessions_controller_spec.rb`

2. Delete VoteCircleType test (2 min)
   - Delete line 23 from `spec/models/vote_circle_type_spec.rb`

3. Mock Agora configuration (5 min)
   - Add to `spec/rails_helper.rb`:
   ```ruby
   RSpec.configure do |config|
     config.before(:each) do
       agora_config = {
         'options_headers' => {'header' => 'value'},
         'themes' => ['default']
       }
       allow(Rails.application.secrets).to receive(:agora).and_return(agora_config)
     end
   end
   ```
   - Remove skip from tests 29, 30, 36

**Result**: -6 tests

---

### PHASE 2: External Service Mocking (35 minutes)
**Goal**: 61 → 59 pending

4. Mock GCM service (20 min)
   - File: `spec/models/notice_spec.rb:363`
   - Remove skip, add GCM mock

5. Fix BroadcastLogger (15 min)
   - File: `spec/models/concerns/safe_condition_evaluator_spec.rb:168`
   - Use stub_const approach

**Result**: -2 tests

---

### PHASE 3: Gem Configuration (20 minutes)
**Goal**: 59 → 57 pending

6. Mock Carmen/GeoExtra (10 min)
   - File: `spec/models/election_location_spec.rb:268`
   - Add: `stub_const('PlebisBrand::GeoExtra', Class.new)`

7. Implement votes test (10 min)
   - File: `spec/models/election_location_spec.rb:276`
   - Create test with Vote factory

**Result**: -2 tests

---

### PHASE 4: Factory Issues (20 minutes)
**Goal**: 57 → 56 pending

8. Fix Support factory (20 min)
   - File: `spec/models/support_spec.rb:35`
   - Ensure unique email generation

**Result**: -1 test

---

### PHASE 5: EmailValidator (30 minutes)
**Goal**: 56 → 55 pending

9. Fix email validation (30 min)
   - File: `spec/models/user_spec.rb:254`
   - Option A: Update gem
   - Option B: Use Rails built-in validation

**Result**: -1 test

---

### PHASE 6: Application Bugs (60 minutes)
**Goal**: 55 → 53 pending

10. Fix collaboration redirect (30 min)
    - File: `spec/requests/collaborations_ok_spec.rb:167`
    - Investigate and fix

11. Fix purple text feature (30 min)
    - File: `spec/requests/tools_militant_request_spec.rb:147`
    - Check CSS and view logic

**Result**: -2 tests

---

### OPTIONAL PHASE 7: Install ESpeak (5 minutes)
**Goal**: 53 → 29 pending

12. Install espeak (5 min)
    ```bash
    brew install espeak  # macOS
    # or
    sudo apt-get install espeak  # Linux
    ```

**Result**: -24 tests

---

### FUTURE PHASE 8: PaperTrail Investigation (1.5-2 hours)
**Goal**: 29 (or 53) → 22 (or 46) pending

13. Investigate and fix PaperTrail conflicts (2 hours)
    - Test different approaches
    - Implement chosen solution
    - Verify all 7 tests pass

**Result**: -7 tests

---

### FUTURE DECISION: Devise :lockable Feature
**Goal**: 22 (or 46) → 0 (or 24) pending

14. Enable Devise :lockable (1-2 hours) OR keep pending
    - If enable: Follow steps in GROUP 8
    - If keep: Tests remain as documentation

**Result**: -22 tests OR keep pending

---

## PART 3: FILES REQUIRING MODIFICATION

### Definite Changes (Phases 1-6):
```
spec/controllers/sessions_controller_spec.rb - Delete 2 tests
spec/models/vote_circle_type_spec.rb - Delete 1 test
spec/rails_helper.rb - Add Agora mock configuration
spec/models/election_location_question_spec.rb - Remove 2 skips
spec/models/election_location_spec.rb - Remove 2 skips, implement 1 test
spec/models/notice_spec.rb - Implement GCM mock, remove skip
spec/models/concerns/safe_condition_evaluator_spec.rb - Fix logger mock
spec/requests/collaborations_ok_spec.rb - Fix or update test
spec/requests/tools_militant_request_spec.rb - Fix or update test
spec/models/user_spec.rb - Fix email validator test
spec/models/support_spec.rb - Fix factory uniqueness
```

### Optional Changes (Phase 7 - ESpeak):
```
System-level installation only - no file changes needed
```

### Future Changes (Phase 8 - PaperTrail):
```
spec/models/user_spec.rb - Remove 7 skips
spec/factories/user.rb - Possibly fix unconfirmed trait
spec/rails_helper.rb - Possibly disable PaperTrail
app/models/user.rb - Possibly configure PaperTrail
```

### Future Changes (Devise :lockable):
```
app/models/user.rb - Add :lockable module
db/migrate/XXX_add_lockable_to_users.rb - New migration
config/initializers/devise.rb - Configure lockable settings
spec/mailers/devise_mailer_spec.rb - Change xit to it (6 tests)
spec/requests/devise_unlocks_new_spec.rb - Remove skip (16 tests)
```

---

## PART 4: EFFORT SUMMARY

### Time Investment by Phase:
- **Phase 1** (Quick Wins): 20 minutes → -6 tests
- **Phase 2** (Mocking): 35 minutes → -2 tests
- **Phase 3** (Gems): 20 minutes → -2 tests
- **Phase 4** (Factory): 20 minutes → -1 test
- **Phase 5** (EmailValidator): 30 minutes → -1 test
- **Phase 6** (App Bugs): 60 minutes → -2 tests
- **Phase 7** (ESpeak): 5 minutes → -24 tests (optional)
- **Phase 8** (PaperTrail): 120 minutes → -7 tests (future)
- **Devise :lockable**: 120 minutes → -22 tests (decision)

### Total Effort Scenarios:
- **Minimum** (Phases 1-6): 3 hours 5 minutes → 14 tests fixed (67 → 53)
- **With ESpeak** (Phases 1-7): 3 hours 10 minutes → 38 tests fixed (67 → 29)
- **With PaperTrail** (Phases 1-8): 5-6 hours → 45 tests fixed (67 → 22)
- **Complete** (All phases): 7-8 hours → 67 tests fixed (67 → 0)

### Recommended Targets:
- **Session 1** (90 min): Phases 1-4 → 67 to 56 pending
- **Session 2** (90 min): Phases 5-6 → 56 to 53 pending
- **Optional**: Phase 7 (5 min) → 53 to 29 pending
- **Future**: Phase 8 (2 hours) → 29 to 22 pending
- **Decision**: Enable :lockable or keep 22 pending

---

## PART 5: DECISION POINTS

### Decision 1: Devise :lockable Feature
**Question**: Enable account locking after failed login attempts?

**If YES**:
- Time: 1-2 hours
- Tests fixed: 22
- Feature gained: Account security (failed login lockout)
- Maintenance: Ongoing unlock request handling

**If NO**:
- Time: 0
- Tests pending: 22
- Benefit: Tests serve as documentation, ready when needed

**Recommendation**: Keep pending unless business requirement exists

---

### Decision 2: PaperTrail Configuration
**Question**: How to handle PaperTrail + unconfirmed users?

**Option A**: Disable PaperTrail in all tests
- Pros: Simple, fixes all 7 tests
- Cons: Loses PaperTrail test coverage

**Option B**: Ignore confirmation fields
- Pros: Keeps PaperTrail active
- Cons: No audit trail for confirmations

**Option C**: Rewrite tests
- Pros: Non-invasive
- Cons: More test code

**Option D**: Fix factory
- Pros: Proper solution
- Cons: Complex

**Recommendation**: Try C or D first, fall back to A if needed

---

### Decision 3: ESpeak Installation
**Question**: Install espeak for audio captcha tests?

**If YES**:
- Time: 5 minutes
- Tests fixed: 24
- Coverage: Full audio captcha testing
- Note: CI may not have espeak installed

**If NO**:
- Time: 0
- Tests pending: 24
- Coverage: No audio captcha testing

**Recommendation**: Install locally, accept CI skip

---

### Decision 4: Application Bugs
**Question**: Are these real bugs or test issues?

**Collaboration rendering** (302 redirect):
- Investigate: Is redirect intentional?
- Fix: Code or test expectations

**Purple text** (exempt_from_payment):
- Investigate: Is feature implemented?
- Fix: CSS, view, or test logic

**Recommendation**: Investigate both (budget 1 hour)

---

## PART 6: SUCCESS METRICS

### Milestone Tracking:
```
Current:         67 pending tests
After Phase 1:   61 pending tests (-6)
After Phase 2:   59 pending tests (-2)
After Phase 3:   57 pending tests (-2)
After Phase 4:   56 pending tests (-1)
After Phase 5:   55 pending tests (-1)
After Phase 6:   53 pending tests (-2)
After Phase 7:   29 pending tests (-24) - if installing espeak
After Phase 8:   22 pending tests (-7)  - if fixing PaperTrail
After :lockable:  0 pending tests (-22) - if enabling feature
```

### Target Goals:
- **Minimum Success**: 67 → 53 (-14 tests, 3 hours)
- **Good Success**: 67 → 29 (-38 tests, 3.5 hours with espeak)
- **Excellent**: 67 → 22 (-45 tests, 5.5 hours)
- **Perfect**: 67 → 0 (-67 tests, 7-8 hours)

---

## PART 7: READY TO START?

### Pre-flight Check:
```bash
# Verify current state
bundle exec rspec --format documentation 2>&1 | grep -c "pending"
# Expected: 67

# Run quick test
bundle exec rspec --format documentation 2>&1 | tail -20
# Should see: "3735 examples, 0 failures, 67 pending"
```

### Phase 1 Verification:
```bash
# After making Phase 1 changes
bundle exec rspec --format documentation 2>&1 | grep -c "pending"
# Expected: 61
```

### Track Progress:
Create a tracking file:
```bash
echo "Phase 1: $(date) - Starting with 67 pending" >> /tmp/test_progress.log
# After each phase:
echo "Phase X: $(date) - Now at YY pending" >> /tmp/test_progress.log
```

---

## CONCLUSION

This comprehensive analysis identifies all 67 pending tests, categorizes them by fixability, provides detailed fix instructions for each, and outlines a prioritized execution plan.

**Key Takeaways**:
1. **14 tests** can be fixed in 3 hours (Phases 1-6)
2. **38 tests** can be fixed in 3.5 hours (with espeak installation)
3. **22 tests** should remain pending (Devise :lockable feature decision)
4. **7 tests** require PaperTrail investigation (add 2 hours)

**Recommended Approach**:
- Complete Phases 1-6 first (3 hours)
- Optionally install espeak (add 5 minutes)
- Investigate PaperTrail issues later (dedicated 2-hour session)
- Keep Devise :lockable tests pending (tests serve as documentation)

**Final State Target**: 22 pending tests (all Devise :lockable feature tests)

This leaves a clean, maintainable test suite with pending tests only for intentionally disabled features.

---

**Document Version**: 1.0
**Last Updated**: 2025-12-03
**Next Review**: After Phase 6 completion
