import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ImpulsaProjectsList from './ImpulsaProjectsList.vue'
import type { ImpulsaProject } from './ImpulsaProjectCard.vue'

interface ProjectFilters {
  status?: string
  category?: string
  search?: string
}

const meta = {
  title: 'Organisms/ImpulsaProjectsList',
  component: ImpulsaProjectsList,
  tags: ['autodocs'],
  argTypes: {
    projects: {
      control: 'object',
      description: 'Array of projects to display',
    },
    loading: {
      control: 'boolean',
      description: 'Loading state',
    },
    compact: {
      control: 'boolean',
      description: 'Compact card display',
    },
    showFilters: {
      control: 'boolean',
      description: 'Show filter options',
    },
    showSearch: {
      control: 'boolean',
      description: 'Show search input',
    },
    showSort: {
      control: 'boolean',
      description: 'Show sort options',
    },
    pagination: {
      control: 'boolean',
      description: 'Enable pagination',
    },
    perPage: {
      control: 'number',
      description: 'Items per page',
    },
    isAuthenticated: {
      control: 'boolean',
      description: 'User authentication status',
    },
  },
} satisfies Meta<typeof ImpulsaProjectsList>

export default meta
type Story = StoryObj<typeof meta>

const mockProjects: ImpulsaProject[] = [
  {
    id: 1,
    title: 'Centro Comunitario de Innovación Social',
    description: 'Proyecto para crear un espacio comunitario dedicado a la innovación social y el desarrollo local.',
    category: 'social',
    fundingGoal: 50000,
    fundingReceived: 32500,
    votes: 156,
    hasVoted: false,
    status: 'voting',
    author: 'María González',
    createdAt: new Date('2024-01-15'),
    imageUrl: 'https://via.placeholder.com/800x400/4ECDC4/FFFFFF?text=Centro+Social',
  },
  {
    id: 2,
    title: 'Plataforma de Datos Abiertos',
    description: 'Desarrollo de una plataforma tecnológica para publicar datos públicos de forma accesible.',
    category: 'technology',
    fundingGoal: 75000,
    fundingReceived: 45000,
    votes: 189,
    hasVoted: false,
    status: 'voting',
    author: 'Juan Pérez',
    createdAt: new Date('2024-01-20'),
    imageUrl: 'https://via.placeholder.com/800x400/45B7D1/FFFFFF?text=Tecnologia',
  },
  {
    id: 3,
    title: 'Festival de Arte Urbano',
    description: 'Organización de un festival anual que promueva el arte urbano y la expresión cultural.',
    category: 'culture',
    fundingGoal: 30000,
    fundingReceived: 30000,
    votes: 234,
    hasVoted: true,
    status: 'funded',
    author: 'Ana Martínez',
    createdAt: new Date('2024-01-10'),
    imageUrl: 'https://via.placeholder.com/800x400/FF6B6B/FFFFFF?text=Arte+Urbano',
  },
  {
    id: 4,
    title: 'Programa de Tutorías Escolares',
    description: 'Iniciativa educativa para proporcionar apoyo escolar gratuito a estudiantes.',
    category: 'education',
    fundingGoal: 20000,
    fundingReceived: 18000,
    votes: 145,
    hasVoted: false,
    status: 'voting',
    author: 'Laura Sánchez',
    createdAt: new Date('2024-01-18'),
    imageUrl: 'https://via.placeholder.com/800x400/96CEB4/FFFFFF?text=Educacion',
  },
  {
    id: 5,
    title: 'Huertos Urbanos Comunitarios',
    description: 'Creación de espacios verdes comunitarios para el cultivo ecológico y la educación ambiental.',
    category: 'environment',
    fundingGoal: 40000,
    fundingReceived: 15000,
    votes: 98,
    hasVoted: false,
    status: 'evaluation',
    author: 'Carlos López',
    createdAt: new Date('2024-01-25'),
    imageUrl: 'https://via.placeholder.com/800x400/66BB6A/FFFFFF?text=Huertos',
  },
  {
    id: 6,
    title: 'Centro de Salud Mental',
    description: 'Establecimiento de un centro de atención psicológica accesible para la comunidad.',
    category: 'health',
    fundingGoal: 60000,
    fundingReceived: 22000,
    votes: 167,
    hasVoted: false,
    status: 'voting',
    author: 'Elena Ruiz',
    createdAt: new Date('2024-01-12'),
    imageUrl: 'https://via.placeholder.com/800x400/EF5350/FFFFFF?text=Salud+Mental',
  },
  {
    id: 7,
    title: 'Biblioteca Comunitaria Digital',
    description: 'Creación de una biblioteca digital con acceso gratuito para toda la comunidad.',
    category: 'education',
    fundingGoal: 15000,
    fundingReceived: 12000,
    votes: 87,
    hasVoted: false,
    status: 'voting',
    author: 'Miguel Torres',
    createdAt: new Date('2024-01-22'),
    imageUrl: 'https://via.placeholder.com/800x400/FECA57/FFFFFF?text=Biblioteca',
  },
  {
    id: 8,
    title: 'Mercado de Productores Locales',
    description: 'Espacio para que productores locales vendan directamente sus productos ecológicos.',
    category: 'social',
    fundingGoal: 25000,
    fundingReceived: 8000,
    votes: 76,
    hasVoted: false,
    status: 'submitted',
    author: 'Isabel Moreno',
    createdAt: new Date('2024-01-28'),
    imageUrl: 'https://via.placeholder.com/800x400/48DBFB/FFFFFF?text=Mercado',
  },
  {
    id: 9,
    title: 'App de Movilidad Sostenible',
    description: 'Aplicación móvil para promover el transporte compartido y rutas en bicicleta.',
    category: 'technology',
    fundingGoal: 35000,
    fundingReceived: 5000,
    votes: 112,
    hasVoted: false,
    status: 'voting',
    author: 'Pedro Navarro',
    createdAt: new Date('2024-01-16'),
    imageUrl: 'https://via.placeholder.com/800x400/5F27CD/FFFFFF?text=Movilidad',
  },
  {
    id: 10,
    title: 'Taller de Reparación Comunitario',
    description: 'Espacio donde los vecinos puedan reparar objetos y aprender habilidades de bricolaje.',
    category: 'social',
    fundingGoal: 18000,
    fundingReceived: 0,
    votes: 54,
    hasVoted: false,
    status: 'draft',
    author: 'Sofía Jiménez',
    createdAt: new Date('2024-01-30'),
    imageUrl: 'https://via.placeholder.com/800x400/00D2D3/FFFFFF?text=Taller',
  },
  {
    id: 11,
    title: 'Programa de Compostaje Urbano',
    description: 'Sistema de compostaje comunitario para reducir residuos orgánicos.',
    category: 'environment',
    fundingGoal: 22000,
    fundingReceived: 22000,
    votes: 201,
    hasVoted: false,
    status: 'completed',
    author: 'Raúl Fernández',
    createdAt: new Date('2024-01-05'),
    imageUrl: 'https://via.placeholder.com/800x400/05C46B/FFFFFF?text=Compostaje',
  },
  {
    id: 12,
    title: 'Cine Comunitario al Aire Libre',
    description: 'Proyecciones gratuitas de cine en espacios públicos durante el verano.',
    category: 'culture',
    fundingGoal: 12000,
    fundingReceived: 3000,
    votes: 143,
    hasVoted: false,
    status: 'rejected',
    author: 'Andrea Castro',
    createdAt: new Date('2024-01-08'),
    imageUrl: 'https://via.placeholder.com/800x400/FF6348/FFFFFF?text=Cine',
  },
]

