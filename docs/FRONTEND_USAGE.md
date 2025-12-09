# PlebisHub Frontend Usage Guide

Quick reference for using the modernized frontend components and utilities.

## Vue Components in ERB Templates

### Basic Usage

Mount Vue components using the `vue_component` helper:

```erb
<%# Simple component %>
<%= vue_component('FlashMessages') %>

<%# Component with props %>
<%= vue_component('CookieConsent',
  privacyUrl: page_path('privacy'),
  cookiesUrl: page_path('cookies'),
  showSettings: true
) %>

<%# Component with HTML options %>
<%= vue_component('Modal', { title: 'Confirm' }, class: 'my-modal', id: 'confirm-modal') %>
```

### Available Components

| Component | Description | Props |
|-----------|-------------|-------|
| `FlashMessages` | Toast notifications | `initialMessages`, `position`, `maxMessages` |
| `CookieConsent` | GDPR cookie banner | `privacyUrl`, `cookiesUrl`, `showSettings` |

---

## Stimulus Controllers

### Dropdown

```erb
<div data-controller="dropdown">
  <button data-action="click->dropdown#toggle">Menu</button>
  <div data-dropdown-target="menu" class="hidden">
    <a href="#">Item 1</a>
    <a href="#">Item 2</a>
  </div>
</div>
```

### Mobile Menu

```erb
<header data-controller="mobile-menu">
  <button data-action="click->mobile-menu#toggle">
    <svg><!-- hamburger icon --></svg>
  </button>
  <nav data-mobile-menu-target="panel" class="hidden md:block">
    <!-- navigation links -->
  </nav>
</header>
```

### Modal

```erb
<div data-controller="modal">
  <button data-action="click->modal#open">Open Modal</button>

  <div data-modal-target="backdrop" class="hidden fixed inset-0 bg-black/50"
       data-action="click->modal#backdropClick">
    <div data-modal-target="dialog" class="bg-white rounded-lg p-6">
      <h2>Modal Title</h2>
      <p>Modal content...</p>
      <button data-action="click->modal#close">Close</button>
    </div>
  </div>
</div>
```

### Tabs

```erb
<div data-controller="tabs">
  <div role="tablist" class="flex gap-2">
    <button data-tabs-target="tab" data-action="click->tabs#select">Tab 1</button>
    <button data-tabs-target="tab" data-action="click->tabs#select">Tab 2</button>
  </div>

  <div data-tabs-target="panel">Content 1</div>
  <div data-tabs-target="panel" class="hidden">Content 2</div>
</div>
```

### Tooltip

```erb
<button data-controller="tooltip"
        data-tooltip-content-value="Helpful tooltip text"
        data-tooltip-position-value="top">
  Hover me
</button>
```

### Clipboard

```erb
<%# Copy static text %>
<button data-controller="clipboard"
        data-clipboard-text-value="Text to copy"
        data-action="click->clipboard#copy">
  Copy
</button>

<%# Copy from input %>
<div data-controller="clipboard">
  <input data-clipboard-target="source" value="Copy this">
  <button data-action="click->clipboard#copy">Copy</button>
</div>
```

---

## Performance Helpers

### Lazy Loading Images

```erb
<%# Basic lazy loading %>
<%= lazy_image_tag 'photo.jpg', alt: 'Description', class: 'w-full' %>

<%# Responsive images with srcset %>
<%= responsive_image_tag 'hero',
    sizes: [320, 640, 1024, 1920],
    alt: 'Hero image' %>

<%# Modern formats with fallback %>
<%= picture_tag 'photo',
    formats: %w[avif webp jpg],
    alt: 'Photo' %>
```

### Resource Hints

```erb
<%# In <head> section %>

<%# Preconnect to external origins %>
<%= preconnect_tag 'https://fonts.googleapis.com' %>
<%= preconnect_tag 'https://fonts.gstatic.com', crossorigin: true %>

<%# DNS prefetch for external domains %>
<%= dns_prefetch_tag 'analytics.example.com' %>

<%# Preload critical resources %>
<%= preload_tag 'fonts/inter.woff2', as: 'font', type: 'font/woff2', crossorigin: 'anonymous' %>

<%# Prefetch for next-page resources %>
<%= prefetch_tag 'next-page-styles.css' %>
```

