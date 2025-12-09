# PlebisHub Front-End Upgrade Guide

A comprehensive step-by-step guide to clean, upgrade, and improve the front-end architecture.

## Current State Analysis

### Architecture Overview

| Layer | Legacy Stack | Modern Stack |
|-------|-------------|--------------|
| **Build Tool** | Sprockets | Vite 5.1.5 |
| **CSS** | Bootstrap 3.4.1 + SASS | Tailwind CSS 3.4.1 |
| **JavaScript** | jQuery + CoffeeScript | Vue 3.4 + TypeScript |
| **State** | Global variables | Pinia |
| **Icons** | Font Awesome 4.7 | Lucide Vue |
| **Components** | ERB partials | Vue SFCs (Atomic Design) |

### Files to Migrate

```
Legacy (Sprockets):
├── app/assets/javascripts/     # 25+ files (.js, .coffee)
├── app/assets/stylesheets/     # 12+ files (.sass, .scss)
└── vendor/assets/              # Third-party legacy libs

Modern (Vite):
├── app/frontend/components/    # 93+ Vue components
├── app/frontend/composables/   # 14 composition functions
└── app/frontend/entrypoints/   # Build entry points
```

---

## Phase 1: Foundation Cleanup (Week 1-2)

### Step 1.1: Remove Deprecated Dependencies

**Gemfile changes:**

```ruby
# REMOVE these gems:
gem 'coffee-rails'           # CoffeeScript is deprecated
gem 'turbolinks'             # Replace with Turbo or remove
gem 'uglifier'               # Vite handles minification

# KEEP these (for now, during transition):
gem 'sprockets-rails'        # Still needed for legacy assets
gem 'sass-rails'             # Still needed for legacy SASS
gem 'jquery-rails'           # Still needed until full migration
gem 'bootstrap-sass'         # Still needed until Tailwind migration
```

**Run:**
```bash
bundle remove coffee-rails turbolinks uglifier
bundle install
```

### Step 1.2: Convert CoffeeScript to JavaScript

**Files to convert:**
```
app/assets/javascripts/
├── collaborations.js.coffee     → collaborations.js
├── credits.js.coffee            → credits.js
├── impulsa.js.coffee            → impulsa.js
├── microcredit.js.coffee        → microcredit.js
├── mobile.js.coffee             → mobile.js
├── proposals.js.coffee          → proposals.js
├── registrations.js.coffee.erb  → registrations.js.erb
├── user_verifications.js.coffee → user_verifications.js
└── zfixes.js.coffee             → zfixes.js
```

**Conversion approach:**
```bash
# Install decaffeinate globally
npm install -g decaffeinate

# Convert each file
decaffeinate app/assets/javascripts/collaborations.js.coffee
decaffeinate app/assets/javascripts/credits.js.coffee
# ... repeat for each file
```

### Step 1.3: Update Layout for Modern Assets

**app/views/layouts/application.html.erb:**

```erb
<!DOCTYPE html>
<html lang="<%= I18n.locale %>">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><%= yield(:title) || 'PlebisHub' %></title>

  <!-- Favicon -->
  <%= favicon_link_tag 'favicon.png' %>

  <!-- Modern Fonts (preconnect for performance) -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Montserrat:wght@600;700;800&display=swap" rel="stylesheet">

  <!-- CSRF Protection -->
  <%= csrf_meta_tags %>
  <%= csp_meta_tag %>

  <!-- Stylesheets -->
  <%= vite_stylesheet_tag 'application.css' %>
  <%= stylesheet_link_tag 'legacy', media: 'all' if legacy_styles_needed? %>

  <!-- Open Graph / Social -->
  <meta property="og:title" content="<%= yield(:og_title) || 'PlebisHub' %>">
  <meta property="og:description" content="<%= yield(:og_description) || @meta_description %>">
  <meta property="og:image" content="<%= yield(:og_image) || @meta_image %>">
  <meta name="twitter:card" content="summary_large_image">

  <%= render 'shared/tag_manager_head' if Rails.env.production? %>
</head>
<body class="<%= body_class(user_signed_in?, controller_name, action_name) %>">
  <div id="app" class="min-h-screen flex flex-col">
    <%= render 'shared/header' %>

    <main class="flex-1">
      <%= render 'shared/flash_messages' %>
      <%= yield %>
    </main>

    <%= render 'shared/footer' %>
  </div>

  <!-- Vue 3 App -->
  <%= vite_javascript_tag 'application' %>

  <!-- Legacy JS (only where needed) -->
  <% if legacy_js_needed? %>
    <%= javascript_include_tag 'legacy', defer: true %>
  <% end %>

  <%= render 'shared/cookie_consent' %>
  <%= render 'shared/analytics' if Rails.env.production? %>
</body>
</html>
```

