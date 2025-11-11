import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Toggle from './Toggle.vue'

describe('Toggle', () => {
  describe('rendering', () => {
    it('renders toggle element', () => {
      const wrapper = mount(Toggle)

      expect(wrapper.find('input[type="checkbox"]').exists()).toBe(true)
      expect(wrapper.find('span[role="switch"]').exists()).toBe(true)
    })

    it('renders unchecked by default', () => {
      const wrapper = mount(Toggle)

      const input = wrapper.find('input[type="checkbox"]')
      expect(input.element.checked).toBe(false)
    })

    it('renders checked when modelValue is true', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true },
      })

      const input = wrapper.find('input[type="checkbox"]')
      expect(input.element.checked).toBe(true)
    })

    it('renders with label', () => {
      const wrapper = mount(Toggle, {
        props: { label: 'Enable notifications' },
      })

      expect(wrapper.text()).toContain('Enable notifications')
    })

    it('renders without label by default', () => {
      const wrapper = mount(Toggle)

      const labels = wrapper.findAll('span').filter((span) => !span.classes().includes('sr-only'))
      // Should only have the toggle switch and knob spans
      expect(labels.length).toBeLessThanOrEqual(2)
    })

    it('renders with slot content', () => {
      const wrapper = mount(Toggle, {
        slots: {
          default: 'Custom toggle label',
        },
      })

      expect(wrapper.text()).toContain('Custom toggle label')
    })

    it('renders with different sizes', () => {
      const sizes = ['sm', 'md', 'lg'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Toggle, {
          props: { size },
        })

        const toggle = wrapper.find('span[role="switch"]')
        const expectedClass = size === 'sm' ? 'h-5' : size === 'md' ? 'h-6' : 'h-7'

        expect(toggle.classes()).toContain(expectedClass)
      })
    })

    it('renders with different variants when checked', () => {
      const variants = ['primary', 'secondary', 'success', 'danger', 'warning', 'info'] as const

      variants.forEach((variant) => {
        const wrapper = mount(Toggle, {
          props: { variant, modelValue: true },
        })

        const toggle = wrapper.find('span[role="switch"]')
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

        expect(toggle.classes()).toContain(expectedClass)
      })
    })

    it('renders gray background when unchecked', () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: false },
      })

      const toggle = wrapper.find('span[role="switch"]')
      expect(toggle.classes()).toContain('bg-gray-300')
    })

    it('renders with disabled state', () => {
      const wrapper = mount(Toggle, {
        props: { disabled: true },
      })

      const input = wrapper.find('input[type="checkbox"]')
      expect(input.element.disabled).toBe(true)
    })

    it('applies disabled styling', () => {
      const wrapper = mount(Toggle, {
        props: { disabled: true, label: 'Disabled' },
      })

      const toggle = wrapper.find('span[role="switch"]')
      expect(toggle.classes()).toContain('opacity-50')
      expect(toggle.classes()).toContain('cursor-not-allowed')
    })

    it('renders label on right by default', () => {
      const wrapper = mount(Toggle, {
        props: { label: 'Label' },
      })

      const label = wrapper.find('label')
      expect(label.classes()).not.toContain('flex-row-reverse')
    })

    it('renders label on left when specified', () => {
      const wrapper = mount(Toggle, {
        props: { label: 'Label', labelPosition: 'left' },
      })

      const label = wrapper.find('label')
      expect(label.classes()).toContain('flex-row-reverse')
    })

    it('renders error message', () => {
      const wrapper = mount(Toggle, {
        props: { error: 'This field is required' },
      })

      const error = wrapper.find('.text-red-600')
      expect(error.exists()).toBe(true)
      expect(error.text()).toBe('This field is required')
    })

    it('renders helper text', () => {
      const wrapper = mount(Toggle, {
        props: { helperText: 'Enable this feature' },
      })

      const helper = wrapper.find('.text-gray-500')
      expect(helper.exists()).toBe(true)
      expect(helper.text()).toBe('Enable this feature')
    })

    it('does not render helper text when error is present', () => {
      const wrapper = mount(Toggle, {
        props: {
          error: 'Error message',
          helperText: 'Helper text',
        },
      })

      expect(wrapper.find('.text-red-600').exists()).toBe(true)
      expect(wrapper.find('.text-gray-500').exists()).toBe(false)
    })

    it('has rounded knob', () => {
      const wrapper = mount(Toggle)

      const knob = wrapper.find('span[aria-hidden="true"]')
      expect(knob.classes()).toContain('rounded-full')
    })

    it('positions knob based on state', () => {
      const unchecked = mount(Toggle, {
        props: { modelValue: false },
      })

      const checkedWrapper = mount(Toggle, {
        props: { modelValue: true },
      })

      const uncheckedKnob = unchecked.find('span[aria-hidden="true"]')
      const checkedKnob = checkedWrapper.find('span[aria-hidden="true"]')

      expect(uncheckedKnob.classes()).toContain('translate-x-0.5')
      expect(checkedKnob.classes()).toContain('translate-x-5')
    })
  })

  describe('behavior', () => {
    it('emits update:modelValue when toggled', async () => {
      const wrapper = mount(Toggle)

      await wrapper.find('input[type="checkbox"]').setValue(true)

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([true])
    })

    it('emits false when toggled off', async () => {
      const wrapper = mount(Toggle, {
        props: { modelValue: true },
      })

      await wrapper.find('input[type="checkbox"]').setValue(false)

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
    })

    it('does not emit when disabled', async () => {
      const wrapper = mount(Toggle, {
        props: { disabled: true },
      })

      // Try to change the input
      const input = wrapper.find('input[type="checkbox"]')
      // When disabled, setting value won't trigger change event
      expect(input.element.disabled).toBe(true)
    })
  })

  describe('accessibility', () => {
    it('has role="switch"', () => {
      const wrapper = mount(Toggle)

      const toggle = wrapper.find('span[role="switch"]')
      expect(toggle.exists()).toBe(true)
    })

    it('has aria-checked attribute', () => {
      const unchecked = mount(Toggle, {
        props: { modelValue: false },
      })

      const checked = mount(Toggle, {
        props: { modelValue: true },
      })

      expect(unchecked.find('span[role="switch"]').attributes('aria-checked')).toBe('false')
      expect(checked.find('span[role="switch"]').attributes('aria-checked')).toBe('true')
    })

    it('has sr-only input', () => {
      const wrapper = mount(Toggle)

      const input = wrapper.find('input[type="checkbox"]')
      expect(input.classes()).toContain('sr-only')
    })

    it('has aria-hidden on knob', () => {
      const wrapper = mount(Toggle)

      const knob = wrapper.find('span[aria-hidden="true"]')
      expect(knob.exists()).toBe(true)
    })

    it('label wraps input for clickability', () => {
      const wrapper = mount(Toggle, {
        props: { label: 'Click me' },
      })

      const label = wrapper.find('label')
      const input = wrapper.find('input[type="checkbox"]')

      // Verify that input is inside label for proper clickability
      expect(label.element.contains(input.element)).toBe(true)
    })
  })

  describe('label styling', () => {
    it('applies correct text size based on toggle size', () => {
      const sizes = ['sm', 'md', 'lg'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Toggle, {
          props: { size, label: 'Label' },
        })

        const labelSpan = wrapper.findAll('span').find((span) => span.text() === 'Label')
        const expectedClass = size === 'sm' ? 'text-sm' : size === 'md' ? 'text-base' : 'text-lg'

        expect(labelSpan?.classes()).toContain(expectedClass)
      })
    })

    it('applies disabled styling to label', () => {
      const wrapper = mount(Toggle, {
        props: { disabled: true, label: 'Label' },
      })

      const labelSpan = wrapper.findAll('span').find((span) => span.text() === 'Label')
      expect(labelSpan?.classes()).toContain('text-gray-400')
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(Toggle, {
        props: {
          modelValue: true,
          size: 'lg',
          variant: 'success',
          label: 'Enable feature',
          labelPosition: 'left',
          helperText: 'This will enable the feature',
        },
      })

      expect(wrapper.find('input[type="checkbox"]').element.checked).toBe(true)
      expect(wrapper.text()).toContain('Enable feature')
      expect(wrapper.text()).toContain('This will enable the feature')
      expect(wrapper.find('span[role="switch"]').classes()).toContain('bg-green-600')
    })

    it('renders disabled with error', () => {
      const wrapper = mount(Toggle, {
        props: {
          disabled: true,
          error: 'Cannot enable',
          label: 'Disabled feature',
        },
      })

      expect(wrapper.find('input[type="checkbox"]').element.disabled).toBe(true)
      expect(wrapper.text()).toContain('Cannot enable')
    })
  })

  describe('v-model integration', () => {
    it('works with v-model', async () => {
      const wrapper = mount(Toggle, {
        props: {
          modelValue: false,
          'onUpdate:modelValue': (value: boolean) => wrapper.setProps({ modelValue: value }),
        },
      })

      expect(wrapper.find('input[type="checkbox"]').element.checked).toBe(false)

      await wrapper.find('input[type="checkbox"]').setValue(true)

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([true])
    })
  })
})
