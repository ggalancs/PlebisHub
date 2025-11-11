import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ListItem from './ListItem.vue'
import Icon from '../atoms/Icon.vue'

describe('ListItem', () => {
  // Basic rendering
  describe('Basic Rendering', () => {
    it('renders with title', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item Title',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Item Title')
    })

    it('renders with subtitle', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Title',
          subtitle: 'Subtitle text',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Subtitle text')
    })

    it('renders as div by default', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.element.tagName).toBe('DIV')
    })

    it('renders as anchor when href provided', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          href: '/path',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.element.tagName).toBe('A')
      expect(wrapper.attributes('href')).toBe('/path')
    })

    it('renders as button when clickable', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          clickable: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.element.tagName).toBe('BUTTON')
    })
  })

  // Icon
  describe('Icon', () => {
    it('renders icon when provided', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          icon: 'user',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(true)
      expect(wrapper.findComponent(Icon).props('name')).toBe('user')
    })

    it('does not render icon by default', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAllComponents(Icon)).toHaveLength(0)
    })
  })

  // Avatar
  describe('Avatar', () => {
    it('renders avatar when provided', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          avatar: '/avatar.jpg',
        },
        global: {
          components: { Icon },
        },
      })

      const img = wrapper.find('img')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('/avatar.jpg')
    })

    it('applies rounded-full to avatar', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          avatar: '/avatar.jpg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('img').classes()).toContain('rounded-full')
    })

    it('uses avatarAlt for alt text', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          avatar: '/avatar.jpg',
          avatarAlt: 'User avatar',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('img').attributes('alt')).toBe('User avatar')
    })
  })

  // Badge
  describe('Badge', () => {
    it('renders badge when provided', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          badge: '5',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('5')
    })

    it('does not render badge by default', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('.rounded-full').exists()).toBe(false)
    })
  })

  // Chevron
  describe('Chevron', () => {
    it('renders chevron when enabled', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          chevron: true,
        },
        global: {
          components: { Icon },
        },
      })

      const chevron = wrapper.findComponent(Icon)
      expect(chevron.exists()).toBe(true)
      expect(chevron.props('name')).toBe('chevron-right')
    })

    it('does not render chevron by default', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAllComponents(Icon)).toHaveLength(0)
    })
  })

  // Sizes
  describe('Sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          size: 'sm',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('px-3')
      expect(wrapper.classes()).toContain('py-2')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('px-4')
      expect(wrapper.classes()).toContain('py-3')
    })

    it('renders large size', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('px-4')
      expect(wrapper.classes()).toContain('py-4')
    })
  })

  // Active state
  describe('Active State', () => {
    it('does not apply active styling by default', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).not.toContain('bg-primary/10')
    })

    it('applies active styling when active', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          active: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-primary/10')
    })
  })

  // Disabled state
  describe('Disabled State', () => {
    it('does not apply disabled styling by default', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).not.toContain('opacity-50')
    })

    it('applies disabled styling when disabled', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('opacity-50')
    })

    it('disables button when clickable and disabled', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          clickable: true,
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.attributes('disabled')).toBeDefined()
    })
  })

  // Divider
  describe('Divider', () => {
    it('does not show divider by default', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).not.toContain('border-b')
    })

    it('shows divider when enabled', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          divider: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('border-b')
    })
  })

  // Click events
  describe('Click Events', () => {
    it('emits click event when clicked', async () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          clickable: true,
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.trigger('click')

      expect(wrapper.emitted('click')).toBeTruthy()
    })

    it('does not emit click when disabled', async () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          clickable: true,
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.trigger('click')

      expect(wrapper.emitted('click')).toBeFalsy()
    })
  })

  // Hover effects
  describe('Hover Effects', () => {
    it('applies hover effect for clickable items', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          clickable: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('hover:bg-gray-50')
      expect(wrapper.classes()).toContain('cursor-pointer')
    })

    it('applies hover effect for links', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          href: '/path',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('hover:bg-gray-50')
    })

    it('does not apply hover effect for static items', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).not.toContain('hover:bg-gray-50')
    })
  })

  // Slots
  describe('Slots', () => {
    it('renders default slot for title', () => {
      const wrapper = mount(ListItem, {
        slots: {
          default: '<strong>Custom Title</strong>',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.html()).toContain('Custom Title')
    })

    it('renders subtitle slot', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Title',
        },
        slots: {
          subtitle: '<em>Custom subtitle</em>',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.html()).toContain('Custom subtitle')
    })

    it('renders leading slot', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        slots: {
          leading: '<div class="custom-leading">Leading</div>',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('.custom-leading').exists()).toBe(true)
    })

    it('renders trailing slot', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
        },
        slots: {
          trailing: '<div class="custom-trailing">Trailing</div>',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('.custom-trailing').exists()).toBe(true)
    })
  })

  // Combinations
  describe('Combinations', () => {
    it('renders with icon, subtitle, and chevron', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          subtitle: 'Description',
          icon: 'user',
          chevron: true,
        },
        global: {
          components: { Icon },
        },
      })

      const icons = wrapper.findAllComponents(Icon)
      expect(icons).toHaveLength(2) // user icon + chevron
      expect(wrapper.text()).toContain('Item')
      expect(wrapper.text()).toContain('Description')
    })

    it('renders active clickable item with avatar and badge', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'User',
          subtitle: 'Online',
          avatar: '/avatar.jpg',
          badge: '3',
          clickable: true,
          active: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.element.tagName).toBe('BUTTON')
      expect(wrapper.classes()).toContain('bg-primary/10')
      expect(wrapper.find('img').exists()).toBe(true)
      expect(wrapper.text()).toContain('3')
    })

    it('renders disabled link with divider', () => {
      const wrapper = mount(ListItem, {
        props: {
          title: 'Item',
          href: '/path',
          disabled: true,
          divider: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('opacity-50')
      expect(wrapper.classes()).toContain('border-b')
    })
  })
})
