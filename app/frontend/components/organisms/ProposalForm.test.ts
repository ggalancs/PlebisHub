import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ProposalForm from './ProposalForm.vue'

describe('ProposalForm', () => {
  describe('rendering', () => {
    it('should render form fields', () => {
      const wrapper = mount(ProposalForm)

      expect(wrapper.find('input').exists()).toBe(true)
      expect(wrapper.find('textarea').exists()).toBe(true)
    })

    it('should render submit button', () => {
      const wrapper = mount(ProposalForm)

      const buttons = wrapper.findAll('button')
      const submitButton = buttons.find((b) => b.text().includes('Crear propuesta'))
      expect(submitButton).toBeTruthy()
    })

    it('should render cancel button', () => {
      const wrapper = mount(ProposalForm)

      const buttons = wrapper.findAll('button')
      const cancelButton = buttons.find((b) => b.text().includes('Cancelar'))
      expect(cancelButton).toBeTruthy()
    })

    it('should render guidelines section', () => {
      const wrapper = mount(ProposalForm)

      expect(wrapper.text()).toContain('Guía para una buena propuesta')
    })

    it('should render form stats', () => {
      const wrapper = mount(ProposalForm)

      expect(wrapper.text()).toContain('Estado del formulario')
    })
  })

  describe('mode: create', () => {
    it('should show create labels by default', () => {
      const wrapper = mount(ProposalForm, {
        props: { mode: 'create' },
      })

      expect(wrapper.text()).toContain('Título de la propuesta')
      expect(wrapper.text()).toContain('Descripción de la propuesta')
    })

    it('should show "Crear propuesta" button text', () => {
      const wrapper = mount(ProposalForm, {
        props: { mode: 'create' },
      })

      expect(wrapper.text()).toContain('Crear propuesta')
    })

    it('should have empty initial values', () => {
      const wrapper = mount(ProposalForm, {
        props: { mode: 'create' },
      })

      const input = wrapper.find('input')
      const textarea = wrapper.find('textarea')

      expect(input.element.value).toBe('')
      expect(textarea.element.value).toBe('')
    })
  })

  describe('mode: edit', () => {
    it('should show edit labels', () => {
      const wrapper = mount(ProposalForm, {
        props: {
          mode: 'edit',
          initialValues: {
            title: 'Test Title',
            description: 'Test Description',
          },
        },
      })

      expect(wrapper.text()).toContain('Editar título')
      expect(wrapper.text()).toContain('Editar descripción')
    })

    it('should show "Guardar cambios" button text', () => {
      const wrapper = mount(ProposalForm, {
        props: { mode: 'edit' },
      })

      expect(wrapper.text()).toContain('Guardar cambios')
    })

    it('should populate form with initial values', () => {
      const wrapper = mount(ProposalForm, {
        props: {
          mode: 'edit',
          initialValues: {
            title: 'Initial Title',
            description: 'Initial Description',
          },
        },
      })

      const input = wrapper.find('input')
      const textarea = wrapper.find('textarea')

      expect(input.element.value).toBe('Initial Title')
      expect(textarea.element.value).toBe('Initial Description')
    })

    it('should update when initialValues change', async () => {
      const wrapper = mount(ProposalForm, {
        props: {
          mode: 'edit',
          initialValues: {
            title: 'Original Title',
            description: 'Original Description',
          },
        },
      })

      await wrapper.setProps({
        initialValues: {
          title: 'Updated Title',
          description: 'Updated Description',
        },
      })
      await nextTick()

      const input = wrapper.find('input')
      const textarea = wrapper.find('textarea')

      expect(input.element.value).toBe('Updated Title')
      expect(textarea.element.value).toBe('Updated Description')
    })
  })

  describe('validation', () => {
    it('should validate required title', async () => {
      const wrapper = mount(ProposalForm)

      const input = wrapper.find('input')
      await input.trigger('focus')
      await input.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('El título es obligatorio')
    })

    it('should validate required description', async () => {
      const wrapper = mount(ProposalForm)

      const textarea = wrapper.find('textarea')
      await textarea.trigger('focus')
      await textarea.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción es obligatoria')
    })

    it('should validate minimum title length', async () => {
      const wrapper = mount(ProposalForm, {
        props: { minTitleLength: 10 },
      })

      const input = wrapper.find('input')
      await input.setValue('Short')
      await input.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('El título debe tener al menos 10 caracteres')
    })

    it('should validate maximum title length', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxTitleLength: 20 },
      })

      const input = wrapper.find('input')
      await input.setValue('This is a very long title that exceeds the limit')
      await input.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('El título no puede exceder 20 caracteres')
    })

    it('should validate minimum description length', async () => {
      const wrapper = mount(ProposalForm, {
        props: { minDescriptionLength: 50 },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('Short description')
      await textarea.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción debe tener al menos 50 caracteres')
    })

    it('should validate maximum description length', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxDescriptionLength: 100 },
      })

      const longText = 'a'.repeat(150)
      const textarea = wrapper.find('textarea')
      await textarea.setValue(longText)
      await textarea.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción no puede exceder 100 caracteres')
    })

    it('should accept valid input', async () => {
      const wrapper = mount(ProposalForm)

      const input = wrapper.find('input')
      const textarea = wrapper.find('textarea')

      await input.setValue('Valid Title with enough characters')
      await textarea.setValue('This is a valid description with more than fifty characters to meet the minimum requirement.')

      await input.trigger('blur')
      await textarea.trigger('blur')
      await nextTick()

      expect(wrapper.text()).not.toContain('obligatorio')
      expect(wrapper.text()).not.toContain('debe tener')
    })

    it('should disable submit button when form is invalid', async () => {
      const wrapper = mount(ProposalForm)

      const buttons = wrapper.findAll('button')
      const submitButton = buttons.find((b) => b.text().includes('Crear'))

      expect(submitButton?.attributes('disabled')).toBeDefined()
    })

    it('should enable submit button when form is valid', async () => {
      const wrapper = mount(ProposalForm)

      const input = wrapper.find('input')
      const textarea = wrapper.find('textarea')

      await input.setValue('Valid Title with enough characters')
      await textarea.setValue('This is a valid description with more than fifty characters to meet the minimum requirement.')
      await nextTick()

      const buttons = wrapper.findAll('button')
      const submitButton = buttons.find((b) => b.text().includes('Crear'))

      expect(submitButton?.attributes('disabled')).toBeUndefined()
    })
  })

  describe('character counters', () => {
    it('should display title character count', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxTitleLength: 150 },
      })

      expect(wrapper.text()).toContain('0 / 150')

      const input = wrapper.find('input')
      await input.setValue('Test')
      await nextTick()

      expect(wrapper.text()).toContain('4 / 150')
    })

    it('should display description character count', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxDescriptionLength: 2000 },
      })

      expect(wrapper.text()).toContain('0 / 2000')

      const textarea = wrapper.find('textarea')
      await textarea.setValue('Test description')
      await nextTick()

      expect(wrapper.text()).toContain('16 / 2000')
    })

    it('should show warning color when title is near limit', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxTitleLength: 50 },
      })

      const input = wrapper.find('input')
      await input.setValue('This title is very close to the maximum limit')
      await nextTick()

      const counterElement = wrapper.find('.text-warning, .text-error')
      expect(counterElement.exists()).toBe(true)
    })

    it('should show warning color when description is near limit', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxDescriptionLength: 100 },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('a'.repeat(95))
      await nextTick()

      const counterElement = wrapper.find('.text-warning, .text-error')
      expect(counterElement.exists()).toBe(true)
    })
  })

  describe('form stats', () => {
    it('should show 0/2 fields completed initially', () => {
      const wrapper = mount(ProposalForm)

      expect(wrapper.text()).toContain('0/2')
    })

    it('should show "Incompleto" status initially', () => {
      const wrapper = mount(ProposalForm)

      expect(wrapper.text()).toContain('Incompleto')
    })

    it('should show 2/2 fields completed when valid', async () => {
      const wrapper = mount(ProposalForm)

      const input = wrapper.find('input')
      const textarea = wrapper.find('textarea')

      await input.setValue('Valid Title with enough characters')
      await textarea.setValue('This is a valid description with more than fifty characters to meet the minimum requirement.')
      await nextTick()

      expect(wrapper.text()).toContain('2/2')
    })

    it('should show "Listo" status when valid', async () => {
      const wrapper = mount(ProposalForm)

      const input = wrapper.find('input')
      const textarea = wrapper.find('textarea')

      await input.setValue('Valid Title with enough characters')
      await textarea.setValue('This is a valid description with more than fifty characters to meet the minimum requirement.')
      await nextTick()

      expect(wrapper.text()).toContain('Listo')
    })
  })

  describe('loading state', () => {
    it('should show loading text on submit button', () => {
      const wrapper = mount(ProposalForm, {
        props: {
          mode: 'create',
          loading: true,
        },
      })

      expect(wrapper.text()).toContain('Creando...')
    })

    it('should show "Guardando..." in edit mode', () => {
      const wrapper = mount(ProposalForm, {
        props: {
          mode: 'edit',
          loading: true,
        },
      })

      expect(wrapper.text()).toContain('Guardando...')
    })

    it('should disable submit button when loading', () => {
      const wrapper = mount(ProposalForm, {
        props: { loading: true },
      })

      const buttons = wrapper.findAll('button')
      const submitButton = buttons.find((b) => b.text().includes('...'))

      expect(submitButton?.attributes('disabled')).toBeDefined()
    })

    it('should disable cancel button when loading', () => {
      const wrapper = mount(ProposalForm, {
        props: { loading: true },
      })

      const buttons = wrapper.findAll('button')
      const cancelButton = buttons.find((b) => b.text().includes('Cancelar'))

      expect(cancelButton?.attributes('disabled')).toBeDefined()
    })

    it('should disable form fields when loading', () => {
      const wrapper = mount(ProposalForm, {
        props: { loading: true },
      })

      const input = wrapper.find('input')
      const textarea = wrapper.find('textarea')

      expect(input.attributes('disabled')).toBeDefined()
      expect(textarea.attributes('disabled')).toBeDefined()
    })
  })

  describe('alerts', () => {
    it('should show success alert when provided', () => {
      const wrapper = mount(ProposalForm, {
        props: {
          success: 'Propuesta creada exitosamente',
        },
      })

      expect(wrapper.text()).toContain('Propuesta creada exitosamente')
    })

    it('should show error alert when provided', () => {
      const wrapper = mount(ProposalForm, {
        props: {
          error: 'Error al crear la propuesta',
        },
      })

      expect(wrapper.text()).toContain('Error al crear la propuesta')
    })

    it('should not show alerts by default', () => {
      const wrapper = mount(ProposalForm)

      expect(wrapper.findComponent({ name: 'Alert' }).exists()).toBe(false)
    })
  })

  describe('events', () => {
    it('should emit submit event with form data', async () => {
      const wrapper = mount(ProposalForm)

      const input = wrapper.find('input')
      const textarea = wrapper.find('textarea')

      await input.setValue('Valid Title with enough characters')
      await textarea.setValue('This is a valid description with more than fifty characters to meet the minimum requirement.')
      await nextTick()

      await wrapper.find('form').trigger('submit')
      await nextTick()

      expect(wrapper.emitted('submit')).toBeTruthy()
      expect(wrapper.emitted('submit')?.[0]).toEqual([
        {
          title: 'Valid Title with enough characters',
          description: 'This is a valid description with more than fifty characters to meet the minimum requirement.',
        },
      ])
    })

    it('should emit cancel event when cancel button clicked', async () => {
      const wrapper = mount(ProposalForm)

      const buttons = wrapper.findAll('button')
      const cancelButton = buttons.find((b) => b.text().includes('Cancelar'))
      await cancelButton?.trigger('click')

      expect(wrapper.emitted('cancel')).toBeTruthy()
    })

    it('should not emit submit when form is invalid', async () => {
      const wrapper = mount(ProposalForm)

      await wrapper.find('form').trigger('submit')
      await nextTick()

      expect(wrapper.emitted('submit')).toBeFalsy()
    })
  })

  describe('exposed methods', () => {
    it('should expose resetForm method', () => {
      const wrapper = mount(ProposalForm)

      expect(wrapper.vm.resetForm).toBeDefined()
      expect(typeof wrapper.vm.resetForm).toBe('function')
    })

    it('should expose setFieldValue method', () => {
      const wrapper = mount(ProposalForm)

      expect(wrapper.vm.setFieldValue).toBeDefined()
      expect(typeof wrapper.vm.setFieldValue).toBe('function')
    })

    it('should expose setFieldError method', () => {
      const wrapper = mount(ProposalForm)

      expect(wrapper.vm.setFieldError).toBeDefined()
      expect(typeof wrapper.vm.setFieldError).toBe('function')
    })

    it('should reset form when resetForm is called', async () => {
      const wrapper = mount(ProposalForm, {
        props: {
          initialValues: {
            title: 'Initial Title',
            description: 'Initial Description',
          },
        },
      })

      const input = wrapper.find('input')
      await input.setValue('Changed Title')
      await nextTick()

      wrapper.vm.resetForm()
      await nextTick()

      expect(input.element.value).toBe('Initial Title')
    })
  })

  describe('accessibility', () => {
    it('should have required attribute on required fields', () => {
      const wrapper = mount(ProposalForm)

      // Check if FormField components have required prop
      const formFields = wrapper.findAllComponents({ name: 'FormField' })
      formFields.forEach((field) => {
        expect(field.props('required')).toBe(true)
      })
    })

    it('should associate labels with inputs', () => {
      const wrapper = mount(ProposalForm)

      const formFields = wrapper.findAllComponents({ name: 'FormField' })
      expect(formFields.length).toBeGreaterThan(0)
      formFields.forEach((field) => {
        expect(field.props('label')).toBeTruthy()
      })
    })

    it('should show error messages for invalid fields', async () => {
      const wrapper = mount(ProposalForm)

      const input = wrapper.find('input')
      await input.trigger('blur')
      await nextTick()

      const formField = wrapper.findComponent({ name: 'FormField' })
      expect(formField.props('error')).toBeTruthy()
    })
  })

  describe('custom validation lengths', () => {
    it('should use custom minTitleLength', async () => {
      const wrapper = mount(ProposalForm, {
        props: { minTitleLength: 20 },
      })

      const input = wrapper.find('input')
      await input.setValue('Short title')
      await input.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('El título debe tener al menos 20 caracteres')
    })

    it('should use custom maxTitleLength', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxTitleLength: 30 },
      })

      const input = wrapper.find('input')
      await input.setValue('This is a very long title that definitely exceeds limit')
      await input.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('El título no puede exceder 30 caracteres')
    })

    it('should use custom minDescriptionLength', async () => {
      const wrapper = mount(ProposalForm, {
        props: { minDescriptionLength: 100 },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('Short description')
      await textarea.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción debe tener al menos 100 caracteres')
    })

    it('should use custom maxDescriptionLength', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxDescriptionLength: 500 },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('a'.repeat(600))
      await textarea.trigger('blur')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción no puede exceder 500 caracteres')
    })
  })
})
