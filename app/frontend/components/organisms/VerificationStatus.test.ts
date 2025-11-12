import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import VerificationStatus from './VerificationStatus.vue'
import type { VerificationItem } from './VerificationStatus.vue'

const mockItems: VerificationItem[] = [
  {
    id: '1',
    label: 'Datos Personales',
    description: 'Verificación de nombre y fecha de nacimiento',
    status: 'completed',
    required: true,
    completedAt: '2024-01-15',
  },
  {
    id: '2',
    label: 'Documento de Identidad',
    description: 'Verificación de DNI o Pasaporte',
    status: 'completed',
    required: true,
    completedAt: '2024-01-20',
    expiresAt: '2029-01-20',
  },
  {
    id: '3',
    label: 'Dirección',
    description: 'Verificación de domicilio',
    status: 'pending',
    required: true,
  },
  {
    id: '4',
    label: 'Teléfono',
    description: 'Verificación de número telefónico',
    status: 'pending',
    required: false,
  },
]

describe('VerificationStatus', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.find('.verification-status').exists()).toBe(true)
    })

    it('should display title', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Estado de Verificación')
    })

    it('should show level badge', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      const badge = wrapper.findComponent({ name: 'Badge' })
      expect(badge.exists()).toBe(true)
      expect(wrapper.text()).toContain('Verificación Estándar')
    })

    it('should show progress bar', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          showProgress: true,
        },
      })
      expect(wrapper.findComponent({ name: 'ProgressBar' }).exists()).toBe(true)
    })

    it('should hide progress bar when showProgress is false', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          showProgress: false,
        },
      })
      expect(wrapper.findComponent({ name: 'ProgressBar' }).exists()).toBe(false)
    })
  })

  describe('verification levels', () => {
    it('should show none level', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'none',
          items: [],
        },
      })
      expect(wrapper.text()).toContain('Sin Verificar')
    })

    it('should show basic level', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'basic',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Verificación Básica')
    })

    it('should show standard level', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Verificación Estándar')
    })

    it('should show advanced level', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'advanced',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Verificación Avanzada')
    })

    it('should show complete level', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'complete',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Verificación Completa')
    })
  })

  describe('items display', () => {
    it('should render verification items', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Datos Personales')
      expect(wrapper.text()).toContain('Documento de Identidad')
    })

    it('should separate required and optional items', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Elementos Requeridos')
      expect(wrapper.text()).toContain('Elementos Opcionales')
    })

    it('should show item descriptions when showDetails is true', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          showDetails: true,
        },
      })
      expect(wrapper.text()).toContain('Verificación de nombre y fecha de nacimiento')
    })

    it('should hide item descriptions when showDetails is false', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          showDetails: false,
        },
      })
      expect(wrapper.text()).not.toContain('Verificación de nombre y fecha de nacimiento')
    })
  })

  describe('item statuses', () => {
    it('should show completed items', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Completado')
    })

    it('should show pending items', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Pendiente')
    })

    it('should show rejected items', () => {
      const rejectedItems = [
        {
          ...mockItems[0],
          status: 'rejected' as const,
          rejectionReason: 'Documento no legible',
        },
      ]
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: rejectedItems,
        },
      })
      expect(wrapper.text()).toContain('Rechazado')
      expect(wrapper.text()).toContain('Documento no legible')
    })

    it('should show expired items', () => {
      const expiredItems = [
        {
          ...mockItems[0],
          status: 'expired' as const,
        },
      ]
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: expiredItems,
        },
      })
      expect(wrapper.text()).toContain('Expirado')
    })
  })

  describe('progress calculation', () => {
    it('should calculate completion percentage', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems, // 2 completed out of 4
        },
      })
      expect(wrapper.text()).toContain('50% completado')
    })

    it('should show 0% for no items', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'none',
          items: [],
        },
      })
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      if (progressBar.exists()) {
        expect(progressBar.props('value')).toBe(0)
      }
    })

    it('should show 100% for all completed', () => {
      const allCompleted = mockItems.map(item => ({ ...item, status: 'completed' as const }))
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'complete',
          items: allCompleted,
        },
      })
      expect(wrapper.text()).toContain('100% completado')
    })
  })

  describe('summary statistics', () => {
    it('should show total items count', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('4') // total
      expect(wrapper.text()).toContain('Total')
    })

    it('should show pending items count', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('2') // pending
      expect(wrapper.text()).toContain('Pendientes')
    })

    it('should show completed items count', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Completados')
    })

    it('should show rejected items count', () => {
      const rejectedItems = [
        { ...mockItems[0], status: 'rejected' as const },
        ...mockItems.slice(1),
      ]
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: rejectedItems,
        },
      })
      expect(wrapper.text()).toContain('Rechazados')
    })

    it('should hide statistics in compact mode', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Total')
    })
  })

  describe('actions', () => {
    it('should show verify button for pending items', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      const verifyButtons = wrapper.findAllComponents({ name: 'Button' }).filter(b => b.text() === 'Verificar')
      expect(verifyButtons.length).toBeGreaterThan(0)
    })

    it('should emit verify-item event', async () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      const verifyButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text() === 'Verificar')
      await verifyButton?.trigger('click')

      expect(wrapper.emitted('verify-item')).toBeTruthy()
    })

    it('should show resubmit button for rejected items', () => {
      const rejectedItems = [
        {
          ...mockItems[0],
          status: 'rejected' as const,
          rejectionReason: 'Error en documento',
        },
      ]
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: rejectedItems,
        },
      })
      expect(wrapper.text()).toContain('Reenviar')
    })

    it('should emit resubmit event', async () => {
      const rejectedItems = [
        {
          ...mockItems[0],
          status: 'rejected' as const,
        },
      ]
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: rejectedItems,
        },
      })
      const resubmitButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text() === 'Reenviar')
      await resubmitButton?.trigger('click')

      expect(wrapper.emitted('resubmit')).toBeTruthy()
    })
  })

  describe('empty state', () => {
    it('should show empty state when no items', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'none',
          items: [],
        },
      })
      expect(wrapper.text()).toContain('No hay elementos de verificación')
    })

    it('should show start verification button', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'none',
          items: [],
        },
      })
      expect(wrapper.text()).toContain('Iniciar Verificación')
    })

    it('should emit start-verification event', async () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'none',
          items: [],
        },
      })
      const startButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Iniciar'))
      await startButton?.trigger('click')

      expect(wrapper.emitted('start-verification')).toBeTruthy()
    })
  })

  describe('next steps', () => {
    it('should show next steps when there are pending items', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Próximos Pasos')
    })

    it('should hide next steps in compact mode', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Próximos Pasos')
    })

    it('should show pending count in next steps', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toMatch(/2 elementos pendientes/)
    })
  })

  describe('dates', () => {
    it('should show completion date', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          showDetails: true,
        },
      })
      expect(wrapper.text()).toContain('Completado:')
    })

    it('should show expiration date', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          showDetails: true,
        },
      })
      expect(wrapper.text()).toContain('Expira:')
    })

    it('should highlight expired items', () => {
      const expiredItems = [
        {
          ...mockItems[0],
          expiresAt: '2020-01-01', // Expired date
        },
      ]
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: expiredItems,
          showDetails: true,
        },
      })
      expect(wrapper.text()).toContain('Expiró:')
    })
  })

  describe('loading state', () => {
    it('should show loading state', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          loading: true,
        },
      })
      const card = wrapper.findComponent({ name: 'Card' })
      expect(card.props('loading')).toBe(true)
    })
  })

  describe('compact mode', () => {
    it('should hide description in compact mode', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Has completado la verificación estándar')
    })

    it('should hide summary statistics in compact mode', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Total')
    })
  })

  describe('required vs optional', () => {
    it('should show required items section', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Elementos Requeridos')
    })

    it('should show optional items section', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      expect(wrapper.text()).toContain('Elementos Opcionales')
    })

    it('should filter required items correctly', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      // There are 3 required items in mockItems
      const text = wrapper.text()
      const requiredSection = text.split('Elementos Opcionales')[0]
      expect(requiredSection).toContain('Datos Personales')
      expect(requiredSection).toContain('Documento de Identidad')
      expect(requiredSection).toContain('Dirección')
    })

    it('should filter optional items correctly', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      const text = wrapper.text()
      const optionalSection = text.split('Elementos Opcionales')[1]
      expect(optionalSection).toContain('Teléfono')
    })
  })

  describe('icons', () => {
    it('should show level icon', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'complete',
          items: mockItems,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      const levelIcon = icons.find(i => i.props('name') === 'award')
      expect(levelIcon?.exists()).toBe(true)
    })

    it('should show status icons for items', () => {
      const wrapper = mount(VerificationStatus, {
        props: {
          level: 'standard',
          items: mockItems,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBeGreaterThan(4) // At least one icon per item
    })
  })
})