---

## Phase 2: CSS Migration (Week 3-4)

### Step 2.1: Audit Current Bootstrap Usage

**Create inventory of Bootstrap classes used:**

```bash
# Find all Bootstrap classes in views
grep -rho 'class="[^"]*"' app/views/ | \
  tr ' ' '\n' | \
  grep -E '^(col-|btn-|alert-|panel-|form-|nav-|table-|modal-)' | \
  sort | uniq -c | sort -rn > bootstrap_classes_audit.txt
```

**Common Bootstrap → Tailwind mappings:**

| Bootstrap 3 | Tailwind CSS |
|-------------|--------------|
| `container` | `container mx-auto px-4` |
| `row` | `flex flex-wrap -mx-4` |
| `col-md-6` | `w-full md:w-1/2 px-4` |
| `btn btn-primary` | `btn-primary` (custom) |
| `btn btn-default` | `btn-secondary` (custom) |
| `alert alert-success` | `alert-success` (custom) |
| `panel` | `card` (Vue component) |
| `form-control` | `input` (Vue component) |
| `pull-right` | `float-right` or `ml-auto` |
| `text-center` | `text-center` |
| `hidden-xs` | `hidden sm:block` |

### Step 2.2: Create Tailwind Utility Classes

**app/frontend/entrypoints/application.css:**

