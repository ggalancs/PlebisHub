import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ImpulsaProjectSteps from './ImpulsaProjectSteps.vue'
import type { ProjectStep } from './ImpulsaProjectSteps.vue'

const mockSteps: ProjectStep[] = [
  {
    id: '1',
    label: 'Presentación',
    description: 'Envía tu proyecto para evaluación',
    icon: 'file-plus',
    status: 'completed',
    date: '2024-01-15',
  },
  {
    id: '2',
    label: 'Evaluación',
    description: 'El equipo técnico revisa tu proyecto',
    status: 'completed',
    date: '2024-02-01',
  },
  {
    id: '3',
    label: 'Votación',
    description: 'Los ciudadanos votan tu proyecto',
    status: 'current',
  },
  {
    id: '4',
    label: 'Financiación',
    description: 'Proyecto financiado y en implementación',
    status: 'pending',
  },
]

describe('ImpulsaProjectSteps', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      expect(wrapper.find('.impulsa-project-steps').exists()).toBe(true)
    })

    it('should render all steps', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const steps = wrapper.findAll('.impulsa-project-steps__step')
      expect(steps).toHaveLength(4)
    })

    it('should render step labels', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      expect(wrapper.text()).toContain('Presentación')
      expect(wrapper.text()).toContain('Evaluación')
      expect(wrapper.text()).toContain('Votación')
      expect(wrapper.text()).toContain('Financiación')
    })

    it('should render step icons', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBeGreaterThanOrEqual(4)
    })

    it('should render custom icon', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const firstIcon = wrapper.findAllComponents({ name: 'Icon' })[0]
      expect(firstIcon.props('name')).toBe('file-plus')
    })

    it('should render connectors', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const connectors = wrapper.findAll('.impulsa-project-steps__connector')
      expect(connectors).toHaveLength(3) // One less than steps
    })
  })

  describe('orientations', () => {
    it('should default to horizontal orientation', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      expect(wrapper.classes()).toContain('impulsa-project-steps--horizontal')
    })

    it('should support vertical orientation', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          orientation: 'vertical',
        },
      })
      expect(wrapper.classes()).toContain('impulsa-project-steps--vertical')
    })
  })

  describe('step statuses', () => {
    it('should show completed step', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const firstStep = wrapper.findAll('.impulsa-project-steps__step')[0]
      expect(firstStep.classes()).toContain('impulsa-project-steps__step--completed')
    })

    it('should show current step', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const thirdStep = wrapper.findAll('.impulsa-project-steps__step')[2]
      expect(thirdStep.classes()).toContain('impulsa-project-steps__step--current')
    })

    it('should show pending step', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const lastStep = wrapper.findAll('.impulsa-project-steps__step')[3]
      expect(lastStep.classes()).toContain('impulsa-project-steps__step--pending')
    })

    it('should show skipped step', () => {
      const stepsWithSkipped = [
        ...mockSteps.slice(0, 2),
        {
          ...mockSteps[2],
          status: 'skipped' as const,
        },
        mockSteps[3],
      ]

      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: stepsWithSkipped,
        },
      })
      const thirdStep = wrapper.findAll('.impulsa-project-steps__step')[2]
      expect(thirdStep.classes()).toContain('impulsa-project-steps__step--skipped')
    })

    it('should use check-circle icon for completed steps', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      // Second step should have check-circle (no custom icon)
      expect(icons[1].props('name')).toBe('check-circle')
    })

    it('should use circle icon for current step', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons[2].props('name')).toBe('circle')
    })
  })

  describe('descriptions', () => {
    it('should show descriptions by default', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      expect(wrapper.text()).toContain('Envía tu proyecto para evaluación')
    })

    it('should hide descriptions when showDescriptions is false', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          showDescriptions: false,
        },
      })
      expect(wrapper.text()).not.toContain('Envía tu proyecto para evaluación')
    })

    it('should hide descriptions in compact mode', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Envía tu proyecto para evaluación')
    })
  })

  describe('dates', () => {
    it('should not show dates by default', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      expect(wrapper.text()).not.toContain('15 ene 2024')
    })

    it('should show dates when showDates is true', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          showDates: true,
        },
      })
      expect(wrapper.text()).toContain('15 ene 2024')
    })

    it('should format dates correctly', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          showDates: true,
        },
      })
      expect(wrapper.text()).toContain('01 feb 2024')
    })

    it('should not show date when step has no date', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          showDates: true,
        },
      })
      const dates = wrapper.findAll('.impulsa-project-steps__date')
      expect(dates).toHaveLength(2) // Only first two steps have dates
    })
  })

  describe('clickable steps', () => {
    it('should not be clickable by default', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const firstStep = wrapper.findAll('.impulsa-project-steps__step')[0]
      expect(firstStep.attributes('style')).toContain('cursor: default')
    })

    it('should be clickable when clickable is true', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          clickable: true,
        },
      })
      const firstStep = wrapper.findAll('.impulsa-project-steps__step')[0]
      expect(firstStep.attributes('style')).toContain('cursor: pointer')
    })

    it('should emit step-click event', async () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          clickable: true,
        },
      })
      const firstStep = wrapper.findAll('.impulsa-project-steps__step')[0]

      await firstStep.trigger('click')

      expect(wrapper.emitted('step-click')).toBeTruthy()
      expect(wrapper.emitted('step-click')?.[0][0]).toEqual(mockSteps[0])
    })

    it('should not emit event when not clickable', async () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          clickable: false,
        },
      })
      const firstStep = wrapper.findAll('.impulsa-project-steps__step')[0]

      await firstStep.trigger('click')

      expect(wrapper.emitted('step-click')).toBeFalsy()
    })
  })

  describe('compact mode', () => {
    it('should apply compact class', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          compact: true,
        },
      })
      expect(wrapper.classes()).toContain('impulsa-project-steps--compact')
    })

    it('should use smaller circles in compact mode', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          compact: true,
        },
      })
      const circle = wrapper.find('.impulsa-project-steps__circle')
      expect(circle.exists()).toBe(true)
    })
  })

  describe('connectors', () => {
    it('should show active connector for completed steps', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const connectors = wrapper.findAll('.impulsa-project-steps__connector')
      const firstConnector = connectors[0] // After first completed step
      expect(firstConnector.classes()).toContain('impulsa-project-steps__connector--active')
    })

    it('should show inactive connector for pending steps', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const connectors = wrapper.findAll('.impulsa-project-steps__connector')
      const lastConnector = connectors[2] // After current step
      expect(lastConnector.classes()).not.toContain('impulsa-project-steps__connector--active')
    })

    it('should not render connector after last step', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const items = wrapper.findAll('.impulsa-project-steps__item')
      const lastItem = items[items.length - 1]
      expect(lastItem.findAll('.impulsa-project-steps__connector')).toHaveLength(0)
    })
  })

  describe('edge cases', () => {
    it('should handle single step', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: [mockSteps[0]],
        },
      })
      const steps = wrapper.findAll('.impulsa-project-steps__step')
      expect(steps).toHaveLength(1)
      expect(wrapper.findAll('.impulsa-project-steps__connector')).toHaveLength(0)
    })

    it('should handle all completed steps', () => {
      const allCompleted = mockSteps.map(s => ({ ...s, status: 'completed' as const }))
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: allCompleted,
        },
      })
      const steps = wrapper.findAll('.impulsa-project-steps__step')
      steps.forEach(step => {
        expect(step.classes()).toContain('impulsa-project-steps__step--completed')
      })
    })

    it('should handle all pending steps', () => {
      const allPending = mockSteps.map(s => ({ ...s, status: 'pending' as const }))
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: allPending,
        },
      })
      const steps = wrapper.findAll('.impulsa-project-steps__step')
      steps.forEach(step => {
        expect(step.classes()).toContain('impulsa-project-steps__step--pending')
      })
    })

    it('should handle steps without descriptions', () => {
      const stepsWithoutDescriptions = mockSteps.map(s => ({ ...s, description: undefined }))
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: stepsWithoutDescriptions,
        },
      })
      expect(wrapper.findAll('.impulsa-project-steps__description')).toHaveLength(0)
    })

    it('should handle steps without custom icons', () => {
      const stepsWithoutIcons = mockSteps.map(s => ({ ...s, icon: undefined }))
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: stepsWithoutIcons,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBe(4) // Should still render default icons
    })

    it('should handle empty steps array', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: [],
        },
      })
      expect(wrapper.findAll('.impulsa-project-steps__step')).toHaveLength(0)
    })
  })

  describe('current step', () => {
    it('should highlight current step by ID', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          currentStep: '3',
        },
      })
      const steps = wrapper.findAll('.impulsa-project-steps__step')
      expect(steps[2].classes()).toContain('impulsa-project-steps__step--current')
    })
  })

  describe('visual indicators', () => {
    it('should show circle indicator for each step', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const circles = wrapper.findAll('.impulsa-project-steps__circle')
      expect(circles).toHaveLength(4)
    })

    it('should show indicator with proper styling', () => {
      const wrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
        },
      })
      const indicator = wrapper.find('.impulsa-project-steps__indicator')
      expect(indicator.exists()).toBe(true)
    })
  })

  describe('responsive behavior', () => {
    it('should maintain structure for different orientations', () => {
      const horizontalWrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          orientation: 'horizontal',
        },
      })

      const verticalWrapper = mount(ImpulsaProjectSteps, {
        props: {
          steps: mockSteps,
          orientation: 'vertical',
        },
      })

      expect(horizontalWrapper.findAll('.impulsa-project-steps__step')).toHaveLength(4)
      expect(verticalWrapper.findAll('.impulsa-project-steps__step')).toHaveLength(4)
    })
  })
})
