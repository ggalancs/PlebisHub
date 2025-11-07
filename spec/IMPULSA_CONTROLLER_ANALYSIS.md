# ImpulsaController - Comprehensive Security & Quality Analysis

**Controller**: `app/controllers/impulsa_controller.rb`
**Lines**: 160
**Actions**: 11 (index, project, evaluation, project_step, update, review, delete, update_step, upload, delete_file, download)
**Complexity**: VERY HIGH (Multi-step Wizard + File Management + State Machine)
**Priority**: #13
**Security Criticality**: MAXIMUM (File uploads/downloads + Dynamic code execution)

## Overview

ImpulsaController manages a complex multi-step wizard for project submissions in the "Impulsa" program. It handles file uploads/downloads, state transitions, and complex validation logic across multiple wizard steps. **CRITICAL SECURITY SYSTEM** - handles user-uploaded files and dynamic code generation.

---

## CRITICAL Issues

### 1. **Path Traversal Vulnerability in download Action** ⚠️ CRITICAL
**Location**: Controller line 121-124
**Severity**: CRITICAL - FILE SYSTEM ACCESS

```ruby
def download
  gname, fname, extension = params[:field].split(".")
  send_file @project.wizard_path(gname, fname)
end
```

**Problems**:
- `params[:field]` is user-controlled input split and used directly in file path
- `wizard_path` concatenates: `files_folder + wizard_values["#{gname}.#{fname}"]`
- Attacker could provide `params[:field] = "../../etc/passwd"` to access system files
- No validation that requested file belongs to user's project
- No sanitization of field parameter
- Could expose sensitive files outside project directory

**Impact**:
- Read arbitrary files on server
- Access other users' uploaded files
- Read configuration files with secrets
- Information disclosure of entire file system
- Compliance violations (unauthorized data access)

**Fix Required**:
- Validate `params[:field]` against allowed wizard fields
- Use `File.basename()` to strip path components
- Verify file exists within project's authorized directory
- Log all download attempts with user_id and requested path

---

### 2. **Arbitrary Code Execution via instance_eval** ⚠️ CRITICAL
**Location**: Wizard concern lines 222-240
**Severity**: CRITICAL - REMOTE CODE EXECUTION

```ruby
def wizard_method_missing(method_sym, *arguments, &block)
  if method_sym.to_s =~ /^_wiz_(.+)__([^=]+)=?$/
    self.instance_eval <<-RUBY
      def _wiz_#{$1}__#{$2}
        wizard_values["#{$1}.#{$2}"]
      end
      def _wiz_#{$1}__#{$2}= value
        assign_wizard_value(:"#{$1}", :"#{$2}", value)
      end
    RUBY
    return send(method_sym, *arguments)
  end
end
```

**Problems**:
- `instance_eval` with string interpolation creates methods dynamically
- If `$1` or `$2` contain malicious code, it will be executed
- Method names come from `method_sym` which could be attacker-controlled
- No sanitization of captured regex groups
- Ruby code injection possible

**Impact**:
- Remote code execution on server
- Complete system compromise
- Database destruction
- Arbitrary file operations
- Privilege escalation

**Fix Required**: Use `define_method` instead of `instance_eval` with string

---

### 3. **No Authorization for File Download** ⚠️ CRITICAL
**Location**: Controller line 121-124, 156-158
**Severity**: CRITICAL - AUTHORIZATION BYPASS

```ruby
def download
  gname, fname, extension = params[:field].split(".")
  send_file @project.wizard_path(gname, fname)
end

def check_project
  redirect_to impulsa_path if @project.nil?
end
```

**Problems**:
- No verification that current_user owns the project
- `check_project` only checks if `@project` is nil, not ownership
- `@project` is set by `@edition.impulsa_projects.where(user:current_user).first`
- But if URL is manipulated, attacker could access other projects' files
- No logging of who downloads what files

**Impact**:
- Unauthorized access to other users' uploaded documents
- Privacy violations (government IDs, personal documents)
- Intellectual property theft (project proposals)
- Compliance violations (GDPR)

