import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ImpulsaProjectCard from './ImpulsaProjectCard.vue'
import type { ImpulsaProject } from './ImpulsaProjectCard.vue'

const meta = {
  title: 'Organisms/ImpulsaProjectCard',
  component: ImpulsaProjectCard,
  tags: ['autodocs'],
  argTypes: {
    project: {
      control: 'object',
      description: 'Project data to display',
    },
    compact: {
      control: 'boolean',
      description: 'Display in compact mode',
    },
    showVoteButton: {
      control: 'boolean',
      description: 'Show voting button',
    },
    isAuthenticated: {
      control: 'boolean',
      description: 'User authentication state',
    },
    loadingVote: {
      control: 'boolean',
      description: 'Loading state for voting',
    },
    disabled: {
      control: 'boolean',
      description: 'Disable card interactions',
    },
    showFullDescription: {
      control: 'boolean',
      description: 'Show full description without truncation',
    },
  },
} satisfies Meta<typeof ImpulsaProjectCard>

export default meta
type Story = StoryObj<typeof meta>

const mockProject: ImpulsaProject = {
  id: 1,
  title: 'Centro Comunitario de Innovación Social',
  description: 'Proyecto para crear un espacio comunitario dedicado a la innovación social, donde los ciudadanos puedan colaborar en iniciativas que mejoren su barrio. Incluye talleres, coworking y actividades educativas.',
  category: 'social',
  fundingGoal: 50000,
  fundingReceived: 32500,
  votes: 156,
  hasVoted: false,
  status: 'voting',
  author: 'María González',
  createdAt: new Date('2024-01-15'),
  imageUrl: 'https://via.placeholder.com/800x400/4ECDC4/FFFFFF?text=Centro+Comunitario',
}

export const Default: Story = {
  args: {
    project: mockProject,
  },
}

export const WithoutImage: Story = {
  args: {
    project: {
      ...mockProject,
      imageUrl: undefined,
    },
  },
}

export const Compact: Story = {
  args: {
    project: mockProject,
    compact: true,
  },
}

export const CompactWithoutImage: Story = {
  args: {
    project: {
      ...mockProject,
      imageUrl: undefined,
    },
    compact: true,
  },
}

// Status Variants
export const StatusDraft: Story = {
  args: {
    project: {
      ...mockProject,
      status: 'draft',
      fundingReceived: 0,
      votes: 0,
    },
  },
}

export const StatusSubmitted: Story = {
  args: {
    project: {
      ...mockProject,
      status: 'submitted',
      fundingReceived: 0,
      votes: 0,
    },
  },
}

export const StatusEvaluation: Story = {
  args: {
    project: {
      ...mockProject,
      status: 'evaluation',
      fundingReceived: 0,
      votes: 0,
    },
  },
}

export const StatusVoting: Story = {
  args: {
    project: {
      ...mockProject,
      status: 'voting',
    },
  },
}

export const StatusFunded: Story = {
  args: {
    project: {
      ...mockProject,
      status: 'funded',
      fundingReceived: 50000,
    },
  },
}

export const StatusRejected: Story = {
  args: {
    project: {
      ...mockProject,
      status: 'rejected',
      fundingReceived: 15000,
    },
  },
}

export const StatusCompleted: Story = {
  args: {
    project: {
      ...mockProject,
      status: 'completed',
      fundingReceived: 50000,
    },
  },
}

// Category Variants
export const CategoryTechnology: Story = {
  args: {
    project: {
      ...mockProject,
      title: 'Plataforma de Datos Abiertos',
      description: 'Desarrollo de una plataforma tecnológica para publicar datos públicos de forma accesible y transparente.',
      category: 'technology',
      imageUrl: 'https://via.placeholder.com/800x400/45B7D1/FFFFFF?text=Tecnologia',
    },
  },
}

export const CategoryCulture: Story = {
  args: {
    project: {
      ...mockProject,
      title: 'Festival de Arte Urbano',
      description: 'Organización de un festival anual que promueva el arte urbano y la expresión cultural en espacios públicos.',
      category: 'culture',
      imageUrl: 'https://via.placeholder.com/800x400/FF6B6B/FFFFFF?text=Cultura',
    },
  },
}

export const CategoryEducation: Story = {
  args: {
    project: {
      ...mockProject,
      title: 'Programa de Tutorías Escolares',
      description: 'Iniciativa educativa para proporcionar apoyo escolar gratuito a estudiantes de primaria y secundaria.',
      category: 'education',
      imageUrl: 'https://via.placeholder.com/800x400/96CEB4/FFFFFF?text=Educacion',
    },
  },
}

