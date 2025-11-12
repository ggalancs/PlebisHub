import { describe, it, expect, vi, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ProposalsList from './ProposalsList.vue'
import type { Proposal } from './ProposalCard.vue'

const mockProposals: Proposal[] = [
  {
    id: 1,
    title: 'Propuesta 1',
    description: 'Descripción de la propuesta 1',
    votes: 100,
    supportsCount: 200,
    hotness: 5000,
    createdAt: new Date('2025-01-01'),
    finishesAt: new Date('2025-04-01'),
    redditThreshold: true,
    supported: false,
    finished: false,
    discarded: false,
  },
  {
    id: 2,
    title: 'Propuesta 2',
    description: 'Descripción de la propuesta 2',
    votes: 50,
    supportsCount: 100,
    hotness: 3000,
    createdAt: new Date('2025-01-15'),
    finishesAt: new Date('2025-04-15'),
    redditThreshold: false,
    supported: false,
    finished: false,
    discarded: false,
  },
  {
    id: 3,
    title: 'Propuesta 3',
    description: 'Descripción de la propuesta 3',
    votes: 80,
    supportsCount: 150,
    hotness: 4000,
    createdAt: new Date('2025-01-10'),
    finishesAt: new Date('2025-04-10'),
    redditThreshold: false,
    supported: false,
    finished: true,
    discarded: false,
  },
  {
    id: 4,
    title: 'Propuesta 4',
    description: 'Descripción de la propuesta 4',
    votes: 10,
    supportsCount: 20,
    hotness: 500,
    createdAt: new Date('2025-01-20'),
    finishesAt: new Date('2025-04-20'),
    redditThreshold: false,
    supported: false,
    finished: false,
    discarded: true,
  },
]

describe('ProposalsList', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  describe('rendering', () => {
    it('should render list of proposals', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
        },
      })

      expect(wrapper.text()).toContain('Propuesta 1')
      expect(wrapper.text()).toContain('Propuesta 2')
    })

    it('should render search bar when searchable', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          searchable: true,
        },
      })

      expect(wrapper.findComponent({ name: 'SearchBar' }).exists()).toBe(true)
    })

    it('should not render search bar when not searchable', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          searchable: false,
        },
      })

      expect(wrapper.findComponent({ name: 'SearchBar' }).exists()).toBe(false)
    })

    it('should render filter dropdown when filterable', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          filterable: true,
        },
      })

      const dropdowns = wrapper.findAllComponents({ name: 'Dropdown' })
      expect(dropdowns.length).toBeGreaterThan(0)
    })

    it('should render sort dropdown when sortable', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          sortable: true,
        },
      })

      const dropdowns = wrapper.findAllComponents({ name: 'Dropdown' })
      expect(dropdowns.length).toBeGreaterThan(0)
    })

    it('should render pagination when showPagination is true', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: Array(20).fill(mockProposals[0]).map((p, i) => ({ ...p, id: i })),
          pageSize: 10,
          showPagination: true,
        },
      })

      expect(wrapper.findComponent({ name: 'Pagination' }).exists()).toBe(true)
    })

    it('should not render pagination when showPagination is false', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          showPagination: false,
        },
      })

      expect(wrapper.findComponent({ name: 'Pagination' }).exists()).toBe(false)
    })
  })

  describe('loading state', () => {
    it('should show spinner when loading', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          loading: true,
        },
      })

      expect(wrapper.findComponent({ name: 'Spinner' }).exists()).toBe(true)
    })

    it('should not show proposals when loading', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          loading: true,
        },
      })

      expect(wrapper.findAllComponents({ name: 'ProposalCard' })).toHaveLength(0)
    })

    it('should disable search when loading', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          loading: true,
          searchable: true,
        },
      })

      const searchBar = wrapper.findComponent({ name: 'SearchBar' })
      expect(searchBar.props('disabled')).toBe(true)
    })
  })

  describe('empty state', () => {
    it('should show empty state when no proposals', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: [],
        },
      })

      expect(wrapper.findComponent({ name: 'EmptyState' }).exists()).toBe(true)
    })

    it('should show custom empty message', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: [],
          emptyMessage: 'Custom empty message',
        },
      })

      expect(wrapper.text()).toContain('Custom empty message')
    })

    it('should show clear filters button when filters are active', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: [],
          searchable: true,
        },
      })

      // Simulate search
      const searchBar = wrapper.findComponent({ name: 'SearchBar' })
      await searchBar.vm.$emit('update:modelValue', 'test')
      await nextTick()
      vi.advanceTimersByTime(300)
      await nextTick()

      expect(wrapper.text()).toContain('Limpiar filtros')
    })
  })

  describe('client-side search', () => {
    it('should filter proposals by title', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
        },
      })

      const searchBar = wrapper.findComponent({ name: 'SearchBar' })
      await searchBar.vm.$emit('update:modelValue', 'Propuesta 1')
      await nextTick()
      vi.advanceTimersByTime(300)
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      expect(cards).toHaveLength(1)
      expect(cards[0].props('proposal').title).toBe('Propuesta 1')
    })

    it('should filter proposals by description', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
        },
      })

      const searchBar = wrapper.findComponent({ name: 'SearchBar' })
      await searchBar.vm.$emit('update:modelValue', 'propuesta 2')
      await nextTick()
      vi.advanceTimersByTime(300)
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      expect(cards).toHaveLength(1)
    })

    it('should be case insensitive', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
        },
      })

      const searchBar = wrapper.findComponent({ name: 'SearchBar' })
      await searchBar.vm.$emit('update:modelValue', 'PROPUESTA 1')
      await nextTick()
      vi.advanceTimersByTime(300)
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      expect(cards).toHaveLength(1)
    })

    it('should debounce search', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
        },
      })

      const searchBar = wrapper.findComponent({ name: 'SearchBar' })

      // Type rapidly
      await searchBar.vm.$emit('update:modelValue', 'P')
      await nextTick()
      await searchBar.vm.$emit('update:modelValue', 'Pr')
      await nextTick()
      await searchBar.vm.$emit('update:modelValue', 'Pro')
      await nextTick()

      // Should not filter yet
      let cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      expect(cards.length).toBeGreaterThan(1)

      // Wait for debounce
      vi.advanceTimersByTime(300)
      await nextTick()

      // Should filter now
      cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      expect(cards.length).toBeGreaterThan(0)
    })

    it('should emit search event', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'server',
        },
      })

      const searchBar = wrapper.findComponent({ name: 'SearchBar' })
      await searchBar.vm.$emit('update:modelValue', 'test')
      await nextTick()
      vi.advanceTimersByTime(300)
      await nextTick()

      expect(wrapper.emitted('search')).toBeTruthy()
      expect(wrapper.emitted('search')?.[0]).toEqual(['test'])
    })
  })

  describe('client-side filtering', () => {
    it('should filter active proposals', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
          filterable: true,
        },
      })

      const dropdown = wrapper.findAllComponents({ name: 'Dropdown' })[0]
      await dropdown.vm.$emit('update:modelValue', 'active')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      // Should show proposals 1 and 2 (not finished, not discarded)
      expect(cards.length).toBe(2)
    })

    it('should filter finished proposals', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
          filterable: true,
        },
      })

      const dropdown = wrapper.findAllComponents({ name: 'Dropdown' })[0]
      await dropdown.vm.$emit('update:modelValue', 'finished')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      expect(cards).toHaveLength(1)
      expect(cards[0].props('proposal').finished).toBe(true)
    })

    it('should filter threshold reached proposals', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
          filterable: true,
        },
      })

      const dropdown = wrapper.findAllComponents({ name: 'Dropdown' })[0]
      await dropdown.vm.$emit('update:modelValue', 'threshold')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      expect(cards).toHaveLength(1)
      expect(cards[0].props('proposal').redditThreshold).toBe(true)
    })

    it('should filter discarded proposals', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
          filterable: true,
        },
      })

      const dropdown = wrapper.findAllComponents({ name: 'Dropdown' })[0]
      await dropdown.vm.$emit('update:modelValue', 'discarded')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      expect(cards).toHaveLength(1)
      expect(cards[0].props('proposal').discarded).toBe(true)
    })

    it('should emit filter event', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          filterable: true,
        },
      })

      const dropdown = wrapper.findAllComponents({ name: 'Dropdown' })[0]
      await dropdown.vm.$emit('update:modelValue', 'active')

      expect(wrapper.emitted('filter')).toBeTruthy()
      expect(wrapper.emitted('filter')?.[0]).toEqual(['active'])
    })
  })

  describe('client-side sorting', () => {
    it('should sort by recent (default)', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
        },
      })

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      // Most recent first (id: 4, created 2025-01-20)
      expect(cards[0].props('proposal').id).toBe(4)
    })

    it('should sort by popular', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
          sortable: true,
        },
      })

      const dropdown = wrapper.findAllComponents({ name: 'Dropdown' })[1]
      await dropdown.vm.$emit('update:modelValue', 'popular')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      // Most supports first (id: 1, supportsCount: 200)
      expect(cards[0].props('proposal').id).toBe(1)
    })

    it('should sort by hot', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
          sortable: true,
        },
      })

      const dropdown = wrapper.findAllComponents({ name: 'Dropdown' })[1]
      await dropdown.vm.$emit('update:modelValue', 'hot')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      // Highest hotness first (id: 1, hotness: 5000)
      expect(cards[0].props('proposal').id).toBe(1)
    })

    it('should sort by time (oldest first)', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'client',
          sortable: true,
        },
      })

      const dropdown = wrapper.findAllComponents({ name: 'Dropdown' })[1]
      await dropdown.vm.$emit('update:modelValue', 'time')
      await nextTick()

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      // Oldest first (id: 1, created 2025-01-01)
      expect(cards[0].props('proposal').id).toBe(1)
    })

    it('should emit sort event', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          sortable: true,
        },
      })

      const dropdown = wrapper.findAllComponents({ name: 'Dropdown' })[1]
      await dropdown.vm.$emit('update:modelValue', 'popular')

      expect(wrapper.emitted('sort')).toBeTruthy()
      expect(wrapper.emitted('sort')?.[0]).toEqual(['popular'])
    })
  })

  describe('pagination', () => {
    it('should paginate proposals', () => {
      const manyProposals = Array(25)
        .fill(mockProposals[0])
        .map((p, i) => ({ ...p, id: i }))

      const wrapper = mount(ProposalsList, {
        props: {
          proposals: manyProposals,
          pageSize: 10,
          paginationType: 'client',
        },
      })

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      expect(cards).toHaveLength(10)
    })

    it('should show correct results count', () => {
      const manyProposals = Array(25)
        .fill(mockProposals[0])
        .map((p, i) => ({ ...p, id: i }))

      const wrapper = mount(ProposalsList, {
        props: {
          proposals: manyProposals,
          pageSize: 10,
          paginationType: 'client',
        },
      })

      expect(wrapper.text()).toContain('Mostrando 1-10 de 25 propuestas')
    })

    it('should emit page-change event', async () => {
      const manyProposals = Array(25)
        .fill(mockProposals[0])
        .map((p, i) => ({ ...p, id: i }))

      const wrapper = mount(ProposalsList, {
        props: {
          proposals: manyProposals,
          pageSize: 10,
          paginationType: 'client',
        },
      })

      const pagination = wrapper.findComponent({ name: 'Pagination' })
      await pagination.vm.$emit('page-change', 2)

      expect(wrapper.emitted('page-change')).toBeTruthy()
      expect(wrapper.emitted('page-change')?.[0]).toEqual([2])
    })

    it('should reset to page 1 when searching', async () => {
      const manyProposals = Array(25)
        .fill(mockProposals[0])
        .map((p, i) => ({ ...p, id: i, title: `Propuesta ${i}` }))

      const wrapper = mount(ProposalsList, {
        props: {
          proposals: manyProposals,
          pageSize: 10,
          paginationType: 'client',
        },
      })

      // Go to page 2
      const pagination = wrapper.findComponent({ name: 'Pagination' })
      await pagination.vm.$emit('page-change', 2)
      await nextTick()

      // Search
      const searchBar = wrapper.findComponent({ name: 'SearchBar' })
      await searchBar.vm.$emit('update:modelValue', 'test')
      await nextTick()
      vi.advanceTimersByTime(300)
      await nextTick()

      // Should be back on page 1
      expect(wrapper.text()).toContain('Mostrando 1-')
    })
  })

  describe('proposal card interactions', () => {
    it('should emit support event', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          isAuthenticated: true,
        },
      })

      const card = wrapper.findComponent({ name: 'ProposalCard' })
      await card.vm.$emit('support', 1)

      expect(wrapper.emitted('support')).toBeTruthy()
      expect(wrapper.emitted('support')?.[0]).toEqual([1])
    })

    it('should emit view event', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
        },
      })

      const card = wrapper.findComponent({ name: 'ProposalCard' })
      await card.vm.$emit('view', 1)

      expect(wrapper.emitted('view')).toBeTruthy()
      expect(wrapper.emitted('view')?.[0]).toEqual([1])
    })

    it('should show loading state on specific proposal', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          isAuthenticated: true,
        },
      })

      const card = wrapper.findComponent({ name: 'ProposalCard' })
      await card.vm.$emit('support', 1)
      await nextTick()

      expect(card.props('loadingSupport')).toBe(true)
    })
  })

  describe('server-side mode', () => {
    it('should not filter client-side in server mode', async () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          paginationType: 'server',
          total: 100,
        },
      })

      const dropdown = wrapper.findAllComponents({ name: 'Dropdown' })[0]
      await dropdown.vm.$emit('update:modelValue', 'active')
      await nextTick()

      // Should still show all proposals (server handles filtering)
      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      expect(cards).toHaveLength(mockProposals.length)
    })

    it('should use total prop for pagination', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals.slice(0, 2),
          paginationType: 'server',
          total: 100,
          pageSize: 10,
        },
      })

      expect(wrapper.text()).toContain('de 100 propuestas')
    })
  })

  describe('authentication', () => {
    it('should pass authentication status to cards', () => {
      const wrapper = mount(ProposalsList, {
        props: {
          proposals: mockProposals,
          isAuthenticated: true,
        },
      })

      const cards = wrapper.findAllComponents({ name: 'ProposalCard' })
      cards.forEach((card) => {
        expect(card.props('isAuthenticated')).toBe(true)
      })
    })
  })
})
