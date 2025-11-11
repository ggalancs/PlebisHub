import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Avatar from './Avatar.vue'

describe('Avatar', () => {
  describe('rendering', () => {
    it('renders avatar element', () => {
      const wrapper = mount(Avatar)
      expect(wrapper.find('span').exists()).toBe(true)
    })

    it('renders with image', () => {
      const wrapper = mount(Avatar, {
        props: {
          src: 'https://example.com/avatar.jpg',
          alt: 'User avatar',
        },
      })

      const img = wrapper.find('img')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('https://example.com/avatar.jpg')
      expect(img.attributes('alt')).toBe('User avatar')
    })

    it('renders with initials when no image', () => {
      const wrapper = mount(Avatar, {
        props: { initials: 'JD' },
      })

      expect(wrapper.text()).toBe('JD')
      expect(wrapper.find('img').exists()).toBe(false)
    })

    it('uppercases initials', () => {
      const wrapper = mount(Avatar, {
        props: { initials: 'jd' },
      })

      expect(wrapper.text()).toBe('JD')
    })

    it('truncates initials to 2 characters', () => {
      const wrapper = mount(Avatar, {
        props: { initials: 'ABCD' },
      })

      expect(wrapper.text()).toBe('AB')
    })

    it('renders default icon when no image or initials', () => {
      const wrapper = mount(Avatar)

      expect(wrapper.find('svg').exists()).toBe(true)
      expect(wrapper.find('img').exists()).toBe(false)
    })

    it('renders custom icon via slot', () => {
      const wrapper = mount(Avatar, {
        slots: {
          default: '<svg data-testid="custom-icon"></svg>',
        },
      })

      expect(wrapper.find('[data-testid="custom-icon"]').exists()).toBe(true)
    })

    it('renders with different sizes', () => {
      const sizes = ['xs', 'sm', 'md', 'lg', 'xl', '2xl'] as const

      sizes.forEach((size) => {
        const wrapper = mount(Avatar, { props: { size } })
        const avatar = wrapper.find('span')

        const expectedClass =
          size === 'xs'
            ? 'h-6'
            : size === 'sm'
              ? 'h-8'
              : size === 'md'
                ? 'h-10'
                : size === 'lg'
                  ? 'h-12'
                  : size === 'xl'
                    ? 'h-14'
                    : 'h-16'

        expect(avatar.classes()).toContain(expectedClass)
      })
    })

    it('renders with different variants', () => {
      const variants = [
        'primary',
        'secondary',
        'success',
        'danger',
        'warning',
        'info',
        'neutral',
      ] as const

      variants.forEach((variant) => {
        const wrapper = mount(Avatar, {
          props: { variant, initials: 'AB' },
        })

        const avatar = wrapper.find('span')
        const expectedClass =
          variant === 'primary'
            ? 'bg-primary-600'
            : variant === 'secondary'
              ? 'bg-secondary-600'
              : variant === 'success'
                ? 'bg-green-600'
                : variant === 'danger'
                  ? 'bg-red-600'
                  : variant === 'warning'
                    ? 'bg-yellow-500'
                    : variant === 'info'
                      ? 'bg-blue-600'
                      : 'bg-gray-600'

        expect(avatar.classes()).toContain(expectedClass)
      })
    })

    it('renders with circle shape by default', () => {
      const wrapper = mount(Avatar)
      expect(wrapper.find('span').classes()).toContain('rounded-full')
    })

    it('renders with square shape', () => {
      const wrapper = mount(Avatar, {
        props: { shape: 'square' },
      })

      const avatar = wrapper.find('span')
      expect(avatar.classes()).toContain('rounded-md')
      expect(avatar.classes()).not.toContain('rounded-full')
    })

    it('renders with status indicator', () => {
      const wrapper = mount(Avatar, {
        props: { status: 'online' },
      })

      const statusIndicator = wrapper.find('span > span[aria-label*="Status"]')
      expect(statusIndicator.exists()).toBe(true)
      expect(statusIndicator.attributes('aria-label')).toBe('Status: online')
    })

    it('does not render status indicator by default', () => {
      const wrapper = mount(Avatar)
      expect(wrapper.find('span > span[aria-label*="Status"]').exists()).toBe(false)
    })

    it('renders status with different colors', () => {
      const statuses = [
        { status: 'online' as const, class: 'bg-green-500' },
        { status: 'offline' as const, class: 'bg-gray-400' },
        { status: 'away' as const, class: 'bg-yellow-500' },
        { status: 'busy' as const, class: 'bg-red-500' },
      ]

      statuses.forEach(({ status, class: expectedClass }) => {
        const wrapper = mount(Avatar, {
          props: { status },
        })

        const statusIndicator = wrapper.find('span > span[aria-label*="Status"]')
        expect(statusIndicator.classes()).toContain(expectedClass)
      })
    })

    it('renders status at bottom by default', () => {
      const wrapper = mount(Avatar, {
        props: { status: 'online' },
      })

      const statusIndicator = wrapper.find('span > span[aria-label*="Status"]')
      expect(statusIndicator.classes()).toContain('bottom-0')
    })

    it('renders status at top when specified', () => {
      const wrapper = mount(Avatar, {
        props: { status: 'online', statusPosition: 'top' },
      })

      const statusIndicator = wrapper.find('span > span[aria-label*="Status"]')
      expect(statusIndicator.classes()).toContain('top-0')
      expect(statusIndicator.classes()).not.toContain('bottom-0')
    })
  })

  describe('priority', () => {
    it('prioritizes image over initials', () => {
      const wrapper = mount(Avatar, {
        props: {
          src: 'https://example.com/avatar.jpg',
          initials: 'JD',
        },
      })

      expect(wrapper.find('img').exists()).toBe(true)
      expect(wrapper.text()).not.toContain('JD')
    })

    it('prioritizes initials over default icon', () => {
      const wrapper = mount(Avatar, {
        props: { initials: 'JD' },
      })

      expect(wrapper.text()).toBe('JD')
      // Should not render default user icon when initials are present
      const svgs = wrapper.findAll('svg')
      // Only status indicator svg should exist if any
      expect(svgs.length).toBe(0)
    })

    it('shows default icon when no image or initials', () => {
      const wrapper = mount(Avatar)

      expect(wrapper.find('img').exists()).toBe(false)
      expect(wrapper.text()).toBe('')
      expect(wrapper.find('svg').exists()).toBe(true)
    })
  })

  describe('accessibility', () => {
    it('has alt text for image', () => {
      const wrapper = mount(Avatar, {
        props: {
          src: 'https://example.com/avatar.jpg',
          alt: 'John Doe',
        },
      })

      expect(wrapper.find('img').attributes('alt')).toBe('John Doe')
    })

    it('defaults to "Avatar" alt text when not provided', () => {
      const wrapper = mount(Avatar, {
        props: { src: 'https://example.com/avatar.jpg' },
      })

      expect(wrapper.find('img').attributes('alt')).toBe('Avatar')
    })

    it('has aria-hidden on initials span', () => {
      const wrapper = mount(Avatar, {
        props: { initials: 'JD' },
      })

      const initialsSpan = wrapper.find('span > span')
      expect(initialsSpan.attributes('aria-hidden')).toBe('true')
    })

    it('has aria-label on status indicator', () => {
      const wrapper = mount(Avatar, {
        props: { status: 'online' },
      })

      const statusIndicator = wrapper.find('span > span[aria-label*="Status"]')
      expect(statusIndicator.attributes('aria-label')).toBe('Status: online')
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(Avatar, {
        props: {
          size: 'xl',
          variant: 'primary',
          initials: 'JD',
          shape: 'square',
          status: 'online',
          statusPosition: 'top',
        },
      })

      const avatar = wrapper.find('span')
      expect(avatar.classes()).toContain('h-14') // xl size
      expect(avatar.classes()).toContain('bg-primary-600') // primary variant
      expect(avatar.classes()).toContain('rounded-md') // square shape
      expect(wrapper.text()).toBe('JD') // initials
      expect(wrapper.find('span > span[aria-label*="Status"]').exists()).toBe(true) // status
    })

    it('renders image with status', () => {
      const wrapper = mount(Avatar, {
        props: {
          src: 'https://example.com/avatar.jpg',
          status: 'online',
        },
      })

      expect(wrapper.find('img').exists()).toBe(true)
      expect(wrapper.find('span > span[aria-label*="Status"]').exists()).toBe(true)
    })
  })
})