export const Default: Story = {
  args: {
    projects: mockProjects,
  },
}

export const Loading: Story = {
  args: {
    projects: mockProjects,
    loading: true,
  },
}

export const Empty: Story = {
  args: {
    projects: [],
  },
}

export const FewProjects: Story = {
  args: {
    projects: mockProjects.slice(0, 3),
  },
}

export const Compact: Story = {
  args: {
    projects: mockProjects,
    compact: true,
  },
}

export const NoFilters: Story = {
  args: {
    projects: mockProjects,
    showFilters: false,
  },
}

export const NoSearch: Story = {
  args: {
    projects: mockProjects,
    showSearch: false,
  },
}

export const NoSort: Story = {
  args: {
    projects: mockProjects,
    showSort: false,
  },
}

export const NoPagination: Story = {
  args: {
    projects: mockProjects,
    pagination: false,
  },
}

export const SmallPerPage: Story = {
  args: {
    projects: mockProjects,
    perPage: 4,
  },
}

export const Authenticated: Story = {
  args: {
    projects: mockProjects,
    isAuthenticated: true,
  },
}

export const NotAuthenticated: Story = {
  args: {
    projects: mockProjects,
    isAuthenticated: false,
  },
}

export const ServerSidePagination: Story = {
  args: {
    projects: mockProjects.slice(0, 6),
    total: 50,
    currentPage: 1,
    perPage: 6,
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { ImpulsaProjectsList },
    setup() {
      const projects = ref(mockProjects)
      const isAuthenticated = ref(false)

      const handleFilterChange = (filters: ProjectFilters) => {
        console.log('Filters changed:', filters)
      }

      const handleSortChange = (sort: string) => {
        console.log('Sort changed:', sort)
      }

      const handleSearchChange = (query: string) => {
        console.log('Search changed:', query)
      }

      const handlePageChange = (page: number) => {
        console.log('Page changed:', page)
      }

      const handleProjectClick = (project: ImpulsaProject) => {
        console.log('Project clicked:', project.title)
        alert(`Navegando a: ${project.title}`)
      }

      const handleVote = (project: ImpulsaProject) => {
        console.log('Vote for project:', project.title)
        // Toggle vote
        const proj = projects.value.find(p => p.id === project.id)
        if (proj) {
          proj.hasVoted = !proj.hasVoted
          proj.votes = (proj.votes || 0) + (proj.hasVoted ? 1 : -1)
        }
      }

      const handleLoginRequired = () => {
        console.log('Login required')
        if (confirm('Necesitas iniciar sesión para votar. ¿Quieres iniciar sesión?')) {
          isAuthenticated.value = true
        }
      }

      const toggleAuth = () => {
        isAuthenticated.value = !isAuthenticated.value
      }

      return {
        projects,
        isAuthenticated,
        handleFilterChange,
        handleSortChange,
        handleSearchChange,
        handlePageChange,
        handleProjectClick,
        handleVote,
        handleLoginRequired,
        toggleAuth,
      }
    },
    template: `
      <div class="p-6">
        <div class="mb-6 flex items-center justify-between">
          <h2 class="text-2xl font-bold">Lista Interactiva de Proyectos IMPULSA</h2>
          <button
            @click="toggleAuth"
            class="px-4 py-2 rounded transition-colors text-sm"
            :class="isAuthenticated ? 'bg-green-600 text-white hover:bg-green-700' : 'bg-gray-600 text-white hover:bg-gray-700'"
          >
            {{ isAuthenticated ? '✓ Autenticado' : '✗ No Autenticado' }}
          </button>
        </div>
        <ImpulsaProjectsList
          :projects="projects"
          :is-authenticated="isAuthenticated"
          :per-page="6"
          @filter-change="handleFilterChange"
          @sort-change="handleSortChange"
          @search-change="handleSearchChange"
          @page-change="handlePageChange"
          @project-click="handleProjectClick"
          @vote="handleVote"
          @login-required="handleLoginRequired"
        />
      </div>
    `,
  }),
  args: {},
}

