import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import MicrocreditList from './MicrocreditList.vue'
import type { Microcredit } from './MicrocreditCard.vue'

const meta = {
  title: 'Organisms/MicrocreditList',
  component: MicrocreditList,
  tags: ['autodocs'],
  argTypes: {
    microcredits: {
      control: 'object',
      description: 'List of microcredits',
    },
    loading: {
      control: 'boolean',
      description: 'Loading state',
    },
    showFilters: {
      control: 'boolean',
      description: 'Show filters',
    },
    showSearch: {
      control: 'boolean',
      description: 'Show search',
    },
    showSort: {
      control: 'boolean',
      description: 'Show sort',
    },
    compactCards: {
      control: 'boolean',
      description: 'Compact card mode',
    },
    itemsPerPage: {
      control: 'number',
      description: 'Items per page',
    },
    showPagination: {
      control: 'boolean',
      description: 'Show pagination',
    },
    investedIds: {
      control: 'array',
      description: 'User invested microcredit IDs',
    },
  },
} satisfies Meta<typeof MicrocreditList>

export default meta
type Story = StoryObj<typeof meta>

const mockMicrocredits: Microcredit[] = [
  {
    id: '1',
    title: 'Expansión de Panadería Local',
    description: 'Necesito financiación para comprar un horno industrial',
    borrower: {
      id: 'b1',
      name: 'María García',
      avatar: 'https://i.pravatar.cc/150?img=1',
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
    deadline: '2025-12-31',
    investorsCount: 12,
    minimumInvestment: 100,
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&h=400&fit=crop',
  },
  {
    id: '2',
    title: 'Taller de Reparación de Bicicletas',
    description: 'Equipamiento para taller de reparación de bicicletas',
    borrower: {
      id: 'b2',
      name: 'Carlos Ruiz',
      avatar: 'https://i.pravatar.cc/150?img=12',
      location: 'Barcelona, España',
      rating: 5,
    },
    amountRequested: 3000,
    amountFunded: 2100,
    interestRate: 6,
    termMonths: 12,
    status: 'funding',
    riskLevel: 'medium',
    category: 'Ecología',
    deadline: '2025-11-30',
    investorsCount: 8,
    minimumInvestment: 100,
    imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=800&h=400&fit=crop',
  },
  {
    id: '3',
    title: 'Huerto Urbano Cooperativo',
    description: 'Materiales y herramientas para huerto urbano',
    borrower: {
      id: 'b3',
      name: 'Ana López',
      avatar: 'https://i.pravatar.cc/150?img=5',
      location: 'Valencia, España',
      rating: 4,
    },
    amountRequested: 2000,
    amountFunded: 2000,
    interestRate: 5,
    termMonths: 10,
    status: 'funded',
    riskLevel: 'low',
    category: 'Agricultura',
    investorsCount: 15,
    minimumInvestment: 25,
  },
  {
    id: '4',
    title: 'Cafetería Comunitaria',
    description: 'Abrir cafetería que emplee personas en riesgo',
    borrower: {
      id: 'b4',
      name: 'Pedro Martínez',
      avatar: 'https://i.pravatar.cc/150?img=8',
      location: 'Sevilla, España',
      rating: 5,
    },
    amountRequested: 8000,
    amountFunded: 6000,
    interestRate: 4.5,
    termMonths: 18,
    status: 'funding',
    riskLevel: 'low',
    category: 'Social',
    investorsCount: 25,
    minimumInvestment: 50,
    imageUrl: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?w=800&h=400&fit=crop',
  },
  {
    id: '5',
    title: 'Librería Independiente',
    description: 'Expansión de librería local con enfoque en autores locales',
    borrower: {
      id: 'b5',
      name: 'Laura Sánchez',
      avatar: 'https://i.pravatar.cc/150?img=9',
      location: 'Bilbao, España',
      rating: 4,
    },
    amountRequested: 10000,
    amountFunded: 2000,
    interestRate: 7,
    termMonths: 24,
    status: 'funding',
    riskLevel: 'high',
    category: 'Cultura',
    investorsCount: 5,
    minimumInvestment: 200,
    imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&h=400&fit=crop',
  },
  {
    id: '6',
    title: 'Escuela de Yoga',
    description: 'Equipamiento para escuela de yoga y bienestar',
    borrower: {
      id: 'b6',
      name: 'Julia Fernández',
      avatar: 'https://i.pravatar.cc/150?img=10',
      location: 'Málaga, España',
      rating: 5,
    },
    amountRequested: 4000,
    amountFunded: 4000,
    interestRate: 5,
    termMonths: 12,
    status: 'repaying',
    riskLevel: 'medium',
    category: 'Salud',
    investorsCount: 20,
    minimumInvestment: 75,
  },
]

export const Default: Story = {
  args: {
    microcredits: mockMicrocredits,
  },
}

export const Loading: Story = {
  args: {
    microcredits: [],
    loading: true,
  },
}

export const Empty: Story = {
  args: {
    microcredits: [],
  },
}

export const SingleItem: Story = {
  args: {
    microcredits: [mockMicrocredits[0]],
  },
}

export const ThreeItems: Story = {
  args: {
    microcredits: mockMicrocredits.slice(0, 3),
  },
}

export const ManyItems: Story = {
  args: {
    microcredits: Array(25).fill(null).map((_, i) => ({
      ...mockMicrocredits[i % mockMicrocredits.length],
      id: `mc-${i}`,
      title: `${mockMicrocredits[i % mockMicrocredits.length].title} ${i + 1}`,
    })),
  },
}

export const WithInvestments: Story = {
  args: {
    microcredits: mockMicrocredits,
    investedIds: ['1', '3'],
  },
}

export const NoFilters: Story = {
  args: {
    microcredits: mockMicrocredits,
    showFilters: false,
  },
}

export const NoSearch: Story = {
  args: {
    microcredits: mockMicrocredits,
    showSearch: false,
  },
}

export const NoSort: Story = {
  args: {
    microcredits: mockMicrocredits,
    showSort: false,
  },
}

export const MinimalControls: Story = {
  args: {
    microcredits: mockMicrocredits,
    showFilters: false,
    showSearch: false,
    showSort: false,
  },
}

export const CompactCards: Story = {
  args: {
    microcredits: mockMicrocredits,
    compactCards: true,
  },
}

export const NoPagination: Story = {
  args: {
    microcredits: mockMicrocredits,
    showPagination: false,
  },
}

export const CustomItemsPerPage: Story = {
  args: {
    microcredits: mockMicrocredits,
    itemsPerPage: 3,
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      const microcredits = ref<Microcredit[]>([...mockMicrocredits])
      const investedIds = ref<string[]>([])
      const loading = ref(false)

      const handleInvest = (microcreditId: string) => {
        console.log('Investing in:', microcreditId)
        if (!investedIds.value.includes(microcreditId)) {
          investedIds.value.push(microcreditId)

          // Update funded amount
          const mc = microcredits.value.find(m => m.id === microcreditId)
          if (mc) {
            mc.amountFunded += 500
            mc.investorsCount = (mc.investorsCount || 0) + 1

            if (mc.amountFunded >= mc.amountRequested) {
              mc.status = 'funded'
            }
          }

          alert(`¡Has invertido en el microcrédito!`)
        }
      }

      const handleViewDetails = (microcreditId: string) => {
        console.log('Viewing details:', microcreditId)
        alert('Abriendo detalles del microcrédito...')
      }

      const handleContactBorrower = (borrowerId: string) => {
        console.log('Contacting borrower:', borrowerId)
        alert('Enviando mensaje al prestatario...')
      }

      const handleLoadMore = () => {
        console.log('Loading more...')
        loading.value = true
        setTimeout(() => {
          loading.value = false
          alert('Más microcréditos cargados')
        }, 1000)
      }

      return {
        microcredits,
        investedIds,
        loading,
        handleInvest,
        handleViewDetails,
        handleContactBorrower,
        handleLoadMore,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Lista Interactiva de Microcréditos</h2>
        <p class="text-sm text-gray-600 mb-6">
          Invierte en microcréditos haciendo clic en "Invertir Ahora"
        </p>
        <MicrocreditList
          :microcredits="microcredits"
          :invested-ids="investedIds"
          :loading="loading"
          @invest="handleInvest"
          @view-details="handleViewDetails"
          @contact-borrower="handleContactBorrower"
          @load-more="handleLoadMore"
        />
      </div>
    `,
  }),
  args: {},
}

export const FilteringDemo: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      return { mockMicrocredits }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Demo de Filtrado</h2>
        <p class="text-sm text-gray-600 mb-6">
          Usa los filtros para buscar microcréditos específicos
        </p>
        <MicrocreditList :microcredits="mockMicrocredits" />
      </div>
    `,
  }),
  args: {},
}

export const SortingDemo: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      return { mockMicrocredits }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Demo de Ordenamiento</h2>
        <p class="text-sm text-gray-600 mb-6">
          Cambia el ordenamiento para ver diferentes resultados
        </p>
        <MicrocreditList :microcredits="mockMicrocredits" />
      </div>
    `,
  }),
  args: {},
}

export const PaginationDemo: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      const manyMicrocredits = Array(25).fill(null).map((_, i) => ({
        ...mockMicrocredits[i % mockMicrocredits.length],
        id: `mc-${i}`,
        title: `${mockMicrocredits[i % mockMicrocredits.length].title} ${i + 1}`,
      }))
      return { manyMicrocredits }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Demo de Paginación</h2>
        <p class="text-sm text-gray-600 mb-6">
          Navega entre las páginas para ver más microcréditos
        </p>
        <MicrocreditList :microcredits="manyMicrocredits" :items-per-page="6" />
      </div>
    `,
  }),
  args: {},
}

