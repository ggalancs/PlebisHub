# PlebisHub Application Issues Report

**Generated:** 2025-11-30 19:19:15

**Total Issues Found:** 51

---

## CRITICAL Issues

### 500 Error on Admin Dashboard

- **Page:** Admin Dashboard
- **URL:** http://localhost:3000/admin
- **Type:** Server Error
- **Description:** Internal server error on admin dashboard

### Health endpoint failing

- **Page:** API
- **URL:** http://localhost:3000/health
- **Type:** Server Error
- **Description:** Health endpoint returns 429

### 500 Error on Registration Page

- **Page:** Registration Page
- **URL:** http://localhost:3000/es/users/sign_up
- **Type:** Server Error
- **Description:** Internal server error on registration page

### Health endpoint not responding

- **Page:** Health Check
- **URL:** http://localhost:3000/health
- **Type:** Server Error
- **Description:** Health endpoint returned status 429

### 500 Error on root URL

- **Page:** Root URL
- **URL:** http://localhost:3000
- **Type:** Server Error
- **Description:** Internal server error on root URL

## HIGH Priority Issues

### 500 Error on Admin Collaborations

- **Page:** Admin Collaborations
- **URL:** http://localhost:3000/admin/collaborations
- **Type:** Server Error
- **Description:** Internal server error on admin collaborations page

### 500 Error on Admin Proposals

- **Page:** Admin Proposals
- **URL:** http://localhost:3000/admin/proposals
- **Type:** Server Error
- **Description:** Internal server error on admin proposals page

### 500 Error on Admin Participation Teams

- **Page:** Admin Participation Teams
- **URL:** http://localhost:3000/admin/participation_teams
- **Type:** Server Error
- **Description:** Internal server error on admin participation teams page

### 500 Error on Admin Categories

- **Page:** Admin Categories
- **URL:** http://localhost:3000/admin/categories
- **Type:** Server Error
- **Description:** Internal server error on admin categories page

### 500 Error on Admin Notices

- **Page:** Admin Notices
- **URL:** http://localhost:3000/admin/notices
- **Type:** Server Error
- **Description:** Internal server error on admin notices page

### Missing CSRF token

- **Page:** Security
- **URL:** http://localhost:3000/es/users/sign_in
- **Type:** Security Issue
- **Description:** Form is missing CSRF protection token

### Redirected to login from profile

- **Page:** User Profile
- **URL:** http://localhost:3000/es/users/edit
- **Type:** Authentication Error
- **Description:** User was redirected to login page instead of profile

### 500 Error on Tools Page

- **Page:** Tools Page
- **URL:** http://localhost:3000/es/herramientas
- **Type:** Server Error
- **Description:** Internal server error on tools page

### 500 Error on Participation Page

- **Page:** Participation Page
- **URL:** http://localhost:3000/es/participa
- **Type:** Server Error
- **Description:** Internal server error on participation page

### 500 Error on Votes Page

- **Page:** Votes Page
- **URL:** http://localhost:3000/es/votos
- **Type:** Server Error
- **Description:** Internal server error on votes page

### 500 Error on Militant Page

- **Page:** Militant Page
- **URL:** http://localhost:3000/es/militante
- **Type:** Server Error
- **Description:** Internal server error on militant page

### 500 Error on Verification Page

- **Page:** Verification Page
- **URL:** http://localhost:3000/es/verificacion
- **Type:** Server Error
- **Description:** Internal server error on verification page

### Login form email field missing

- **Page:** Login Page
- **URL:** http://localhost:3000/es
- **Type:** Missing Element
- **Description:** Email input field not found on login page

### Login form elements not found

- **Page:** Login Page
- **URL:** http://localhost:3000/es/users/sign_in
- **Type:** Missing Element
- **Description:** Could not find login form elements within timeout

### Email field missing on password recovery

- **Page:** Password Recovery Page
- **URL:** http://localhost:3000/es/users/password/new
- **Type:** Missing Element
- **Description:** Email input field not found

### 500 on empty parameter

- **Page:** Edge Cases
- **URL:** http://localhost:3000/es/votos//
- **Type:** Server Error
- **Description:** Server error when accessing URL with empty parameter

### 500 on empty parameter

- **Page:** Edge Cases
- **URL:** http://localhost:3000/es/propuestas/
- **Type:** Server Error
- **Description:** Server error when accessing URL with empty parameter

## MEDIUM Priority Issues

### Missing lang attribute

- **Page:** Accessibility
- **URL:** http://localhost:3000/ca
- **Type:** Accessibility Issue
- **Description:** HTML element missing lang attribute

### Missing lang attribute

