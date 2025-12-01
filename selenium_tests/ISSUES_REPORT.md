# PlebisHub Application Issues Report

**Generated:** 2025-11-30 23:30:21

**Total Issues Found:** 35

---

## HIGH Priority Issues

### 500 Error on Admin Votes

- **Page:** Admin Votes
- **URL:** http://localhost:3000/admin/votes
- **Type:** Server Error
- **Description:** Internal server error on admin votes page

### 500 Error on Admin Census

- **Page:** Admin Census
- **URL:** http://localhost:3000/admin/census
- **Type:** Server Error
- **Description:** Internal server error on admin census page

### 500 Error on Admin Participation Teams

- **Page:** Admin Participation Teams
- **URL:** http://localhost:3000/admin/participation_teams
- **Type:** Server Error
- **Description:** Internal server error on admin participation teams page

### 500 Error on Admin CMS Pages

- **Page:** Admin CMS Pages
- **URL:** http://localhost:3000/admin/pages
- **Type:** Server Error
- **Description:** Internal server error on admin CMS pages

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

### 500 Error on Votes Page

- **Page:** Votes Page
- **URL:** http://localhost:3000/es/votos
- **Type:** Server Error
- **Description:** Internal server error on votes page

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

### Login form password field missing

- **Page:** Login Page
- **URL:** http://localhost:3000/es
- **Type:** Missing Element
- **Description:** Password input field not found on login page

### Login form elements not found

- **Page:** Login Page
- **URL:** http://localhost:3000/es/users/sign_in
- **Type:** Missing Element
- **Description:** Could not find login form elements within timeout

### 500 on empty parameter

- **Page:** Edge Cases
- **URL:** http://localhost:3000/es/votos//
- **Type:** Server Error
- **Description:** Server error when accessing URL with empty parameter

### Registration submission test failed

- **Page:** Registration Form
- **URL:** http://localhost:3000/es/users/sign_up
- **Type:** Test Error
- **Description:** Message: element click intercepted: Element <input type="submit" name="commit" value="Inscribirse" class="button" data-disable-with="Inscribirse"> is not clickable at point (589, 916). Other element would receive the click: <div class="cookie">...</div>
  (Session info: chrome=142.0.7444.176)
Stacktrace:
0   chromedriver                        0x00000001008aaecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x00000001008a2b88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x00000001003ba2b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x00000001004073f0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 389732
4   chromedriver                        0x000000010040595c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 382928
5   chromedriver                        0x000000010040376c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 374240
6   chromedriver                        0x0000000100402b64 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 371160
7   chromedriver                        0x00000001003f7a78 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 325868
8   chromedriver                        0x00000001003f7504 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 324472
9   chromedriver                        0x0000000100442d54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
10  chromedriver                        0x00000001003f5ef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
11  chromedriver                        0x000000010086e0c8 cxxbridge1$str$ptr + 2692164
12  chromedriver                        0x00000001008718dc cxxbridge1$str$ptr + 2706520
13  chromedriver                        0x000000010084e84c cxxbridge1$str$ptr + 2563016
14  chromedriver                        0x00000001008721b4 cxxbridge1$str$ptr + 2708784
15  chromedriver                        0x00000001008400f4 cxxbridge1$str$ptr + 2503792
16  chromedriver                        0x0000000100891498 cxxbridge1$str$ptr + 2836500
17  chromedriver                        0x000000010089161c cxxbridge1$str$ptr + 2836888
18  chromedriver                        0x00000001008a27d8 cxxbridge1$str$ptr + 2906964
19  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
20  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### 500 Error on contact page

- **Page:** Contact Form
- **URL:** http://localhost:3000/es/contacto
- **Type:** Server Error
- **Description:** Internal server error on contact page

## MEDIUM Priority Issues

### Form inputs missing labels

- **Page:** Accessibility
- **URL:** http://localhost:3000/es/users/sign_up
- **Type:** Accessibility Issue
- **Description:** Inputs without labels: user_born_at_3i, user_born_at_2i, user_born_at_1i, user_vote_province, user_vote_town

### Admin access control test failed

