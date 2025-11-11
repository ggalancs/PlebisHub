import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Button from './Button.vue'

describe('Button', () => {
  describe('rendering', () => {
    it('renders with default props', () => {
      const wrapper = mount(Button, {
        slots: {
          default: 'Click me',
        },
      })

      expect(wrapper.text()).toBe('Click me')
      expect(wrapper.find('button').exists()).toBe(true)
    })

    it('renders with different variants', () => {
      const variants = ['primary', 'secondary', 'ghost', 'danger', 'success'] as const

      variants.forEach((variant) => {
        const wrapper = mount(Button, {
          props: { variant },
          slots: { default: 'Button' },
        })

        const button = wrapper.find('button')
        expect(button.classes()).toContain(
          variant === 'primary'
            ? 'bg-primary-700'
            : variant === 'secondary'
              ? 'bg-secondary-600'
              : variant === 'ghost'
                ? 'bg-transparent'
                : variant === 'danger'
                  ? 'bg-red-600'
                  : 'bg-green-600'
        )
      })
    })

    it('renders with different sizes', () => {
      const sizes = ['sm', 'md', 'lg'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Button, {
          props: { size },
          slots: { default: 'Button' },
        })

        const button = wrapper.find('button')
        expect(button.classes()).toContain(
          size === 'sm' ? 'text-sm' : size === 'md' ? 'text-base' : 'text-lg'
        )
      })
    })

    it('renders full width when fullWidth prop is true', () => {
      const wrapper = mount(Button, {
        props: { fullWidth: true },
        slots: { default: 'Button' },
      })

      expect(wrapper.find('button').classes()).toContain('w-full')
    })

    it('shows loading spinner when loading prop is true', () => {
      const wrapper = mount(Button, {
        props: { loading: true },
        slots: { default: 'Button' },
      })

      expect(wrapper.find('svg').exists()).toBe(true)
      expect(wrapper.find('svg').classes()).toContain('animate-spin')
    })
  })

  describe('behavior', () => {
    it('emits click event when clicked', async () => {
      const wrapper = mount(Button, {
        slots: { default: 'Click me' },
      })

      await wrapper.find('button').trigger('click')
      expect(wrapper.emitted('click')).toBeTruthy()
      expect(wrapper.emitted('click')?.[0]).toBeDefined()
    })

    it('does not emit click when disabled', async () => {
      const wrapper = mount(Button, {
        props: { disabled: true },
        slots: { default: 'Disabled' },
      })

      await wrapper.find('button').trigger('click')
      expect(wrapper.emitted('click')).toBeFalsy()
    })

    it('does not emit click when loading', async () => {
      const wrapper = mount(Button, {
        props: { loading: true },
        slots: { default: 'Loading' },
      })

      await wrapper.find('button').trigger('click')
      expect(wrapper.emitted('click')).toBeFalsy()
    })

    it('has correct button type', () => {
      const types = ['button', 'submit', 'reset'] as const

      types.forEach((type) => {
        const wrapper = mount(Button, {
          props: { type },
          slots: { default: 'Button' },
        })

        expect(wrapper.find('button').attributes('type')).toBe(type)
      })
    })
  })

  describe('accessibility', () => {
    it('has disabled attribute when disabled', () => {
      const wrapper = mount(Button, {
        props: { disabled: true },
        slots: { default: 'Disabled' },
      })

      expect(wrapper.find('button').attributes('disabled')).toBeDefined()
    })

    it('has disabled attribute when loading', () => {
      const wrapper = mount(Button, {
        props: { loading: true },
        slots: { default: 'Loading' },
      })

      expect(wrapper.find('button').attributes('disabled')).toBeDefined()
    })

    it('applies correct icon-only styles', () => {
      const wrapper = mount(Button, {
        props: { iconOnly: true, size: 'md' },
        slots: { default: '🔍' },
      })

      expect(wrapper.find('button').classes()).toContain('p-2.5')
      expect(wrapper.find('button').classes()).not.toContain('px-4')
    })
  })
})
