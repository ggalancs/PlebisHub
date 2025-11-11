import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Kbd from './Kbd.vue'
import Icon from '../atoms/Icon.vue'

describe('Kbd', () => {
  // Basic rendering
  describe('Basic Rendering', () => {
    it('renders a kbd element', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'Ctrl',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').exists()).toBe(true)
    })

    it('renders single key', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'Enter',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Enter')
    })

    it('renders key combination from array', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: ['Ctrl', 'C'],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Ctrl + C')
    })

    it('renders multiple keys with + separator', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: ['Cmd', 'Shift', 'P'],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Cmd + Shift + P')
    })

    it('renders slot content', () => {
      const wrapper = mount(Kbd, {
        slots: {
          default: 'Custom Key',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Custom Key')
    })
  })

  // Icons
  describe('Icons', () => {
    it('renders icon when provided', () => {
      const wrapper = mount(Kbd, {
        props: {
          icon: 'command',
          keys: 'K',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(true)
      expect(wrapper.findComponent(Icon).props('name')).toBe('command')
    })

    it('renders icon without keys', () => {
      const wrapper = mount(Kbd, {
        props: {
          icon: 'arrow-up',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(true)
    })

    it('renders icon with slot content', () => {
      const wrapper = mount(Kbd, {
        props: {
          icon: 'command',
        },
        slots: {
          default: 'K',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(true)
      expect(wrapper.text()).toBe('K')
    })
  })

  // Sizes
  describe('Sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'A',
          size: 'sm',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('px-1.5')
      expect(wrapper.find('kbd').classes()).toContain('text-xs')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'B',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('px-2')
      expect(wrapper.find('kbd').classes()).toContain('text-sm')
    })

    it('renders large size', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'C',
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('px-3')
      expect(wrapper.find('kbd').classes()).toContain('text-base')
    })

    it('adjusts icon size based on kbd size', () => {
      const wrapper = mount(Kbd, {
        props: {
          icon: 'command',
          keys: 'K',
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findComponent(Icon).props('size')).toBe(18)
    })
  })

  // Variants
  describe('Variants', () => {
    it('renders default variant', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'A',
          variant: 'default',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('bg-gray-50')
      expect(wrapper.find('kbd').classes()).toContain('border-gray-200')
    })

    it('renders outline variant', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'B',
          variant: 'outline',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('bg-transparent')
      expect(wrapper.find('kbd').classes()).toContain('border-gray-300')
    })

    it('renders solid variant', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'C',
          variant: 'solid',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('bg-gray-700')
      expect(wrapper.find('kbd').classes()).toContain('text-white')
    })
  })

  // Disabled state
  describe('Disabled State', () => {
    it('applies disabled styling when disabled', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'A',
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('opacity-50')
      expect(wrapper.find('kbd').classes()).toContain('cursor-not-allowed')
    })

    it('does not apply disabled styling by default', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'B',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).not.toContain('opacity-50')
    })
  })

  // Title attribute
  describe('Title Attribute', () => {
    it('sets title attribute when provided', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'Ctrl',
          title: 'Control key',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').attributes('title')).toBe('Control key')
    })

    it('has no title attribute when not provided', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'A',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').attributes('title')).toBeUndefined()
    })
  })

  // Edge cases
  describe('Edge Cases', () => {
    it('renders empty when no keys or content provided', () => {
      const wrapper = mount(Kbd, {
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('')
    })

    it('handles single key in array', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: ['A'],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('A')
    })

    it('renders empty array as empty string', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: [],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('')
    })

    it('prefers slot content over keys prop', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'Should not appear',
        },
        slots: {
          default: 'Custom',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Custom')
    })
  })

  // Common keyboard shortcuts
  describe('Common Keyboard Shortcuts', () => {
    it('renders copy shortcut', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: ['Ctrl', 'C'],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Ctrl + C')
    })

    it('renders paste shortcut', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: ['Ctrl', 'V'],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Ctrl + V')
    })

    it('renders save shortcut', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: ['Ctrl', 'S'],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Ctrl + S')
    })

    it('renders undo shortcut', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: ['Ctrl', 'Z'],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Ctrl + Z')
    })

    it('renders command palette shortcut', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: ['Cmd', 'K'],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Cmd + K')
    })
  })

  // Special keys
  describe('Special Keys', () => {
    it('renders arrow keys', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: '↑',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('↑')
    })

    it('renders escape key', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'Esc',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Esc')
    })

    it('renders return key', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: '↵',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('↵')
    })

    it('renders tab key', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'Tab',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toBe('Tab')
    })
  })

  // Combinations
  describe('Combinations', () => {
    it('renders large solid kbd with icon and key combination', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: ['Cmd', 'K'],
          icon: 'command',
          size: 'lg',
          variant: 'solid',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(true)
      expect(wrapper.text()).toContain('Cmd + K')
      expect(wrapper.find('kbd').classes()).toContain('bg-gray-700')
      expect(wrapper.find('kbd').classes()).toContain('text-base')
    })

    it('renders small outline disabled kbd', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'A',
          size: 'sm',
          variant: 'outline',
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('text-xs')
      expect(wrapper.find('kbd').classes()).toContain('bg-transparent')
      expect(wrapper.find('kbd').classes()).toContain('opacity-50')
    })

    it('renders kbd with icon, title, and custom content', () => {
      const wrapper = mount(Kbd, {
        props: {
          icon: 'arrow-up',
          title: 'Up arrow',
        },
        slots: {
          default: '↑',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findComponent(Icon).exists()).toBe(true)
      expect(wrapper.text()).toBe('↑')
      expect(wrapper.find('kbd').attributes('title')).toBe('Up arrow')
    })
  })

  // Styling
  describe('Styling', () => {
    it('applies font-mono class', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'A',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('font-mono')
    })

    it('applies rounded border', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'B',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('rounded')
      expect(wrapper.find('kbd').classes()).toContain('border')
    })

    it('applies shadow', () => {
      const wrapper = mount(Kbd, {
        props: {
          keys: 'C',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('kbd').classes()).toContain('shadow-sm')
    })
  })
})
