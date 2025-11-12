/**
 * Brand management composable
 * Refactored for better performance, SSR safety, and maintainability
 */

import { ref, computed, watch, readonly } from 'vue'
import type {
  BrandColors,
  BrandTheme,
  PartialBrandColors,
  BrandStorageData,
  BrandExportData,
  ContrastValidation,
  HexColor,
} from '@/types/brand'
import { BrandError, BrandErrorType } from '@/types/brand'
import { validateContrast, generateColorPalette, isValidHexColor } from '@/utils/color'
import { safeLocalStorage, getDocumentElement, isBrowser } from '@/utils/ssr'
import { debounce } from '@/utils/performance'

// Constants
const STORAGE_KEY = 'plebishub-brand'
const STORAGE_VERSION = '1.0.0'
const APPLY_COLORS_DEBOUNCE = 150 // ms

// Default PlebisHub brand theme
const defaultTheme: BrandTheme = {
  id: 'default',
  name: 'PlebisHub Default',
  description: 'Original PlebisHub brand colors',
  colors: {
    primary: '#612d62',
    primaryLight: '#8a4f98',
    primaryDark: '#4c244a',
    secondary: '#269283',
    secondaryLight: '#14b8a6',
    secondaryDark: '#0f766e',
  },
}

// Pre-defined brand themes
const predefinedThemes: readonly BrandTheme[] = [
  defaultTheme,
  {
    id: 'ocean',
    name: 'Ocean Blue',
    description: 'Cool blue tones',
    colors: {
      primary: '#1e40af',
      primaryLight: '#3b82f6',
      primaryDark: '#1e3a8a',
      secondary: '#0891b2',
      secondaryLight: '#06b6d4',
      secondaryDark: '#0e7490',
    },
  },
  {
    id: 'forest',
    name: 'Forest Green',
    description: 'Natural green palette',
    colors: {
      primary: '#15803d',
      primaryLight: '#22c55e',
      primaryDark: '#14532d',
      secondary: '#0d9488',
      secondaryLight: '#14b8a6',
      secondaryDark: '#115e59',
    },
  },
  {
    id: 'sunset',
    name: 'Sunset Orange',
    description: 'Warm orange and red tones',
    colors: {
      primary: '#c2410c',
      primaryLight: '#f97316',
      primaryDark: '#7c2d12',
      secondary: '#dc2626',
      secondaryLight: '#ef4444',
      secondaryDark: '#991b1b',
    },
  },
  {
    id: 'monochrome',
    name: 'Monochrome',
    description: 'Black and white',
    colors: {
      primary: '#1a1a1a',
      primaryLight: '#404040',
      primaryDark: '#000000',
      secondary: '#666666',
      secondaryLight: '#999999',
      secondaryDark: '#333333',
    },
  },
] as const

// Singleton state - ensures single source of truth
let instance: ReturnType<typeof createBrandComposable> | null = null

/**
 * Internal composable factory
 * Creates the actual composable logic
 */