```css
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

/* ==========================================
   DESIGN SYSTEM - Component Classes
   ========================================== */

/* Buttons */
@layer components {
  .btn {
    @apply inline-flex items-center justify-center px-4 py-2
           font-medium rounded-lg transition-all duration-200
           focus:outline-none focus:ring-2 focus:ring-offset-2
           disabled:opacity-50 disabled:cursor-not-allowed;
  }

  .btn-primary {
    @apply btn bg-primary-600 text-white
           hover:bg-primary-700 focus:ring-primary-500;
  }

  .btn-secondary {
    @apply btn bg-secondary-600 text-white
           hover:bg-secondary-700 focus:ring-secondary-500;
  }

  .btn-outline {
    @apply btn border-2 border-primary-600 text-primary-600
           hover:bg-primary-50 focus:ring-primary-500;
  }

  .btn-ghost {
    @apply btn text-gray-700 hover:bg-gray-100 focus:ring-gray-500;
  }

  .btn-sm { @apply text-sm px-3 py-1.5; }
  .btn-lg { @apply text-lg px-6 py-3; }
}

/* Forms */
@layer components {
  .form-input {
    @apply block w-full px-3 py-2
           border border-gray-300 rounded-lg
           placeholder-gray-400
           focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent
           disabled:bg-gray-100 disabled:cursor-not-allowed;
  }

  .form-label {
    @apply block text-sm font-medium text-gray-700 mb-1;
  }

  .form-error {
    @apply mt-1 text-sm text-red-600;
  }

  .form-help {
    @apply mt-1 text-sm text-gray-500;
  }
}

/* Cards */
@layer components {
  .card {
    @apply bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden;
  }

  .card-header {
    @apply px-6 py-4 border-b border-gray-100 bg-gray-50;
  }

  .card-body {
    @apply px-6 py-4;
  }

  .card-footer {
    @apply px-6 py-4 border-t border-gray-100 bg-gray-50;
  }
}

/* Alerts */
@layer components {
  .alert {
    @apply p-4 rounded-lg border flex items-start gap-3;
  }

  .alert-success {
    @apply alert bg-green-50 border-green-200 text-green-800;
  }

  .alert-error {
    @apply alert bg-red-50 border-red-200 text-red-800;
  }

  .alert-warning {
    @apply alert bg-yellow-50 border-yellow-200 text-yellow-800;
  }

  .alert-info {
    @apply alert bg-blue-50 border-blue-200 text-blue-800;
  }
}

/* Navigation */
@layer components {
  .nav-link {
    @apply px-4 py-2 text-gray-600 font-medium rounded-lg
           hover:text-primary-600 hover:bg-primary-50
           transition-colors duration-200;
  }

  .nav-link-active {
    @apply nav-link text-primary-600 bg-primary-50;
  }
}

/* Tables */
@layer components {
  .table {
    @apply min-w-full divide-y divide-gray-200;
  }

  .table th {
    @apply px-6 py-3 text-left text-xs font-medium
           text-gray-500 uppercase tracking-wider bg-gray-50;
  }

  .table td {
    @apply px-6 py-4 whitespace-nowrap text-sm text-gray-900;
  }

  .table tbody tr {
    @apply hover:bg-gray-50 transition-colors;
  }
}

/* ==========================================
   LEGACY COMPATIBILITY LAYER
   (Remove after full migration)
   ========================================== */

@layer utilities {
  /* Bootstrap grid compatibility */
  .container { @apply mx-auto px-4 max-w-7xl; }
  .row { @apply flex flex-wrap -mx-4; }
  .col-xs-12 { @apply w-full px-4; }
  .col-sm-6 { @apply w-full sm:w-1/2 px-4; }
  .col-md-4 { @apply w-full md:w-1/3 px-4; }
  .col-md-6 { @apply w-full md:w-1/2 px-4; }
  .col-md-8 { @apply w-full md:w-2/3 px-4; }
  .col-lg-3 { @apply w-full lg:w-1/4 px-4; }
  .col-lg-4 { @apply w-full lg:w-1/3 px-4; }

  /* Bootstrap utilities compatibility */
  .pull-left { @apply float-left; }
  .pull-right { @apply float-right; }
  .clearfix::after { @apply block clear-both content-['']; }
  .hidden-xs { @apply hidden sm:block; }
  .hidden-sm { @apply hidden md:block; }
  .visible-xs { @apply block sm:hidden; }
}
```

### Step 2.3: Create Legacy Stylesheet Bundle

**app/assets/stylesheets/legacy.css.sass:**

```sass
// Legacy Bootstrap (only for pages not yet migrated)
@import "bootstrap_custom"

// Legacy component styles
@import "impulsa"
@import "forms"
@import "adjustments"
@import "user_verifications"

// Keep only essential vendor styles
@import "select2"
@import "select2-adj"
```

---

## Phase 3: JavaScript Migration (Week 5-8)

### Step 3.1: Create Vue Mount Points Strategy

**Gradual migration approach - "Island Architecture":**

```erb
<!-- In ERB views, create mount points for Vue components -->
<div
  data-vue-component="CollaborationForm"
  data-props='<%= { user_id: current_user.id, csrf_token: form_authenticity_token }.to_json %>'
></div>
```

**app/frontend/entrypoints/application.ts:**

