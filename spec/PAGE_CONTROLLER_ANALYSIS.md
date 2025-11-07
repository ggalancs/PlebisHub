# PageController - Security & Quality Analysis

**Date**: 2025-11-07
**Controller**: app/controllers/page_controller.rb
**Complexity**: COMPLEX (30+ actions, form iframe embedding)
**Current Status**: ⚠️ CRITICAL SECURITY ISSUES

---

## Current Implementation

**Lines of Code**: 230
**Purpose**: Form iframe embedding with user data pre-population and URL signing
**Actions**: 30+ actions for various form pages (primaries, candidatures, hospitality, etc.)

### Key Components:
- `show_form`: Dynamic page rendering with optional authentication
- `add_user_params`: Adds user PII to URL parameters
- `sign_url`: HMAC signature via UrlSignatureService
- Multiple static form actions (privacy_policy, faq, guarantees, etc.)

---

## Security Assessment

### 🔴 CRITICAL PRIORITY ISSUES

#### 1. **PII Exposure in URL Parameters** - Lines 186-217
**Severity**: CRITICAL
**Category**: Data Privacy / Security
**Location**: `add_user_params` method

**Issue**: Sensitive personal information exposed in GET request URLs

```ruby
params = {
  id: current_user.id,
  first_name: current_user.first_name,
  last_name: current_user.last_name,
  document_vatid: current_user.document_vatid,  # National ID!
  born_at: current_user.born_at.strftime('%d/%m/%Y'),  # DOB!
  phone: current_user.phone,
  email: current_user.email,
  address: current_user.full_address,
  # ... 13 total fields
}
url + params.map { |param, value| "&participa_user_#{param}=#{u(value)}" }.join
```

**Risk**:
- PII logged in server logs, browser history, proxy logs
- Visible in browser address bar
- Can be leaked via Referer header
- Not encrypted even with HTTPS (appears in logs)
- GDPR/privacy law violations
- Social engineering attacks using visible data

**Impact**: CRITICAL - Violates data protection regulations

**Fix**: Use POST requests with encrypted body, or session-based data transfer

---

#### 2. **No Nil Check Before strftime** - Line 202
**Severity**: CRITICAL
**Category**: Error Handling
**Location**: `add_user_params` method

**Issue**: Will crash with NoMethodError if `born_at` is nil

```ruby
born_at: current_user.born_at.strftime('%d/%m/%Y'),  # Crashes if nil!
```

**Risk**:
- 500 error for users without birth date
- Application crash
- Stack trace exposure

**Fix**: Add nil check with safe navigation or default value

---

#### 3. **Duplicate Method Definition** - Lines 124-130
**Severity**: CRITICAL
**Category**: Code Quality / Bugs
**Location**: `representantes_electorales_extranjeros`

**Issue**: Method defined twice (lines 124 and 128), second overrides first

```ruby
def representantes_electorales_extranjeros  # Line 124
  render :form_iframe, locals: { ... }
end

def representantes_electorales_extranjeros  # Line 128 (DUPLICATE!)
  render :form_iframe, locals: { ... }
end
```

**Risk**:
- Confusion about which code actually runs
- Potential bugs if they differ
- Dead code
- Linting warnings

**Fix**: Remove duplicate method

---

#### 4. **No Error Handling for Page.find** - Line 25
**Severity**: CRITICAL
**Category**: Error Handling
**Location**: `show_form` action

**Issue**: Will raise ActiveRecord::RecordNotFound if page doesn't exist

```ruby
@page = Page.find(params[:id])  # Raises if not found
```

**Risk**:
- 404 error page (acceptable) but no custom handling
- Potential for enumeration attacks
- No logging of invalid access attempts

**Fix**: Use `find_by` with nil handling or rescue RecordNotFound

---

### 🟠 HIGH PRIORITY ISSUES

#### 5. **Deprecated before_filter** - Line 14
**Severity**: HIGH
**Category**: Deprecation
**Location**: Filter declaration

**Issue**: `before_filter` deprecated in Rails 5.0, removed in Rails 5.1+

```ruby
before_filter :set_metas  # DEPRECATED
```

**Should be**:
```ruby
before_action :set_metas  # MODERN
```

**Risk**:
- Will break in future Rails versions
- Already deprecated warnings in logs

**Fix**: Replace with `before_action`

---

#### 6. **Regex URL Matching in Controller** - Line 34
**Severity**: HIGH
**Category**: Code Quality / Security
**Location**: `show_form` action

**Issue**: Business logic (URL pattern matching) in controller instead of model