- **Page:** Accessibility
- **URL:** http://localhost:3000/eu
- **Type:** Accessibility Issue
- **Description:** HTML element missing lang attribute

### Admin access control test failed

- **Page:** Admin Access Control
- **URL:** http://localhost:3000/admin
- **Type:** Test Error
- **Description:** Message: 
Stacktrace:
0   chromedriver                        0x0000000103232ecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x000000010322ab88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x0000000102d422b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x0000000102d8988c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x0000000102dcad54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x0000000102d7def0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x00000001031f60c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x00000001031f98dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x00000001031d684c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x00000001031fa1b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x00000001031c80f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x0000000103219498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x000000010321961c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x000000010322a7d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### Invalid login test failed

- **Page:** Login Page
- **URL:** http://localhost:3000/es/users/sign_in
- **Type:** Test Error
- **Description:** Message: 
Stacktrace:
0   chromedriver                        0x0000000102582ecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x000000010257ab88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x00000001020922b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x00000001020d988c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x000000010211ad54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x00000001020cdef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x00000001025460c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x00000001025498dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x000000010252684c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x000000010254a1b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x00000001025180f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x0000000102569498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x000000010256961c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x000000010257a7d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### Logout test failed

- **Page:** Dashboard
- **URL:** http://localhost:3000/es/users/sign_in
- **Type:** Test Error
- **Description:** Message: 
Stacktrace:
0   chromedriver                        0x0000000102c02ecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x0000000102bfab88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x00000001027122b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x000000010275988c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x000000010279ad54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x000000010274def0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x0000000102bc60c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x0000000102bc98dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x0000000102ba684c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x0000000102bca1b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x0000000102b980f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x0000000102be9498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x0000000102be961c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x0000000102bfa7d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### 500 on direct action URL

- **Page:** Edge Cases
- **URL:** http://localhost:3000/users/unlock
- **Type:** Server Error
- **Description:** Server error when accessing action URL directly

### 500 on double-encoded URL

- **Page:** Edge Cases
- **URL:** http://localhost:3000/es/%252e%252e%252f
- **Type:** Server Error
- **Description:** Server error on double URL encoding

### 500 on double-encoded URL

- **Page:** Edge Cases
- **URL:** http://localhost:3000/es/%2525252e%2525252e%2525252f
- **Type:** Server Error
- **Description:** Server error on double URL encoding

### 500 on null byte in URL

- **Page:** Edge Cases
- **URL:** http://localhost:3000/es/test%00.html
- **Type:** Server Error
- **Description:** Server error with null byte in URL

### No amount selection on single collaboration

- **Page:** Single Collaboration Form
- **URL:** http://localhost:3000/es/colabora/puntual
- **Type:** Missing Element
- **Description:** Could not find amount selection options

### Microcredit page missing content

- **Page:** Microcredit Form
- **URL:** http://localhost:3000/es/microcreditos
- **Type:** Content Issue
- **Description:** Neither form nor 'no campaigns' message found

### Profile update form test failed

- **Page:** Profile Update Form
- **URL:** http://localhost:3000/es/users/edit
- **Type:** Test Error
- **Description:** Message: 
Stacktrace:
0   chromedriver                        0x0000000104d2aecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x0000000104d22b88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x000000010483a2b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x000000010488188c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x00000001048c2d54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x0000000104875ef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x0000000104cee0c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x0000000104cf18dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x0000000104cce84c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x0000000104cf21b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x0000000104cc00f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x0000000104d11498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x0000000104d1161c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x0000000104d227d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### Moderate page load time: Home

- **Page:** Performance
- **URL:** http://localhost:3000/es
- **Type:** Performance Issue
- **Description:** Home page took 5.03 seconds to load

### JavaScript console errors

- **Page:** Performance
- **URL:** http://localhost:3000/es
- **Type:** JavaScript Error
- **Description:** Console errors: http://localhost:3000/es 8 Loading the stylesheet 'https://fonts.googleapis.com/css?family=Montserrat:400,700' violates the following Content Security Policy directive: "style-src 'self' 'unsafe-inline'". Note that 'style-src-elem' was not explicitly set, so 'style-src' is used as a fallback. The action has been blocked.; http://localhost:3000/es 20 Executing inline script violates the following Content Security Policy directive 'script-src 'self' 'unsafe-eval''. Either the 'unsafe-inline' keyword, a hash ('sha256-fpUL/IXEAg1CE4Huyb/0NGHNjl9rrM3VniAacs5plJA='), or a nonce ('nonce-...') is required to enable inline execution. The action has been blocked.; http://localhost:3000/es 218 Executing inline script violates the following Content Security Policy directive 'script-src 'self' 'unsafe-eval''. Either the 'unsafe-inline' keyword, a hash ('sha256-V/wOQnokx12gn+N0zjfyYMbzPZKZN3cAt5+OrEVZfzg='), or a nonce ('nonce-...') is required to enable inline execution. The action has been blocked.; http://localhost:3000/es 236 Executing inline script violates the following Content Security Policy directive 'script-src 'self' 'unsafe-eval''. Either the 'unsafe-inline' keyword, a hash ('sha256-6GOYrydaQe00k/x4PBHFwxowvNeiJdaeRAXTbuxuvw8='), or a nonce ('nonce-...') is required to enable inline execution. The action has been blocked.; http://localhost:3000/assets/application-bd879ba0aa8d232ec49b8e9660487c84e628628d63209810a8cf3ab28100cc57.js - Failed to load resource: the server responded with a status of 429 (Too Many Requests)