```typescript
import { createApp, defineAsyncComponent } from 'vue'
import { createPinia } from 'pinia'

// Component registry for lazy loading
const components: Record<string, () => Promise<any>> = {
  // Forms
  CollaborationForm: () => import('@components/organisms/CollaborationForm.vue'),
  MicrocreditForm: () => import('@components/organisms/MicrocreditForm.vue'),
  ImpulsaProjectForm: () => import('@components/organisms/ImpulsaProjectForm.vue'),
  ProposalForm: () => import('@components/organisms/ProposalForm.vue'),

  // Widgets
  VotingWidget: () => import('@components/organisms/VotingWidget.vue'),
  VerificationSteps: () => import('@components/organisms/VerificationSteps.vue'),

  // Common
  FlashMessages: () => import('@components/molecules/FlashMessages.vue'),
  CookieConsent: () => import('@components/molecules/CookieConsent.vue'),
}

// Mount Vue components on DOM elements
function mountVueComponents() {
  const pinia = createPinia()

  document.querySelectorAll('[data-vue-component]').forEach((el) => {
    const componentName = el.getAttribute('data-vue-component')
    if (!componentName || !components[componentName]) {
      console.warn(`Vue component "${componentName}" not found in registry`)
      return
    }

    const props = JSON.parse(el.getAttribute('data-props') || '{}')

    const app = createApp(
      defineAsyncComponent(components[componentName]),
      props
    )

    app.use(pinia)
    app.mount(el)
  })
}

// Initialize on DOM ready and Turbo navigation (if using Turbo)
document.addEventListener('DOMContentLoaded', mountVueComponents)
document.addEventListener('turbo:load', mountVueComponents)
```

### Step 3.2: Migrate jQuery Functions to Vue Composables

**Example: Select2 → Vue Select Component**

**Before (jQuery):**
```javascript
// app/assets/javascripts/forms.js
$(document).ready(function() {
  $('.select2').select2({
    placeholder: 'Selecciona una opción',
    allowClear: true
  });
});
```

**After (Vue composable):**
```typescript
// app/frontend/composables/useSelect.ts
import { ref, onMounted, onUnmounted, watch } from 'vue'

export function useSelect(options: {
  placeholder?: string
  allowClear?: boolean
  searchable?: boolean
  multiple?: boolean
}) {
  const selectedValue = ref<string | string[] | null>(null)
  const isOpen = ref(false)
  const searchQuery = ref('')

  const filteredOptions = computed(() => {
    if (!searchQuery.value) return options.items
    return options.items.filter(item =>
      item.label.toLowerCase().includes(searchQuery.value.toLowerCase())
    )
  })

  return {
    selectedValue,
    isOpen,
    searchQuery,
    filteredOptions,
    open: () => isOpen.value = true,
    close: () => isOpen.value = false,
    select: (value: string) => {
      if (options.multiple) {
        const current = selectedValue.value as string[] || []
        selectedValue.value = current.includes(value)
          ? current.filter(v => v !== value)
          : [...current, value]
      } else {
        selectedValue.value = value
        isOpen.value = false
      }
    },
    clear: () => {
      selectedValue.value = options.multiple ? [] : null
    }
  }
}
```

### Step 3.3: Create Migration Helper for Legacy Code

**app/frontend/utils/legacy-bridge.ts:**

```typescript
/**
 * Bridge between legacy jQuery code and Vue components
 * Use this during migration to allow jQuery and Vue to coexist
 */

// Expose Vue components to global scope for legacy code
import { createApp } from 'vue'

export function exposeToLegacy(name: string, component: any) {
  (window as any).VueComponents = (window as any).VueComponents || {}
  (window as any).VueComponents[name] = component
}

// Allow legacy jQuery to trigger Vue events
export function createEventBridge() {
  const eventBus = new EventTarget()

  // jQuery can dispatch events
  (window as any).dispatchVueEvent = (name: string, detail: any) => {
    eventBus.dispatchEvent(new CustomEvent(name, { detail }))
  }

  // Vue can listen to events
  return {
    on: (name: string, handler: (detail: any) => void) => {
      eventBus.addEventListener(name, (e: Event) => {
        handler((e as CustomEvent).detail)
      })
    },
    off: (name: string, handler: (detail: any) => void) => {
      eventBus.removeEventListener(name, handler as EventListener)
    }
  }
}

// CSRF token helper for AJAX requests
export function getCsrfToken(): string {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta?.getAttribute('content') || ''
}

// Flash message helper (works with both systems)
export function showFlash(type: 'success' | 'error' | 'warning' | 'info', message: string) {
  const event = new CustomEvent('flash-message', {
    detail: { type, message }
  })
  document.dispatchEvent(event)
}
```