```ruby
if /https:\/\/[^\/]*\.plebisbrand.info\/.*/.match(@page.link)
  render :formview_iframe, locals: { ... }
else
  render :form_iframe, locals: { ... }
end
```

**Problems**:
- Duplicates logic from Page model (line 18 in page.rb has same regex)
- Controller shouldn't contain business logic
- Harder to test
- Inconsistent with model method `external_plebisbrand_link?`

**Fix**: Use `@page.external_plebisbrand_link?` method

---

#### 7. **No Input Validation** - Line 25
**Severity**: HIGH
**Category**: Input Validation
**Location**: `show_form` action

**Issue**: No validation of `params[:id]` before use

```ruby
@page = Page.find(params[:id])  # What if params[:id] is malicious?
```

**Risk**:
- SQL injection (mitigated by ActiveRecord, but bad practice)
- Invalid ID formats causing errors

**Fix**: Validate ID is numeric and positive

---

#### 8. **No URL Encoding Validation** - Line 216
**Severity**: HIGH
**Category**: Security
**Location**: `add_user_params` method

**Issue**: Uses ERB::Util `u()` for URL encoding but doesn't validate input

```ruby
url + params.map { |param, value| "&participa_user_#{param}=#{u(value)}" }.join
```

**Risk**:
- If user data contains unexpected characters, could break URL
- No validation that encoded result is safe
- Potential for URL injection if base URL is attacker-controlled

**Fix**: Validate user data before encoding, use proper URI building

---

### 🟡 MEDIUM PRIORITY ISSUES

#### 9. **Logic Bug in set_metas** - Lines 20-21
**Severity**: MEDIUM
**Category**: Logic Error
**Location**: `set_metas` method

**Issue**: Line 21 checks `@meta_description` instead of `@meta_image`

```ruby
@meta_description = Rails.application.secrets.metas["description"] if @meta_description.nil?
@meta_image = Rails.application.secrets.metas["image"] if @meta_description.nil?  # BUG!
                                                        # Should be @meta_image.nil?
```

**Risk**:
- meta_image never gets default value if meta_description is set
- Incorrect SEO/social media previews

**Fix**: Change condition to `if @meta_image.nil?`

---

#### 10. **Unused Variable in set_metas** - Line 17
**Severity**: MEDIUM
**Category**: Code Quality
**Location**: `set_metas` method

**Issue**: Variable `election` assigned but never used

```ruby
election = @current_elections.select {|election| election.meta_description if !election.meta_description.blank? }.first
# Variable 'election' is never used after this
```

**Risk**:
- Dead code
- Confusing to maintainers
- Potential logic error (was it supposed to be used?)

**Fix**: Remove or use the variable

---

#### 11. **No Test Coverage** - Entire controller
**Severity**: MEDIUM
**Category**: Testing
**Location**: N/A

**Issue**: No test file exists for this complex controller

**Risk**:
- Regressions go undetected
- PII exposure issues not caught
- Difficult to refactor safely
- Business logic bugs uncaught

**Fix**: Create comprehensive test suite

---

#### 12. **Massive Code Duplication** - Lines 53-178
**Severity**: MEDIUM
**Category**: Code Quality
**Location**: Multiple form actions

**Issue**: 25+ nearly identical methods that just render form_iframe with different parameters

```ruby
def guarantees_form
  render :form_iframe, locals: { title: "...", url: form_url(77), return_path: guarantees_path }
end

def old_circles_data_validation
  render :form_iframe, locals: { title: "...", url: form_url(45) }
end

# ... 23 more similar methods
```

**Risk**:
- Hard to maintain
- Bugs need fixing in multiple places
- No DRY principle

**Fix**: Create a generic `render_form` action with dynamic routing or configuration

---

### 🟢 LOW PRIORITY ISSUES

#### 13. **No Logging** - Entire controller
**Severity**: LOW
**Category**: Observability
**Location**: All actions

**Issue**: No logging of form access, especially for sensitive forms

**Risk**:
- Cannot audit who accessed which forms
- No security monitoring
- Difficult to debug issues

**Fix**: Add structured logging for form access

---

#### 14. **Domain and Secret Caching** - Lines 223-229
**Severity**: LOW
**Category**: Performance
**Location**: Private methods

**Issue**: Uses instance variables to cache secrets

```ruby
def domain
  @domain ||= Rails.application.secrets.forms["domain"]
end

def secret
  @secret ||= Rails.application.secrets.forms["secret"]
end
```

**Note**: This is actually acceptable, but could use class-level caching or config object

**Fix**: (Optional) Move to application config

---

## Security Checklist Results

### ❌ 1. Input Validation
- ❌ **No validation**: `params[:id]` not validated before Page.find
- ❌ **No nil checks**: `born_at.strftime` without nil guard
- ⚠️ **URL validation**: No validation of constructed URLs