- **Page:** Admin Access Control
- **URL:** http://localhost:3000/admin
- **Type:** Test Error
- **Description:** Message: 
Stacktrace:
0   chromedriver                        0x0000000100ceeecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x0000000100ce6b88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x00000001007fe2b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x000000010084588c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x0000000100886d54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x0000000100839ef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x0000000100cb20c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x0000000100cb58dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x0000000100c9284c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x0000000100cb61b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x0000000100c840f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x0000000100cd5498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x0000000100cd561c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x0000000100ce67d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### Invalid login test failed

- **Page:** Login Page
- **URL:** http://localhost:3000/es/users/sign_in
- **Type:** Test Error
- **Description:** Message: 
Stacktrace:
0   chromedriver                        0x0000000105146ecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x000000010513eb88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x0000000104c562b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x0000000104c9d88c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x0000000104cded54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x0000000104c91ef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x000000010510a0c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x000000010510d8dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x00000001050ea84c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x000000010510e1b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x00000001050dc0f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x000000010512d498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x000000010512d61c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x000000010513e7d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### Logout test failed

- **Page:** Dashboard
- **URL:** http://localhost:3000/es/users/sign_in
- **Type:** Test Error
- **Description:** Message: 
Stacktrace:
0   chromedriver                        0x0000000103256ecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x000000010324eb88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x0000000102d662b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x0000000102dad88c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x0000000102deed54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x0000000102da1ef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x000000010321a0c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x000000010321d8dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x00000001031fa84c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x000000010321e1b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x00000001031ec0f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x000000010323d498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x000000010323d61c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x000000010324e7d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### Registration validation test failed

- **Page:** Registration Form
- **URL:** http://localhost:3000/es/users/sign_up
- **Type:** Test Error
- **Description:** Message: element click intercepted: Element <input type="submit" name="commit" value="Inscribirse" class="button" data-disable-with="Inscribirse"> is not clickable at point (589, 915). Other element would receive the click: <div class="cookie">...</div>
  (Session info: chrome=142.0.7444.176)
Stacktrace:
0   chromedriver                        0x00000001008feecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x00000001008f6b88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x000000010040e2b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x000000010045b3f0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 389732
4   chromedriver                        0x000000010045995c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 382928
5   chromedriver                        0x000000010045776c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 374240
6   chromedriver                        0x0000000100456b64 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 371160
7   chromedriver                        0x000000010044ba78 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 325868
8   chromedriver                        0x000000010044b504 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 324472
9   chromedriver                        0x0000000100496d54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
10  chromedriver                        0x0000000100449ef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
11  chromedriver                        0x00000001008c20c8 cxxbridge1$str$ptr + 2692164
12  chromedriver                        0x00000001008c58dc cxxbridge1$str$ptr + 2706520
13  chromedriver                        0x00000001008a284c cxxbridge1$str$ptr + 2563016
14  chromedriver                        0x00000001008c61b4 cxxbridge1$str$ptr + 2708784
15  chromedriver                        0x00000001008940f4 cxxbridge1$str$ptr + 2503792
16  chromedriver                        0x00000001008e5498 cxxbridge1$str$ptr + 2836500
17  chromedriver                        0x00000001008e561c cxxbridge1$str$ptr + 2836888
18  chromedriver                        0x00000001008f67d8 cxxbridge1$str$ptr + 2906964
19  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
20  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


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
0   chromedriver                        0x00000001029eeecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x00000001029e6b88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x00000001024fe2b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x000000010254588c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x0000000102586d54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x0000000102539ef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x00000001029b20c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x00000001029b58dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x000000010299284c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x00000001029b61b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x00000001029840f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x00000001029d5498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x00000001029d561c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x00000001029e67d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### Moderate page load time: Home

- **Page:** Performance
- **URL:** http://localhost:3000/es
- **Type:** Performance Issue
- **Description:** Home page took 5.02 seconds to load

### JavaScript console errors

