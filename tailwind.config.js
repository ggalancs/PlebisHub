/** @type {import('tailwindcss').Config} */
import plugin from 'tailwindcss/plugin'
import forms from '@tailwindcss/forms'
import typography from '@tailwindcss/typography'
import containerQueries from '@tailwindcss/container-queries'

export default {
  content: [
    './app/frontend/**/*.{vue,js,ts,jsx,tsx}',
    './app/views/**/*.{erb,haml,slim}',
    './engines/**/app/views/**/*.{erb,haml,slim}',
  ],

  // Enable dark mode via class strategy for manual toggle
  darkMode: 'class',

  theme: {
    // Container configuration
    container: {
      center: true,
      padding: {
        DEFAULT: '1rem',
        sm: '1.5rem',
        lg: '2rem',
      },
      screens: {
        sm: '640px',
        md: '768px',
        lg: '1024px',
        xl: '1280px',
        '2xl': '1400px',
      },
    },

    extend: {
      // ============================================
      // COLORS
      // ============================================
      colors: {
        // Brand colors - Primary (Morado/Purple)
        primary: {
          50: '#faf5fb',
          100: '#f4ebf6',
          200: '#ead7ee',
          300: '#dab9e0',
          400: '#c491cd',
          500: '#a96bb6',
          600: '#8a4f98',
          700: '#612d62', // Base brand color
          800: '#5a2a59',
          900: '#4c244a',
          950: '#3d1e3c',
          DEFAULT: '#612d62',
        },

        // Brand colors - Secondary (Verde/Green)
        secondary: {
          50: '#f0fdfa',
          100: '#ccfbf1',
          200: '#99f6e4',
          300: '#5eead4',
          400: '#2dd4bf',
          500: '#14b8a6',
          600: '#269283', // Base secondary color
          700: '#0f766e',
          800: '#115e59',
          900: '#134e4a',
          950: '#0d3d38',
          DEFAULT: '#269283',
        },

        // Semantic colors
        success: {
          light: '#dcfce7',
          DEFAULT: '#22c55e',
          dark: '#166534',
        },
        warning: {
          light: '#fef3c7',
          DEFAULT: '#f59e0b',
          dark: '#92400e',
        },
        error: {
          light: '#fee2e2',
          DEFAULT: '#ef4444',
          dark: '#991b1b',
        },
        info: {
          light: '#dbeafe',
          DEFAULT: '#3b82f6',
          dark: '#1e40af',
        },

        // Surface/Background semantic colors (for light/dark mode)
        surface: {
          DEFAULT: 'var(--surface-background)',
          foreground: 'var(--surface-foreground)',
          muted: 'var(--surface-muted)',
          'muted-foreground': 'var(--surface-muted-foreground)',
          card: 'var(--surface-card)',
          'card-hover': 'var(--surface-card-hover)',
        },
        border: {
          DEFAULT: 'var(--border-color)',
          hover: 'var(--border-hover)',
        },
      },

      // ============================================
      // TYPOGRAPHY
      // ============================================
      fontFamily: {
        sans: [
          'Inter Variable',
          'Inter',
          'system-ui',
          '-apple-system',
          'BlinkMacSystemFont',
          'Segoe UI',
          'Roboto',
          'sans-serif',
        ],
        heading: ['Montserrat', 'Inter Variable', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'SF Mono', 'Fira Code', 'Consolas', 'monospace'],
      },

      fontSize: {
        '2xs': ['0.625rem', { lineHeight: '1rem' }], // 10px
        xs: ['0.75rem', { lineHeight: '1rem' }], // 12px
        sm: ['0.875rem', { lineHeight: '1.25rem' }], // 14px
        base: ['1rem', { lineHeight: '1.5rem' }], // 16px
        lg: ['1.125rem', { lineHeight: '1.75rem' }], // 18px
        xl: ['1.25rem', { lineHeight: '1.75rem' }], // 20px
        '2xl': ['1.5rem', { lineHeight: '2rem' }], // 24px
        '3xl': ['1.875rem', { lineHeight: '2.25rem' }], // 30px
        '4xl': ['2.25rem', { lineHeight: '2.5rem' }], // 36px
        '5xl': ['3rem', { lineHeight: '1' }], // 48px
        '6xl': ['3.75rem', { lineHeight: '1' }], // 60px
        '7xl': ['4.5rem', { lineHeight: '1' }], // 72px
      },

      // ============================================
      // SPACING
      // ============================================
      spacing: {
        4.5: '1.125rem', // 18px
        5.5: '1.375rem', // 22px
        13: '3.25rem', // 52px
        15: '3.75rem', // 60px
        17: '4.25rem', // 68px
        18: '4.5rem', // 72px
        19: '4.75rem', // 76px
        21: '5.25rem', // 84px
        22: '5.5rem', // 88px
        26: '6.5rem', // 104px
        30: '7.5rem', // 120px
        34: '8.5rem', // 136px
        38: '9.5rem', // 152px
        42: '10.5rem', // 168px
        46: '11.5rem', // 184px
        50: '12.5rem', // 200px
        54: '13.5rem', // 216px
        58: '14.5rem', // 232px
        62: '15.5rem', // 248px
        66: '16.5rem', // 264px
        70: '17.5rem', // 280px
        74: '18.5rem', // 296px
        78: '19.5rem', // 312px
        82: '20.5rem', // 328px
        86: '21.5rem', // 344px
        90: '22.5rem', // 360px
        94: '23.5rem', // 376px
      },

      // ============================================
      // BORDERS & RADIUS
      // ============================================
      borderRadius: {
        DEFAULT: '0.375rem', // 6px
        sm: '0.125rem', // 2px
        md: '0.375rem', // 6px
        lg: '0.5rem', // 8px
        xl: '0.75rem', // 12px
        '2xl': '1rem', // 16px
        '3xl': '1.5rem', // 24px
      },

      borderWidth: {
        DEFAULT: '1px',
        0: '0',
        2: '2px',
        3: '3px',
        4: '4px',
        6: '6px',
        8: '8px',
      },

      // ============================================
      // SHADOWS
      // ============================================
      boxShadow: {
        xs: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
        sm: '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)',
        DEFAULT: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
        md: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
        lg: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
        xl: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)',
        '2xl': '0 25px 50px -12px rgb(0 0 0 / 0.25)',
        inner: 'inset 0 2px 4px 0 rgb(0 0 0 / 0.05)',
        none: 'none',
        // Glow effects for interactive elements
        'glow-primary': '0 0 15px rgb(97 45 98 / 0.35)',
        'glow-secondary': '0 0 15px rgb(38 146 131 / 0.35)',
        'glow-success': '0 0 15px rgb(34 197 94 / 0.35)',
        'glow-error': '0 0 15px rgb(239 68 68 / 0.35)',
        // Elevation shadows for cards
        'elevation-1': '0 1px 3px rgba(0, 0, 0, 0.12), 0 1px 2px rgba(0, 0, 0, 0.24)',
        'elevation-2': '0 3px 6px rgba(0, 0, 0, 0.15), 0 2px 4px rgba(0, 0, 0, 0.12)',
        'elevation-3': '0 10px 20px rgba(0, 0, 0, 0.15), 0 3px 6px rgba(0, 0, 0, 0.10)',
        'elevation-4': '0 15px 25px rgba(0, 0, 0, 0.15), 0 5px 10px rgba(0, 0, 0, 0.05)',
        'elevation-5': '0 20px 40px rgba(0, 0, 0, 0.2)',
      },

      // ============================================
      // TRANSITIONS & ANIMATIONS
      // ============================================
      transitionDuration: {
        DEFAULT: '200ms',
        0: '0ms',
        75: '75ms',
        100: '100ms',
        150: '150ms',
        200: '200ms',
        300: '300ms',
        400: '400ms',
        500: '500ms',
        700: '700ms',
        1000: '1000ms',
      },

      transitionTimingFunction: {
        DEFAULT: 'cubic-bezier(0.4, 0, 0.2, 1)',
        linear: 'linear',
        in: 'cubic-bezier(0.4, 0, 1, 1)',
        out: 'cubic-bezier(0, 0, 0.2, 1)',
        'in-out': 'cubic-bezier(0.4, 0, 0.2, 1)',
        bounce: 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
        spring: 'cubic-bezier(0.175, 0.885, 0.32, 1.275)',
      },

      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        fadeOut: {
          '0%': { opacity: '1' },
          '100%': { opacity: '0' },
        },
        slideInUp: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideInDown: {
          '0%': { opacity: '0', transform: 'translateY(-10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideInLeft: {
          '0%': { opacity: '0', transform: 'translateX(-10px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
        slideInRight: {
          '0%': { opacity: '0', transform: 'translateX(10px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
        slideOutUp: {
          '0%': { opacity: '1', transform: 'translateY(0)' },
          '100%': { opacity: '0', transform: 'translateY(-10px)' },
        },
        slideOutDown: {
          '0%': { opacity: '1', transform: 'translateY(0)' },
          '100%': { opacity: '0', transform: 'translateY(10px)' },
        },
        scaleIn: {
          '0%': { opacity: '0', transform: 'scale(0.95)' },
          '100%': { opacity: '1', transform: 'scale(1)' },
        },
        scaleOut: {
          '0%': { opacity: '1', transform: 'scale(1)' },
          '100%': { opacity: '0', transform: 'scale(0.95)' },
        },
        shimmer: {
          '0%': { backgroundPosition: '-200% 0' },
          '100%': { backgroundPosition: '200% 0' },
        },
        shake: {
          '0%, 100%': { transform: 'translateX(0)' },
          '10%, 30%, 50%, 70%, 90%': { transform: 'translateX(-4px)' },
          '20%, 40%, 60%, 80%': { transform: 'translateX(4px)' },
        },
        wiggle: {
          '0%, 100%': { transform: 'rotate(-3deg)' },
          '50%': { transform: 'rotate(3deg)' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-5px)' },
        },
        heartbeat: {
          '0%': { transform: 'scale(1)' },
          '14%': { transform: 'scale(1.1)' },
          '28%': { transform: 'scale(1)' },
          '42%': { transform: 'scale(1.1)' },
          '70%': { transform: 'scale(1)' },
        },
      },

      animation: {
        'fade-in': 'fadeIn 0.2s ease-out',
        'fade-out': 'fadeOut 0.2s ease-out',
        'slide-in-up': 'slideInUp 0.3s ease-out',
        'slide-in-down': 'slideInDown 0.3s ease-out',
        'slide-in-left': 'slideInLeft 0.3s ease-out',
        'slide-in-right': 'slideInRight 0.3s ease-out',
        'slide-out-up': 'slideOutUp 0.3s ease-out',
        'slide-out-down': 'slideOutDown 0.3s ease-out',
        'scale-in': 'scaleIn 0.2s ease-out',
        'scale-out': 'scaleOut 0.2s ease-out',
        shimmer: 'shimmer 2s linear infinite',
        shake: 'shake 0.5s ease-in-out',
        wiggle: 'wiggle 1s ease-in-out infinite',
        float: 'float 3s ease-in-out infinite',
        heartbeat: 'heartbeat 1.5s ease-in-out infinite',
      },

      // ============================================
      // Z-INDEX
      // ============================================
      zIndex: {
        behind: '-1',
        0: '0',
        10: '10',
        20: '20',
        30: '30',
        40: '40',
        50: '50',
        60: '60',
        70: '70',
        80: '80',
        90: '90',
        100: '100',
        dropdown: '10',
        sticky: '20',
        fixed: '30',
        overlay: '40',
        modal: '50',
        popover: '60',
        tooltip: '70',
        toast: '80',
        max: '9999',
      },

      // ============================================
      // ADDITIONAL UTILITIES
      // ============================================
      aspectRatio: {
        auto: 'auto',
        square: '1 / 1',
        video: '16 / 9',
        '4/3': '4 / 3',
        '3/2': '3 / 2',
        '2/3': '2 / 3',
        '9/16': '9 / 16',
      },

      backdropBlur: {
        xs: '2px',
      },

      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic': 'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
        'gradient-primary':
          'linear-gradient(135deg, var(--color-primary-600), var(--color-primary-800))',
        'gradient-secondary':
          'linear-gradient(135deg, var(--color-secondary-500), var(--color-secondary-700))',
        shimmer: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent)',
      },

      // Ring customizations for focus states
      ringWidth: {
        DEFAULT: '2px',
        0: '0px',
        1: '1px',
        2: '2px',
        4: '4px',
        8: '8px',
      },

      ringOffsetWidth: {
        0: '0px',
        1: '1px',
        2: '2px',
        4: '4px',
        8: '8px',
      },

      // Width/height utilities for common UI patterns
      maxWidth: {
        '8xl': '88rem', // 1408px
        '9xl': '96rem', // 1536px
        prose: '65ch',
        'screen-xs': '475px',
        'screen-sm': '640px',
        'screen-md': '768px',
        'screen-lg': '1024px',
        'screen-xl': '1280px',
        'screen-2xl': '1536px',
      },

      minHeight: {
        screen: '100vh',
        'screen-small': '100svh',
        'screen-dynamic': '100dvh',
      },

      // Typography plugin settings
      typography: (theme) => ({
        DEFAULT: {
          css: {
            '--tw-prose-body': theme('colors.gray.700'),
            '--tw-prose-headings': theme('colors.gray.900'),
            '--tw-prose-lead': theme('colors.gray.600'),
            '--tw-prose-links': theme('colors.primary.700'),
            '--tw-prose-bold': theme('colors.gray.900'),
            '--tw-prose-counters': theme('colors.gray.500'),
            '--tw-prose-bullets': theme('colors.gray.300'),
            '--tw-prose-hr': theme('colors.gray.200'),
            '--tw-prose-quotes': theme('colors.gray.900'),
            '--tw-prose-quote-borders': theme('colors.primary.500'),
            '--tw-prose-captions': theme('colors.gray.500'),
            '--tw-prose-code': theme('colors.gray.900'),
            '--tw-prose-pre-code': theme('colors.gray.200'),
            '--tw-prose-pre-bg': theme('colors.gray.800'),
            '--tw-prose-th-borders': theme('colors.gray.300'),
            '--tw-prose-td-borders': theme('colors.gray.200'),
            // Dark mode
            '--tw-prose-invert-body': theme('colors.gray.300'),
            '--tw-prose-invert-headings': theme('colors.white'),
            '--tw-prose-invert-lead': theme('colors.gray.400'),
            '--tw-prose-invert-links': theme('colors.primary.400'),
            '--tw-prose-invert-bold': theme('colors.white'),
            '--tw-prose-invert-counters': theme('colors.gray.400'),
            '--tw-prose-invert-bullets': theme('colors.gray.600'),
            '--tw-prose-invert-hr': theme('colors.gray.700'),
            '--tw-prose-invert-quotes': theme('colors.gray.100'),
            '--tw-prose-invert-quote-borders': theme('colors.primary.400'),
            '--tw-prose-invert-captions': theme('colors.gray.400'),
            '--tw-prose-invert-code': theme('colors.white'),
            '--tw-prose-invert-pre-code': theme('colors.gray.300'),
            '--tw-prose-invert-pre-bg': 'rgb(0 0 0 / 50%)',
            '--tw-prose-invert-th-borders': theme('colors.gray.600'),
            '--tw-prose-invert-td-borders': theme('colors.gray.700'),
            maxWidth: '65ch',
            a: {
              textDecoration: 'underline',
              textUnderlineOffset: '2px',
              '&:hover': {
                color: theme('colors.primary.600'),
              },
            },
            'h1, h2, h3, h4': {
              fontFamily: theme('fontFamily.heading').join(', '),
              fontWeight: '700',
            },
          },
        },
      }),
    },
  },

  // ============================================
  // PLUGINS
  // ============================================
  plugins: [
    // Forms plugin for better form styling
    forms({
      strategy: 'class', // Use class strategy to avoid conflicts
    }),

    // Typography plugin for prose content
    typography,

    // Container queries plugin
    containerQueries,

    // Custom plugin for additional utilities
    plugin(({ addUtilities, addComponents, addBase, theme }) => {
      // Base layer additions
      addBase({
        // Smooth scrolling
        html: {
          scrollBehavior: 'smooth',
        },
        // Better focus handling
        '*:focus-visible': {
          outline: `2px solid ${theme('colors.primary.500')}`,
          outlineOffset: '2px',
        },
        // Selection color
        '::selection': {
          backgroundColor: theme('colors.primary.200'),
          color: theme('colors.primary.900'),
        },
        // Dark mode selection
        '.dark ::selection': {
          backgroundColor: theme('colors.primary.800'),
          color: theme('colors.primary.100'),
        },
      })

      // Custom utilities
      addUtilities({
        // Text wrapping utilities
        '.text-balance': {
          textWrap: 'balance',
        },
        '.text-pretty': {
          textWrap: 'pretty',
        },

        // Hide scrollbar utilities
        '.scrollbar-hide': {
          '-ms-overflow-style': 'none',
          'scrollbar-width': 'none',
          '&::-webkit-scrollbar': {
            display: 'none',
          },
        },
        '.scrollbar-thin': {
          'scrollbar-width': 'thin',
          '&::-webkit-scrollbar': {
            width: '6px',
            height: '6px',
          },
        },

        // Custom scrollbar styling
        '.scrollbar-primary': {
          '&::-webkit-scrollbar-track': {
            backgroundColor: theme('colors.gray.100'),
            borderRadius: '9999px',
          },
          '&::-webkit-scrollbar-thumb': {
            backgroundColor: theme('colors.primary.400'),
            borderRadius: '9999px',
            '&:hover': {
              backgroundColor: theme('colors.primary.500'),
            },
          },
        },

        // Gradient text
        '.text-gradient-primary': {
          backgroundImage: `linear-gradient(135deg, ${theme('colors.primary.600')}, ${theme('colors.primary.400')})`,
          '-webkit-background-clip': 'text',
          'background-clip': 'text',
          '-webkit-text-fill-color': 'transparent',
        },
        '.text-gradient-secondary': {
          backgroundImage: `linear-gradient(135deg, ${theme('colors.secondary.600')}, ${theme('colors.secondary.400')})`,
          '-webkit-background-clip': 'text',
          'background-clip': 'text',
          '-webkit-text-fill-color': 'transparent',
        },

        // Drag utilities
        '.drag-none': {
          '-webkit-user-drag': 'none',
          'user-drag': 'none',
        },

        // Tap highlight
        '.tap-highlight-none': {
          '-webkit-tap-highlight-color': 'transparent',
        },

        // Backdrop utilities
        '.backdrop-blur-xs': {
          '--tw-backdrop-blur': 'blur(2px)',
          'backdrop-filter': 'var(--tw-backdrop-blur)',
        },

        // Focus ring utilities
        '.focus-ring': {
          '&:focus': {
            outline: 'none',
            boxShadow: `0 0 0 2px ${theme('colors.white')}, 0 0 0 4px ${theme('colors.primary.500')}`,
          },
        },
        '.focus-ring-inset': {
          '&:focus': {
            outline: 'none',
            boxShadow: `inset 0 0 0 2px ${theme('colors.primary.500')}`,
          },
        },

        // Skeleton loading
        '.skeleton': {
          backgroundColor: theme('colors.gray.200'),
          backgroundImage:
            'linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent)',
          backgroundSize: '200% 100%',
          animation: 'shimmer 2s linear infinite',
        },

        // Glass morphism
        '.glass': {
          backgroundColor: 'rgba(255, 255, 255, 0.7)',
          backdropFilter: 'blur(10px)',
          border: '1px solid rgba(255, 255, 255, 0.3)',
        },
        '.glass-dark': {
          backgroundColor: 'rgba(0, 0, 0, 0.5)',
          backdropFilter: 'blur(10px)',
          border: '1px solid rgba(255, 255, 255, 0.1)',
        },
      })

      // Component classes
      addComponents({
        // Skip link for accessibility
        '.skip-link': {
          position: 'absolute',
          top: '-40px',
          left: '0',
          background: theme('colors.primary.700'),
          color: theme('colors.white'),
          padding: '8px 16px',
          zIndex: '100',
          textDecoration: 'none',
          '&:focus': {
            top: '0',
          },
        },

        // Visually hidden (screen readers only)
        '.sr-only': {
          position: 'absolute',
          width: '1px',
          height: '1px',
          padding: '0',
          margin: '-1px',
          overflow: 'hidden',
          clip: 'rect(0, 0, 0, 0)',
          whiteSpace: 'nowrap',
          borderWidth: '0',
        },
        '.not-sr-only': {
          position: 'static',
          width: 'auto',
          height: 'auto',
          padding: '0',
          margin: '0',
          overflow: 'visible',
          clip: 'auto',
          whiteSpace: 'normal',
        },

        // Focus visible only (hide focus for mouse users)
        '.focus-visible-ring': {
          '&:focus': {
            outline: 'none',
          },
          '&:focus-visible': {
            outline: `2px solid ${theme('colors.primary.500')}`,
            outlineOffset: '2px',
          },
        },
      })
    }),
  ],

  // ============================================
  // SAFELIST - Classes that should never be purged
  // ============================================
  safelist: [
    // Dynamic color classes that might be generated
    { pattern: /^(bg|text|border|ring)-(primary|secondary|success|warning|error|info)/ },
    {
      pattern:
        /^(bg|text|border|ring)-(primary|secondary)-(50|100|200|300|400|500|600|700|800|900|950)/,
    },
    // Animation classes
    { pattern: /^animate-/ },
    // Grid columns
    { pattern: /^(col|row)-span-/ },
  ],

  // ============================================
  // FUTURE - Opt into upcoming features
  // ============================================
  future: {
    hoverOnlyWhenSupported: true,
  },
}
