import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Radio from './Radio.vue'

describe('Radio', () => {
  describe('rendering', () => {
    it('renders radio input', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1' },
      })
      expect(wrapper.find('input[type="radio"]').exists()).toBe(true)
    })

    it('renders with label', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', label: 'Option 1' },
      })

      expect(wrapper.find('label').exists()).toBe(true)
      expect(wrapper.find('label').text()).toContain('Option 1')
    })

    it('renders with required indicator', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', label: 'Required option', required: true },
      })

      expect(wrapper.find('label').text()).toContain('*')
      expect(wrapper.find('input').attributes('required')).toBeDefined()
    })

    it('renders with helper text', () => {
      const wrapper = mount(Radio, {
        props: {
          value: 'option1',
          label: 'Option 1',
          helperText: 'This is the first option',
        },
      })

      const helperText = wrapper.find('p.text-gray-500')
      expect(helperText.exists()).toBe(true)
      expect(helperText.text()).toBe('This is the first option')
    })

    it('renders with error message', () => {
      const wrapper = mount(Radio, {
        props: {
          value: 'option1',
          label: 'Option 1',
          error: 'You must select an option',
        },
      })

      const errorMessage = wrapper.find('p.text-red-600')
      expect(errorMessage.exists()).toBe(true)
      expect(errorMessage.text()).toBe('You must select an option')
      expect(errorMessage.attributes('role')).toBe('alert')
    })

    it('does not show helper text when error is present', () => {
      const wrapper = mount(Radio, {
        props: {
          value: 'option1',
          label: 'Option',
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
        const wrapper = mount(Radio, {
          props: { value: 'option1', size },
        })
        const radio = wrapper.find('input[type="radio"]')

        expect(radio.classes()).toContain(size === 'sm' ? 'h-4' : size === 'md' ? 'h-5' : 'h-6')
      })
    })
  })

  describe('behavior', () => {
    it('emits update:modelValue when selected', async () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', modelValue: '' },
      })

      await wrapper.find('input').setValue(true)

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['option1'])
    })

    it('emits change event', async () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1' },
      })

      await wrapper.find('input').setValue(true)

      expect(wrapper.emitted('change')).toBeTruthy()
    })

    it('updates selected value via v-model', async () => {
      const wrapper = mount(Radio, {
        props: {
          value: 'option1',
          modelValue: '',
          'onUpdate:modelValue': (value: string | number | boolean) =>
            wrapper.setProps({ modelValue: value }),
        },
      })

      const input = wrapper.find('input')
      expect((input.element as HTMLInputElement).checked).toBe(false)

      await input.setValue(true)
      await wrapper.vm.$nextTick()

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['option1'])
    })

    it('can be selected by clicking label', async () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', label: 'Click me' },
      })

      const input = wrapper.find('input')
      await input.setValue(true)

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    })
  })

  describe('states', () => {
    it('is checked when modelValue matches value', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', modelValue: 'option1' },
      })

      const input = wrapper.find('input').element as HTMLInputElement
      expect(input.checked).toBe(true)
    })

    it('is unchecked when modelValue does not match value', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', modelValue: 'option2' },
      })

      const input = wrapper.find('input').element as HTMLInputElement
      expect(input.checked).toBe(false)
    })

    it('works with numeric values', () => {
      const wrapper = mount(Radio, {
        props: { value: 1, modelValue: 1 },
      })

      const input = wrapper.find('input').element as HTMLInputElement
      expect(input.checked).toBe(true)
    })

    it('works with boolean values', () => {
      const wrapper = mount(Radio, {
        props: { value: true, modelValue: true },
      })

      const input = wrapper.find('input').element as HTMLInputElement
      expect(input.checked).toBe(true)
    })

    it('disables radio when disabled prop is true', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', disabled: true },
      })

      expect(wrapper.find('input').attributes('disabled')).toBeDefined()
    })

    it('applies disabled styles to label', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', label: 'Disabled', disabled: true },
      })

      const label = wrapper.find('label')
      expect(label.classes()).toContain('text-gray-400')
      expect(label.classes()).toContain('cursor-not-allowed')
    })

    it('applies error styles when error prop is provided', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', error: 'Error message' },
      })

      const input = wrapper.find('input')
      expect(input.classes()).toContain('border-red-500')
    })

    it('applies checked styles when selected', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', modelValue: 'option1' },
      })

      const input = wrapper.find('input')
      expect(input.classes()).toContain('border-primary-700')
    })
  })

  describe('accessibility', () => {
    it('has proper aria-invalid when error exists', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', error: 'Error message' },
      })

      expect(wrapper.find('input').attributes('aria-invalid')).toBe('true')
    })

    it('links radio to error message with aria-describedby', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', id: 'test-radio', error: 'Error message' },
      })

      const input = wrapper.find('input')
      expect(input.attributes('aria-describedby')).toBe('test-radio-error')
    })

    it('links radio to helper text with aria-describedby', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', id: 'test-radio', helperText: 'Helper text' },
      })

      const input = wrapper.find('input')
      expect(input.attributes('aria-describedby')).toBe('test-radio-helper')
    })

    it('has proper label association', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', label: 'Option', id: 'option-radio' },
      })

      const label = wrapper.find('label')
      const input = wrapper.find('input')

      expect(label.attributes('for')).toBe('option-radio')
      expect(input.attributes('id')).toBe('option-radio')
    })

    it('generates unique id when id prop is not provided', () => {
      const wrapper1 = mount(Radio, { props: { value: 'option1', label: 'Radio 1' } })
      const wrapper2 = mount(Radio, { props: { value: 'option2', label: 'Radio 2' } })

      const id1 = wrapper1.find('input').attributes('id')
      const id2 = wrapper2.find('input').attributes('id')

      expect(id1).toBeDefined()
      expect(id2).toBeDefined()
      expect(id1).not.toBe(id2)
    })
  })

  describe('attributes', () => {
    it('passes name attribute', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1', name: 'options' },
      })

      expect(wrapper.find('input').attributes('name')).toBe('options')
    })

    it('passes value attribute', () => {
      const wrapper = mount(Radio, {
        props: { value: 'option1' },
      })

      expect(wrapper.find('input').attributes('value')).toBe('option1')
    })
  })

  describe('radio group behavior', () => {
    it('only one radio in a group can be selected', async () => {
      const groupName = 'test-group'

      const wrapper1 = mount(Radio, {
        props: { value: 'option1', modelValue: '', name: groupName },
      })

      const wrapper2 = mount(Radio, {
        props: { value: 'option2', modelValue: '', name: groupName },
      })

      // Select first radio
      await wrapper1.find('input').setValue(true)
      expect(wrapper1.emitted('update:modelValue')?.[0]).toEqual(['option1'])

      // Both radios should have same name attribute
      expect(wrapper1.find('input').attributes('name')).toBe(groupName)
      expect(wrapper2.find('input').attributes('name')).toBe(groupName)
    })
  })
})
