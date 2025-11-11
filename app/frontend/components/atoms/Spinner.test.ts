import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Spinner from './Spinner.vue'

describe('Spinner', () => {
  describe('rendering', () => {
    it('renders spinner element', () => {
      const wrapper = mount(Spinner)

      expect(wrapper.find('div[role="status"]').exists()).toBe(true)
      expect(wrapper.find('div[aria-hidden="true"]').exists()).toBe(true)
    })

    it('renders with default size', () => {
      const wrapper = mount(Spinner)

      const spinner = wrapper.find('div[aria-hidden="true"]')
      expect(spinner.classes()).toContain('h-8')
      expect(spinner.classes()).toContain('w-8')
    })

    it('renders with different sizes', () => {
      const sizes = ['xs', 'sm', 'md', 'lg', 'xl', '2xl'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Spinner, {
          props: { size },
        })

        const spinner = wrapper.find('div[aria-hidden="true"]')
        const expectedClass =
          size === 'xs'
            ? 'h-4'
            : size === 'sm'
              ? 'h-6'
              : size === 'md'
                ? 'h-8'
                : size === 'lg'
                  ? 'h-12'
                  : size === 'xl'
                    ? 'h-16'
                    : 'h-20'

        expect(spinner.classes()).toContain(expectedClass)
      })
    })

    it('renders with different variants', () => {
      const variants = [
        'primary',
        'secondary',
        'success',
        'danger',
        'warning',
        'info',
        'neutral',
        'white',
      ] as const

      variants.forEach((variant) => {
        const wrapper = mount(Spinner, {
          props: { variant },
        })

        const spinner = wrapper.find('div[aria-hidden="true"]')
        const expectedClass =
          variant === 'primary'
            ? 'border-primary-600'
            : variant === 'secondary'
              ? 'border-secondary-600'
              : variant === 'success'
                ? 'border-green-600'
                : variant === 'danger'
                  ? 'border-red-600'
                  : variant === 'warning'
                    ? 'border-yellow-500'
                    : variant === 'info'
                      ? 'border-blue-600'
                      : variant === 'neutral'
                        ? 'border-gray-600'
                        : 'border-white'

        expect(spinner.classes()).toContain(expectedClass)
      })
    })

    it('renders with loading text', () => {
      const wrapper = mount(Spinner, {
        props: { text: 'Loading data...' },
      })

      expect(wrapper.text()).toContain('Loading data...')
    })

    it('does not render text when not provided', () => {
      const wrapper = mount(Spinner)

      // Should only have sr-only text "Loading..."
      const visibleText = wrapper.find('span:not(.sr-only)')
      expect(visibleText.exists()).toBe(false)
    })

    it('renders with slot content', () => {
      const wrapper = mount(Spinner, {
        slots: {
          default: 'Please wait...',
        },
      })

      expect(wrapper.text()).toContain('Please wait...')
    })

    it('prioritizes slot over text prop', () => {
      const wrapper = mount(Spinner, {
        props: { text: 'Text from prop' },
        slots: {
          default: 'Custom loading text',
        },
      })

      const visibleText = wrapper.find('span:not(.sr-only)')
      expect(visibleText.text()).toContain('Custom loading text')
      expect(visibleText.text()).not.toContain('Text from prop')
    })

    it('has spinning animation class', () => {
      const wrapper = mount(Spinner)

      const spinner = wrapper.find('div[aria-hidden="true"]')
      expect(spinner.classes()).toContain('animate-spin')
    })

    it('has rounded circle classes', () => {
      const wrapper = mount(Spinner)

      const spinner = wrapper.find('div[aria-hidden="true"]')
      expect(spinner.classes()).toContain('rounded-full')
    })

    it('has border classes', () => {
      const wrapper = mount(Spinner)

      const spinner = wrapper.find('div[aria-hidden="true"]')
      expect(spinner.classes()).toContain('border-2')
      expect(spinner.classes()).toContain('border-solid')
      expect(spinner.classes()).toContain('border-t-transparent')
    })
  })

  describe('overlay mode', () => {
    it('renders with container overlay', () => {
      const wrapper = mount(Spinner, {
        props: { overlay: true, overlayType: 'container' },
      })

      const container = wrapper.find('div[role="status"]')
      expect(container.classes()).toContain('absolute')
      expect(container.classes()).toContain('inset-0')
      expect(container.classes()).toContain('bg-black/50')
      expect(container.classes()).toContain('backdrop-blur-sm')
    })

    it('renders with fullscreen overlay', () => {
      const wrapper = mount(Spinner, {
        props: { overlay: true, overlayType: 'fullscreen' },
      })

      const container = wrapper.find('div[role="status"]')
      expect(container.classes()).toContain('fixed')
      expect(container.classes()).toContain('inset-0')
    })

    it('renders without overlay by default', () => {
      const wrapper = mount(Spinner)

      const container = wrapper.find('div[role="status"]')
      expect(container.classes()).toContain('inline-flex')
      expect(container.classes()).not.toContain('absolute')
      expect(container.classes()).not.toContain('fixed')
    })

    it('renders white variant text in overlay mode', () => {
      const wrapper = mount(Spinner, {
        props: {
          overlay: true,
          text: 'Loading...',
        },
      })

      const text = wrapper.find('span:not(.sr-only)')
      expect(text.classes()).toContain('text-white')
    })
  })

  describe('accessibility', () => {
    it('has role="status"', () => {
      const wrapper = mount(Spinner)

      const container = wrapper.find('div[role="status"]')
      expect(container.exists()).toBe(true)
    })

    it('has aria-live="polite"', () => {
      const wrapper = mount(Spinner)

      const container = wrapper.find('div[role="status"]')
      expect(container.attributes('aria-live')).toBe('polite')
    })

    it('has aria-hidden on spinner', () => {
      const wrapper = mount(Spinner)

      const spinner = wrapper.find('div[aria-hidden="true"]')
      expect(spinner.exists()).toBe(true)
    })

    it('has screen reader only text', () => {
      const wrapper = mount(Spinner)

      const srText = wrapper.find('.sr-only')
      expect(srText.exists()).toBe(true)
      expect(srText.text()).toBe('Loading...')
    })
  })

  describe('text styling', () => {
    it('applies correct text size based on spinner size', () => {
      const sizes = ['xs', 'sm', 'md', 'lg', 'xl', '2xl'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Spinner, {
          props: { size, text: 'Loading' },
        })

        const text = wrapper.find('span:not(.sr-only)')
        const expectedClass =
          size === 'xs'
            ? 'text-xs'
            : size === 'sm'
              ? 'text-sm'
              : size === 'md'
                ? 'text-base'
                : size === 'lg'
                  ? 'text-lg'
                  : size === 'xl'
                    ? 'text-xl'
                    : 'text-2xl'

        expect(text.classes()).toContain(expectedClass)
      })
    })

    it('applies correct text color based on variant', () => {
      const variants = [
        { variant: 'primary' as const, class: 'text-primary-600' },
        { variant: 'secondary' as const, class: 'text-secondary-600' },
        { variant: 'success' as const, class: 'text-green-600' },
        { variant: 'danger' as const, class: 'text-red-600' },
        { variant: 'warning' as const, class: 'text-yellow-600' },
        { variant: 'info' as const, class: 'text-blue-600' },
        { variant: 'neutral' as const, class: 'text-gray-600' },
      ]

      variants.forEach(({ variant, class: expectedClass }) => {
        const wrapper = mount(Spinner, {
          props: { variant, text: 'Loading' },
        })

        const text = wrapper.find('span:not(.sr-only)')
        expect(text.classes()).toContain(expectedClass)
      })
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(Spinner, {
        props: {
          size: 'lg',
          variant: 'success',
          text: 'Processing...',
        },
      })

      const spinner = wrapper.find('div[aria-hidden="true"]')
      expect(spinner.classes()).toContain('h-12')
      expect(spinner.classes()).toContain('border-green-600')
      expect(wrapper.text()).toContain('Processing...')
    })

    it('renders overlay with text', () => {
      const wrapper = mount(Spinner, {
        props: {
          overlay: true,
          overlayType: 'fullscreen',
          size: 'xl',
          text: 'Loading application...',
        },
      })

      const container = wrapper.find('div[role="status"]')
      expect(container.classes()).toContain('fixed')
      expect(container.classes()).toContain('inset-0')
      expect(wrapper.text()).toContain('Loading application...')
    })
  })
})
