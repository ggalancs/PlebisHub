/**
 * Main entry point for Vue 3 + Vite frontend
 * This file is loaded by vite_rails and initializes the Vue application
 *
 * Supports:
 * - Islands Architecture: Mount Vue components in ERB templates
 * - Lazy Loading: Components loaded on demand
 * - Legacy Bridge: jQuery/Vue interoperability during migration
 */

import { createApp, defineAsyncComponent } from 'vue'
import { createPinia } from 'pinia'
import type { Component, App } from 'vue'

// Import global styles
import './application.css'

// Import Stimulus controllers
import '@/controllers'

// ==========================================
// Component Registry with Lazy Loading
// ==========================================

type ComponentLoader = () => Promise<{ default: Component }>

// Async component loaders for code splitting
// Only includes components that actually exist in the codebase
const componentLoaders: Record<string, ComponentLoader> = {
  // Atoms
  Button: () => import('@/components/atoms/Button.vue'),
  Input: () => import('@/components/atoms/Input.vue'),
  Badge: () => import('@/components/atoms/Badge.vue'),
  Avatar: () => import('@/components/atoms/Avatar.vue'),
  Spinner: () => import('@/components/atoms/Spinner.vue'),
  Toggle: () => import('@/components/atoms/Toggle.vue'),
  Checkbox: () => import('@/components/atoms/Checkbox.vue'),
  Radio: () => import('@/components/atoms/Radio.vue'),
  Progress: () => import('@/components/atoms/Progress.vue'),
  Icon: () => import('@/components/atoms/Icon.vue'),
  Tooltip: () => import('@/components/atoms/Tooltip.vue'),
  Logo: () => import('@/components/atoms/Logo.vue'),

  // Molecules
  Alert: () => import('@/components/molecules/Alert.vue'),
  Card: () => import('@/components/molecules/Card.vue'),
  Modal: () => import('@/components/molecules/Modal.vue'),
  Tabs: () => import('@/components/molecules/Tabs.vue'),
  Accordion: () => import('@/components/molecules/Accordion.vue'),
  Dropdown: () => import('@/components/molecules/Dropdown.vue'),
  Pagination: () => import('@/components/molecules/Pagination.vue'),
  FormField: () => import('@/components/molecules/FormField.vue'),
  SearchBar: () => import('@/components/molecules/SearchBar.vue'),
  FileUpload: () => import('@/components/molecules/FileUpload.vue'),
  DatePicker: () => import('@/components/molecules/DatePicker.vue'),
  Combobox: () => import('@/components/molecules/Combobox.vue'),
  Toast: () => import('@/components/molecules/Toast.vue'),
  Breadcrumb: () => import('@/components/molecules/Breadcrumb.vue'),
  EmptyState: () => import('@/components/molecules/EmptyState.vue'),
  Skeleton: () => import('@/components/molecules/Skeleton.vue'),
  FlashMessages: () => import('@/components/molecules/FlashMessages.vue'),
  CookieConsent: () => import('@/components/molecules/CookieConsent.vue'),

  // Organisms - Forms
  CollaborationForm: () => import('@/components/organisms/CollaborationForm.vue'),
  MicrocreditForm: () => import('@/components/organisms/MicrocreditForm.vue'),
  ImpulsaProjectForm: () => import('@/components/organisms/ImpulsaProjectForm.vue'),
  ProposalForm: () => import('@/components/organisms/ProposalForm.vue'),
  ParticipationForm: () => import('@/components/organisms/ParticipationForm.vue'),

  // Organisms - Display
  VotingWidget: () => import('@/components/organisms/VotingWidget.vue'),
  VerificationSteps: () => import('@/components/organisms/VerificationSteps.vue'),
  VerificationStatus: () => import('@/components/organisms/VerificationStatus.vue'),
  SMSValidator: () => import('@/components/organisms/SMSValidator.vue'),
  ThemeSwitcher: () => import('@/components/organisms/ThemeSwitcher.vue'),
}

// Store for synchronously registered components
const registeredComponents: Record<string, Component> = {}

// Track mounted apps for cleanup
const mountedApps: Map<HTMLElement, App> = new Map()

// Shared Pinia instance
let sharedPinia: ReturnType<typeof createPinia> | null = null

function getPinia() {
  if (!sharedPinia) {
    sharedPinia = createPinia()
  }
  return sharedPinia
}

// ==========================================
// Component Registration
// ==========================================

/**
 * Register a Vue component synchronously
 */
export function registerComponent(name: string, component: Component) {
  registeredComponents[name] = component
}

/**
 * Register a component loader for async loading
 */
export function registerComponentLoader(name: string, loader: ComponentLoader) {
  componentLoaders[name] = loader
}

/**
 * Get a component by name (sync or async)
 */
function getComponent(name: string): Component | null {
  // Check sync registry first
  if (registeredComponents[name]) {
    return registeredComponents[name]
  }

  // Check async loaders
  if (componentLoaders[name]) {
    return defineAsyncComponent({
      loader: componentLoaders[name],
      loadingComponent: {
        template: '<div class="flex items-center justify-center p-4"><div class="spinner-md"></div></div>',
      },
      errorComponent: {
        template: '<div class="alert alert-error">Failed to load component</div>',
      },
      delay: 200,
      timeout: 10000,
    })
  }

  return null
}

// ==========================================
// Component Mounting
// ==========================================

/**
 * Mount a Vue component on a specific element
 * Used for Islands Architecture - mounting Vue components in ERB templates
 */
