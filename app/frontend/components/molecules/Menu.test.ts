import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Menu from './Menu.vue'
import type { MenuItem } from './Menu.vue'

const sampleItems: MenuItem[] = [
  { id: 1, label: 'Edit', icon: 'edit' },
  { id: 2, label: 'Duplicate', icon: 'copy' },
  { id: 3, label: 'Archive', icon: 'archive' },
  { id: 'sep1', label: '', separator: true },
  { id: 4, label: 'Delete', icon: 'trash', destructive: true },
]

describe('Menu', () => {
  // Basic Rendering Tests
  it('renders when modelValue is true', () => {
    const wrapper = mount(Menu, {
      props: { items: sampleItems, modelValue: true },
    })
    expect(wrapper.find('.menu').exists()).toBe(true)
  })

  it('does not render when modelValue is false', () => {
    const wrapper = mount(Menu, {
      props: { items: sampleItems, modelValue: false },
    })
    expect(wrapper.find('.menu').exists()).toBe(false)
  })

  it('renders all menu items', () => {
    const wrapper = mount(Menu, {
      props: { items: sampleItems, modelValue: true },
    })
    const menuItems = wrapper.findAll('.menu-item')
    // 4 regular items (excluding separator)
    expect(menuItems).toHaveLength(4)
  })

  it('renders item labels correctly', () => {
    const wrapper = mount(Menu, {
      props: { items: sampleItems, modelValue: true },
    })
    expect(wrapper.text()).toContain('Edit')
    expect(wrapper.text()).toContain('Duplicate')
    expect(wrapper.text()).toContain('Delete')
  })

  // Separator Tests
  it('renders separators', () => {
    const wrapper = mount(Menu, {
      props: { items: sampleItems, modelValue: true },
    })
    const separators = wrapper.findAll('.menu-separator')
    expect(separators).toHaveLength(1)
  })

  it('separator has correct role', () => {
    const wrapper = mount(Menu, {
      props: { items: sampleItems, modelValue: true },
    })
    const separator = wrapper.find('.menu-separator')
    expect(separator.attributes('role')).toBe('separator')
  })

  // Icon Tests
  it('renders icons for items with icon prop', () => {
    const wrapper = mount(Menu, {
      props: { items: [{ id: 1, label: 'Edit', icon: 'edit' }], modelValue: true },
    })
    const icon = wrapper.findComponent({ name: 'Icon' })
    expect(icon.exists()).toBe(true)
    expect(icon.props('name')).toBe('edit')
  })

  it('does not render icon when icon prop is not provided', () => {
    const wrapper = mount(Menu, {
      props: { items: [{ id: 1, label: 'No Icon' }], modelValue: true },
    })
    const icons = wrapper.findAllComponents({ name: 'Icon' })
    expect(icons).toHaveLength(0)
  })

  // Disabled Item Tests
  it('applies disabled styling to disabled items', () => {
    const wrapper = mount(Menu, {
      props: {
        items: [{ id: 1, label: 'Disabled', disabled: true }],
        modelValue: true,
      },
    })
    const menuItem = wrapper.find('.menu-item')
    expect(menuItem.classes()).toContain('text-gray-400')
    expect(menuItem.classes()).toContain('cursor-not-allowed')
  })

  it('disabled items have disabled attribute', () => {
    const wrapper = mount(Menu, {
      props: {
        items: [{ id: 1, label: 'Disabled', disabled: true }],
        modelValue: true,
      },
    })
    const menuItem = wrapper.find('.menu-item')
    expect(menuItem.attributes('disabled')).toBe('')
  })

  it('disabled items have aria-disabled attribute', () => {
    const wrapper = mount(Menu, {
      props: {
        items: [{ id: 1, label: 'Disabled', disabled: true }],
        modelValue: true,
      },
    })
    const menuItem = wrapper.find('.menu-item')
    expect(menuItem.attributes('aria-disabled')).toBe('true')
  })

  it('does not emit select when disabled item is clicked', async () => {
    const wrapper = mount(Menu, {
      props: {
        items: [{ id: 1, label: 'Disabled', disabled: true }],
        modelValue: true,
      },
    })
    const menuItem = wrapper.find('.menu-item')
    await menuItem.trigger('click')

    expect(wrapper.emitted('select')).toBeFalsy()
  })

  // Destructive Item Tests
  it('applies destructive styling to destructive items', () => {
    const wrapper = mount(Menu, {
      props: {
        items: [{ id: 1, label: 'Delete', destructive: true }],
        modelValue: true,
      },
    })
    const menuItem = wrapper.find('.menu-item')
    expect(menuItem.classes()).toContain('text-red-600')
  })

  // Click Tests
  it('emits select event when item is clicked', async () => {
    const wrapper = mount(Menu, {
      props: { items: [{ id: 1, label: 'Test' }], modelValue: true },
    })
    const menuItem = wrapper.find('.menu-item')
    await menuItem.trigger('click')

    expect(wrapper.emitted('select')).toBeTruthy()
    expect(wrapper.emitted('select')?.[0][0]).toEqual({ id: 1, label: 'Test' })
  })

  it('emits update:modelValue to close menu on item click', async () => {
    const wrapper = mount(Menu, {
      props: { items: [{ id: 1, label: 'Test' }], modelValue: true, closeOnClick: true },
    })
    const menuItem = wrapper.find('.menu-item')
    await menuItem.trigger('click')

    expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])
  })

  it('does not close menu when closeOnClick is false', async () => {
    const wrapper = mount(Menu, {
      props: { items: [{ id: 1, label: 'Test' }], modelValue: true, closeOnClick: false },
    })
    const menuItem = wrapper.find('.menu-item')
    await menuItem.trigger('click')

    expect(wrapper.emitted('update:modelValue')).toBeFalsy()
    expect(wrapper.emitted('select')).toBeTruthy()
  })

  // Shortcut Tests
  it('renders keyboard shortcuts', () => {
    const wrapper = mount(Menu, {
      props: {
        items: [{ id: 1, label: 'Save', shortcut: '⌘S' }],
        modelValue: true,
      },
    })
    expect(wrapper.text()).toContain('⌘S')
  })

  it('shortcut has correct styling', () => {
    const wrapper = mount(Menu, {
      props: {
        items: [{ id: 1, label: 'Save', shortcut: '⌘S' }],
        modelValue: true,
      },
    })
    const shortcut = wrapper.find('.text-xs.text-gray-400')
    expect(shortcut.exists()).toBe(true)
    expect(shortcut.text()).toBe('⌘S')
  })

  // Keyboard Navigation Tests
  it('closes menu on Escape key', async () => {
    const wrapper = mount(Menu, {
      props: { items: sampleItems, modelValue: true },
      attachTo: document.body,
    })

    await wrapper.trigger('keydown', { key: 'Escape' })

    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([false])

    wrapper.unmount()
  })

  it('navigates down with ArrowDown key', async () => {
    const wrapper = mount(Menu, {
      props: {
        items: [
          { id: 1, label: 'Item 1' },
          { id: 2, label: 'Item 2' },
        ],
        modelValue: true,
      },
      attachTo: document.body,
    })

    const event = new KeyboardEvent('keydown', { key: 'ArrowDown' })
    document.dispatchEvent(event)
    await wrapper.vm.$nextTick()

    // First item should be focused
    const items = wrapper.findAll('.menu-item')
    expect(items[0].classes()).toContain('bg-gray-100')

    wrapper.unmount()
  })

  it('navigates up with ArrowUp key', async () => {
    const wrapper = mount(Menu, {
      props: {
        items: [
          { id: 1, label: 'Item 1' },
          { id: 2, label: 'Item 2' },
        ],
        modelValue: true,
      },
      attachTo: document.body,
    })

    const event = new KeyboardEvent('keydown', { key: 'ArrowUp' })
    document.dispatchEvent(event)
    await wrapper.vm.$nextTick()

    // Last item should be focused
    const items = wrapper.findAll('.menu-item')
    expect(items[1].classes()).toContain('bg-gray-100')

    wrapper.unmount()
  })

  it('selects focused item with Enter key', async () => {
    const wrapper = mount(Menu, {
      props: {
        items: [{ id: 1, label: 'Test' }],
        modelValue: true,
      },
      attachTo: document.body,
    })

    // Focus first item
    const downEvent = new KeyboardEvent('keydown', { key: 'ArrowDown' })
    document.dispatchEvent(downEvent)
    await wrapper.vm.$nextTick()

    // Select with Enter
    const enterEvent = new KeyboardEvent('keydown', { key: 'Enter' })
    document.dispatchEvent(enterEvent)
    await wrapper.vm.$nextTick()

    expect(wrapper.emitted('select')).toBeTruthy()

    wrapper.unmount()
  })

  it('selects focused item with Space key', async () => {
    const wrapper = mount(Menu, {
      props: {
        items: [{ id: 1, label: 'Test' }],
        modelValue: true,
      },
      attachTo: document.body,
    })

    // Focus first item
    const downEvent = new KeyboardEvent('keydown', { key: 'ArrowDown' })
    document.dispatchEvent(downEvent)
    await wrapper.vm.$nextTick()

    // Select with Space
    const spaceEvent = new KeyboardEvent('keydown', { key: ' ' })
    document.dispatchEvent(spaceEvent)
    await wrapper.vm.$nextTick()

    expect(wrapper.emitted('select')).toBeTruthy()

    wrapper.unmount()
  })

  // Accessibility Tests
  it('has correct role attribute', () => {
    const wrapper = mount(Menu, {
      props: { items: sampleItems, modelValue: true },
    })
    expect(wrapper.find('.menu').attributes('role')).toBe('menu')
  })

  it('has correct aria-orientation', () => {
    const wrapper = mount(Menu, {
      props: { items: sampleItems, modelValue: true },
    })
    expect(wrapper.find('.menu').attributes('aria-orientation')).toBe('vertical')
  })

  it('menu items have role="menuitem"', () => {
    const wrapper = mount(Menu, {
      props: { items: [{ id: 1, label: 'Test' }], modelValue: true },
    })
    const menuItem = wrapper.find('.menu-item')
    expect(menuItem.attributes('role')).toBe('menuitem')
  })

  it('menu items have type="button"', () => {
    const wrapper = mount(Menu, {
      props: { items: [{ id: 1, label: 'Test' }], modelValue: true },
    })
    const menuItem = wrapper.find('.menu-item')
    expect(menuItem.attributes('type')).toBe('button')
  })

  // Edge Cases
  it('handles empty items array', () => {
    const wrapper = mount(Menu, {
      props: { items: [], modelValue: true },
    })
    expect(wrapper.find('.menu').exists()).toBe(true)
    expect(wrapper.findAll('.menu-item')).toHaveLength(0)
  })

  it('handles items with only separators', () => {
    const wrapper = mount(Menu, {
      props: {
        items: [
          { id: 1, label: '', separator: true },
          { id: 2, label: '', separator: true },
        ],
        modelValue: true,
      },
    })
    expect(wrapper.findAll('.menu-separator')).toHaveLength(2)
    expect(wrapper.findAll('.menu-item')).toHaveLength(0)
  })

  it('skips disabled items in keyboard navigation', async () => {
    const wrapper = mount(Menu, {
      props: {
        items: [
          { id: 1, label: 'Item 1' },
          { id: 2, label: 'Item 2', disabled: true },
          { id: 3, label: 'Item 3' },
        ],
        modelValue: true,
      },
      attachTo: document.body,
    })

    // Navigate with arrow keys - should skip disabled item
    const event = new KeyboardEvent('keydown', { key: 'ArrowDown' })
    document.dispatchEvent(event)
    await wrapper.vm.$nextTick()

    const items = wrapper.findAll('.menu-item')
    // First non-disabled item should be focused
    expect(items[0].classes()).toContain('bg-gray-100')

    wrapper.unmount()
  })

  it('does not select separator items', async () => {
    const items: MenuItem[] = [
      { id: 1, label: 'Item 1' },
      { id: 'sep', label: '', separator: true },
      { id: 2, label: 'Item 2' },
    ]
    const wrapper = mount(Menu, {
      props: { items, modelValue: true },
    })

    // Try clicking separator (though it's not rendered as a button)
    const separator = wrapper.find('.menu-separator')
    await separator.trigger('click')

    expect(wrapper.emitted('select')).toBeFalsy()
  })
})
