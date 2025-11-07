# MilitantController - Security & Quality Analysis

**Date**: 2025-11-07
**Controller**: app/controllers/militant_controller.rb
**Complexity**: MEDIUM-COMPLEX (HMAC verification, external API)
**Current Status**: ⚠️ CRITICAL SECURITY ISSUES

---

## Current Implementation

```ruby
class MilitantController < ActionController::Base
  #TODO : refactorize code and use API::V2Controller instead
  def get_militant_info
    @result = ""
    signature_service = UrlSignatureService.new
    url_verified, data = signature_service.verify_militant_url(request.original_url)

    if url_verified
      if params[:collaborate].present?
        current_user = User.find_by_id(params[:participa_user_id])
        @result = current_user.collaborator_for_militant? ? "1" : "0"
      else
        exemption = params[:exemption]
        current_user = User.find_by_id(params[:participa_user_id])
        if current_user
          current_user.update(exempt_from_payment: exemption)
          current_user.update(militant: current_user.still_militant?)
          current_user.process_militant_data
          @result = "OK#{exemption} #{data}"
        else
          @result = "UserError"
        end
      end
    else
      @result = "signatureError #{data}"
    end
  end
end
```

**Lines of Code**: 28
**Purpose**: External API endpoint for Participa to update user militant status and check collaboration status

---

## Security Assessment

### 🔴 CRITICAL PRIORITY ISSUES

#### 1. **No Explicit Render** - Line 3-27
**Severity**: CRITICAL
**Category**: Response Handling
**Location**: Entire action

**Issue**: No explicit render call - relies on implicit rendering with instance variable

```ruby
# CURRENT (implicit):
@result = "OK"
# Rails implicitly renders get_militant_info.html.erb with @result

# SHOULD BE (explicit):
render plain: "OK", status: :ok
```

**Risk**:
- Unexpected behavior if view template changes
- No control over content-type or status codes
- Difficult to test and maintain
- May expose internal variables in view

**Fix**: Add explicit render calls with proper content-type and status

---

#### 2. **Nil Handling Errors** - Lines 10-11, 14-22
**Severity**: CRITICAL
**Category**: Error Handling
**Location**: User lookup and method calls

**Issue**: No nil check before calling methods on user object

```ruby
# Line 10-11: Can raise NoMethodError if user is nil
current_user = User.find_by_id(params[:participa_user_id])
@result = current_user.collaborator_for_militant? # NoMethodError if nil!

# Line 15-19: Only checks in else branch, not in collaborate branch
if current_user
  # Updates...
end
```

**Risk**:
- NoMethodError exposed to external API caller
- 500 errors with stack traces
- Inconsistent error handling between branches

**Fix**: Add nil checks before all method calls

---

#### 3. **No Test Coverage** - Entire controller
**Severity**: CRITICAL
**Category**: Testing
**Location**: N/A

**Issue**: No test file exists for this security-sensitive controller

**Risk**:
- Regressions go undetected
- Security vulnerabilities not caught
- Difficult to refactor safely

**Fix**: Create comprehensive test suite

---

### 🟠 HIGH PRIORITY ISSUES

#### 4. **Input Validation Missing** - Lines 10, 13, 14
**Severity**: HIGH
**Category**: Input Validation
**Location**: Parameter usage

**Issue**: No validation of parameter types or values

```ruby
# No validation that participa_user_id is present or valid
current_user = User.find_by_id(params[:participa_user_id])

# No validation of exemption value (should be boolean or specific values)
exemption = params[:exemption]
current_user.update(exempt_from_payment: exemption)
```

**Risk**:
- SQL injection (mitigated by ActiveRecord, but still bad practice)
- Invalid data types stored in database
- Unexpected behavior with malformed input

**Fix**: Validate parameter presence, type, and range

---

#### 5. **No Authorization Check** - Lines 10, 14
**Severity**: HIGH
**Category**: Authorization
**Location**: User updates

**Issue**: Signature verifies URL is authentic but not that caller is authorized for specific user

