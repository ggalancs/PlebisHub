import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import NotificationBadge from './NotificationBadge.vue'

describe('NotificationBadge', () => {
  it('renders with default props', () => {
    const wrapper = mount(NotificationBadge, {
      slots: { default: '<button>Click</button>' },
    })
    expect(wrapper.exists()).toBe(true)
  })

  it('renders slot content', () => {
    const wrapper = mount(NotificationBadge, {
      slots: { default: '<button class="test-btn">Button</button>' },
    })
    expect(wrapper.html()).toContain('test-btn')
    expect(wrapper.text()).toContain('Button')
  })

  it('shows badge when count is greater than 0', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 5 },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').exists()).toBe(true)
    expect(wrapper.find('.notification-badge').text()).toBe('5')
  })

  it('hides badge when count is 0 by default', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 0 },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').exists()).toBe(false)
  })

  it('shows badge when count is 0 and showZero is true', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 0, showZero: true },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').exists()).toBe(true)
    expect(wrapper.find('.notification-badge').text()).toBe('0')
  })

  it('displays count correctly', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 42 },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').text()).toBe('42')
  })

  it('displays max+ when count exceeds max', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 150, max: 99 },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').text()).toBe('99+')
  })

  it('respects custom max value', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 10, max: 5 },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').text()).toBe('5+')
  })

  it('shows dot when dot prop is true', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 5, dot: true },
      slots: { default: '<button>Button</button>' },
    })
    const badge = wrapper.find('.notification-badge')
    expect(badge.text()).toBe('')
    expect(badge.classes()).toContain('w-2')
    expect(badge.classes()).toContain('h-2')
  })

  it('applies primary variant by default', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1 },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').classes()).toContain('bg-primary')
  })

  it('applies success variant', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1, variant: 'success' },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').classes()).toContain('bg-green-500')
  })

  it('applies warning variant', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1, variant: 'warning' },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').classes()).toContain('bg-yellow-500')
  })

  it('applies danger variant', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1, variant: 'danger' },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').classes()).toContain('bg-red-500')
  })

  it('applies gray variant', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1, variant: 'gray' },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').classes()).toContain('bg-gray-500')
  })

  it('positions badge at top-right by default', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1 },
      slots: { default: '<button>Button</button>' },
    })
    const badge = wrapper.find('.notification-badge')
    expect(badge.classes()).toContain('top-0')
    expect(badge.classes()).toContain('right-0')
  })

  it('positions badge at top-left', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1, position: 'top-left' },
      slots: { default: '<button>Button</button>' },
    })
    const badge = wrapper.find('.notification-badge')
    expect(badge.classes()).toContain('top-0')
    expect(badge.classes()).toContain('left-0')
  })

  it('positions badge at bottom-right', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1, position: 'bottom-right' },
      slots: { default: '<button>Button</button>' },
    })
    const badge = wrapper.find('.notification-badge')
    expect(badge.classes()).toContain('bottom-0')
    expect(badge.classes()).toContain('right-0')
  })

  it('positions badge at bottom-left', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1, position: 'bottom-left' },
      slots: { default: '<button>Button</button>' },
    })
    const badge = wrapper.find('.notification-badge')
    expect(badge.classes()).toContain('bottom-0')
    expect(badge.classes()).toContain('left-0')
  })

  it('has correct ARIA label for count', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 5 },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').attributes('aria-label')).toBe('5 notifications')
  })

  it('has correct ARIA label for dot', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 5, dot: true },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').attributes('aria-label')).toBe('Notification')
  })

  it('has rounded-full class', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1 },
      slots: { default: '<button>Button</button>' },
    })
    expect(wrapper.find('.notification-badge').classes()).toContain('rounded-full')
  })

  it('has border styling', () => {
    const wrapper = mount(NotificationBadge, {
      props: { count: 1 },
      slots: { default: '<button>Button</button>' },
    })
    const badge = wrapper.find('.notification-badge')
    expect(badge.classes()).toContain('border-2')
    expect(badge.classes()).toContain('border-white')
  })

  it('container has relative positioning', () => {
    const wrapper = mount(NotificationBadge, {
      slots: { default: '<button>Button</button>' },
    })
    const container = wrapper.find('.notification-badge-container')
    expect(container.classes()).toContain('relative')
  })
})