**Fix Required**:
- Add explicit ownership check: `@project.user_id == current_user.id`
- Log all file access attempts
- Verify file belongs to current user's project

---

### 4. **No File Type Validation in upload Action** ⚠️ CRITICAL
**Location**: Controller lines 76-101
**Severity**: CRITICAL - MALWARE UPLOAD

```ruby
def upload
  gname, fname = params[:field].split(".")
  result = @project.assign_wizard_value(gname, fname, params[:file])
  # ...
end
```

**Problems**:
- Relies solely on `assign_wizard_value` validation
- Extension validation can be bypassed (e.g., `malware.jpg.exe`)
- No content-type verification
- No malware scanning
- Files stored with original extensions
- No filename sanitization beyond extension check
- Could upload executable files

**Impact**:
- Malware upload to server
- Script injection (SVG with JavaScript)
- Server-side code execution if web server misconfigured
- Denial of service (large files)
- Storage exhaustion

**Fix Required**:
- Validate MIME type matches extension
- Use virus scanning (ClamAV integration)
- Generate random filenames (UUID)
- Store files outside web root
- Implement file size quotas per user

---

### 5. **No Error Handling Throughout Controller** ⚠️ CRITICAL
**Location**: All actions
**Severity**: CRITICAL - RELIABILITY & INFORMATION DISCLOSURE

**Missing rescues for**:
- `@project.save` (lines 23, 63, 93, 116) - could raise database errors
- `send_file` (line 123) - could raise if file doesn't exist
- `File operations` in wizard concern - could fail
- `@project.wizard_path` (line 123) - could return nil/invalid path
- `params[:field].split` (lines 77, 104, 122) - could raise on nil

**Impact**:
- Application crashes expose stack traces with sensitive info
- Users see internal file paths and implementation details
- No graceful degradation
- Lost work if wizard fails
- Security information disclosure

**Fix Required**: Add comprehensive rescue blocks with logging

---

### 6. **SQL Injection Risk in project_params** ⚠️ CRITICAL
**Location**: Controller lines 146-154, Wizard concern line 152
**Severity**: CRITICAL - SQL INJECTION

```ruby
def wizard_step_params
  _all = wizard[wizard_step][:groups].map do |gname,group|
    group[:fields].map do |fname, field|
      ["_wiz_#{gname}__#{fname}", field[:type]=="check_boxes"]
    end
  end
end
```

**Problems**:
- `wizard_step` comes from `params[:step]` (line 131)
- Used as hash key without validation
- Could inject SQL if wizard definition comes from database
- wizard configuration eval'd with `SafeConditionEvaluator` but still risky

**Impact**:
- Potential SQL injection via wizard_step parameter
- NoMethodError if wizard_step is invalid (DoS)
- Could manipulate allowed parameters

**Fix Required**: Whitelist valid wizard steps

---

### 7. **No Security Logging** ⚠️ CRITICAL
**Location**: Throughout controller
**Severity**: CRITICAL - NO AUDIT TRAIL

**Missing Logs**:
- File uploads (who, what, when, size)
- File downloads (who accessed which files)
- File deletions
- Project state transitions
- Failed authorization attempts
- Suspicious parameter values
- Path traversal attempts

**Impact**:
- No forensic capability
- Cannot detect attacks
- Cannot investigate breaches
- Compliance violations (no audit trail for file access)
- Cannot track malicious activity

**Fix Required**: Add comprehensive structured JSON logging

---

### 8. **No CSRF Protection Verification for AJAX Actions** ⚠️ CRITICAL
**Location**: upload (76-101), delete_file (103-119), download (121-124)
**Severity**: CRITICAL - CSRF VULNERABILITY

**Problems**:
- JSON responses suggest AJAX usage
- No explicit CSRF token verification
- Attacker could craft AJAX requests from malicious site
- Could upload files on behalf of user
- Could delete user's files
- Could trigger downloads

**Impact**:
- Cross-site request forgery enabling:
  - Unauthorized file uploads
  - File deletion attacks
  - Storage exhaustion attacks
  - Malware injection

