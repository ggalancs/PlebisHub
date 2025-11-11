import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Stepper from './Stepper.vue'

describe('Stepper', () => {
  const basicSteps = [
    { label: 'Step 1', description: 'First step' },
    { label: 'Step 2', description: 'Second step' },
    { label: 'Step 3', description: 'Third step' },
  ]

  describe('rendering', () => {
    it('renders all steps', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0 },
      })

      expect(wrapper.text()).toContain('Step 1')
      expect(wrapper.text()).toContain('Step 2')
      expect(wrapper.text()).toContain('Step 3')
    })

    it('renders step descriptions', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0 },
      })

      expect(wrapper.text()).toContain('First step')
      expect(wrapper.text()).toContain('Second step')
      expect(wrapper.text()).toContain('Third step')
    })

    it('renders without descriptions', () => {
      const steps = [{ label: 'Step 1' }, { label: 'Step 2' }]
      const wrapper = mount(Stepper, {
        props: { steps, currentStep: 0 },
      })

      expect(wrapper.findAll('.step-content').length).toBe(2)
    })

    it('renders step numbers by default', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0 },
      })

      const stepNumbers = wrapper.findAll('.w-10.h-10')
      expect(stepNumbers[0].text()).toBe('1')
      expect(stepNumbers[1].text()).toBe('2')
      expect(stepNumbers[2].text()).toBe('3')
    })

    it('renders connecting lines', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0 },
      })

      const lines = wrapper.findAll('.step-line')
      expect(lines.length).toBe(2) // 3 steps = 2 lines
    })
  })

  describe('status computation', () => {
    it('marks previous steps as complete', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 2 },
      })

      const stepNumbers = wrapper.findAll('.w-10.h-10')
      expect(stepNumbers[0].classes()).toContain('bg-primary-600')
      expect(stepNumbers[1].classes()).toContain('bg-primary-600')
    })

    it('marks current step with ring', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 1 },
      })

      const stepNumbers = wrapper.findAll('.w-10.h-10')
      expect(stepNumbers[1].classes()).toContain('ring-4')
      expect(stepNumbers[1].classes()).toContain('ring-primary-100')
    })

    it('marks future steps as upcoming', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0 },
      })

      const stepNumbers = wrapper.findAll('.w-10.h-10')
      expect(stepNumbers[1].classes()).toContain('bg-gray-200')
      expect(stepNumbers[2].classes()).toContain('bg-gray-200')
    })

    it('shows check icon for completed steps', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 2 },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      const checkIcons = icons.filter((icon) => icon.props('name') === 'check')
      expect(checkIcons.length).toBe(2) // Steps 0 and 1 are complete
    })
  })

  describe('explicit status', () => {
    it('uses explicit status when provided', () => {
      const steps = [
        { label: 'Step 1', status: 'complete' as const },
        { label: 'Step 2', status: 'error' as const },
        { label: 'Step 3', status: 'upcoming' as const },
      ]
      const wrapper = mount(Stepper, {
        props: { steps, currentStep: 1 },
      })

      const stepNumbers = wrapper.findAll('.w-10.h-10')
      expect(stepNumbers[0].classes()).toContain('bg-primary-600')
      expect(stepNumbers[1].classes()).toContain('bg-red-600')
      expect(stepNumbers[2].classes()).toContain('bg-gray-200')
    })

    it('shows error icon for error status', () => {
      const steps = [{ label: 'Step 1', status: 'error' as const }]
      const wrapper = mount(Stepper, {
        props: { steps, currentStep: 0 },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('x')
    })

    it('applies error styling', () => {
      const steps = [
        { label: 'Error Step', description: 'Something went wrong', status: 'error' as const },
      ]
      const wrapper = mount(Stepper, {
        props: { steps, currentStep: 0 },
      })

      const stepNumber = wrapper.find('.w-10.h-10')
      expect(stepNumber.classes()).toContain('bg-red-600')
    })
  })

  describe('custom icons', () => {
    it('renders custom icons', () => {
      const steps = [
        { label: 'Cart', icon: 'shopping-cart' },
        { label: 'Payment', icon: 'credit-card' },
        { label: 'Done', icon: 'check-circle' },
      ]
      const wrapper = mount(Stepper, {
        props: { steps, currentStep: 0 },
      })

      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons[0].props('name')).toBe('shopping-cart')
      expect(icons[1].props('name')).toBe('credit-card')
      expect(icons[2].props('name')).toBe('check-circle')
    })

    it('prefers custom icon over status icon', () => {
      const steps = [{ label: 'Step', icon: 'star', status: 'complete' as const }]
      const wrapper = mount(Stepper, {
        props: { steps, currentStep: 1 },
      })

      const icon = wrapper.findComponent({ name: 'Icon' })
      expect(icon.props('name')).toBe('star') // Not 'check'
    })
  })

  describe('orientation', () => {
    it('renders horizontal by default', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0 },
      })

      const stepper = wrapper.find('.stepper')
      expect(stepper.classes()).toContain('flex')
      expect(stepper.classes()).toContain('items-start')
    })

    it('renders vertical orientation', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0, orientation: 'vertical' },
      })

      const stepper = wrapper.find('.stepper')
      expect(stepper.classes()).toContain('flex-col')
    })

    it('applies correct line styles for horizontal', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0, orientation: 'horizontal' },
      })

      const line = wrapper.find('.step-line')
      expect(line.classes()).toContain('px-4')
    })

    it('applies correct line styles for vertical', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0, orientation: 'vertical' },
      })

      const line = wrapper.find('.step-line')
      expect(line.classes()).toContain('ml-5')
    })
  })

  describe('clickable', () => {
    it('is not clickable by default', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 2 },
      })

      const steps = wrapper.findAll('.step')
      expect(steps[0].classes()).not.toContain('cursor-pointer')
    })

    it('adds cursor-pointer to completed steps when clickable', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 2, clickable: true },
      })

      const stepElements = wrapper.findAll('.step > div')
      expect(stepElements[0].classes()).toContain('cursor-pointer')
      expect(stepElements[1].classes()).toContain('cursor-pointer')
      expect(stepElements[2].classes()).not.toContain('cursor-pointer') // Current step
    })

    it('emits step-click when completed step clicked', async () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 2, clickable: true },
      })

      const stepElements = wrapper.findAll('.step > div')
      await stepElements[0].trigger('click')

      expect(wrapper.emitted('step-click')).toBeTruthy()
      expect(wrapper.emitted('step-click')?.[0]).toEqual([0])
    })

    it('does not emit when non-completed step clicked', async () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 1, clickable: true },
      })

      const stepElements = wrapper.findAll('.step > div')
      await stepElements[2].trigger('click') // Upcoming step

      expect(wrapper.emitted('step-click')).toBeFalsy()
    })

    it('does not emit when not clickable', async () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 2, clickable: false },
      })

      const stepElements = wrapper.findAll('.step > div')
      await stepElements[0].trigger('click')

      expect(wrapper.emitted('step-click')).toBeFalsy()
    })
  })

  describe('line colors', () => {
    it('colors lines for completed steps', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 2 },
      })

      const lines = wrapper.findAll('.step-line > div')
      expect(lines[0].classes()).toContain('bg-primary-600')
      expect(lines[1].classes()).toContain('bg-primary-600')
    })

    it('uses gray for upcoming step lines', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0 },
      })

      const lines = wrapper.findAll('.step-line > div')
      expect(lines[0].classes()).toContain('bg-gray-200')
      expect(lines[1].classes()).toContain('bg-gray-200')
    })

    it('colors line after current step', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 1 },
      })

      const lines = wrapper.findAll('.step-line > div')
      expect(lines[0].classes()).toContain('bg-primary-600') // After step 0 (complete)
      expect(lines[1].classes()).toContain('bg-gray-200') // After step 1 (current)
    })
  })

  describe('label colors', () => {
    it('highlights current step label', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 1 },
      })

      const labels = wrapper.findAll('.step-content > div:first-child')
      expect(labels[1].classes()).toContain('text-primary-600')
    })

    it('uses gray for upcoming step labels', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0 },
      })

      const labels = wrapper.findAll('.step-content > div:first-child')
      expect(labels[1].classes()).toContain('text-gray-500')
      expect(labels[2].classes()).toContain('text-gray-500')
    })

    it('uses red for error step labels', () => {
      const steps = [{ label: 'Error Step', status: 'error' as const }]
      const wrapper = mount(Stepper, {
        props: { steps, currentStep: 0 },
      })

      const label = wrapper.find('.step-content > div:first-child')
      expect(label.classes()).toContain('text-red-600')
    })
  })

  describe('edge cases', () => {
    it('handles single step', () => {
      const steps = [{ label: 'Only Step' }]
      const wrapper = mount(Stepper, {
        props: { steps, currentStep: 0 },
      })

      expect(wrapper.findAll('.step').length).toBe(1)
      expect(wrapper.findAll('.step-line').length).toBe(0)
    })

    it('handles many steps', () => {
      const steps = Array.from({ length: 10 }, (_, i) => ({
        label: `Step ${i + 1}`,
      }))
      const wrapper = mount(Stepper, {
        props: { steps, currentStep: 5 },
      })

      expect(wrapper.findAll('.step').length).toBe(10)
      expect(wrapper.findAll('.step-line').length).toBe(9)
    })

    it('handles currentStep at end', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 2 },
      })

      const stepNumbers = wrapper.findAll('.w-10.h-10')
      expect(stepNumbers[2].classes()).toContain('ring-4')
    })

    it('handles currentStep at start', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0 },
      })

      const stepNumbers = wrapper.findAll('.w-10.h-10')
      expect(stepNumbers[0].classes()).toContain('ring-4')
    })
  })

  describe('layout', () => {
    it('centers content in horizontal mode', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0, orientation: 'horizontal' },
      })

      const stepContents = wrapper.findAll('.step-content')
      stepContents.forEach((content) => {
        expect(content.classes()).toContain('text-center')
      })
    })

    it('does not center content in vertical mode', () => {
      const wrapper = mount(Stepper, {
        props: { steps: basicSteps, currentStep: 0, orientation: 'vertical' },
      })

      const stepContents = wrapper.findAll('.step-content')
      stepContents.forEach((content) => {
        expect(content.classes()).not.toContain('text-center')
      })
    })
  })

  describe('combinations', () => {
    it('works with all features', () => {
      const steps = [
        {
          label: 'Cart',
          description: 'Review items',
          icon: 'shopping-cart',
          status: 'complete' as const,
        },
        {
          label: 'Payment',
          description: 'Enter payment',
          icon: 'credit-card',
          status: 'current' as const,
        },
        {
          label: 'Confirm',
          description: 'Review order',
          icon: 'check-circle',
          status: 'upcoming' as const,
        },
      ]
      const wrapper = mount(Stepper, {
        props: { steps, currentStep: 1, orientation: 'vertical', clickable: true },
      })

      expect(wrapper.exists()).toBe(true)
      expect(wrapper.text()).toContain('Cart')
      expect(wrapper.text()).toContain('Payment')
      expect(wrapper.text()).toContain('Confirm')
    })
  })
})
