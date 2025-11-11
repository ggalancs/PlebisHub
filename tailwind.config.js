/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './app/frontend/**/*.{vue,js,ts,jsx,tsx}',
    './app/views/**/*.{erb,haml,slim}',
    './engines/**/app/views/**/*.{erb,haml,slim}',
  ],
  theme: {
    extend: {
      colors: {
        // Primary color - Morado PlebisHub (#612d62)
        primary: {
          50: '#faf5fb',
          100: '#f4ebf6',
          200: '#ead7ee',
          300: '#dab9e0',
          400: '#c491cd',
          500: '#a96bb6',
          600: '#8a4f98',
          700: '#612d62', // Base color
          800: '#5a2a59',
          900: '#4c244a',
        },
        // Secondary color - Verde (#269283)
        secondary: {
          50: '#f0fdfa',
          100: '#ccfbf1',
          200: '#99f6e4',
          300: '#5eead4',
          400: '#2dd4bf',
          500: '#14b8a6',
          600: '#269283', // Base color
          700: '#0f766e',
          800: '#115e59',
          900: '#134e4a',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        heading: ['Montserrat', 'sans-serif'],
      },
      fontSize: {
        xs: ['12px', { lineHeight: '1.5' }],
        sm: ['14px', { lineHeight: '1.5' }],
        base: ['16px', { lineHeight: '1.5' }],
        lg: ['18px', { lineHeight: '1.5' }],
        xl: ['20px', { lineHeight: '1.4' }],
        '2xl': ['25px', { lineHeight: '1.3' }],
        '3xl': ['31px', { lineHeight: '1.2' }],
        '4xl': ['39px', { lineHeight: '1.1' }],
        '5xl': ['49px', { lineHeight: '1' }],
      },
      spacing: {
        // 8px base grid system
        0.5: '2px',
        1: '4px',
        2: '8px',
        3: '12px',
        4: '16px',
        5: '20px',
        6: '24px',
        8: '32px',
        10: '40px',
        12: '48px',
        16: '64px',
        20: '80px',
        24: '96px',
      },
      borderRadius: {
        DEFAULT: '8px',
        sm: '4px',
        md: '8px',
        lg: '12px',
        xl: '16px',
        '2xl': '24px',
      },
      boxShadow: {
        sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
        DEFAULT: '0 2px 8px 0 rgb(0 0 0 / 0.1)',
        md: '0 4px 12px 0 rgb(0 0 0 / 0.1)',
        lg: '0 8px 24px 0 rgb(0 0 0 / 0.1)',
        xl: '0 16px 48px 0 rgb(0 0 0 / 0.15)',
      },
    },
  },
  plugins: [],
}
