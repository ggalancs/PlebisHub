import { ref, computed, watch, onMounted, type Ref, type ComputedRef } from 'vue'

export interface ThemeColors {
  primary?: string
  secondary?: string
  success?: string
  warning?: string
  error?: string
  info?: string
  background?: string
  surface?: string
  text?: string
  textSecondary?: string
  border?: string
}

export interface Theme {
  id: string
  name: string
  colors: ThemeColors
  fontFamily?: string
  borderRadius?: string
  spacing?: string
}

/** API theme response structure */
interface ApiTheme {
  id?: string | number
  name: string
  colors?: {
    primary?: string
    secondary?: string
  }
  typography?: {
    fontPrimary?: string
  }
}

export interface UseThemeReturn {
  /** Current active theme */
  currentTheme: Ref<Theme | null>

  /** Available themes */
  themes: Ref<Theme[]>

  /** Current theme colors */
  colors: ComputedRef<ThemeColors>

  /** Whether dark mode is active */
  isDark: ComputedRef<boolean>

  /** Whether theme is loading */
  isLoading: Ref<boolean>

  /** Set active theme */
  setTheme: (themeId: string) => void

  /** Toggle between light and dark mode */
  toggleDarkMode: () => void

  /** Apply theme to DOM */
  applyTheme: (theme: Theme) => void

  /** Load themes from API */
  loadThemes: () => Promise<void>

  /** Get theme by ID */
  getTheme: (themeId: string) => Theme | undefined

  /** Export current theme as JSON */
  exportTheme: () => string

  /** Import theme from JSON */
  importTheme: (json: string) => Theme | null
}

// Default light theme
const defaultLightTheme: Theme = {
  id: 'default-light',
  name: 'Light',
  colors: {
    primary: '#612d62',
    secondary: '#269283',
    success: '#10b981',
    warning: '#f59e0b',
    error: '#ef4444',
    info: '#3b82f6',
    background: '#ffffff',
    surface: '#f3f4f6',
    text: '#1f2937',
    textSecondary: '#6b7280',
    border: '#e5e7eb',
  },
  fontFamily: 'Inter, system-ui, sans-serif',
  borderRadius: '0.375rem',
  spacing: '1rem',
}

// Default dark theme
const defaultDarkTheme: Theme = {
  id: 'default-dark',
  name: 'Dark',
  colors: {
    primary: '#a855f7',
    secondary: '#34d399',
    success: '#10b981',
    warning: '#f59e0b',
    error: '#ef4444',
    info: '#3b82f6',
    background: '#111827',
    surface: '#1f2937',
    text: '#f9fafb',
    textSecondary: '#d1d5db',
    border: '#374151',
  },
  fontFamily: 'Inter, system-ui, sans-serif',
  borderRadius: '0.375rem',
  spacing: '1rem',
}

// Storage keys
const THEME_STORAGE_KEY = 'plebis-hub-theme'
const DARK_MODE_STORAGE_KEY = 'plebis-hub-dark-mode'

/**
 * useTheme Composable
 *
 * Manages application theming with support for custom themes, dark mode, and persistence
 *
 * @returns Theme state and methods
 *
 * @example
 * ```ts
 * // In your app setup
 * const theme = useTheme()
 *
 * // Load themes from API
 * await theme.loadThemes()
 *
 * // Switch theme
 * theme.setTheme('corporate-blue')
 *
 * // Toggle dark mode
 * theme.toggleDarkMode()
 *
 * // Access current colors
 * const primaryColor = theme.colors.value.primary
 * ```
 *
 * @example
 * ```vue
 * <template>
 *   <div :style="{ backgroundColor: colors.background }">
 *     <button @click="toggleDarkMode">
 *       {{ isDark ? 'Light' : 'Dark' }} Mode
 *     </button>
 *     <select @change="setTheme($event.target.value)">
 *       <option v-for="t in themes" :key="t.id" :value="t.id">
 *         {{ t.name }}
 *       </option>
 *     </select>
 *   </div>
 * </template>
 *
 * <script setup>
 * import { useTheme } from '@/composables/useTheme'
 *
 * const { colors, isDark, themes, setTheme, toggleDarkMode } = useTheme()
 * </script>
 * ```
 */
