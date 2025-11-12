import type { Meta, StoryObj } from '@storybook/vue3'
import ProposalCard from './ProposalCard.vue'
import type { Proposal } from './ProposalCard.vue'

const mockProposal: Proposal = {
  id: 1,
  title: 'Propuesta de Mejora del Transporte Público',
  description:
    'Esta propuesta busca mejorar el sistema de transporte público de la ciudad mediante la implementación de carriles exclusivos para autobuses, ampliación de rutas y modernización de la flota vehicular. Se estima que esto reducirá los tiempos de viaje en un 30% y mejorará significativamente la calidad del aire.',
  votes: 234,
  supportsCount: 567,
  hotness: 8900,
  createdAt: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000), // 15 days ago
  finishesAt: new Date(Date.now() + 75 * 24 * 60 * 60 * 1000), // 75 days from now
  redditThreshold: false,
  supported: false,
  finished: false,
  discarded: false,
}

const meta = {
  title: 'Organisms/ProposalCard',
  component: ProposalCard,
  tags: ['autodocs'],
  argTypes: {
    detailed: {
      control: 'boolean',
    },
    showSupportButton: {
      control: 'boolean',
    },
    loadingSupport: {
      control: 'boolean',
    },
    isAuthenticated: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof ProposalCard>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    proposal: mockProposal,
  },
}

export const Authenticated: Story = {
  args: {
    proposal: mockProposal,
    isAuthenticated: true,
  },
}

export const Supported: Story = {
  args: {
    proposal: {
      ...mockProposal,
      supported: true,
    },
    isAuthenticated: true,
  },
}

export const LoadingSupport: Story = {
  args: {
    proposal: mockProposal,
    isAuthenticated: true,
    loadingSupport: true,
  },
}

export const ThresholdReached: Story = {
  args: {
    proposal: {
      ...mockProposal,
      redditThreshold: true,
      supportsCount: 1234,
    },
    isAuthenticated: true,
  },
}

export const Finished: Story = {
  args: {
    proposal: {
      ...mockProposal,
      finished: true,
      redditThreshold: true,
      supportsCount: 1500,
    },
  },
}

export const Discarded: Story = {
  args: {
    proposal: {
      ...mockProposal,
      discarded: true,
      supportsCount: 45,
    },
  },
}

export const HighSupport: Story = {
  args: {
    proposal: {
      ...mockProposal,
      votes: 890,
      supportsCount: 2340,
      hotness: 25000,
      redditThreshold: true,
    },
    isAuthenticated: true,
  },
}

export const LowSupport: Story = {
  args: {
    proposal: {
      ...mockProposal,
      votes: 12,
      supportsCount: 28,
      hotness: 450,
    },
    isAuthenticated: true,
  },
}

export const DetailedView: Story = {
  args: {
    proposal: mockProposal,
    detailed: true,
    isAuthenticated: true,
  },
}

export const WithoutSupportButton: Story = {
  args: {
    proposal: mockProposal,
    showSupportButton: false,
  },
}

export const ShortDescription: Story = {
  args: {
    proposal: {
      ...mockProposal,
      title: 'Propuesta Corta',
      description: 'Esta es una descripción corta.',
    },
    isAuthenticated: true,
  },
}

export const LongTitle: Story = {
  args: {
    proposal: {
      ...mockProposal,
      title:
        'Propuesta de Implementación de un Sistema Integral de Gestión Ambiental y Sustentabilidad para la Ciudad',
    },
    isAuthenticated: true,
  },
}

export const FewDaysRemaining: Story = {
  args: {
    proposal: {
      ...mockProposal,
      finishesAt: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000), // 5 days from now
    },
    isAuthenticated: true,
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { ProposalCard },
    setup() {
      const handleSupport = (id: number | string) => {
        alert(`Apoyando propuesta #${id}`)
      }

      const handleView = (id: number | string) => {
        alert(`Ver detalles de propuesta #${id}`)
      }

      return { args, handleSupport, handleView }
    },
    template: `
      <div class="p-4">
        <ProposalCard
          v-bind="args"
          @support="handleSupport"
          @view="handleView"
        />
        <p class="mt-4 text-sm text-gray-600">
          Click en "Apoyar" o "Ver detalles" para ver eventos
        </p>
      </div>
    `,
  }),
  args: {
    proposal: mockProposal,
    isAuthenticated: true,
  },
}

export const Grid: Story = {
  render: (args) => ({
    components: { ProposalCard },
    setup() {
      const proposals: Proposal[] = [
        mockProposal,
        {
          id: 2,
          title: 'Creación de Espacios Verdes Urbanos',
          description:
            'Propuesta para crear más parques y áreas verdes en la ciudad, mejorando la calidad de vida de los ciudadanos.',
          votes: 156,
          supportsCount: 423,
          hotness: 6500,
          createdAt: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000),
          finishesAt: new Date(Date.now() + 70 * 24 * 60 * 60 * 1000),
          redditThreshold: false,
          supported: false,
          finished: false,
          discarded: false,
        },
        {
          id: 3,
          title: 'Programa de Reciclaje Municipal',
          description:
            'Implementación de un sistema de reciclaje eficiente con contenedores diferenciados y campañas educativas.',
          votes: 312,
          supportsCount: 891,
          hotness: 12000,
          createdAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
          finishesAt: new Date(Date.now() + 80 * 24 * 60 * 60 * 1000),
          redditThreshold: true,
          supported: true,
          finished: false,
          discarded: false,
        },
        {
          id: 4,
          title: 'Mejora de Iluminación en Barrios',
          description: 'Instalación de iluminación LED en calles y espacios públicos.',
          votes: 89,
          supportsCount: 234,
          hotness: 3400,
          createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
          finishesAt: new Date(Date.now() + 85 * 24 * 60 * 60 * 1000),
          redditThreshold: false,
          supported: false,
          finished: false,
          discarded: false,
        },
      ]

      return { proposals }
    },
    template: `
      <div class="p-4">
        <h2 class="text-2xl font-bold mb-6">Propuestas Activas</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <ProposalCard
            v-for="proposal in proposals"
            :key="proposal.id"
            :proposal="proposal"
            :is-authenticated="true"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}