```ruby
# Signature proves request is from trusted source
# But doesn't verify that source is authorized to modify THIS user
current_user = User.find_by_id(params[:participa_user_id])
current_user.update(exempt_from_payment: exemption)
```

**Risk**:
- Any valid signature can modify any user
- No user-specific authorization
- Potential privilege escalation

**Fix**: Verify signature includes and validates specific user_id

---

### 🟡 MEDIUM PRIORITY ISSUES

#### 6. **Duplicate Database Queries** - Lines 10, 14
**Severity**: MEDIUM
**Category**: Performance
**Location**: User lookup in if/else branches

**Issue**: User looked up twice in different branches

```ruby
if params[:collaborate].present?
  current_user = User.find_by_id(params[:participa_user_id]) # Query 1
  # ...
else
  current_user = User.find_by_id(params[:participa_user_id]) # Query 2 (same!)
  # ...
end
```

**Risk**:
- Unnecessary database queries
- Potential race condition (user could change between queries)
- Performance degradation

**Fix**: Move user lookup before if/else, query once

---

#### 7. **No Strong Parameters** - Line 16
**Severity**: MEDIUM
**Category**: Mass Assignment Protection
**Location**: User update

**Issue**: Direct update with param value without sanitization

```ruby
exemption = params[:exemption]
current_user.update(exempt_from_payment: exemption)
```

**Risk**:
- If exemption param is hash, could mass-assign other attributes
- Type coercion issues
- Unexpected values stored

**Fix**: Validate exemption value explicitly, use strong parameters pattern

---

#### 8. **CSRF Protection Disabled** - Line 1
**Severity**: MEDIUM (Intentional for API)
**Category**: CSRF Protection
**Location**: Controller inheritance

**Issue**: Inherits from `ActionController::Base` instead of `ApplicationController`

**Analysis**:
- This is an external API endpoint called from Participa platform
- HMAC signature provides authentication
- CSRF not applicable for server-to-server API

**Note**: ✅ This is acceptable for API endpoints, but should be documented

**Fix**: Add comment explaining why CSRF is disabled

---

#### 9. **Inconsistent Error Response Format** - Lines 21, 25
**Severity**: MEDIUM
**Category**: API Design
**Location**: Error responses

**Issue**: Different error formats for different error types

```ruby
@result = "UserError"        # Line 21
@result = "signatureError #{data}"  # Line 25
@result = "OK#{exemption} #{data}"  # Line 19
```

**Risk**:
- Difficult for API clients to parse responses
- Inconsistent error handling
- Data leakage in error messages (exposes signature data)

**Fix**: Use consistent JSON response format with proper status codes

---

### 🟢 LOW PRIORITY ISSUES

#### 10. **No Logging** - Entire action
**Severity**: LOW
**Category**: Observability
**Location**: All branches

**Issue**: No logging of security-sensitive actions

**Risk**:
- Cannot audit who changed militant status
- Cannot debug API issues
- No security monitoring trail

**Fix**: Add structured logging for all operations

---

#### 11. **Instance Variable Anti-pattern** - Line 4
**Severity**: LOW
**Category**: Code Quality
**Location**: @result usage

**Issue**: Uses instance variable for return value instead of explicit render

```ruby
@result = ""
# ... modify @result
# Implicit render uses @result in view
```

**Risk**:
- Coupling to view layer
- Difficult to test
- Unclear control flow

**Fix**: Use explicit render with return values

---

#### 12. **Multiple Update Calls** - Lines 16-17
**Severity**: LOW
**Category**: Performance
**Location**: User updates

**Issue**: Three separate database updates instead of one

```ruby
current_user.update(exempt_from_payment: exemption)  # UPDATE 1
current_user.update(militant: current_user.still_militant?)  # UPDATE 2
current_user.process_militant_data  # May trigger UPDATE 3
```

**Risk**:
- Three database round-trips
- Potential race conditions
- Inefficient

**Fix**: Combine into single update call where possible

---

## Security Checklist Results

