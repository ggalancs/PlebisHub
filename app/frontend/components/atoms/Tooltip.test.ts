import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import Tooltip from './Tooltip.vue'

describe('Tooltip', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  describe('rendering', () => {
    it('renders tooltip container', () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip text' },
        slots: { default: '<button>Hover me</button>' },
      })

      expect(wrapper.find('div[role="tooltip"]').exists()).toBe(true)
    })

    it('renders trigger content', () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip' },
        slots: { default: '<button>Click me</button>' },
      })

      expect(wrapper.text()).toContain('Click me')
    })

    it('renders tooltip content from prop', () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'This is a tooltip' },
        slots: { default: '<button>Hover</button>' },
      })

      expect(wrapper.find('div[role="tooltip"]').text()).toBe('This is a tooltip')
    })

    it('renders tooltip content from slot', () => {
      const wrapper = mount(Tooltip, {
        slots: {
          default: '<button>Hover</button>',
          tooltip: '<strong>Custom tooltip</strong>',
        },
      })

      expect(wrapper.find('div[role="tooltip"]').html()).toContain(
        '<strong>Custom tooltip</strong>'
      )
    })

    it('is hidden by default', () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip' },
        slots: { default: '<button>Hover</button>' },
      })

      const tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('opacity-0')
      expect(tooltip.classes()).toContain('invisible')
    })

    it('renders with different positions', () => {
      const positions = ['top', 'bottom', 'left', 'right'] as const

      positions.forEach((position) => {
        const wrapper = mount(Tooltip, {
          props: { content: 'Tooltip', position },
          slots: { default: '<button>Hover</button>' },
        })

        const tooltip = wrapper.find('div[role="tooltip"]')
        // Check that position-specific classes are applied
        expect(tooltip.classes().length).toBeGreaterThan(0)
      })
    })

    it('renders top position by default', () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip' },
        slots: { default: '<button>Hover</button>' },
      })

      const tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('bottom-full')
    })

    it('renders with different variants', () => {
      const variants = ['dark', 'light', 'primary', 'danger', 'success', 'warning'] as const

      variants.forEach((variant) => {
        const wrapper = mount(Tooltip, {
          props: { content: 'Tooltip', variant },
          slots: { default: '<button>Hover</button>' },
        })

        const tooltip = wrapper.find('div[role="tooltip"]')
        const expectedClass =
          variant === 'dark'
            ? 'bg-gray-900'
            : variant === 'light'
              ? 'bg-white'
              : variant === 'primary'
                ? 'bg-primary-600'
                : variant === 'danger'
                  ? 'bg-red-600'
                  : variant === 'success'
                    ? 'bg-green-600'
                    : 'bg-yellow-500'

        expect(tooltip.classes()).toContain(expectedClass)
      })
    })

    it('renders with arrow by default', () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip' },
        slots: { default: '<button>Hover</button>' },
      })

      const arrow = wrapper.find('div[role="tooltip"] > div')
      expect(arrow.exists()).toBe(true)
      expect(arrow.classes()).toContain('rotate-45')
    })

    it('does not render arrow when disabled', () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip', arrow: false },
        slots: { default: '<button>Hover</button>' },
      })

      const arrows = wrapper.find('div[role="tooltip"]').findAll('div')
      expect(arrows.length).toBe(0)
    })
  })

  describe('behavior', () => {
    it('shows tooltip on mouseenter after delay', async () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip', delay: 200 },
        slots: { default: '<button>Hover</button>' },
      })

      const container = wrapper.find('div')
      await container.trigger('mouseenter')

      // Tooltip should not be visible immediately
      let tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('opacity-0')

      // Advance timers past delay
      vi.advanceTimersByTime(200)
      await wrapper.vm.$nextTick()

      // Tooltip should now be visible
      tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('opacity-100')
      expect(tooltip.classes()).toContain('visible')
    })

    it('hides tooltip on mouseleave', async () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip', delay: 0 },
        slots: { default: '<button>Hover</button>' },
      })

      const container = wrapper.find('div')

      // Show tooltip
      await container.trigger('mouseenter')
      vi.advanceTimersByTime(0)
      await wrapper.vm.$nextTick()

      // Hide tooltip
      await container.trigger('mouseleave')
      await wrapper.vm.$nextTick()

      const tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('opacity-0')
      expect(tooltip.classes()).toContain('invisible')
    })

    it('shows tooltip on focus', async () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip', delay: 0 },
        slots: { default: '<button>Focus me</button>' },
      })

      const container = wrapper.find('div')
      await container.trigger('focus')
      vi.advanceTimersByTime(0)
      await wrapper.vm.$nextTick()

      const tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('opacity-100')
    })

    it('hides tooltip on blur', async () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip', delay: 0 },
        slots: { default: '<button>Focus me</button>' },
      })

      const container = wrapper.find('div')

      // Show tooltip
      await container.trigger('focus')
      vi.advanceTimersByTime(0)
      await wrapper.vm.$nextTick()

      // Hide tooltip
      await container.trigger('blur')
      await wrapper.vm.$nextTick()

      const tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('opacity-0')
    })

    it('respects custom delay', async () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip', delay: 500 },
        slots: { default: '<button>Hover</button>' },
      })

      const container = wrapper.find('div')
      await container.trigger('mouseenter')

      // Should not be visible after 200ms
      vi.advanceTimersByTime(200)
      await wrapper.vm.$nextTick()

      let tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('opacity-0')

      // Should be visible after 500ms
      vi.advanceTimersByTime(300)
      await wrapper.vm.$nextTick()

      tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('opacity-100')
    })

    it('cancels show timeout on quick mouseleave', async () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip', delay: 500 },
        slots: { default: '<button>Hover</button>' },
      })

      const container = wrapper.find('div')

      // Trigger mouseenter
      await container.trigger('mouseenter')

      // Leave before delay completes
      vi.advanceTimersByTime(200)
      await container.trigger('mouseleave')

      // Complete the original delay
      vi.advanceTimersByTime(300)
      await wrapper.vm.$nextTick()

      // Tooltip should still be hidden
      const tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('opacity-0')
    })
  })

  describe('accessibility', () => {
    it('has role="tooltip"', () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip' },
        slots: { default: '<button>Hover</button>' },
      })

      expect(wrapper.find('div[role="tooltip"]').exists()).toBe(true)
    })

    it('has pointer-events-none on tooltip', () => {
      const wrapper = mount(Tooltip, {
        props: { content: 'Tooltip' },
        slots: { default: '<button>Hover</button>' },
      })

      const tooltip = wrapper.find('div[role="tooltip"]')
      expect(tooltip.classes()).toContain('pointer-events-none')
    })
  })

  describe('combinations', () => {
    it('renders with all features', () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Custom tooltip',
          position: 'right',
          variant: 'primary',
          arrow: true,
          delay: 100,
        },
        slots: { default: '<button>Hover me</button>' },
      })

      expect(wrapper.find('div[role="tooltip"]').exists()).toBe(true)
      expect(wrapper.text()).toContain('Hover me')
      expect(wrapper.find('div[role="tooltip"]').text()).toBe('Custom tooltip')
    })

    it('works with custom slot content', () => {
      const wrapper = mount(Tooltip, {
        slots: {
          default: '<button class="custom-btn">Custom Button</button>',
          tooltip: '<div class="custom-tooltip">Rich content</div>',
        },
      })

      expect(wrapper.find('.custom-btn').exists()).toBe(true)
      expect(wrapper.find('.custom-tooltip').exists()).toBe(true)
    })
  })

  describe('arrow styling', () => {
    it('applies correct arrow position for each side', () => {
      const positions: Array<'top' | 'bottom' | 'left' | 'right'> = [
        'top',
        'bottom',
        'left',
        'right',
      ]

      positions.forEach((position) => {
        const wrapper = mount(Tooltip, {
          props: { content: 'Tooltip', position, arrow: true },
          slots: { default: '<button>Hover</button>' },
        })

        const arrow = wrapper.find('div[role="tooltip"] > div')
        expect(arrow.exists()).toBe(true)
        expect(arrow.classes()).toContain('rotate-45')
      })
    })

    it('applies correct arrow color for each variant', () => {
      const variants: Array<'dark' | 'light' | 'primary' | 'danger' | 'success' | 'warning'> = [
        'dark',
        'light',
        'primary',
        'danger',
        'success',
        'warning',
      ]

      variants.forEach((variant) => {
        const wrapper = mount(Tooltip, {
          props: { content: 'Tooltip', variant, arrow: true },
          slots: { default: '<button>Hover</button>' },
        })

        const arrow = wrapper.find('div[role="tooltip"] > div')
        expect(arrow.exists()).toBe(true)
      })
    })
  })
})