export const SearchDemo: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      return { mockMicrocredits }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Demo de Búsqueda</h2>
        <p class="text-sm text-gray-600 mb-6">
          Busca microcréditos por título, descripción, prestatario o categoría
        </p>
        <MicrocreditList :microcredits="mockMicrocredits" />
      </div>
    `,
  }),
  args: {},
}

export const ByStatus: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      const statuses = [
        { label: 'En Financiación', microcredits: mockMicrocredits.filter(m => m.status === 'funding') },
        { label: 'Financiados', microcredits: mockMicrocredits.filter(m => m.status === 'funded') },
        { label: 'En Repago', microcredits: mockMicrocredits.filter(m => m.status === 'repaying') },
      ]
      return { statuses }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Microcréditos por Estado</h2>
        <div class="space-y-8">
          <div v-for="status in statuses" :key="status.label">
            <h3 class="text-lg font-semibold mb-4">{{ status.label }}</h3>
            <MicrocreditList
              :microcredits="status.microcredits"
              :show-filters="false"
              :show-pagination="false"
              compact-cards
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const ByCategory: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      const categories = [
        { label: 'Negocio', microcredits: mockMicrocredits.filter(m => m.category === 'Negocio') },
        { label: 'Social', microcredits: mockMicrocredits.filter(m => m.category === 'Social') },
        { label: 'Ecología', microcredits: mockMicrocredits.filter(m => m.category === 'Ecología') },
      ]
      return { categories }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Microcréditos por Categoría</h2>
        <div class="space-y-8">
          <div v-for="category in categories" :key="category.label">
            <h3 class="text-lg font-semibold mb-4">{{ category.label }}</h3>
            <MicrocreditList
              :microcredits="category.microcredits"
              :show-filters="false"
              :show-pagination="false"
              compact-cards
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const ByRiskLevel: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      const riskLevels = [
        { label: 'Riesgo Bajo', microcredits: mockMicrocredits.filter(m => m.riskLevel === 'low') },
        { label: 'Riesgo Medio', microcredits: mockMicrocredits.filter(m => m.riskLevel === 'medium') },
        { label: 'Riesgo Alto', microcredits: mockMicrocredits.filter(m => m.riskLevel === 'high') },
      ]
      return { riskLevels }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Microcréditos por Nivel de Riesgo</h2>
        <div class="space-y-8">
          <div v-for="riskLevel in riskLevels" :key="riskLevel.label">
            <h3 class="text-lg font-semibold mb-4">{{ riskLevel.label }}</h3>
            <MicrocreditList
              :microcredits="riskLevel.microcredits"
              :show-filters="false"
              :show-pagination="false"
              compact-cards
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      return { mockMicrocredits }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <MicrocreditList
            :microcredits="mockMicrocredits.slice(0, 3)"
            :items-per-page="3"
            compact-cards
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const EmptyWithFilters: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      return { mockMicrocredits }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Estado Vacío con Filtros</h2>
        <p class="text-sm text-gray-600 mb-6">
          Busca algo que no exista para ver el estado vacío con la opción de limpiar filtros
        </p>
        <MicrocreditList :microcredits="mockMicrocredits" />
      </div>
    `,
  }),
  args: {},
}