export const CategoryEnvironment: Story = {
  args: {
    project: {
      ...mockProject,
      title: 'Huertos Urbanos Comunitarios',
      description: 'Creación de espacios verdes comunitarios para el cultivo ecológico y la educación ambiental.',
      category: 'environment',
      imageUrl: 'https://via.placeholder.com/800x400/66BB6A/FFFFFF?text=Medio+Ambiente',
    },
  },
}

export const CategoryHealth: Story = {
  args: {
    project: {
      ...mockProject,
      title: 'Centro de Salud Mental Comunitario',
      description: 'Establecimiento de un centro de atención psicológica accesible para todos los ciudadanos.',
      category: 'health',
      imageUrl: 'https://via.placeholder.com/800x400/EF5350/FFFFFF?text=Salud',
    },
  },
}

// Funding Progress Variants
export const FundingZeroPercent: Story = {
  args: {
    project: {
      ...mockProject,
      fundingReceived: 0,
    },
  },
}

export const FundingTwentyFivePercent: Story = {
  args: {
    project: {
      ...mockProject,
      fundingReceived: 12500,
    },
  },
}

export const FundingFiftyPercent: Story = {
  args: {
    project: {
      ...mockProject,
      fundingReceived: 25000,
    },
  },
}

export const FundingSeventyFivePercent: Story = {
  args: {
    project: {
      ...mockProject,
      fundingReceived: 37500,
    },
  },
}

export const FundingOneHundredPercent: Story = {
  args: {
    project: {
      ...mockProject,
      fundingReceived: 50000,
      status: 'funded',
    },
  },
}

export const FundingOverfunded: Story = {
  args: {
    project: {
      ...mockProject,
      fundingReceived: 65000,
      status: 'funded',
    },
  },
}

// Voting States
export const NotVoted: Story = {
  args: {
    project: {
      ...mockProject,
      hasVoted: false,
    },
    isAuthenticated: true,
  },
}

export const AlreadyVoted: Story = {
  args: {
    project: {
      ...mockProject,
      hasVoted: true,
    },
    isAuthenticated: true,
  },
}

export const VotingLoading: Story = {
  args: {
    project: mockProject,
    isAuthenticated: true,
    loadingVote: true,
  },
}

export const NotAuthenticated: Story = {
  args: {
    project: mockProject,
    isAuthenticated: false,
  },
}

export const VoteButtonHidden: Story = {
  args: {
    project: mockProject,
    showVoteButton: false,
  },
}

// Other States
export const Disabled: Story = {
  args: {
    project: mockProject,
    disabled: true,
  },
}

export const LongDescription: Story = {
  args: {
    project: {
      ...mockProject,
      description: 'Este es un proyecto muy ambicioso que busca transformar la manera en que los ciudadanos interactúan con su entorno urbano. A través de la implementación de tecnologías innovadoras y la participación activa de la comunidad, buscamos crear un espacio que no solo sirva como punto de encuentro, sino también como catalizador de cambio social positivo. El proyecto incluye múltiples fases de desarrollo, cada una diseñada cuidadosamente para maximizar el impacto en la comunidad local. Desde talleres educativos hasta eventos culturales, cada actividad está pensada para fomentar la cohesión social y el desarrollo sostenible.',
    },
  },
}

export const FullDescription: Story = {
  args: {
    project: {
      ...mockProject,
      description: 'Este es un proyecto muy ambicioso que busca transformar la manera en que los ciudadanos interactúan con su entorno urbano. A través de la implementación de tecnologías innovadoras y la participación activa de la comunidad, buscamos crear un espacio que no solo sirva como punto de encuentro, sino también como catalizador de cambio social positivo.',
    },
    showFullDescription: true,
  },
}

export const HighVotes: Story = {
  args: {
    project: {
      ...mockProject,
      votes: 1247,
    },
  },
}

export const LowFunding: Story = {
  args: {
    project: {
      ...mockProject,
      fundingGoal: 5000,
      fundingReceived: 1250,
    },
  },
}

export const HighFunding: Story = {
  args: {
    project: {
      ...mockProject,
      fundingGoal: 250000,
      fundingReceived: 187500,
    },
  },
}

