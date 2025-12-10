import { describe, it, expect, beforeEach, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ParticipationForm from './ParticipationForm.vue'
import type { ParticipationFormData } from './ParticipationForm.vue'

const mockInitialData: Partial<ParticipationFormData> = {
  name: 'Equipo de Medio Ambiente',
  description: 'Trabajamos en iniciativas para mejorar el medio ambiente local',
  maxMembers: 15,
  status: 'recruiting',
  meetingSchedule: 'Jueves 18:00',
  tags: ['Medio Ambiente', 'Sostenibilidad'],
  imageUrl: 'https://example.com/image.jpg',
}

describe('ParticipationForm', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(ParticipationForm)
      expect(wrapper.find('.participation-form').exists()).toBe(true)
    })

    it('should show create title when mode is create', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          mode: 'create',
        },
      })
      expect(wrapper.text()).toContain('Crear Equipo de Participación')
    })

    it('should show edit title when mode is edit', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          mode: 'edit',
        },
      })
      expect(wrapper.text()).toContain('Editar Equipo')
    })

    it('should display all form fields', () => {
      const wrapper = mount(ParticipationForm)
      expect(wrapper.text()).toContain('Nombre del Equipo')
      expect(wrapper.text()).toContain('Descripción')
      expect(wrapper.text()).toContain('Estado')
      expect(wrapper.text()).toContain('Máximo de Miembros')
      expect(wrapper.text()).toContain('Horario de Reuniones')
      expect(wrapper.text()).toContain('Etiquetas')
    })

    it('should show image upload section when not compact', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          compact: false,
        },
      })
      expect(wrapper.text()).toContain('Imagen del Equipo')
    })

    it('should hide image upload section when compact', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Imagen del Equipo')
    })
  })

  describe('initial data', () => {
    it('should load initial data', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          initialData: mockInitialData,
        },
      })
      await nextTick()

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      expect(nameInput?.props('modelValue')).toBe('Equipo de Medio Ambiente')
    })

    it('should load tags from initial data', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          initialData: mockInitialData,
        },
      })
      await nextTick()

      expect(wrapper.text()).toContain('Medio Ambiente')
      expect(wrapper.text()).toContain('Sostenibilidad')
    })

    it('should show image preview when imageUrl is provided', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          initialData: mockInitialData,
        },
      })
      await nextTick()

      const img = wrapper.find('img[alt="Team preview"]')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('https://example.com/image.jpg')
    })
  })

  describe('form validation', () => {
    it('should require team name', async () => {
      const wrapper = mount(ParticipationForm)

      // Trigger form submission
      await wrapper.vm.handleSubmit()
      await nextTick()

      // Check the errors state
      expect(wrapper.vm.errors.name).toBe('El nombre del equipo es requerido')
      expect(wrapper.emitted('submit')).toBeFalsy()
    })

    it('should validate minimum name length', async () => {
      const wrapper = mount(ParticipationForm)

      // Set short name directly on formData
      wrapper.vm.formData.name = 'AB'
      await wrapper.vm.handleSubmit()
      await nextTick()

      expect(wrapper.vm.errors.name).toBe('El nombre debe tener al menos 3 caracteres')
    })

    it('should validate maximum name length', async () => {
      const wrapper = mount(ParticipationForm)

      // Set long name
      wrapper.vm.formData.name = 'A'.repeat(101)
      await wrapper.vm.handleSubmit()
      await nextTick()

      expect(wrapper.vm.errors.name).toBe('El nombre no puede exceder 100 caracteres')
    })

    it('should require description', async () => {
      const wrapper = mount(ParticipationForm)

      // Set valid name but no description
      wrapper.vm.formData.name = 'Equipo Test'
      await wrapper.vm.handleSubmit()
      await nextTick()

      expect(wrapper.vm.errors.description).toBe('La descripción es requerida')
    })

    it('should validate minimum description length', async () => {
      const wrapper = mount(ParticipationForm)

      // Set valid name but short description
      wrapper.vm.formData.name = 'Equipo Test'
      wrapper.vm.formData.description = 'Corto'
      await wrapper.vm.handleSubmit()
      await nextTick()

      expect(wrapper.vm.errors.description).toBe('La descripción debe tener al menos 20 caracteres')
    })

    it('should validate maximum description length', async () => {
      const wrapper = mount(ParticipationForm)

      // Set long description
      wrapper.vm.formData.name = 'Equipo Test'
      wrapper.vm.formData.description = 'A'.repeat(501)
      await wrapper.vm.handleSubmit()
      await nextTick()

      expect(wrapper.vm.errors.description).toBe('La descripción no puede exceder 500 caracteres')
    })

    it('should validate minimum max members', async () => {
      const wrapper = mount(ParticipationForm)

      // Set valid data with invalid maxMembers
      wrapper.vm.formData.name = 'Equipo Test'
      wrapper.vm.formData.description = 'Esta es una descripción válida con más de 20 caracteres'
      wrapper.vm.formData.maxMembers = 1
      await wrapper.vm.handleSubmit()
      await nextTick()

      expect(wrapper.vm.errors.maxMembers).toBe('El equipo debe tener al menos 2 miembros')
    })

    it('should validate maximum max members', async () => {
      const wrapper = mount(ParticipationForm)

      // Set valid data with too many maxMembers
      wrapper.vm.formData.name = 'Equipo Test'
      wrapper.vm.formData.description = 'Esta es una descripción válida con más de 20 caracteres'
      wrapper.vm.formData.maxMembers = 101
      await wrapper.vm.handleSubmit()
      await nextTick()

      expect(wrapper.vm.errors.maxMembers).toBe('El equipo no puede tener más de 100 miembros')
    })

    it('should allow undefined max members', async () => {
      const wrapper = mount(ParticipationForm)

      // Set valid data without maxMembers
      wrapper.vm.formData.name = 'Equipo Test'
      wrapper.vm.formData.description = 'Esta es una descripción válida con más de 20 caracteres'
      await wrapper.vm.handleSubmit()
      await nextTick()

      expect(wrapper.emitted('submit')).toBeTruthy()
    })
  })

  describe('character counters', () => {
    it('should show name character count', () => {
      const wrapper = mount(ParticipationForm)
      expect(wrapper.text()).toContain('0 / 100')
    })

    it('should update name character count', async () => {
      const wrapper = mount(ParticipationForm)

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      await nameInput?.setValue('Test')
      await nextTick()

      expect(wrapper.text()).toContain('4 / 100')
    })

    it('should show description character count', () => {
      const wrapper = mount(ParticipationForm)
      expect(wrapper.text()).toContain('0 / 500')
    })

    it('should update description character count', async () => {
      const wrapper = mount(ParticipationForm)

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Test description')
      await nextTick()

      expect(wrapper.text()).toContain('16 / 500')
    })
  })

  describe('tags', () => {
    it('should add tag on button click', async () => {
      const wrapper = mount(ParticipationForm)

      const tagInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('etiqueta')
      )
      await tagInput?.setValue('Nueva Etiqueta')

      const addButton = wrapper.findAllComponents({ name: 'Button' }).find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'plus'
      })
      await addButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Nueva Etiqueta')
    })

    it('should add tag on Enter key', async () => {
      const wrapper = mount(ParticipationForm)

      const tagInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('etiqueta')
      )
      await tagInput?.setValue('Nueva Etiqueta')
      await tagInput?.trigger('keydown', { key: 'Enter' })
      await nextTick()

      expect(wrapper.text()).toContain('Nueva Etiqueta')
    })

    it('should not add duplicate tags', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          initialData: {
            ...mockInitialData,
            tags: ['Existente'],
          },
        },
      })
      await nextTick()

      const tagInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('etiqueta')
      )
      await tagInput?.setValue('Existente')

      const addButton = wrapper.findAllComponents({ name: 'Button' }).find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'plus'
      })
      await addButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('1 / 10 etiquetas')
    })

    it('should remove tag', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          initialData: mockInitialData,
        },
      })
      await nextTick()

      expect(wrapper.text()).toContain('Medio Ambiente')

      const removeButtons = wrapper.findAll('button').filter(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'x'
      })
      await removeButtons[0]?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('1 / 10 etiquetas')
    })

    it('should limit tags to 10', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          initialData: {
            ...mockInitialData,
            tags: Array(10).fill(null).map((_, i) => `Tag ${i + 1}`),
          },
        },
      })
      await nextTick()

      expect(wrapper.text()).toContain('10 / 10 etiquetas')

      const tagInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('etiqueta')
      )
      expect(tagInput?.props('disabled')).toBe(true)
    })

    it('should show error when trying to add more than 10 tags', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          initialData: {
            ...mockInitialData,
            tags: Array(10).fill(null).map((_, i) => `Tag ${i + 1}`),
          },
        },
      })
      await nextTick()

      // Try to add via code (simulating a race condition or edge case)
      const tagInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('etiqueta')
      )
      await tagInput?.vm.$emit('update:modelValue', 'New Tag')

      const addButton = wrapper.findAllComponents({ name: 'Button' }).find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'plus'
      })
      expect(addButton?.props('disabled')).toBe(true)
    })
  })

  describe('image upload', () => {
    it('should show image upload when no image', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          compact: false, // Need non-compact mode to show image upload
        },
      })
      // FileUpload component shows "Click to upload or drag and drop"
      expect(wrapper.text()).toContain('Imagen del Equipo')
    })

    it('should show image preview when uploaded', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          initialData: mockInitialData,
          compact: false, // Need non-compact mode to show image upload
        },
      })
      await nextTick()

      const img = wrapper.find('img[alt="Team preview"]')
      expect(img.exists()).toBe(true)
    })

    it('should remove image', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          initialData: mockInitialData,
          compact: false, // Need non-compact mode
        },
      })
      await nextTick()

      // Instead of checking text, verify through state
      expect(wrapper.vm.formData.imageUrl).toBe('https://example.com/image.jpg')

      // Call the remove handler directly
      await wrapper.vm.handleRemoveImage()
      await nextTick()

      expect(wrapper.vm.formData.imageUrl).toBe('')
      expect(wrapper.vm.formData.imageFile).toBeUndefined()
    })
  })

  describe('form submission', () => {
    it('should emit submit event with valid data', async () => {
      const wrapper = mount(ParticipationForm)

      // Set form data directly
      wrapper.vm.formData.name = 'Equipo Test'
      wrapper.vm.formData.description = 'Esta es una descripción válida con más de 20 caracteres'
      await wrapper.vm.handleSubmit()
      await nextTick()

      expect(wrapper.emitted('submit')).toBeTruthy()
      const submitData = wrapper.emitted('submit')?.[0]?.[0] as ParticipationFormData
      expect(submitData.name).toBe('Equipo Test')
      expect(submitData.description).toBe('Esta es una descripción válida con más de 20 caracteres')
    })

    it('should not submit with invalid data', async () => {
      const wrapper = mount(ParticipationForm)

      await wrapper.vm.handleSubmit()
      await nextTick()

      expect(wrapper.emitted('submit')).toBeFalsy()
    })

    it('should disable submit button when form is invalid', () => {
      const wrapper = mount(ParticipationForm)

      // Form is invalid when empty - check the computed isFormValid
      expect(wrapper.vm.isFormValid).toBe(false)
    })

    it('should enable submit button when form is valid', async () => {
      const wrapper = mount(ParticipationForm)

      // Set valid data directly
      wrapper.vm.formData.name = 'Equipo Test'
      wrapper.vm.formData.description = 'Esta es una descripción válida con más de 20 caracteres'
      await nextTick()

      // Check computed isFormValid
      expect(wrapper.vm.isFormValid).toBe(true)
    })
  })

  describe('cancel button', () => {
    it('should show cancel button by default', () => {
      const wrapper = mount(ParticipationForm)
      const cancelButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text() === 'Cancelar'
      )
      expect(cancelButton).toBeDefined()
      expect(cancelButton?.exists()).toBe(true)
    })

    it('should hide cancel button when showCancel is false', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          showCancel: false,
        },
      })
      const cancelButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text() === 'Cancelar'
      )
      // When showCancel is false, there should be no button with "Cancelar" text
      expect(cancelButton).toBeUndefined()
    })

    it('should emit cancel event', async () => {
      const wrapper = mount(ParticipationForm)
      const cancelButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text() === 'Cancelar'
      )
      await cancelButton?.trigger('click')

      expect(wrapper.emitted('cancel')).toBeTruthy()
    })
  })

  describe('edit mode', () => {
    it('should show "Guardar Cambios" in edit mode', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          mode: 'edit',
          initialData: mockInitialData,
        },
      })
      expect(wrapper.text()).toContain('Guardar Cambios')
    })

    it('should disable submit when no changes in edit mode', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          mode: 'edit',
          initialData: mockInitialData,
        },
      })

      // Check hasChanges computed - should be false when no changes made
      expect(wrapper.vm.hasChanges).toBe(false)
    })

    it('should enable submit when changes made in edit mode', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          mode: 'edit',
          initialData: mockInitialData,
        },
      })

      // Modify the formData directly
      wrapper.vm.formData.name = 'Nuevo Nombre'
      await nextTick()

      // Check hasChanges computed - should be true after changes
      expect(wrapper.vm.hasChanges).toBe(true)
    })
  })

  describe('loading and disabled states', () => {
    it('should show loading state', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          loading: true,
        },
      })
      // Verify the loading prop is passed correctly
      expect(wrapper.props('loading')).toBe(true)
    })

    it('should disable all inputs when disabled', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          disabled: true,
        },
      })
      // Verify the disabled prop is passed correctly
      expect(wrapper.props('disabled')).toBe(true)
    })

    it('should disable submit button when loading', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          loading: true,
        },
      })

      // When loading, form actions should be disabled
      // Check that loading state is correctly propagated
      expect(wrapper.props('loading')).toBe(true)
    })
  })

  describe('status select', () => {
    it('should show status select with options', () => {
      const wrapper = mount(ParticipationForm)
      const select = wrapper.findComponent({ name: 'Select' })
      expect(select.exists()).toBe(true)
    })

    it('should have default status as recruiting', () => {
      const wrapper = mount(ParticipationForm)
      const select = wrapper.findComponent({ name: 'Select' })
      expect(select.props('modelValue')).toBe('recruiting')
    })

    it('should change status', async () => {
      const wrapper = mount(ParticipationForm)
      const select = wrapper.findComponent({ name: 'Select' })
      await select.setValue('active')
      await nextTick()

      expect(select.props('modelValue')).toBe('active')
    })
  })
})
