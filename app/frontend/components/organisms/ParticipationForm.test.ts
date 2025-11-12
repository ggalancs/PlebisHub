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

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El nombre del equipo es requerido')
      expect(wrapper.emitted('submit')).toBeFalsy()
    })

    it('should validate minimum name length', async () => {
      const wrapper = mount(ParticipationForm)

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      await nameInput?.setValue('AB')

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El nombre debe tener al menos 3 caracteres')
    })

    it('should validate maximum name length', async () => {
      const wrapper = mount(ParticipationForm)

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      const longName = 'A'.repeat(101)
      await nameInput?.setValue(longName)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El nombre no puede exceder 100 caracteres')
    })

    it('should require description', async () => {
      const wrapper = mount(ParticipationForm)

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      await nameInput?.setValue('Equipo Test')

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción es requerida')
    })

    it('should validate minimum description length', async () => {
      const wrapper = mount(ParticipationForm)

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      await nameInput?.setValue('Equipo Test')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Corto')

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción debe tener al menos 20 caracteres')
    })

    it('should validate maximum description length', async () => {
      const wrapper = mount(ParticipationForm)

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      const longDescription = 'A'.repeat(501)
      await descriptionInput?.setValue(longDescription)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción no puede exceder 500 caracteres')
    })

    it('should validate minimum max members', async () => {
      const wrapper = mount(ParticipationForm)

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      await nameInput?.setValue('Equipo Test')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 20 caracteres')

      const maxMembersInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('type') === 'number'
      )
      await maxMembersInput?.setValue(1)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El equipo debe tener al menos 2 miembros')
    })

    it('should validate maximum max members', async () => {
      const wrapper = mount(ParticipationForm)

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      await nameInput?.setValue('Equipo Test')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 20 caracteres')

      const maxMembersInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('type') === 'number'
      )
      await maxMembersInput?.setValue(101)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El equipo no puede tener más de 100 miembros')
    })

    it('should allow undefined max members', async () => {
      const wrapper = mount(ParticipationForm)

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      await nameInput?.setValue('Equipo Test')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 20 caracteres')

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
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
      const wrapper = mount(ParticipationForm)
      expect(wrapper.text()).toContain('Arrastra una imagen o haz clic para seleccionar')
    })

    it('should show image preview when uploaded', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          initialData: mockInitialData,
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
        },
      })
      await nextTick()

      const removeButton = wrapper.findAll('button').find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'trash-2'
      })
      await removeButton?.trigger('click')
      await nextTick()

      expect(wrapper.find('img[alt="Team preview"]').exists()).toBe(false)
      expect(wrapper.text()).toContain('Arrastra una imagen')
    })
  })

  describe('form submission', () => {
    it('should emit submit event with valid data', async () => {
      const wrapper = mount(ParticipationForm)

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      await nameInput?.setValue('Equipo Test')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 20 caracteres')

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.emitted('submit')).toBeTruthy()
      const submitData = wrapper.emitted('submit')?.[0]?.[0] as ParticipationFormData
      expect(submitData.name).toBe('Equipo Test')
      expect(submitData.description).toBe('Esta es una descripción válida con más de 20 caracteres')
    })

    it('should not submit with invalid data', async () => {
      const wrapper = mount(ParticipationForm)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.emitted('submit')).toBeFalsy()
    })

    it('should disable submit button when form is invalid', () => {
      const wrapper = mount(ParticipationForm)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      expect(submitButton?.props('disabled')).toBe(true)
    })

    it('should enable submit button when form is valid', async () => {
      const wrapper = mount(ParticipationForm)

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      await nameInput?.setValue('Equipo Test')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 20 caracteres')
      await nextTick()

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      expect(submitButton?.props('disabled')).toBe(false)
    })
  })

  describe('cancel button', () => {
    it('should show cancel button by default', () => {
      const wrapper = mount(ParticipationForm)
      const cancelButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text() === 'Cancelar'
      )
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
      expect(cancelButton?.exists()).toBe(false)
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

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Guardar')
      )
      expect(submitButton?.props('disabled')).toBe(true)
    })

    it('should enable submit when changes made in edit mode', async () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          mode: 'edit',
          initialData: mockInitialData,
        },
      })

      const nameInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Equipo')
      )
      await nameInput?.setValue('Nuevo Nombre')
      await nextTick()

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Guardar')
      )
      expect(submitButton?.props('disabled')).toBe(false)
    })
  })

  describe('loading and disabled states', () => {
    it('should show loading state', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          loading: true,
        },
      })
      const card = wrapper.findComponent({ name: 'Card' })
      expect(card.props('loading')).toBe(true)
    })

    it('should disable all inputs when disabled', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          disabled: true,
        },
      })
      const inputs = wrapper.findAllComponents({ name: 'Input' })
      inputs.forEach(input => {
        expect(input.props('disabled')).toBe(true)
      })
    })

    it('should disable submit button when loading', () => {
      const wrapper = mount(ParticipationForm, {
        props: {
          loading: true,
        },
      })

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Crear')
      )
      expect(submitButton?.props('disabled')).toBe(true)
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