export function useTheme(): UseThemeReturn {
  const currentTheme = ref<Theme | null>(null)
  const themes = ref<Theme[]>([defaultLightTheme, defaultDarkTheme])
  const isLoading = ref(false)
  const isDarkMode = ref(false)

  // Computed: current theme colors
  const colors = computed<ThemeColors>(() => {
    return currentTheme.value?.colors || defaultLightTheme.colors
  })

  // Computed: whether dark mode is active
  const isDark = computed(() => {
    return isDarkMode.value || currentTheme.value?.id === 'default-dark'
  })

  /**
   * Convert hex color to RGB values
   */
  const hexToRgb = (hex: string): { r: number; g: number; b: number } | null => {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    return result
      ? {
          r: parseInt(result[1], 16),
          g: parseInt(result[2], 16),
          b: parseInt(result[3], 16),
        }
      : null
  }

  /**
   * Apply theme to DOM by setting CSS custom properties
   */
  const applyTheme = (theme: Theme) => {
    const root = document.documentElement

    // Apply colors as CSS custom properties
    Object.entries(theme.colors).forEach(([key, value]) => {
      if (value) {
        root.style.setProperty(`--color-${key}`, value)

        // Also set RGB values for opacity support
        const rgb = hexToRgb(value)
        if (rgb) {
          root.style.setProperty(`--color-${key}-rgb`, `${rgb.r}, ${rgb.g}, ${rgb.b}`)
        }
      }
    })

    // Apply font family
    if (theme.fontFamily) {
      root.style.setProperty('--font-family', theme.fontFamily)
    }

    // Apply border radius
    if (theme.borderRadius) {
      root.style.setProperty('--border-radius', theme.borderRadius)
    }

    // Apply spacing
    if (theme.spacing) {
      root.style.setProperty('--spacing', theme.spacing)
    }

    // Update dark mode class
    if (isDark.value) {
      root.classList.add('dark')
    } else {
      root.classList.remove('dark')
    }

    // Save to localStorage
    localStorage.setItem(THEME_STORAGE_KEY, theme.id)
    localStorage.setItem(DARK_MODE_STORAGE_KEY, isDark.value.toString())
  }

  /**
   * Set active theme
   */
  const setTheme = (themeId: string) => {
    const theme = themes.value.find((t) => t.id === themeId)
    if (theme) {
      currentTheme.value = theme
      applyTheme(theme)
    }
  }

  /**
   * Toggle dark mode
   */
  const toggleDarkMode = () => {
    isDarkMode.value = !isDarkMode.value

    // Switch to dark/light default theme
    const targetThemeId = isDarkMode.value ? 'default-dark' : 'default-light'
    const targetTheme = themes.value.find((t) => t.id === targetThemeId)

    if (targetTheme) {
      currentTheme.value = targetTheme
      applyTheme(targetTheme)
    }
  }

  /**
   * Load themes from API
   */
  const loadThemes = async () => {
    isLoading.value = true

    try {
      const response = await fetch('/api/v1/themes')
      if (response.ok) {
        const data = await response.json()

        // Convert API themes to our Theme interface
        const apiThemes = (data as ApiTheme[]).map((apiTheme): Theme => ({
          id: `custom-${apiTheme.id || apiTheme.name}`,
          name: apiTheme.name,
          colors: {
            primary: apiTheme.colors?.primary,
            secondary: apiTheme.colors?.secondary,
            success: '#10b981',
            warning: '#f59e0b',
            error: '#ef4444',
            info: '#3b82f6',
            background: '#ffffff',
            surface: '#f3f4f6',
            text: '#1f2937',
            textSecondary: '#6b7280',
            border: '#e5e7eb',
          },
          fontFamily: apiTheme.typography?.fontPrimary ?
            `${apiTheme.typography.fontPrimary}, system-ui, sans-serif` :
            'Inter, system-ui, sans-serif',
        }))

        themes.value = [defaultLightTheme, defaultDarkTheme, ...apiThemes]
      }
    } catch (error) {
      console.error('Failed to load themes:', error)
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Get theme by ID
   */
  const getTheme = (themeId: string): Theme | undefined => {
    return themes.value.find((t) => t.id === themeId)
  }

  /**
   * Export current theme as JSON
   */
  const exportTheme = (): string => {
    if (!currentTheme.value) return '{}'
    return JSON.stringify(currentTheme.value, null, 2)
  }

  /**
   * Import theme from JSON
   */
  const importTheme = (json: string): Theme | null => {
    try {
      const theme = JSON.parse(json) as Theme

      // Validate theme structure
      if (!theme.id || !theme.name || !theme.colors) {
        console.error('Invalid theme structure')
        return null
      }

      // Add to themes list
      themes.value.push(theme)

      return theme
    } catch (error) {
      console.error('Failed to import theme:', error)
      return null
    }
  }

  /**
   * Initialize theme from localStorage or system preference
   */
  const initializeTheme = () => {
    // Check localStorage first
    const savedThemeId = localStorage.getItem(THEME_STORAGE_KEY)
    const savedDarkMode = localStorage.getItem(DARK_MODE_STORAGE_KEY)

    if (savedDarkMode !== null) {
      isDarkMode.value = savedDarkMode === 'true'
    } else {
      // Check system preference
      isDarkMode.value = window.matchMedia('(prefers-color-scheme: dark)').matches
    }

    if (savedThemeId) {
      const theme = getTheme(savedThemeId)
      if (theme) {
        currentTheme.value = theme
        applyTheme(theme)
        return
      }
    }

    // No saved theme, use default based on dark mode preference
    const defaultTheme = isDarkMode.value ? defaultDarkTheme : defaultLightTheme
    currentTheme.value = defaultTheme
    applyTheme(defaultTheme)
  }

  /**
   * Watch for system color scheme changes
   */
  const watchSystemColorScheme = () => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')

    const handler = (e: MediaQueryListEvent) => {
      // Only update if user hasn't manually set a preference
      if (localStorage.getItem(DARK_MODE_STORAGE_KEY) === null) {
        isDarkMode.value = e.matches
        toggleDarkMode()
      }
    }

    // Modern browsers
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener('change', handler)
    } else {
      // Fallback for older browsers
      mediaQuery.addListener(handler)
    }

    // Return cleanup function
    return () => {
      if (mediaQuery.removeEventListener) {
        mediaQuery.removeEventListener('change', handler)
      } else {
        mediaQuery.removeListener(handler)
      }
    }
  }

  // Initialize on mount
  onMounted(() => {
    initializeTheme()
    const cleanup = watchSystemColorScheme()

    // Cleanup on unmount (Vue automatically handles this)
    return cleanup
  })

  // Watch for theme changes
  watch(currentTheme, (newTheme) => {
    if (newTheme) {
      applyTheme(newTheme)
    }
  })

  return {
    currentTheme,
    themes,
    colors,
    isDark,
    isLoading,
    setTheme,
    toggleDarkMode,
    applyTheme,
    loadThemes,
    getTheme,
    exportTheme,
    importTheme,
  }
}
