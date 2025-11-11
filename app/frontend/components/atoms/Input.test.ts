import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Input from './Input.vue'

describe('Input', () => {
  describe('rendering', () => {
    it('renders with default props', () => {
      const wrapper = mount(Input)
      expect(wrapper.find('input').exists()).toBe(true)
      expect(wrapper.find('input').attributes('type')).toBe('text')
    })

    it('renders with different types', () => {
      const types = ['text', 'email', 'password', 'number', 'tel', 'url'] as const

      types.forEach((type) => {
        const wrapper = mount(Input, { props: { type } })
        const input = wrapper.find('input')

        if (type === 'password') {
          // Password type should be 'password' by default
          expect(input.attributes('type')).toBe('password')
        } else {
          expect(input.attributes('type')).toBe(type)
        }
      })
    })

    it('renders with label', () => {
      const wrapper = mount(Input, {
        props: { label: 'Email Address' },
      })

      expect(wrapper.find('label').exists()).toBe(true)
      expect(wrapper.find('label').text()).toContain('Email Address')
    })

    it('renders with required indicator', () => {
      const wrapper = mount(Input, {
        props: { label: 'Email', required: true },
      })

      expect(wrapper.find('label').text()).toContain('*')
      expect(wrapper.find('input').attributes('required')).toBeDefined()
    })

    it('renders with helper text', () => {
      const wrapper = mount(Input, {
        props: { helperText: 'Enter your email address' },
      })

      const helperText = wrapper.find('p.text-gray-500')
      expect(helperText.exists()).toBe(true)
      expect(helperText.text()).toBe('Enter your email address')
    })

    it('renders with error message', () => {
      const wrapper = mount(Input, {
        props: { error: 'Email is required' },
      })

      const errorMessage = wrapper.find('p.text-red-600')
      expect(errorMessage.exists()).toBe(true)
      expect(errorMessage.text()).toBe('Email is required')
      expect(errorMessage.attributes('role')).toBe('alert')
    })

    it('does not show helper text when error is present', () => {
      const wrapper = mount(Input, {
        props: {
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
        const wrapper = mount(Input, { props: { size } })
        const input = wrapper.find('input')

        expect(input.classes()).toContain(
          size === 'sm' ? 'text-sm' : size === 'md' ? 'text-base' : 'text-lg'
        )
      })
    })

    it('renders full width when fullWidth prop is true', () => {
      const wrapper = mount(Input, {
        props: { fullWidth: true },
      })

      expect(wrapper.find('div').classes()).toContain('w-full')
    })

    it('renders password toggle button for password type', () => {
      const wrapper = mount(Input, {
        props: { type: 'password' },
      })

      expect(wrapper.find('button[type="button"]').exists()).toBe(true)
    })

    it('does not render password toggle when showPasswordToggle is false', () => {
      const wrapper = mount(Input, {
        props: { type: 'password', showPasswordToggle: false },
      })

      expect(wrapper.find('button[type="button"]').exists()).toBe(false)
    })

    it('renders with placeholder', () => {
      const wrapper = mount(Input, {
        props: { placeholder: 'Enter text...' },
      })

      expect(wrapper.find('input').attributes('placeholder')).toBe('Enter text...')
    })
  })

  describe('behavior', () => {
    it('emits update:modelValue on input', async () => {
      const wrapper = mount(Input)
      const input = wrapper.find('input')

      await input.setValue('test value')

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['test value'])
    })

    it('emits number for number type', async () => {
      const wrapper = mount(Input, {
        props: { type: 'number' },
      })
      const input = wrapper.find('input')

      await input.setValue('42')

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([42])
    })

    it('emits focus event', async () => {
      const wrapper = mount(Input)
      const input = wrapper.find('input')

      await input.trigger('focus')

      expect(wrapper.emitted('focus')).toBeTruthy()
    })

    it('emits blur event', async () => {
      const wrapper = mount(Input)
      const input = wrapper.find('input')

      await input.trigger('blur')

      expect(wrapper.emitted('blur')).toBeTruthy()
    })

    it('emits change event', async () => {
      const wrapper = mount(Input)
      const input = wrapper.find('input')

      await input.trigger('change')

      expect(wrapper.emitted('change')).toBeTruthy()
    })

    it('toggles password visibility', async () => {
      const wrapper = mount(Input, {
        props: { type: 'password' },
      })

      const input = wrapper.find('input')
      const toggleButton = wrapper.find('button[type="button"]')

      // Initially password type
      expect(input.attributes('type')).toBe('password')

      // Click toggle
      await toggleButton.trigger('click')
      expect(input.attributes('type')).toBe('text')

      // Click again
      await toggleButton.trigger('click')
      expect(input.attributes('type')).toBe('password')
    })

    it('supports v-model', async () => {
      const wrapper = mount(Input, {
        props: {
          modelValue: 'initial value',
          'onUpdate:modelValue': (value: string | number) =>
            wrapper.setProps({ modelValue: value }),
        },
      })

      const input = wrapper.find('input')
      expect((input.element as HTMLInputElement).value).toBe('initial value')

      await input.setValue('new value')
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['new value'])
    })
  })

  describe('states', () => {
    it('disables input when disabled prop is true', () => {
      const wrapper = mount(Input, {
        props: { disabled: true },
      })

      expect(wrapper.find('input').attributes('disabled')).toBeDefined()
    })

    it('makes input readonly when readonly prop is true', () => {
      const wrapper = mount(Input, {
        props: { readonly: true },
      })

      expect(wrapper.find('input').attributes('readonly')).toBeDefined()
    })

    it('applies error styles when error prop is provided', () => {
      const wrapper = mount(Input, {
        props: { error: 'Error message' },
      })

      const input = wrapper.find('input')
      expect(input.classes()).toContain('border-red-300')
      expect(input.classes()).toContain('text-red-900')
    })

    it('hides password toggle when disabled', () => {
      const wrapper = mount(Input, {
        props: { type: 'password', disabled: true },
      })

      expect(wrapper.find('button[type="button"]').exists()).toBe(false)
    })
  })

  describe('accessibility', () => {
    it('has proper aria-invalid when error exists', () => {
      const wrapper = mount(Input, {
        props: { error: 'Error message' },
      })

      expect(wrapper.find('input').attributes('aria-invalid')).toBe('true')
    })

    it('links input to error message with aria-describedby', () => {
      const wrapper = mount(Input, {
        props: { id: 'test-input', error: 'Error message' },
      })

      const input = wrapper.find('input')
      expect(input.attributes('aria-describedby')).toBe('test-input-error')
    })

    it('links input to helper text with aria-describedby', () => {
      const wrapper = mount(Input, {
        props: { id: 'test-input', helperText: 'Helper text' },
      })

      const input = wrapper.find('input')
      expect(input.attributes('aria-describedby')).toBe('test-input-helper')
    })

    it('has proper label association', () => {
      const wrapper = mount(Input, {
        props: { label: 'Email', id: 'email-input' },
      })

      const label = wrapper.find('label')
      const input = wrapper.find('input')

      expect(label.attributes('for')).toBe('email-input')
      expect(input.attributes('id')).toBe('email-input')
    })

    it('has screen reader text for password toggle', () => {
      const wrapper = mount(Input, {
        props: { type: 'password' },
      })

      expect(wrapper.find('.sr-only').text()).toContain('password')
    })
  })

  describe('attributes', () => {
    it('passes name attribute', () => {
      const wrapper = mount(Input, {
        props: { name: 'email' },
      })

      expect(wrapper.find('input').attributes('name')).toBe('email')
    })

    it('passes autocomplete attribute', () => {
      const wrapper = mount(Input, {
        props: { autocomplete: 'email' },
      })

      expect(wrapper.find('input').attributes('autocomplete')).toBe('email')
    })

    it('passes min, max, step for number type', () => {
      const wrapper = mount(Input, {
        props: {
          type: 'number',
          min: 0,
          max: 100,
          step: 5,
        },
      })

      const input = wrapper.find('input')
      expect(input.attributes('min')).toBe('0')
      expect(input.attributes('max')).toBe('100')
      expect(input.attributes('step')).toBe('5')
    })

    it('passes pattern attribute', () => {
      const wrapper = mount(Input, {
        props: { pattern: '[0-9]{4}' },
      })

      expect(wrapper.find('input').attributes('pattern')).toBe('[0-9]{4}')
    })

    it('passes maxlength attribute', () => {
      const wrapper = mount(Input, {
        props: { maxlength: 50 },
      })

      expect(wrapper.find('input').attributes('maxlength')).toBe('50')
    })
  })

  describe('exposed methods', () => {
    it('exposes focus method', () => {
      const wrapper = mount(Input)
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const vm = wrapper.vm as any

      expect(vm.focus).toBeDefined()
      expect(typeof vm.focus).toBe('function')
    })

    it('exposes blur method', () => {
      const wrapper = mount(Input)
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const vm = wrapper.vm as any

      expect(vm.blur).toBeDefined()
      expect(typeof vm.blur).toBe('function')
    })
  })
})
