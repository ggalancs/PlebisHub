import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Stat from './Stat.vue'

describe('Stat', () => {
  describe('rendering', () => {
    it('renders label', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Total Revenue',
          value: 12500,
        },
      })

      expect(wrapper.text()).toContain('Total Revenue')
    })

    it('renders numeric value', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 1234,
        },
      })

      expect(wrapper.text()).toContain('1234')
    })

    it('renders string value', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Status',
          value: 'Active',
        },
      })

      expect(wrapper.text()).toContain('Active')
    })

    it('renders prefix', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
          prefix: '$',
        },
      })

      expect(wrapper.text()).toContain('$')
    })

    it('renders suffix', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Growth',
          value: 25,
          suffix: '%',
        },
      })

      expect(wrapper.text()).toContain('%')
    })

    it('renders icon', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          icon: 'users',
        },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.exists()).toBe(true)
      expect(icon.props('name')).toBe('users')
    })

    it('renders without icon', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
        },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      // Should have no icons (or only trend icons if change is present)
      const mainIcon = icons.find((icon) => icon.props('name') === 'users')
      expect(mainIcon).toBeUndefined()
    })
  })

  describe('change indicator', () => {
    it('renders positive change', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
          change: 12.5,
        },
      })

      expect(wrapper.text()).toContain('+12.5%')
    })

    it('renders negative change', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
          change: -5.2,
        },
      })

      expect(wrapper.text()).toContain('-5.2%')
    })

    it('renders zero change', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
          change: 0,
        },
      })

      expect(wrapper.text()).toContain('0%')
    })

    it('renders change label', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
          change: 10,
          changeLabel: 'vs last month',
        },
      })

      expect(wrapper.text()).toContain('vs last month')
    })

    it('shows success badge for positive change', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
          change: 10,
        },
      })

      const badge = wrapper.findComponent({ name: 'Badge' })
      expect(badge.props('variant')).toBe('success')
    })

    it('shows danger badge for negative change', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
          change: -10,
        },
      })

      const badge = wrapper.findComponent({ name: 'Badge' })
      expect(badge.props('variant')).toBe('danger')
    })

    it('does not render change when not provided', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
        },
      })

      expect(wrapper.findComponent({ name: 'Badge' }).exists()).toBe(false)
    })
  })

  describe('trend icons', () => {
    it('shows trending-up icon for positive change', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
          change: 10,
          showTrend: true,
        },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      const trendIcon = icons.find((icon) => icon.props('name') === 'trending-up')
      expect(trendIcon).toBeDefined()
    })

    it('shows trending-down icon for negative change', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
          change: -10,
          showTrend: true,
        },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      const trendIcon = icons.find((icon) => icon.props('name') === 'trending-down')
      expect(trendIcon).toBeDefined()
    })

    it('hides trend icon when showTrend is false', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Revenue',
          value: 1000,
          change: 10,
          showTrend: false,
        },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      const trendIcon = icons.find(
        (icon) => icon.props('name') === 'trending-up' || icon.props('name') === 'trending-down'
      )
      expect(trendIcon).toBeUndefined()
    })
  })

  describe('variants', () => {
    it('renders default variant', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          variant: 'default',
        },
      })

      expect(wrapper.classes()).toContain('border-gray-200')
    })

    it('renders success variant', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          variant: 'success',
        },
      })

      expect(wrapper.classes()).toContain('border-green-200')
    })

    it('renders warning variant', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          variant: 'warning',
        },
      })

      expect(wrapper.classes()).toContain('border-yellow-200')
    })

    it('renders danger variant', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          variant: 'danger',
        },
      })

      expect(wrapper.classes()).toContain('border-red-200')
    })

    it('renders info variant', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          variant: 'info',
        },
      })

      expect(wrapper.classes()).toContain('border-blue-200')
    })

    it('renders primary variant', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          variant: 'primary',
        },
      })

      expect(wrapper.classes()).toContain('border-primary-200')
    })

    it('applies variant color to value', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          variant: 'success',
        },
      })

      const value = wrapper.find('.font-bold')
      expect(value.classes()).toContain('text-green-600')
    })

    it('applies variant color to icon', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          icon: 'users',
          variant: 'info',
        },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.classes()).toContain('text-blue-600')
    })
  })

  describe('sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          size: 'sm',
        },
      })

      expect(wrapper.classes()).toContain('p-4')
      const value = wrapper.find('.font-bold')
      expect(value.classes()).toContain('text-2xl')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
        },
      })

      expect(wrapper.classes()).toContain('p-5')
      const value = wrapper.find('.font-bold')
      expect(value.classes()).toContain('text-3xl')
    })

    it('renders large size', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          size: 'lg',
        },
      })

      expect(wrapper.classes()).toContain('p-6')
      const value = wrapper.find('.font-bold')
      expect(value.classes()).toContain('text-4xl')
    })
  })

  describe('loading state', () => {
    it('shows skeleton when loading', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          loading: true,
        },
      })

      const skeleton = wrapper.find('.animate-pulse')
      expect(skeleton.exists()).toBe(true)
    })

    it('hides value when loading', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          loading: true,
        },
      })

      const value = wrapper.find('.font-bold')
      expect(value.exists()).toBe(false)
    })

    it('shows label when loading', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          loading: true,
        },
      })

      expect(wrapper.text()).toContain('Users')
    })

    it('hides change when loading', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          change: 10,
          loading: true,
        },
      })

      expect(wrapper.findComponent({ name: 'Badge' }).exists()).toBe(false)
    })
  })

  describe('slots', () => {
    it('renders footer slot', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
        },
        slots: {
          footer: '<div class="custom-footer">View details</div>',
        },
      })

      expect(wrapper.find('.custom-footer').exists()).toBe(true)
      expect(wrapper.text()).toContain('View details')
    })

    it('footer has border top', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
        },
        slots: {
          footer: '<div>Footer</div>',
        },
      })

      const footer = wrapper.find('.border-t')
      expect(footer.exists()).toBe(true)
    })
  })

  describe('styling', () => {
    it('has white background', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
        },
      })

      expect(wrapper.classes()).toContain('bg-white')
    })

    it('has border', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
        },
      })

      expect(wrapper.classes()).toContain('border')
    })

    it('has rounded corners', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
        },
      })

      expect(wrapper.classes()).toContain('rounded-lg')
    })

    it('has transition', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
        },
      })

      expect(wrapper.classes()).toContain('transition-all')
    })

    it('icon container has rounded background', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Users',
          value: 100,
          icon: 'users',
        },
      })

      const iconContainer = wrapper.find('.rounded-full')
      expect(iconContainer.exists()).toBe(true)
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Total Revenue',
          value: 12500,
          prefix: '$',
          suffix: 'USD',
          change: 15.3,
          changeLabel: 'vs last month',
          icon: 'dollar-sign',
          variant: 'success',
          size: 'lg',
        },
      })

      expect(wrapper.text()).toContain('Total Revenue')
      expect(wrapper.text()).toContain('12500')
      expect(wrapper.text()).toContain('$')
      expect(wrapper.text()).toContain('USD')
      expect(wrapper.text()).toContain('+15.3%')
      expect(wrapper.text()).toContain('vs last month')

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      const mainIcon = icons.find((icon) => icon.props('name') === 'dollar-sign')
      expect(mainIcon).toBeDefined()
    })

    it('works with minimal props', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Count',
          value: 42,
        },
      })

      expect(wrapper.exists()).toBe(true)
      expect(wrapper.text()).toContain('Count')
      expect(wrapper.text()).toContain('42')
    })

    it('handles negative change with danger variant', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Sales',
          value: 800,
          change: -12,
          variant: 'danger',
        },
      })

      expect(wrapper.text()).toContain('-12%')
      const badge = wrapper.findComponent({ name: 'Badge' })
      expect(badge.props('variant')).toBe('danger')
    })
  })

  describe('edge cases', () => {
    it('handles zero value', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Count',
          value: 0,
        },
      })

      expect(wrapper.text()).toContain('0')
    })

    it('handles very large numbers', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Count',
          value: 9999999,
        },
      })

      expect(wrapper.text()).toContain('9999999')
    })

    it('handles decimal values', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Rate',
          value: '99.99',
        },
      })

      expect(wrapper.text()).toContain('99.99')
    })

    it('handles empty string value', () => {
      const wrapper = mount(Stat, {
        props: {
          label: 'Status',
          value: '',
        },
      })

      expect(wrapper.exists()).toBe(true)
    })
  })
})