**Fix Required**: Verify Rails CSRF token on all state-changing actions

---

## HIGH Priority Issues

### 9. **Hardcoded Spanish Strings (No I18n)** ⚠️ HIGH
**Location**: Lines 32, 34, 42, 45, 50, 52, 80-86, 109
**Severity**: HIGH - INTERNATIONALIZATION

```ruby
flash[:notice] = "El proyecto ha sido marcado para ser revisado."
errors = ["El tipo de fichero subido no es correcto."]
```

**Problems**:
- All user-facing messages hardcoded in Spanish
- Not using `I18n.t()` for translations
- No internationalization support
- Inconsistent with rest of application

**Fix Required**: Extract all strings to I18n locale files

---

### 10. **Business Logic in Controller** ⚠️ HIGH
**Location**: Throughout (delete logic lines 39-56, update_step logic lines 61-73)
**Severity**: HIGH - CODE ORGANIZATION

**Problems**:
- Complex conditional logic in controller actions
- State transitions in controller (should be in model/state machine)
- File path construction in controller
- Validation logic mixed with controller logic

**Fix Required**: Extract to model methods and service objects

---

### 11. **Unsafe File Path Construction** ⚠️ HIGH
**Location**: upload action line 77, delete_file line 104, download line 122
**Severity**: HIGH - PATH TRAVERSAL

```ruby
gname, fname = params[:field].split(".")
```

**Problems**:
- Splitting on "." is brittle
- No validation of resulting values
- Could return nil if no "." present
- Could have unexpected number of elements
- `extension` captured but not validated in download

**Fix Required**: Validate split results, use safer parsing

---

### 12. **No File Size Limits Enforced in Controller** ⚠️ HIGH
**Location**: upload action lines 76-101
**Severity**: HIGH - DENIAL OF SERVICE

**Problems**:
- Model has `MAX_FILE_SIZE = 10MB` but enforced after reading file
- No streaming upload handling
- Could exhaust server memory
- No per-user storage quota

**Fix Required**: Enforce limits at web server/middleware level

---

### 13. **Complex Conditional Logic in delete Action** ⚠️ HIGH
**Location**: Lines 39-56
**Severity**: HIGH - CODE COMPLEXITY

```ruby
def delete
  if @project.deleteable?
    if @project.destroy
      # ...
    else
      # ...
    end
  else
    if @project.mark_as_resigned
      # ...
    else
      # ...
    end
  end
end
```

**Problems**:
- Nested conditionals hard to test
- Multiple responsibilities (delete vs resign)
- Error messages don't explain why action failed
- Should be extracted to service object

**Fix Required**: Extract to service object with clear interface

---

## MEDIUM Priority Issues

### 14. **Missing frozen_string_literal** ⚠️ MEDIUM
**Location**: Line 1
**Severity**: MEDIUM - PERFORMANCE

**Fix Required**: Add `# frozen_string_literal: true`

---

### 15. **Inconsistent Error Handling** ⚠️ MEDIUM
**Location**: upload (lines 79-88), delete_file (lines 106-111)
**Severity**: MEDIUM - USER EXPERIENCE

**Problems**:
- Error messages returned as array with single element
- Inconsistent JSON response structure
- No error codes for client-side handling
- Generic error messages don't help user fix issue

**Fix Required**: Standardize JSON error responses

---

### 16. **No Input Validation for step Parameter** ⚠️ MEDIUM
**Location**: set_variables line 131
**Severity**: MEDIUM - SECURITY

```ruby
@step = params[:step]
@project.wizard_step = @step if @step
```

**Problems**:
- No whitelist of valid steps
- Could set invalid wizard_step
- Could cause errors in wizard navigation
- NoMethodError if accessing wizard[invalid_step]

**Fix Required**: Validate against `wizard.keys`

---

### 17. **Ambiguous Action Names** ⚠️ MEDIUM
**Location**: project, evaluation actions (lines 10-14)
**Severity**: MEDIUM - CODE CLARITY

```ruby
def project
end

def evaluation
end
```

