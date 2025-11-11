import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import EmptyState from './EmptyState.vue'

describe('EmptyState', () => {
  describe('rendering', () => {
    it('renders title', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items found' },
      })

      expect(wrapper.text()).toContain('No items found')
    })

    it('renders description', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          description: 'Try adding some items',
        },
      })

      expect(wrapper.text()).toContain('Try adding some items')
    })

    it('renders without description', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items' },
      })

      expect(wrapper.find('p').exists()).toBe(false)
    })

    it('renders default icon', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'Empty' },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.exists()).toBe(true)
      expect(icon.props('name')).toBe('inbox')
    })

    it('renders custom icon', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No results', icon: 'search' },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('search')
    })

    it('renders image instead of icon', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          imageSrc: '/empty.svg',
          imageAlt: 'Empty state',
        },
      })

      const img = wrapper.find('img')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('/empty.svg')
      expect(img.attributes('alt')).toBe('Empty state')
    })

    it('prefers image over icon', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          icon: 'inbox',
          imageSrc: '/empty.svg',
        },
      })

      const img = wrapper.find('img')
      const iconContainer = wrapper.find('.rounded-full')

      expect(img.exists()).toBe(true)
      expect(iconContainer.exists()).toBe(false)
    })

    it('renders primary action button', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          primaryAction: 'Add Item',
        },
      })

      expect(wrapper.text()).toContain('Add Item')
      expect(wrapper.findComponent({ name: 'Button' }).exists()).toBe(true)
    })

    it('renders secondary action button', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          secondaryAction: 'Learn More',
        },
      })

      expect(wrapper.text()).toContain('Learn More')
    })

    it('renders both action buttons', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          primaryAction: 'Add Item',
          secondaryAction: 'Learn More',
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons).toHaveLength(2)
    })

    it('does not render actions section when no actions', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items' },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons).toHaveLength(0)
    })
  })

  describe('slots', () => {
    it('renders icon slot', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items' },
        slots: {
          icon: '<div class="custom-icon">Custom Icon</div>',
        },
      })

      expect(wrapper.find('.custom-icon').exists()).toBe(true)
      expect(wrapper.text()).toContain('Custom Icon')
    })

    it('renders description slot', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items' },
        slots: {
          description: '<p>Custom description content</p>',
        },
      })

      expect(wrapper.text()).toContain('Custom description content')
    })

    it('renders actions slot', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items' },
        slots: {
          actions: '<button class="custom-btn">Custom Action</button>',
        },
      })

      expect(wrapper.find('.custom-btn').exists()).toBe(true)
    })

    it('prefers description slot over prop', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          description: 'Prop description',
        },
        slots: {
          description: '<p>Slot description</p>',
        },
      })

      expect(wrapper.text()).toContain('Slot description')
      expect(wrapper.text()).not.toContain('Prop description')
    })

    it('prefers actions slot over button props', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          primaryAction: 'Prop Action',
        },
        slots: {
          actions: '<button class="slot-action">Slot Action</button>',
        },
      })

      expect(wrapper.find('.slot-action').exists()).toBe(true)
      expect(wrapper.text()).toContain('Slot Action')
      expect(wrapper.text()).not.toContain('Prop Action')
    })
  })

  describe('sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items', size: 'sm' },
      })

      expect(wrapper.classes()).toContain('p-6')
      expect(wrapper.classes()).toContain('max-w-xs')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items' },
      })

      expect(wrapper.classes()).toContain('p-8')
      expect(wrapper.classes()).toContain('max-w-md')
    })

    it('renders large size', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items', size: 'lg' },
      })

      expect(wrapper.classes()).toContain('p-12')
      expect(wrapper.classes()).toContain('max-w-lg')
    })

    it('applies correct title size', () => {
      const wrapperSm = mount(EmptyState, {
        props: { title: 'No items', size: 'sm' },
      })
      const wrapperLg = mount(EmptyState, {
        props: { title: 'No items', size: 'lg' },
      })

      const titleSm = wrapperSm.find('h3')
      const titleLg = wrapperLg.find('h3')

      expect(titleSm.classes()).toContain('text-base')
      expect(titleLg.classes()).toContain('text-xl')
    })

    it('applies correct icon size', () => {
      const wrapperSm = mount(EmptyState, {
        props: { title: 'No items', size: 'sm' },
      })
      const wrapperLg = mount(EmptyState, {
        props: { title: 'No items', size: 'lg' },
      })

      const iconContainerSm = wrapperSm.find('.rounded-full')
      const iconContainerLg = wrapperLg.find('.rounded-full')

      expect(iconContainerSm.classes()).toContain('w-12')
      expect(iconContainerSm.classes()).toContain('h-12')
      expect(iconContainerLg.classes()).toContain('w-20')
      expect(iconContainerLg.classes()).toContain('h-20')
    })

    it('applies correct image size', () => {
      const wrapperSm = mount(EmptyState, {
        props: { title: 'No items', size: 'sm', imageSrc: '/empty.svg' },
      })
      const wrapperLg = mount(EmptyState, {
        props: { title: 'No items', size: 'lg', imageSrc: '/empty.svg' },
      })

      const imageSm = wrapperSm.find('img')
      const imageLg = wrapperLg.find('img')

      expect(imageSm.classes()).toContain('w-32')
      expect(imageSm.classes()).toContain('h-32')
      expect(imageLg.classes()).toContain('w-64')
      expect(imageLg.classes()).toContain('h-64')
    })
  })

  describe('events', () => {
    it('emits primary-action when primary button clicked', async () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          primaryAction: 'Add Item',
        },
      })

      const button = wrapper.findComponent({ name: 'Button' })
      await button.trigger('click')

      expect(wrapper.emitted('primary-action')).toBeTruthy()
    })

    it('emits secondary-action when secondary button clicked', async () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          secondaryAction: 'Learn More',
        },
      })

      const button = wrapper.findComponent({ name: 'Button' })
      await button.trigger('click')

      expect(wrapper.emitted('secondary-action')).toBeTruthy()
    })

    it('emits correct events for both buttons', async () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          primaryAction: 'Add Item',
          secondaryAction: 'Learn More',
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })

      await buttons[0].trigger('click')
      expect(wrapper.emitted('primary-action')).toBeTruthy()

      await buttons[1].trigger('click')
      expect(wrapper.emitted('secondary-action')).toBeTruthy()
    })
  })

  describe('layout', () => {
    it('centers content', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items' },
      })

      expect(wrapper.classes()).toContain('flex')
      expect(wrapper.classes()).toContain('flex-col')
      expect(wrapper.classes()).toContain('items-center')
      expect(wrapper.classes()).toContain('justify-center')
      expect(wrapper.classes()).toContain('text-center')
    })

    it('renders elements in correct order', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          description: 'Description text',
          primaryAction: 'Add Item',
        },
      })

      const html = wrapper.html()
      const iconIndex = html.indexOf('Icon')
      const titleIndex = html.indexOf('No items')
      const descriptionIndex = html.indexOf('Description text')
      const buttonIndex = html.indexOf('Add Item')

      expect(iconIndex).toBeLessThan(titleIndex)
      expect(titleIndex).toBeLessThan(descriptionIndex)
      expect(descriptionIndex).toBeLessThan(buttonIndex)
    })
  })

  describe('styling', () => {
    it('has gray background for icon container', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items' },
      })

      const iconContainer = wrapper.find('.rounded-full')
      expect(iconContainer.classes()).toContain('bg-gray-100')
    })

    it('has gray text for icon', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items' },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.classes()).toContain('text-gray-400')
    })

    it('has gray text for description', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          description: 'Description',
        },
      })

      const description = wrapper.find('p')
      expect(description.classes()).toContain('text-gray-600')
    })

    it('secondary button has secondary variant', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          secondaryAction: 'Learn More',
        },
      })

      const button = wrapper.findComponent({ name: 'Button' })
      expect(button.props('variant')).toBe('secondary')
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No search results',
          description: 'Try adjusting your search terms',
          icon: 'search',
          primaryAction: 'Clear Search',
          secondaryAction: 'Browse All',
          size: 'lg',
        },
      })

      expect(wrapper.text()).toContain('No search results')
      expect(wrapper.text()).toContain('Try adjusting your search terms')
      expect(wrapper.text()).toContain('Clear Search')
      expect(wrapper.text()).toContain('Browse All')
      expect(wrapper.classes()).toContain('p-12')

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('search')
    })

    it('works with minimal props', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'Empty' },
      })

      expect(wrapper.exists()).toBe(true)
      expect(wrapper.text()).toContain('Empty')
    })

    it('works with image and actions', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No files',
          imageSrc: '/empty-folder.svg',
          primaryAction: 'Upload File',
        },
      })

      const img = wrapper.find('img')
      expect(img.exists()).toBe(true)
      expect(wrapper.text()).toContain('Upload File')
    })

    it('works with custom slots', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'Custom Empty State' },
        slots: {
          icon: '<div class="custom-icon">🎨</div>',
          description: '<p class="custom-desc">Totally custom</p>',
          actions: '<button class="custom-btn">Do Something</button>',
        },
      })

      expect(wrapper.find('.custom-icon').exists()).toBe(true)
      expect(wrapper.find('.custom-desc').exists()).toBe(true)
      expect(wrapper.find('.custom-btn').exists()).toBe(true)
    })
  })

  describe('accessibility', () => {
    it('uses semantic heading for title', () => {
      const wrapper = mount(EmptyState, {
        props: { title: 'No items' },
      })

      const title = wrapper.find('h3')
      expect(title.exists()).toBe(true)
      expect(title.text()).toBe('No items')
    })

    it('provides alt text for image', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          imageSrc: '/empty.svg',
          imageAlt: 'Empty folder illustration',
        },
      })

      const img = wrapper.find('img')
      expect(img.attributes('alt')).toBe('Empty folder illustration')
    })

    it('uses empty alt when not provided', () => {
      const wrapper = mount(EmptyState, {
        props: {
          title: 'No items',
          imageSrc: '/empty.svg',
        },
      })

      const img = wrapper.find('img')
      expect(img.attributes('alt')).toBe('')
    })
  })
})