- **Page:** Performance
- **URL:** http://localhost:3000/es
- **Type:** JavaScript Error
- **Description:** Console errors: http://localhost:3000/es 8 Loading the stylesheet 'https://fonts.googleapis.com/css?family=Montserrat:400,700' violates the following Content Security Policy directive: "style-src 'self' 'unsafe-inline'". Note that 'style-src-elem' was not explicitly set, so 'style-src' is used as a fallback. The action has been blocked.; http://localhost:3000/es 20 Executing inline script violates the following Content Security Policy directive 'script-src 'self' 'unsafe-eval''. Either the 'unsafe-inline' keyword, a hash ('sha256-fpUL/IXEAg1CE4Huyb/0NGHNjl9rrM3VniAacs5plJA='), or a nonce ('nonce-...') is required to enable inline execution. The action has been blocked.; http://localhost:3000/es 218 Executing inline script violates the following Content Security Policy directive 'script-src 'self' 'unsafe-eval''. Either the 'unsafe-inline' keyword, a hash ('sha256-V/wOQnokx12gn+N0zjfyYMbzPZKZN3cAt5+OrEVZfzg='), or a nonce ('nonce-...') is required to enable inline execution. The action has been blocked.; http://localhost:3000/es 236 Executing inline script violates the following Content Security Policy directive 'script-src 'self' 'unsafe-eval''. Either the 'unsafe-inline' keyword, a hash ('sha256-6GOYrydaQe00k/x4PBHFwxowvNeiJdaeRAXTbuxuvw8='), or a nonce ('nonce-...') is required to enable inline execution. The action has been blocked.; http://localhost:3000/api/csp-violations - Failed to load resource: the server responded with a status of 429 (Too Many Requests)

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
0   chromedriver                        0x0000000103466ecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x000000010345eb88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x0000000102f762b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x0000000102fbd88c _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 366336
4   chromedriver                        0x0000000102ffed54 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 633800
5   chromedriver                        0x0000000102fb1ef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
6   chromedriver                        0x000000010342a0c8 cxxbridge1$str$ptr + 2692164
7   chromedriver                        0x000000010342d8dc cxxbridge1$str$ptr + 2706520
8   chromedriver                        0x000000010340a84c cxxbridge1$str$ptr + 2563016
9   chromedriver                        0x000000010342e1b4 cxxbridge1$str$ptr + 2708784
10  chromedriver                        0x00000001033fc0f4 cxxbridge1$str$ptr + 2503792
11  chromedriver                        0x000000010344d498 cxxbridge1$str$ptr + 2836500
12  chromedriver                        0x000000010344d61c cxxbridge1$str$ptr + 2836888
13  chromedriver                        0x000000010345e7d8 cxxbridge1$str$ptr + 2906964
14  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
15  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### Session timeout test failed

- **Page:** Edge Cases
- **URL:** http://localhost:3000
- **Type:** Test Error
- **Description:** Message: invalid session id: session deleted as the browser has closed the connection
from disconnected: not connected to DevTools
  (Session info: chrome=142.0.7444.176)
Stacktrace:
0   chromedriver                        0x0000000104f66ecc cxxbridge1$str$ptr + 2941512
1   chromedriver                        0x0000000104f5eb88 cxxbridge1$str$ptr + 2907908
2   chromedriver                        0x0000000104a762b0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 74020
3   chromedriver                        0x0000000104a5fa2c chromedriver + 211500
4   chromedriver                        0x0000000104a82eb8 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 126252
5   chromedriver                        0x0000000104ae5de8 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 531548
6   chromedriver                        0x0000000104afe8b4 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 632616
7   chromedriver                        0x0000000104ab1ef0 _RNvCsgXDX2mvAJAg_7___rustc35___rust_no_alloc_shim_is_unstable_v2 + 318820
8   chromedriver                        0x0000000104f2a0c8 cxxbridge1$str$ptr + 2692164
9   chromedriver                        0x0000000104f2d8dc cxxbridge1$str$ptr + 2706520
10  chromedriver                        0x0000000104f0a84c cxxbridge1$str$ptr + 2563016
11  chromedriver                        0x0000000104f2e1b4 cxxbridge1$str$ptr + 2708784
12  chromedriver                        0x0000000104efc0f4 cxxbridge1$str$ptr + 2503792
13  chromedriver                        0x0000000104f4d498 cxxbridge1$str$ptr + 2836500
14  chromedriver                        0x0000000104f4d61c cxxbridge1$str$ptr + 2836888
15  chromedriver                        0x0000000104f5e7d8 cxxbridge1$str$ptr + 2906964
16  libsystem_pthread.dylib             0x0000000185a01c08 _pthread_start + 136
17  libsystem_pthread.dylib             0x00000001859fcba8 thread_start + 8


### No compression

- **Page:** Performance
- **URL:** http://localhost:3000/es
- **Type:** Performance Issue
- **Description:** Server does not use gzip/deflate compression

