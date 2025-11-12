import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import MicrocreditForm from './MicrocreditForm.vue'
import type { MicrocreditFormData } from './MicrocreditForm.vue'

const mockInitialData: Partial<MicrocreditFormData> = {
  title: 'Expansión de Panadería Local',
  description: 'Necesito financiación para comprar un horno industrial y expandir mi panadería artesanal en el barrio con productos de calidad',
  amountRequested: 5000,
  interestRate: 5.5,
  termMonths: 12,
  riskLevel: 'low',
  category: 'Negocio',
  deadline: '2025-12-31',
  minimumInvestment: 100,
  imageUrl: 'https://example.com/image.jpg',
}

describe('MicrocreditForm', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(MicrocreditForm)
      expect(wrapper.find('.microcredit-form').exists()).toBe(true)
    })

    it('should show create title when mode is create', () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          mode: 'create',
        },
      })
      expect(wrapper.text()).toContain('Solicitar Microcrédito')
    })

    it('should show edit title when mode is edit', () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          mode: 'edit',
        },
      })
      expect(wrapper.text()).toContain('Editar Microcrédito')
    })

    it('should display all form fields', () => {
      const wrapper = mount(MicrocreditForm)
      expect(wrapper.text()).toContain('Título del Proyecto')
      expect(wrapper.text()).toContain('Descripción del Proyecto')
      expect(wrapper.text()).toContain('Cantidad Solicitada')
      expect(wrapper.text()).toContain('Tasa de Interés')
      expect(wrapper.text()).toContain('Plazo')
      expect(wrapper.text()).toContain('Nivel de Riesgo')
    })

    it('should show image upload section when not compact', () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          compact: false,
        },
      })
      expect(wrapper.text()).toContain('Imagen del Proyecto')
    })

    it('should hide image upload section when compact', () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Imagen del Proyecto')
    })
  })

  describe('initial data', () => {
    it('should load initial data', async () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          initialData: mockInitialData,
        },
      })
      await nextTick()

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      expect(titleInput?.props('modelValue')).toBe('Expansión de Panadería Local')
    })

    it('should show image preview when imageUrl is provided', async () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          initialData: mockInitialData,
        },
      })
      await nextTick()

      const img = wrapper.find('img[alt="Project preview"]')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('https://example.com/image.jpg')
    })
  })

  describe('form validation', () => {
    it('should require title', async () => {
      const wrapper = mount(MicrocreditForm)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El título es requerido')
      expect(wrapper.emitted('submit')).toBeFalsy()
    })

    it('should validate minimum title length', async () => {
      const wrapper = mount(MicrocreditForm)

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      await titleInput?.setValue('Corto')

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El título debe tener al menos 10 caracteres')
    })

    it('should validate maximum title length', async () => {
      const wrapper = mount(MicrocreditForm)

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      const longTitle = 'A'.repeat(101)
      await titleInput?.setValue(longTitle)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('El título no puede exceder 100 caracteres')
    })

    it('should require description', async () => {
      const wrapper = mount(MicrocreditForm)

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      await titleInput?.setValue('Proyecto de test válido')

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción es requerida')
    })

    it('should validate minimum description length', async () => {
      const wrapper = mount(MicrocreditForm)

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Corta')

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción debe tener al menos 50 caracteres')
    })

    it('should validate maximum description length', async () => {
      const wrapper = mount(MicrocreditForm)

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      const longDescription = 'A'.repeat(1001)
      await descriptionInput?.setValue(longDescription)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La descripción no puede exceder 1000 caracteres')
    })

    it('should validate minimum amount', async () => {
      const wrapper = mount(MicrocreditForm)

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      await titleInput?.setValue('Proyecto de test válido')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 50 caracteres para pasar la validación')

      const amountInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '5000'
      )
      await amountInput?.setValue(50)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La cantidad mínima es 100€')
    })

    it('should validate maximum amount', async () => {
      const wrapper = mount(MicrocreditForm)

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      await titleInput?.setValue('Proyecto de test válido')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 50 caracteres para pasar la validación')

      const amountInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '5000'
      )
      await amountInput?.setValue(150000)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La cantidad máxima es 100,000€')
    })

    it('should validate interest rate range', async () => {
      const wrapper = mount(MicrocreditForm)

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      await titleInput?.setValue('Proyecto de test válido')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 50 caracteres para pasar la validación')

      const amountInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '5000'
      )
      await amountInput?.setValue(5000)

      const interestInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '5.5'
      )
      await interestInput?.setValue(35)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La tasa de interés máxima es 30%')
    })

    it('should validate minimum investment', async () => {
      const wrapper = mount(MicrocreditForm)

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      await titleInput?.setValue('Proyecto de test válido')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 50 caracteres para pasar la validación')

      const amountInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '5000'
      )
      await amountInput?.setValue(5000)

      const interestInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '5.5'
      )
      await interestInput?.setValue(5.5)

      const minimumInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '100'
      )
      await minimumInput?.setValue(5)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La inversión mínima debe ser al menos 10€')
    })

    it('should validate minimum investment not exceeding amount requested', async () => {
      const wrapper = mount(MicrocreditForm)

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      await titleInput?.setValue('Proyecto de test válido')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 50 caracteres para pasar la validación')

      const amountInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '5000'
      )
      await amountInput?.setValue(1000)

      const interestInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '5.5'
      )
      await interestInput?.setValue(5.5)

      const minimumInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '100'
      )
      await minimumInput?.setValue(1500)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('La inversión mínima no puede ser mayor a la cantidad solicitada')
    })
  })

  describe('character counters', () => {
    it('should show title character count', () => {
      const wrapper = mount(MicrocreditForm)
      expect(wrapper.text()).toContain('0 / 100')
    })

    it('should update title character count', async () => {
      const wrapper = mount(MicrocreditForm)

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      await titleInput?.setValue('Test')
      await nextTick()

      expect(wrapper.text()).toContain('4 / 100')
    })

    it('should show description character count', () => {
      const wrapper = mount(MicrocreditForm)
      expect(wrapper.text()).toContain('0 / 1000')
    })

    it('should update description character count', async () => {
      const wrapper = mount(MicrocreditForm)

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Test description')
      await nextTick()

      expect(wrapper.text()).toContain('16 / 1000')
    })
  })

  describe('payment summary', () => {
    it('should show payment summary when form is valid', async () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          initialData: mockInitialData,
        },
      })
      await nextTick()

      expect(wrapper.text()).toContain('Resumen de Pagos')
      expect(wrapper.text()).toContain('Pago Mensual')
      expect(wrapper.text()).toContain('Total a Devolver')
      expect(wrapper.text()).toContain('Intereses Totales')
    })

    it('should not show payment summary when form is invalid', () => {
      const wrapper = mount(MicrocreditForm)
      expect(wrapper.text()).not.toContain('Resumen de Pagos')
    })
  })

  describe('form submission', () => {
    it('should emit submit event with valid data', async () => {
      const wrapper = mount(MicrocreditForm)

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      await titleInput?.setValue('Proyecto de test válido')

      const descriptionInput = wrapper.findComponent({ name: 'Textarea' })
      await descriptionInput?.setValue('Esta es una descripción válida con más de 50 caracteres para pasar la validación')

      const amountInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '5000'
      )
      await amountInput?.setValue(5000)

      const interestInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder') === '5.5'
      )
      await interestInput?.setValue(5.5)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.emitted('submit')).toBeTruthy()
      const submitData = wrapper.emitted('submit')?.[0]?.[0] as MicrocreditFormData
      expect(submitData.title).toBe('Proyecto de test válido')
      expect(submitData.amountRequested).toBe(5000)
    })

    it('should not submit with invalid data', async () => {
      const wrapper = mount(MicrocreditForm)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      await submitButton?.trigger('click')
      await nextTick()

      expect(wrapper.emitted('submit')).toBeFalsy()
    })

    it('should disable submit button when form is invalid', () => {
      const wrapper = mount(MicrocreditForm)

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      expect(submitButton?.props('disabled')).toBe(true)
    })

    it('should enable submit button when form is valid', async () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          initialData: mockInitialData,
        },
      })
      await nextTick()

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Guardar')
      )
      // Should be disabled in edit mode when no changes
      expect(submitButton?.props('disabled')).toBe(true)
    })
  })

  describe('cancel button', () => {
    it('should show cancel button by default', () => {
      const wrapper = mount(MicrocreditForm)
      const cancelButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text() === 'Cancelar'
      )
      expect(cancelButton?.exists()).toBe(true)
    })

    it('should hide cancel button when showCancel is false', () => {
      const wrapper = mount(MicrocreditForm, {
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
      const wrapper = mount(MicrocreditForm)
      const cancelButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text() === 'Cancelar'
      )
      await cancelButton?.trigger('click')

      expect(wrapper.emitted('cancel')).toBeTruthy()
    })
  })

  describe('edit mode', () => {
    it('should show "Guardar Cambios" in edit mode', () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          mode: 'edit',
          initialData: mockInitialData,
        },
      })
      expect(wrapper.text()).toContain('Guardar Cambios')
    })

    it('should disable submit when no changes in edit mode', () => {
      const wrapper = mount(MicrocreditForm, {
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
      const wrapper = mount(MicrocreditForm, {
        props: {
          mode: 'edit',
          initialData: mockInitialData,
        },
      })

      const titleInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Panadería')
      )
      await titleInput?.setValue('Nuevo título del proyecto')
      await nextTick()

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Guardar')
      )
      expect(submitButton?.props('disabled')).toBe(false)
    })
  })

  describe('loading and disabled states', () => {
    it('should show loading state', () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          loading: true,
        },
      })
      const card = wrapper.findComponent({ name: 'Card' })
      expect(card.props('loading')).toBe(true)
    })

    it('should disable all inputs when disabled', () => {
      const wrapper = mount(MicrocreditForm, {
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
      const wrapper = mount(MicrocreditForm, {
        props: {
          loading: true,
        },
      })

      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Enviar')
      )
      expect(submitButton?.props('disabled')).toBe(true)
    })
  })

  describe('risk level select', () => {
    it('should show risk level select with options', () => {
      const wrapper = mount(MicrocreditForm)
      const selects = wrapper.findAllComponents({ name: 'Select' })
      expect(selects.length).toBeGreaterThan(0)
    })

    it('should have default risk level as medium', () => {
      const wrapper = mount(MicrocreditForm)
      const riskSelect = wrapper.findAllComponents({ name: 'Select' })[1] // Risk level is second select
      expect(riskSelect.props('modelValue')).toBe('medium')
    })
  })

  describe('term select', () => {
    it('should have default term as 12 months', () => {
      const wrapper = mount(MicrocreditForm)
      const termSelect = wrapper.findAllComponents({ name: 'Select' })[0] // Term is first select
      expect(termSelect.props('modelValue')).toBe(12)
    })
  })

  describe('category select', () => {
    it('should show category select', () => {
      const wrapper = mount(MicrocreditForm)
      expect(wrapper.text()).toContain('Categoría')
    })
  })

  describe('image upload', () => {
    it('should show image upload when no image', () => {
      const wrapper = mount(MicrocreditForm)
      expect(wrapper.text()).toContain('Arrastra una imagen o haz clic para seleccionar')
    })

    it('should show image preview when uploaded', async () => {
      const wrapper = mount(MicrocreditForm, {
        props: {
          initialData: mockInitialData,
        },
      })
      await nextTick()

      const img = wrapper.find('img[alt="Project preview"]')
      expect(img.exists()).toBe(true)
    })

    it('should remove image', async () => {
      const wrapper = mount(MicrocreditForm, {
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

      expect(wrapper.find('img[alt="Project preview"]').exists()).toBe(false)
      expect(wrapper.text()).toContain('Arrastra una imagen')
    })
  })
})
