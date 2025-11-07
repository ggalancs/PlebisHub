# OrdersController - Security & Quality Analysis

**Date**: 2025-11-07
**Controller**: app/controllers/orders_controller.rb
**Complexity**: MEDIUM-COMPLEX (payment processing, XML/SOAP)
**Current Status**: ⚠️ DEPRECATIONS & MISSING ERROR HANDLING

---

## Current Implementation

```ruby
class OrdersController < ApplicationController
  protect_from_forgery except: :callback_redsys

  def callback_redsys
    processor = RedsysPaymentProcessor.new(params, request.body.read)
    result = processor.process

    order = result[:order]

    if result[:is_soap]
      render text: order.redsys_callback_response, content_type: "text/xml"
    else
      render text: order.is_paid? ? "OK" : "KO"
    end
  end
end
```

**Lines of Code**: 16
**Purpose**: Payment gateway callback endpoint for Redsys (Spanish payment processor)

---

## Security Assessment

### 🟡 MEDIUM PRIORITY ISSUES

#### 1. **Deprecated render Syntax** - Lines 11, 13
**Severity**: MEDIUM
**Category**: Deprecation / Code Quality
**Location**: `callback_redsys` action

**Issue**: `render text:` is deprecated in Rails 5+ and removed in Rails 7

```ruby
# DEPRECATED:
render text: order.redsys_callback_response, content_type: "text/xml"
render text: order.is_paid? ? "OK" : "KO"

# MODERN:
render xml: order.redsys_callback_response
render plain: order.is_paid? ? "OK" : "KO"
```

**Risk**:
- Will break in future Rails versions
- `render text:` uses HTML content-type by default (overridden here)

**Fix**: Use `render xml:` and `render plain:`

---

#### 2. **No Error Handling** - Lines 4-14
**Severity**: MEDIUM-HIGH
**Category**: Error Handling
**Location**: Entire action

**Issue**: No rescue blocks for potential failures

```ruby
# Can raise various exceptions:
# - XML parsing errors (malformed SOAP)
# - ActiveRecord errors (order not found, database failures)
# - Invalid order ID format
# - Missing parent object
```

**Risk**:
- 500 errors expose stack traces to payment gateway
- Failed payments may not be logged properly
- No graceful degradation

**Fix**: Add comprehensive error handling with logging

---

#### 3. **No Nil Check on Order** - Line 8
**Severity**: MEDIUM
**Category**: Nil Handling
**Location**: After processor.process

**Issue**: Assumes `result[:order]` always exists

```ruby
# CURRENT:
order = result[:order]
# ... immediately use order without nil check
```

**Risk**:
- NoMethodError if order creation fails
- Could expose sensitive error details

**Fix**: Add nil/presence validation

---

### 🟢 LOW PRIORITY ISSUES

#### 4. **No Request Logging** - Entire action
**Severity**: LOW
**Category**: Observability
**Location**: callback_redsys

**Issue**: No logging of callback attempts for security monitoring

**Risk**:
- Difficult to debug payment issues
- Can't detect suspicious callback patterns
- No audit trail for compliance

**Fix**: Add structured logging for all callbacks

---

#### 5. **No IP Validation** - Entire action
**Severity**: LOW (Redsys validates via signature)
**Category**: Defense in Depth
**Location**: callback_redsys

**Issue**: Doesn't validate request originates from Redsys servers

**Note**:
- Signature validation in `Order#redsys_parse_response!` is primary security
- IP validation would be additional layer
- Redsys IPs may change, signature is more reliable

**Fix**: Optional - could add IP whitelist as defense-in-depth

---

## Security Checklist Results

### ✅ 1. Input Validation
- ✅ **Delegate to Service**: RedsysPaymentProcessor validates inputs
- ⚠️ **Nil Checks**: Missing order nil validation
- ✅ **XML Parsing**: Uses Hash.from_xml (ActiveSupport - safe from XXE in Rails 7)

### ✅ 2. Path Traversal Security
- ✅ **Not Applicable**: No file operations

### ✅ 3. I18n Translation Handling
- ✅ **Not Applicable**: No I18n calls

### ✅ 4. Resource Cleanup
- ✅ **Not Applicable**: No temporary resources

### ✅ 5. Additional Security Checks
- ✅ **SQL Injection**: Uses ActiveRecord (safe)
- ✅ **XSS Prevention**: Renders plain text/XML (no HTML)
- ✅ **CSRF Protection**: Correctly disabled for callback (external POST)
- ✅ **Authentication**: N/A (payment gateway callback, uses HMAC signature)
- ✅ **Signature Validation**: Delegated to Order model (`redsys_merchant_response_signature`)
- ⚠️ **Error Handling**: Missing rescue blocks

### ✅ 6. Test Coverage Requirements
- ❌ **No tests exist**: Need comprehensive test suite

---

## Correctness of CSRF Exemption

**Analysis**: `protect_from_forgery except: :callback_redsys` is **CORRECT**

**Why CSRF is disabled:**
1. External callback from Redsys payment gateway
2. No session/cookies involved
3. Uses HMAC-SHA256 signature for authentication
4. Gateway can't obtain Rails CSRF token

**Security compensations:**
- HMAC signature validation (in `Order#redsys_parse_response!`)
- Timestamp validation (±1 hour window)
- Order ID validation

**Verdict**: ✅ Properly secured through cryptographic signatures

---

## XML/SOAP Security

**Analysis**: XML parsing via `Hash.from_xml`

**ActiveSupport XML Parsing (Rails 7)**:
- Uses Nokogiri by default
- XXE (XML External Entity) attacks mitigated by:
  - `Nokogiri::XML::ParseOptions::NONET` (no network access)
  - `Nokogiri::XML::ParseOptions::NOENT` (no entity expansion)
- XML Bomb protection: Nokogiri limits expansion

**Verdict**: ✅ Safe from common XML attacks in Rails 7.2

---

## Payment Processing Flow

1. **Redsys sends callback** → OrdersController#callback_redsys
2. **Parse request** → RedsysPaymentProcessor
   - Detects SOAP vs HTTP POST
   - Extracts order ID and parameters
3. **Find/Create Order** → Order.parent_from_order_id
4. **Validate & Process** → Order#redsys_parse_response!
   - Validates HMAC signature
   - Checks timestamp (±1 hour)
   - Updates order status
5. **Return response** → SOAP XML or "OK"/"KO"

---

## Summary

**Total Issues Found**: 5

### Breakdown by Severity:
- **MEDIUM**: 3 (Deprecated render, No error handling, No nil checks)
- **LOW**: 2 (No logging, No IP validation)

### Required Fixes:
1. ✅ Replace `render text:` with `render xml:` and `render plain:`
2. ✅ Add comprehensive error handling with rescue blocks
3. ✅ Add nil check for order before using
4. ✅ Add structured logging for callbacks
5. ✅ Add comprehensive test suite

### Optional Enhancements:
- IP whitelist validation (defense in depth)
- Rate limiting for callbacks
- Metrics/monitoring for payment failures

---

## Recommended Implementation

See fixed controller and comprehensive test suite for complete solution.

---

## Notes on Testing

**Challenges**:
- External payment gateway integration
- SOAP/XML parsing
- HMAC signature generation
- Time-based validation

**Strategy**:
- Mock RedsysPaymentProcessor
- Test both SOAP and HTTP POST flows
- Test error scenarios
- Verify response formats

