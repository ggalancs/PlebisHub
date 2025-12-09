import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ProposalsList from './ProposalsList.vue'
import type { Proposal } from './ProposalCard.vue'

// Generate mock proposals
const generateProposal = (id: number, overrides: Partial<Proposal> = {}): Proposal => ({
  id,
  title: `Propuesta ${id}: ${['Mejora del transporte', 'Espacios verdes', 'Reciclaje', 'Iluminación LED', 'Seguridad vial'][id % 5]}`,
  description: `Esta es una descripción detallada de la propuesta número ${id}. Lorem ipsum dolor sit amet, consectetur adipiscing elit.`,
  votes: Math.floor(Math.random() * 500),
  supportsCount: Math.floor(Math.random() * 1000),
  hotness: Math.floor(Math.random() * 20000),
  createdAt: new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000),
  finishesAt: new Date(Date.now() + Math.random() * 90 * 24 * 60 * 60 * 1000),
  redditThreshold: Math.random() > 0.7,
  supported: Math.random() > 0.8,
  finished: false,
  discarded: false,
  ...overrides,
})

const mockProposals: Proposal[] = Array.from({ length: 10 }, (_, i) => generateProposal(i + 1))

const meta = {
  title: 'Organisms/ProposalsList',
  component: ProposalsList,
  tags: ['autodocs'],
  argTypes: {
    loading: {
      control: 'boolean',
    },
    searchable: {
      control: 'boolean',
    },
    filterable: {
      control: 'boolean',
    },
    sortable: {
      control: 'boolean',
    },
    showPagination: {
      control: 'boolean',
    },
    paginationType: {
      control: 'select',
      options: ['client', 'server'],
    },
    isAuthenticated: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof ProposalsList>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    proposals: mockProposals.slice(0, 5),
    isAuthenticated: true,
  },
}

export const WithSearch: Story = {
  args: {
    proposals: mockProposals,
    searchable: true,
    isAuthenticated: true,
  },
}

export const WithFilters: Story = {
  args: {
    proposals: [
      ...mockProposals.slice(0, 3),
      generateProposal(11, { finished: true }),
      generateProposal(12, { discarded: true }),
      generateProposal(13, { redditThreshold: true }),
    ],
    filterable: true,
    isAuthenticated: true,
  },
}

export const WithSorting: Story = {
  args: {
    proposals: mockProposals,
    sortable: true,
    isAuthenticated: true,
  },
}

export const WithPagination: Story = {
  args: {
    proposals: Array.from({ length: 25 }, (_, i) => generateProposal(i + 1)),
    pageSize: 5,
    showPagination: true,
    paginationType: 'client',
    isAuthenticated: true,
  },
}

export const Loading: Story = {
  args: {
    proposals: mockProposals,
    loading: true,
  },
}

export const Empty: Story = {
  args: {
    proposals: [],
  },
}

export const EmptyWithCustomMessage: Story = {
  args: {
    proposals: [],
    emptyMessage: 'No hay propuestas disponibles',
    emptyDescription: 'Actualmente no hay propuestas que cumplan con los criterios seleccionados.',
  },
}

export const LargeList: Story = {
  args: {
    proposals: Array.from({ length: 50 }, (_, i) => generateProposal(i + 1)),
    pageSize: 10,
    showPagination: true,
    searchable: true,
    filterable: true,
    sortable: true,
    isAuthenticated: true,
  },
}

export const NotAuthenticated: Story = {
  args: {
    proposals: mockProposals.slice(0, 5),
    isAuthenticated: false,
  },
}

export const MixedStates: Story = {
  args: {
    proposals: [
      generateProposal(1, { redditThreshold: true }),
      generateProposal(2, { finished: true }),
      generateProposal(3, { discarded: true }),
      generateProposal(4, {}),
      generateProposal(5, { supported: true, redditThreshold: true }),
    ],
    isAuthenticated: true,
  },
}