---

## Phase 4: Component-by-Component Migration (Week 9-16)

### Step 4.1: Migration Priority Order

**Priority 1 - High Traffic Pages:**
1. Registration/Login forms
2. Main navigation/header
3. Flash messages
4. Footer

**Priority 2 - Core Features:**
5. Collaboration forms
6. Microcredit forms
7. Voting widgets
8. User verification flow

**Priority 3 - Secondary Features:**
9. Impulsa project forms
10. Proposal system
11. Profile pages
12. Admin interfaces

### Step 4.2: Example Migration - Flash Messages

**Before (ERB partial):**
```erb
<!-- app/views/application/_flash_boxes.html.erb -->
<% flash.each do |type, message| %>
  <div class="alert alert-<%= type %> alert-dismissible">
    <button type="button" class="close" data-dismiss="alert">&times;</button>
    <%= message %>
  </div>
<% end %>
```

**After (Vue component):**
```vue
<!-- app/frontend/components/molecules/FlashMessages.vue -->
<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { X, CheckCircle, AlertCircle, AlertTriangle, Info } from 'lucide-vue-next'

interface FlashMessage {
  id: number
  type: 'success' | 'error' | 'warning' | 'info'
  message: string
}

const messages = ref<FlashMessage[]>([])
let messageId = 0

const icons = {
  success: CheckCircle,
  error: AlertCircle,
  warning: AlertTriangle,
  info: Info
}

const styles = {
  success: 'bg-green-50 border-green-200 text-green-800',
  error: 'bg-red-50 border-red-200 text-red-800',
  warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
  info: 'bg-blue-50 border-blue-200 text-blue-800'
}

function addMessage(type: FlashMessage['type'], message: string) {
  const id = ++messageId
  messages.value.push({ id, type, message })

  // Auto-dismiss after 5 seconds
  setTimeout(() => removeMessage(id), 5000)
}

function removeMessage(id: number) {
  messages.value = messages.value.filter(m => m.id !== id)
}

// Listen for flash events from Rails/legacy code
function handleFlashEvent(e: Event) {
  const { type, message } = (e as CustomEvent).detail
  addMessage(type, message)
}

onMounted(() => {
  document.addEventListener('flash-message', handleFlashEvent)

  // Load initial flash messages from Rails
  const initialFlash = document.querySelector('[data-flash-messages]')
  if (initialFlash) {
    const flashData = JSON.parse(initialFlash.getAttribute('data-flash-messages') || '[]')
    flashData.forEach(({ type, message }: { type: string; message: string }) => {
      addMessage(type as FlashMessage['type'], message)
    })
  }
})

onUnmounted(() => {
  document.removeEventListener('flash-message', handleFlashEvent)
})
</script>

<template>
  <div class="fixed top-4 right-4 z-50 flex flex-col gap-2 max-w-md">
    <TransitionGroup name="flash">
      <div
        v-for="msg in messages"
        :key="msg.id"
        :class="['flex items-start gap-3 p-4 rounded-lg border shadow-lg', styles[msg.type]]"
      >
        <component :is="icons[msg.type]" class="w-5 h-5 flex-shrink-0 mt-0.5" />
        <p class="flex-1 text-sm">{{ msg.message }}</p>
        <button
          @click="removeMessage(msg.id)"
          class="flex-shrink-0 p-1 rounded hover:bg-black/5 transition-colors"
        >
          <X class="w-4 h-4" />
        </button>
      </div>
    </TransitionGroup>
  </div>
</template>

<style scoped>
.flash-enter-active,
.flash-leave-active {
  transition: all 0.3s ease;
}

.flash-enter-from {
  opacity: 0;
  transform: translateX(100%);
}

.flash-leave-to {
  opacity: 0;
  transform: translateX(100%);
}
</style>
```

---

## Phase 5: Performance Optimization (Week 17-18)

### Step 5.1: Bundle Analysis & Optimization

**Add bundle analyzer:**

```bash
pnpm add -D rollup-plugin-visualizer
```

