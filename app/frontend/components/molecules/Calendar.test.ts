import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import Calendar, { type CalendarEvent } from './Calendar.vue'
import Icon from '../atoms/Icon.vue'
import Button from '../atoms/Button.vue'

const mockEvents: CalendarEvent[] = [
  {
    id: '1',
    title: 'Team Meeting',
    date: new Date(2024, 0, 15),
    color: '#3b82f6',
  },
  {
    id: '2',
    title: 'Project Deadline',
    date: new Date(2024, 0, 20),
    color: '#ef4444',
  },
]

describe('Calendar', () => {
  describe('Basic Rendering', () => {
    it('renders correctly', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })
      expect(wrapper.exists()).toBe(true)
    })

    it('renders with label', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
          label: 'Event Calendar',
        },
        global: {
          components: { Icon, Button },
        },
      })
      expect(wrapper.find('label').text()).toBe('Event Calendar')
    })

    it('renders description', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
          description: 'View and manage events',
        },
        global: {
          components: { Icon, Button },
        },
      })
      expect(wrapper.text()).toContain('View and manage events')
    })

    it('renders error message', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
          error: 'Date selection required',
        },
        global: {
          components: { Icon, Button },
        },
      })
      expect(wrapper.text()).toContain('Date selection required')
      expect(wrapper.find('.text-red-600').exists()).toBe(true)
    })

    it('displays current month and year', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      const today = new Date()
      const monthName = today.toLocaleString('en-US', { month: 'long' })
      const year = today.getFullYear()

      expect(wrapper.text()).toContain(monthName)
      expect(wrapper.text()).toContain(year.toString())
    })

    it('renders week day headers', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.text()).toContain('Su')
      expect(wrapper.text()).toContain('Mo')
      expect(wrapper.text()).toContain('Tu')
    })

    it('renders calendar grid', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.find('.grid.grid-cols-7').exists()).toBe(true)
    })
  })

  describe('Navigation', () => {
    it('has previous month button', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.find('[aria-label="Previous month"]').exists()).toBe(true)
    })

    it('has next month button', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.find('[aria-label="Next month"]').exists()).toBe(true)
    })

    it('has today button', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      const todayButton = wrapper.findAll('button').find((btn) => btn.text() === 'Today')
      expect(todayButton).toBeDefined()
    })

    it('navigates to previous month', async () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      const initialMonth = wrapper.text()
      await wrapper.find('[aria-label="Previous month"]').trigger('click')
      await nextTick()

      const newMonth = wrapper.text()
      expect(newMonth).not.toBe(initialMonth)
    })

    it('navigates to next month', async () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      const initialMonth = wrapper.text()
      await wrapper.find('[aria-label="Next month"]').trigger('click')
      await nextTick()

      const newMonth = wrapper.text()
      expect(newMonth).not.toBe(initialMonth)
    })
  })

  describe('Date Selection', () => {
    it('emits date-click when date is clicked', async () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      const dayElements = wrapper.findAll('.cursor-pointer')
      if (dayElements.length > 0) {
        await dayElements[0].trigger('click')
        await nextTick()

        expect(wrapper.emitted('date-click')).toBeTruthy()
      }
    })

    it('emits update:modelValue in single mode', async () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
          mode: 'single',
          modelValue: null,
        },
        global: {
          components: { Icon, Button },
        },
      })

      const dayElements = wrapper.findAll('.cursor-pointer')
      if (dayElements.length > 0) {
        await dayElements[0].trigger('click')
        await nextTick()

        expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      }
    })

    it('highlights selected date', () => {
      const selectedDate = new Date()
      const wrapper = mount(Calendar, {
        props: {
          events: [],
          modelValue: selectedDate,
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.html()).toContain('border-primary-600')
      expect(wrapper.html()).toContain('bg-primary-50')
    })

    it('highlights today', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.html()).toContain('bg-primary-600')
      expect(wrapper.html()).toContain('text-white')
    })
  })

  describe('Events Display', () => {
    it('displays events on calendar', () => {
      const events: CalendarEvent[] = [
        {
          id: '1',
          title: 'Test Event',
          date: new Date(),
        },
      ]

      const wrapper = mount(Calendar, {
        props: {
          events,
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.text()).toContain('Test Event')
    })

    it('limits event display to 2 per day', () => {
      const today = new Date()
      const events: CalendarEvent[] = [
        { id: '1', title: 'Event 1', date: today },
        { id: '2', title: 'Event 2', date: today },
        { id: '3', title: 'Event 3', date: today },
      ]

      const wrapper = mount(Calendar, {
        props: {
          events,
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.text()).toContain('Event 1')
      expect(wrapper.text()).toContain('Event 2')
      expect(wrapper.text()).toContain('+1 more')
    })

    it('applies custom color to events', () => {
      const events: CalendarEvent[] = [
        {
          id: '1',
          title: 'Custom Event',
          date: new Date(),
          color: '#ff0000',
        },
      ]

      const wrapper = mount(Calendar, {
        props: {
          events,
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.html()).toContain('background-color: rgb(255, 0, 0)')
    })

    it('emits event-click when event is clicked', async () => {
      const events: CalendarEvent[] = [
        {
          id: '1',
          title: 'Clickable Event',
          date: new Date(),
        },
      ]

      const wrapper = mount(Calendar, {
        props: {
          events,
        },
        global: {
          components: { Icon, Button },
        },
      })

      const eventElement = wrapper.findAll('.text-white').find((el) =>
        el.text().includes('Clickable Event')
      )

      if (eventElement) {
        await eventElement.trigger('click')
        await nextTick()

        expect(wrapper.emitted('event-click')).toBeTruthy()
      }
    })
  })

  describe('Date Constraints', () => {
    it('disables dates before minDate', () => {
      const minDate = new Date()
      minDate.setDate(minDate.getDate() + 5)

      const wrapper = mount(Calendar, {
        props: {
          events: [],
          minDate,
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.html()).toContain('cursor-not-allowed')
    })

    it('disables dates after maxDate', () => {
      const maxDate = new Date()
      maxDate.setDate(maxDate.getDate() - 5)

      const wrapper = mount(Calendar, {
        props: {
          events: [],
          maxDate,
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.html()).toContain('cursor-not-allowed')
    })

    it('does not emit events for disabled dates', async () => {
      const minDate = new Date()
      minDate.setDate(minDate.getDate() + 5)

      const wrapper = mount(Calendar, {
        props: {
          events: [],
          minDate,
        },
        global: {
          components: { Icon, Button },
        },
      })

      const disabledDays = wrapper.findAll('.cursor-not-allowed')
      if (disabledDays.length > 0) {
        await disabledDays[0].trigger('click')
        await nextTick()

        expect(wrapper.emitted('date-click')).toBeFalsy()
      }
    })
  })

  describe('Multiple Selection Mode', () => {
    it('supports multiple date selection', async () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
          mode: 'multiple',
          modelValue: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      const dayElements = wrapper.findAll('.cursor-pointer')
      if (dayElements.length > 1) {
        await dayElements[0].trigger('click')
        await nextTick()
        await dayElements[1].trigger('click')
        await nextTick()

        const emitted = wrapper.emitted('update:modelValue')
        expect(emitted).toBeTruthy()
        expect(emitted?.length).toBeGreaterThanOrEqual(2)
      }
    })

    it('toggles date selection in multiple mode', async () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
          mode: 'multiple',
          modelValue: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      const dayElements = wrapper.findAll('.cursor-pointer')
      if (dayElements.length > 0) {
        await dayElements[0].trigger('click')
        await nextTick()
        await dayElements[0].trigger('click')
        await nextTick()

        const emitted = wrapper.emitted('update:modelValue')
        expect(emitted).toBeTruthy()
      }
    })
  })

  describe('Week Configuration', () => {
    it('starts week with Sunday by default', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      const weekDays = wrapper.findAll('.text-center.text-xs.font-medium')
      expect(weekDays[0].text()).toBe('Su')
    })

    it('adjusts week start day', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
          firstDayOfWeek: 1, // Monday
        },
        global: {
          components: { Icon, Button },
        },
      })

      const weekDays = wrapper.findAll('.text-center.text-xs.font-medium')
      expect(weekDays[0].text()).toBe('Mo')
    })
  })

  describe('Disabled State', () => {
    it('disables navigation when disabled', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
          disabled: true,
        },
        global: {
          components: { Icon, Button },
        },
      })

      const prevButton = wrapper.find('[aria-label="Previous month"]')
      expect(prevButton.attributes('disabled')).toBeDefined()
    })

    it('disables date selection when disabled', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
          disabled: true,
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.html()).toContain('cursor-not-allowed')
    })
  })

  describe('Edge Cases', () => {
    it('handles empty events array', () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      expect(wrapper.exists()).toBe(true)
    })

    it('handles year transitions', async () => {
      const wrapper = mount(Calendar, {
        props: {
          events: [],
        },
        global: {
          components: { Icon, Button },
        },
      })

      // Navigate through 12 months to cross year boundary
      const nextButton = wrapper.find('[aria-label="Next month"]')
      for (let i = 0; i < 12; i++) {
        await nextButton.trigger('click')
        await nextTick()
      }

      expect(wrapper.text()).toMatch(/\d{4}/)
    })
  })
})
