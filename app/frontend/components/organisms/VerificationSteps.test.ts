import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import VerificationSteps from './VerificationSteps.vue'
import type { VerificationData } from './VerificationSteps.vue'

const mockData: VerificationData = {
  personal: {
    firstName: 'Juan',
    lastName: 'García López',
    dateOfBirth: '1990-01-15',
    nationality: 'Española',
  },
  document: {
    documentType: 'dni',
    documentNumber: '12345678A',
    expirationDate: '2030-12-31',
  },
  address: {
    street: 'Calle Mayor',
    number: '123',
    floor: '3',
    door: 'B',
    postalCode: '28013',
    city: 'Madrid',
    province: 'Madrid',
  },
  phone: {
    countryCode: '+34',
    phoneNumber: '600123456',
    verificationCode: '123456',
  },
}

describe('VerificationSteps', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(VerificationSteps)
      expect(wrapper.find('.verification-steps').exists()).toBe(true)
    })

    it('should display title', () => {
      const wrapper = mount(VerificationSteps)
      expect(wrapper.text()).toContain('Verificación de Identidad')
    })

    it('should show status badge', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          verificationStatus: 'in_progress',
        },
      })
      expect(wrapper.findComponent({ name: 'Badge' }).exists()).toBe(true)
      expect(wrapper.text()).toContain('En Progreso')
    })

    it('should show progress bar', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          showProgress: true,
        },
      })
      expect(wrapper.findComponent({ name: 'ProgressBar' }).exists()).toBe(true)
    })

    it('should hide progress bar when showProgress is false', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          showProgress: false,
        },
      })
      expect(wrapper.findComponent({ name: 'ProgressBar' }).exists()).toBe(false)
    })

    it('should render step indicators', () => {
      const wrapper = mount(VerificationSteps)
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBeGreaterThan(5) // At least 5 step icons
    })
  })

  describe('step 1: personal info', () => {
    it('should show personal info form', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'personal',
        },
      })
      expect(wrapper.text()).toContain('Datos Personales')
    })

    it('should render first name input', () => {
      const wrapper = mount(VerificationSteps)
      expect(wrapper.text()).toContain('Nombre')
    })

    it('should render last name input', () => {
      const wrapper = mount(VerificationSteps)
      expect(wrapper.text()).toContain('Apellidos')
    })

    it('should render date of birth input', () => {
      const wrapper = mount(VerificationSteps)
      expect(wrapper.text()).toContain('Fecha de Nacimiento')
    })

    it('should render nationality input', () => {
      const wrapper = mount(VerificationSteps)
      expect(wrapper.text()).toContain('Nacionalidad')
    })

    it('should validate first name', async () => {
      const wrapper = mount(VerificationSteps)
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('nombre debe tener al menos 2 caracteres')
    })

    it('should validate age (18+)', async () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          initialData: {
            personal: {
              firstName: 'Juan',
              lastName: 'García',
              dateOfBirth: '2020-01-01', // Too young
              nationality: 'Española',
            },
          },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('mayor de 18 años')
    })
  })

  describe('step 2: document', () => {
    it('should show document form', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
        },
      })
      expect(wrapper.text()).toContain('Documento de Identidad')
    })

    it('should render document type select', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
        },
      })
      expect(wrapper.text()).toContain('Tipo de Documento')
    })

    it('should render document number input', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
        },
      })
      expect(wrapper.text()).toContain('Número de Documento')
    })

    it('should render expiration date input', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
        },
      })
      expect(wrapper.text()).toContain('Fecha de Caducidad')
    })

    it('should validate document type', async () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Selecciona un tipo de documento')
    })

    it('should validate expired documents', async () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
          initialData: {
            document: {
              documentType: 'dni',
              documentNumber: '12345678A',
              expirationDate: '2020-01-01', // Expired
            },
          },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('documento ha caducado')
    })
  })

  describe('step 3: address', () => {
    it('should show address form', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'address',
        },
      })
      expect(wrapper.text()).toContain('Dirección de Residencia')
    })

    it('should render street input', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'address',
        },
      })
      expect(wrapper.text()).toContain('Calle')
    })

    it('should render postal code input', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'address',
        },
      })
      expect(wrapper.text()).toContain('Código Postal')
    })

    it('should validate postal code format', async () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'address',
          initialData: {
            address: {
              street: 'Calle Mayor',
              number: '123',
              postalCode: '123', // Too short
              city: 'Madrid',
              province: 'Madrid',
            },
          },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('código postal debe tener 5 dígitos')
    })

    it('should allow optional floor and door', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'address',
        },
      })
      expect(wrapper.text()).toContain('Piso (opcional)')
      expect(wrapper.text()).toContain('Puerta (opcional)')
    })
  })

  describe('step 4: phone', () => {
    it('should show phone form', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'phone',
        },
      })
      expect(wrapper.text()).toContain('Verificación de Teléfono')
    })

    it('should render country code select', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'phone',
        },
      })
      const selects = wrapper.findAllComponents({ name: 'Select' })
      expect(selects.length).toBeGreaterThan(0)
    })

    it('should render phone number input', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'phone',
        },
      })
      expect(wrapper.text()).toContain('Número de Teléfono')
    })

    it('should show send code button', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'phone',
        },
      })
      expect(wrapper.text()).toContain('Enviar Código de Verificación')
    })

    it('should emit send-verification-code event', async () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'phone',
          initialData: {
            phone: {
              countryCode: '+34',
              phoneNumber: '600123456',
            },
          },
        },
      })
      const sendCodeButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Enviar Código'))

      await sendCodeButton?.trigger('click')

      expect(wrapper.emitted('send-verification-code')).toBeTruthy()
    })

    it('should validate phone number length', async () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'phone',
          initialData: {
            phone: {
              countryCode: '+34',
              phoneNumber: '123', // Too short
            },
          },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('al menos 9 dígitos')
    })
  })

  describe('step 5: review', () => {
    it('should show review step', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'review',
          initialData: mockData,
        },
      })
      expect(wrapper.text()).toContain('Revisión de Datos')
    })

    it('should display personal info summary', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'review',
          initialData: mockData,
        },
      })
      expect(wrapper.text()).toContain('Juan')
      expect(wrapper.text()).toContain('García López')
    })

    it('should display document summary', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'review',
          initialData: mockData,
        },
      })
      expect(wrapper.text()).toContain('12345678A')
    })

    it('should display address summary', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'review',
          initialData: mockData,
        },
      })
      expect(wrapper.text()).toContain('Calle Mayor')
      expect(wrapper.text()).toContain('28013')
    })

    it('should display phone summary', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'review',
          initialData: mockData,
        },
      })
      expect(wrapper.text()).toContain('+34')
      expect(wrapper.text()).toContain('600123456')
    })

    it('should show submit button', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'review',
        },
      })
      expect(wrapper.text()).toContain('Enviar Verificación')
    })
  })

  describe('navigation', () => {
    it('should navigate to next step', async () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          initialData: {
            personal: mockData.personal,
          },
        },
      })
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Documento de Identidad')
    })

    it('should navigate to previous step', async () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
        },
      })
      const prevButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Anterior'))

      await prevButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Datos Personales')
    })

    it('should not show previous button on first step', () => {
      const wrapper = mount(VerificationSteps)
      const prevButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Anterior'))
      expect(prevButton).toBeUndefined()
    })

    it('should not navigate with validation errors', async () => {
      const wrapper = mount(VerificationSteps)
      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Siguiente'))

      await nextButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Datos Personales')
    })

    it('should emit step-change event', async () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
        },
      })
      const prevButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Anterior'))

      await prevButton?.trigger('click')

      expect(wrapper.emitted('step-change')).toBeTruthy()
      expect(wrapper.emitted('step-change')?.[0]).toEqual(['personal'])
    })
  })

  describe('progress', () => {
    it('should show 0% on first step', () => {
      const wrapper = mount(VerificationSteps)
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.props('value')).toBe(0)
    })

    it('should show 25% on second step', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
        },
      })
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.props('value')).toBe(25)
    })

    it('should show 100% on last step', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'review',
        },
      })
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.props('value')).toBe(100)
    })
  })

  describe('form submission', () => {
    it('should emit submit event with data', async () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'review',
          initialData: mockData,
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Enviar Verificación'))

      await submitButton?.trigger('click')

      expect(wrapper.emitted('submit')).toBeTruthy()
    })
  })

  describe('cancel action', () => {
    it('should show cancel button', () => {
      const wrapper = mount(VerificationSteps)
      const cancelButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text() === 'Cancelar')
      expect(cancelButton?.exists()).toBe(true)
    })

    it('should emit cancel event', async () => {
      const wrapper = mount(VerificationSteps)
      const cancelButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text() === 'Cancelar')

      await cancelButton?.trigger('click')

      expect(wrapper.emitted('cancel')).toBeTruthy()
    })
  })

  describe('verification statuses', () => {
    it('should show not_started status', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          verificationStatus: 'not_started',
        },
      })
      expect(wrapper.text()).toContain('No Iniciado')
    })

    it('should show in_progress status', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          verificationStatus: 'in_progress',
        },
      })
      expect(wrapper.text()).toContain('En Progreso')
    })

    it('should show pending_review status', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          verificationStatus: 'pending_review',
        },
      })
      expect(wrapper.text()).toContain('Pendiente de Revisión')
    })

    it('should show verified status', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          verificationStatus: 'verified',
        },
      })
      expect(wrapper.text()).toContain('Verificado')
    })

    it('should show rejected status', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          verificationStatus: 'rejected',
        },
      })
      expect(wrapper.text()).toContain('Rechazado')
    })
  })

  describe('loading state', () => {
    it('should disable inputs when loading', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          loading: true,
        },
      })
      const inputs = wrapper.findAllComponents({ name: 'Input' })
      inputs.forEach(input => {
        expect(input.props('disabled')).toBe(true)
      })
    })

    it('should show loading on submit button', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'review',
          loading: true,
        },
      })
      const submitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Verificación'))
      expect(submitButton?.props('loading')).toBe(true)
    })
  })

  describe('disabled state', () => {
    it('should disable all inputs', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          disabled: true,
        },
      })
      const inputs = wrapper.findAllComponents({ name: 'Input' })
      inputs.forEach(input => {
        expect(input.props('disabled')).toBe(true)
      })
    })
  })

  describe('initial data', () => {
    it('should populate form with initial data', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          initialData: mockData,
        },
      })
      const input = wrapper.findComponent({ name: 'Input' })
      expect(input.props('modelValue')).toBe('Juan')
    })
  })

  describe('document types', () => {
    it('should show all document type options', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
        },
      })
      const select = wrapper.findComponent({ name: 'Select' })
      const options = select.props('options')

      expect(options).toContainEqual({ value: 'dni', label: 'DNI' })
      expect(options).toContainEqual({ value: 'passport', label: 'Pasaporte' })
      expect(options).toContainEqual({ value: 'nie', label: 'NIE' })
      expect(options).toContainEqual({ value: 'residence_card', label: 'Tarjeta de Residencia' })
    })
  })

  describe('step indicators', () => {
    it('should highlight current step', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'document',
        },
      })
      // The second step indicator should have primary color
      const stepIndicators = wrapper.findAll('[class*="bg-primary"]')
      expect(stepIndicators.length).toBeGreaterThan(0)
    })

    it('should mark completed steps', () => {
      const wrapper = mount(VerificationSteps, {
        props: {
          currentStep: 'address', // Third step
        },
      })
      const greenSteps = wrapper.findAll('[class*="bg-green"]')
      expect(greenSteps.length).toBeGreaterThan(0) // Previous steps should be green
    })
  })
})