**vite.config.ts:**
```typescript
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig({
  plugins: [
    // ... other plugins
    visualizer({
      filename: 'tmp/bundle-stats.html',
      open: true,
      gzipSize: true
    })
  ]
})
```

### Step 5.2: Implement Code Splitting

**app/frontend/config/lazy-loading.ts:**

```typescript
export const lazyComponents = {
  // Load immediately (above the fold)
  critical: [
    'Header',
    'FlashMessages',
    'Button',
    'Input'
  ],

  // Load on interaction
  interactive: [
    'Modal',
    'Dropdown',
    'Tabs',
    'Accordion'
  ],

  // Load when visible (intersection observer)
  deferred: [
    'Footer',
    'CookieConsent',
    'VotingWidget'
  ],

  // Load on route/page
  routeBased: {
    '/collaborations': ['CollaborationForm', 'PaymentWidget'],
    '/microcredits': ['MicrocreditForm', 'LoanCalculator'],
    '/impulsa': ['ImpulsaProjectForm', 'ProjectGallery'],
    '/votes': ['VotingWidget', 'VoteResults']
  }
}
```

### Step 5.3: Image Optimization

**Install sharp for image processing:**
```bash
pnpm add -D vite-plugin-image-optimizer
```

**vite.config.ts:**
```typescript
import { ViteImageOptimizer } from 'vite-plugin-image-optimizer'

export default defineConfig({
  plugins: [
    ViteImageOptimizer({
      png: { quality: 80 },
      jpeg: { quality: 80 },
      webp: { quality: 80 },
      avif: { quality: 70 }
    })
  ]
})
```

### Step 5.4: Add Resource Hints

**app/views/layouts/application.html.erb:**
```erb
<head>
  <!-- DNS Prefetch -->
  <link rel="dns-prefetch" href="//fonts.googleapis.com">
  <link rel="dns-prefetch" href="//fonts.gstatic.com">

  <!-- Preconnect -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

  <!-- Preload critical assets -->
  <%= vite_preload_tag 'application.css', as: 'style' %>
  <%= vite_preload_tag 'application.ts', as: 'script' %>

  <!-- Prefetch next likely pages -->
  <% if user_signed_in? %>
    <link rel="prefetch" href="<%= vite_asset_path('organisms-forms.js') %>">
  <% end %>
</head>
```

---

## Phase 6: Testing & Quality Assurance (Week 19-20)

### Step 6.1: Component Testing

**Run existing tests:**
```bash
pnpm test              # Unit tests
pnpm test:coverage     # With coverage
pnpm test:e2e          # E2E tests
```

### Step 6.2: Visual Regression Testing

**Add Chromatic for Storybook:**
```bash
pnpm add -D chromatic

# Run visual tests
npx chromatic --project-token=<your-token>
```

### Step 6.3: Performance Testing

**Lighthouse CI setup:**
```bash
pnpm add -D @lhci/cli

# Create lighthouserc.js
```

**lighthouserc.js:**
```javascript
module.exports = {
  ci: {
    collect: {
      url: ['http://localhost:3000/', 'http://localhost:3000/collaborations/new'],
      numberOfRuns: 3
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.8 }],
        'categories:accessibility': ['error', { minScore: 0.9 }],
        'categories:best-practices': ['error', { minScore: 0.9 }],
        'categories:seo': ['error', { minScore: 0.9 }]
      }
    }
  }
}
```

### Step 6.4: Accessibility Audit

**Run a11y tests:**
```bash
pnpm storybook        # Start Storybook
# Use the a11y addon panel to check each component
```

---

## Phase 7: Cleanup & Documentation (Week 21-22)

### Step 7.1: Remove Legacy Code

**After full migration, remove:**

```ruby
# Gemfile - REMOVE:
gem 'bootstrap-sass'
gem 'jquery-rails'
gem 'jquery-fileupload-rails'
gem 'turbolinks'
```

**Delete legacy directories:**
```bash
rm -rf app/assets/javascripts/*.coffee
rm -rf app/assets/stylesheets/bootstrap*
rm -rf vendor/assets/javascripts/jquery*
rm -rf vendor/assets/stylesheets/jquery*
```