export const FilteredByStatus: Story = {
  render: (args) => ({
    components: { ImpulsaProjectsList },
    setup() {
      return { mockProjects }
    },
    template: `
      <div class="p-6 space-y-8">
        <div>
          <h3 class="text-xl font-bold mb-4">En Votación</h3>
          <ImpulsaProjectsList
            :projects="mockProjects.filter(p => p.status === 'voting')"
            :per-page="6"
          />
        </div>
        <div>
          <h3 class="text-xl font-bold mb-4">Financiados</h3>
          <ImpulsaProjectsList
            :projects="mockProjects.filter(p => p.status === 'funded')"
            :per-page="6"
          />
        </div>
        <div>
          <h3 class="text-xl font-bold mb-4">Completados</h3>
          <ImpulsaProjectsList
            :projects="mockProjects.filter(p => p.status === 'completed')"
            :per-page="6"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const FilteredByCategory: Story = {
  render: (args) => ({
    components: { ImpulsaProjectsList },
    setup() {
      return { mockProjects }
    },
    template: `
      <div class="p-6 space-y-8">
        <div>
          <h3 class="text-xl font-bold mb-4">Proyectos Sociales</h3>
          <ImpulsaProjectsList
            :projects="mockProjects.filter(p => p.category === 'social')"
            compact
          />
        </div>
        <div>
          <h3 class="text-xl font-bold mb-4">Proyectos Tecnológicos</h3>
          <ImpulsaProjectsList
            :projects="mockProjects.filter(p => p.category === 'technology')"
            compact
          />
        </div>
        <div>
          <h3 class="text-xl font-bold mb-4">Proyectos Culturales</h3>
          <ImpulsaProjectsList
            :projects="mockProjects.filter(p => p.category === 'culture')"
            compact
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const WithRealTimeUpdates: Story = {
  render: (args) => ({
    components: { ImpulsaProjectsList },
    setup() {
      const projects = ref([...mockProjects])
      const updating = ref(false)

      const simulateVote = () => {
        updating.value = true
        const randomProject = projects.value[Math.floor(Math.random() * projects.value.length)]
        randomProject.votes = (randomProject.votes || 0) + 1
        setTimeout(() => {
          updating.value = false
        }, 500)
      }

      const simulateFunding = () => {
        updating.value = true
        const votingProjects = projects.value.filter(p => p.status === 'voting')
        if (votingProjects.length > 0) {
          const randomProject = votingProjects[Math.floor(Math.random() * votingProjects.length)]
          randomProject.fundingReceived = (randomProject.fundingReceived || 0) + 1000
        }
        setTimeout(() => {
          updating.value = false
        }, 500)
      }

      return {
        projects,
        updating,
        simulateVote,
        simulateFunding,
      }
    },
    template: `
      <div class="p-6">
        <div class="mb-6 flex items-center gap-4">
          <h2 class="text-2xl font-bold flex-1">Actualizaciones en Tiempo Real</h2>
          <button
            @click="simulateVote"
            :disabled="updating"
            class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50 text-sm"
          >
            Simular Voto
          </button>
          <button
            @click="simulateFunding"
            :disabled="updating"
            class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 disabled:opacity-50 text-sm"
          >
            Simular Donación
          </button>
        </div>
        <ImpulsaProjectsList
          :projects="projects"
          :per-page="6"
          :is-authenticated="true"
        />
      </div>
    `,
  }),
  args: {},
}

export const CompactGrid: Story = {
  args: {
    projects: mockProjects,
    compact: true,
    perPage: 8,
  },
}

export const MinimalInterface: Story = {
  args: {
    projects: mockProjects,
    showFilters: false,
    showSearch: false,
    showSort: false,
    pagination: false,
    compact: true,
  },
}

export const FullFeatured: Story = {
  args: {
    projects: mockProjects,
    showFilters: true,
    showSearch: true,
    showSort: true,
    pagination: true,
    perPage: 6,
    isAuthenticated: true,
  },
}