export function mountComponent(
  el: HTMLElement,
  componentName: string,
  props: Record<string, unknown> = {}
): App | null {
  // Cleanup existing app if re-mounting
  if (mountedApps.has(el)) {
    const existingApp = mountedApps.get(el)
    existingApp?.unmount()
    mountedApps.delete(el)
  }

  const component = getComponent(componentName)

  if (!component) {
    console.warn(`[Vue] Component "${componentName}" not found in registry`)
    return null
  }

  const app = createApp(component, props)
  app.use(getPinia())

  // Add global error handler
  app.config.errorHandler = (err, _instance, info) => {
    console.error(`[Vue Error] ${componentName}:`, err, info)
    // Dispatch event for error tracking
    window.dispatchEvent(
      new CustomEvent('vue:error', {
        detail: { component: componentName, error: err, info },
      })
    )
  }

  app.mount(el)
  mountedApps.set(el, app)

  return app
}

/**
 * Unmount a Vue app from an element
 */
export function unmountComponent(el: HTMLElement) {
  const app = mountedApps.get(el)
  if (app) {
    app.unmount()
    mountedApps.delete(el)
  }
}

/**
 * Auto-mount all Vue components on page
 */
function autoMountComponents() {
  const elements = document.querySelectorAll<HTMLElement>('[data-vue-component]')

  elements.forEach((el) => {
    // Skip if already mounted
    if (mountedApps.has(el)) return

    const componentName = el.getAttribute('data-vue-component')
    if (!componentName) return

    // Parse props from data attribute
    let props: Record<string, unknown> = {}
    const propsAttr = el.getAttribute('data-vue-props') || el.getAttribute('data-props')

    if (propsAttr) {
      try {
        props = JSON.parse(propsAttr)
      } catch (e) {
        console.error(`[Vue] Failed to parse props for ${componentName}:`, e)
      }
    }

    // Also collect data-* attributes as props
    Array.from(el.attributes).forEach((attr) => {
      if (attr.name.startsWith('data-prop-')) {
        const propName = attr.name
          .replace('data-prop-', '')
          .replace(/-([a-z])/g, (_, letter) => letter.toUpperCase())
        props[propName] = attr.value
      }
    })

    mountComponent(el, componentName, props)
  })
}

// ==========================================
// Legacy Bridge (jQuery/Vue Interop)
// ==========================================

interface LegacyBridge {
  // Event bus for jQuery <-> Vue communication
  emit: (event: string, data?: unknown) => void
  on: (event: string, handler: (data: unknown) => void) => void
  off: (event: string, handler?: (data: unknown) => void) => void

  // CSRF token helper
  getCsrfToken: () => string

  // Flash message helper
  showFlash: (type: 'success' | 'error' | 'warning' | 'info', message: string) => void

  // Mount component programmatically
  mount: typeof mountComponent
  unmount: typeof unmountComponent
}

// Event handlers storage
const eventHandlers: Map<string, Set<(data: unknown) => void>> = new Map()

export const legacyBridge: LegacyBridge = {
  emit(event: string, data?: unknown) {
    // Dispatch DOM event for jQuery listeners
    document.dispatchEvent(new CustomEvent(`vue:${event}`, { detail: data }))

    // Also call registered handlers
    const handlers = eventHandlers.get(event)
    if (handlers) {
      handlers.forEach((handler) => handler(data))
    }
  },

  on(event: string, handler: (data: unknown) => void) {
    if (!eventHandlers.has(event)) {
      eventHandlers.set(event, new Set())
    }
    eventHandlers.get(event)!.add(handler)

    // Also listen to DOM events from jQuery
    const domHandler = (e: Event) => handler((e as CustomEvent).detail)
    document.addEventListener(`jquery:${event}`, domHandler)

    return () => {
      eventHandlers.get(event)?.delete(handler)
      document.removeEventListener(`jquery:${event}`, domHandler)
    }
  },

  off(event: string, handler?: (data: unknown) => void) {
    if (handler) {
      eventHandlers.get(event)?.delete(handler)
    } else {
      eventHandlers.delete(event)
    }
  },

  getCsrfToken() {
    const meta = document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')
    return meta?.content || ''
  },

  showFlash(type, message) {
    document.dispatchEvent(
      new CustomEvent('flash:show', {
        detail: { type, message },
      })
    )
  },

  mount: mountComponent,
  unmount: unmountComponent,
}

// Expose to window for jQuery access
declare global {
  interface Window {
    VueBridge: LegacyBridge
    mountVueComponent: typeof mountComponent
    unmountVueComponent: typeof unmountComponent
  }
}

window.VueBridge = legacyBridge
window.mountVueComponent = mountComponent
window.unmountVueComponent = unmountComponent

// ==========================================
// Initialization
// ==========================================

// Auto-mount on DOMContentLoaded
document.addEventListener('DOMContentLoaded', () => {
  autoMountComponents()
})

// Re-mount on Turbo navigation (if using Turbo)
document.addEventListener('turbo:load', () => {
  autoMountComponents()
})

// Re-mount on custom navigation events
document.addEventListener('page:load', () => {
  autoMountComponents()
})

// Cleanup on Turbo cache
document.addEventListener('turbo:before-cache', () => {
  mountedApps.forEach((app, _el) => {
    app.unmount()
  })
  mountedApps.clear()
})

// Export for use in other files
export { createApp, createPinia, defineAsyncComponent }
export type { Component, App }
