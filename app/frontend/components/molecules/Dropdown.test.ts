import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import Dropdown from './Dropdown.vue'

describe('Dropdown', () => {
  const defaultItems = [
    { key: 'edit', label: 'Edit', icon: 'edit' },
    { key: 'duplicate', label: 'Duplicate', icon: 'copy' },
    { key: 'delete', label: 'Delete', icon: 'trash', danger: true },
  ]

  beforeEach(() => {
    // Mock document event listeners
    document.addEventListener = vi.fn()
    document.removeEventListener = vi.fn()
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  describe('rendering', () => {
    it('renders trigger button', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      expect(wrapper.find('button').exists()).toBe(true)
    })

    it('renders trigger label', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems, label: 'Actions' },
      })

      expect(wrapper.text()).toContain('Actions')
    })

    it('renders trigger icon', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems, icon: 'settings' },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBeGreaterThan(0)
    })

    it('renders chevron icon', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      const chevron = icons.find((icon) => icon.props('name') === 'chevron-down')
      expect(chevron?.exists()).toBe(true)
    })

    it('hides dropdown menu by default', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const menu = wrapper.find('[role="menu"]')
      expect(menu.isVisible()).toBe(false)
    })
  })

  describe('toggle behavior', () => {
    it('opens dropdown on click', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const menu = wrapper.find('[role="menu"]')
      expect(menu.isVisible()).toBe(true)
    })

    it('closes dropdown on second click', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')
      await trigger.trigger('click')

      const menu = wrapper.find('[role="menu"]')
      expect(menu.isVisible()).toBe(false)
    })

    it('changes chevron icon when open', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      const chevron = icons.find((icon) => icon.props('name') === 'chevron-up')
      expect(chevron?.exists()).toBe(true)
    })
  })

  describe('menu items', () => {
    it('renders all menu items', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const items = wrapper.findAll('[role="menuitem"]')
      expect(items.length).toBe(3)
    })

    it('renders item labels', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      expect(wrapper.text()).toContain('Edit')
      expect(wrapper.text()).toContain('Duplicate')
      expect(wrapper.text()).toContain('Delete')
    })

    it('renders item icons', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      // Should have trigger icons + menu item icons
      expect(icons.length).toBeGreaterThan(3)
    })

    it('renders item badges', async () => {
      const items = [
        { key: 'inbox', label: 'Inbox', badge: 5 },
        { key: 'sent', label: 'Sent' },
      ]

      const wrapper = mount(Dropdown, {
        props: { items },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      expect(wrapper.text()).toContain('5')
    })

    it('renders dividers', async () => {
      const items = [
        { key: 'edit', label: 'Edit', divider: true },
        { key: 'delete', label: 'Delete' },
      ]

      const wrapper = mount(Dropdown, {
        props: { items },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const divider = wrapper.find('[role="separator"]')
      expect(divider.exists()).toBe(true)
    })

    it('applies danger styling to danger items', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const items = wrapper.findAll('[role="menuitem"]')
      const deleteItem = items[2]
      expect(deleteItem.classes()).toContain('text-red-600')
    })
  })

  describe('item selection', () => {
    it('emits select event when item clicked', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const items = wrapper.findAll('[role="menuitem"]')
      await items[0].trigger('click')

      expect(wrapper.emitted('select')).toBeTruthy()
      expect(wrapper.emitted('select')?.[0]).toEqual([defaultItems[0]])
    })

    it('closes dropdown after item selection', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const items = wrapper.findAll('[role="menuitem"]')
      await items[0].trigger('click')

      const menu = wrapper.find('[role="menu"]')
      expect(menu.isVisible()).toBe(false)
    })

    it('does not emit when disabled item clicked', async () => {
      const items = [
        { key: 'edit', label: 'Edit' },
        { key: 'delete', label: 'Delete', disabled: true },
      ]

      const wrapper = mount(Dropdown, {
        props: { items },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const menuItems = wrapper.findAll('[role="menuitem"]')
      await menuItems[1].trigger('click')

      expect(wrapper.emitted('select')).toBeFalsy()
    })
  })

  describe('disabled state', () => {
    it('renders disabled trigger button', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems, disabled: true },
      })

      const trigger = wrapper.find('button')
      expect(trigger.element.disabled).toBe(true)
      expect(trigger.classes()).toContain('opacity-50')
    })

    it('does not open when disabled', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems, disabled: true },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const menu = wrapper.find('[role="menu"]')
      expect(menu.isVisible()).toBe(false)
    })

    it('renders disabled menu items', async () => {
      const items = [
        { key: 'edit', label: 'Edit' },
        { key: 'delete', label: 'Delete', disabled: true },
      ]

      const wrapper = mount(Dropdown, {
        props: { items },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const menuItems = wrapper.findAll('[role="menuitem"]')
      expect(menuItems[1].attributes('aria-disabled')).toBe('true')
      expect(menuItems[1].classes()).toContain('text-gray-400')
    })
  })

  describe('sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems, size: 'sm' },
      })

      const trigger = wrapper.find('button')
      expect(trigger.classes()).toContain('text-sm')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      expect(trigger.classes()).toContain('text-base')
    })

    it('renders large size', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems, size: 'lg' },
      })

      const trigger = wrapper.find('button')
      expect(trigger.classes()).toContain('text-lg')
    })
  })

  describe('placement', () => {
    it('renders bottom-start by default', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const menu = wrapper.find('[role="menu"]')
      expect(menu.classes()).toContain('left-0')
      expect(menu.classes()).toContain('mt-2')
    })

    it('renders bottom-end placement', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems, placement: 'bottom-end' },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const menu = wrapper.find('[role="menu"]')
      expect(menu.classes()).toContain('right-0')
    })

    it('renders top-start placement', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems, placement: 'top-start' },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const menu = wrapper.find('[role="menu"]')
      expect(menu.classes()).toContain('bottom-full')
      expect(menu.classes()).toContain('mb-2')
    })

    it('renders top-end placement', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems, placement: 'top-end' },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const menu = wrapper.find('[role="menu"]')
      expect(menu.classes()).toContain('right-0')
      expect(menu.classes()).toContain('bottom-full')
    })
  })

  describe('full width', () => {
    it('renders full width trigger', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems, fullWidth: true },
      })

      const trigger = wrapper.find('button')
      expect(trigger.classes()).toContain('w-full')
    })

    it('does not render full width by default', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      expect(trigger.classes()).not.toContain('w-full')
    })
  })

  describe('accessibility', () => {
    it('has proper ARIA attributes', () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      expect(trigger.attributes('aria-expanded')).toBe('false')
      expect(trigger.attributes('aria-haspopup')).toBe('true')
    })

    it('updates aria-expanded when opened', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      expect(trigger.attributes('aria-expanded')).toBe('true')
    })

    it('has role="menu" on dropdown', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const menu = wrapper.find('[role="menu"]')
      expect(menu.exists()).toBe(true)
    })

    it('has role="menuitem" on items', async () => {
      const wrapper = mount(Dropdown, {
        props: { items: defaultItems },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const items = wrapper.findAll('[role="menuitem"]')
      expect(items.length).toBe(3)
    })

    it('has role="separator" on dividers', async () => {
      const items = [
        { key: 'edit', label: 'Edit', divider: true },
        { key: 'delete', label: 'Delete' },
      ]

      const wrapper = mount(Dropdown, {
        props: { items },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      const separator = wrapper.find('[role="separator"]')
      expect(separator.exists()).toBe(true)
    })
  })

  describe('combinations', () => {
    it('renders with all features', async () => {
      const items = [
        { key: 'edit', label: 'Edit', icon: 'edit', badge: 3 },
        { key: 'view', label: 'View', icon: 'eye', divider: true },
        { key: 'delete', label: 'Delete', icon: 'trash', danger: true, disabled: true },
      ]

      const wrapper = mount(Dropdown, {
        props: {
          items,
          label: 'Actions',
          icon: 'more-vertical',
          size: 'lg',
          placement: 'bottom-end',
        },
      })

      const trigger = wrapper.find('button')
      await trigger.trigger('click')

      expect(wrapper.find('[role="menu"]').exists()).toBe(true)
      expect(wrapper.findAll('[role="menuitem"]').length).toBe(3)
      expect(wrapper.find('[role="separator"]').exists()).toBe(true)
    })

    it('works with minimal props', () => {
      const items = [{ key: 'action', label: 'Action' }]

      const wrapper = mount(Dropdown, {
        props: { items },
      })

      expect(wrapper.find('button').exists()).toBe(true)
      expect(wrapper.text()).toContain('Options')
    })
  })
})
