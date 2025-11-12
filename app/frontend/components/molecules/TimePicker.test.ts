import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { mount, VueWrapper } from '@vue/test-utils'
import { nextTick } from 'vue'
import TimePicker from './TimePicker.vue'
import Icon from '../atoms/Icon.vue'

describe('TimePicker', () => {
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
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.exists()).toBe(true)
    })

    it('renders with label', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          label: 'Select Time',
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.find('label').text()).toContain('Select Time')
    })

    it('renders required indicator', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          label: 'Time',
          required: true,
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.find('span[aria-label="required"]').text()).toBe('*')
    })

    it('renders description', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          description: 'Choose a time',
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.text()).toContain('Choose a time')
    })

    it('renders error message', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          error: 'Time is required',
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.text()).toContain('Time is required')
      expect(wrapper.find('.text-red-600').exists()).toBe(true)
    })

    it('displays placeholder when no value', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          placeholder: 'Pick a time',
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.text()).toContain('Pick a time')
    })

    it('displays selected time in 12h format', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '14:30 PM',
          format: '12h',
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.text()).toContain('02:30 PM')
    })

    it('displays selected time in 24h format', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '14:30',
          format: '24h',
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.text()).toContain('14:30')
    })

    it('does not show picker by default', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.find('.h-48').exists()).toBe(false)
    })
  })

  describe('Picker Open/Close', () => {
    it('opens picker on click', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.findAll('.h-48')).toHaveLength(2) // Hour + Minute
    })

    it('closes picker on second click', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      const trigger = wrapper.find('.flex.w-full')
      await trigger.trigger('click')
      await nextTick()
      expect(wrapper.findAll('.h-48').length).toBeGreaterThan(0)

      await trigger.trigger('click')
      await nextTick()
      expect(wrapper.findAll('.h-48')).toHaveLength(0)
    })

    it('does not open when disabled', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          disabled: true,
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.findAll('.h-48')).toHaveLength(0)
    })
  })

  describe('12-Hour Format', () => {
    it('shows 12-hour options by default', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '12h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const hourButtons = wrapper.findAll('.h-48')[0].findAll('button')
      expect(hourButtons.length).toBe(12)
    })

    it('shows AM/PM selector in 12h format', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '12h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('AM')
      expect(wrapper.text()).toContain('PM')
    })

    it('selects hour in 12h format', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '12h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const hourButtons = wrapper.findAll('.h-48')[0].findAll('button')
      await hourButtons[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('change')).toBeTruthy()
    })

    it('selects minute', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '12h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const minuteButtons = wrapper.findAll('.h-48')[1].findAll('button')
      await minuteButtons[15].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    })

    it('switches between AM and PM', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '12:00 AM',
          format: '12h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const periodButtons = wrapper.findAll('.flex-1.rounded')
      await periodButtons[1].trigger('click') // Click PM
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[0][0] as string
      expect(emittedValue).toContain('PM')
    })

    it('formats time correctly in 12h format', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '12h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      // Select hour 3
      const hourButtons = wrapper.findAll('.h-48')[0].findAll('button')
      await hourButtons[3].trigger('click')
      await nextTick()

      // Select minute 30
      const minuteButtons = wrapper.findAll('.h-48')[1].findAll('button')
      await minuteButtons[30].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[1][0] as string
      expect(emittedValue).toMatch(/03:30 (AM|PM)/)
    })
  })

  describe('24-Hour Format', () => {
    it('shows 24-hour options', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '24h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const hourButtons = wrapper.findAll('.h-48')[0].findAll('button')
      expect(hourButtons.length).toBe(24)
    })

    it('does not show AM/PM selector in 24h format', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '24h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const periodText = wrapper.text()
      // Should have Hour and Min labels but not Period
      expect(periodText).toContain('Hour')
      expect(periodText).toContain('Min')
      expect(periodText).not.toContain('Period')
    })

    it('selects hour in 24h format', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '24h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const hourButtons = wrapper.findAll('.h-48')[0].findAll('button')
      await hourButtons[14].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    })

    it('formats time correctly in 24h format', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '24h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      // Select hour 14
      const hourButtons = wrapper.findAll('.h-48')[0].findAll('button')
      await hourButtons[14].trigger('click')
      await nextTick()

      // Select minute 30
      const minuteButtons = wrapper.findAll('.h-48')[1].findAll('button')
      await minuteButtons[30].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[1][0] as string
      expect(emittedValue).toBe('14:30')
    })
  })

  describe('Seconds Support', () => {
    it('shows seconds selector when showSeconds is true', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          showSeconds: true,
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Sec')
      expect(wrapper.findAll('.h-48')).toHaveLength(3) // Hour + Minute + Second
    })

    it('hides seconds selector by default', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          showSeconds: false,
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.text()).not.toContain('Sec')
      expect(wrapper.findAll('.h-48')).toHaveLength(2) // Hour + Minute only
    })

    it('selects seconds', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          showSeconds: true,
          format: '24h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const secondButtons = wrapper.findAll('.h-48')[2].findAll('button')
      await secondButtons[30].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[0][0] as string
      expect(emittedValue).toContain(':30')
    })

    it('includes seconds in formatted time', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          showSeconds: true,
          format: '24h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      // Select hour 14
      const hourButtons = wrapper.findAll('.h-48')[0].findAll('button')
      await hourButtons[14].trigger('click')
      await nextTick()

      // Select minute 30
      const minuteButtons = wrapper.findAll('.h-48')[1].findAll('button')
      await minuteButtons[30].trigger('click')
      await nextTick()

      // Select second 45
      const secondButtons = wrapper.findAll('.h-48')[2].findAll('button')
      await secondButtons[45].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[2][0] as string
      expect(emittedValue).toBe('14:30:45')
    })
  })

  describe('Step Configuration', () => {
    it('respects minuteStep', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          minuteStep: 15,
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const minuteButtons = wrapper.findAll('.h-48')[1].findAll('button')
      expect(minuteButtons.length).toBe(4) // 0, 15, 30, 45
    })

    it('respects secondStep', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          showSeconds: true,
          secondStep: 10,
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const secondButtons = wrapper.findAll('.h-48')[2].findAll('button')
      expect(secondButtons.length).toBe(6) // 0, 10, 20, 30, 40, 50
    })
  })

  describe('Clear Functionality', () => {
    it('shows clear button when value is selected', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '14:30',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('[aria-label="Clear selection"]').exists()).toBe(true)
    })

    it('clears selection on clear button click', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '14:30',
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.find('[aria-label="Clear selection"]').trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([null])
    })

    it('does not show clear button when no value', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('[aria-label="Clear selection"]').exists()).toBe(false)
    })
  })

  describe('Size Props', () => {
    it('applies small size classes', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          size: 'sm',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('.timepicker-container').classes()).toContain('text-sm')
    })

    it('applies large size classes', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('.timepicker-container').classes()).toContain('text-lg')
    })
  })

  describe('Disabled State', () => {
    it('does not open picker when disabled', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          disabled: true,
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.findAll('.h-48')).toHaveLength(0)
    })

    it('does not show clear button when disabled', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '14:30',
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('[aria-label="Clear selection"]').exists()).toBe(false)
    })
  })

  describe('Time Parsing and Formatting', () => {
    it('parses 12h format correctly', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '02:30 PM',
          format: '12h',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('02:30 PM')
    })

    it('parses 24h format correctly', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '14:30',
          format: '24h',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('14:30')
    })

    it('parses time with seconds', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '14:30:45',
          format: '24h',
          showSeconds: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('14:30:45')
    })

    it('handles midnight in 12h format', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '12:00 AM',
          format: '12h',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('12:00 AM')
    })

    it('handles noon in 12h format', () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: '12:00 PM',
          format: '12h',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('12:00 PM')
    })
  })

  describe('Events', () => {
    it('emits update:modelValue on hour change', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '24h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const hourButtons = wrapper.findAll('.h-48')[0].findAll('button')
      await hourButtons[10].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('change')).toBeTruthy()
    })

    it('emits update:modelValue on minute change', async () => {
      wrapper = mount(TimePicker, {
        props: {
          modelValue: null,
          format: '24h',
        },
        global: {
          components: { Icon },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const minuteButtons = wrapper.findAll('.h-48')[1].findAll('button')
      await minuteButtons[30].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('change')).toBeTruthy()
    })
  })
})
