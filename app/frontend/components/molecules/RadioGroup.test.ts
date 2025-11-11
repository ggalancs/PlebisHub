import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import RadioGroup from './RadioGroup.vue'

const mockOptions = [
  { label: 'Option 1', value: '1' },
  { label: 'Option 2', value: '2' },
  { label: 'Option 3', value: '3' },
]

describe('RadioGroup', () => {
  describe('Basic Rendering', () => {
    it('renders fieldset element', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions },
      })
      expect(wrapper.find('fieldset').exists()).toBe(true)
    })

    it('renders all options', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions },
      })
      expect(wrapper.findAll('input[type="radio"]')).toHaveLength(3)
    })

    it('renders option labels', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions },
      })
      expect(wrapper.text()).toContain('Option 1')
      expect(wrapper.text()).toContain('Option 2')
      expect(wrapper.text()).toContain('Option 3')
    })

    it('renders group label when provided', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, label: 'Select option' },
      })
      expect(wrapper.find('legend').text()).toContain('Select option')
    })

    it('renders description when provided', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, description: 'Choose one' },
      })
      expect(wrapper.text()).toContain('Choose one')
    })
  })

  describe('Selection', () => {
    it('checks selected option', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: '2', options: mockOptions },
      })
      const radios = wrapper.findAll('input[type="radio"]')
      expect((radios[0].element as HTMLInputElement).checked).toBe(false)
      expect((radios[1].element as HTMLInputElement).checked).toBe(true)
      expect((radios[2].element as HTMLInputElement).checked).toBe(false)
    })

    it('emits update:modelValue when radio is selected', async () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions },
      })
      await wrapper.findAll('input')[1].trigger('change')
      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['2'])
    })

    it('emits change event', async () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions },
      })
      await wrapper.findAll('input')[1].trigger('change')
      expect(wrapper.emitted('change')).toBeTruthy()
      expect(wrapper.emitted('change')?.[0]).toEqual(['2'])
    })

    it('changes selection', async () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: '1', options: mockOptions },
      })
      await wrapper.findAll('input')[2].trigger('change')
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['3'])
    })
  })

  describe('Name Attribute', () => {
    it('applies same name to all radios', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, name: 'test-group' },
      })
      wrapper.findAll('input').forEach((input) => {
        expect(input.attributes('name')).toBe('test-group')
      })
    })

    it('generates unique name by default', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions },
      })
      const name = wrapper.findAll('input')[0].attributes('name')
      expect(name).toContain('radio-group-')
    })
  })

  describe('Orientation', () => {
    it('renders vertical by default', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions },
      })
      expect(wrapper.find('.space-y-2').exists()).toBe(true)
    })

    it('renders horizontal when specified', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, orientation: 'horizontal' },
      })
      expect(wrapper.find('.flex.flex-wrap').exists()).toBe(true)
    })
  })

  describe('Disabled State', () => {
    it('disables all radios when disabled', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, disabled: true },
      })
      wrapper.findAll('input').forEach((input) => {
        expect(input.attributes('disabled')).toBeDefined()
      })
    })

    it('applies disabled styling to fieldset', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, disabled: true },
      })
      expect(wrapper.find('fieldset').classes()).toContain('opacity-50')
    })

    it('disables individual option', () => {
      const wrapper = mount(RadioGroup, {
        props: {
          modelValue: null,
          options: [
            { label: 'Option 1', value: '1' },
            { label: 'Option 2', value: '2', disabled: true },
          ],
        },
      })
      const radios = wrapper.findAll('input')
      expect(radios[0].attributes('disabled')).toBeUndefined()
      expect(radios[1].attributes('disabled')).toBeDefined()
    })

    it('does not emit when disabled', async () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, disabled: true },
      })
      await wrapper.findAll('input')[0].trigger('change')
      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })
  })

  describe('Required', () => {
    it('shows asterisk when required', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, label: 'Option', required: true },
      })
      expect(wrapper.find('.text-red-500').text()).toBe('*')
    })

    it('does not show asterisk by default', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, label: 'Option' },
      })
      expect(wrapper.find('.text-red-500').exists()).toBe(false)
    })
  })

  describe('Error State', () => {
    it('displays error message', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, error: 'Please select an option' },
      })
      expect(wrapper.find('.text-red-600').text()).toBe('Please select an option')
    })

    it('applies error styling to label', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions, label: 'Option', error: 'Error' },
      })
      expect(wrapper.find('legend').classes()).toContain('text-red-700')
    })
  })

  describe('Edge Cases', () => {
    it('handles empty options array', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: [] },
      })
      expect(wrapper.findAll('input')).toHaveLength(0)
    })

    it('handles numeric values', () => {
      const wrapper = mount(RadioGroup, {
        props: {
          modelValue: 2,
          options: [
            { label: 'One', value: 1 },
            { label: 'Two', value: 2 },
          ],
        },
      })
      const radios = wrapper.findAll('input')
      expect((radios[0].element as HTMLInputElement).checked).toBe(false)
      expect((radios[1].element as HTMLInputElement).checked).toBe(true)
    })

    it('handles null value', () => {
      const wrapper = mount(RadioGroup, {
        props: { modelValue: null, options: mockOptions },
      })
      wrapper.findAll('input').forEach((input) => {
        expect((input.element as HTMLInputElement).checked).toBe(false)
      })
    })
  })
})
