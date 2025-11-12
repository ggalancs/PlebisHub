/**
 * SSR-safe utilities for accessing browser APIs
 */

/**
 * Check if code is running in browser
 */
export const isBrowser = typeof window !== 'undefined'

/**
 * Check if code is running on server
 */
export const isServer = !isBrowser

/**
 * SSR-safe localStorage wrapper
 */
export const safeLocalStorage = {
  getItem(key: string): string | null {
    if (!isBrowser) return null
    try {
      return localStorage.getItem(key)
    } catch (error) {
      console.warn(`Failed to get item from localStorage: ${key}`, error)
      return null
    }
  },

  setItem(key: string, value: string): boolean {
    if (!isBrowser) return false
    try {
      localStorage.setItem(key, value)
      return true
    } catch (error) {
      console.warn(`Failed to set item in localStorage: ${key}`, error)
      return false
    }
  },

  removeItem(key: string): boolean {
    if (!isBrowser) return false
    try {
      localStorage.removeItem(key)
      return true
    } catch (error) {
      console.warn(`Failed to remove item from localStorage: ${key}`, error)
      return false
    }
  },

  clear(): boolean {
    if (!isBrowser) return false
    try {
      localStorage.clear()
      return true
    } catch (error) {
      console.warn('Failed to clear localStorage', error)
      return false
    }
  },
}

/**
 * SSR-safe sessionStorage wrapper
 */
export const safeSessionStorage = {
  getItem(key: string): string | null {
    if (!isBrowser) return null
    try {
      return sessionStorage.getItem(key)
    } catch (error) {
      console.warn(`Failed to get item from sessionStorage: ${key}`, error)
      return null
    }
  },

  setItem(key: string, value: string): boolean {
    if (!isBrowser) return false
    try {
      sessionStorage.setItem(key, value)
      return true
    } catch (error) {
      console.warn(`Failed to set item in sessionStorage: ${key}`, error)
      return false
    }
  },

  removeItem(key: string): boolean {
    if (!isBrowser) return false
    try {
      sessionStorage.removeItem(key)
      return true
    } catch (error) {
      console.warn(`Failed to remove item from sessionStorage: ${key}`, error)
      return false
    }
  },

  clear(): boolean {
    if (!isBrowser) return false
    try {
      sessionStorage.clear()
      return true
    } catch (error) {
      console.warn('Failed to clear sessionStorage', error)
      return false
    }
  },
}

/**
 * SSR-safe document accessor
 */
export function getDocument(): Document | null {
  return isBrowser ? document : null
}

/**
 * SSR-safe window accessor
 */
export function getWindow(): Window | null {
  return isBrowser ? window : null
}

/**
 * SSR-safe document.documentElement accessor
 */
export function getDocumentElement(): HTMLElement | null {
  return isBrowser ? document.documentElement : null
}

/**
 * Execute callback only in browser
 * @param callback - Callback to execute
 * @param fallback - Optional fallback value for SSR
 */
export function onBrowser<T>(callback: () => T, fallback?: T): T | undefined {
  if (isBrowser) {
    return callback()
  }
  return fallback
}

/**
 * Execute callback only on server
 * @param callback - Callback to execute
 */
export function onServer<T>(callback: () => T): T | undefined {
  if (isServer) {
    return callback()
  }
  return undefined
}
