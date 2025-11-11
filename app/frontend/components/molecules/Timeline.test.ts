import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Timeline from './Timeline.vue'

describe('Timeline', () => {
  const basicItems = [
    { title: 'Event 1', description: 'First event', timestamp: '2024-01-01' },
    { title: 'Event 2', description: 'Second event', timestamp: '2024-01-02' },
    { title: 'Event 3', description: 'Third event', timestamp: '2024-01-03' },
  ]

  describe('rendering', () => {
    it('renders all timeline items', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems },
      })

      expect(wrapper.text()).toContain('Event 1')
      expect(wrapper.text()).toContain('Event 2')
      expect(wrapper.text()).toContain('Event 3')
    })

    it('renders item descriptions', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems },
      })

      expect(wrapper.text()).toContain('First event')
      expect(wrapper.text()).toContain('Second event')
      expect(wrapper.text()).toContain('Third event')
    })

    it('renders timestamps', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems },
      })

      expect(wrapper.text()).toContain('2024-01-01')
      expect(wrapper.text()).toContain('2024-01-02')
      expect(wrapper.text()).toContain('2024-01-03')
    })

    it('renders without descriptions', () => {
      const items = [
        { title: 'Event 1', timestamp: '2024-01-01' },
        { title: 'Event 2', timestamp: '2024-01-02' },
      ]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      expect(wrapper.text()).toContain('Event 1')
      expect(wrapper.text()).toContain('Event 2')
    })

    it('renders without timestamps', () => {
      const items = [
        { title: 'Event 1', description: 'First event' },
        { title: 'Event 2', description: 'Second event' },
      ]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      expect(wrapper.text()).toContain('Event 1')
      expect(wrapper.text()).toContain('First event')
    })

    it('renders connecting lines', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems },
      })

      const lines = wrapper.findAll('.absolute.top-10')
      expect(lines.length).toBe(2) // 3 items = 2 connecting lines
    })

    it('does not render line after last item', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems },
      })

      const items = wrapper.findAll('.timeline-item')
      const lastItem = items[items.length - 1]

      expect(lastItem.find('.absolute.top-10').exists()).toBe(false)
    })
  })

  describe('icons', () => {
    it('renders custom icons', () => {
      const items = [
        { title: 'Created', icon: 'plus-circle' },
        { title: 'Updated', icon: 'edit' },
        { title: 'Deleted', icon: 'trash-2' },
      ]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons[0].props('name')).toBe('plus-circle')
      expect(icons[1].props('name')).toBe('edit')
      expect(icons[2].props('name')).toBe('trash-2')
    })

    it('renders without icons', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems },
      })

      // Should still have icon containers
      const iconContainers = wrapper.findAll('.w-10.h-10')
      expect(iconContainers.length).toBe(3)
    })

    it('applies white color to icons', () => {
      const items = [{ title: 'Event', icon: 'star' }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.classes()).toContain('text-white')
    })
  })

  describe('variants', () => {
    it('renders default variant', () => {
      const items = [{ title: 'Event', variant: 'default' as const }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const iconContainer = wrapper.find('.w-10.h-10')
      expect(iconContainer.classes()).toContain('bg-gray-400')
    })

    it('renders success variant', () => {
      const items = [{ title: 'Event', variant: 'success' as const }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const iconContainer = wrapper.find('.w-10.h-10')
      expect(iconContainer.classes()).toContain('bg-green-500')
    })

    it('renders warning variant', () => {
      const items = [{ title: 'Event', variant: 'warning' as const }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const iconContainer = wrapper.find('.w-10.h-10')
      expect(iconContainer.classes()).toContain('bg-yellow-500')
    })

    it('renders danger variant', () => {
      const items = [{ title: 'Event', variant: 'danger' as const }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const iconContainer = wrapper.find('.w-10.h-10')
      expect(iconContainer.classes()).toContain('bg-red-500')
    })

    it('renders info variant', () => {
      const items = [{ title: 'Event', variant: 'info' as const }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const iconContainer = wrapper.find('.w-10.h-10')
      expect(iconContainer.classes()).toContain('bg-blue-500')
    })

    it('applies correct badge variant', () => {
      const items = [{ title: 'Event', variant: 'success' as const, badge: 'New' }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const badge = wrapper.findComponent({ name: 'Badge' })
      expect(badge.props('variant')).toBe('success')
    })
  })

  describe('badges', () => {
    it('renders badge', () => {
      const items = [{ title: 'Event', badge: 'New' }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      expect(wrapper.text()).toContain('New')
      expect(wrapper.findComponent({ name: 'Badge' }).exists()).toBe(true)
    })

    it('renders without badge', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems },
      })

      expect(wrapper.findComponent({ name: 'Badge' }).exists()).toBe(false)
    })

    it('renders multiple badges', () => {
      const items = [
        { title: 'Event 1', badge: 'New' },
        { title: 'Event 2', badge: 'Updated' },
        { title: 'Event 3', badge: 'Completed' },
      ]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const badges = wrapper.findAllComponents({ name: 'Badge' })
      expect(badges.length).toBe(3)
    })
  })

  describe('positions', () => {
    it('renders left position by default', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems },
      })

      const timeline = wrapper.find('.timeline')
      expect(timeline.classes()).not.toContain('max-w-4xl')
      expect(timeline.classes()).not.toContain('mx-auto')
    })

    it('renders center position', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems, position: 'center' },
      })

      const timeline = wrapper.find('.timeline')
      expect(timeline.classes()).toContain('max-w-4xl')
      expect(timeline.classes()).toContain('mx-auto')
    })

    it('shows timestamp on left for center position', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems, position: 'center' },
      })

      // In center position, timestamps are in separate column
      const timestamps = wrapper.findAll('.text-right.text-sm')
      expect(timestamps.length).toBe(3)
    })

    it('shows timestamp below content for left position', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems, position: 'left' },
      })

      // In left position, timestamps are inside content card
      const timestamps = wrapper.findAll('.text-xs.text-gray-500')
      expect(timestamps.length).toBe(3)
    })

    it('applies correct line position for center', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems, position: 'center' },
      })

      const line = wrapper.find('.absolute.top-10')
      expect(line.classes()).toContain('left-1/2')
      expect(line.classes()).toContain('-translate-x-1/2')
    })

    it('applies correct line position for left', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems, position: 'left' },
      })

      const line = wrapper.find('.absolute.top-10')
      expect(line.classes()).toContain('left-5')
    })
  })

  describe('slots', () => {
    it('renders item slot', () => {
      const items = [{ title: 'Event 1' }]
      const wrapper = mount(Timeline, {
        props: { items },
        slots: {
          'item-0': '<div class="custom-content">Custom Content</div>',
        },
      })

      expect(wrapper.find('.custom-content').exists()).toBe(true)
      expect(wrapper.text()).toContain('Custom Content')
    })

    it('renders different slots for different items', () => {
      const items = [{ title: 'Event 1' }, { title: 'Event 2' }]
      const wrapper = mount(Timeline, {
        props: { items },
        slots: {
          'item-0': '<div class="slot-0">Slot 0</div>',
          'item-1': '<div class="slot-1">Slot 1</div>',
        },
      })

      expect(wrapper.find('.slot-0').exists()).toBe(true)
      expect(wrapper.find('.slot-1').exists()).toBe(true)
    })
  })

  describe('styling', () => {
    it('has white border on icon circles', () => {
      const items = [{ title: 'Event' }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const iconContainer = wrapper.find('.w-10.h-10')
      expect(iconContainer.classes()).toContain('border-4')
      expect(iconContainer.classes()).toContain('border-white')
    })

    it('has rounded icon circles', () => {
      const items = [{ title: 'Event' }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const iconContainer = wrapper.find('.w-10.h-10')
      expect(iconContainer.classes()).toContain('rounded-full')
    })

    it('has content cards with borders', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems },
      })

      const cards = wrapper.findAll('.rounded-lg.border')
      expect(cards.length).toBe(3)
    })
  })

  describe('edge cases', () => {
    it('handles single item', () => {
      const items = [{ title: 'Single Event' }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      expect(wrapper.text()).toContain('Single Event')
      expect(wrapper.findAll('.absolute.top-10').length).toBe(0)
    })

    it('handles many items', () => {
      const items = Array.from({ length: 10 }, (_, i) => ({
        title: `Event ${i + 1}`,
      }))
      const wrapper = mount(Timeline, {
        props: { items },
      })

      expect(wrapper.findAll('.timeline-item').length).toBe(10)
      expect(wrapper.findAll('.absolute.top-10').length).toBe(9)
    })

    it('handles empty items array', () => {
      const wrapper = mount(Timeline, {
        props: { items: [] },
      })

      expect(wrapper.findAll('.timeline-item').length).toBe(0)
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const items = [
        {
          title: 'Created',
          description: 'Project was created',
          timestamp: '2024-01-01 10:00',
          icon: 'plus-circle',
          variant: 'success' as const,
          badge: 'New',
        },
        {
          title: 'Updated',
          description: 'Made some changes',
          timestamp: '2024-01-02 14:30',
          icon: 'edit',
          variant: 'info' as const,
          badge: 'Updated',
        },
      ]
      const wrapper = mount(Timeline, {
        props: { items, position: 'center' },
      })

      expect(wrapper.text()).toContain('Created')
      expect(wrapper.text()).toContain('Updated')
      expect(wrapper.text()).toContain('Project was created')
      expect(wrapper.text()).toContain('New')
      expect(wrapper.findAllComponents({ name: 'Icon' }).length).toBe(2)
    })

    it('works with minimal props', () => {
      const items = [{ title: 'Event' }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      expect(wrapper.exists()).toBe(true)
      expect(wrapper.text()).toContain('Event')
    })
  })

  describe('layout', () => {
    it('removes bottom padding from last item', () => {
      const wrapper = mount(Timeline, {
        props: { items: basicItems },
      })

      const items = wrapper.findAll('.timeline-item')
      expect(items[0].classes()).toContain('pb-8')
      expect(items[items.length - 1].classes()).toContain('pb-0')
    })

    it('has z-index on icon circles', () => {
      const items = [{ title: 'Event' }]
      const wrapper = mount(Timeline, {
        props: { items },
      })

      const iconContainer = wrapper.find('.w-10.h-10')
      expect(iconContainer.classes()).toContain('z-10')
    })
  })
})
