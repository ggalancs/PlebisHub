import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import UserCard from './UserCard.vue'

describe('UserCard', () => {
  describe('rendering', () => {
    it('renders user name', () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
      })

      expect(wrapper.text()).toContain('John Doe')
    })

    it('renders title', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          title: 'Software Engineer',
        },
      })

      expect(wrapper.text()).toContain('Software Engineer')
    })

    it('renders description in detailed variant', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          description: 'Full stack developer',
          variant: 'detailed',
        },
      })

      expect(wrapper.text()).toContain('Full stack developer')
    })

    it('does not render description in default variant', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          description: 'Full stack developer',
          variant: 'default',
        },
      })

      expect(wrapper.text()).not.toContain('Full stack developer')
    })

    it('renders avatar', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          avatarSrc: '/avatar.jpg',
        },
      })

      const avatar = wrapper.findComponent({ name: 'Avatar' })
      expect(avatar.exists()).toBe(true)
      expect(avatar.props('src')).toBe('/avatar.jpg')
    })

    it('renders status badge', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          statusBadge: 'Online',
        },
      })

      expect(wrapper.text()).toContain('Online')
      expect(wrapper.findComponent({ name: 'Badge' }).exists()).toBe(true)
    })

    it('renders verified badge', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          verified: true,
        },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('badge-check')
    })

    it('does not render verified badge when false', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          verified: false,
        },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      const verifiedIcon = icons.find((icon) => icon.props('name') === 'badge-check')
      expect(verifiedIcon).toBeUndefined()
    })
  })

  describe('variants', () => {
    it('renders compact variant', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          variant: 'compact',
        },
      })

      expect(wrapper.classes()).toContain('p-4')
      const avatar = wrapper.findComponent({ name: 'Avatar' })
      expect(avatar.props('size')).toBe('md')
    })

    it('renders default variant', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          variant: 'default',
        },
      })

      expect(wrapper.classes()).toContain('p-4')
      const avatar = wrapper.findComponent({ name: 'Avatar' })
      expect(avatar.props('size')).toBe('lg')
    })

    it('renders detailed variant', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          variant: 'detailed',
        },
      })

      expect(wrapper.classes()).toContain('p-6')
      const avatar = wrapper.findComponent({ name: 'Avatar' })
      expect(avatar.props('size')).toBe('xl')
    })
  })

  describe('stats', () => {
    it('does not show stats by default', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          followersCount: 100,
        },
      })

      expect(wrapper.text()).not.toContain('Followers')
    })

    it('shows stats when enabled', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          showStats: true,
          followersCount: 100,
          followingCount: 50,
          postsCount: 25,
        },
      })

      expect(wrapper.text()).toContain('100')
      expect(wrapper.text()).toContain('Followers')
      expect(wrapper.text()).toContain('50')
      expect(wrapper.text()).toContain('Following')
      expect(wrapper.text()).toContain('25')
      expect(wrapper.text()).toContain('Posts')
    })

    it('formats large follower counts', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          showStats: true,
          followersCount: 1500,
        },
      })

      expect(wrapper.text()).toContain('1.5K')
    })

    it('formats million counts', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          showStats: true,
          followersCount: 2500000,
        },
      })

      expect(wrapper.text()).toContain('2.5M')
    })

    it('shows individual stats', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          showStats: true,
          followersCount: 100,
        },
      })

      expect(wrapper.text()).toContain('Followers')
      expect(wrapper.text()).not.toContain('Following')
      expect(wrapper.text()).not.toContain('Posts')
    })
  })

  describe('actions', () => {
    it('renders primary action button', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          primaryAction: 'Follow',
        },
      })

      expect(wrapper.text()).toContain('Follow')
    })

    it('renders secondary action button', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          secondaryAction: 'Message',
        },
      })

      expect(wrapper.text()).toContain('Message')
    })

    it('renders both action buttons', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          primaryAction: 'Follow',
          secondaryAction: 'Message',
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      expect(buttons.length).toBe(2)
    })

    it('emits primary-action event', async () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          primaryAction: 'Follow',
        },
      })

      const buttons = wrapper.findAllComponents({ name: 'Button' })
      await buttons[0].trigger('click')

      expect(wrapper.emitted('primary-action')).toBeTruthy()
    })

    it('emits secondary-action event', async () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          secondaryAction: 'Message',
        },
      })

      const button = wrapper.findComponent({ name: 'Button' })
      await button.trigger('click')

      expect(wrapper.emitted('secondary-action')).toBeTruthy()
    })
  })

  describe('link behavior', () => {
    it('renders as div by default', () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
      })

      expect(wrapper.element.tagName).toBe('DIV')
    })

    it('renders as anchor with href', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          href: '/users/1',
        },
      })

      expect(wrapper.element.tagName).toBe('A')
      expect(wrapper.attributes('href')).toBe('/users/1')
    })

    it('adds hover styles with href', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          href: '/users/1',
        },
      })

      expect(wrapper.classes()).toContain('hover:shadow-md')
      expect(wrapper.classes()).toContain('cursor-pointer')
    })

    it('emits click event when not a link', async () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
      })

      await wrapper.trigger('click')

      expect(wrapper.emitted('click')).toBeTruthy()
    })

    it('does not emit click event when is a link', async () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          href: '/users/1',
        },
      })

      await wrapper.trigger('click')

      expect(wrapper.emitted('click')).toBeFalsy()
    })
  })

  describe('slots', () => {
    it('renders actions slot', () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
        slots: {
          actions: '<button class="custom-action">Custom Action</button>',
        },
      })

      expect(wrapper.find('.custom-action').exists()).toBe(true)
    })

    it('renders footer slot', () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
        slots: {
          footer: '<div class="custom-footer">Footer Content</div>',
        },
      })

      expect(wrapper.find('.custom-footer').exists()).toBe(true)
    })

    it('footer slot has border top', () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
        slots: {
          footer: '<div>Footer</div>',
        },
      })

      const footerWrapper = wrapper.find('.border-t.border-gray-200')
      expect(footerWrapper.exists()).toBe(true)
    })
  })

  describe('status variants', () => {
    it('applies status variant to badge', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          statusBadge: 'Online',
          statusVariant: 'success',
        },
      })

      const badge = wrapper.findComponent({ name: 'Badge' })
      expect(badge.props('variant')).toBe('success')
    })

    it('uses default variant when not specified', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          statusBadge: 'Away',
        },
      })

      const badge = wrapper.findComponent({ name: 'Badge' })
      expect(badge.props('variant')).toBe('default')
    })
  })

  describe('compact variant layout', () => {
    it('uses horizontal layout', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          variant: 'compact',
        },
      })

      const layout = wrapper.find('.flex.items-center.gap-3')
      expect(layout.exists()).toBe(true)
    })

    it('truncates text in compact mode', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          title: 'Software Engineer',
          variant: 'compact',
        },
      })

      const title = wrapper.find('.truncate')
      expect(title.exists()).toBe(true)
    })

    it('shows status badge in compact mode', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          statusBadge: 'Active',
          variant: 'compact',
        },
      })

      expect(wrapper.text()).toContain('Active')
    })
  })

  describe('edge cases', () => {
    it('handles missing optional props', () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
      })

      expect(wrapper.exists()).toBe(true)
      expect(wrapper.text()).toContain('John Doe')
    })

    it('handles zero stats', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          showStats: true,
          followersCount: 0,
        },
      })

      expect(wrapper.text()).toContain('0')
    })

    it('handles undefined stats gracefully', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          showStats: true,
        },
      })

      expect(wrapper.find('.border-t.border-b').exists()).toBe(false)
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'Jane Smith',
          title: 'Product Designer',
          description: 'Passionate about user experience',
          avatarSrc: '/avatar.jpg',
          statusBadge: 'Online',
          statusVariant: 'success',
          variant: 'detailed',
          verified: true,
          showStats: true,
          followersCount: 1200,
          followingCount: 500,
          postsCount: 85,
          primaryAction: 'Follow',
          secondaryAction: 'Message',
        },
      })

      expect(wrapper.text()).toContain('Jane Smith')
      expect(wrapper.text()).toContain('Product Designer')
      expect(wrapper.text()).toContain('Passionate about user experience')
      expect(wrapper.text()).toContain('Online')
      expect(wrapper.text()).toContain('1.2K')
      expect(wrapper.text()).toContain('Follow')
      expect(wrapper.text()).toContain('Message')

      const verifiedIcon = wrapper
        .findAllComponents({ name: 'Icon' })
        .find((icon) => icon.props('name') === 'badge-check')
      expect(verifiedIcon).toBeDefined()
    })

    it('works as clickable card', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          href: '/profile/johndoe',
          variant: 'compact',
        },
      })

      expect(wrapper.element.tagName).toBe('A')
      expect(wrapper.attributes('href')).toBe('/profile/johndoe')
      expect(wrapper.classes()).toContain('cursor-pointer')
    })
  })

  describe('styling', () => {
    it('has border and rounded corners', () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
      })

      expect(wrapper.classes()).toContain('border')
      expect(wrapper.classes()).toContain('rounded-lg')
    })

    it('has white background', () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
      })

      expect(wrapper.classes()).toContain('bg-white')
    })

    it('has transition on shadow', () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
      })

      expect(wrapper.classes()).toContain('transition-shadow')
    })
  })

  describe('accessibility', () => {
    it('passes alt text to avatar', () => {
      const wrapper = mount(UserCard, {
        props: {
          name: 'John Doe',
          avatarSrc: '/avatar.jpg',
        },
      })

      const avatar = wrapper.findComponent({ name: 'Avatar' })
      expect(avatar.props('alt')).toBe('John Doe')
    })

    it('uses semantic heading for name', () => {
      const wrapper = mount(UserCard, {
        props: { name: 'John Doe' },
      })

      const heading = wrapper.find('h3')
      expect(heading.exists()).toBe(true)
      expect(heading.text()).toContain('John Doe')
    })
  })
})
