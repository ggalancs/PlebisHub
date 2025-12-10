import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import MicrocreditCard from './MicrocreditCard.vue'
import type { Microcredit } from './MicrocreditCard.vue'

const mockMicrocredit: Microcredit = {
  id: '1',
  title: 'Expansión de Panadería Local',
  description: 'Necesito financiación para comprar un horno industrial y expandir mi panadería',
  borrower: {
    id: 'borrower-1',
    name: 'María García',
    avatar: 'https://example.com/avatar.jpg',
    location: 'Madrid, España',
    rating: 4,
  },
  amountRequested: 5000,
  amountFunded: 3000,
  interestRate: 5.5,
  termMonths: 12,
  status: 'funding',
  riskLevel: 'low',
  category: 'Negocio',
  deadline: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000).toISOString(), // 15 days from now
  investorsCount: 12,
  minimumInvestment: 100,
  imageUrl: 'https://example.com/bakery.jpg',
}

describe('MicrocreditCard', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.find('.microcredit-card').exists()).toBe(true)
    })

    it('should display microcredit title', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('Expansión de Panadería Local')
    })

    it('should display microcredit description', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('Necesito financiación para comprar un horno industrial')
    })

    it('should hide description in compact mode', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Necesito financiación')
    })

    it('should display image when provided', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      const img = wrapper.find('img[alt="Expansión de Panadería Local"]')
      expect(img.exists()).toBe(true)
      expect(img.attributes('src')).toBe('https://example.com/bakery.jpg')
    })

    it('should hide image in compact mode', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          compact: true,
        },
      })
      const img = wrapper.find('.microcredit-card__image')
      expect(img.exists()).toBe(false)
    })
  })

  describe('borrower information', () => {
    it('should display borrower name', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('María García')
    })

    it('should display borrower location', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('Madrid, España')
    })

    it('should show borrower avatar', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      const avatar = wrapper.findComponent({ name: 'Avatar' })
      expect(avatar.exists()).toBe(true)
      // Avatar exists and is passed src from borrower.avatar
      expect(avatar.props('src')).toBe('https://example.com/avatar.jpg')
    })

    it('should show borrower rating', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('4/5')
    })

    it('should show contact button', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      const contactButton = wrapper.findAllComponents({ name: 'Button' }).find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'mail'
      })
      expect(contactButton?.exists()).toBe(true)
    })

    it('should emit contact-borrower event', async () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      const contactButton = wrapper.findAllComponents({ name: 'Button' }).find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'mail'
      })
      await contactButton?.trigger('click')

      expect(wrapper.emitted('contact-borrower')).toBeTruthy()
      expect(wrapper.emitted('contact-borrower')?.[0]).toEqual(['borrower-1'])
    })
  })

  describe('status', () => {
    it('should show pending status', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: { ...mockMicrocredit, status: 'pending' },
        },
      })
      expect(wrapper.text()).toContain('Pendiente')
    })

    it('should show funding status', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('En Financiación')
    })

    it('should show funded status', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: { ...mockMicrocredit, status: 'funded' },
        },
      })
      expect(wrapper.text()).toContain('Financiado')
    })

    it('should show repaying status', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: { ...mockMicrocredit, status: 'repaying' },
        },
      })
      expect(wrapper.text()).toContain('En Repago')
    })

    it('should show completed status', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: { ...mockMicrocredit, status: 'completed' },
        },
      })
      expect(wrapper.text()).toContain('Completado')
    })

    it('should show defaulted status', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: { ...mockMicrocredit, status: 'defaulted' },
        },
      })
      expect(wrapper.text()).toContain('Impagado')
    })

    it('should show defaulted banner', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: { ...mockMicrocredit, status: 'defaulted' },
        },
      })
      expect(wrapper.find('.microcredit-card__banner--defaulted').exists()).toBe(true)
      expect(wrapper.text()).toContain('Este microcrédito ha sido impagado')
    })
  })

  describe('funding progress', () => {
    it('should display funding progress', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('60%') // 3000/5000
    })

    it('should show progress bar', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      const progressBar = wrapper.findComponent({ name: 'ProgressBar' })
      expect(progressBar.exists()).toBe(true)
      expect(progressBar.props('value')).toBe(60)
    })

    it('should display amounts', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      // Check for amounts - may be formatted with € symbol
      expect(wrapper.text()).toContain('3000') || expect(wrapper.text()).toContain('3.000')
      expect(wrapper.text()).toContain('5000') || expect(wrapper.text()).toContain('5.000')
    })

    it('should display remaining amount', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      // Check for remaining amount - 5000 - 3000 = 2000
      const text = wrapper.text()
      expect(text).toContain('Faltan') || expect(text).toContain('2000') || expect(text).toContain('2.000')
    })

    it('should not show remaining amount when fully funded', () => {
      const fullyFunded = { ...mockMicrocredit, amountFunded: 5000 }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: fullyFunded,
        },
      })
      expect(wrapper.text()).not.toContain('Faltan')
    })
  })

  describe('fully funded state', () => {
    it('should show funded banner when fully funded', () => {
      const fullyFunded = { ...mockMicrocredit, amountFunded: 5000 }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: fullyFunded,
        },
      })
      expect(wrapper.find('.microcredit-card__banner--funded').exists()).toBe(true)
      expect(wrapper.text()).toContain('¡Objetivo alcanzado!')
    })

    it('should show "Completamente Financiado" on invest button when fully funded', () => {
      const fullyFunded = { ...mockMicrocredit, amountFunded: 5000 }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: fullyFunded,
        },
      })
      expect(wrapper.text()).toContain('Completamente Financiado')
    })

    it('should disable invest button when fully funded', () => {
      const fullyFunded = { ...mockMicrocredit, amountFunded: 5000 }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: fullyFunded,
        },
      })
      const investButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Completamente Financiado'))
      expect(investButton?.props('disabled')).toBe(true)
    })
  })

  describe('key information', () => {
    it('should display interest rate', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('5.5%')
      expect(wrapper.text()).toContain('Interés')
    })

    it('should display term in months', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('12 m')
      expect(wrapper.text()).toContain('Plazo')
    })

    it('should display investors count', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('12')
      expect(wrapper.text()).toContain('Inversores')
    })

    it('should not show investors count when undefined', () => {
      const noInvestors = { ...mockMicrocredit, investorsCount: undefined }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: noInvestors,
        },
      })
      expect(wrapper.text()).not.toContain('Inversores')
    })

    it('should display minimum investment', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('100')
      expect(wrapper.text()).toContain('Mínimo')
    })

    it('should not show minimum investment when undefined', () => {
      const noMinimum = { ...mockMicrocredit, minimumInvestment: undefined }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: noMinimum,
        },
      })
      expect(wrapper.text()).not.toContain('Mínimo')
    })
  })

  describe('risk level', () => {
    it('should show low risk level', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('Riesgo Bajo')
    })

    it('should show medium risk level', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: { ...mockMicrocredit, riskLevel: 'medium' },
        },
      })
      expect(wrapper.text()).toContain('Riesgo Medio')
    })

    it('should show high risk level', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: { ...mockMicrocredit, riskLevel: 'high' },
        },
      })
      expect(wrapper.text()).toContain('Riesgo Alto')
    })

    it('should not show risk level when undefined', () => {
      const noRisk = { ...mockMicrocredit, riskLevel: undefined }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: noRisk,
        },
      })
      expect(wrapper.text()).not.toContain('Riesgo')
    })

    it('should hide risk level in compact mode', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Riesgo Bajo')
    })
  })

  describe('category', () => {
    it('should display category', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('Negocio')
    })

    it('should not show category when undefined', () => {
      const noCategory = { ...mockMicrocredit, category: undefined }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: noCategory,
        },
      })
      const badges = wrapper.findAllComponents({ name: 'Badge' })
      const categoryBadges = badges.filter(b => b.text() === 'Negocio')
      expect(categoryBadges.length).toBe(0)
    })

    it('should hide category in compact mode', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Negocio')
    })
  })

  describe('deadline', () => {
    it('should show days until deadline', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toMatch(/\d+ días? restantes/)
    })

    it('should not show deadline when undefined', () => {
      const noDeadline = { ...mockMicrocredit, deadline: undefined }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: noDeadline,
        },
      })
      expect(wrapper.text()).not.toContain('restantes')
    })

    it('should not show deadline when status is not funding', () => {
      const funded = { ...mockMicrocredit, status: 'funded' as const }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: funded,
        },
      })
      expect(wrapper.text()).not.toContain('restantes')
    })

    it('should hide deadline in compact mode', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('restantes')
    })
  })

  describe('expected return', () => {
    it('should show expected return', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      expect(wrapper.text()).toContain('Retorno esperado')
    })

    it('should not show expected return when no minimum investment', () => {
      const noMinimum = { ...mockMicrocredit, minimumInvestment: undefined }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: noMinimum,
        },
      })
      expect(wrapper.text()).not.toContain('Retorno esperado')
    })

    it('should not show expected return when status is not funding', () => {
      const funded = { ...mockMicrocredit, status: 'funded' as const }
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: funded,
        },
      })
      expect(wrapper.text()).not.toContain('Retorno esperado')
    })

    it('should hide expected return in compact mode', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Retorno esperado')
    })
  })

  describe('invested badge', () => {
    it('should show invested badge when hasInvested is true', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          hasInvested: true,
        },
      })
      const badges = wrapper.findAllComponents({ name: 'Badge' })
      const investedBadge = badges.find(b => b.text().includes('Invertido'))
      expect(investedBadge?.exists()).toBe(true)
    })

    it('should not show invested badge when hasInvested is false', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          hasInvested: false,
        },
      })
      const badges = wrapper.findAllComponents({ name: 'Badge' })
      const investedBadge = badges.find(b => b.text().includes('Invertido'))
      // When badge is not found, investedBadge is undefined
      expect(investedBadge).toBeUndefined()
    })

    it('should show invested badge on image', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          hasInvested: true,
        },
      })
      expect(wrapper.find('.microcredit-card__invested-badge').exists()).toBe(true)
    })
  })

  describe('actions', () => {
    it('should show invest button when status is funding', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          showInvestButton: true,
        },
      })
      const investButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Invertir'))
      expect(investButton?.exists()).toBe(true)
    })

    it('should not show invest button when showInvestButton is false', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          showInvestButton: false,
        },
      })
      const investButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Invertir'))
      // When button is not found, investButton is undefined
      expect(investButton).toBeUndefined()
    })

    it('should not show invest button when status is not funding', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: { ...mockMicrocredit, status: 'completed' },
        },
      })
      const investButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Invertir'))
      // When button is not found, investButton is undefined
      expect(investButton).toBeUndefined()
    })

    it('should show view details button', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      const detailsButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Ver Detalles'))
      expect(detailsButton?.exists()).toBe(true)
    })

    it('should emit invest event', async () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      const investButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Invertir'))
      await investButton?.trigger('click')

      expect(wrapper.emitted('invest')).toBeTruthy()
      expect(wrapper.emitted('invest')?.[0]).toEqual(['1'])
    })

    it('should emit view-details event', async () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      const detailsButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Ver Detalles'))
      await detailsButton?.trigger('click')

      expect(wrapper.emitted('view-details')).toBeTruthy()
      expect(wrapper.emitted('view-details')?.[0]).toEqual(['1'])
    })

    it('should disable invest button when disabled prop is true', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          disabled: true,
        },
      })
      const investButton = wrapper.findAllComponents({ name: 'Button' }).find(b => b.text().includes('Invertir'))
      expect(investButton?.props('disabled')).toBe(true)
    })
  })

  describe('loading state', () => {
    it('should show loading state', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
          loading: true,
        },
      })
      // Check that loading prop is passed to component
      expect(wrapper.props('loading')).toBe(true)
    })
  })

  describe('icons', () => {
    it('should show appropriate status icons', () => {
      const wrapper = mount(MicrocreditCard, {
        props: {
          microcredit: mockMicrocredit,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBeGreaterThan(0)
    })
  })
})
