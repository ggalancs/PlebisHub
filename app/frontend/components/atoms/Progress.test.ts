import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Progress from './Progress.vue'

describe('Progress', () => {
  describe('rendering', () => {
    it('renders progress bar', () => {
      const wrapper = mount(Progress)

      expect(wrapper.find('div[role="progressbar"]').exists()).toBe(true)
    })

    it('renders with default value of 0', () => {
      const wrapper = mount(Progress)

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.attributes('style')).toContain('width: 0%')
    })

    it('renders with specified value', () => {
      const wrapper = mount(Progress, {
        props: { value: 50 },
      })

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.attributes('style')).toContain('width: 50%')
    })

    it('renders with 100% when value equals max', () => {
      const wrapper = mount(Progress, {
        props: { value: 100, max: 100 },
      })

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.attributes('style')).toContain('width: 100%')
    })

    it('caps value at 100%', () => {
      const wrapper = mount(Progress, {
        props: { value: 150 },
      })

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.attributes('style')).toContain('width: 100%')
    })

    it('floors value at 0%', () => {
      const wrapper = mount(Progress, {
        props: { value: -10 },
      })

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.attributes('style')).toContain('width: 0%')
    })

    it('renders with different sizes', () => {
      const sizes = ['sm', 'md', 'lg'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Progress, {
          props: { size },
        })

        const container = wrapper.find('div[role="progressbar"]')
        const expectedClass = size === 'sm' ? 'h-2' : size === 'md' ? 'h-3' : 'h-4'

        expect(container.classes()).toContain(expectedClass)
      })
    })

    it('renders with different variants', () => {
      const variants = ['primary', 'secondary', 'success', 'danger', 'warning', 'info'] as const

      variants.forEach((variant) => {
        const wrapper = mount(Progress, {
          props: { variant, value: 50 },
        })

        const bar = wrapper.find('div[role="progressbar"] > div')
        const expectedClass =
          variant === 'primary'
            ? 'bg-primary-600'
            : variant === 'secondary'
              ? 'bg-secondary-600'
              : variant === 'success'
                ? 'bg-green-600'
                : variant === 'danger'
                  ? 'bg-red-600'
                  : variant === 'warning'
                    ? 'bg-yellow-500'
                    : 'bg-blue-600'

        expect(bar.classes()).toContain(expectedClass)
      })
    })

    it('does not show label by default', () => {
      const wrapper = mount(Progress, {
        props: { value: 50 },
      })

      expect(wrapper.find('.text-sm').exists()).toBe(false)
    })

    it('shows label when showLabel is true', () => {
      const wrapper = mount(Progress, {
        props: { value: 50, showLabel: true },
      })

      expect(wrapper.find('.text-sm').exists()).toBe(true)
      expect(wrapper.text()).toContain('50%')
    })

    it('shows custom label', () => {
      const wrapper = mount(Progress, {
        props: { value: 50, showLabel: true, label: 'Uploading...' },
      })

      expect(wrapper.text()).toContain('Uploading...')
      expect(wrapper.text()).not.toContain('50%')
    })

    it('renders with striped background', () => {
      const wrapper = mount(Progress, {
        props: { value: 50, striped: true },
      })

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.classes()).toContain('bg-striped')
    })

    it('renders with animated stripes', () => {
      const wrapper = mount(Progress, {
        props: { value: 50, animated: true },
      })

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.classes()).toContain('bg-striped')
      expect(bar.classes()).toContain('animate-stripes')
    })

    it('renders in indeterminate state', () => {
      const wrapper = mount(Progress, {
        props: { indeterminate: true },
      })

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.classes()).toContain('animate-indeterminate')
      expect(bar.attributes('style')).toContain('width: 30%')
    })

    it('shows "Loading..." in indeterminate state with label', () => {
      const wrapper = mount(Progress, {
        props: { indeterminate: true, showLabel: true },
      })

      expect(wrapper.text()).toContain('Loading...')
    })

    it('has rounded container', () => {
      const wrapper = mount(Progress)

      const container = wrapper.find('div[role="progressbar"]')
      expect(container.classes()).toContain('rounded-full')
    })

    it('has transition classes on bar', () => {
      const wrapper = mount(Progress, {
        props: { value: 50 },
      })

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.classes()).toContain('transition-all')
      expect(bar.classes()).toContain('duration-300')
    })
  })

  describe('accessibility', () => {
    it('has role="progressbar"', () => {
      const wrapper = mount(Progress)

      expect(wrapper.find('div[role="progressbar"]').exists()).toBe(true)
    })

    it('has aria-valuenow attribute', () => {
      const wrapper = mount(Progress, {
        props: { value: 50 },
      })

      const container = wrapper.find('div[role="progressbar"]')
      expect(container.attributes('aria-valuenow')).toBe('50')
    })

    it('has aria-valuemin attribute', () => {
      const wrapper = mount(Progress, {
        props: { value: 50 },
      })

      const container = wrapper.find('div[role="progressbar"]')
      expect(container.attributes('aria-valuemin')).toBe('0')
    })

    it('has aria-valuemax attribute', () => {
      const wrapper = mount(Progress, {
        props: { value: 50, max: 100 },
      })

      const container = wrapper.find('div[role="progressbar"]')
      expect(container.attributes('aria-valuemax')).toBe('100')
    })

    it('updates aria-valuenow when value changes', async () => {
      const wrapper = mount(Progress, {
        props: { value: 30 },
      })

      await wrapper.setProps({ value: 70 })

      const container = wrapper.find('div[role="progressbar"]')
      expect(container.attributes('aria-valuenow')).toBe('70')
    })
  })

  describe('custom max value', () => {
    it('calculates percentage with custom max', () => {
      const wrapper = mount(Progress, {
        props: { value: 50, max: 200 },
      })

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.attributes('style')).toContain('width: 25%')
    })

    it('shows correct percentage label with custom max', () => {
      const wrapper = mount(Progress, {
        props: { value: 50, max: 200, showLabel: true },
      })

      expect(wrapper.text()).toContain('25%')
    })

    it('caps at 100% with custom max when value exceeds', () => {
      const wrapper = mount(Progress, {
        props: { value: 300, max: 200 },
      })

      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.attributes('style')).toContain('width: 100%')
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(Progress, {
        props: {
          value: 75,
          variant: 'success',
          size: 'lg',
          showLabel: true,
          striped: true,
          animated: true,
        },
      })

      const container = wrapper.find('div[role="progressbar"]')
      const bar = wrapper.find('div[role="progressbar"] > div')

      expect(container.classes()).toContain('h-4')
      expect(bar.classes()).toContain('bg-green-600')
      expect(bar.classes()).toContain('bg-striped')
      expect(bar.classes()).toContain('animate-stripes')
      expect(bar.attributes('style')).toContain('width: 75%')
      expect(wrapper.text()).toContain('75%')
    })

    it('renders indeterminate with custom label', () => {
      const wrapper = mount(Progress, {
        props: {
          indeterminate: true,
          showLabel: true,
          label: 'Processing...',
        },
      })

      expect(wrapper.text()).toContain('Processing...')
      expect(wrapper.find('div[role="progressbar"] > div').classes()).toContain(
        'animate-indeterminate'
      )
    })
  })

  describe('edge cases', () => {
    it('handles value of 0', () => {
      const wrapper = mount(Progress, {
        props: { value: 0, showLabel: true },
      })

      expect(wrapper.text()).toContain('0%')
      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.attributes('style')).toContain('width: 0%')
    })

    it('handles value of 100', () => {
      const wrapper = mount(Progress, {
        props: { value: 100, showLabel: true },
      })

      expect(wrapper.text()).toContain('100%')
      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.attributes('style')).toContain('width: 100%')
    })

    it('handles fractional values', () => {
      const wrapper = mount(Progress, {
        props: { value: 33.33, showLabel: true },
      })

      expect(wrapper.text()).toContain('33%')
      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.attributes('style')).toContain('width: 33.33%')
    })

    it('handles max of 0 gracefully', () => {
      const wrapper = mount(Progress, {
        props: { value: 50, max: 0 },
      })

      // Should handle division by zero
      const bar = wrapper.find('div[role="progressbar"] > div')
      expect(bar.exists()).toBe(true)
    })
  })
})
