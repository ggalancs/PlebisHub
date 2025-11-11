import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Checkbox from './Checkbox.vue'

describe('Checkbox', () => {
  describe('rendering', () => {
    it('renders checkbox input', () => {
      const wrapper = mount(Checkbox)
      expect(wrapper.find('input[type="checkbox"]').exists()).toBe(true)
    })

    it('renders with label', () => {
      const wrapper = mount(Checkbox, {
        props: { label: 'Accept terms' },
      })

      expect(wrapper.find('label').exists()).toBe(true)
      expect(wrapper.find('label').text()).toContain('Accept terms')
    })

    it('renders with required indicator', () => {
      const wrapper = mount(Checkbox, {
        props: { label: 'Required field', required: true },
      })

      expect(wrapper.find('label').text()).toContain('*')
      expect(wrapper.find('input').attributes('required')).toBeDefined()
    })

    it('renders with helper text', () => {
      const wrapper = mount(Checkbox, {
        props: {
          label: 'Subscribe',
          helperText: 'You can unsubscribe at any time',
        },
      })

      const helperText = wrapper.find('p.text-gray-500')
      expect(helperText.exists()).toBe(true)
      expect(helperText.text()).toBe('You can unsubscribe at any time')
    })

    it('renders with error message', () => {
      const wrapper = mount(Checkbox, {
        props: {
          label: 'Terms',
          error: 'You must accept the terms',
        },
      })

      const errorMessage = wrapper.find('p.text-red-600')
      expect(errorMessage.exists()).toBe(true)
      expect(errorMessage.text()).toBe('You must accept the terms')
      expect(errorMessage.attributes('role')).toBe('alert')
    })

    it('does not show helper text when error is present', () => {
      const wrapper = mount(Checkbox, {
        props: {
          label: 'Terms',
          helperText: 'Helper text',
          error: 'Error message',
        },
      })

      expect(wrapper.find('p.text-gray-500').exists()).toBe(false)
      expect(wrapper.find('p.text-red-600').exists()).toBe(true)
    })

    it('renders with different sizes', () => {
      const sizes = ['sm', 'md', 'lg'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Checkbox, { props: { size } })
        const checkbox = wrapper.find('input[type="checkbox"]')

        expect(checkbox.classes()).toContain(size === 'sm' ? 'h-4' : size === 'md' ? 'h-5' : 'h-6')
      })
    })
  })

  describe('behavior', () => {
    it('emits update:modelValue when clicked', async () => {
      const wrapper = mount(Checkbox, {
        props: { modelValue: false },
      })

      await wrapper.find('input').setChecked(true)

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([true])
    })

    it('emits change event', async () => {
      const wrapper = mount(Checkbox)

      await wrapper.find('input').trigger('change')

      expect(wrapper.emitted('change')).toBeTruthy()
    })

    it('updates checked state via v-model', async () => {
      const wrapper = mount(Checkbox, {
        props: {
          modelValue: false,
          'onUpdate:modelValue': (value: boolean) => wrapper.setProps({ modelValue: value }),
        },
      })

      const input = wrapper.find('input')
      expect((input.element as HTMLInputElement).checked).toBe(false)

      await input.setChecked(true)
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([true])
    })

    it('can be checked by clicking label', async () => {
      const wrapper = mount(Checkbox, {
        props: { label: 'Click me' },
      })

      // Clicking label should check the associated checkbox
      const input = wrapper.find('input')
      await input.setChecked(true)

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    })
  })

  describe('states', () => {
    it('is checked when modelValue is true', () => {
      const wrapper = mount(Checkbox, {
        props: { modelValue: true },
      })

      const input = wrapper.find('input').element as HTMLInputElement
      expect(input.checked).toBe(true)
    })

    it('is unchecked when modelValue is false', () => {
      const wrapper = mount(Checkbox, {
        props: { modelValue: false },
      })

      const input = wrapper.find('input').element as HTMLInputElement
      expect(input.checked).toBe(false)
    })

    it('disables checkbox when disabled prop is true', () => {
      const wrapper = mount(Checkbox, {
        props: { disabled: true },
      })

      expect(wrapper.find('input').attributes('disabled')).toBeDefined()
    })

    it('applies disabled styles to label', () => {
      const wrapper = mount(Checkbox, {
        props: { label: 'Disabled', disabled: true },
      })

      const label = wrapper.find('label')
      expect(label.classes()).toContain('text-gray-400')
      expect(label.classes()).toContain('cursor-not-allowed')
    })

    it('sets indeterminate state', () => {
      const wrapper = mount(Checkbox, {
        props: { indeterminate: true },
      })

      const input = wrapper.find('input').element as HTMLInputElement
      expect(input.indeterminate).toBe(true)
    })

    it('applies error styles when error prop is provided', () => {
      const wrapper = mount(Checkbox, {
        props: { error: 'Error message' },
      })

      const input = wrapper.find('input')
      expect(input.classes()).toContain('border-red-500')
    })

    it('applies checked styles when checked', () => {
      const wrapper = mount(Checkbox, {
        props: { modelValue: true },
      })

      const input = wrapper.find('input')
      expect(input.classes()).toContain('bg-primary-700')
      expect(input.classes()).toContain('border-primary-700')
    })
  })

  describe('accessibility', () => {
    it('has proper aria-invalid when error exists', () => {
      const wrapper = mount(Checkbox, {
        props: { error: 'Error message' },
      })

      expect(wrapper.find('input').attributes('aria-invalid')).toBe('true')
    })

    it('links checkbox to error message with aria-describedby', () => {
      const wrapper = mount(Checkbox, {
        props: { id: 'test-checkbox', error: 'Error message' },
      })

      const input = wrapper.find('input')
      expect(input.attributes('aria-describedby')).toBe('test-checkbox-error')
    })

    it('links checkbox to helper text with aria-describedby', () => {
      const wrapper = mount(Checkbox, {
        props: { id: 'test-checkbox', helperText: 'Helper text' },
      })

      const input = wrapper.find('input')
      expect(input.attributes('aria-describedby')).toBe('test-checkbox-helper')
    })

    it('has proper label association', () => {
      const wrapper = mount(Checkbox, {
        props: { label: 'Terms', id: 'terms-checkbox' },
      })

      const label = wrapper.find('label')
      const input = wrapper.find('input')

      expect(label.attributes('for')).toBe('terms-checkbox')
      expect(input.attributes('id')).toBe('terms-checkbox')
    })

    it('generates unique id when id prop is not provided', () => {
      const wrapper1 = mount(Checkbox, { props: { label: 'Checkbox 1' } })
      const wrapper2 = mount(Checkbox, { props: { label: 'Checkbox 2' } })

      const id1 = wrapper1.find('input').attributes('id')
      const id2 = wrapper2.find('input').attributes('id')

      expect(id1).toBeDefined()
      expect(id2).toBeDefined()
      expect(id1).not.toBe(id2)
    })
  })

  describe('attributes', () => {
    it('passes name attribute', () => {
      const wrapper = mount(Checkbox, {
        props: { name: 'terms' },
      })

      expect(wrapper.find('input').attributes('name')).toBe('terms')
    })

    it('passes value attribute', () => {
      const wrapper = mount(Checkbox, {
        props: { value: 'accept' },
      })

      expect(wrapper.find('input').attributes('value')).toBe('accept')
    })
  })
})