export const LoadingState: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      const loading = ref(true)
      setTimeout(() => {
        loading.value = false
      }, 3000)
      return { mockMicrocredits, loading }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Estado de Carga</h2>
        <p class="text-sm text-gray-600 mb-6">
          La lista mostrará el estado de carga durante 3 segundos
        </p>
        <MicrocreditList :microcredits="mockMicrocredits" :loading="loading" />
      </div>
    `,
  }),
  args: {},
}

export const InfiniteScroll: Story = {
  render: (args) => ({
    components: { MicrocreditList },
    setup() {
      const microcredits = ref<Microcredit[]>([...mockMicrocredits.slice(0, 6)])
      const loading = ref(false)

      const handleLoadMore = () => {
        loading.value = true
        setTimeout(() => {
          const newItems = Array(3).fill(null).map((_, i) => ({
            ...mockMicrocredits[i % mockMicrocredits.length],
            id: `mc-${microcredits.value.length + i}`,
            title: `${mockMicrocredits[i % mockMicrocredits.length].title} ${microcredits.value.length + i + 1}`,
          }))
          microcredits.value.push(...newItems)
          loading.value = false
        }, 1000)
      }

      return {
        microcredits,
        loading,
        handleLoadMore,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Scroll Infinito</h2>
        <p class="text-sm text-gray-600 mb-6">
          Haz clic en "Cargar Más" para agregar más microcréditos a la lista
        </p>
        <MicrocreditList
          :microcredits="microcredits"
          :loading="loading"
          :show-pagination="false"
          @load-more="handleLoadMore"
        />
      </div>
    `,
  }),
  args: {},
}
