import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import MicrocreditList from './MicrocreditList.vue'
import type { Microcredit } from './MicrocreditCard.vue'

const mockMicrocredits: Microcredit[] = [
  {
    id: '1',
    title: 'Expansión de Panadería',
    description: 'Necesito financiación para horno industrial',
    borrower: {
      id: 'b1',
      name: 'María García',
      location: 'Madrid',
    },
    amountRequested: 5000,
    amountFunded: 3000,
    interestRate: 5.5,
    termMonths: 12,
    status: 'funding',
    riskLevel: 'low',
    category: 'Negocio',
    deadline: '2025-12-31',
  },
  {
    id: '2',
    title: 'Taller de Bicicletas',
    description: 'Equipamiento para taller de reparación',
    borrower: {
      id: 'b2',
      name: 'Carlos Ruiz',
      location: 'Barcelona',
    },
    amountRequested: 3000,
    amountFunded: 2100,
    interestRate: 6,
    termMonths: 12,
    status: 'funding',
    riskLevel: 'medium',
    category: 'Ecología',
    deadline: '2025-11-30',
  },
  {
    id: '3',
    title: 'Huerto Urbano',
    description: 'Materiales para huerto urbano',
    borrower: {
      id: 'b3',
      name: 'Ana López',
      location: 'Valencia',
    },
    amountRequested: 2000,
    amountFunded: 2000,
    interestRate: 5,
    termMonths: 10,
    status: 'funded',
    riskLevel: 'low',
    category: 'Agricultura',
  },
]

