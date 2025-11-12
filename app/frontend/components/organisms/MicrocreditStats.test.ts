import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import MicrocreditStats from './MicrocreditStats.vue'
import type { Microcredit } from './MicrocreditCard.vue'

const mockMicrocredits: Microcredit[] = [
  {
    id: '1',
    title: 'Panadería',
    description: 'Test',
    borrower: { id: 'b1', name: 'María' },
    amountRequested: 5000,
    amountFunded: 3000,
    interestRate: 5.5,
    termMonths: 12,
    status: 'funding',
    riskLevel: 'low',
    category: 'Negocio',
    investorsCount: 12,
  },
  {
    id: '2',
    title: 'Taller',
    description: 'Test',
    borrower: { id: 'b2', name: 'Carlos' },
    amountRequested: 3000,
    amountFunded: 3000,
    interestRate: 6,
    termMonths: 12,
    status: 'funded',
    riskLevel: 'medium',
    category: 'Ecología',
    investorsCount: 8,
  },
  {
    id: '3',
    title: 'Huerto',
    description: 'Test',
    borrower: { id: 'b3', name: 'Ana' },
    amountRequested: 2000,
    amountFunded: 2000,
    interestRate: 5,
    termMonths: 10,
    status: 'completed',
    riskLevel: 'low',
    category: 'Agricultura',
    investorsCount: 15,
  },
  {
    id: '4',
    title: 'Cafetería',
    description: 'Test',
    borrower: { id: 'b4', name: 'Pedro' },
    amountRequested: 8000,
    amountFunded: 6000,
    interestRate: 4.5,
    termMonths: 18,
    status: 'repaying',
    riskLevel: 'low',
    category: 'Social',
    investorsCount: 25,
  },
  {
    id: '5',
    title: 'Librería',
    description: 'Test',
    borrower: { id: 'b5', name: 'Laura' },
    amountRequested: 10000,
    amountFunded: 2000,
    interestRate: 7,
    termMonths: 24,
    status: 'defaulted',
    riskLevel: 'high',
    category: 'Cultura',
    investorsCount: 5,
  },
]

