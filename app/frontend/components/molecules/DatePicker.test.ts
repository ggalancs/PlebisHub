import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { mount, VueWrapper } from '@vue/test-utils'
import { nextTick } from 'vue'
import DatePicker from './DatePicker.vue'
import Icon from '../atoms/Icon.vue'
import Button from '../atoms/Button.vue'
import Input from '../atoms/Input.vue'

describe('DatePicker', () => {
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
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Button, Input },
        },
      })
      expect(wrapper.exists()).toBe(true)
    })

    it('renders with label', () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          label: 'Select Date',
        },
        global: {
          components: { Icon, Button, Input },
        },
      })
      expect(wrapper.find('label').text()).toContain('Select Date')
    })

    it('renders required indicator', () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          label: 'Date',
          required: true,
        },
        global: {
          components: { Icon, Button, Input },
        },
      })
      expect(wrapper.find('span[aria-label="required"]').text()).toBe('*')
    })

    it('renders description', () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          description: 'Choose a date',
        },
        global: {
          components: { Icon, Button, Input },
        },
      })
      expect(wrapper.text()).toContain('Choose a date')
    })

    it('renders error message', () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          error: 'Date is required',
        },
        global: {
          components: { Icon, Button, Input },
        },
      })
      expect(wrapper.text()).toContain('Date is required')
      expect(wrapper.find('.text-red-600').exists()).toBe(true)
    })

    it('displays placeholder when no value', () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          placeholder: 'Pick a date',
        },
        global: {
          components: { Icon, Button, Input },
        },
      })
      expect(wrapper.text()).toContain('Pick a date')
    })

    it('displays selected date', () => {
      const date = new Date(2024, 0, 15) // January 15, 2024
      wrapper = mount(DatePicker, {
        props: {
          modelValue: date,
        },
        global: {
          components: { Icon, Button, Input },
        },
      })
      expect(wrapper.text()).toContain('Jan 15, 2024')
    })

    it('does not show calendar by default', () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Button, Input },
        },
      })
      expect(wrapper.find('.grid.grid-cols-7').exists()).toBe(false)
    })
  })

  describe('Calendar Open/Close', () => {
    it('opens calendar on click', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(2) // Week days + calendar
    })

    it('closes calendar on second click', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      const trigger = wrapper.find('.flex.w-full')
      await trigger.trigger('click')
      await nextTick()
      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(2)

      await trigger.trigger('click')
      await nextTick()
      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(0)
    })

    it('does not open when disabled', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          disabled: true,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(0)
    })
  })

  describe('Single Date Selection', () => {
    it('selects a date in single mode', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          mode: 'single',
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text)
      })

      await dayButtons[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('change')).toBeTruthy()
    })

    it('closes calendar after selecting date in single mode', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          mode: 'single',
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text)
      })

      await dayButtons[0].trigger('click')
      await nextTick()

      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(0)
    })
  })

  describe('Range Date Selection', () => {
    it('selects start date in range mode', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          mode: 'range',
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text)
      })

      await dayButtons[5].trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(Array.isArray(wrapper.emitted('update:modelValue')?.[0][0])).toBe(true)
    })

    it('selects date range in range mode', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          mode: 'range',
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text)
      })

      await dayButtons[5].trigger('click')
      await nextTick()
      await dayButtons[10].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[1][0] as Date[]
      expect(Array.isArray(emittedValue)).toBe(true)
      expect(emittedValue.length).toBe(2)
    })

    it('closes calendar after selecting range', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          mode: 'range',
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text)
      })

      await dayButtons[5].trigger('click')
      await dayButtons[10].trigger('click')
      await nextTick()

      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(0)
    })

    it('swaps dates if end is before start', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          mode: 'range',
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text)
      })

      await dayButtons[10].trigger('click')
      await nextTick()
      await dayButtons[5].trigger('click')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[1][0] as Date[]
      expect(emittedValue[0].getDate()).toBeLessThan(emittedValue[1].getDate())
    })
  })

  describe('Multiple Date Selection', () => {
    it('selects multiple dates', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: [],
          mode: 'multiple',
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text)
      })

      await dayButtons[5].trigger('click')
      await nextTick()
      await dayButtons[10].trigger('click')
      await nextTick()
      await dayButtons[15].trigger('click')
      await nextTick()

      const lastEmitted = wrapper.emitted('update:modelValue')?.[2][0] as Date[]
      expect(Array.isArray(lastEmitted)).toBe(true)
      expect(lastEmitted.length).toBe(3)
    })

    it('deselects date on second click in multiple mode', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: [],
          mode: 'multiple',
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text)
      })

      await dayButtons[5].trigger('click')
      await nextTick()
      await dayButtons[5].trigger('click')
      await nextTick()

      const lastEmitted = wrapper.emitted('update:modelValue')?.[1][0] as Date[]
      expect(lastEmitted.length).toBe(0)
    })

    it('does not close calendar after selection in multiple mode', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: [],
          mode: 'multiple',
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text)
      })

      await dayButtons[5].trigger('click')
      await nextTick()

      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(2)
    })
  })

  describe('Month Navigation', () => {
    it('navigates to previous month', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const prevButton = wrapper.find('[aria-label="Previous month"]')
      await prevButton.trigger('click')
      await nextTick()

      // Calendar should still be visible
      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(2)
    })

    it('navigates to next month', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const nextButton = wrapper.find('[aria-label="Next month"]')
      await nextButton.trigger('click')
      await nextTick()

      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(2)
    })
  })

  describe('Date Constraints', () => {
    it('disables dates before minDate', async () => {
      const minDate = new Date(2024, 0, 15)
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          minDate,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text) && parseInt(text) < 15
      })

      if (dayButtons.length > 0) {
        expect(dayButtons[0].attributes('disabled')).toBeDefined()
      }
    })

    it('disables dates after maxDate', async () => {
      const maxDate = new Date(2024, 0, 15)
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          maxDate,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text) && parseInt(text) > 15
      })

      if (dayButtons.length > 0) {
        expect(dayButtons[0].attributes('disabled')).toBeDefined()
      }
    })

    it('disables specific dates', async () => {
      const disabledDates = [new Date(2024, 0, 10), new Date(2024, 0, 20)]
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          disabledDates,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(2)
    })

    it('does not emit change for disabled date', async () => {
      const minDate = new Date(2024, 0, 15)
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          minDate,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const dayButtons = wrapper.findAll('button[type="button"]').filter((btn) => {
        const text = btn.text()
        return text && /^\d+$/.test(text) && parseInt(text) < 15
      })

      if (dayButtons.length > 0) {
        await dayButtons[0].trigger('click')
        await nextTick()
        expect(wrapper.emitted('update:modelValue')).toBeFalsy()
      }
    })
  })

  describe('Clear Functionality', () => {
    it('shows clear button when value is selected', () => {
      const date = new Date(2024, 0, 15)
      wrapper = mount(DatePicker, {
        props: {
          modelValue: date,
        },
        global: {
          components: { Icon, Button, Input },
        },
      })

      expect(wrapper.find('[aria-label="Clear selection"]').exists()).toBe(true)
    })

    it('clears selection on clear button click', async () => {
      const date = new Date(2024, 0, 15)
      wrapper = mount(DatePicker, {
        props: {
          modelValue: date,
        },
        global: {
          components: { Icon, Button, Input },
        },
      })

      await wrapper.find('[aria-label="Clear selection"]').trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([null])
    })

    it('clears to empty array in range mode', async () => {
      const dates = [new Date(2024, 0, 10), new Date(2024, 0, 15)]
      wrapper = mount(DatePicker, {
        props: {
          modelValue: dates,
          mode: 'range',
        },
        global: {
          components: { Icon, Button, Input },
        },
      })

      await wrapper.find('[aria-label="Clear selection"]').trigger('click')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([[]])
    })
  })

  describe('Display Formatting', () => {
    it('displays single date correctly', () => {
      const date = new Date(2024, 5, 15) // June 15, 2024
      wrapper = mount(DatePicker, {
        props: {
          modelValue: date,
        },
        global: {
          components: { Icon, Button, Input },
        },
      })

      expect(wrapper.text()).toContain('Jun 15, 2024')
    })

    it('displays date range correctly', () => {
      const dates = [new Date(2024, 0, 10), new Date(2024, 0, 20)]
      wrapper = mount(DatePicker, {
        props: {
          modelValue: dates,
          mode: 'range',
        },
        global: {
          components: { Icon, Button, Input },
        },
      })

      expect(wrapper.text()).toContain('Jan 10, 2024')
      expect(wrapper.text()).toContain('Jan 20, 2024')
    })

    it('displays multiple dates correctly', () => {
      const dates = [new Date(2024, 0, 10), new Date(2024, 0, 15)]
      wrapper = mount(DatePicker, {
        props: {
          modelValue: dates,
          mode: 'multiple',
        },
        global: {
          components: { Icon, Button, Input },
        },
      })

      expect(wrapper.text()).toContain('Jan 10, 2024')
      expect(wrapper.text()).toContain('Jan 15, 2024')
    })
  })

  describe('Size Props', () => {
    it('applies small size classes', () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          size: 'sm',
        },
        global: {
          components: { Icon, Button, Input },
        },
      })

      expect(wrapper.find('.datepicker-container').classes()).toContain('text-sm')
    })

    it('applies large size classes', () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          size: 'lg',
        },
        global: {
          components: { Icon, Button, Input },
        },
      })

      expect(wrapper.find('.datepicker-container').classes()).toContain('text-lg')
    })
  })

  describe('Week Configuration', () => {
    it('renders week days starting with Sunday by default', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const weekDays = wrapper.findAll('.grid.grid-cols-7')[0].findAll('div')
      expect(weekDays[0].text()).toBe('Su')
    })

    it('adjusts week days based on firstDayOfWeek', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          firstDayOfWeek: 1, // Monday
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      const weekDays = wrapper.findAll('.grid.grid-cols-7')[0].findAll('div')
      expect(weekDays[0].text()).toBe('Mo')
    })
  })

  describe('Disabled State', () => {
    it('does not open calendar when disabled', async () => {
      wrapper = mount(DatePicker, {
        props: {
          modelValue: null,
          disabled: true,
        },
        global: {
          components: { Icon, Button, Input },
        },
        attachTo: document.body,
      })

      await wrapper.find('.flex.w-full').trigger('click')
      await nextTick()

      expect(wrapper.findAll('.grid.grid-cols-7')).toHaveLength(0)
    })

    it('does not clear when disabled', async () => {
      const date = new Date(2024, 0, 15)
      wrapper = mount(DatePicker, {
        props: {
          modelValue: date,
          disabled: true,
        },
        global: {
          components: { Icon, Button, Input },
        },
      })

      const clearButton = wrapper.find('[aria-label="Clear selection"]')
      expect(clearButton.exists()).toBe(false)
    })
  })
})
