import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import CheckboxGroup from './CheckboxGroup.vue'

const mockOptions = [
  { label: 'Option 1', value: '1' },
  { label: 'Option 2', value: '2' },
  { label: 'Option 3', value: '3' },
]

describe('CheckboxGroup', () => {
  describe('Basic Rendering', () => {
    it('renders fieldset element', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions },
      })
      expect(wrapper.find('fieldset').exists()).toBe(true)
    })

    it('renders all options', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions },
      })
      expect(wrapper.findAll('input[type="checkbox"]')).toHaveLength(3)
    })

    it('renders option labels', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions },
      })
      expect(wrapper.text()).toContain('Option 1')
      expect(wrapper.text()).toContain('Option 2')
      expect(wrapper.text()).toContain('Option 3')
    })

    it('renders group label when provided', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions, label: 'Select options' },
      })
      expect(wrapper.find('legend').text()).toContain('Select options')
    })

    it('renders description when provided', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions, description: 'Choose multiple' },
      })
      expect(wrapper.text()).toContain('Choose multiple')
    })
  })

  describe('Selection', () => {
    it('checks selected options', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: ['1', '3'], options: mockOptions },
      })
      const checkboxes = wrapper.findAll('input[type="checkbox"]')
      expect((checkboxes[0].element as HTMLInputElement).checked).toBe(true)
      expect((checkboxes[1].element as HTMLInputElement).checked).toBe(false)
      expect((checkboxes[2].element as HTMLInputElement).checked).toBe(true)
    })

    it('emits update:modelValue when checkbox is checked', async () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions },
      })
      await wrapper.findAll('input')[0].setValue(true)
      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([['1']])
    })

    it('emits change event', async () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions },
      })
      await wrapper.findAll('input')[0].setValue(true)
      expect(wrapper.emitted('change')).toBeTruthy()
      expect(wrapper.emitted('change')?.[0]).toEqual([['1']])
    })

    it('adds value when checking', async () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: ['1'], options: mockOptions },
      })
      await wrapper.findAll('input')[1].setValue(true)
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([['1', '2']])
    })

    it('removes value when unchecking', async () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: ['1', '2'], options: mockOptions },
      })
      await wrapper.findAll('input')[0].setValue(false)
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([['2']])
    })
  })

  describe('Orientation', () => {
    it('renders vertical by default', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions },
      })
      expect(wrapper.find('.space-y-2').exists()).toBe(true)
    })

    it('renders horizontal when specified', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions, orientation: 'horizontal' },
      })
      expect(wrapper.find('.flex.flex-wrap').exists()).toBe(true)
    })
  })

  describe('Disabled State', () => {
    it('disables all checkboxes when disabled', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions, disabled: true },
      })
      wrapper.findAll('input').forEach((input) => {
        expect(input.attributes('disabled')).toBeDefined()
      })
    })

    it('applies disabled styling to fieldset', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions, disabled: true },
      })
      expect(wrapper.find('fieldset').classes()).toContain('opacity-50')
    })

    it('disables individual option', () => {
      const wrapper = mount(CheckboxGroup, {
        props: {
          modelValue: [],
          options: [
            { label: 'Option 1', value: '1' },
            { label: 'Option 2', value: '2', disabled: true },
          ],
        },
      })
      const checkboxes = wrapper.findAll('input')
      expect(checkboxes[0].attributes('disabled')).toBeUndefined()
      expect(checkboxes[1].attributes('disabled')).toBeDefined()
    })

    it('does not emit when disabled', async () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions, disabled: true },
      })
      await wrapper.findAll('input')[0].setValue(true)
      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })
  })

  describe('Required', () => {
    it('shows asterisk when required', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions, label: 'Options', required: true },
      })
      expect(wrapper.find('.text-red-500').text()).toBe('*')
    })

    it('does not show asterisk by default', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions, label: 'Options' },
      })
      expect(wrapper.find('.text-red-500').exists()).toBe(false)
    })
  })

  describe('Error State', () => {
    it('displays error message', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions, error: 'Please select at least one' },
      })
      expect(wrapper.find('.text-red-600').text()).toBe('Please select at least one')
    })

    it('applies error styling to label', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: mockOptions, label: 'Options', error: 'Error' },
      })
      expect(wrapper.find('legend').classes()).toContain('text-red-700')
    })
  })

  describe('Edge Cases', () => {
    it('handles empty options array', () => {
      const wrapper = mount(CheckboxGroup, {
        props: { modelValue: [], options: [] },
      })
      expect(wrapper.findAll('input')).toHaveLength(0)
    })

    it('handles numeric values', () => {
      const wrapper = mount(CheckboxGroup, {
        props: {
          modelValue: [1, 2],
          options: [
            { label: 'One', value: 1 },
            { label: 'Two', value: 2 },
          ],
        },
      })
      const checkboxes = wrapper.findAll('input')
      expect((checkboxes[0].element as HTMLInputElement).checked).toBe(true)
      expect((checkboxes[1].element as HTMLInputElement).checked).toBe(true)
    })
  })
})