---

## Flash Messages from JavaScript

### Using the Legacy Bridge

```javascript
// Show flash messages from jQuery or vanilla JS
window.VueBridge.showFlash('success', 'Operation completed!')
window.VueBridge.showFlash('error', 'Something went wrong')
window.VueBridge.showFlash('warning', 'Please review your input')
window.VueBridge.showFlash('info', 'FYI: New features available')

// Mount a Vue component programmatically
const el = document.querySelector('#my-container')
window.VueBridge.mount(el, 'ComponentName', { prop1: 'value' })

// Unmount a component
window.VueBridge.unmount(el)

// Get CSRF token
const token = window.VueBridge.getCsrfToken()

// Event communication (jQuery <-> Vue)
window.VueBridge.emit('customEvent', { data: 'value' })
window.VueBridge.on('customEvent', (data) => console.log(data))
```

### Using Vue Composables

```typescript
// In a Vue component
import { useFlash } from '@/composables/useFlash'

const flash = useFlash()
flash.success('Saved successfully!')
flash.error('Failed to save')
```

---

## API Requests

### Using useApi Composable

```typescript
import { useApi } from '@/composables/useApi'

const api = useApi()

// GET request
const users = await api.get('/api/users')

// POST request
const newUser = await api.post('/api/users', {
  name: 'John',
  email: 'john@example.com'
})

// PUT request
await api.put('/api/users/1', { name: 'Jane' })

// DELETE request
await api.delete('/api/users/1')

// Check loading state
if (api.loading.value) {
  // Show spinner
}

// Handle errors
if (api.error.value) {
  console.error(api.error.value)
}
```

### Creating API Client with Base URL

```typescript
import { createApiClient } from '@/composables/useApi'

const client = createApiClient({
  baseUrl: '/api/v1',
  headers: {
    'X-Custom-Header': 'value'
  }
})

// All requests will use /api/v1 prefix
const data = await client.get('/users') // -> /api/v1/users
```

---

## CSS Classes Reference

### Buttons

```html
<!-- Variants -->
<button class="btn btn-primary">Primary</button>
<button class="btn btn-secondary">Secondary</button>
<button class="btn btn-outline">Outline</button>
<button class="btn btn-ghost">Ghost</button>
<button class="btn btn-danger">Danger</button>

<!-- Sizes -->
<button class="btn btn-sm">Small</button>
<button class="btn">Medium</button>
<button class="btn btn-lg">Large</button>

<!-- States -->
<button class="btn btn-primary" disabled>Disabled</button>
<button class="btn btn-primary btn-loading">Loading...</button>
```

### Forms

```html
<label class="form-label">Email</label>
<input type="email" class="form-input" placeholder="you@example.com">
<span class="form-error">Please enter a valid email</span>
<span class="form-hint">We'll never share your email</span>

<!-- Select -->
<select class="form-select">
  <option>Option 1</option>
</select>

<!-- Checkbox/Radio -->
<label class="form-checkbox">
  <input type="checkbox">
  <span>Remember me</span>
</label>
```

### Cards

```html
<div class="card">
  <div class="card-header">Title</div>
  <div class="card-body">Content here</div>
  <div class="card-footer">Footer</div>
</div>
```

### Alerts

```html
<div class="alert alert-success">Success message</div>
<div class="alert alert-error">Error message</div>
<div class="alert alert-warning">Warning message</div>
<div class="alert alert-info">Info message</div>
```

### Navigation

```html
<nav class="nav-tabs">
  <a href="#" class="nav-link nav-link-active">Active</a>
  <a href="#" class="nav-link">Inactive</a>
</nav>
```

---

## Running Tests

```bash
# Run all frontend tests
npm run test

# Run with coverage
npm run test:coverage

# Run in watch mode
npm run test:watch
```

---

## File Structure

```
app/frontend/
├── components/
│   ├── atoms/           # Basic UI elements
│   ├── molecules/       # Composed components
│   └── organisms/       # Complex components
├── composables/         # Vue composition functions
├── controllers/         # Stimulus controllers
├── entrypoints/         # Build entry points
├── test/               # Test files
│   ├── components/
│   └── composables/
└── types/              # TypeScript definitions
```
