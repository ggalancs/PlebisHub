import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ButtonGroup from './ButtonGroup.vue'
import Icon from '../atoms/Icon.vue'

const mockButtons = [
  { id: 1, label: 'Left', icon: 'align-left' },
  { id: 2, label: 'Center', icon: 'align-center' },
  { id: 3, label: 'Right', icon: 'align-right' },
]

describe('ButtonGroup', () => {
  // Basic rendering
  describe('Basic Rendering', () => {
    it('renders all buttons', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAll('button')).toHaveLength(3)
    })

    it('renders button labels', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Left')
      expect(wrapper.text()).toContain('Center')
      expect(wrapper.text()).toContain('Right')
    })

    it('has role group', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.attributes('role')).toBe('group')
    })

    it('applies aria-label', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          ariaLabel: 'Text alignment',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.attributes('aria-label')).toBe('Text alignment')
    })
  })

  // Icons
  describe('Icons', () => {
    it('renders icons for buttons', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
        },
        global: {
          components: { Icon },
        },
      })

      const icons = wrapper.findAllComponents(Icon)
      expect(icons).toHaveLength(3)
      expect(icons[0].props('name')).toBe('align-left')
      expect(icons[1].props('name')).toBe('align-center')
      expect(icons[2].props('name')).toBe('align-right')
    })

    it('renders buttons with icon only', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [
            { id: 1, icon: 'bold' },
            { id: 2, icon: 'italic' },
            { id: 3, icon: 'underline' },
          ],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAllComponents(Icon)).toHaveLength(3)
      expect(wrapper.text()).toBe('')
    })

    it('renders buttons with label only', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [
            { id: 1, label: 'One' },
            { id: 2, label: 'Two' },
          ],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAllComponents(Icon)).toHaveLength(0)
      expect(wrapper.text()).toContain('One')
      expect(wrapper.text()).toContain('Two')
    })
  })

  // Variants
  describe('Variants', () => {
    it('renders default variant', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          variant: 'default',
        },
        global: {
          components: { Icon },
        },
      })

      const button = wrapper.findAll('button')[0]
      expect(button.classes()).toContain('bg-gray-100')
    })

    it('renders outlined variant', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          variant: 'outlined',
        },
        global: {
          components: { Icon },
        },
      })

      const button = wrapper.findAll('button')[0]
      expect(button.classes()).toContain('border')
      expect(button.classes()).toContain('bg-white')
    })

    it('renders ghost variant', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          variant: 'ghost',
        },
        global: {
          components: { Icon },
        },
      })

      const button = wrapper.findAll('button')[0]
      expect(button.classes()).toContain('bg-transparent')
    })
  })

  // Sizes
  describe('Sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          size: 'sm',
        },
        global: {
          components: { Icon },
        },
      })

      const button = wrapper.findAll('button')[0]
      expect(button.classes()).toContain('px-3')
      expect(button.classes()).toContain('text-sm')
    })

    it('renders medium size by default', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
        },
        global: {
          components: { Icon },
        },
      })

      const button = wrapper.findAll('button')[0]
      expect(button.classes()).toContain('px-4')
      expect(button.classes()).toContain('py-2')
    })

    it('renders large size', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      const button = wrapper.findAll('button')[0]
      expect(button.classes()).toContain('px-6')
      expect(button.classes()).toContain('text-base')
    })
  })

  // Orientation
  describe('Orientation', () => {
    it('renders horizontal by default', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('flex-row')
    })

    it('renders vertical orientation', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          orientation: 'vertical',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('flex-col')
    })

    it('applies rounded corners for horizontal first button', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
        },
        global: {
          components: { Icon },
        },
      })

      const firstButton = wrapper.findAll('button')[0]
      expect(firstButton.classes()).toContain('rounded-l-md')
    })

    it('applies rounded corners for horizontal last button', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
        },
        global: {
          components: { Icon },
        },
      })

      const lastButton = wrapper.findAll('button')[2]
      expect(lastButton.classes()).toContain('rounded-r-md')
    })

    it('applies rounded corners for vertical first button', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          orientation: 'vertical',
        },
        global: {
          components: { Icon },
        },
      })

      const firstButton = wrapper.findAll('button')[0]
      expect(firstButton.classes()).toContain('rounded-t-md')
    })

    it('applies rounded corners for vertical last button', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          orientation: 'vertical',
        },
        global: {
          components: { Icon },
        },
      })

      const lastButton = wrapper.findAll('button')[2]
      expect(lastButton.classes()).toContain('rounded-b-md')
    })
  })

  // Active state
  describe('Active State', () => {
    it('applies active styling to active button', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [
            { id: 1, label: 'One' },
            { id: 2, label: 'Two', active: true },
            { id: 3, label: 'Three' },
          ],
        },
        global: {
          components: { Icon },
        },
      })

      const activeButton = wrapper.findAll('button')[1]
      expect(activeButton.classes()).toContain('bg-primary')
      expect(activeButton.classes()).toContain('text-white')
    })

    it('does not apply active styling to inactive buttons', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [
            { id: 1, label: 'One' },
            { id: 2, label: 'Two', active: true },
          ],
        },
        global: {
          components: { Icon },
        },
      })

      const inactiveButton = wrapper.findAll('button')[0]
      expect(inactiveButton.classes()).not.toContain('bg-primary')
    })
  })

  // Disabled state
  describe('Disabled State', () => {
    it('disables all buttons when disabled prop is true', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      wrapper.findAll('button').forEach((button) => {
        expect(button.attributes('disabled')).toBeDefined()
      })
    })

    it('disables individual button when button.disabled is true', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [
            { id: 1, label: 'One' },
            { id: 2, label: 'Two', disabled: true },
            { id: 3, label: 'Three' },
          ],
        },
        global: {
          components: { Icon },
        },
      })

      const buttons = wrapper.findAll('button')
      expect(buttons[0].attributes('disabled')).toBeUndefined()
      expect(buttons[1].attributes('disabled')).toBeDefined()
      expect(buttons[2].attributes('disabled')).toBeUndefined()
    })

    it('applies disabled styling', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [{ id: 1, label: 'One', disabled: true }],
        },
        global: {
          components: { Icon },
        },
      })

      const button = wrapper.find('button')
      expect(button.classes()).toContain('opacity-50')
      expect(button.classes()).toContain('cursor-not-allowed')
    })
  })

  // Click events
  describe('Click Events', () => {
    it('emits click event when button is clicked', async () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.findAll('button')[1].trigger('click')

      expect(wrapper.emitted('click')).toBeTruthy()
      expect(wrapper.emitted('click')?.[0][1]).toBe(1) // index
    })

    it('does not emit click when button is disabled', async () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [{ id: 1, label: 'One', disabled: true }],
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.find('button').trigger('click')

      expect(wrapper.emitted('click')).toBeFalsy()
    })

    it('does not emit click when group is disabled', async () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.findAll('button')[0].trigger('click')

      expect(wrapper.emitted('click')).toBeFalsy()
    })
  })

  // Links
  describe('Links', () => {
    it('renders as anchor when href is provided', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [{ id: 1, label: 'Link', href: '/path' }],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('a').exists()).toBe(true)
      expect(wrapper.find('a').attributes('href')).toBe('/path')
    })

    it('renders as button when no href', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [{ id: 1, label: 'Button' }],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('button').exists()).toBe(true)
      expect(wrapper.find('a').exists()).toBe(false)
    })
  })

  // Border handling
  describe('Border Handling', () => {
    it('applies negative margins for outlined variant to collapse borders', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          variant: 'outlined',
        },
        global: {
          components: { Icon },
        },
      })

      const secondButton = wrapper.findAll('button')[1]
      expect(secondButton.classes()).toContain('-ml-[1px]')
    })

    it('applies negative top margin for vertical outlined', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          variant: 'outlined',
          orientation: 'vertical',
        },
        global: {
          components: { Icon },
        },
      })

      const secondButton = wrapper.findAll('button')[1]
      expect(secondButton.classes()).toContain('-mt-[1px]')
    })
  })

  // Single button
  describe('Single Button', () => {
    it('applies full rounded when only one button', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [{ id: 1, label: 'Only' }],
        },
        global: {
          components: { Icon },
        },
      })

      const button = wrapper.find('button')
      expect(button.classes()).toContain('rounded-md')
    })
  })

  // Combinations
  describe('Combinations', () => {
    it('renders outlined variant with active button', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: [
            { id: 1, label: 'One' },
            { id: 2, label: 'Two', active: true },
          ],
          variant: 'outlined',
        },
        global: {
          components: { Icon },
        },
      })

      const activeButton = wrapper.findAll('button')[1]
      expect(activeButton.classes()).toContain('bg-primary')
      expect(activeButton.classes()).toContain('border-primary')
    })

    it('renders vertical ghost variant with large size', () => {
      const wrapper = mount(ButtonGroup, {
        props: {
          buttons: mockButtons,
          variant: 'ghost',
          orientation: 'vertical',
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.classes()).toContain('flex-col')
      const button = wrapper.findAll('button')[0]
      expect(button.classes()).toContain('bg-transparent')
      expect(button.classes()).toContain('px-6')
    })
  })
})
