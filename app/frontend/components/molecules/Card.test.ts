import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Card from './Card.vue'

describe('Card', () => {
  describe('rendering', () => {
    it('renders as div by default', () => {
      const wrapper = mount(Card)

      expect(wrapper.element.tagName).toBe('DIV')
    })

    it('renders as anchor with href', () => {
      const wrapper = mount(Card, {
        props: { href: 'https://example.com' },
      })

      expect(wrapper.element.tagName).toBe('A')
      expect(wrapper.attributes('href')).toBe('https://example.com')
    })

    it('renders title', () => {
      const wrapper = mount(Card, {
        props: { title: 'Card Title' },
      })

      expect(wrapper.text()).toContain('Card Title')
    })

    it('renders subtitle', () => {
      const wrapper = mount(Card, {
        props: { subtitle: 'Card Subtitle' },
      })

      expect(wrapper.text()).toContain('Card Subtitle')
    })

    it('renders title and subtitle together', () => {
      const wrapper = mount(Card, {
        props: {
          title: 'Card Title',
          subtitle: 'Card Subtitle',
        },
      })

      expect(wrapper.text()).toContain('Card Title')
      expect(wrapper.text()).toContain('Card Subtitle')
    })

    it('renders image from prop', () => {
      const wrapper = mount(Card, {
        props: {
          imageSrc: '/test-image.jpg',
          imageAlt: 'Test Image',
        },
      })

      const img = wrapper.find('img')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('/test-image.jpg')
      expect(img.attributes('alt')).toBe('Test Image')
    })

    it('renders default slot', () => {
      const wrapper = mount(Card, {
        slots: {
          default: '<p>Card content</p>',
        },
      })

      expect(wrapper.text()).toContain('Card content')
    })

    it('renders header slot', () => {
      const wrapper = mount(Card, {
        slots: {
          header: '<h2>Custom Header</h2>',
        },
      })

      expect(wrapper.text()).toContain('Custom Header')
    })

    it('renders footer slot', () => {
      const wrapper = mount(Card, {
        slots: {
          footer: '<button>Action</button>',
        },
      })

      expect(wrapper.text()).toContain('Action')
    })

    it('renders image slot', () => {
      const wrapper = mount(Card, {
        slots: {
          image: '<img src="/custom.jpg" alt="Custom" />',
        },
      })

      const img = wrapper.find('img')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('/custom.jpg')
    })

    it('does not render header when no title, subtitle or slot', () => {
      const wrapper = mount(Card, {
        slots: {
          default: '<p>Content</p>',
        },
      })

      expect(wrapper.find('.card-header').exists()).toBe(false)
    })

    it('does not render footer when no slot', () => {
      const wrapper = mount(Card, {
        slots: {
          default: '<p>Content</p>',
        },
      })

      expect(wrapper.find('.card-footer').exists()).toBe(false)
    })

    it('does not render body when no default slot', () => {
      const wrapper = mount(Card, {
        props: { title: 'Title' },
      })

      expect(wrapper.find('.card-body').exists()).toBe(false)
    })
  })

  describe('variants', () => {
    it('renders default variant', () => {
      const wrapper = mount(Card)

      expect(wrapper.classes()).toContain('shadow-md')
      expect(wrapper.classes()).toContain('border')
      expect(wrapper.classes()).toContain('border-gray-100')
    })

    it('renders bordered variant', () => {
      const wrapper = mount(Card, {
        props: { variant: 'bordered' },
      })

      expect(wrapper.classes()).toContain('border')
      expect(wrapper.classes()).toContain('border-gray-200')
      expect(wrapper.classes()).not.toContain('shadow-md')
    })

    it('renders elevated variant', () => {
      const wrapper = mount(Card, {
        props: { variant: 'elevated' },
      })

      expect(wrapper.classes()).toContain('shadow-lg')
      expect(wrapper.classes()).toContain('border')
    })

    it('renders flat variant', () => {
      const wrapper = mount(Card, {
        props: { variant: 'flat' },
      })

      expect(wrapper.classes()).toContain('bg-gray-50')
      expect(wrapper.classes()).not.toContain('shadow-md')
    })
  })

  describe('padding', () => {
    it('renders with no padding', () => {
      const wrapper = mount(Card, {
        props: { padding: 'none' },
        slots: { default: '<p>Content</p>' },
      })

      const body = wrapper.find('.card-body')
      expect(body.classes()).not.toContain('p-3')
      expect(body.classes()).not.toContain('p-4')
      expect(body.classes()).not.toContain('p-6')
    })

    it('renders with small padding', () => {
      const wrapper = mount(Card, {
        props: { padding: 'sm' },
        slots: { default: '<p>Content</p>' },
      })

      const body = wrapper.find('.card-body')
      expect(body.classes()).toContain('p-3')
    })

    it('renders with medium padding by default', () => {
      const wrapper = mount(Card, {
        slots: { default: '<p>Content</p>' },
      })

      const body = wrapper.find('.card-body')
      expect(body.classes()).toContain('p-4')
    })

    it('renders with large padding', () => {
      const wrapper = mount(Card, {
        props: { padding: 'lg' },
        slots: { default: '<p>Content</p>' },
      })

      const body = wrapper.find('.card-body')
      expect(body.classes()).toContain('p-6')
    })

    it('applies padding to header', () => {
      const wrapper = mount(Card, {
        props: { title: 'Title', padding: 'lg' },
      })

      const header = wrapper.find('.card-header')
      expect(header.classes()).toContain('p-6')
    })

    it('applies padding to footer', () => {
      const wrapper = mount(Card, {
        props: { padding: 'lg' },
        slots: { footer: '<button>Action</button>' },
      })

      const footer = wrapper.find('.card-footer')
      expect(footer.classes()).toContain('p-6')
    })
  })

  describe('hoverable', () => {
    it('adds hover effect when hoverable', () => {
      const wrapper = mount(Card, {
        props: { hoverable: true },
      })

      expect(wrapper.classes()).toContain('hover:shadow-lg')
    })

    it('does not add hover effect by default', () => {
      const wrapper = mount(Card)

      expect(wrapper.classes()).not.toContain('hover:shadow-lg')
    })

    it('adds elevated hover effect for elevated variant', () => {
      const wrapper = mount(Card, {
        props: { variant: 'elevated', hoverable: true },
      })

      expect(wrapper.classes()).toContain('hover:shadow-xl')
    })

    it('adds flat hover effect for flat variant', () => {
      const wrapper = mount(Card, {
        props: { variant: 'flat', hoverable: true },
      })

      expect(wrapper.classes()).toContain('hover:bg-gray-100')
    })

    it('does not add hover effect when disabled', () => {
      const wrapper = mount(Card, {
        props: { hoverable: true, disabled: true },
      })

      expect(wrapper.classes()).not.toContain('hover:shadow-lg')
    })
  })

  describe('clickable', () => {
    it('adds cursor-pointer when clickable', () => {
      const wrapper = mount(Card, {
        props: { clickable: true },
      })

      expect(wrapper.classes()).toContain('cursor-pointer')
    })

    it('adds cursor-pointer with href', () => {
      const wrapper = mount(Card, {
        props: { href: 'https://example.com' },
      })

      expect(wrapper.classes()).toContain('cursor-pointer')
    })

    it('does not add cursor-pointer by default', () => {
      const wrapper = mount(Card)

      expect(wrapper.classes()).not.toContain('cursor-pointer')
    })

    it('emits click event when clicked', async () => {
      const wrapper = mount(Card, {
        props: { clickable: true },
      })

      await wrapper.trigger('click')

      expect(wrapper.emitted('click')).toBeTruthy()
    })

    it('does not add cursor-pointer when disabled', () => {
      const wrapper = mount(Card, {
        props: { clickable: true, disabled: true },
      })

      expect(wrapper.classes()).not.toContain('cursor-pointer')
    })
  })

  describe('disabled state', () => {
    it('renders disabled state', () => {
      const wrapper = mount(Card, {
        props: { disabled: true },
      })

      expect(wrapper.classes()).toContain('opacity-50')
      expect(wrapper.classes()).toContain('cursor-not-allowed')
      expect(wrapper.attributes('aria-disabled')).toBe('true')
    })

    it('does not emit click when disabled', async () => {
      const wrapper = mount(Card, {
        props: { disabled: true, clickable: true },
      })

      await wrapper.trigger('click')

      expect(wrapper.emitted('click')).toBeFalsy()
    })

    it('removes href when disabled', () => {
      const wrapper = mount(Card, {
        props: { href: 'https://example.com', disabled: true },
      })

      expect(wrapper.element.tagName).toBe('DIV')
      expect(wrapper.attributes('href')).toBeUndefined()
    })

    it('does not apply hover effects when disabled', () => {
      const wrapper = mount(Card, {
        props: { hoverable: true, disabled: true },
      })

      expect(wrapper.classes()).not.toContain('hover:shadow-lg')
    })
  })

  describe('click handling', () => {
    it('emits click event with event object', async () => {
      const wrapper = mount(Card)

      await wrapper.trigger('click')

      expect(wrapper.emitted('click')).toBeTruthy()
      expect(wrapper.emitted('click')?.[0]).toHaveLength(1)
    })

    it('does not emit click when disabled', async () => {
      const wrapper = mount(Card, {
        props: { disabled: true },
      })

      await wrapper.trigger('click')

      expect(wrapper.emitted('click')).toBeFalsy()
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(Card, {
        props: {
          variant: 'elevated',
          padding: 'lg',
          hoverable: true,
          clickable: true,
          title: 'Card Title',
          subtitle: 'Card Subtitle',
          imageSrc: '/image.jpg',
        },
        slots: {
          default: '<p>Content</p>',
          footer: '<button>Action</button>',
        },
      })

      expect(wrapper.classes()).toContain('shadow-lg')
      expect(wrapper.classes()).toContain('hover:shadow-xl')
      expect(wrapper.classes()).toContain('cursor-pointer')
      expect(wrapper.text()).toContain('Card Title')
      expect(wrapper.text()).toContain('Card Subtitle')
      expect(wrapper.text()).toContain('Content')
      expect(wrapper.text()).toContain('Action')
      expect(wrapper.find('img').exists()).toBe(true)
    })

    it('works with minimal props', () => {
      const wrapper = mount(Card, {
        slots: {
          default: '<p>Simple content</p>',
        },
      })

      expect(wrapper.exists()).toBe(true)
      expect(wrapper.text()).toContain('Simple content')
    })

    it('works as link card', () => {
      const wrapper = mount(Card, {
        props: {
          href: 'https://example.com',
          hoverable: true,
          title: 'Link Card',
        },
        slots: {
          default: '<p>Click to navigate</p>',
        },
      })

      expect(wrapper.element.tagName).toBe('A')
      expect(wrapper.attributes('href')).toBe('https://example.com')
      expect(wrapper.classes()).toContain('cursor-pointer')
    })

    it('works as image card', () => {
      const wrapper = mount(Card, {
        props: {
          imageSrc: '/card-image.jpg',
          imageAlt: 'Card Image',
          title: 'Image Card',
        },
        slots: {
          default: '<p>Card with image</p>',
          footer: '<button>View</button>',
        },
      })

      const img = wrapper.find('img')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('/card-image.jpg')
      expect(wrapper.text()).toContain('Image Card')
      expect(wrapper.text()).toContain('Card with image')
      expect(wrapper.text()).toContain('View')
    })
  })

  describe('accessibility', () => {
    it('has aria-disabled when disabled', () => {
      const wrapper = mount(Card, {
        props: { disabled: true },
      })

      expect(wrapper.attributes('aria-disabled')).toBe('true')
    })

    it('does not have aria-disabled when not disabled', () => {
      const wrapper = mount(Card)

      expect(wrapper.attributes('aria-disabled')).toBeUndefined()
    })

    it('image has alt attribute', () => {
      const wrapper = mount(Card, {
        props: {
          imageSrc: '/image.jpg',
          imageAlt: 'Descriptive text',
        },
      })

      const img = wrapper.find('img')
      expect(img.attributes('alt')).toBe('Descriptive text')
    })

    it('image has empty alt when not provided', () => {
      const wrapper = mount(Card, {
        props: {
          imageSrc: '/image.jpg',
        },
      })

      const img = wrapper.find('img')
      expect(img.attributes('alt')).toBe('')
    })
  })

  describe('layout', () => {
    it('renders header before body', () => {
      const wrapper = mount(Card, {
        props: { title: 'Header' },
        slots: { default: '<p>Body</p>' },
      })

      const html = wrapper.html()
      const headerIndex = html.indexOf('Header')
      const bodyIndex = html.indexOf('Body')

      expect(headerIndex).toBeLessThan(bodyIndex)
    })

    it('renders body before footer', () => {
      const wrapper = mount(Card, {
        slots: {
          default: '<p>Body</p>',
          footer: '<p>Footer</p>',
        },
      })

      const html = wrapper.html()
      const bodyIndex = html.indexOf('Body')
      const footerIndex = html.indexOf('Footer')

      expect(bodyIndex).toBeLessThan(footerIndex)
    })

    it('renders image before header', () => {
      const wrapper = mount(Card, {
        props: {
          imageSrc: '/image.jpg',
          title: 'Title',
        },
      })

      const html = wrapper.html()
      const imageIndex = html.indexOf('<img')
      const titleIndex = html.indexOf('Title')

      expect(imageIndex).toBeLessThan(titleIndex)
    })

    it('footer has border-top', () => {
      const wrapper = mount(Card, {
        slots: {
          footer: '<button>Action</button>',
        },
      })

      const footer = wrapper.find('.card-footer')
      expect(footer.classes()).toContain('border-t')
      expect(footer.classes()).toContain('border-gray-200')
    })
  })
})
