import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ProgressSteps from './ProgressSteps.vue'
import Icon from '../atoms/Icon.vue'

const mockSteps = [
  { id: 1, label: 'Step 1', description: 'First step' },
  { id: 2, label: 'Step 2', description: 'Second step' },
  { id: 3, label: 'Step 3', description: 'Third step' },
]

describe('ProgressSteps', () => {
  // Basic rendering
  describe('Basic Rendering', () => {
    it('renders all steps', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAll('li')).toHaveLength(3)
    })

    it('renders step labels', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Step 1')
      expect(wrapper.text()).toContain('Step 2')
      expect(wrapper.text()).toContain('Step 3')
    })

    it('renders step descriptions', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('First step')
      expect(wrapper.text()).toContain('Second step')
      expect(wrapper.text()).toContain('Third step')
    })

    it('renders step numbers', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('1')
      expect(wrapper.text()).toContain('2')
      expect(wrapper.text()).toContain('3')
    })
  })

  // Current step
  describe('Current Step', () => {
    it('marks the current step with aria-current', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 1,
        },
        global: {
          components: { Icon },
        },
      })

      const steps = wrapper.findAll('[aria-current]')
      expect(steps).toHaveLength(1)
      expect(steps[0].attributes('aria-current')).toBe('step')
    })

    it('applies correct styling to completed steps', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 2,
        },
        global: {
          components: { Icon },
        },
      })

      // First two steps should be completed (show check icons)
      const icons = wrapper.findAllComponents(Icon)
      const checkIcons = icons.filter((icon) => icon.props('name') === 'check')
      expect(checkIcons.length).toBeGreaterThanOrEqual(2)
    })

    it('shows check icon for completed steps', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 1,
        },
        global: {
          components: { Icon },
        },
      })

      const icons = wrapper.findAllComponents(Icon)
      const checkIcon = icons.find((icon) => icon.props('name') === 'check')
      expect(checkIcon).toBeDefined()
    })
  })

  // Orientation
  describe('Orientation', () => {
    it('renders horizontal by default', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('nav').classes()).toContain('flex-row')
    })

    it('renders vertical orientation', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
          orientation: 'vertical',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('nav').classes()).toContain('flex-col')
    })
  })

  // Labels
  describe('Labels', () => {
    it('shows labels by default', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Step 1')
    })

    it('hides labels when showLabels is false', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
          showLabels: false,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).not.toContain('Step 1')
      // Numbers should still be visible
      expect(wrapper.text()).toContain('1')
    })
  })

  // Clickable steps
  describe('Clickable Steps', () => {
    it('renders buttons when clickable is true', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
          clickable: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAll('button')).toHaveLength(3)
    })

    it('does not render buttons when clickable is false', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
          clickable: false,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAll('button')).toHaveLength(0)
    })

    it('emits stepClick event when step is clicked', async () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
          clickable: true,
        },
        global: {
          components: { Icon },
        },
      })

      await wrapper.findAll('button')[1].trigger('click')

      expect(wrapper.emitted('stepClick')).toBeTruthy()
      expect(wrapper.emitted('stepClick')?.[0]).toEqual([1])
    })

    it('does not emit event when step is disabled', async () => {
      const stepsWithDisabled = [
        { id: 1, label: 'Step 1' },
        { id: 2, label: 'Step 2', disabled: true },
        { id: 3, label: 'Step 3' },
      ]

      const wrapper = mount(ProgressSteps, {
        props: {
          steps: stepsWithDisabled,
          currentStep: 0,
          clickable: true,
        },
        global: {
          components: { Icon },
        },
      })

      const buttons = wrapper.findAll('button')
      // Disabled steps are rendered as divs, not buttons, so we should only have 2 buttons
      expect(buttons).toHaveLength(2)
    })
  })

  // Sizes
  describe('Sizes', () => {
    it('renders small size', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
          size: 'sm',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('.w-8').exists()).toBe(true)
    })

    it('renders medium size by default', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('.w-10').exists()).toBe(true)
    })

    it('renders large size', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('.w-12').exists()).toBe(true)
    })

    it('adjusts icon size based on step size', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 1, // So we get a check icon
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      const icon = wrapper.findComponent(Icon)
      expect(icon.props('size')).toBe(24)
    })
  })

  // Variants
  describe('Variants', () => {
    it('renders default variant', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 1,
          variant: 'default',
        },
        global: {
          components: { Icon },
        },
      })

      // Current step should have border
      expect(wrapper.find('.border-primary').exists()).toBe(true)
    })

    it('renders simple variant', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 1,
          variant: 'simple',
        },
        global: {
          components: { Icon },
        },
      })

      // Simple variant uses ring instead of border
      expect(wrapper.find('.ring-4').exists()).toBe(true)
    })
  })

  // Custom icons
  describe('Custom Icons', () => {
    it('renders custom icons for steps', () => {
      const stepsWithIcons = [
        { id: 1, label: 'Step 1', icon: 'user' },
        { id: 2, label: 'Step 2', icon: 'settings' },
        { id: 3, label: 'Step 3', icon: 'check-circle' },
      ]

      const wrapper = mount(ProgressSteps, {
        props: {
          steps: stepsWithIcons,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      const icons = wrapper.findAllComponents(Icon)
      expect(icons.some((icon) => icon.props('name') === 'user')).toBe(true)
      expect(icons.some((icon) => icon.props('name') === 'settings')).toBe(true)
    })

    it('prefers check icon over custom icon for completed steps', () => {
      const stepsWithIcons = [
        { id: 1, label: 'Step 1', icon: 'user' },
        { id: 2, label: 'Step 2', icon: 'settings' },
      ]

      const wrapper = mount(ProgressSteps, {
        props: {
          steps: stepsWithIcons,
          currentStep: 1,
        },
        global: {
          components: { Icon },
        },
      })

      const icons = wrapper.findAllComponents(Icon)
      // First step should show check, not user icon
      expect(icons[0].props('name')).toBe('check')
    })
  })

  // Connectors
  describe('Connectors', () => {
    it('renders connectors between steps', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      // Should have 2 connectors for 3 steps
      const connectors = wrapper.findAll('[aria-hidden="true"]')
      expect(connectors.length).toBeGreaterThanOrEqual(2)
    })

    it('colors connectors for completed steps', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 2,
        },
        global: {
          components: { Icon },
        },
      })

      // At least one connector should have primary color
      expect(wrapper.find('.bg-primary').exists()).toBe(true)
    })
  })

  // Accessibility
  describe('Accessibility', () => {
    it('has nav element with aria-label', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
          ariaLabel: 'Checkout progress',
        },
        global: {
          components: { Icon },
        },
      })

      const nav = wrapper.find('nav')
      expect(nav.attributes('aria-label')).toBe('Checkout progress')
    })

    it('uses default aria-label when none provided', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      const nav = wrapper.find('nav')
      expect(nav.attributes('aria-label')).toBe('Progress')
    })

    it('uses ordered list for steps', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('ol').exists()).toBe(true)
    })
  })

  // Disabled steps
  describe('Disabled Steps', () => {
    it('applies disabled styling to disabled steps', () => {
      const stepsWithDisabled = [
        { id: 1, label: 'Step 1' },
        { id: 2, label: 'Step 2', disabled: true },
      ]

      const wrapper = mount(ProgressSteps, {
        props: {
          steps: stepsWithDisabled,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('.opacity-50').exists()).toBe(true)
    })
  })

  // Edge cases
  describe('Edge Cases', () => {
    it('handles single step', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: [{ id: 1, label: 'Only Step' }],
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAll('li')).toHaveLength(1)
      // No connectors for single step
      expect(wrapper.findAll('[aria-hidden="true"]')).toHaveLength(0)
    })

    it('handles last step as current', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 2,
        },
        global: {
          components: { Icon },
        },
      })

      // All previous steps should show check icons
      const icons = wrapper.findAllComponents(Icon)
      const checkIcons = icons.filter((icon) => icon.props('name') === 'check')
      expect(checkIcons).toHaveLength(2)
    })

    it('handles steps without descriptions', () => {
      const stepsNoDesc = [
        { id: 1, label: 'Step 1' },
        { id: 2, label: 'Step 2' },
      ]

      const wrapper = mount(ProgressSteps, {
        props: {
          steps: stepsNoDesc,
          currentStep: 0,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Step 1')
    })
  })

  // Combinations
  describe('Combinations', () => {
    it('renders vertical clickable steps with custom size', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 1,
          orientation: 'vertical',
          clickable: true,
          size: 'lg',
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('nav').classes()).toContain('flex-col')
      expect(wrapper.findAll('button')).toHaveLength(3)
      expect(wrapper.find('.w-12').exists()).toBe(true)
    })

    it('renders simple variant without labels', () => {
      const wrapper = mount(ProgressSteps, {
        props: {
          steps: mockSteps,
          currentStep: 1,
          variant: 'simple',
          showLabels: false,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.find('.ring-4').exists()).toBe(true)
      expect(wrapper.text()).not.toContain('Step 1')
    })
  })
})
