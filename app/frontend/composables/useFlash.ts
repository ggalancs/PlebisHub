/**
 * Flash Messages Composable
 * Replaces jQuery flash message handling with Vue reactive system
 */

import { ref, readonly, onMounted, onUnmounted } from 'vue'

export type FlashType = 'success' | 'error' | 'warning' | 'info'

export interface FlashMessage {
  id: number
  type: FlashType
  message: string
  title?: string
  dismissible?: boolean
  duration?: number
}

// Global message store (shared across components)
const messages = ref<FlashMessage[]>([])
let messageId = 0

// Default auto-dismiss duration in ms
const DEFAULT_DURATION = 5000

/**
 * Add a flash message
 */
export function addFlash(
  type: FlashType,
  message: string,
  options: {
    title?: string
    dismissible?: boolean
    duration?: number | null
  } = {}
): number {
  const id = ++messageId
  const duration = options.duration === null ? null : (options.duration ?? DEFAULT_DURATION)

  messages.value.push({
    id,
    type,
    message,
    title: options.title,
    dismissible: options.dismissible ?? true,
    duration: duration ?? undefined,
  })

  // Auto-dismiss after duration
  if (duration) {
    setTimeout(() => {
      removeFlash(id)
    }, duration)
  }

  return id
}

/**
 * Remove a flash message by ID
 */
export function removeFlash(id: number): void {
  const index = messages.value.findIndex((m) => m.id === id)
  if (index !== -1) {
    messages.value.splice(index, 1)
  }
}

/**
 * Clear all flash messages
 */
export function clearFlashes(): void {
  messages.value = []
}

/**
 * Flash message composable
 */
export function useFlash() {
  // Listen for flash events from legacy code
  const handleFlashEvent = (e: Event) => {
    const { type, message, title, duration } = (e as CustomEvent).detail || {}
    if (type && message) {
      addFlash(type, message, { title, duration })
    }
  }

  onMounted(() => {
    // Listen for custom flash events
    document.addEventListener('flash:show', handleFlashEvent)

    // Load initial flash messages from Rails (if present in DOM)
    const flashContainer = document.querySelector('[data-flash-messages]')
    if (flashContainer) {
      try {
        const initialMessages = JSON.parse(
          flashContainer.getAttribute('data-flash-messages') || '[]'
        )
        initialMessages.forEach(
          ({ type, message, title }: { type: FlashType; message: string; title?: string }) => {
            addFlash(type, message, { title })
          }
        )
      } catch (e) {
        console.error('[useFlash] Failed to parse initial messages:', e)
      }
    }
  })

  onUnmounted(() => {
    document.removeEventListener('flash:show', handleFlashEvent)
  })

  return {
    messages: readonly(messages),
    add: addFlash,
    remove: removeFlash,
    clear: clearFlashes,

    // Convenience methods
    success: (message: string, options?: { title?: string; duration?: number }) =>
      addFlash('success', message, options),
    error: (message: string, options?: { title?: string; duration?: number }) =>
      addFlash('error', message, options),
    warning: (message: string, options?: { title?: string; duration?: number }) =>
      addFlash('warning', message, options),
    info: (message: string, options?: { title?: string; duration?: number }) =>
      addFlash('info', message, options),
  }
}

// Export for direct use
export { messages as flashMessages }
