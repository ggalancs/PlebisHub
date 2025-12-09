import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ImpulsaProjectForm from './ImpulsaProjectForm.vue'
import type { ImpulsaProjectFormData } from './ImpulsaProjectForm.vue'

const mockFormData: ImpulsaProjectFormData = {
  title: 'Centro Comunitario de Innovación',
  description: 'Un proyecto para crear un espacio comunitario dedicado a la innovación social y el desarrollo local.',
  category: 'social',
  fundingGoal: 50000,
  budgetBreakdown: 'Materiales: 20.000€\nPersonal: 25.000€\nOperativo: 5.000€',
  teamMembers: 'María González (Coordinadora), Juan Pérez (Desarrollador)',
  skillsNeeded: 'Diseñador gráfico, Educador social',
  startDate: '2024-03-01',
  endDate: '2024-12-31',
  milestones: 'Mes 1: Planificación\nMes 6: Implementación\nMes 12: Evaluación',
  documents: [],
}

describe('ImpulsaProjectForm', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(ImpulsaProjectForm)
      expect(wrapper.find('.impulsa-project-form').exists()).toBe(true)
    })

    it('should render progress stepper', () => {
      const wrapper = mount(ImpulsaProjectForm)
      expect(wrapper.find('.impulsa-project-form__stepper').exists()).toBe(true)
    })

    it('should render all 4 step buttons', () => {
      const wrapper = mount(ImpulsaProjectForm)
      const stepButtons = wrapper.findAll('.impulsa-project-form__step-button')
      expect(stepButtons).toHaveLength(4)
    })

    it('should render progress bar', () => {
      const wrapper = mount(ImpulsaProjectForm)
      expect(wrapper.findComponent({ name: 'ProgressBar' }).exists()).toBe(true)
    })

    it('should highlight current step', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: { currentStep: 2 },
      })
      const stepButtons = wrapper.findAll('.impulsa-project-form__step-button')
      expect(stepButtons[1].classes()).toContain('bg-primary')
    })

    it('should show step 1 by default', () => {
      const wrapper = mount(ImpulsaProjectForm)
      expect(wrapper.text()).toContain('Información Básica')
    })
  })

  describe('step 1: basic info', () => {
    it('should render title input', () => {
      const wrapper = mount(ImpulsaProjectForm)
      const input = wrapper.findComponent({ name: 'Input' })
      expect(input.exists()).toBe(true)
    })

    it('should render description textarea', () => {
      const wrapper = mount(ImpulsaProjectForm)
      const textarea = wrapper.findComponent({ name: 'Textarea' })
      expect(textarea.exists()).toBe(true)
    })

    it('should render category select', () => {
      const wrapper = mount(ImpulsaProjectForm)
      const select = wrapper.findComponent({ name: 'Select' })
      expect(select.exists()).toBe(true)
    })

    it('should show character counter for title', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          initialData: { title: 'Test Project' },
        },
      })
      expect(wrapper.text()).toContain('12/100 caracteres')
    })

    it('should show character counter for description', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          initialData: { description: 'Test description' },
        },
      })
      expect(wrapper.text()).toContain('16/2000 caracteres')
    })

    it('should validate title length', async () => {
      const wrapper = mount(ImpulsaProjectForm)
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El título debe tener al menos 10 caracteres')
    })

    it('should validate description length', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          initialData: { title: 'Valid Project Title' },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción debe tener al menos 50 caracteres')
    })

    it('should validate category selection', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          initialData: {
            title: 'Valid Project Title',
            description: 'A valid description with more than fifty characters to pass validation',
          },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Debes seleccionar una categoría')
    })
  })

  describe('step 2: funding', () => {
    it('should render funding goal input', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 2,
        },
      })
      await nextTick()
      expect(wrapper.text()).toContain('Objetivo de Financiación')
    })

    it('should render budget breakdown textarea', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 2,
        },
      })
      await nextTick()
      expect(wrapper.text()).toContain('Desglose del Presupuesto')
    })

    it('should validate funding goal is required', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 2,
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El objetivo de financiación debe ser mayor a 0')
    })

    it('should validate funding goal maximum', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 2,
          initialData: { fundingGoal: 2000000 },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El objetivo no puede exceder 1.000.000')
    })

    it('should validate budget breakdown', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 2,
          initialData: { fundingGoal: 50000 },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Debes proporcionar un desglose del presupuesto')
    })
  })

  describe('step 3: team', () => {
    it('should render team members textarea', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 3,
        },
      })
      await nextTick()
      expect(wrapper.text()).toContain('Miembros del Equipo')
    })

    it('should render skills needed textarea', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 3,
        },
      })
      await nextTick()
      expect(wrapper.text()).toContain('Habilidades Necesarias')
    })

    it('should validate team members field', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 3,
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Describe los miembros del equipo')
    })

    it('should validate skills needed field', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 3,
          initialData: { teamMembers: 'Valid team description here' },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Describe las habilidades necesarias')
    })
  })

  describe('step 4: timeline', () => {
    it('should render start date input', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
        },
      })
      await nextTick()
      expect(wrapper.text()).toContain('Fecha de Inicio')
    })

    it('should render end date input', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
        },
      })
      await nextTick()
      expect(wrapper.text()).toContain('Fecha de Finalización')
    })

    it('should render milestones textarea', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
        },
      })
      await nextTick()
      expect(wrapper.text()).toContain('Hitos del Proyecto')
    })

    it('should render document uploader', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
        },
      })
      await nextTick()
      expect(wrapper.findComponent({ name: 'MediaUploader' }).exists()).toBe(true)
    })

    it('should validate start date', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Enviar'))

      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La fecha de inicio es requerida')
    })

    it('should validate end date', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
          initialData: { startDate: '2024-01-01' },
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Enviar'))

      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La fecha de finalización es requerida')
    })

    it('should validate end date is after start date', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
          initialData: {
            startDate: '2024-12-31',
            endDate: '2024-01-01',
          },
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Enviar'))

      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La fecha de finalización debe ser posterior')
    })

    it('should validate milestones field', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
          initialData: {
            startDate: '2024-01-01',
            endDate: '2024-12-31',
          },
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Enviar'))

      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Describe los hitos del proyecto')
    })
  })

  describe('navigation', () => {
    it('should navigate to next step', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          initialData: {
            title: 'Valid Project Title',
            description: 'A valid description with more than fifty characters to pass validation',
            category: 'social',
          },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Financiación')
    })

    it('should navigate to previous step', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 2,
        },
      })
      const prevButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Anterior'))

      await prevButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Información Básica')
    })

    it('should not navigate forward with validation errors', async () => {
      const wrapper = mount(ImpulsaProjectForm)
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Información Básica')
    })

    it('should emit step-change event', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 2,
        },
      })
      const prevButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Anterior'))

      await prevButton?.trigger('click')
      await nextTick()

      expect(wrapper.emitted('step-change')).toBeTruthy()
      expect(wrapper.emitted('step-change')?.[0]).toEqual([1])
    })

    it('should not show previous button on step 1', () => {
      const wrapper = mount(ImpulsaProjectForm)
      const prevButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Anterior'))
      expect(prevButton).toBeUndefined()
    })

    it('should not show next button on step 4', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))
      expect(nextButton).toBeUndefined()
    })

    it('should show submit button on step 4', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Enviar'))
      expect(submitButton?.exists()).toBe(true)
    })

    it('should allow clicking on step buttons', async () => {
      const wrapper = mount(ImpulsaProjectForm)
      const stepButtons = wrapper.findAll('.impulsa-project-form__step-button')

      await stepButtons[2].trigger('click')
      await nextTick()

      expect(wrapper.emitted('step-change')?.[0]).toEqual([3])
    })
  })

  describe('progress bar', () => {
    it('should show 0% progress on step 1', () => {
      const wrapper = mount(ImpulsaProjectForm)
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.props('value')).toBe(0)
    })

    it('should show 33% progress on step 2', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: { currentStep: 2 },
      })
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.props('value')).toBeCloseTo(33.33, 1)
    })

    it('should show 66% progress on step 3', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: { currentStep: 3 },
      })
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.props('value')).toBeCloseTo(66.66, 1)
    })

    it('should show 100% progress on step 4', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: { currentStep: 4 },
      })
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.props('value')).toBe(100)
    })
  })

  describe('form submission', () => {
    it('should emit submit event with form data', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
          initialData: mockFormData,
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Enviar'))

      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.emitted('submit')).toBeTruthy()
      expect(wrapper.emitted('submit')?.[0][0]).toMatchObject(mockFormData)
    })

    it('should not submit with validation errors', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Enviar'))

      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.emitted('submit')).toBeFalsy()
    })

    it('should validate all steps before submitting', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
          initialData: {
            // Only step 4 data, missing step 1-3
            startDate: '2024-01-01',
            endDate: '2024-12-31',
            milestones: 'Valid milestones here',
          },
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Enviar'))

      await submitButton?.trigger('click')
      await nextTick()

      // Should navigate back to step 1 due to validation error
      expect(wrapper.text()).toContain('Información Básica')
    })
  })

  describe('save draft', () => {
    it('should show save draft button', () => {
      const wrapper = mount(ImpulsaProjectForm)
      const saveDraftButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Guardar Borrador'))
      expect(saveDraftButton?.exists()).toBe(true)
    })

    it('should emit save-draft event', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          initialData: { title: 'Draft Project' },
        },
      })
      const saveDraftButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Guardar Borrador'))

      await saveDraftButton?.trigger('click')
      await nextTick()

      expect(wrapper.emitted('save-draft')).toBeTruthy()
      expect(wrapper.emitted('save-draft')?.[0][0]).toMatchObject({ title: 'Draft Project' })
    })

    it('should not validate on save draft', async () => {
      const wrapper = mount(ImpulsaProjectForm)
      const saveDraftButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Guardar Borrador'))

      await saveDraftButton?.trigger('click')
      await nextTick()

      // Should emit even with empty data
      expect(wrapper.emitted('save-draft')).toBeTruthy()
    })
  })

  describe('cancel action', () => {
    it('should show cancel button', () => {
      const wrapper = mount(ImpulsaProjectForm)
      const cancelButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text() === 'Cancelar')
      expect(cancelButton?.exists()).toBe(true)
    })

    it('should emit cancel event', async () => {
      const wrapper = mount(ImpulsaProjectForm)
      const cancelButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text() === 'Cancelar')

      await cancelButton?.trigger('click')
      await nextTick()

      expect(wrapper.emitted('cancel')).toBeTruthy()
    })
  })

  describe('edit mode', () => {
    it('should show "Actualizar Proyecto" in edit mode', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          mode: 'edit',
          currentStep: 4,
        },
      })
      expect(wrapper.text()).toContain('Actualizar Proyecto')
    })

    it('should show "Enviar Proyecto" in create mode', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          mode: 'create',
          currentStep: 4,
        },
      })
      expect(wrapper.text()).toContain('Enviar Proyecto')
    })
  })

  describe('loading state', () => {
    it('should disable form when loading', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          loading: true,
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))
      expect(nextButton?.props('disabled')).toBe(true)
    })

    it('should show loading on submit button', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          currentStep: 4,
          loading: true,
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Proyecto'))
      expect(submitButton?.props('loading')).toBe(true)
    })
  })

  describe('disabled state', () => {
    it('should disable all inputs when disabled', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          disabled: true,
        },
      })
      const inputs = wrapper.findAllComponents({ name: 'Input' })
      inputs.forEach(input => {
        expect(input.props('disabled')).toBe(true)
      })
    })

    it('should disable step buttons when disabled', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          disabled: true,
        },
      })
      const stepButtons = wrapper.findAll('.impulsa-project-form__step-button')
      stepButtons.forEach(button => {
        expect(button.attributes('disabled')).toBeDefined()
      })
    })
  })

  describe('initial data', () => {
    it('should populate form with initial data', () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          initialData: mockFormData,
        },
      })
      const input = wrapper.findComponent({ name: 'Input' })
      expect(input.props('modelValue')).toBe(mockFormData.title)
    })

    it('should preserve data when navigating steps', async () => {
      const wrapper = mount(ImpulsaProjectForm, {
        props: {
          initialData: {
            title: 'Test Title',
            description: 'A description with more than fifty characters to pass validation rules',
            category: 'social',
          },
        },
      })

      // Navigate to step 2
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))
      await nextButton?.trigger('click')
      await nextTick()

      // Navigate back
      const prevButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Anterior'))
      await prevButton?.trigger('click')
      await nextTick()

      // Data should still be there
      const input = wrapper.findComponent({ name: 'Input' })
      expect(input.props('modelValue')).toBe('Test Title')
    })
  })

  describe('category options', () => {
    it('should show all category options', () => {
      const wrapper = mount(ImpulsaProjectForm)
      const select = wrapper.findComponent({ name: 'Select' })
      const options = select.props('options')

      expect(options).toHaveLength(7)
      expect(options).toContainEqual({ value: 'social', label: 'Social' })
      expect(options).toContainEqual({ value: 'technology', label: 'Tecnología' })
      expect(options).toContainEqual({ value: 'culture', label: 'Cultura' })
      expect(options).toContainEqual({ value: 'education', label: 'Educación' })
      expect(options).toContainEqual({ value: 'environment', label: 'Medio Ambiente' })
      expect(options).toContainEqual({ value: 'health', label: 'Salud' })
      expect(options).toContainEqual({ value: 'other', label: 'Otro' })
    })
  })
})
