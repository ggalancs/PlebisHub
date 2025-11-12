/**
 * ID generation utilities
 * SSR-safe and collision-resistant
 */

let idCounter = 0

/**
 * Generate a unique ID that works in SSR
 * Uses a counter instead of Math.random() to ensure consistency
 * @param prefix - Optional prefix for the ID
 * @returns Unique ID string
 */
export function generateId(prefix = 'id'): string {
  return `${prefix}-${++idCounter}`
}

/**
 * Generate a unique ID for a component instance
 * Combines prefix with timestamp and counter for better collision resistance
 * @param prefix - Optional prefix for the ID
 * @returns Unique ID string
 */
export function generateComponentId(prefix = 'component'): string {
  // Use timestamp in SSR-safe way
  const timestamp = typeof performance !== 'undefined' && performance.now
    ? Math.floor(performance.now())
    : Date.now()

  return `${prefix}-${timestamp}-${++idCounter}`
}

/**
 * Reset the ID counter (useful for testing)
 */
export function resetIdCounter(): void {
  idCounter = 0
}