**Problems**:
- Empty actions suggest views only
- Names too generic (project could mean many things)
- No comments explaining purpose
- Unclear responsibilities

**Fix Required**: Add comments or rename for clarity

---

### 18. **No Test Coverage** ⚠️ MEDIUM
**Location**: N/A
**Severity**: MEDIUM - QUALITY ASSURANCE

**Problems**:
- No test file exists for this critical controller
- Complex wizard logic untested
- File upload/download paths untested
- State transitions untested
- Security vulnerabilities undetected

**Fix Required**: Comprehensive test suite (80-100 tests estimated)

---

## LOW Priority Issues

### 19. **Inconsistent Guard Clause Usage** ⚠️ LOW
**Location**: Lines 22, 59
**Severity**: LOW - CODE STYLE

```ruby
redirect_to project_impulsa_path and return unless @project.editable?
redirect_to project_impulsa_path and return unless @project.saveable?
```

**Fix Required**: Extract to before_actions for consistency

---

### 20. **Magic Symbols in Code** ⚠️ LOW
**Location**: Lines 81-86, 108
**Severity**: LOW - MAINTAINABILITY

```ruby
when :wrong_extension
when :wrong_size
when :wrong_field
```

**Fix Required**: Define constants for return values

---

## Security Checklist Results

### ❌ Authentication
**Status**: PARTIAL
- Authentication required for most actions
- BUT: index action allows anonymous access
- No verification of user identity in file operations

### ❌ Authorization
**Status**: MISSING
- No ownership verification for file downloads
- No check if user can modify project
- Relies on `@project` being nil but insufficient

### ❌ Input Validation
**Status**: MISSING
- No validation of params[:field]
- No validation of params[:step]
- No validation of file content
- Path traversal possible

### ❌ Error Handling
**Status**: MISSING
- No rescue blocks in controller
- File operations could crash
- No graceful error messages

### ❌ Logging
**Status**: MISSING
- No logging for file uploads
- No logging for file downloads
- No logging for state transitions
- No audit trail

### ❌ File Upload Security
**Status**: VULNERABLE
- Extension validation can be bypassed
- No malware scanning
- No content-type verification
- Original filenames used
- No streaming uploads

### ❌ Path Traversal Protection
**Status**: VULNERABLE
- params[:field] used directly in paths
- No File.basename() sanitization
- send_file with user-controlled path
- Could access arbitrary files

### ❌ Code Injection Protection
**Status**: VULNERABLE
- instance_eval with string interpolation
- Dynamic method generation from user input
- Could execute arbitrary Ruby code

### ⚠️ CSRF Protection
**Status**: QUESTIONABLE
- Rails default CSRF protection present
- BUT: AJAX actions need explicit verification
- Download action should be GET with signed token

---

## Issue Summary

| Severity | Count | Issues |
|----------|-------|--------|
| CRITICAL | 8 | Path traversal, Code execution (instance_eval), No authorization, No file validation, No error handling, SQL injection, No logging, No CSRF verification |
| HIGH | 5 | Hardcoded strings, Business logic in controller, Unsafe path construction, No file size limits, Complex conditionals |
| MEDIUM | 5 | frozen_string_literal, Inconsistent errors, No step validation, Ambiguous actions, No tests |
| LOW | 2 | Inconsistent guards, Magic symbols |
| **TOTAL** | **20** | |

---

## Recommended Fix Priority

**CRITICAL (Must Fix Immediately)**:
1. Issue #1 - Path traversal in download (validate field param, use File.basename)
2. Issue #2 - Code execution via instance_eval (use define_method)
3. Issue #3 - No authorization for downloads (verify ownership)
4. Issue #4 - No file type validation (MIME type, malware scan)
5. Issue #5 - Add comprehensive error handling
6. Issue #6 - Validate wizard_step parameter
7. Issue #7 - Add security logging
8. Issue #8 - Verify CSRF protection for AJAX

**HIGH (Should Fix Soon)**:
9. Issue #9 - Extract strings to I18n
10. Issue #10 - Extract business logic to models/services
11. Issue #11 - Safe path parsing
12. Issue #12 - Enforce file size limits
13. Issue #13 - Refactor delete action