### ⚠️ 1. Input Validation
- ❌ **No validation**: `participa_user_id` not validated for presence/type
- ❌ **No validation**: `exemption` value not validated
- ❌ **No validation**: `collaborate` parameter not validated (but uses .present?)
- ⚠️ **SQL Injection**: Safe via ActiveRecord, but should still validate

### ✅ 2. Path Traversal Security
- ✅ **Not Applicable**: No file operations

### ✅ 3. I18n Translation Handling
- ✅ **Not Applicable**: No I18n calls

### ✅ 4. Resource Cleanup
- ✅ **Not Applicable**: No temporary resources

### ⚠️ 5. Additional Security Checks
- ✅ **HMAC Signature**: Uses UrlSignatureService for authentication
- ⚠️ **CSRF Protection**: Disabled (acceptable for API, but should document)
- ❌ **Authorization**: No check that signature is for specific user
- ❌ **Error Handling**: NoMethodError if user is nil
- ❌ **Response Format**: Plain text instead of structured JSON
- ❌ **Logging**: No audit trail for sensitive operations

### ❌ 6. Test Coverage Requirements
- ❌ **No tests exist**: Need comprehensive test suite

---

## HMAC Signature Security

**Analysis**: `UrlSignatureService.verify_militant_url`

**How it works**:
1. Extracts signature and timestamp from URL
2. Rebuilds canonical URL with specific parameters
3. Generates expected signature using HMAC-SHA256
4. Compares expected vs received signature

**Security**:
- ✅ Uses HMAC-SHA256 (secure algorithm)
- ✅ Includes timestamp (prevents replay attacks with time window)
- ✅ Canonical URL includes participa_user_id, exemption, collaborate
- ⚠️ No timestamp expiration check (should verify timestamp is recent)
- ⚠️ Signature doesn't bind to specific user (authorization issue)

**Verdict**: 🟡 Signature provides authentication but weak authorization

---

## API Contract Analysis

**Expected Usage**: External call from Participa platform

**Scenarios**:
1. **Check if user is collaborator** (GET):
   - `?participa_user_id=123&collaborate=1&signature=xxx&timestamp=yyy`
   - Returns: "1" (yes) or "0" (no)

2. **Update user exemption status** (GET):
   - `?participa_user_id=123&exemption=true&signature=xxx&timestamp=yyy`
   - Returns: "OKtrue [data]"

**Problems**:
- Uses GET for state-changing operations (should use POST/PUT)
- No HTTP method restrictions
- Plain text responses (should be JSON)
- Success response includes internal data

---

## Summary

**Total Issues Found**: 12

### Breakdown by Severity:
- **CRITICAL**: 3 (No render, Nil handling, No tests)
- **HIGH**: 2 (Input validation, Authorization)
- **MEDIUM**: 4 (Duplicate queries, Strong params, CSRF docs, Error format)
- **LOW**: 3 (Logging, Instance var, Multiple updates)

### Required Fixes:
1. ✅ Add explicit render calls with proper content-type and status
2. ✅ Add nil checks before all method calls
3. ✅ Add input validation for all parameters
4. ✅ Move user lookup before if/else to avoid duplication
5. ✅ Validate exemption value explicitly
6. ✅ Add consistent JSON response format
7. ✅ Add structured logging for security audit
8. ✅ Combine multiple updates into single call where possible
9. ✅ Add comprehensive test suite
10. ✅ Document CSRF exemption and HMAC authentication

### Optional Enhancements:
- Add timestamp expiration check in signature verification
- Add rate limiting for API endpoint
- Consider moving to RESTful POST/PUT instead of GET
- Add user-specific authorization to signature
- Add metrics/monitoring for API usage

---

## Recommended Implementation

See fixed controller and comprehensive test suite for complete solution.

---

## Notes on Testing

**Challenges**:
- External API integration
- HMAC signature generation
- URL signature verification
- User state management

**Strategy**:
- Mock UrlSignatureService
- Test both collaborate and exemption flows
- Test all error scenarios
- Verify response formats
- Test nil user handling
- Test signature verification failure
