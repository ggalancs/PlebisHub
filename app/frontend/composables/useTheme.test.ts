import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { nextTick } from 'vue'
import { useTheme, type Theme } from './useTheme'

describe('useTheme', () => {
  let localStorageMock: { [key: string]: string }

  beforeEach(() => {
    // Mock localStorage
    localStorageMock = {}
    global.localStorage = {
      getItem: vi.fn((key: string) => localStorageMock[key] || null),
      setItem: vi.fn((key: string, value: string) => {
        localStorageMock[key] = value
      }),
      removeItem: vi.fn((key: string) => {
        delete localStorageMock[key]
      }),
      clear: vi.fn(() => {
        localStorageMock = {}
      }),
      key: vi.fn(),
      length: 0,
    }

    // Mock document.documentElement
    global.document.documentElement = {
      style: {
        setProperty: vi.fn(),
      },
      classList: {
        add: vi.fn(),
        remove: vi.fn(),
      },
    } as any

    // Mock matchMedia
    global.matchMedia = vi.fn(() => ({
      matches: false,
      media: '',
      onchange: null,
      addListener: vi.fn(),
      removeListener: vi.fn(),
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })) as any
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  describe('initialization', () => {
    it('should initialize with default light theme', () => {
      const theme = useTheme()

      expect(theme.currentTheme.value).toBeTruthy()
      expect(theme.currentTheme.value?.id).toBe('default-light')
    })

    it('should have default themes available', () => {
      const theme = useTheme()

      expect(theme.themes.value).toHaveLength(2)
      expect(theme.themes.value.some((t) => t.id === 'default-light')).toBe(true)
      expect(theme.themes.value.some((t) => t.id === 'default-dark')).toBe(true)
    })

    it('should not be in dark mode by default', () => {
      const theme = useTheme()

      expect(theme.isDark.value).toBe(false)
    })

    it('should not be loading initially', () => {
      const theme = useTheme()

      expect(theme.isLoading.value).toBe(false)
    })

    it('should have colors from default theme', () => {
      const theme = useTheme()

      expect(theme.colors.value).toBeTruthy()
      expect(theme.colors.value.primary).toBe('#612d62')
      expect(theme.colors.value.secondary).toBe('#269283')
    })
  })

  describe('setTheme', () => {
    it('should switch to specified theme', () => {
      const theme = useTheme()

      theme.setTheme('default-dark')

      expect(theme.currentTheme.value?.id).toBe('default-dark')
    })

    it('should update colors when theme changes', async () => {
      const theme = useTheme()

      theme.setTheme('default-dark')
      await nextTick()

      expect(theme.colors.value.primary).toBe('#a855f7')
    })

    it('should do nothing for non-existent theme', () => {
      const theme = useTheme()
      const initialThemeId = theme.currentTheme.value?.id

      theme.setTheme('non-existent-theme')

      expect(theme.currentTheme.value?.id).toBe(initialThemeId)
    })

    it('should save theme to localStorage', () => {
      const theme = useTheme()

      theme.setTheme('default-dark')

      expect(localStorage.setItem).toHaveBeenCalledWith(
        'plebis-hub-theme',
        'default-dark'
      )
    })
  })

  describe('toggleDarkMode', () => {
    it('should toggle dark mode', () => {
      const theme = useTheme()
      const initialDark = theme.isDark.value

      theme.toggleDarkMode()

      expect(theme.isDark.value).toBe(!initialDark)
    })

    it('should switch to dark theme when enabling dark mode', () => {
      const theme = useTheme()

      theme.toggleDarkMode()

      expect(theme.currentTheme.value?.id).toBe('default-dark')
    })

    it('should switch to light theme when disabling dark mode', () => {
      const theme = useTheme()

      theme.toggleDarkMode() // Enable
      theme.toggleDarkMode() // Disable

      expect(theme.currentTheme.value?.id).toBe('default-light')
    })

    it('should save dark mode preference to localStorage', () => {
      const theme = useTheme()

      theme.toggleDarkMode()

      expect(localStorage.setItem).toHaveBeenCalledWith(
        'plebis-hub-dark-mode',
        expect.any(String)
      )
    })
  })

  describe('applyTheme', () => {
    it('should apply theme colors as CSS custom properties', () => {
      const theme = useTheme()
      const customTheme: Theme = {
        id: 'custom',
        name: 'Custom',
        colors: {
          primary: '#ff0000',
          secondary: '#00ff00',
        },
      }

      theme.applyTheme(customTheme)

      expect(document.documentElement.style.setProperty).toHaveBeenCalledWith(
        '--color-primary',
        '#ff0000'
      )
      expect(document.documentElement.style.setProperty).toHaveBeenCalledWith(
        '--color-secondary',
        '#00ff00'
      )
    })

    it('should apply RGB values for colors', () => {
      const theme = useTheme()
      const customTheme: Theme = {
        id: 'custom',
        name: 'Custom',
        colors: {
          primary: '#ff0000', // rgb(255, 0, 0)
        },
      }

      theme.applyTheme(customTheme)

      expect(document.documentElement.style.setProperty).toHaveBeenCalledWith(
        '--color-primary-rgb',
        '255, 0, 0'
      )
    })

    it('should apply font family if provided', () => {
      const theme = useTheme()
      const customTheme: Theme = {
        id: 'custom',
        name: 'Custom',
        colors: {},
        fontFamily: 'Arial, sans-serif',
      }

      theme.applyTheme(customTheme)

      expect(document.documentElement.style.setProperty).toHaveBeenCalledWith(
        '--font-family',
        'Arial, sans-serif'
      )
    })

    it('should apply border radius if provided', () => {
      const theme = useTheme()
      const customTheme: Theme = {
        id: 'custom',
        name: 'Custom',
        colors: {},
        borderRadius: '0.5rem',
      }

      theme.applyTheme(customTheme)

      expect(document.documentElement.style.setProperty).toHaveBeenCalledWith(
        '--border-radius',
        '0.5rem'
      )
    })

    it('should add dark class when in dark mode', () => {
      const theme = useTheme()

      theme.toggleDarkMode()
      theme.applyTheme(theme.currentTheme.value!)

      expect(document.documentElement.classList.add).toHaveBeenCalledWith('dark')
    })

    it('should remove dark class when not in dark mode', () => {
      const theme = useTheme()

      theme.applyTheme(theme.currentTheme.value!)

      expect(document.documentElement.classList.remove).toHaveBeenCalledWith('dark')
    })
  })

  describe('loadThemes', () => {
    it('should set loading state during load', async () => {
      const theme = useTheme()

      const loadPromise = theme.loadThemes()
      expect(theme.isLoading.value).toBe(true)

      await loadPromise
      expect(theme.isLoading.value).toBe(false)
    })

    it('should not crash on error', async () => {
      const theme = useTheme()

      // Mock console.error to avoid noise in tests
      const consoleError = vi.spyOn(console, 'error').mockImplementation(() => {})

      await expect(theme.loadThemes()).resolves.not.toThrow()

      consoleError.mockRestore()
    })
  })

  describe('getTheme', () => {
    it('should return theme by ID', () => {
      const theme = useTheme()

      const darkTheme = theme.getTheme('default-dark')

      expect(darkTheme).toBeTruthy()
      expect(darkTheme?.name).toBe('Dark')
    })

    it('should return undefined for non-existent theme', () => {
      const theme = useTheme()

      const nonExistent = theme.getTheme('non-existent')

      expect(nonExistent).toBeUndefined()
    })
  })

  describe('exportTheme', () => {
    it('should export current theme as JSON', () => {
      const theme = useTheme()

      const exported = theme.exportTheme()
      const parsed = JSON.parse(exported)

      expect(parsed.id).toBe('default-light')
      expect(parsed.name).toBe('Light')
      expect(parsed.colors).toBeTruthy()
    })

    it('should return empty object if no current theme', () => {
      const theme = useTheme()
      theme.currentTheme.value = null

      const exported = theme.exportTheme()

      expect(exported).toBe('{}')
    })
  })

  describe('importTheme', () => {
    it('should import valid theme JSON', () => {
      const theme = useTheme()
      const customTheme = {
        id: 'custom-imported',
        name: 'Custom Imported',
        colors: {
          primary: '#123456',
        },
      }

      const imported = theme.importTheme(JSON.stringify(customTheme))

      expect(imported).toBeTruthy()
      expect(imported?.id).toBe('custom-imported')
      expect(theme.themes.value).toContainEqual(customTheme)
    })

    it('should return null for invalid JSON', () => {
      const theme = useTheme()

      const imported = theme.importTheme('invalid json')

      expect(imported).toBeNull()
    })

    it('should return null for invalid theme structure', () => {
      const theme = useTheme()
      const invalid = { invalid: 'structure' }

      const consoleError = vi.spyOn(console, 'error').mockImplementation(() => {})
      const imported = theme.importTheme(JSON.stringify(invalid))

      expect(imported).toBeNull()
      consoleError.mockRestore()
    })

    it('should validate required theme properties', () => {
      const theme = useTheme()
      const incompleteTheme = {
        id: 'incomplete',
        // Missing name and colors
      }

      const consoleError = vi.spyOn(console, 'error').mockImplementation(() => {})
      const imported = theme.importTheme(JSON.stringify(incompleteTheme))

      expect(imported).toBeNull()
      consoleError.mockRestore()
    })
  })

  describe('colors computed property', () => {
    it('should return colors from current theme', () => {
      const theme = useTheme()

      expect(theme.colors.value.primary).toBe('#612d62')
    })

    it('should update when theme changes', async () => {
      const theme = useTheme()

      theme.setTheme('default-dark')
      await nextTick()

      expect(theme.colors.value.primary).toBe('#a855f7')
    })

    it('should return default colors if no current theme', () => {
      const theme = useTheme()
      theme.currentTheme.value = null

      expect(theme.colors.value.primary).toBe('#612d62')
    })
  })

  describe('isDark computed property', () => {
    it('should return true when dark theme is active', () => {
      const theme = useTheme()

      theme.setTheme('default-dark')

      expect(theme.isDark.value).toBe(true)
    })

    it('should return false when light theme is active', () => {
      const theme = useTheme()

      theme.setTheme('default-light')

      expect(theme.isDark.value).toBe(false)
    })
  })

  describe('localStorage persistence', () => {
    it('should restore theme from localStorage', () => {
      localStorageMock['plebis-hub-theme'] = 'default-dark'

      const theme = useTheme()

      expect(theme.currentTheme.value?.id).toBe('default-dark')
    })

    it('should restore dark mode preference from localStorage', () => {
      localStorageMock['plebis-hub-dark-mode'] = 'true'

      const theme = useTheme()

      expect(theme.isDark.value).toBe(true)
    })
  })

  describe('system color scheme', () => {
    it('should respect system color scheme when no saved preference', () => {
      global.matchMedia = vi.fn(() => ({
        matches: true, // Dark mode
        media: '',
        onchange: null,
        addListener: vi.fn(),
        removeListener: vi.fn(),
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        dispatchEvent: vi.fn(),
      })) as any

      const theme = useTheme()

      expect(theme.isDark.value).toBe(true)
    })

    it('should not override user preference with system preference', () => {
      localStorageMock['plebis-hub-dark-mode'] = 'false'

      global.matchMedia = vi.fn(() => ({
        matches: true, // System prefers dark
        media: '',
        onchange: null,
        addListener: vi.fn(),
        removeListener: vi.fn(),
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        dispatchEvent: vi.fn(),
      })) as any

      const theme = useTheme()

      // Should use user preference (false), not system preference (true)
      expect(theme.isDark.value).toBe(false)
    })
  })

  describe('edge cases', () => {
    it('should handle missing color values gracefully', () => {
      const theme = useTheme()
      const incompleteTheme: Theme = {
        id: 'incomplete',
        name: 'Incomplete',
        colors: {
          primary: '#ff0000',
          // other colors missing
        },
      }

      expect(() => theme.applyTheme(incompleteTheme)).not.toThrow()
    })

    it('should handle invalid hex colors gracefully', () => {
      const theme = useTheme()
      const invalidTheme: Theme = {
        id: 'invalid',
        name: 'Invalid',
        colors: {
          primary: 'not-a-color',
        },
      }

      expect(() => theme.applyTheme(invalidTheme)).not.toThrow()
    })
  })
})
