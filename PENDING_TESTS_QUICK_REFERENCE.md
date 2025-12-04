# PENDING TESTS - QUICK REFERENCE

**Total**: 67 pending tests | **Target**: 22 pending (keeping Devise :lockable)

## BREAKDOWN BY CATEGORY

| Category | Count | Time | Action |
|----------|-------|------|--------|
| Devise :lockable (KEEP) | 22 | - | Feature disabled, keep pending |
| AudioCaptcha/ESpeak | 24 | 5 min | Install espeak (optional) |
| PaperTrail issues | 7 | 2 hrs | Investigation needed |
| Quick wins | 6 | 20 min | Delete tests + mock config |
| External services | 3 | 35 min | Mock GCM + BroadcastLogger |
| Gem config | 2 | 20 min | Mock Carmen + implement test |
| Application bugs | 2 | 1 hr | Fix collaboration + purple text |
| EmailValidator | 1 | 30 min | Fix or replace gem |
| **TOTAL FIXABLE** | **45** | **4-5 hrs** | **Reduces to 22 pending** |

## 3-HOUR ACTION PLAN (67 → 53 pending)

### PHASE 1: Quick Wins (20 min) → -6 tests

```bash
# 1. DELETE redundant tests
spec/controllers/sessions_controller_spec.rb:114  # Delete
spec/controllers/sessions_controller_spec.rb:197  # Delete
spec/models/vote_circle_type_spec.rb:23           # Delete

# 2. MOCK Agora config in spec/rails_helper.rb
allow(Rails.application.secrets).to receive(:agora).and_return({...})

# 3. REMOVE skip from:
spec/models/election_location_question_spec.rb:139, 196
spec/models/election_location_spec.rb:305
```

### PHASE 2: Mock External Services (35 min) → -2 tests

```bash
# 1. Mock GCM in spec/models/notice_spec.rb:363
allow(GCM).to receive(:send_notification).and_return(true)

# 2. Fix BroadcastLogger in spec/models/concerns/safe_condition_evaluator_spec.rb:168
stub_const('BroadcastLogger', logger_double)
```

### PHASE 3: Gem Configuration (20 min) → -2 tests

```bash
# 1. Mock Carmen in spec/models/election_location_spec.rb:268
stub_const('PlebisBrand::GeoExtra', Class.new)

# 2. Implement test in spec/models/election_location_spec.rb:276
# Add Vote factory test implementation
```

### PHASE 4: Fix Support Factory (20 min) → -1 test

```bash
# Fix email uniqueness in spec/models/support_spec.rb:35
```

### PHASE 5: EmailValidator (30 min) → -1 test

```bash
# Fix or replace in spec/models/user_spec.rb:254
# Option: Use Rails built-in email validation
```

### PHASE 6: Application Bugs (60 min) → -2 tests

```bash
# 1. Fix collaboration redirect: spec/requests/collaborations_ok_spec.rb:167
# 2. Fix purple text feature: spec/requests/tools_militant_request_spec.rb:147
```

**Result**: 67 → 53 pending in 3 hours

## OPTIONAL: Install ESpeak (5 min) → -24 tests

```bash
# macOS
brew install espeak

# Linux
sudo apt-get install espeak

# Verify
which espeak
```

**Result**: 53 → 29 pending

## FUTURE: PaperTrail (2 hrs) → -7 tests

Investigation needed for `spec/models/user_spec.rb` tests:
- Lines 28, 325, 331, 337, 343, 349, 475

**Result**: 29 → 22 pending

## KEEP PENDING: Devise :lockable (22 tests)

These tests should remain pending unless you want to enable account locking:
- `spec/mailers/devise_mailer_spec.rb` (6 unlock tests)
- `spec/requests/devise_unlocks_new_spec.rb` (16 unlock route tests)

**Reason**: Feature intentionally disabled, tests ready when needed

## FILES TO MODIFY (Phases 1-6)

**Delete** (3 tests):
- `spec/controllers/sessions_controller_spec.rb` - lines 114, 197
- `spec/models/vote_circle_type_spec.rb` - line 23

**Add config**:
- `spec/rails_helper.rb` - Agora mock

**Remove skip + implement**:
- `spec/models/notice_spec.rb:363`
- `spec/models/concerns/safe_condition_evaluator_spec.rb:168`
- `spec/models/election_location_question_spec.rb:139, 196`
- `spec/models/election_location_spec.rb:268, 276, 305`
- `spec/models/support_spec.rb:35`
- `spec/models/user_spec.rb:254`
- `spec/requests/collaborations_ok_spec.rb:167`
- `spec/requests/tools_militant_request_spec.rb:147`

## SUCCESS METRICS

```
Starting:       67 pending
After 3 hours:  53 pending (-14 tests)
With ESpeak:    29 pending (-38 tests total)
With PaperTrail: 22 pending (-45 tests total)
Target:         22 pending (Devise :lockable only)
```

## VERIFICATION COMMANDS

```bash
# Before starting
bundle exec rspec | tail -3
# Should show: 3735 examples, 0 failures, 67 pending

# After each phase
bundle exec rspec --format documentation 2>&1 | grep -c "pending"

# Check specific file
bundle exec rspec spec/path/to/file_spec.rb
```

## NEXT STEPS

1. Read full analysis: `PENDING_TESTS_ANALYSIS.md`
2. Start with Phase 1 (20 minutes)
3. Verify count reduces to 61
4. Continue through phases
5. Track progress in `/tmp/test_progress.log`

---

**Quick Summary**:
- Fix **14 tests** in 3 hours (Phases 1-6)
- Optionally fix **24 more** by installing espeak (5 min)
- Leave **22 tests** pending (Devise :lockable feature)
- Investigate **7 tests** later (PaperTrail, 2 hours)

**Realistic Goal**: 67 → 29 pending tests (3.5 hours including espeak)
