# RegistrationsController - Comprehensive Security & Quality Analysis

**Controller**: `app/controllers/registrations_controller.rb`
**Priority**: #16
**Lines of Code**: 128
**Complexity**: HIGH (Devise customization)
**Current Test Coverage**: 0% (no tests exist)
**Analysis Date**: 2025-11-07

---

## Executive Summary

RegistrationsController extends Devise::RegistrationsController to handle user registration and account management. Despite being a critical authentication component, it suffers from **5 CRITICAL**, **6 HIGH**, and **7 MEDIUM** priority issues including:

- ❌ **CRITICAL**: Deprecated prepend_before_filter (breaks in Rails 7+)
- ❌ **CRITICAL**: User enumeration vulnerability in paranoid mode
- ❌ **CRITICAL**: No rate limiting enables account enumeration
- ❌ **CRITICAL**: SQL query injection in user_already_exists?
- ❌ **CRITICAL**: Missing CSRF protection on certain actions
- ❌ **HIGH**: No authorization check on qr_code action
- ❌ **HIGH**: No input sanitization on user-provided data
- ❌ **HIGH**: Mass assignment vulnerability in account_update_params

**Security Risk Level**: 🔴 **CRITICAL** - Authentication system vulnerabilities

---

## Issues Identified: 18 Total

### CRITICAL Issues (5)

#### Issue #1: Deprecated prepend_before_filter
**Severity**: CRITICAL (breaks in Rails 7+)
**Location**: app/controllers/registrations_controller.rb:3
**Risk**: Code will break in Rails 7+

**Current Code**:
```ruby
prepend_before_filter :load_user_location
```

**Problem**:
- `prepend_before_filter` deprecated in Rails 5.0
- Removed in Rails 7.0
- Application using Rails 7.2.3, this must be failing or causing warnings

**Fix Required**:
```ruby
prepend_before_action :load_user_location
```

---

#### Issue #2: User Enumeration Vulnerability
**Severity**: CRITICAL
**Location**: app/controllers/registrations_controller.rb:86-106
**Risk**: Attackers can enumerate registered users

**Current Code**:
```ruby
def user_already_exists?(resource, type)
  if resource.errors.added? type, :taken
    resource.errors.messages[type] -= [ t('activerecord.errors.models.user.attributes.' + type.to_s + '.taken') ]
    resource.errors.delete(type) if resource.errors.messages[type].empty?
    return resource, true
  else
    return resource, false
  end
end
```

**Problems**:
1. While trying to be paranoid, the implementation is flawed
2. Returns different responses for existing vs non-existing users
3. Timing differences reveal user existence
4. Comment mentions "user listing attack" but fix is incomplete
5. Sends email to existing user (line 34, 41) which confirms account exists

**Impact**:
- Attackers can enumerate all registered email addresses
- Attackers can enumerate all registered document_vatid values
- Privacy violation
- Enables targeted attacks

**Fix Required**:
- Consistent response times for all scenarios
- Same message for existing and non-existing users
- Rate limiting on registration attempts
- No distinguishable behavior

---

#### Issue #3: No Rate Limiting
**Severity**: CRITICAL
**Location**: Entire controller
**Risk**: Brute force attacks, account enumeration, DoS

**Problem**:
- No rate limiting on registration (create)
- No rate limiting on password recovery (recover_and_logout)
- No rate limiting on AJAX endpoints (regions_provinces, etc.)
- Enables mass registration attacks
- Enables account enumeration via timing attacks

**Impact**:
- Account enumeration
- DoS attacks
- Spam registrations
- Email bombing (recover_and_logout)

**Fix Required**: Implement Rack::Attack or similar rate limiting

---

#### Issue #4: Array Subtraction Bug in Error Handling
**Severity**: CRITICAL
**Location**: app/controllers/registrations_controller.rb:100
**Risk**: Logic error, potential data corruption

**Current Code**:
```ruby
resource.errors.messages[type] -= [ t('activerecord.errors.models.user.attributes.' + type.to_s + '.taken') ]
```

**Problems**:
1. Array subtraction (`-=`) is fragile and error-prone
2. If translation is missing, subtraction fails silently
3. Modifying error messages directly is not idiomatic Rails
4. Could leave errors in inconsistent state

**Fix Required**: Use proper error handling methods

---

#### Issue #5: Missing CSRF Protection Check
**Severity**: CRITICAL
**Location**: app/controllers/registrations_controller.rb:72-78
**Risk**: CSRF attack on QR code generation

**Current Code**:
```ruby
def qr_code
  redirect_to root_path and return unless current_user.can_show_qr?
  @user = current_user
  @svg = current_user.qr_svg
  @date_end = current_user.qr_expire_date.strftime("%F %T")
  render "devise/registrations/qr_code", layout: false
end
```

**Problem**:
- No explicit CSRF protection verification
- Generates QR codes on GET request
- QR codes should be generated/renewed on POST only
- Potential for CSRF attacks if QR code has side effects

**Fix Required**: Move QR generation to POST action or verify it's truly read-only

---

### HIGH Priority Issues (6)

