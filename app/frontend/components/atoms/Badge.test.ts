import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Badge from './Badge.vue'

describe('Badge', () => {
  describe('rendering', () => {
    it('renders badge with content', () => {
      const wrapper = mount(Badge, {
        slots: { default: 'New' },
      })

      expect(wrapper.text()).toBe('New')
      expect(wrapper.find('span').exists()).toBe(true)
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
      ] as const

      variants.forEach((variant) => {
        const wrapper = mount(Badge, {
          props: { variant },
          slots: { default: 'Badge' },
        })

        const badge = wrapper.find('span')
        const expectedClass =
          variant === 'primary'
            ? 'bg-primary-100'
            : variant === 'secondary'
              ? 'bg-secondary-100'
              : variant === 'success'
                ? 'bg-green-100'
                : variant === 'danger'
                  ? 'bg-red-100'
                  : variant === 'warning'
                    ? 'bg-yellow-100'
                    : variant === 'info'
                      ? 'bg-blue-100'
                      : 'bg-gray-100'

        expect(badge.classes()).toContain(expectedClass)
      })
    })

    it('renders with different sizes', () => {
      const sizes = ['sm', 'md', 'lg'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Badge, {
          props: { size },
          slots: { default: 'Badge' },
        })

        const badge = wrapper.find('span')
        expect(badge.classes()).toContain(
          size === 'sm' ? 'text-xs' : size === 'md' ? 'text-sm' : 'text-base'
        )
      })
    })

    it('renders with dot indicator', () => {
      const wrapper = mount(Badge, {
        props: { dot: true },
        slots: { default: 'Badge' },
      })

      const dot = wrapper.find('span > span')
      expect(dot.exists()).toBe(true)
      expect(dot.classes()).toContain('rounded-full')
    })

    it('renders with pill shape', () => {
      const wrapper = mount(Badge, {
        props: { pill: true },
        slots: { default: 'Badge' },
      })

      const badge = wrapper.find('span')
      expect(badge.classes()).toContain('rounded-full')
    })

    it('renders with rounded corners by default', () => {
      const wrapper = mount(Badge, {
        props: { pill: false },
        slots: { default: 'Badge' },
      })

      const badge = wrapper.find('span')
      expect(badge.classes()).toContain('rounded-md')
    })

    it('renders with remove button when removable', () => {
      const wrapper = mount(Badge, {
        props: { removable: true },
        slots: { default: 'Badge' },
      })

      const removeButton = wrapper.find('button')
      expect(removeButton.exists()).toBe(true)
      expect(removeButton.attributes('aria-label')).toBe('Remove')
    })

    it('does not render remove button by default', () => {
      const wrapper = mount(Badge, {
        slots: { default: 'Badge' },
      })

      expect(wrapper.find('button').exists()).toBe(false)
    })
  })

  describe('behavior', () => {
    it('emits remove event when close button is clicked', async () => {
      const wrapper = mount(Badge, {
        props: { removable: true },
        slots: { default: 'Badge' },
      })

      await wrapper.find('button').trigger('click')

      expect(wrapper.emitted('remove')).toBeTruthy()
      expect(wrapper.emitted('remove')).toHaveLength(1)
    })

    it('does not emit remove event when not removable', async () => {
      const wrapper = mount(Badge, {
        props: { removable: false },
        slots: { default: 'Badge' },
      })

      // No button should exist
      expect(wrapper.find('button').exists()).toBe(false)
    })
  })

  describe('combinations', () => {
    it('renders with dot and removable', () => {
      const wrapper = mount(Badge, {
        props: { dot: true, removable: true },
        slots: { default: 'Badge' },
      })

      expect(wrapper.find('span > span').exists()).toBe(true) // Dot
      expect(wrapper.find('button').exists()).toBe(true) // Remove button
    })

    it('renders with dot and pill shape', () => {
      const wrapper = mount(Badge, {
        props: { dot: true, pill: true },
        slots: { default: 'Badge' },
      })

      const badge = wrapper.find('span')
      expect(badge.classes()).toContain('rounded-full')
      expect(wrapper.find('span > span').exists()).toBe(true) // Dot
    })

    it('renders all features together', () => {
      const wrapper = mount(Badge, {
        props: {
          variant: 'success',
          size: 'lg',
          dot: true,
          pill: true,
          removable: true,
        },
        slots: { default: 'Complete' },
      })

      const badge = wrapper.find('span')
      expect(badge.classes()).toContain('bg-green-100')
      expect(badge.classes()).toContain('text-base')
      expect(badge.classes()).toContain('rounded-full')
      expect(wrapper.find('span > span').exists()).toBe(true) // Dot
      expect(wrapper.find('button').exists()).toBe(true) // Remove button
    })
  })

  describe('dot indicator variants', () => {
    it('renders dot with correct variant colors', () => {
      const variants = [
        { variant: 'primary' as const, class: 'bg-primary-600' },
        { variant: 'secondary' as const, class: 'bg-secondary-600' },
        { variant: 'success' as const, class: 'bg-green-600' },
        { variant: 'danger' as const, class: 'bg-red-600' },
        { variant: 'warning' as const, class: 'bg-yellow-600' },
        { variant: 'info' as const, class: 'bg-blue-600' },
        { variant: 'neutral' as const, class: 'bg-gray-600' },
      ]

      variants.forEach(({ variant, class: expectedClass }) => {
        const wrapper = mount(Badge, {
          props: { variant, dot: true },
          slots: { default: 'Badge' },
        })

        const dot = wrapper.find('span > span')
        expect(dot.classes()).toContain(expectedClass)
      })
    })

    it('renders dot with correct sizes', () => {
      const sizes = ['sm', 'md', 'lg'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Badge, {
          props: { size, dot: true },
          slots: { default: 'Badge' },
        })

        const dot = wrapper.find('span > span')
        const expectedClass = size === 'sm' ? 'h-1.5' : size === 'md' ? 'h-2' : 'h-2.5'
        expect(dot.classes()).toContain(expectedClass)
      })
    })
  })

  describe('accessibility', () => {
    it('has aria-hidden on dot indicator', () => {
      const wrapper = mount(Badge, {
        props: { dot: true },
        slots: { default: 'Badge' },
      })

      const dot = wrapper.find('span > span')
      expect(dot.attributes('aria-hidden')).toBe('true')
    })

    it('has aria-label on remove button', () => {
      const wrapper = mount(Badge, {
        props: { removable: true },
        slots: { default: 'Badge' },
      })

      const button = wrapper.find('button')
      expect(button.attributes('aria-label')).toBe('Remove')
    })

    it('remove button is type button', () => {
      const wrapper = mount(Badge, {
        props: { removable: true },
        slots: { default: 'Badge' },
      })

      const button = wrapper.find('button')
      expect(button.attributes('type')).toBe('button')
    })
  })
})