describe('MicrocreditList', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.find('.microcredit-list').exists()).toBe(true)
    })

    it('should display all microcredits', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards.length).toBe(3)
    })

    it('should display results count', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      expect(wrapper.text()).toContain('3 microcréditos')
    })

    it('should show singular form for one result', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: [mockMicrocredits[0]],
        },
      })
      expect(wrapper.text()).toContain('1 microcrédito')
    })
  })

  describe('search', () => {
    it('should show search input when showSearch is true', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          showSearch: true,
        },
      })
      const searchInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Buscar')
      )
      expect(searchInput?.exists()).toBe(true)
    })

    it('should hide search input when showSearch is false', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          showSearch: false,
        },
      })
      const searchInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Buscar')
      )
      expect(searchInput?.exists()).toBe(false)
    })

    it('should filter microcredits by search query', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const searchInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Buscar')
      )
      await searchInput?.setValue('Panadería')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards.length).toBe(1)
      expect(wrapper.text()).toContain('1 microcrédito')
    })

    it('should search in title, description, borrower name, and category', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const searchInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Buscar')
      )

      // Search by borrower name
      await searchInput?.setValue('María')
      await nextTick()
      let cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards.length).toBe(1)

      // Search by category
      await searchInput?.setValue('Ecología')
      await nextTick()
      cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards.length).toBe(1)
    })
  })

  describe('filters', () => {
    it('should show filters when showFilters is true', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          showFilters: true,
        },
      })
      const selects = wrapper.findAllComponents({ name: 'Select' })
      expect(selects.length).toBeGreaterThan(0)
    })

    it('should hide filters when showFilters is false', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          showFilters: false,
          showSort: false,
        },
      })
      const selects = wrapper.findAllComponents({ name: 'Select' })
      expect(selects.length).toBe(0)
    })

    it('should filter by status', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const statusSelect = wrapper.findAllComponents({ name: 'Select' })[0]
      await statusSelect.setValue('funded')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards.length).toBe(1)
    })

    it('should filter by risk level', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const riskSelect = wrapper.findAllComponents({ name: 'Select' })[1]
      await riskSelect.setValue('low')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards.length).toBe(2)
    })

    it('should filter by category', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const categorySelect = wrapper.findAllComponents({ name: 'Select' })[2]
      await categorySelect.setValue('Ecología')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards.length).toBe(1)
    })

    it('should show clear filters button when filters are active', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const searchInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Buscar')
      )
      await searchInput?.setValue('test')
      await nextTick()

      const clearButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Limpiar Filtros')
      )
      expect(clearButton?.exists()).toBe(true)
    })

    it('should clear all filters when clear button is clicked', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const searchInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Buscar')
      )
      await searchInput?.setValue('test')
      await nextTick()

      const clearButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Limpiar Filtros')
      )
      await clearButton?.trigger('click')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards.length).toBe(3)
    })
  })

  describe('sorting', () => {
    it('should show sort select when showSort is true', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          showSort: true,
        },
      })
      expect(wrapper.text()).toContain('Más Recientes')
    })

    it('should sort by amount (high to low)', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const sortSelect = wrapper.findAllComponents({ name: 'Select' }).find(
        s => s.props('options')?.some((o: any) => o.value === 'amount-high')
      )
      await sortSelect?.setValue('amount-high')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards[0].props('microcredit').amountRequested).toBe(5000)
    })

    it('should sort by amount (low to high)', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const sortSelect = wrapper.findAllComponents({ name: 'Select' }).find(
        s => s.props('options')?.some((o: any) => o.value === 'amount-low')
      )
      await sortSelect?.setValue('amount-low')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards[0].props('microcredit').amountRequested).toBe(2000)
    })

    it('should sort by interest (high to low)', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const sortSelect = wrapper.findAllComponents({ name: 'Select' }).find(
        s => s.props('options')?.some((o: any) => o.value === 'interest-high')
      )
      await sortSelect?.setValue('interest-high')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards[0].props('microcredit').interestRate).toBe(6)
    })

    it('should sort by interest (low to high)', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const sortSelect = wrapper.findAllComponents({ name: 'Select' }).find(
        s => s.props('options')?.some((o: any) => o.value === 'interest-low')
      )
      await sortSelect?.setValue('interest-low')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards[0].props('microcredit').interestRate).toBe(5)
    })
  })

  describe('pagination', () => {
    const manyMicrocredits = Array(25).fill(null).map((_, i) => ({
      ...mockMicrocredits[0],
      id: `mc-${i}`,
      title: `Microcrédito ${i + 1}`,
    }))

    it('should show pagination when enabled', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: manyMicrocredits,
          showPagination: true,
        },
      })
      const paginationButtons = wrapper.findAllComponents({ name: 'Button' }).filter(
        b => b.text() === '1' || b.text() === '2'
      )
      expect(paginationButtons.length).toBeGreaterThan(0)
    })

    it('should hide pagination when disabled', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: manyMicrocredits,
          showPagination: false,
        },
      })
      const paginationButtons = wrapper.findAllComponents({ name: 'Button' }).filter(
        b => b.text() === '1' || b.text() === '2'
      )
      expect(paginationButtons.length).toBe(0)
    })

    it('should display items per page', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: manyMicrocredits,
          itemsPerPage: 10,
        },
      })
      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards.length).toBe(10)
    })

    it('should change page when pagination button is clicked', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: manyMicrocredits,
          itemsPerPage: 10,
        },
      })

      const page2Button = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text() === '2'
      )
      await page2Button?.trigger('click')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards[0].props('microcredit').title).toBe('Microcrédito 11')
    })

    it('should disable previous button on first page', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: manyMicrocredits,
        },
      })
      const prevButton = wrapper.findAllComponents({ name: 'Button' }).find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'chevron-left'
      })
      expect(prevButton?.props('disabled')).toBe(true)
    })

    it('should disable next button on last page', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: manyMicrocredits,
          itemsPerPage: 10,
        },
      })

      const page3Button = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text() === '3'
      )
      await page3Button?.trigger('click')
      await nextTick()

      const nextButton = wrapper.findAllComponents({ name: 'Button' }).find(b => {
        const icon = b.findComponent({ name: 'Icon' })
        return icon.exists() && icon.props('name') === 'chevron-right'
      })
      expect(nextButton?.props('disabled')).toBe(true)
    })
  })

  describe('empty state', () => {
    it('should show empty state when no microcredits', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: [],
        },
      })
      expect(wrapper.text()).toContain('No hay microcréditos disponibles')
    })

    it('should show empty state when filtered results are empty', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const searchInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Buscar')
      )
      await searchInput?.setValue('nonexistent')
      await nextTick()

      expect(wrapper.text()).toContain('No se encontraron microcréditos')
    })

    it('should show clear filters button in empty state', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })

      const searchInput = wrapper.findAllComponents({ name: 'Input' }).find(
        i => i.props('placeholder')?.includes('Buscar')
      )
      await searchInput?.setValue('nonexistent')
      await nextTick()

      const clearButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Limpiar Filtros')
      )
      expect(clearButton?.exists()).toBe(true)
    })
  })

  describe('loading state', () => {
    it('should show loading cards when loading', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: [],
          loading: true,
        },
      })
      const loadingCards = wrapper.findAllComponents({ name: 'Card' }).filter(
        c => c.props('loading') === true
      )
      expect(loadingCards.length).toBeGreaterThan(0)
    })

    it('should hide pagination when loading', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          loading: true,
        },
      })
      const paginationButtons = wrapper.findAllComponents({ name: 'Button' }).filter(
        b => b.text() === '1' || b.text() === '2'
      )
      expect(paginationButtons.length).toBe(0)
    })
  })

  describe('invested microcredits', () => {
    it('should mark microcredits as invested', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          investedIds: ['1'],
        },
      })
      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      expect(cards[0].props('hasInvested')).toBe(true)
      expect(cards[1].props('hasInvested')).toBe(false)
    })
  })

  describe('compact mode', () => {
    it('should render cards in compact mode', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          compactCards: true,
        },
      })
      const cards = wrapper.findAllComponents({ name: 'MicrocreditCard' })
      cards.forEach(card => {
        expect(card.props('compact')).toBe(true)
      })
    })
  })

  describe('events', () => {
    it('should emit invest event', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      const card = wrapper.findComponent({ name: 'MicrocreditCard' })
      await card.vm.$emit('invest', '1')

      expect(wrapper.emitted('invest')).toBeTruthy()
      expect(wrapper.emitted('invest')?.[0]).toEqual(['1'])
    })

    it('should emit view-details event', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      const card = wrapper.findComponent({ name: 'MicrocreditCard' })
      await card.vm.$emit('view-details', '1')

      expect(wrapper.emitted('view-details')).toBeTruthy()
      expect(wrapper.emitted('view-details')?.[0]).toEqual(['1'])
    })

    it('should emit contact-borrower event', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
        },
      })
      const card = wrapper.findComponent({ name: 'MicrocreditCard' })
      await card.vm.$emit('contact-borrower', 'b1')

      expect(wrapper.emitted('contact-borrower')).toBeTruthy()
      expect(wrapper.emitted('contact-borrower')?.[0]).toEqual(['b1'])
    })

    it('should emit load-more event', async () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          showPagination: false,
        },
      })
      const loadMoreButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Cargar Más')
      )
      await loadMoreButton?.trigger('click')

      expect(wrapper.emitted('load-more')).toBeTruthy()
    })
  })

  describe('load more button', () => {
    it('should show load more button when pagination is disabled', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          showPagination: false,
        },
      })
      const loadMoreButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Cargar Más')
      )
      expect(loadMoreButton?.exists()).toBe(true)
    })

    it('should hide load more button when pagination is enabled', () => {
      const wrapper = mount(MicrocreditList, {
        props: {
          microcredits: mockMicrocredits,
          showPagination: true,
        },
      })
      const loadMoreButton = wrapper.findAllComponents({ name: 'Button' }).find(
        b => b.text().includes('Cargar Más')
      )
      expect(loadMoreButton?.exists()).toBe(false)
    })
  })
})
