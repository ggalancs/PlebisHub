import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { mount, VueWrapper } from '@vue/test-utils'
import { nextTick } from 'vue'
import Combobox from './Combobox.vue'
import Icon from '../atoms/Icon.vue'
import Input from '../atoms/Input.vue'

const mockOptions = [
  { label: 'Option 1', value: '1' },
  { label: 'Option 2', value: '2' },
  { label: 'Option 3', value: '3' },
  { label: 'Disabled Option', value: '4', disabled: true },
]

describe('Combobox', () => {
  let wrapper: VueWrapper<any>

  beforeEach(() => {
    const el = document.createElement('div')
    el.id = 'app'
    document.body.appendChild(el)
  })

  afterEach(() => {
    if (wrapper) {
      wrapper.unmount()
    }
    document.body.innerHTML = ''
  })

  describe('Basic Rendering', () => {
    it('renders correctly', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.exists()).toBe(true)
    })

    it('renders with label', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          label: 'Test Label',
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.find('label').text()).toContain('Test Label')
    })

    it('renders required indicator', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          label: 'Test',
          required: true,
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.find('span[aria-label="required"]').text()).toBe('*')
    })

    it('renders description', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          description: 'Test description',
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.text()).toContain('Test description')
    })

    it('renders error message', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          error: 'Error message',
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.text()).toContain('Error message')
      expect(wrapper.find('.text-red-600').exists()).toBe(true)
    })

    it('does not show dropdown by default', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.find('[role="listbox"]').exists()).toBe(false)
    })

    it('displays placeholder when no value selected', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          placeholder: 'Select an option',
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.text()).toContain('Select an option')
    })

    it('displays selected option label', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: '1',
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.text()).toContain('Option 1')
    })
  })

  describe('Dropdown Open/Close', () => {
    it('opens dropdown on click', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      expect(wrapper.find('[role="listbox"]').exists()).toBe(true)
      expect(wrapper.emitted('open')).toBeTruthy()
    })

    it('closes dropdown on second click', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      const trigger = wrapper.find('.relative.flex')
      await trigger.trigger('click')
      await nextTick()
      expect(wrapper.find('[role="listbox"]').exists()).toBe(true)

      await trigger.trigger('click')
      await nextTick()
      expect(wrapper.find('[role="listbox"]').exists()).toBe(false)
      expect(wrapper.emitted('close')).toBeTruthy()
    })

    it('closes dropdown on outside click', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()
      expect(wrapper.find('[role="listbox"]').exists()).toBe(true)

      await document.body.click()
      await nextTick()
      expect(wrapper.find('[role="listbox"]').exists()).toBe(false)
    })

    it('does not open when disabled', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          disabled: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      expect(wrapper.find('[role="listbox"]').exists()).toBe(false)
    })
  })

  describe('Option Selection', () => {
    it('selects option on click', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      await options[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['1'])
      expect(wrapper.emitted('change')).toBeTruthy()
    })

    it('closes dropdown after selection in single mode', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      await options[0].trigger('click')
      await nextTick()

      expect(wrapper.find('[role="listbox"]').exists()).toBe(false)
    })

    it('does not select disabled option', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      await options[3].trigger('click') // Disabled option
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    })

    it('displays check icon for selected option', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: '1',
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const selectedOption = wrapper.findAll('[role="option"]')[0]
      expect(selectedOption.classes()).toContain('bg-primary-50')
    })
  })

  describe('Multiple Selection', () => {
    it('allows multiple selections', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: [],
          options: mockOptions,
          multiple: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      await options[0].trigger('click')
      await nextTick()
      await options[1].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([['1']])
      expect(wrapper.emitted('update:modelValue')?.[1]).toEqual([['1', '2']])
    })

    it('does not close dropdown after selection in multiple mode', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: [],
          options: mockOptions,
          multiple: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      await options[0].trigger('click')
      await nextTick()

      expect(wrapper.find('[role="listbox"]').exists()).toBe(true)
    })

    it('deselects option on second click in multiple mode', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: ['1'],
          options: mockOptions,
          multiple: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      await options[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([[]])
    })

    it('displays multiple selected options', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: ['1', '2'],
          options: mockOptions,
          multiple: true,
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.text()).toContain('Option 1, Option 2')
    })
  })

  describe('Search Functionality', () => {
    it('filters options based on search query', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          searchable: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.setValue('Option 1')
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      expect(options).toHaveLength(1)
      expect(options[0].text()).toContain('Option 1')
    })

    it('emits search event on input', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          searchable: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.setValue('test')
      await nextTick()

      expect(wrapper.emitted('search')).toBeTruthy()
      expect(wrapper.emitted('search')?.[0]).toEqual(['test'])
    })

    it('shows no results message when no matches', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          searchable: true,
          noResultsText: 'No matches',
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.setValue('nonexistent')
      await nextTick()

      expect(wrapper.text()).toContain('No matches')
    })

    it('does not show search input when searchable is false', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          searchable: false,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      expect(wrapper.find('input').exists()).toBe(false)
    })
  })

  describe('Clear Functionality', () => {
    it('shows clear button when value is selected and clearable is true', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: '1',
          options: mockOptions,
          clearable: true,
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.find('[aria-label="Clear selection"]').exists()).toBe(true)
    })

    it('clears selection on clear button click', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: '1',
          options: mockOptions,
          clearable: true,
        },
        global: {
          components: { Icon, Input },
        },
      })

      await wrapper.find('[aria-label="Clear selection"]').trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([null])
    })

    it('hides clear button when clearable is false', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: '1',
          options: mockOptions,
          clearable: false,
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.find('[aria-label="Clear selection"]').exists()).toBe(false)
    })

    it('clears to empty array in multiple mode', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: ['1', '2'],
          options: mockOptions,
          multiple: true,
          clearable: true,
        },
        global: {
          components: { Icon, Input },
        },
      })

      await wrapper.find('[aria-label="Clear selection"]').trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([[]])
    })
  })

  describe('Keyboard Navigation', () => {
    it('opens dropdown on ArrowDown key', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      const trigger = wrapper.find('.relative.flex')
      await trigger.trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.trigger('keydown', { key: 'ArrowDown' })
      await nextTick()

      expect(wrapper.find('[role="listbox"]').exists()).toBe(true)
    })

    it('closes dropdown on Escape key', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.trigger('keydown', { key: 'Escape' })
      await nextTick()

      expect(wrapper.find('[role="listbox"]').exists()).toBe(false)
    })

    it('navigates options with ArrowDown', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.trigger('keydown', { key: 'ArrowDown' })
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      expect(options[0].classes()).toContain('bg-gray-100')
    })

    it('navigates options with ArrowUp', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.trigger('keydown', { key: 'ArrowDown' })
      await input.trigger('keydown', { key: 'ArrowDown' })
      await input.trigger('keydown', { key: 'ArrowUp' })
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      expect(options[0].classes()).toContain('bg-gray-100')
    })

    it('selects focused option on Enter key', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.trigger('keydown', { key: 'ArrowDown' })
      await input.trigger('keydown', { key: 'Enter' })
      await nextTick()

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['1'])
    })

    it('focuses first option on Home key', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.trigger('keydown', { key: 'Home' })
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      expect(options[0].classes()).toContain('bg-gray-100')
    })

    it('focuses last option on End key', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.trigger('keydown', { key: 'End' })
      await nextTick()

      const options = wrapper.findAll('[role="option"]')
      expect(options[options.length - 1].classes()).toContain('bg-gray-100')
    })

    it('closes dropdown on Tab key', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const input = wrapper.find('input')
      await input.trigger('keydown', { key: 'Tab' })
      await nextTick()

      expect(wrapper.find('[role="listbox"]').exists()).toBe(false)
    })
  })

  describe('Loading State', () => {
    it('shows loading indicator when loading is true', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: [],
          loading: true,
          loadingText: 'Loading...',
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Loading...')
    })

    it('hides options when loading', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          loading: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      expect(wrapper.findAll('[role="option"]')).toHaveLength(0)
    })
  })

  describe('Accessibility', () => {
    it('has listbox role', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      expect(wrapper.find('[role="listbox"]').exists()).toBe(true)
    })

    it('has aria-multiselectable in multiple mode', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: [],
          options: mockOptions,
          multiple: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const listbox = wrapper.find('[role="listbox"]')
      expect(listbox.attributes('aria-multiselectable')).toBe('true')
    })

    it('options have aria-selected attribute', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: '1',
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const selectedOption = wrapper.findAll('[role="option"]')[0]
      expect(selectedOption.attributes('aria-selected')).toBe('true')
    })

    it('disabled options have aria-disabled attribute', async () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.relative.flex').trigger('click')
      await nextTick()

      const disabledOption = wrapper.findAll('[role="option"]')[3]
      expect(disabledOption.attributes('aria-disabled')).toBe('true')
    })
  })

  describe('Size Props', () => {
    it('applies small size classes', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          size: 'sm',
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.find('.combobox-container').classes()).toContain('text-sm')
    })

    it('applies large size classes', () => {
      wrapper = mount(Combobox, {
        props: {
          modelValue: null,
          options: mockOptions,
          size: 'lg',
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.find('.combobox-container').classes()).toContain('text-lg')
    })
  })
})