### ✅ 2. Path Traversal Security
- ✅ **Not Applicable**: No file operations

### ✅ 3. I18n Translation Handling
- ✅ **Not Applicable**: No I18n calls

### ✅ 4. Resource Cleanup
- ✅ **Not Applicable**: No temporary resources

### ⚠️ 5. Additional Security Checks
- ✅ **HMAC Signature**: Uses UrlSignatureService (good!)
- ✅ **Authentication**: Has `before_action :authenticate_user!` with exceptions
- ❌ **PII Protection**: Exposes sensitive data in URLs (CRITICAL)
- ❌ **Error Handling**: No rescue blocks for Page.find
- ❌ **URL Validation**: Regex in controller instead of using model method
- ⚠️ **SQL Injection**: Safe via ActiveRecord, but should validate ID

### ❌ 6. Test Coverage Requirements
- ❌ **No tests exist**: Need comprehensive test suite

---

## Data Privacy Analysis (GDPR/CCPA)

**Critical Finding**: `add_user_params` method violates data minimization principles

### Data Exposed in URLs:
1. **Identity**: id, first_name, last_name, document_vatid
2. **Contact**: email, phone, address, postal_code, country
3. **Demographic**: born_at, gender
4. **Political**: vote_town, autonomy, town_code
5. **Financial**: exempt_from_payment

### Violations:
- **URL Logging**: All this data logged in:
  - Web server access logs
  - Proxy server logs
  - Browser history
  - Analytics systems
  - CDN logs (if applicable)
- **Referer Leakage**: PII leaked when user clicks external links
- **Session Replay**: Visible in session replay tools
- **Copy/Paste**: Users may share URLs with PII

### Compliance:
- ⚠️ **GDPR Article 5**: Data minimization violated
- ⚠️ **GDPR Article 25**: No privacy by design
- ⚠️ **CCPA**: Potential violation of consumer privacy

---

## URL Signing Security

**Analysis**: Uses UrlSignatureService with HMAC-SHA256

**How it works**:
1. Builds URL with user parameters
2. Signs with HMAC-SHA256 and timestamp
3. External form validates signature

**Security**:
- ✅ Uses secure HMAC algorithm
- ✅ Includes timestamp (prevents replay)
- ❌ Doesn't prevent PII exposure (signature validates authenticity, not privacy)

**Verdict**: 🟡 Signature is secure, but doesn't address PII exposure

---

## Summary

**Total Issues Found**: 14

### Breakdown by Severity:
- **CRITICAL**: 4 (PII in URLs, nil crash, duplicate method, no error handling)
- **HIGH**: 4 (Deprecated filter, regex in controller, no validation, URL encoding)
- **MEDIUM**: 3 (Logic bug, unused variable, no tests)
- **LOW**: 2 (No logging, caching pattern)
- **Code Quality**: 1 (Massive duplication)

### Required Fixes:
1. ✅ **CRITICAL**: Move PII to POST body or session (not URL parameters)
2. ✅ **CRITICAL**: Add nil check before born_at.strftime
3. ✅ **CRITICAL**: Remove duplicate method definition
4. ✅ **CRITICAL**: Add error handling for Page.find
5. ✅ **HIGH**: Replace before_filter with before_action
6. ✅ **HIGH**: Use Page model method instead of regex
7. ✅ **HIGH**: Validate params[:id]
8. ✅ **MEDIUM**: Fix meta_image logic bug
9. ✅ **MEDIUM**: Remove or use unused election variable
10. ✅ **MEDIUM**: Add comprehensive test suite
11. ✅ **LOW**: Add structured logging

### Optional Enhancements:
- Refactor duplicate actions into single dynamic action
- Move to POST requests for forms with sensitive data
- Add rate limiting
- Add form access audit trail
- Use dedicated session storage for user data

---

## Recommended Implementation

**Phase 1** (Critical Security Fixes):
- Fix PII exposure
- Add nil checks
- Remove duplicate
- Add error handling

**Phase 2** (Code Quality):
- Replace deprecated filter
- Use model methods
- Add validation
- Fix logic bugs

**Phase 3** (Testing & Logging):
- Create test suite
- Add logging
- Add monitoring

---

## Notes on Testing

**Challenges**:
- 30+ actions to test
- Complex user data flow
- URL signing verification
- Form iframe rendering
- Authentication exceptions

**Strategy**:
- Test show_form with all scenarios
- Test add_user_params with various user states
- Test nil handling
- Test URL signing integration
- Test authentication flow
- Sample test for other form actions (they're similar)