### Step 7.2: Update Asset Pipeline

**config/initializers/assets.rb:**
```ruby
# Only precompile the legacy bundle if still needed
Rails.application.config.assets.precompile += %w[legacy.js legacy.css] if ENV['LEGACY_ASSETS']

# Otherwise, Vite handles everything
Rails.application.config.assets.compile = false
```

### Step 7.3: Final Documentation

Update README with new frontend architecture:

```markdown
## Frontend Architecture

This application uses a modern frontend stack:

- **Build Tool**: Vite 5.x
- **Framework**: Vue 3.4 with Composition API
- **Styling**: Tailwind CSS 3.4
- **State Management**: Pinia
- **TypeScript**: Strict mode enabled
- **Testing**: Vitest + Playwright

### Development

```bash
# Start Vite dev server (run alongside Rails)
pnpm dev

# Run tests
pnpm test

# Build for production
pnpm build

# Component development
pnpm storybook
```

### File Structure

```
app/frontend/
├── assets/           # Static assets (images, fonts)
├── components/       # Vue components (Atomic Design)
│   ├── atoms/        # Basic elements
│   ├── molecules/    # Composite components
│   └── organisms/    # Complex features
├── composables/      # Vue composition functions
├── entrypoints/      # Build entry points
├── stores/           # Pinia stores
├── types/            # TypeScript types
└── utils/            # Utility functions
```
```

---

## Quick Reference: Commands

```bash
# Development
pnpm dev                    # Start Vite dev server
rails s                     # Start Rails server
pnpm storybook              # Component library

# Testing
pnpm test                   # Run unit tests
pnpm test:e2e               # Run E2E tests
pnpm test:coverage          # Coverage report

# Building
pnpm build                  # Production build
pnpm type-check             # TypeScript validation

# Linting
pnpm lint                   # ESLint
pnpm format                 # Prettier

# Analysis
pnpm build && open tmp/bundle-stats.html
```

---

## Migration Checklist

### Phase 1: Foundation ✅
- [ ] Remove deprecated gems (coffee-rails, turbolinks, uglifier)
- [ ] Convert CoffeeScript files to JavaScript
- [ ] Update layout template

### Phase 2: CSS ✅
- [ ] Audit Bootstrap class usage
- [ ] Create Tailwind component classes
- [ ] Set up legacy CSS bundle

### Phase 3: JavaScript ✅
- [ ] Set up Vue mount points
- [ ] Create legacy bridge utilities
- [ ] Migrate jQuery to composables

### Phase 4: Components ✅
- [ ] Migrate flash messages
- [ ] Migrate header/navigation
- [ ] Migrate forms
- [ ] Migrate widgets

### Phase 5: Performance ✅
- [ ] Set up bundle analysis
- [ ] Implement code splitting
- [ ] Optimize images
- [ ] Add resource hints

### Phase 6: Testing ✅
- [ ] Run component tests
- [ ] Visual regression testing
- [ ] Performance testing
- [ ] Accessibility audit

### Phase 7: Cleanup ✅
- [ ] Remove legacy dependencies
- [ ] Delete unused files
- [ ] Update documentation

---

## Estimated Timeline

| Phase | Duration | Focus |
|-------|----------|-------|
| Phase 1 | 2 weeks | Foundation cleanup |
| Phase 2 | 2 weeks | CSS migration |
| Phase 3 | 4 weeks | JavaScript migration |
| Phase 4 | 8 weeks | Component migration |
| Phase 5 | 2 weeks | Performance |
| Phase 6 | 2 weeks | Testing |
| Phase 7 | 2 weeks | Cleanup |
| **Total** | **22 weeks** | ~5.5 months |

---

## Support Resources

- [Vue 3 Documentation](https://vuejs.org/)
- [Tailwind CSS Documentation](https://tailwindcss.com/)
- [Vite Documentation](https://vitejs.dev/)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Storybook Documentation](https://storybook.js.org/)