**MEDIUM (Should Fix)**:
14-18. Issues #14-#18

**LOW (Nice to Have)**:
19-20. Issues #19-#20

---

## Testing Requirements

### Must Cover (80-100 tests):

**Authentication & Authorization (15 tests)**:
1. Index accessible without login
2. Other actions require authentication
3. File download requires ownership
4. Cannot download other users' files
5. Cannot modify other users' projects

**Path Traversal Security (10 tests)**:
1. Download with path traversal attempt rejected
2. Download with absolute path rejected
3. Download with ../ sequences rejected
4. Download only allows project's own files
5. Logs path traversal attempts

**File Upload Security (15 tests)**:
1. Validates file extension
2. Validates MIME type matches extension
3. Rejects executable files
4. Enforces file size limits
5. Generates safe filenames
6. Logs all uploads
7. Handles upload errors

**File Download (10 tests)**:
1. Downloads authorized file successfully
2. Rejects unauthorized file access
3. Handles missing files gracefully
4. Logs all downloads
5. Validates field parameter format

**Wizard Navigation (12 tests)**:
1. project_step displays correct step
2. update_step advances to next step
3. Invalid step parameter rejected
4. Wizard step validation works
5. Cannot skip required steps

**State Transitions (15 tests)**:
1. review marks project for review
2. delete deletes if deleteable
3. delete marks as resigned if not deleteable
4. State transitions logged
5. Invalid transitions prevented

**Error Handling (10 tests)**:
1. Missing project handled gracefully
2. File not found handled
3. Database errors caught
4. User-friendly error messages
5. Errors logged

**Integration Tests (13 tests)**:
1. Complete wizard flow
2. Upload and download cycle
3. Project creation to submission
4. Multi-step validation
5. File management across steps

---

## Files to Create/Modify

1. ✏️ **app/controllers/impulsa_controller.rb** - Fix all issues
2. ✏️ **app/models/concerns/impulsa_project_wizard.rb** - Fix instance_eval, add validation
3. ✏️ **app/models/impulsa_project.rb** - Add authorization methods
4. ✨ **app/services/impulsa_file_service.rb** - Extract file handling
5. ✨ **spec/controllers/impulsa_controller_spec.rb** - Comprehensive tests
6. ✨ **spec/services/impulsa_file_service_spec.rb** - Service tests
7. ✨ **config/locales/impulsa.es.yml** - Spanish translations
8. ✨ **config/locales/impulsa.en.yml** - English translations
9. ✨ **spec/IMPULSA_CONTROLLER_ANALYSIS.md** - This document
10. ✨ **spec/IMPULSA_CONTROLLER_COMPLETE_RESOLUTION.md** - Resolution doc

---

## Special Security Considerations

### File Upload/Download Security:
- User-uploaded files are extremely dangerous
- Must validate content-type matches extension
- Must scan for malware
- Must prevent path traversal
- Must log all file access
- Must verify ownership
- Must use secure file names (UUIDs)

### Code Injection via instance_eval:
- **MOST CRITICAL ISSUE** - arbitrary code execution possible
- String interpolation in instance_eval is extremely dangerous
- Must replace with define_method
- Could destroy database, compromise secrets, pivot to other systems

### State Machine Security:
- State transitions must be validated
- Cannot skip validation steps
- Logs must track all state changes
- Resignation vs deletion must be clear

### Wizard Configuration:
- wizard configuration must be immutable
- No eval() or instance_eval on wizard definitions
- SafeConditionEvaluator must be truly safe
- Validate all wizard steps exist

---

## Notes

- This controller is **MAXIMUM SECURITY CRITICALITY**
- **Path traversal vulnerability** could expose entire filesystem
- **instance_eval vulnerability** enables remote code execution
- File handling is most dangerous part of application
- Complex wizard logic requires extensive testing
- Consider replacing wizard with simpler form_for/step approach
- Consider moving file storage to S3/external service
- Implement file virus scanning before storage
- Add rate limiting for file uploads

---