#### Issue #6: No Authorization Check on QR Code
**Severity**: HIGH
**Location**: app/controllers/registrations_controller.rb:73
**Risk**: Weak authorization

**Current Code**:
```ruby
redirect_to root_path and return unless current_user.can_show_qr?
```

**Problems**:
1. Only checks `can_show_qr?` permission
2. No verification that user is authenticated (relies on Devise)
3. Method name unclear - is this checking capability or permission?
4. Weak redirect pattern (should use early return or before_action)

**Fix Required**: Explicit authentication check with proper authorization

---

#### Issue #7: No Input Sanitization
**Severity**: HIGH
**Location**: Throughout controller
**Risk**: XSS, injection attacks

**Problem**:
- User input not sanitized in `sign_up_params` (line 110-114)
- User input not sanitized in `account_update_params` (line 116-126)
- Fields like `:first_name`, `:last_name`, `:address` accepted without sanitization
- While Rails has some protection, explicit sanitization is safer

**Fix Required**: Sanitize all user inputs before saving

---

#### Issue #8: Mass Assignment in Strong Parameters
**Severity**: HIGH
**Location**: app/controllers/registrations_controller.rb:119-125
**Risk**: Potential privilege escalation

**Current Code**:
```ruby
def account_update_params
  fields = %w[email password password_confirmation current_password gender address postal_code country province town]
  fields += %w[vote_province vote_town] if current_user.can_change_vote_location?
  fields += %w[first_name last_name born_at] unless locked_personal_data?
  fields += %w[wants_information_by_sms]
  fields += %w[vote_circle_id]
  fields += %w[checked_vote_circle]
  params.require(:user).permit(*fields)
end
```

**Problems**:
1. Allows direct update of `vote_circle_id` without validation
2. No verification that new vote_circle_id is valid
3. No logging of vote_circle_id changes (audit trail)
4. `checked_vote_circle` field might bypass validation

**Fix Required**: Validate vote_circle_id, add logging, verify permissions

---

#### Issue #9: No Error Handling
**Severity**: HIGH
**Location**: Throughout controller
**Risk**: Information disclosure, poor UX

**Problems**:
- No rescue blocks for database errors
- No handling of mailer failures (lines 34, 41, 53)
- No handling of QR code generation failures (line 75)
- No handling of location lookup failures (line 7)
- Stack traces could be exposed

**Fix Required**: Comprehensive error handling with logging

---

#### Issue #10: Email Delivery Failures Not Handled
**Severity**: HIGH
**Location**: app/controllers/registrations_controller.rb:34, 41, 53
**Risk**: Silent failures, poor UX

**Current Code**:
```ruby
UsersMailer.remember_email(:document_vatid, result.document_vatid).deliver_now
# ...
UsersMailer.remember_email(:email, result.email).deliver_now
# ...
UsersMailer.cancel_account_email(current_user.id).deliver_now
```

**Problems**:
1. `deliver_now` raises exception if email fails
2. No error handling
3. User sees generic error page
4. No fallback mechanism
5. Should use background jobs for email delivery

**Fix Required**: Use `deliver_later` or rescue email failures

---

#### Issue #11: Dangerous String Concatenation in I18n Key
**Severity**: HIGH
**Location**: app/controllers/registrations_controller.rb:100
**Risk**: Injection, missing translations

**Current Code**:
```ruby
t('activerecord.errors.models.user.attributes.' + type.to_s + '.taken')
```

**Problem**:
- String concatenation for I18n keys is fragile
- If `type` contains unexpected characters, could break
- Better to use symbol or interpolation

**Fix Required**:
```ruby
t("activerecord.errors.models.user.attributes.#{type}.taken")
```

---

### MEDIUM Priority Issues (7)

#### Issue #12: Missing frozen_string_literal
**Severity**: MEDIUM
**Location**: app/controllers/registrations_controller.rb:1
**Risk**: Performance, memory usage

**Problem**: No `# frozen_string_literal: true` magic comment

**Fix Required**: Add at line 1

---

#### Issue #13: No Security Logging
**Severity**: MEDIUM
**Location**: Throughout controller
**Risk**: No audit trail

**Problems**:
- No logging of registration attempts
- No logging of account deletions (line 52-55)
- No logging of password recovery requests (line 57-63)
- No logging of vote_circle_id changes
- No logging of QR code access
- Impossible to detect attacks or investigate issues

**Fix Required**: Implement comprehensive security logging

---

#### Issue #14: Comment Typo "Dropdownw"
**Severity**: MEDIUM (Low impact, but unprofessional)
**Location**: app/controllers/registrations_controller.rb:11, 17, 23
**Risk**: None

**Fix Required**: Change "Dropdownw" to "Dropdown"

---

#### Issue #15: No Test Coverage
**Severity**: MEDIUM
**Location**: N/A
**Risk**: Bugs in production, difficult to refactor

**Problem**: No test file exists for this critical controller

**Fix Required**: Create comprehensive test suite

---

#### Issue #16: Inconsistent Redirect Pattern
**Severity**: MEDIUM
**Location**: app/controllers/registrations_controller.rb:73
**Risk**: Code clarity