export const ServerSideMode: Story = {
  render: () => ({
    components: { ProposalsList },
    setup() {
      const currentPage = ref(1)
      const proposals = ref(mockProposals.slice(0, 10))
      const loading = ref(false)

      const handlePageChange = async (page: number) => {
        loading.value = true
        currentPage.value = page

        // Simulate API call
        await new Promise((resolve) => setTimeout(resolve, 1000))

        // Update proposals
        const start = (page - 1) * 10
        proposals.value = Array.from({ length: 10 }, (_, i) =>
          generateProposal(start + i + 1)
        )

        loading.value = false
      }

      const handleSearch = async (query: string) => {
        console.log('Search:', query)
        loading.value = true
        await new Promise((resolve) => setTimeout(resolve, 500))
        loading.value = false
      }

      const handleFilter = async (filter: string) => {
        console.log('Filter:', filter)
        loading.value = true
        await new Promise((resolve) => setTimeout(resolve, 500))
        loading.value = false
      }

      const handleSort = async (sort: string) => {
        console.log('Sort:', sort)
        loading.value = true
        await new Promise((resolve) => setTimeout(resolve, 500))
        loading.value = false
      }

      return {
        proposals,
        currentPage,
        loading,
        handlePageChange,
        handleSearch,
        handleFilter,
        handleSort,
      }
    },
    template: `
      <div class="p-4">
        <h2 class="text-2xl font-bold mb-4">Server-Side Pagination Demo</h2>
        <p class="text-sm text-gray-600 mb-6">
          Los cambios de página, búsqueda, filtros y ordenamiento simulan llamadas a API
        </p>
        <ProposalsList
          :proposals="proposals"
          :current-page="currentPage"
          :total="100"
          :page-size="10"
          :loading="loading"
          pagination-type="server"
          :is-authenticated="true"
          @page-change="handlePageChange"
          @search="handleSearch"
          @filter="handleFilter"
          @sort="handleSort"
        />
      </div>
    `,
  }),
  args: {},
}

export const Interactive: Story = {
  render: () => ({
    components: { ProposalsList },
    setup() {
      const proposals = ref(mockProposals)

      const handleSupport = (id: number | string) => {
        console.log('Supporting proposal:', id)
        // Update the proposal
        const proposal = proposals.value.find((p) => p.id === id)
        if (proposal) {
          proposal.supported = true
          proposal.supportsCount++
        }
      }

      const handleView = (id: number | string) => {
        alert(`Ver detalles de propuesta #${id}`)
      }

      const handlePageChange = (page: number) => {
        console.log('Page changed to:', page)
      }

      const handleSearch = (query: string) => {
        console.log('Search query:', query)
      }

      const handleFilter = (filter: string) => {
        console.log('Filter:', filter)
      }

      const handleSort = (sort: string) => {
        console.log('Sort:', sort)
      }

      return {
        proposals,
        handleSupport,
        handleView,
        handlePageChange,
        handleSearch,
        handleFilter,
        handleSort,
      }
    },
    template: `
      <div class="p-4">
        <ProposalsList
          :proposals="proposals"
          :is-authenticated="true"
          @support="handleSupport"
          @view="handleView"
          @page-change="handlePageChange"
          @search="handleSearch"
          @filter="handleFilter"
          @sort="handleSort"
        />
        <div class="mt-6 p-4 bg-gray-100 rounded">
          <p class="text-sm font-medium">Eventos:</p>
          <p class="text-xs text-gray-600 mt-1">Abre la consola para ver los eventos emitidos</p>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const WithoutControls: Story = {
  args: {
    proposals: mockProposals.slice(0, 5),
    searchable: false,
    filterable: false,
    sortable: false,
    showPagination: false,
    isAuthenticated: true,
  },
}

export const OnlySearch: Story = {
  args: {
    proposals: mockProposals,
    searchable: true,
    filterable: false,
    sortable: false,
    showPagination: false,
    isAuthenticated: true,
  },
}

export const OnlyFilters: Story = {
  args: {
    proposals: [
      ...mockProposals.slice(0, 3),
      generateProposal(11, { finished: true }),
      generateProposal(12, { discarded: true }),
      generateProposal(13, { redditThreshold: true }),
    ],
    searchable: false,
    filterable: true,
    sortable: false,
    showPagination: false,
    isAuthenticated: true,
  },
}

export const ResponsiveGrid: Story = {
  render: () => ({
    components: { ProposalsList },
    setup() {
      return { proposals: mockProposals.slice(0, 6) }
    },
    template: `
      <div class="p-4">
        <h2 class="text-2xl font-bold mb-6">Lista Responsive</h2>
        <p class="text-sm text-gray-600 mb-6">
          Redimensiona el navegador para ver cómo se adapta el grid
        </p>
        <ProposalsList
          :proposals="proposals"
          :is-authenticated="true"
        />
      </div>
    `,
  }),
  args: {},
}
