# AudioCaptchaController Analysis

## Controller Purpose
Generates accessible audio CAPTCHA in Spanish using text-to-speech (ESpeak) for visually impaired users.

## Public Actions

### `index`
- Creates temporary audio directory if needed
- Generates MP3 file with spoken CAPTCHA value
- Sends file to user with `audio/mp3` MIME type

## Private Methods

### `speech`
- Creates ESpeak::Speech object with randomized parameters:
  - Voice: Spanish with random gender (f/m) and variant (1-4)
  - Speed: Random 90-129
  - Pitch: Random 0-29
  - Capital: Random 3-32

### `captcha_value_spelling`
- Converts CAPTCHA characters to Spanish phonetic spelling
- Uses I18n translations: `simple_captcha.letters.{LETTER}`
- Returns nil if captcha_value is nil (guard clause)

### `captcha_value`
- Retrieves CAPTCHA value using SimpleCaptcha::Utils
- Returns nil if captcha_key is invalid

### `captcha_key`
- Extracts `captcha_key` from params
- Could be nil if not provided

### `file_path`
- Generates: `{Rails.root}/tmp/audios/{captcha_key}.mp3`
- Vulnerable to path traversal if captcha_key contains "../"

### `file_dir`
- Returns: `{Rails.root}/tmp/audios`

## Identified Issues

### Problem 1: Missing Nil Check Before Speech Generation
**Severity**: HIGH
**Issue**: If `captcha_value` is nil (invalid key), `captcha_value_spelling` returns nil, but `speech` method is still called, which will fail when trying to pass nil to ESpeak::Speech.new

**Location**: Line 10-12
```ruby
speech.save file_path  # Will fail if captcha_value_spelling is nil
```

**Recommended Fix**: Add validation before generating speech
```ruby
def index
  return head :not_found unless captcha_value

  FileUtils.mkdir_p file_dir
  speech.save file_path
  send_file file_path, type: 'audio/mp3', disposition: :inline
end
```

### Problem 2: Path Traversal Vulnerability
**Severity**: HIGH (Security)
**Issue**: `captcha_key` from params is used directly in file path without sanitization

**Location**: Line 41
```ruby
@file_path ||= "#{file_dir}/#{captcha_key}.mp3"
```

**Attack Vector**: `captcha_key=../../etc/passwd` could access sensitive files
**Recommended Fix**: Sanitize captcha_key or use a whitelist

### Problem 3: Missing I18n Translations
**Severity**: MEDIUM
**Issue**: References `I18n.t("simple_captcha.letters.#{letter}")` but translations may not exist

**Location**: Line 29
**Impact**: Will show translation missing errors if keys don't exist

### Problem 4: File Cleanup
**Severity**: LOW
**Issue**: Generated MP3 files are never cleaned up from tmp/audios/
**Impact**: Disk space accumulation over time

## Test Coverage Plan

### Success Cases
1. Valid captcha_key returns audio file
2. Directory is created if it doesn't exist
3. File is sent with correct MIME type
4. File is sent with inline disposition

### Edge Cases
5. Missing captcha_key parameter
6. Invalid captcha_key (no matching value)
7. Nil captcha_value handling
8. Empty captcha_key
9. Special characters in captcha_key

### Security Tests
10. Path traversal attempt (../)
11. Absolute path injection

### Integration Tests
12. Speech parameters randomization
13. Captcha value spelling conversion
14. File generation and storage

## Dependencies
- `simple_captcha` gem
- `espeak` gem
- `espeak` system binary
- I18n translations for letters
