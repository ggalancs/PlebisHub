/**
 * Main entry point for Vue 3 + Vite frontend
 * This file is loaded by vite_rails and initializes the Vue application
 */

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import type { Component } from 'vue'

// Import global styles
import './application.css'

// Store for registered components
const registeredComponents: Record<string, Component> = {}

/**
 * Register a Vue component globally
 * This allows components to be used throughout the application
 */
export function registerComponent(name: string, component: Component) {
  registeredComponents[name] = component
}

/**
 * Mount a Vue component on a specific element
 * Used for Islands Architecture - mounting Vue components in ERB templates
 */
export function mountComponent(
  el: HTMLElement,
  componentName: string,
  props: Record<string, unknown> = {}
) {
  const component = registeredComponents[componentName]

  if (!component) {
    console.error(`Component "${componentName}" not registered`)
    return
  }

  const app = createApp(component, props)
  const pinia = createPinia()

  app.use(pinia)
  app.mount(el)

  return app
}

/**
 * Auto-mount components on page load
 * Looks for elements with data-vue-component attribute
 */
document.addEventListener('DOMContentLoaded', () => {
  const elements = document.querySelectorAll('[data-vue-component]')

  elements.forEach((el) => {
    const componentName = el.getAttribute('data-vue-component')
    const propsAttr = el.getAttribute('data-vue-props')

    if (!componentName) return

    let props = {}
    if (propsAttr) {
      try {
        props = JSON.parse(propsAttr)
      } catch (e) {
        console.error('Failed to parse component props:', e)
      }
    }

    mountComponent(el as HTMLElement, componentName, props)
  })
})

// Export for use in other files
export { createApp, createPinia }
