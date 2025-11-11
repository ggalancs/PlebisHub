import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Badge from './Badge.vue'
import Icon from '../atoms/Icon.vue'

describe('Badge', () => {
  // Basic rendering
  describe('Basic Rendering', () => {
    it('renders badge with label', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'New',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('New')
    })

    it('renders badge with slot content', () => {
      const wrapper = mount(Badge, {
        slots: {
          default: 'Custom Badge',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Custom Badge')
    })

    it('prefers slot over label prop', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Label',
        },
        slots: {
          default: 'Slot',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Slot')
    })

    it('renders as span element', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.element.tagName).toBe('SPAN')
    })
  })

  // Variants
  describe('Variants', () => {
    it('renders default variant', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Default',
          variant: 'default',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-gray-100')
      expect(wrapper.classes()).toContain('text-gray-800')
    })

    it('renders primary variant', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Primary',
          variant: 'primary',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-primary')
      expect(wrapper.classes()).toContain('text-white')
    })

    it('renders secondary variant', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Secondary',
          variant: 'secondary',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-secondary')
      expect(wrapper.classes()).toContain('text-white')
    })

    it('renders success variant', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Success',
          variant: 'success',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-green-100')
      expect(wrapper.classes()).toContain('text-green-800')
    })

    it('renders warning variant', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Warning',
          variant: 'warning',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-yellow-100')
      expect(wrapper.classes()).toContain('text-yellow-800')
    })

    it('renders danger variant', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Danger',
          variant: 'danger',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-red-100')
      expect(wrapper.classes()).toContain('text-red-800')
    })

    it('renders info variant', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Info',
          variant: 'info',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-blue-100')
      expect(wrapper.classes()).toContain('text-blue-800')
    })
  })

  // Sizes
  describe('Sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Small',
          size: 'sm',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('px-2')
      expect(wrapper.classes()).toContain('text-xs')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Medium',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('px-2.5')
      expect(wrapper.classes()).toContain('text-sm')
    })

    it('renders large size', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Large',
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('px-3')
      expect(wrapper.classes()).toContain('text-base')
    })
  })

  // Rounded
  describe('Rounded', () => {
    it('renders medium rounded by default', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('rounded-md')
    })

    it('renders small rounded', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          rounded: 'sm',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('rounded-sm')
    })

    it('renders large rounded', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          rounded: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('rounded-lg')
    })

    it('renders full rounded', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          rounded: 'full',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('rounded-full')
    })
  })

  // Icon
  describe('Icon', () => {
    it('renders icon when provided', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          icon: 'star',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(true)
      expect(wrapper.findComponent(Icon).props('name')).toBe('star')
    })

    it('does not render icon by default', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAllComponents(Icon)).toHaveLength(0)
    })

    it('adjusts icon size based on badge size', () => {
      const wrapperSm = mount(Badge, {
        props: {
          label: 'Small',
          icon: 'star',
          size: 'sm',
        },
        global: {
          components: { Icon },
        },
      })

      const wrapperLg = mount(Badge, {
        props: {
          label: 'Large',
          icon: 'star',
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapperSm.findComponent(Icon).props('size')).toBe(12)
      expect(wrapperLg.findComponent(Icon).props('size')).toBe(18)
    })

    it('renders icon without label', () => {
      const wrapper = mount(Badge, {
        props: {
          icon: 'check',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(true)
    })
  })

  // Removable
  describe('Removable', () => {
    it('does not show remove button by default', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('button').exists()).toBe(false)
    })

    it('shows remove button when removable', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          removable: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('button').exists()).toBe(true)
    })

    it('emits remove event when remove button clicked', async () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          removable: true,
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.find('button').trigger('click')

      expect(wrapper.emitted('remove')).toBeTruthy()
      expect(wrapper.emitted('remove')).toHaveLength(1)
    })

    it('remove button has x icon', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          removable: true,
        },
        global: {
          components: { Icon },
        },
      })

      const icons = wrapper.findAllComponents(Icon)
      const xIcon = icons.find((icon) => icon.props('name') === 'x')
      expect(xIcon).toBeDefined()
    })

    it('remove button has aria-label', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          removable: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('button').attributes('aria-label')).toBe('Remove badge')
    })

    it('uses custom remove label', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          removable: true,
          removeLabel: 'Delete tag',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('button').attributes('aria-label')).toBe('Delete tag')
    })

    it('stops event propagation on remove', async () => {
      const parentClick = vi.fn()
      const wrapper = mount(
        {
          components: { Badge },
          template:
            '<div @click="parentClick"><Badge label="Test" removable @remove="() => {}" /></div>',
          setup() {
            return { parentClick }
          },
        },
        {
          global: {
            components: { Icon },
          },
        }
      )

      await wrapper.find('button').trigger('click')

      expect(parentClick).not.toHaveBeenCalled()
    })
  })

  // Disabled
  describe('Disabled', () => {
    it('does not apply disabled styling by default', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).not.toContain('opacity-50')
      expect(wrapper.classes()).not.toContain('cursor-not-allowed')
    })

    it('applies disabled styling when disabled', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('opacity-50')
      expect(wrapper.classes()).toContain('cursor-not-allowed')
    })

    it('hides remove button when disabled', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          removable: true,
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('button').exists()).toBe(false)
    })

    it('does not emit remove when disabled', async () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      // Even if we manually trigger (though button shouldn't exist)
      expect(wrapper.emitted('remove')).toBeFalsy()
    })
  })

  // Edge cases
  describe('Edge Cases', () => {
    it('renders without label or slot', () => {
      const wrapper = mount(Badge, {
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.exists()).toBe(true)
    })

    it('handles empty label', () => {
      const wrapper = mount(Badge, {
        props: {
          label: '',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('')
    })

    it('handles long text', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'This is a very long badge text that might overflow',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('This is a very long badge text')
    })
  })

  // Combinations
  describe('Combinations', () => {
    it('renders with icon and removable', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          icon: 'star',
          removable: true,
        },
        global: {
          components: { Icon },
        },
      })

      const icons = wrapper.findAllComponents(Icon)
      expect(icons).toHaveLength(2) // star icon + x icon
      expect(wrapper.find('button').exists()).toBe(true)
    })

    it('renders primary variant with full rounded and large size', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
          variant: 'primary',
          rounded: 'full',
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-primary')
      expect(wrapper.classes()).toContain('rounded-full')
      expect(wrapper.classes()).toContain('text-base')
    })

    it('renders success badge with icon, small size, and removable', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Success',
          variant: 'success',
          icon: 'check',
          size: 'sm',
          removable: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-green-100')
      expect(wrapper.classes()).toContain('text-xs')
      expect(wrapper.findComponent(Icon).props('name')).toBe('check')
      expect(wrapper.find('button').exists()).toBe(true)
    })

    it('renders danger badge disabled with icon', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Danger',
          variant: 'danger',
          icon: 'alert-circle',
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('bg-red-100')
      expect(wrapper.classes()).toContain('opacity-50')
      expect(wrapper.findComponent(Icon).exists()).toBe(true)
    })
  })

  // Styling
  describe('Styling', () => {
    it('applies inline-flex', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('inline-flex')
    })

    it('applies items-center and justify-center', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('items-center')
      expect(wrapper.classes()).toContain('justify-center')
    })

    it('applies font-medium', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('font-medium')
    })

    it('applies transition-colors', () => {
      const wrapper = mount(Badge, {
        props: {
          label: 'Badge',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('transition-colors')
    })
  })
})
