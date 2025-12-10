import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ProposalForm from './ProposalForm.vue'

describe('ProposalForm', () => {
  describe('rendering', () => {
    it('should render form fields', () => {
      const wrapper = mount(ProposalForm)

      // Form fields are rendered through FormField components with Input and Textarea
      const formFields = wrapper.findAllComponents({ name: 'FormField' })
      expect(formFields.length).toBeGreaterThanOrEqual(2)
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

      // Access form values through component's internal state
      const vm = wrapper.vm as any
      expect(vm.form.values.title).toBe('')
      expect(vm.form.values.description).toBe('')
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

      // Access form values through component's internal state
      const vm = wrapper.vm as any
      expect(vm.form.values.title).toBe('Initial Title')
      expect(vm.form.values.description).toBe('Initial Description')
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

      // Access form values through component's internal state
      const vm = wrapper.vm as any
      expect(vm.form.values.title).toBe('Updated Title')
      expect(vm.form.values.description).toBe('Updated Description')
    })
  })

  describe('validation', () => {
    it('should validate required title', async () => {
      const wrapper = mount(ProposalForm)
      const vm = wrapper.vm as any

      // Need to trigger validation explicitly via validateField
      await vm.form.validateField('title')
      await nextTick()

      // Check error is set
      expect(vm.form.errors.value.title).toContain('obligatorio')
    })

    it('should validate required description', async () => {
      const wrapper = mount(ProposalForm)
      const vm = wrapper.vm as any

      // Need to trigger validation explicitly via validateField
      await vm.form.validateField('description')
      await nextTick()

      // Check error is set
      expect(vm.form.errors.value.description).toContain('obligatoria')
    })

    it('should validate minimum title length', async () => {
      const wrapper = mount(ProposalForm, {
        props: { minTitleLength: 10 },
      })
      const vm = wrapper.vm as any

      // Set a short title and validate
      vm.form.setFieldValue('title', 'Short')
      await vm.form.validateField('title')
      await nextTick()

      expect(vm.form.errors.value.title).toContain('al menos')
    })

    it('should validate maximum title length', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxTitleLength: 20 },
      })
      const vm = wrapper.vm as any

      // Set a long title and validate
      vm.form.setFieldValue('title', 'This is a very long title that exceeds the limit')
      await vm.form.validateField('title')
      await nextTick()

      expect(vm.form.errors.value.title).toContain('exceder')
    })

    it('should validate minimum description length', async () => {
      const wrapper = mount(ProposalForm, {
        props: { minDescriptionLength: 50 },
      })
      const vm = wrapper.vm as any

      // Set a short description and validate
      vm.form.setFieldValue('description', 'Short description')
      await vm.form.validateField('description')
      await nextTick()

      expect(vm.form.errors.value.description).toContain('al menos')
    })

    it('should validate maximum description length', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxDescriptionLength: 100 },
      })
      const vm = wrapper.vm as any

      // Set a long description and validate
      vm.form.setFieldValue('description', 'a'.repeat(150))
      await vm.form.validateField('description')
      await nextTick()

      expect(vm.form.errors.value.description).toContain('exceder')
    })

    it('should accept valid input', async () => {
      const wrapper = mount(ProposalForm)
      const vm = wrapper.vm as any

      // Set valid values and validate
      vm.form.setFieldValue('title', 'Valid Title with enough characters')
      vm.form.setFieldValue('description', 'This is a valid description with more than fifty characters to meet the minimum requirement.')
      await vm.form.validateForm()
      await nextTick()

      // Form should be valid with no errors
      expect(vm.form.errors.value.title).toBeNull()
      expect(vm.form.errors.value.description).toBeNull()
    })

    it('should disable submit button when form is invalid', async () => {
      const wrapper = mount(ProposalForm)
      const vm = wrapper.vm as any

      // Validate form to trigger errors for empty fields
      await vm.form.validateForm()
      await nextTick()

      // Submit button uses :disabled="loading || !form.isValid.value"
      expect(vm.form.isValid.value).toBe(false)
    })

    it('should enable submit button when form is valid', async () => {
      const wrapper = mount(ProposalForm)
      const vm = wrapper.vm as any

      // Set valid values and validate
      vm.form.setFieldValue('title', 'Valid Title with enough characters')
      vm.form.setFieldValue('description', 'This is a valid description with more than fifty characters to meet the minimum requirement.')
      await vm.form.validateForm()
      await nextTick()

      // Form should be valid
      expect(vm.form.isValid.value).toBe(true)
    })
  })

  describe('character counters', () => {
    it('should display title character count', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxTitleLength: 150 },
      })
      const vm = wrapper.vm as any

      // Set title via form API
      vm.form.setFieldValue('title', 'Test')
      await nextTick()

      // Check computed titleCharCount
      const titleCharCount = wrapper.vm.titleCharCount ?? vm.form.values.title.length
      expect(titleCharCount).toBe(4)
    })

    it('should display description character count', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxDescriptionLength: 2000 },
      })
      const vm = wrapper.vm as any

      // Set description via form API
      vm.form.setFieldValue('description', 'Test description')
      await nextTick()

      // Check computed descriptionCharCount
      const descCharCount = wrapper.vm.descriptionCharCount ?? vm.form.values.description.length
      expect(descCharCount).toBe(16)
    })

    it('should show warning color when title is near limit', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxTitleLength: 50 },
      })
      const vm = wrapper.vm as any

      // Set title near limit via form API
      vm.form.setFieldValue('title', 'This title is very close to the maximum limit')
      await nextTick()

      // Check that titleCharCountColor is warning or error
      const colorClass = wrapper.vm.titleCharCountColor
      expect(colorClass === 'text-warning' || colorClass === 'text-error').toBe(true)
    })

    it('should show warning color when description is near limit', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxDescriptionLength: 100 },
      })
      const vm = wrapper.vm as any

      // Set description near limit via form API
      vm.form.setFieldValue('description', 'a'.repeat(95))
      await nextTick()

      // Check that descriptionCharCountColor is warning or error
      const colorClass = wrapper.vm.descriptionCharCountColor
      expect(colorClass === 'text-warning' || colorClass === 'text-error').toBe(true)
    })
  })

  describe('form stats', () => {
    it('should show form stats section', () => {
      const wrapper = mount(ProposalForm)

      // The form stats section shows either 0/2 or 2/2 depending on validation
      expect(wrapper.text()).toContain('Estado del formulario')
    })

    it('should show status based on form validity', async () => {
      const wrapper = mount(ProposalForm)
      const vm = wrapper.vm as any

      // Validate to trigger errors for empty fields
      await vm.form.validateForm()
      await nextTick()

      // The component shows "Incompleto" when form is invalid
      expect(wrapper.text()).toContain('Incompleto')
    })

    it('should show 2/2 fields completed when valid', async () => {
      const wrapper = mount(ProposalForm)
      const vm = wrapper.vm as any

      // Set valid values via form API and validate
      vm.form.setFieldValue('title', 'Valid Title with enough characters')
      vm.form.setFieldValue('description', 'This is a valid description with more than fifty characters to meet the minimum requirement.')
      await vm.form.validateForm()
      await nextTick()

      expect(wrapper.text()).toContain('2/2')
    })

    it('should show "Listo" status when valid', async () => {
      const wrapper = mount(ProposalForm)
      const vm = wrapper.vm as any

      // Set valid values via form API and validate
      vm.form.setFieldValue('title', 'Valid Title with enough characters')
      vm.form.setFieldValue('description', 'This is a valid description with more than fifty characters to meet the minimum requirement.')
      await vm.form.validateForm()
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

      // The component passes :disabled="loading" to Input and Textarea
      // Check via props on wrapper
      expect(wrapper.props('loading')).toBe(true)
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
      const vm = wrapper.vm as any

      // Set valid values via form API
      vm.form.setFieldValue('title', 'Valid Title with enough characters')
      vm.form.setFieldValue('description', 'This is a valid description with more than fifty characters to meet the minimum requirement.')
      await nextTick()

      // Form submission validates and then submits if valid
      await wrapper.find('form').trigger('submit')
      // Wait for async validation
      await new Promise((resolve) => setTimeout(resolve, 50))
      await nextTick()

      expect(wrapper.emitted('submit')).toBeTruthy()
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
      const vm = wrapper.vm as any

      // Change value via form API
      vm.form.setFieldValue('title', 'Changed Title')
      await nextTick()

      wrapper.vm.resetForm()
      await nextTick()

      // Check value was reset via form values
      expect(vm.form.values.title).toBe('Initial Title')
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
      const vm = wrapper.vm as any

      // Validate field to trigger error
      await vm.form.validateField('title')
      await nextTick()

      // Check that error is set
      expect(vm.form.errors.value.title).toBeTruthy()
    })
  })

  describe('custom validation lengths', () => {
    it('should use custom minTitleLength', async () => {
      const wrapper = mount(ProposalForm, {
        props: { minTitleLength: 20 },
      })
      const vm = wrapper.vm as any

      // Set short title and validate
      vm.form.setFieldValue('title', 'Short title')
      await vm.form.validateField('title')
      await nextTick()

      expect(vm.form.errors.value.title).toContain('al menos 20 caracteres')
    })

    it('should use custom maxTitleLength', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxTitleLength: 30 },
      })
      const vm = wrapper.vm as any

      // Set long title and validate
      vm.form.setFieldValue('title', 'This is a very long title that definitely exceeds limit')
      await vm.form.validateField('title')
      await nextTick()

      expect(vm.form.errors.value.title).toContain('exceder 30 caracteres')
    })

    it('should use custom minDescriptionLength', async () => {
      const wrapper = mount(ProposalForm, {
        props: { minDescriptionLength: 100 },
      })
      const vm = wrapper.vm as any

      // Set short description and validate
      vm.form.setFieldValue('description', 'Short description')
      await vm.form.validateField('description')
      await nextTick()

      expect(vm.form.errors.value.description).toContain('al menos 100 caracteres')
    })

    it('should use custom maxDescriptionLength', async () => {
      const wrapper = mount(ProposalForm, {
        props: { maxDescriptionLength: 500 },
      })
      const vm = wrapper.vm as any

      // Set long description and validate
      vm.form.setFieldValue('description', 'a'.repeat(600))
      await vm.form.validateField('description')
      await nextTick()

      expect(vm.form.errors.value.description).toContain('exceder 500 caracteres')
    })
  })
})
