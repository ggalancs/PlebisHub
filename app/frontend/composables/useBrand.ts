import { ref, computed, watch } from 'vue'

export interface BrandColors {
  primary: string
  primaryLight: string
  primaryDark: string
  secondary: string
  secondaryLight: string
  secondaryDark: string
}

export interface BrandTheme {
  id: string
  name: string
  colors: BrandColors
  description?: string
}

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
const predefinedThemes: BrandTheme[] = [
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
]

// Reactive state
const currentTheme = ref<BrandTheme>(defaultTheme)
const customColors = ref<Partial<BrandColors> | null>(null)
const isLoading = ref(false)

/**
 * Composable for managing brand customization
 */
export function useBrand() {
  // Computed: current brand colors (custom or theme)
  const brandColors = computed<BrandColors>(() => {
    if (customColors.value) {
      return {
        ...currentTheme.value.colors,
        ...customColors.value,
      }
    }
    return currentTheme.value.colors
  })

  // Computed: is custom theme active
  const isCustomTheme = computed(() => customColors.value !== null)

  /**
   * Set a predefined theme
   */
  const setTheme = (themeId: string) => {
    const theme = predefinedThemes.find((t) => t.id === themeId)
    if (theme) {
      currentTheme.value = theme
      customColors.value = null
      applyBrandColors(theme.colors)
      saveBrandToStorage(theme)
    }
  }

  /**
   * Set custom colors
   */
  const setCustomColors = (colors: Partial<BrandColors>) => {
    customColors.value = {
      ...customColors.value,
      ...colors,
    }
    applyBrandColors(brandColors.value)
    saveBrandToStorage({ ...currentTheme.value, colors: brandColors.value })
  }

  /**
   * Reset to default theme
   */
  const resetToDefault = () => {
    currentTheme.value = defaultTheme
    customColors.value = null
    applyBrandColors(defaultTheme.colors)
    localStorage.removeItem('plebishub-brand')
  }

  /**
   * Apply brand colors to CSS custom properties
   */
  const applyBrandColors = (colors: BrandColors) => {
    const root = document.documentElement

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
  }

  /**
   * Save brand to localStorage
   */
  const saveBrandToStorage = (theme: BrandTheme) => {
    try {
      localStorage.setItem('plebishub-brand', JSON.stringify({
        themeId: theme.id,
        customColors: customColors.value,
      }))
    } catch (error) {
      console.error('Failed to save brand to localStorage:', error)
    }
  }

  /**
   * Load brand from localStorage
   */
  const loadBrandFromStorage = () => {
    try {
      const stored = localStorage.getItem('plebishub-brand')
      if (stored) {
        isLoading.value = true
        const data = JSON.parse(stored)

        if (data.themeId) {
          const theme = predefinedThemes.find((t) => t.id === data.themeId)
          if (theme) {
            currentTheme.value = theme
          }
        }

        if (data.customColors) {
          customColors.value = data.customColors
        }

        applyBrandColors(brandColors.value)
        isLoading.value = false
      }
    } catch (error) {
      console.error('Failed to load brand from localStorage:', error)
      isLoading.value = false
    }
  }

  /**
   * Export brand configuration as JSON
   */
  const exportBrandConfig = (): string => {
    return JSON.stringify({
      theme: currentTheme.value,
      customColors: customColors.value,
    }, null, 2)
  }

  /**
   * Import brand configuration from JSON
   */
  const importBrandConfig = (json: string): boolean => {
    try {
      const data = JSON.parse(json)

      if (data.theme) {
        currentTheme.value = data.theme
      }

      if (data.customColors) {
        customColors.value = data.customColors
      }

      applyBrandColors(brandColors.value)
      saveBrandToStorage(currentTheme.value)

      return true
    } catch (error) {
      console.error('Failed to import brand config:', error)
      return false
    }
  }

  /**
   * Validate color contrast for accessibility (WCAG AA)
   * Returns true if contrast ratio is >= 4.5:1
   */
  const validateColorContrast = (foreground: string, background: string): boolean => {
    const getLuminance = (hex: string): number => {
      const rgb = parseInt(hex.slice(1), 16)
      const r = (rgb >> 16) & 0xff
      const g = (rgb >> 8) & 0xff
      const b = (rgb >> 0) & 0xff

      const rsRGB = r / 255
      const gsRGB = g / 255
      const bsRGB = b / 255

      const rLinear = rsRGB <= 0.03928 ? rsRGB / 12.92 : Math.pow((rsRGB + 0.055) / 1.055, 2.4)
      const gLinear = gsRGB <= 0.03928 ? gsRGB / 12.92 : Math.pow((gsRGB + 0.055) / 1.055, 2.4)
      const bLinear = bsRGB <= 0.03928 ? bsRGB / 12.92 : Math.pow((bsRGB + 0.055) / 1.055, 2.4)

      return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear
    }

    const l1 = getLuminance(foreground)
    const l2 = getLuminance(background)
    const contrast = (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05)

    return contrast >= 4.5
  }

  // Watch for changes and apply
  watch(brandColors, (newColors) => {
    applyBrandColors(newColors)
  })

  return {
    // State
    currentTheme,
    brandColors,
    customColors,
    isCustomTheme,
    isLoading,
    predefinedThemes,

    // Methods
    setTheme,
    setCustomColors,
    resetToDefault,
    loadBrandFromStorage,
    exportBrandConfig,
    importBrandConfig,
    validateColorContrast,
  }
}