### 500 Error on Audio Captcha

- **Page:** Audio Captcha
- **URL:** http://localhost:3000/es/audio_captcha
- **Type:** Server Error
- **Description:** Internal server error on audio captcha endpoint

## LOW Priority Issues

### No skip navigation link

- **Page:** Accessibility
- **URL:** http://localhost:3000/es
- **Type:** Accessibility Issue
- **Description:** Page lacks skip navigation link for keyboard users

### No main landmark

- **Page:** Accessibility
- **URL:** http://localhost:3000/es
- **Type:** Accessibility Issue
- **Description:** Page lacks main landmark for screen readers

### No navigation landmark

- **Page:** Accessibility
- **URL:** http://localhost:3000/es
- **Type:** Accessibility Issue
- **Description:** Page lacks navigation landmark

### Unexpected content type: /es

- **Page:** API
- **URL:** http://localhost:3000/es
- **Type:** Response Error
- **Description:** Expected text/html, got application/json

### Unicode form test failed

- **Page:** Edge Cases
- **URL:** http://localhost:3000/es/users/sign_in
- **Type:** Test Error
- **Description:** Message: no such element: Unable to locate element: {"method":"css selector","selector":"[id="user_email"]"}
  (Session info: chrome=142.0.7444.176); For documentation on this error, please visit: https://www.selenium.dev/documentation/webdriver/troubleshooting/errors#no-such-element-exception
Stacktrace:
0   chromedriver                        0x000000010543eecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x0000000105436b88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x0000000104f4e2b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x0000000104f9588c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x0000000104fd6d54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x0000000104f89ef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x00000001054020c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x00000001054058dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x00000001053e284c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x00000001054061b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x00000001053d40f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x0000000105425498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x000000010542561c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x00000001054367d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### Session timeout test failed

- **Page:** Edge Cases
- **URL:** http://localhost:3000
- **Type:** Test Error
- **Description:** Message: 
Stacktrace:
0   chromedriver                        0x00000001026b2ecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x00000001026aab88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x00000001021c22b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x000000010220988c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x000000010224ad54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x00000001021fdef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x00000001026760c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x00000001026798dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x000000010265684c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x000000010267a1b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x00000001026480f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x0000000102699498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x000000010269961c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x00000001026aa7d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### External link opens in same tab

- **Page:** External Links
- **URL:** http://localhost:3000/es
- **Type:** UX Issue
- **Description:** External link http://plebisbrand.info/organizacion/ opens in same tab

### External link opens in same tab

- **Page:** External Links
- **URL:** http://localhost:3000/es
- **Type:** UX Issue
- **Description:** External link http://plebisbrand.info/programa/ opens in same tab

### External link opens in same tab

- **Page:** External Links
- **URL:** http://localhost:3000/es
- **Type:** UX Issue
- **Description:** External link https://transparencia.plebisbrand.info/ opens in same tab

### External link opens in same tab

- **Page:** External Links
- **URL:** http://localhost:3000/es
- **Type:** UX Issue
- **Description:** External link http://tienda.plebisbrand.info/ opens in same tab

### External link opens in same tab

- **Page:** External Links
- **URL:** http://localhost:3000/es
- **Type:** UX Issue
- **Description:** External link https://www.youtube.com/user/CirculosPlebisBrand/ opens in same tab

### External link opens in same tab

- **Page:** External Links
- **URL:** http://localhost:3000/es
- **Type:** UX Issue
- **Description:** External link https://www.facebook.com/pages/PlebisBrand/269212336568846 opens in same tab

### External link opens in same tab

- **Page:** External Links
- **URL:** http://localhost:3000/es
- **Type:** UX Issue
- **Description:** External link https://twitter.com/PLEBISBRAND opens in same tab

### No compression

- **Page:** Performance
- **URL:** http://localhost:3000/es
- **Type:** Performance Issue
- **Description:** Server does not use gzip/deflate compression

