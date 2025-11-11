import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Toggle from './Toggle.vue'
import Icon from '../atoms/Icon.vue'

describe('Toggle', () => {
  describe('Basic Rendering', () => {
    it('renders as button with switch role', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false },
        global: { components: { Icon } },
      })
      expect(wrapper.element.tagName).toBe('BUTTON')
      expect(wrapper.attributes('role')).toBe('switch')
    })

    it('has correct aria-checked attribute', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true },
        global: { components: { Icon } },
      })
      expect(wrapper.attributes('aria-checked')).toBe('true')
    })
  })

  describe('Value States', () => {
    it('applies off styling when false', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false },
        global: { components: { Icon } },
      })
      expect(wrapper.classes()).toContain('bg-gray-200')
    })

    it('applies on styling when true', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true },
        global: { components: { Icon } },
      })
      expect(wrapper.classes()).toContain('bg-primary')
    })
  })

  describe('Sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false, size: 'sm' },
        global: { components: { Icon } },
      })
      expect(wrapper.classes()).toContain('h-5')
      expect(wrapper.classes()).toContain('w-9')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false },
        global: { components: { Icon } },
      })
      expect(wrapper.classes()).toContain('h-6')
      expect(wrapper.classes()).toContain('w-11')
    })

    it('renders large size', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false, size: 'lg' },
        global: { components: { Icon } },
      })
      expect(wrapper.classes()).toContain('h-8')
      expect(wrapper.classes()).toContain('w-16')
    })
  })

  describe('Variants', () => {
    it('renders primary variant', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true, variant: 'primary' },
        global: { components: { Icon } },
      })
      expect(wrapper.classes()).toContain('bg-primary')
    })

    it('renders success variant', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true, variant: 'success' },
        global: { components: { Icon } },
      })
      expect(wrapper.classes()).toContain('bg-green-600')
    })

    it('renders warning variant', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true, variant: 'warning' },
        global: { components: { Icon } },
      })
      expect(wrapper.classes()).toContain('bg-yellow-500')
    })

    it('renders danger variant', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true, variant: 'danger' },
        global: { components: { Icon } },
      })
      expect(wrapper.classes()).toContain('bg-red-600')
    })
  })

  describe('Icons', () => {
    it('does not show icon by default', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false },
        global: { components: { Icon } },
      })
      expect(wrapper.findComponent(Icon).exists()).toBe(false)
    })

    it('shows check/x icons when showIcon is true', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true, showIcon: true },
        global: { components: { Icon } },
      })
      expect(wrapper.findComponent(Icon).exists()).toBe(true)
      expect(wrapper.findComponent(Icon).props('name')).toBe('check')
    })

    it('shows x icon when off', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false, showIcon: true },
        global: { components: { Icon } },
      })
      expect(wrapper.findComponent(Icon).props('name')).toBe('x')
    })

    it('shows custom icon when provided', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true, showIcon: true, icon: 'star' },
        global: { components: { Icon } },
      })
      expect(wrapper.findComponent(Icon).props('name')).toBe('star')
    })
  })

  describe('Disabled State', () => {
    it('applies disabled styling', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false, disabled: true },
        global: { components: { Icon } },
      })
      expect(wrapper.classes()).toContain('opacity-50')
      expect(wrapper.attributes('disabled')).toBeDefined()
    })

    it('does not emit events when disabled', async () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false, disabled: true },
        global: { components: { Icon } },
      })
      await wrapper.trigger('click')
      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })
  })

  describe('Toggle Functionality', () => {
    it('emits update:modelValue on click', async () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false },
        global: { components: { Icon } },
      })
      await wrapper.trigger('click')
      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([true])
    })

    it('emits change event', async () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false },
        global: { components: { Icon } },
      })
      await wrapper.trigger('click')
      expect(wrapper.emitted('change')).toBeTruthy()
      expect(wrapper.emitted('change')?.[0]).toEqual([true])
    })

    it('toggles from true to false', async () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true },
        global: { components: { Icon } },
      })
      await wrapper.trigger('click')
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
    })
  })

  describe('Accessibility', () => {
    it('uses label for aria-label', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false, label: 'Enable notifications' },
        global: { components: { Icon } },
      })
      expect(wrapper.attributes('aria-label')).toBe('Enable notifications')
    })

    it('prefers ariaLabel over label', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false, label: 'Label', ariaLabel: 'Aria Label' },
        global: { components: { Icon } },
      })
      expect(wrapper.attributes('aria-label')).toBe('Aria Label')
    })

    it('has sr-only text with label', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false, label: 'Dark mode' },
        global: { components: { Icon } },
      })
      expect(wrapper.find('.sr-only').text()).toBe('Dark mode')
    })
  })
})
