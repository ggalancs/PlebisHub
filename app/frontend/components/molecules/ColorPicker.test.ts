import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { mount, VueWrapper } from '@vue/test-utils'
import { nextTick } from 'vue'
import ColorPicker from './ColorPicker.vue'
import Icon from '../atoms/Icon.vue'
import Input from '../atoms/Input.vue'

describe('ColorPicker', () => {
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
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.exists()).toBe(true)
    })

    it('renders with label', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          label: 'Select Color',
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.find('label').text()).toContain('Select Color')
    })

    it('renders required indicator', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          label: 'Color',
          required: true,
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.find('span[aria-label="required"]').text()).toBe('*')
    })

    it('renders description', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          description: 'Choose a color',
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.text()).toContain('Choose a color')
    })

    it('renders error message', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          error: 'Color is required',
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.text()).toContain('Color is required')
      expect(wrapper.find('.text-red-600').exists()).toBe(true)
    })

    it('displays placeholder when no value', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          placeholder: 'Pick a color',
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.text()).toContain('Pick a color')
    })

    it('displays selected color', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: '#FF0000',
        },
        global: {
          components: { Icon, Input },
        },
      })
      expect(wrapper.text()).toContain('#FF0000')
    })

    it('shows color preview', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: '#FF0000',
        },
        global: {
          components: { Icon, Input },
        },
      })
      const preview = wrapper.find('.h-6.w-6')
      expect(preview.attributes('style')).toContain('background-color: rgb(255, 0, 0)')
    })
  })

  describe('Picker Open/Close', () => {
    it('opens picker on click', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.find('.grid.grid-cols-6').exists()).toBe(true)
    })

    it('closes picker on second click', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      const trigger = wrapper.find('.flex.w-full')
      await trigger.trigger('click')
      await nextTick()
      expect(wrapper.find('.grid.grid-cols-6').exists()).toBe(true)

      await trigger.trigger('click')
      await nextTick()
      expect(wrapper.find('.grid.grid-cols-6').exists()).toBe(false)
    })

    it('does not open when disabled', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          disabled: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.find('.grid.grid-cols-6').exists()).toBe(false)
    })
  })

  describe('Color Selection', () => {
    it('selects a color from basic palette', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const colorButtons = wrapper.findAll('.grid.grid-cols-6 button')
      await colorButtons[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('change')).toBeTruthy()
    })

    it('highlights selected color', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: '#FF0000',
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const selectedButton = wrapper.find('button[title="#FF0000"]')
      expect(selectedButton.classes()).toContain('border-primary-600')
    })
  })

  describe('Format Support', () => {
    it('outputs HEX format by default', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          format: 'hex',
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const colorButtons = wrapper.findAll('.grid.grid-cols-6 button')
      await colorButtons[0].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[0][0] as string
      expect(emittedValue).toMatch(/^#[0-9A-F]{6}$/i)
    })

    it('outputs RGB format', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          format: 'rgb',
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const colorButtons = wrapper.findAll('.grid.grid-cols-6 button')
      await colorButtons[0].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[0][0] as string
      expect(emittedValue).toMatch(/^rgb\(\d+,\s*\d+,\s*\d+\)$/)
    })

    it('outputs HSL format', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          format: 'hsl',
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const colorButtons = wrapper.findAll('.grid.grid-cols-6 button')
      await colorButtons[0].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[0][0] as string
      expect(emittedValue).toMatch(/^hsl\(\d+,\s*\d+%,\s*\d+%\)$/)
    })
  })

  describe('Alpha/Opacity Support', () => {
    it('shows alpha slider when showAlpha is true', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          showAlpha: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Opacity')
      expect(wrapper.find('input[type="range"]').exists()).toBe(true)
    })

    it('hides alpha slider by default', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          showAlpha: false,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.text()).not.toContain('Opacity')
      expect(wrapper.find('input[type="range"]').exists()).toBe(false)
    })

    it('updates alpha value', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: '#FF0000',
          showAlpha: true,
          format: 'rgb',
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const slider = wrapper.find('input[type="range"]')
      await slider.setValue('0.5')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[0][0] as string
      expect(emittedValue).toContain('0.5')
    })

    it('outputs RGBA format with alpha', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          format: 'rgb',
          showAlpha: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const colorButtons = wrapper.findAll('.grid.grid-cols-6 button')
      await colorButtons[0].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[0][0] as string
      expect(emittedValue).toMatch(/^rgba\(\d+,\s*\d+,\s*\d+,\s*[\d.]+\)$/)
    })

    it('outputs HSLA format with alpha', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          format: 'hsl',
          showAlpha: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const colorButtons = wrapper.findAll('.grid.grid-cols-6 button')
      await colorButtons[0].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[0][0] as string
      expect(emittedValue).toMatch(/^hsla\(\d+,\s*\d+%,\s*\d+%,\s*[\d.]+\)$/)
    })
  })

  describe('Preset Colors', () => {
    it('renders preset colors', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          presets: ['#FF0000', '#00FF00', '#0000FF'],
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Presets')
      const presetButtons = wrapper.findAll('.flex-wrap button')
      expect(presetButtons.length).toBeGreaterThanOrEqual(3)
    })

    it('selects preset color', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          presets: ['#FF0000', '#00FF00'],
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const presetButtons = wrapper.findAll('.flex-wrap button')
      await presetButtons[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    })
  })

  describe('Clear Functionality', () => {
    it('shows clear button when value is selected', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: '#FF0000',
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.find('[aria-label="Clear selection"]').exists()).toBe(true)
    })

    it('clears selection on clear button click', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: '#FF0000',
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

    it('does not show clear button when no value', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.find('[aria-label="Clear selection"]').exists()).toBe(false)
    })
  })

  describe('Size Props', () => {
    it('applies small size classes', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          size: 'sm',
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.find('.colorpicker-container').classes()).toContain('text-sm')
    })

    it('applies large size classes', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          size: 'lg',
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.find('.colorpicker-container').classes()).toContain('text-lg')
    })
  })

  describe('Disabled State', () => {
    it('does not open picker when disabled', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
          disabled: true,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.find('.grid.grid-cols-6').exists()).toBe(false)
    })

    it('does not show clear button when disabled', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: '#FF0000',
          disabled: true,
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.find('[aria-label="Clear selection"]').exists()).toBe(false)
    })
  })

  describe('Color Parsing', () => {
    it('parses HEX color', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: '#FF0000',
        },
        global: {
          components: { Icon, Input },
        },
      })

      const preview = wrapper.find('.h-6.w-6')
      expect(preview.attributes('style')).toContain('background-color: rgb(255, 0, 0)')
    })

    it('parses RGB color', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: 'rgb(255, 0, 0)',
        },
        global: {
          components: { Icon, Input },
        },
      })

      const preview = wrapper.find('.h-6.w-6')
      expect(preview.attributes('style')).toContain('rgb(255, 0, 0)')
    })

    it('parses HEX with alpha', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: '#FF000080',
          showAlpha: true,
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.exists()).toBe(true)
    })

    it('parses RGBA color', () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: 'rgba(255, 0, 0, 0.5)',
          showAlpha: true,
        },
        global: {
          components: { Icon, Input },
        },
      })

      expect(wrapper.exists()).toBe(true)
    })
  })

  describe('Events', () => {
    it('emits update:modelValue on color change', async () => {
      wrapper = mount(ColorPicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const colorButtons = wrapper.findAll('.grid.grid-cols-6 button')
      await colorButtons[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('change')).toBeTruthy()
    })
  })
})
