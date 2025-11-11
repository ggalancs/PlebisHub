import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import FormField from './FormField.vue'
import Input from '../atoms/Input.vue'

describe('FormField', () => {
  describe('rendering', () => {
    it('renders form field with input', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username' },
      })

      expect(wrapper.find('label').exists()).toBe(true)
      expect(wrapper.findComponent(Input).exists()).toBe(true)
    })

    it('renders label text', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Email Address' },
      })

      expect(wrapper.text()).toContain('Email Address')
    })

    it('does not render label when not provided', () => {
      const wrapper = mount(FormField)

      expect(wrapper.find('label').exists()).toBe(false)
    })

    it('renders required indicator', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Password', required: true },
      })

      const asterisk = wrapper.find('span[aria-label="required"]')
      expect(asterisk.exists()).toBe(true)
      expect(asterisk.text()).toBe('*')
      expect(asterisk.classes()).toContain('text-red-600')
    })

    it('does not render required indicator by default', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username' },
      })

      expect(wrapper.find('span[aria-label="required"]').exists()).toBe(false)
    })

    it('renders in vertical layout by default', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username' },
      })

      const container = wrapper.find('div')
      expect(container.classes()).toContain('space-y-1')
      expect(container.classes()).not.toContain('flex')
    })

    it('renders in horizontal layout', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', layout: 'horizontal' },
      })

      const container = wrapper.find('div')
      expect(container.classes()).toContain('flex')
      expect(container.classes()).toContain('items-start')
    })
  })

  describe('input integration', () => {
    it('passes modelValue to input', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', modelValue: 'john_doe' },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('modelValue')).toBe('john_doe')
    })

    it('passes type to input', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Email', type: 'email' },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('type')).toBe('email')
    })

    it('passes placeholder to input', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', placeholder: 'Enter your username' },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('placeholder')).toBe('Enter your username')
    })

    it('passes disabled to input', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', disabled: true },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('disabled')).toBe(true)
    })

    it('passes readonly to input', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', readonly: true },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('readonly')).toBe(true)
    })

    it('passes size to input', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', size: 'lg' },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('size')).toBe('lg')
    })

    it('passes error to input', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Email', error: 'Invalid email address' },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('error')).toBe('Invalid email address')
    })

    it('passes helperText to input', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Password', helperText: 'Must be at least 8 characters' },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('helperText')).toBe('Must be at least 8 characters')
    })

    it('passes showPasswordToggle to input', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Password', type: 'password', showPasswordToggle: true },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('showPasswordToggle')).toBe(true)
    })
  })

  describe('behavior', () => {
    it('emits update:modelValue when input changes', async () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username' },
      })

      const input = wrapper.findComponent(Input)
      await input.vm.$emit('update:modelValue', 'new_value')

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['new_value'])
    })

    it('emits numeric values', async () => {
      const wrapper = mount(FormField, {
        props: { label: 'Age', type: 'number' },
      })

      const input = wrapper.findComponent(Input)
      await input.vm.$emit('update:modelValue', 25)

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([25])
    })
  })

  describe('label styling', () => {
    it('applies error color to label when error is present', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Email', error: 'Invalid email' },
      })

      const label = wrapper.find('label')
      expect(label.classes()).toContain('text-red-600')
    })

    it('applies disabled color to label when disabled', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', disabled: true },
      })

      const label = wrapper.find('label')
      expect(label.classes()).toContain('text-gray-400')
    })

    it('applies normal color to label by default', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username' },
      })

      const label = wrapper.find('label')
      expect(label.classes()).toContain('text-gray-700')
    })

    it('applies horizontal layout classes to label', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', layout: 'horizontal' },
      })

      const label = wrapper.find('label')
      expect(label.classes()).toContain('pt-2')
      expect(label.classes()).toContain('min-w-[120px]')
    })
  })

  describe('slots', () => {
    it('passes through prefix slot', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Search' },
        slots: {
          prefix: '<span class="prefix-icon">🔍</span>',
        },
      })

      expect(wrapper.find('.prefix-icon').exists()).toBe(true)
      expect(wrapper.text()).toContain('🔍')
    })

    it('passes through suffix slot', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Password' },
        slots: {
          suffix: '<span class="suffix-icon">👁</span>',
        },
      })

      expect(wrapper.find('.suffix-icon').exists()).toBe(true)
      expect(wrapper.text()).toContain('👁')
    })

    it('passes through both prefix and suffix slots', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Amount' },
        slots: {
          prefix: '<span>$</span>',
          suffix: '<span>USD</span>',
        },
      })

      expect(wrapper.text()).toContain('$')
      expect(wrapper.text()).toContain('USD')
    })
  })

  describe('layouts', () => {
    it('renders vertical layout with proper spacing', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', layout: 'vertical' },
      })

      const container = wrapper.find('div')
      expect(container.classes()).toContain('space-y-1')
    })

    it('renders horizontal layout with flex', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', layout: 'horizontal' },
      })

      const container = wrapper.find('div')
      expect(container.classes()).toContain('flex')
      expect(container.classes()).toContain('items-start')
      expect(container.classes()).toContain('gap-4')
    })

    it('applies flex-1 to input wrapper in horizontal layout', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', layout: 'horizontal' },
      })

      const inputWrapper = wrapper.findAll('div')[1]
      expect(inputWrapper.classes()).toContain('flex-1')
    })

    it('does not apply flex-1 to input wrapper in vertical layout', () => {
      const wrapper = mount(FormField, {
        props: { label: 'Username', layout: 'vertical' },
      })

      const inputWrapper = wrapper.findAll('div')[1]
      expect(inputWrapper.classes()).not.toContain('flex-1')
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(FormField, {
        props: {
          label: 'Email Address',
          required: true,
          type: 'email',
          placeholder: 'you@example.com',
          helperText: 'We will never share your email',
          size: 'lg',
          layout: 'vertical',
        },
      })

      expect(wrapper.text()).toContain('Email Address')
      expect(wrapper.find('span[aria-label="required"]').exists()).toBe(true)
      const input = wrapper.findComponent(Input)
      expect(input.props('type')).toBe('email')
      expect(input.props('placeholder')).toBe('you@example.com')
      expect(input.props('helperText')).toBe('We will never share your email')
      expect(input.props('size')).toBe('lg')
    })

    it('renders horizontal layout with error', () => {
      const wrapper = mount(FormField, {
        props: {
          label: 'Username',
          required: true,
          error: 'Username is required',
          layout: 'horizontal',
        },
      })

      const label = wrapper.find('label')
      expect(label.classes()).toContain('text-red-600')
      expect(wrapper.findComponent(Input).props('error')).toBe('Username is required')
    })

    it('renders disabled field with required indicator', () => {
      const wrapper = mount(FormField, {
        props: {
          label: 'Username',
          required: true,
          disabled: true,
        },
      })

      expect(wrapper.find('span[aria-label="required"]').exists()).toBe(true)
      const label = wrapper.find('label')
      expect(label.classes()).toContain('text-gray-400')
      expect(wrapper.findComponent(Input).props('disabled')).toBe(true)
    })
  })

  describe('v-model integration', () => {
    it('works with v-model', async () => {
      const wrapper = mount(FormField, {
        props: {
          label: 'Username',
          modelValue: 'initial',
          'onUpdate:modelValue': (value: string | number) =>
            wrapper.setProps({ modelValue: value }),
        },
      })

      const input = wrapper.findComponent(Input)
      expect(input.props('modelValue')).toBe('initial')

      await input.vm.$emit('update:modelValue', 'updated')

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['updated'])
    })
  })
})