describe('MicrocreditStats', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.find('.microcredit-stats').exists()).toBe(true)
    })

    it('should display main stats cards', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('Total Financiado')
      expect(wrapper.text()).toContain('Total Microcréditos')
      expect(wrapper.text()).toContain('Total Inversores')
      expect(wrapper.text()).toContain('Tasa de Éxito')
    })

    it('should display secondary stats when not compact', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
          compact: false,
        },
      })
      expect(wrapper.text()).toContain('Por Estado')
      expect(wrapper.text()).toContain('Por Nivel de Riesgo')
      expect(wrapper.text()).toContain('Top Categorías')
    })

    it('should hide secondary stats when compact', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Por Estado')
      expect(wrapper.text()).not.toContain('Por Nivel de Riesgo')
    })
  })

  describe('total amount funded', () => {
    it('should calculate total amount funded', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      // 3000 + 3000 + 2000 + 6000 + 2000 = 16000
      expect(wrapper.text()).toContain('16.000')
    })

    it('should calculate total amount requested', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      // 5000 + 3000 + 2000 + 8000 + 10000 = 28000
      expect(wrapper.text()).toContain('28.000')
    })

    it('should calculate funding percentage', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      // 16000/28000 = 57.14% rounds to 57%
      expect(progressBar.props('value')).toBe(57)
    })
  })

  describe('total microcredits', () => {
    it('should display total microcredits count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('5')
    })

    it('should display active microcredits count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      // funding + repaying = 1 + 1 = 2
      expect(wrapper.text()).toContain('2 activos')
    })
  })

  describe('total investors', () => {
    it('should sum all investors', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      // 12 + 8 + 15 + 25 + 5 = 65
      expect(wrapper.text()).toContain('65')
    })

    it('should display funded microcredits count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      // funded + repaying + completed = 1 + 1 + 1 = 3
      expect(wrapper.text()).toContain('3 proyectos financiados')
    })
  })

  describe('success rate', () => {
    it('should calculate success rate', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      // completed/(completed + defaulted) = 1/(1+1) = 50%
      expect(wrapper.text()).toContain('50%')
    })

    it('should show completed count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('1 completados')
    })

    it('should return 0% when no completed or defaulted', () => {
      const noneCompleted = mockMicrocredits.filter(mc => mc.status === 'funding')
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: noneCompleted,
        },
      })
      expect(wrapper.text()).toContain('0%')
    })
  })

  describe('by status', () => {
    it('should show pending count', () => {
      const withPending = [
        ...mockMicrocredits,
        { ...mockMicrocredits[0], id: '6', status: 'pending' as const },
      ]
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: withPending,
        },
      })
      expect(wrapper.text()).toContain('Pendientes')
    })

    it('should show funding count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('En Financiación')
    })

    it('should show funded count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('Financiados')
    })

    it('should show repaying count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('En Repago')
    })

    it('should show completed count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('Completados')
    })

    it('should show defaulted count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('Impagados')
    })
  })

  describe('by risk level', () => {
    it('should show low risk count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('Bajo')
      // 3 low risk microcredits
    })

    it('should show medium risk count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('Medio')
    })

    it('should show high risk count', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('Alto')
    })

    it('should show progress bars for risk levels', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      const progressBars = wrapper.findAllComponents({ name: 'ProgressBar' })
      expect(progressBars.length).toBeGreaterThan(0)
    })
  })

  describe('top categories', () => {
    it('should show top categories', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('Negocio')
      expect(wrapper.text()).toContain('Ecología')
    })

    it('should show "no categories" when empty', () => {
      const noCategories = mockMicrocredits.map(mc => ({ ...mc, category: undefined }))
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: noCategories,
        },
      })
      expect(wrapper.text()).toContain('No hay categorías disponibles')
    })

    it('should limit to top 5 categories', () => {
      const manyCategories = Array(10).fill(null).map((_, i) => ({
        ...mockMicrocredits[0],
        id: `mc-${i}`,
        category: `Categoría ${i}`,
      }))
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: manyCategories,
        },
      })
      // Should show max 5 categories, each gets a progress bar
      const progressBars = wrapper.findAllComponents({ name: 'ProgressBar' })
      // 1 for funding percentage + up to 5 for categories + risk levels
      expect(progressBars.length).toBeLessThanOrEqual(15)
    })
  })

  describe('average interest rate', () => {
    it('should calculate average interest rate', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      // (5.5 + 6 + 5 + 4.5 + 7) / 5 = 28 / 5 = 5.6
      expect(wrapper.text()).toContain('5.6%')
    })

    it('should return 0 when no microcredits', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: [],
        },
      })
      expect(wrapper.text()).toContain('0%')
    })
  })

  describe('average term', () => {
    it('should calculate average term', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      // (12 + 12 + 10 + 18 + 24) / 5 = 76 / 5 = 15.2 rounds to 15
      expect(wrapper.text()).toContain('15 meses')
    })

    it('should return 0 when no microcredits', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: [],
        },
      })
      expect(wrapper.text()).toContain('0 meses')
    })
  })

  describe('loading state', () => {
    it('should show loading cards when loading', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
          loading: true,
        },
      })
      const loadingCards = wrapper.findAllComponents({ name: 'Card' }).filter(
        c => c.props('loading') === true
      )
      expect(loadingCards.length).toBeGreaterThan(0)
    })
  })

  describe('empty state', () => {
    it('should handle empty microcredits array', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: [],
        },
      })
      expect(wrapper.find('.microcredit-stats').exists()).toBe(true)
      expect(wrapper.text()).toContain('0')
    })

    it('should show 0% funding when no microcredits', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: [],
        },
      })
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.props('value')).toBe(0)
    })
  })

  describe('icons', () => {
    it('should show appropriate icons', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBeGreaterThan(0)
    })

    it('should have dollar-sign icon for funded amount', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      const dollarIcon = wrapper.findAllComponents({ name: 'Icon' }).find(
        i => i.props('name') === 'dollar-sign'
      )
      expect(dollarIcon?.exists()).toBe(true)
    })

    it('should have users icon for investors', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      const usersIcon = wrapper.findAllComponents({ name: 'Icon' }).find(
        i => i.props('name') === 'users'
      )
      expect(usersIcon?.exists()).toBe(true)
    })
  })

  describe('formatting', () => {
    it('should format currency correctly', () => {
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('€')
    })

    it('should format numbers with thousand separators', () => {
      const largeMicrocredits = [
        {
          ...mockMicrocredits[0],
          amountRequested: 100000,
          amountFunded: 50000,
          investorsCount: 1000,
        },
      ]
      const wrapper = mount(MicrocreditStats, {
        props: {
          microcredits: largeMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('1.000')
    })
  })
})
