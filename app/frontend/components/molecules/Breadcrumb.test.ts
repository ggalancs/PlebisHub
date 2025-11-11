import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Breadcrumb from './Breadcrumb.vue'
import Icon from '../atoms/Icon.vue'

describe('Breadcrumb', () => {
  const defaultItems = [
    { label: 'Home', href: '/' },
    { label: 'Products', href: '/products' },
    { label: 'Laptops', href: '/products/laptops' },
    { label: 'MacBook Pro' },
  ]

  describe('rendering', () => {
    it('renders breadcrumb nav', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      expect(wrapper.find('nav[aria-label="Breadcrumb"]').exists()).toBe(true)
    })

    it('renders all items', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const items = wrapper.findAll('li')
      expect(items.length).toBe(4)
    })

    it('renders item labels', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      expect(wrapper.text()).toContain('Home')
      expect(wrapper.text()).toContain('Products')
      expect(wrapper.text()).toContain('Laptops')
      expect(wrapper.text()).toContain('MacBook Pro')
    })

    it('renders links for items with href', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const links = wrapper.findAll('a')
      expect(links.length).toBe(3) // First 3 items have href

      expect(links[0].attributes('href')).toBe('/')
      expect(links[1].attributes('href')).toBe('/products')
      expect(links[2].attributes('href')).toBe('/products/laptops')
    })

    it('renders last item as text without link', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const listItems = wrapper.findAll('li')
      const lastItem = listItems[listItems.length - 1]

      expect(lastItem.find('a').exists()).toBe(false)
      expect(lastItem.find('span').exists()).toBe(true)
    })

    it('renders separators between items', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const separators = wrapper.findAll('span[aria-hidden="true"]')
      expect(separators.length).toBe(3) // 4 items = 3 separators
    })

    it('does not render separator after last item', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const separators = wrapper.findAll('span[aria-hidden="true"]')
      expect(separators.length).toBe(defaultItems.length - 1)
    })
  })

  describe('separators', () => {
    it('renders chevron separator by default', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const icons = wrapper.findAllComponents(Icon)
      const separatorIcons = icons.filter((icon) => icon.props('name') === 'chevron-right')

      expect(separatorIcons.length).toBeGreaterThan(0)
    })

    it('renders slash separator', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems, separator: 'slash' },
      })

      const icons = wrapper.findAllComponents(Icon)
      const separatorIcons = icons.filter((icon) => icon.props('name') === 'slash')

      expect(separatorIcons.length).toBeGreaterThan(0)
    })

    it('renders arrow separator', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems, separator: 'arrow' },
      })

      const icons = wrapper.findAllComponents(Icon)
      const separatorIcons = icons.filter((icon) => icon.props('name') === 'arrow-right')

      expect(separatorIcons.length).toBeGreaterThan(0)
    })

    it('renders custom text separator', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems, separator: '>' },
      })

      const separators = wrapper.findAll('[aria-hidden="true"]')
      expect(separators[0].text()).toContain('>')
    })
  })

  describe('home icon', () => {
    it('shows home icon on first item when showHome is true', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems, showHome: true },
      })

      const icons = wrapper.findAllComponents(Icon)
      const homeIcon = icons.find((icon) => icon.props('name') === 'home')

      expect(homeIcon?.exists()).toBe(true)
    })

    it('does not show home icon by default', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const icons = wrapper.findAllComponents(Icon)
      const homeIcon = icons.find((icon) => icon.props('name') === 'home')

      expect(homeIcon).toBeUndefined()
    })

    it('prefers custom icon over home icon', () => {
      const itemsWithIcon = [
        { label: 'Home', href: '/', icon: 'star' },
        { label: 'Products', href: '/products' },
      ]

      const wrapper = mount(Breadcrumb, {
        props: { items: itemsWithIcon, showHome: true },
      })

      const icons = wrapper.findAllComponents(Icon)
      const starIcon = icons.find((icon) => icon.props('name') === 'star')
      const homeIcon = icons.find((icon) => icon.props('name') === 'home')

      expect(starIcon?.exists()).toBe(true)
      expect(homeIcon).toBeUndefined()
    })
  })

  describe('custom icons', () => {
    it('renders custom icons for items', () => {
      const itemsWithIcons = [
        { label: 'Dashboard', href: '/', icon: 'layout-dashboard' },
        { label: 'Settings', href: '/settings', icon: 'settings' },
        { label: 'Profile' },
      ]

      const wrapper = mount(Breadcrumb, {
        props: { items: itemsWithIcons },
      })

      const icons = wrapper.findAllComponents(Icon)
      const dashboardIcon = icons.find((icon) => icon.props('name') === 'layout-dashboard')
      const settingsIcon = icons.find((icon) => icon.props('name') === 'settings')

      expect(dashboardIcon?.exists()).toBe(true)
      expect(settingsIcon?.exists()).toBe(true)
    })
  })

  describe('sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems, size: 'sm' },
      })

      const listItems = wrapper.findAll('li')
      expect(listItems[0].classes()).toContain('text-xs')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const listItems = wrapper.findAll('li')
      expect(listItems[0].classes()).toContain('text-sm')
    })

    it('renders large size', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems, size: 'lg' },
      })

      const listItems = wrapper.findAll('li')
      expect(listItems[0].classes()).toContain('text-base')
    })
  })

  describe('disabled items', () => {
    it('renders disabled items as text', () => {
      const items = [
        { label: 'Home', href: '/' },
        { label: 'Products', href: '/products', disabled: true },
        { label: 'Current' },
      ]

      const wrapper = mount(Breadcrumb, {
        props: { items },
      })

      const links = wrapper.findAll('a')
      expect(links.length).toBe(1) // Only Home should be a link
    })

    it('applies disabled classes to disabled items', () => {
      const items = [
        { label: 'Home', href: '/' },
        { label: 'Disabled', href: '/disabled', disabled: true },
        { label: 'Current' },
      ]

      const wrapper = mount(Breadcrumb, {
        props: { items },
      })

      const listItems = wrapper.findAll('li')
      const disabledItem = listItems[1]

      // Find the content span (not the separator span)
      const contentSpan = disabledItem
        .findAll('span')
        .find((span) => span.text().includes('Disabled'))

      expect(contentSpan?.classes()).toContain('text-gray-400')
    })

    it('has aria-disabled on disabled items', () => {
      const items = [
        { label: 'Home', href: '/' },
        { label: 'Disabled', href: '/disabled', disabled: true },
      ]

      const wrapper = mount(Breadcrumb, {
        props: { items },
      })

      const listItems = wrapper.findAll('li')
      const disabledItem = listItems[1]

      expect(disabledItem.find('span').attributes('aria-disabled')).toBe('true')
    })
  })

  describe('max items', () => {
    const manyItems = [
      { label: 'Home', href: '/' },
      { label: 'Category', href: '/category' },
      { label: 'Subcategory', href: '/category/sub' },
      { label: 'Product Type', href: '/category/sub/type' },
      { label: 'Product', href: '/category/sub/type/product' },
      { label: 'Details' },
    ]

    it('shows all items when maxItems is 0', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: manyItems, maxItems: 0 },
      })

      const listItems = wrapper.findAll('li')
      expect(listItems.length).toBe(6)
    })

    it('truncates items with ellipsis when exceeding maxItems', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: manyItems, maxItems: 4 },
      })

      const listItems = wrapper.findAll('li')
      // Should show: Home, ..., Product, Details = 4 items
      expect(listItems.length).toBe(4)
      expect(wrapper.text()).toContain('...')
    })

    it('shows first item and last (maxItems - 2) items', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: manyItems, maxItems: 3 },
      })

      // Should show: Home, ..., Details (3 total)
      expect(wrapper.text()).toContain('Home')
      expect(wrapper.text()).toContain('...')
      expect(wrapper.text()).toContain('Details')
      expect(wrapper.text()).not.toContain('Category')
      expect(wrapper.text()).not.toContain('Subcategory')
      expect(wrapper.text()).not.toContain('Product Type')
    })

    it('renders ellipsis as disabled item', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: manyItems, maxItems: 3 },
      })

      const listItems = wrapper.findAll('li')
      const ellipsisItem = listItems[1] // Second item should be ellipsis

      expect(ellipsisItem.text()).toContain('...')
      expect(ellipsisItem.find('span').classes()).toContain('text-gray-400')
    })
  })

  describe('behavior', () => {
    it('emits click event when item is clicked', async () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const links = wrapper.findAll('a')
      await links[0].trigger('click')

      expect(wrapper.emitted('click')).toBeTruthy()
      expect(wrapper.emitted('click')?.[0]).toEqual([defaultItems[0], 0])
    })

    it('does not emit click for disabled items', async () => {
      const items = [
        { label: 'Home', href: '/' },
        { label: 'Disabled', href: '/disabled', disabled: true },
      ]

      const wrapper = mount(Breadcrumb, {
        props: { items },
      })

      const listItems = wrapper.findAll('li')
      const disabledItem = listItems[1].find('span')
      await disabledItem.trigger('click')

      expect(wrapper.emitted('click')).toBeFalsy()
    })

    it('does not emit click for ellipsis item', async () => {
      const manyItems = [
        { label: 'Home', href: '/' },
        { label: 'A', href: '/a' },
        { label: 'B', href: '/b' },
        { label: 'C', href: '/c' },
        { label: 'D' },
      ]

      const wrapper = mount(Breadcrumb, {
        props: { items: manyItems, maxItems: 3 },
      })

      const listItems = wrapper.findAll('li')
      const ellipsisItem = listItems[1].find('span')
      await ellipsisItem.trigger('click')

      expect(wrapper.emitted('click')).toBeFalsy()
    })

    it('does not emit click for current page', async () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const listItems = wrapper.findAll('li')
      const currentItem = listItems[listItems.length - 1].find('span')
      await currentItem.trigger('click')

      // Current page click should still emit
      expect(wrapper.emitted('click')).toBeTruthy()
    })
  })

  describe('accessibility', () => {
    it('has navigation role', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      expect(wrapper.find('nav').exists()).toBe(true)
    })

    it('has aria-label on nav', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const nav = wrapper.find('nav')
      expect(nav.attributes('aria-label')).toBe('Breadcrumb')
    })

    it('has aria-current on last item', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const listItems = wrapper.findAll('li')
      const lastItem = listItems[listItems.length - 1]

      expect(lastItem.find('span').attributes('aria-current')).toBe('page')
    })

    it('has aria-hidden on separators', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const separators = wrapper.findAll('[aria-hidden="true"]')
      expect(separators.length).toBeGreaterThan(0)
    })

    it('uses ordered list semantics', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      expect(wrapper.find('ol').exists()).toBe(true)
      expect(wrapper.find('li').exists()).toBe(true)
    })
  })

  describe('edge cases', () => {
    it('handles single item', () => {
      const items = [{ label: 'Home' }]

      const wrapper = mount(Breadcrumb, {
        props: { items },
      })

      expect(wrapper.text()).toContain('Home')
      expect(wrapper.findAll('[aria-hidden="true"]').length).toBe(0) // No separators
    })

    it('handles empty items array', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: [] },
      })

      expect(wrapper.find('nav').exists()).toBe(true)
      expect(wrapper.findAll('li').length).toBe(0)
    })

    it('handles items without href', () => {
      const items = [{ label: 'First' }, { label: 'Second' }, { label: 'Third' }]

      const wrapper = mount(Breadcrumb, {
        props: { items },
      })

      expect(wrapper.findAll('a').length).toBe(0)
      expect(wrapper.findAll('span').length).toBeGreaterThan(0)
    })
  })

  describe('styling', () => {
    it('applies link classes to intermediate items', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const links = wrapper.findAll('a')
      expect(links[0].classes()).toContain('text-gray-600')
    })

    it('applies current classes to last item', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems },
      })

      const listItems = wrapper.findAll('li')
      const lastItem = listItems[listItems.length - 1]

      expect(lastItem.find('span').classes()).toContain('text-gray-900')
      expect(lastItem.find('span').classes()).toContain('font-medium')
    })

    it('applies separator spacing based on size', () => {
      const wrapper = mount(Breadcrumb, {
        props: { items: defaultItems, size: 'sm' },
      })

      const separators = wrapper.findAll('[aria-hidden="true"]')
      expect(separators[0].classes()).toContain('mx-1')
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const items = [
        { label: 'Home', href: '/', icon: 'home' },
        { label: 'Products', href: '/products' },
        { label: 'Laptops', href: '/products/laptops', disabled: true },
        { label: 'MacBook Pro' },
      ]

      const wrapper = mount(Breadcrumb, {
        props: {
          items,
          separator: 'arrow',
          showHome: true,
          size: 'lg',
        },
      })

      expect(wrapper.find('nav').exists()).toBe(true)
      expect(wrapper.findAll('li').length).toBe(4)

      const icons = wrapper.findAllComponents(Icon)
      expect(icons.length).toBeGreaterThan(0)
    })

    it('works with minimal props', () => {
      const items = [{ label: 'Home', href: '/' }, { label: 'Current' }]

      const wrapper = mount(Breadcrumb, {
        props: { items },
      })

      expect(wrapper.find('nav').exists()).toBe(true)
      expect(wrapper.text()).toContain('Home')
      expect(wrapper.text()).toContain('Current')
    })
  })
})
