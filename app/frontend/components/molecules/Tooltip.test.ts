import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import Tooltip from './Tooltip.vue'

describe('Tooltip', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.restoreAllMocks()
    vi.useRealTimers()
  })

  // Basic rendering
  describe('Basic Rendering', () => {
    it('renders trigger content', () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip text',
        },
        slots: {
          default: '<button>Hover me</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.html()).toContain('Hover me')
    })

    it('does not show tooltip by default', () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip text',
        },
        slots: {
          default: '<button>Hover me</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(false)
    })

    it('renders tooltip content from prop', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Helpful information',
        },
        slots: {
          default: '<button>Hover me</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.text()).toContain('Helpful information')
    })

    it('renders tooltip content from slot', async () => {
      const wrapper = mount(Tooltip, {
        slots: {
          default: '<button>Hover me</button>',
          content: '<strong>Custom content</strong>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.html()).toContain('Custom content')
    })
  })

  // Show/Hide behavior
  describe('Show/Hide Behavior', () => {
    it('shows tooltip on mouseenter after delay', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          delay: 200,
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      expect(wrapper.find('[role="tooltip"]').exists()).toBe(false)

      vi.advanceTimersByTime(200)
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(true)
    })

    it('hides tooltip on mouseleave', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          delay: 0,
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(true)

      await wrapper.trigger('mouseleave')
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(false)
    })

    it('shows tooltip on focus', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
        },
        slots: {
          default: '<button>Focus me</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('focus')
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(true)
    })

    it('hides tooltip on blur', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
        },
        slots: {
          default: '<button>Focus me</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('focus')
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[role="tooltip"]').exists()).toBe(true)

      await wrapper.trigger('blur')
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[role="tooltip"]').exists()).toBe(false)
    })

    it('cancels show timeout on mouseleave before delay', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          delay: 200,
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.advanceTimersByTime(100)
      await wrapper.trigger('mouseleave')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(false)
    })
  })

  // Disabled state
  describe('Disabled State', () => {
    it('does not show tooltip when disabled', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          disabled: true,
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(false)
    })

    it('does not show tooltip on focus when disabled', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          disabled: true,
        },
        slots: {
          default: '<button>Focus</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('focus')
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(false)
    })
  })

  // Variants
  describe('Variants', () => {
    it('renders dark variant by default', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      const tooltip = wrapper.find('[role="tooltip"]')
      expect(tooltip.classes()).toContain('bg-gray-900')
      expect(tooltip.classes()).toContain('text-white')
    })

    it('renders light variant', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          variant: 'light',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      const tooltip = wrapper.find('[role="tooltip"]')
      expect(tooltip.classes()).toContain('bg-white')
      expect(tooltip.classes()).toContain('text-gray-900')
    })
  })

  // Max width
  describe('Max Width', () => {
    it('applies medium max-width by default', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').classes()).toContain('max-w-sm')
    })

    it('applies small max-width', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          maxWidth: 'sm',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').classes()).toContain('max-w-xs')
    })

    it('applies large max-width', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          maxWidth: 'lg',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').classes()).toContain('max-w-lg')
    })

    it('applies no max-width when none', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          maxWidth: 'none',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      const tooltip = wrapper.find('[role="tooltip"]')
      expect(tooltip.classes()).not.toContain('max-w-sm')
      expect(tooltip.classes()).not.toContain('max-w-xs')
      expect(tooltip.classes()).not.toContain('max-w-lg')
    })
  })

  // Arrow
  describe('Arrow', () => {
    it('shows arrow by default', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('.w-2.h-2').exists()).toBe(true)
    })

    it('hides arrow when showArrow is false', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          showArrow: false,
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('.w-2.h-2').exists()).toBe(false)
    })
  })

  // Delay
  describe('Delay', () => {
    it('uses default delay of 200ms', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')

      vi.advanceTimersByTime(199)
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[role="tooltip"]').exists()).toBe(false)

      vi.advanceTimersByTime(1)
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[role="tooltip"]').exists()).toBe(true)
    })

    it('respects custom delay', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          delay: 500,
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')

      vi.advanceTimersByTime(499)
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[role="tooltip"]').exists()).toBe(false)

      vi.advanceTimersByTime(1)
      await wrapper.vm.$nextTick()
      expect(wrapper.find('[role="tooltip"]').exists()).toBe(true)
    })

    it('shows immediately with 0 delay', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          delay: 0,
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(true)
    })
  })

  // Accessibility
  describe('Accessibility', () => {
    it('has role tooltip', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(true)
    })

    it('generates unique id', async () => {
      const wrapper1 = mount(Tooltip, {
        props: {
          content: 'Tooltip 1',
        },
        slots: {
          default: '<button>Hover 1</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      const wrapper2 = mount(Tooltip, {
        props: {
          content: 'Tooltip 2',
        },
        slots: {
          default: '<button>Hover 2</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper1.trigger('mouseenter')
      await wrapper2.trigger('mouseenter')
      vi.runAllTimers()
      await Promise.all([wrapper1.vm.$nextTick(), wrapper2.vm.$nextTick()])

      const id1 = wrapper1.find('[role="tooltip"]').attributes('id')
      const id2 = wrapper2.find('[role="tooltip"]').attributes('id')

      expect(id1).toBeDefined()
      expect(id2).toBeDefined()
      expect(id1).not.toBe(id2)
    })

    it('has pointer-events-none to prevent interaction', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').classes()).toContain('pointer-events-none')
    })
  })

  // Placement
  describe('Placement', () => {
    it('defaults to top placement', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      // Top placement means arrow is at bottom
      const arrow = wrapper.find('.w-2.h-2')
      expect(arrow.classes()).toContain('bottom-[-4px]')
    })

    it('supports bottom placement', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          placement: 'bottom',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      const arrow = wrapper.find('.w-2.h-2')
      expect(arrow.classes()).toContain('top-[-4px]')
    })

    it('supports left placement', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          placement: 'left',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      const arrow = wrapper.find('.w-2.h-2')
      expect(arrow.classes()).toContain('right-[-4px]')
    })

    it('supports right placement', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          placement: 'right',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      const arrow = wrapper.find('.w-2.h-2')
      expect(arrow.classes()).toContain('left-[-4px]')
    })
  })

  // Edge cases
  describe('Edge Cases', () => {
    it('handles empty content', async () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: '',
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      await wrapper.trigger('mouseenter')
      vi.runAllTimers()
      await wrapper.vm.$nextTick()

      expect(wrapper.find('[role="tooltip"]').exists()).toBe(true)
    })

    it('cleans up timeout on unmount', () => {
      const wrapper = mount(Tooltip, {
        props: {
          content: 'Tooltip',
          delay: 500,
        },
        slots: {
          default: '<button>Hover</button>',
        },
        global: {
          stubs: {
            Teleport: true,
          },
        },
      })

      wrapper.trigger('mouseenter')
      wrapper.unmount()

      // Should not throw error
      expect(() => vi.runAllTimers()).not.toThrow()
    })
  })
})