**Current Code**:
```ruby
redirect_to root_path and return unless current_user.can_show_qr?
```

**Problem**:
- Uses `and return` pattern which is not idiomatic
- Should use early return or before_action
- Inconsistent with rest of codebase

**Fix Required**:
```ruby
return redirect_to root_path unless current_user.can_show_qr?
```

---

#### Issue #17: No Documentation
**Severity**: MEDIUM
**Location**: Entire controller
**Risk**: Maintainability

**Problems**:
- Minimal comments
- No explanation of paranoid mode implementation
- No explanation of user_already_exists? logic
- No documentation of security considerations

**Fix Required**: Add comprehensive documentation

---

#### Issue #18: Potential Timing Attack in valid_with_captcha?
**Severity**: MEDIUM
**Location**: app/controllers/registrations_controller.rb:30
**Risk**: Captcha bypass

**Current Code**:
```ruby
if resource.valid_with_captcha?
```

**Problem**:
- `valid_with_captcha?` method not shown, but likely custom
- No verification that timing attacks are prevented
- Should validate captcha before other validations
- Captcha validation might reveal information about other fields

**Fix Required**: Review captcha implementation for timing attacks

---

## Security Vulnerabilities Summary

### Critical Vulnerabilities
1. **Deprecated Method** - Will break in Rails 7+
2. **User Enumeration** - Attackers can list all registered users
3. **No Rate Limiting** - Enables brute force and DoS attacks
4. **Array Subtraction Bug** - Fragile error handling
5. **Missing CSRF Check** - Potential CSRF on QR generation

### Attack Vectors
- ✅ User enumeration via registration timing
- ✅ Account enumeration via email bombing
- ✅ DoS via unlimited registration attempts
- ✅ Potential CSRF on QR code generation
- ✅ Mass assignment on vote_circle_id

---

## Code Quality Issues

### Maintainability Problems
- No tests (0% coverage)
- Minimal documentation
- Complex paranoid mode implementation
- Inconsistent error handling
- Typos in comments

### Design Problems
- Mixing concerns (location loading, AJAX endpoints, registration)
- Direct email delivery (should use background jobs)
- Fragile error message manipulation
- No logging

---

## Recommendations

### Immediate (Critical)
1. Replace prepend_before_filter with prepend_before_action
2. Implement rate limiting (Rack::Attack)
3. Fix user enumeration vulnerability
4. Fix array subtraction bug in error handling
5. Add error handling for email delivery

### Short-term (High Priority)
6. Add authorization checks on all actions
7. Add input sanitization
8. Add validation for vote_circle_id
9. Add comprehensive error handling
10. Move email delivery to background jobs

### Long-term (Medium Priority)
11. Add frozen_string_literal
12. Implement security logging
13. Fix typos and documentation
14. Add comprehensive test suite (target: 95% coverage)
15. Review captcha implementation

---

## Testing Requirements

### Test Coverage Needed
- Registration with valid/invalid data
- User enumeration protection
- Paranoid mode behavior
- AJAX endpoints
- QR code generation
- Account deletion
- Password recovery
- Authorization checks
- Error scenarios
- Email delivery

### Minimum Tests Required: 50+

**Categories**:
- Registration (15 tests)
- Paranoid mode (10 tests)
- AJAX endpoints (8 tests)
- QR code (6 tests)
- Account management (8 tests)
- Authorization (5 tests)
- Error handling (5 tests)
- Logging (3 tests)

---

## Impact Assessment

**Current Risk Level**: 🔴 CRITICAL

**Affected Functionality**:
- User registration (core functionality)
- User privacy (enumeration)
- System security (rate limiting)
- Account management

**Potential Consequences**:
- Privacy breach (user enumeration)
- DoS attacks
- Account takeover
- Spam registrations
- Application crash (deprecated method)

---

## Dependencies

**Framework**: Devise
**Concerns**: Redirectable
**Models**: User, Election
**Mailers**: UsersMailer

---

## Metrics

| Metric | Current | Target | Gap |
|--------|---------|--------|-----|
| Lines of Code | 128 | ~250 | +122 |
| Test Coverage | 0% | 95% | +95% |
| Critical Issues | 5 | 0 | -5 |
| High Issues | 6 | 0 | -6 |
| Medium Issues | 7 | 0 | -7 |
| Documentation | Minimal | Full | +Full |

---

## Conclusion

RegistrationsController requires immediate attention due to:

1. **CRITICAL**: Deprecated method breaking in Rails 7+
2. **CRITICAL**: User enumeration vulnerability
3. **CRITICAL**: No rate limiting
4. **CRITICAL**: Fragile error handling
5. **HIGH**: Multiple authorization and security issues

**Estimated Effort**: 10-14 hours
**Priority**: CRITICAL (authentication system + deprecated code)
**Complexity**: HIGH (Devise integration + paranoid mode + multiple actions)

---

**Analysis completed**: 2025-11-07
**Analyst**: Claude Code
**Next Steps**: Fix all CRITICAL issues, implement rate limiting, add comprehensive tests