// Interactive Story
export const Interactive: Story = {
  render: () => ({
    components: { ImpulsaProjectCard },
    setup() {
      const project = ref<ImpulsaProject>({
        ...mockProject,
        hasVoted: false,
      })
      const isAuthenticated = ref(true)
      const loadingVote = ref(false)

      const handleVote = () => {
        console.log('Vote clicked for project:', project.value.id)
        loadingVote.value = true

        // Simulate vote processing
        setTimeout(() => {
          project.value = {
            ...project.value,
            hasVoted: true,
            votes: (project.value.votes || 0) + 1,
          }
          loadingVote.value = false
        }, 1000)
      }

      const handleLoginRequired = () => {
        console.log('Login required')
        alert('Por favor, inicia sesión para votar')
      }

      const handleClick = () => {
        console.log('Card clicked, navigating to project detail...')
      }

      const toggleAuth = () => {
        isAuthenticated.value = !isAuthenticated.value
      }

      return {
        project,
        isAuthenticated,
        loadingVote,
        handleVote,
        handleLoginRequired,
        handleClick,
        toggleAuth,
      }
    },
    template: `
      <div class="p-6 max-w-4xl space-y-4">
        <div class="flex items-center gap-4 mb-4">
          <h2 class="text-2xl font-bold">Proyecto IMPULSA Interactivo</h2>
          <button
            @click="toggleAuth"
            class="px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark transition-colors text-sm"
          >
            {{ isAuthenticated ? 'Cerrar Sesión' : 'Iniciar Sesión' }}
          </button>
        </div>
        <p class="text-sm text-gray-600 mb-4">
          Estado de autenticación: <strong>{{ isAuthenticated ? 'Autenticado' : 'No autenticado' }}</strong>
        </p>
        <ImpulsaProjectCard
          :project="project"
          :is-authenticated="isAuthenticated"
          :loading-vote="loadingVote"
          @vote="handleVote"
          @login-required="handleLoginRequired"
          @click="handleClick"
        />
        <div class="mt-6 p-4 bg-gray-50 rounded">
          <h3 class="font-semibold mb-2">Estado del Proyecto:</h3>
          <pre class="text-xs">{{ JSON.stringify({
            title: project.title,
            votes: project.votes,
            hasVoted: project.hasVoted,
            fundingProgress: Math.round((project.fundingReceived || 0) / project.fundingGoal * 100) + '%'
          }, null, 2) }}</pre>
        </div>
      </div>
    `,
  }),
  args: {},
}

// Grid Layout Story
export const GridLayout: Story = {
  render: () => ({
    components: { ImpulsaProjectCard },
    setup() {
      const projects: ImpulsaProject[] = [
        {
          ...mockProject,
          id: 1,
          title: 'Centro Comunitario',
          category: 'social',
          imageUrl: 'https://via.placeholder.com/800x400/4ECDC4/FFFFFF?text=Social',
        },
        {
          ...mockProject,
          id: 2,
          title: 'Plataforma Digital',
          category: 'technology',
          fundingReceived: 15000,
          votes: 89,
          imageUrl: 'https://via.placeholder.com/800x400/45B7D1/FFFFFF?text=Tech',
        },
        {
          ...mockProject,
          id: 3,
          title: 'Festival Cultural',
          category: 'culture',
          fundingReceived: 45000,
          votes: 234,
          status: 'funded',
          imageUrl: 'https://via.placeholder.com/800x400/FF6B6B/FFFFFF?text=Cultura',
        },
        {
          ...mockProject,
          id: 4,
          title: 'Huertos Urbanos',
          category: 'environment',
          fundingReceived: 8000,
          votes: 67,
          imageUrl: 'https://via.placeholder.com/800x400/66BB6A/FFFFFF?text=Ambiente',
        },
        {
          ...mockProject,
          id: 5,
          title: 'Programa Educativo',
          category: 'education',
          fundingReceived: 28000,
          votes: 145,
          imageUrl: 'https://via.placeholder.com/800x400/96CEB4/FFFFFF?text=Educacion',
        },
        {
          ...mockProject,
          id: 6,
          title: 'Centro de Salud',
          category: 'health',
          fundingReceived: 12000,
          votes: 98,
          status: 'evaluation',
          imageUrl: 'https://via.placeholder.com/800x400/EF5350/FFFFFF?text=Salud',
        },
      ]

      return { projects }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Proyectos IMPULSA</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <ImpulsaProjectCard
            v-for="project in projects"
            :key="project.id"
            :project="project"
            :is-authenticated="true"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

// Compact Grid Layout
export const CompactGrid: Story = {
  render: () => ({
    components: { ImpulsaProjectCard },
    setup() {
      const projects: ImpulsaProject[] = [
        { ...mockProject, id: 1, title: 'Centro Comunitario', votes: 156 },
        { ...mockProject, id: 2, title: 'Plataforma Digital', votes: 89, fundingReceived: 15000 },
        { ...mockProject, id: 3, title: 'Festival Cultural', votes: 234, fundingReceived: 45000, status: 'funded' },
        { ...mockProject, id: 4, title: 'Huertos Urbanos', votes: 67, fundingReceived: 8000 },
        { ...mockProject, id: 5, title: 'Programa Educativo', votes: 145, fundingReceived: 28000 },
        { ...mockProject, id: 6, title: 'Centro de Salud', votes: 98, fundingReceived: 12000 },
      ]

      return { projects }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Vista Compacta</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <ImpulsaProjectCard
            v-for="project in projects"
            :key="project.id"
            :project="project"
            :is-authenticated="true"
            compact
          />
        </div>
      </div>
    `,
  }),
  args: {},
}