function createBrandComposable() {
  // Reactive state
  const currentTheme = ref<BrandTheme>(defaultTheme)
  const customColors = ref<PartialBrandColors | null>(null)
  const isLoading = ref(false)
  const error = ref<BrandError | null>(null)

  // Computed: current brand colors (custom or theme)
  const brandColors = computed<BrandColors>(() => {
    if (customColors.value) {
      return {
        ...currentTheme.value.colors,
        ...customColors.value,
      } as BrandColors
    }
    return currentTheme.value.colors
  })

  // Computed: is custom theme active
  const isCustomTheme = computed(() => customColors.value !== null)

  /**
   * Apply brand colors to CSS custom properties
   * Debounced for performance
   */
  const applyBrandColorsToDOM = debounce((colors: BrandColors) => {
    const root = getDocumentElement()
    if (!root) return

    try {
      // Apply CSS variables
      root.style.setProperty('--brand-primary', colors.primary)
      root.style.setProperty('--brand-primary-light', colors.primaryLight)
      root.style.setProperty('--brand-primary-dark', colors.primaryDark)
      root.style.setProperty('--brand-secondary', colors.secondary)
      root.style.setProperty('--brand-secondary-light', colors.secondaryLight)
      root.style.setProperty('--brand-secondary-dark', colors.secondaryDark)

      // Also update Tailwind custom properties if they exist
      root.style.setProperty('--color-primary-700', colors.primary)
      root.style.setProperty('--color-primary-600', colors.primaryLight)
      root.style.setProperty('--color-primary-800', colors.primaryDark)
      root.style.setProperty('--color-secondary-600', colors.secondary)
      root.style.setProperty('--color-secondary-500', colors.secondaryLight)
      root.style.setProperty('--color-secondary-700', colors.secondaryDark)
    } catch (err) {
      error.value = new BrandError(
        BrandErrorType.VALIDATION_ERROR,
        'Failed to apply brand colors to DOM',
        err
      )
    }
  }, APPLY_COLORS_DEBOUNCE)

  /**
   * Validate and sanitize color object
   */
  function validateColors(colors: PartialBrandColors): boolean {
    const colorKeys = Object.keys(colors) as Array<keyof BrandColors>

    for (const key of colorKeys) {
      const color = colors[key]
      if (color && !isValidHexColor(color)) {
        error.value = new BrandError(
          BrandErrorType.INVALID_COLOR,
          `Invalid hex color for ${key}: ${color}`
        )
        return false
      }
    }

    return true
  }

  /**
   * Set a predefined theme
   */
  function setTheme(themeId: string): boolean {
    try {
      const theme = predefinedThemes.find((t) => t.id === themeId)
      if (!theme) {
        error.value = new BrandError(
          BrandErrorType.VALIDATION_ERROR,
          `Theme not found: ${themeId}`
        )
        return false
      }

      currentTheme.value = theme
      customColors.value = null
      applyBrandColorsToDOM(theme.colors)
      saveBrandToStorage(theme)
      error.value = null

      return true
    } catch (err) {
      error.value = new BrandError(
        BrandErrorType.VALIDATION_ERROR,
        'Failed to set theme',
        err
      )
      return false
    }
  }

  /**
   * Set custom colors
   */
  function setCustomColors(colors: PartialBrandColors): boolean {
    if (!validateColors(colors)) {
      return false
    }

    try {
      customColors.value = {
        ...customColors.value,
        ...colors,
      }

      applyBrandColorsToDOM(brandColors.value)
      saveBrandToStorage({ ...currentTheme.value, colors: brandColors.value })
      error.value = null

      return true
    } catch (err) {
      error.value = new BrandError(
        BrandErrorType.VALIDATION_ERROR,
        'Failed to set custom colors',
        err
      )
      return false
    }
  }

  /**
   * Generate color variants from a base color
   */
  function setColorWithVariants(
    type: 'primary' | 'secondary',
    baseColor: HexColor
  ): boolean {
    if (!isValidHexColor(baseColor)) {
      error.value = new BrandError(
        BrandErrorType.INVALID_COLOR,
        `Invalid hex color: ${baseColor}`
      )
      return false
    }

    try {
      const palette = generateColorPalette(baseColor)

      const colorUpdates: PartialBrandColors = {
        [type]: palette.primary,
        [`${type}Light`]: palette.primaryLight,
        [`${type}Dark`]: palette.primaryDark,
      } as PartialBrandColors

      return setCustomColors(colorUpdates)
    } catch (err) {
      error.value = new BrandError(
        BrandErrorType.VALIDATION_ERROR,
        'Failed to generate color variants',
        err
      )
      return false
    }
  }

  /**
   * Reset to default theme
   */
  function resetToDefault(): void {
    currentTheme.value = defaultTheme
    customColors.value = null
    applyBrandColorsToDOM(defaultTheme.colors)
    safeLocalStorage.removeItem(STORAGE_KEY)
    error.value = null
  }

  /**
   * Save brand to localStorage
   */
  function saveBrandToStorage(theme: BrandTheme): boolean {
    try {
      const data: BrandStorageData = {
        themeId: theme.id,
        customColors: customColors.value ?? undefined,
        timestamp: Date.now(),
      }

      const success = safeLocalStorage.setItem(STORAGE_KEY, JSON.stringify(data))

      if (!success) {
        error.value = new BrandError(
          BrandErrorType.STORAGE_ERROR,
          'Failed to save brand to localStorage'
        )
      }

      return success
    } catch (err) {
      error.value = new BrandError(
        BrandErrorType.STORAGE_ERROR,
        'Failed to save brand to localStorage',
        err
      )
      return false
    }
  }

  /**
   * Load brand from localStorage
   */
  function loadBrandFromStorage(): boolean {
    if (!isBrowser) return false

    try {
      isLoading.value = true
      const stored = safeLocalStorage.getItem(STORAGE_KEY)

      if (!stored) {
        isLoading.value = false
        return false
      }

      const data: BrandStorageData = JSON.parse(stored)

      if (data.themeId) {
        const theme = predefinedThemes.find((t) => t.id === data.themeId)
        if (theme) {
          currentTheme.value = theme
        }
      }

      if (data.customColors && validateColors(data.customColors)) {
        customColors.value = data.customColors
      }

      applyBrandColorsToDOM(brandColors.value)
      error.value = null
      isLoading.value = false

      return true
    } catch (err) {
      error.value = new BrandError(
        BrandErrorType.STORAGE_ERROR,
        'Failed to load brand from localStorage',
        err
      )
      isLoading.value = false
      return false
    }
  }

  /**
   * Export brand configuration as JSON
   */
  function exportBrandConfig(): string | null {
    try {
      const data: BrandExportData = {
        theme: currentTheme.value,
        customColors: customColors.value,
        version: STORAGE_VERSION,
        exportedAt: new Date().toISOString(),
      }

      return JSON.stringify(data, null, 2)
    } catch (err) {
      error.value = new BrandError(
        BrandErrorType.VALIDATION_ERROR,
        'Failed to export brand config',
        err
      )
      return null
    }
  }

  /**
   * Import brand configuration from JSON
   */
  function importBrandConfig(json: string): boolean {
    try {
      const data: BrandExportData = JSON.parse(json)

      // Validate data structure
      if (!data.theme || !data.theme.colors) {
        throw new Error('Invalid brand configuration format')
      }

      // Validate colors
      if (data.customColors && !validateColors(data.customColors)) {
        return false
      }

      currentTheme.value = data.theme
      customColors.value = data.customColors

      applyBrandColorsToDOM(brandColors.value)
      saveBrandToStorage(currentTheme.value)
      error.value = null

      return true
    } catch (err) {
      error.value = new BrandError(
        BrandErrorType.IMPORT_ERROR,
        'Failed to import brand config',
        err
      )
      return false
    }
  }

  /**
   * Validate color contrast (wrapper for utility function)
   */
  function validateColorContrast(
    foreground: HexColor,
    background: HexColor
  ): ContrastValidation | null {
    try {
      return validateContrast(foreground, background)
    } catch (err) {
      error.value = new BrandError(
        BrandErrorType.VALIDATION_ERROR,
        'Failed to validate contrast',
        err
      )
      return null
    }
  }

  /**
   * Clear any errors
   */
  function clearError(): void {
    error.value = null
  }

  // Watch for changes and apply
  watch(
    brandColors,
    (newColors) => {
      applyBrandColorsToDOM(newColors)
    },
    { immediate: false }
  )

  return {
    // State (readonly to prevent external mutation)
    currentTheme: readonly(currentTheme),
    brandColors: readonly(brandColors),
    customColors: readonly(customColors),
    isCustomTheme: readonly(isCustomTheme),
    isLoading: readonly(isLoading),
    error: readonly(error),
    predefinedThemes,

    // Methods
    setTheme,
    setCustomColors,
    setColorWithVariants,
    resetToDefault,
    loadBrandFromStorage,
    exportBrandConfig,
    importBrandConfig,
    validateColorContrast,
    clearError,
  }
}

/**
 * Use brand composable
 * Implements singleton pattern for global state
 */
export function useBrand() {
  if (!instance) {
    instance = createBrandComposable()
  }

  return instance
}

/**
 * Reset brand instance (useful for testing)
 */
export function resetBrandInstance(): void {
  instance = null
}
