import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import VotingWidget from './VotingWidget.vue'
import type { VoteData } from './VotingWidget.vue'

const mockVoteData: VoteData = {
  votes: 234,
  supportsCount: 567,
  hotness: 8900,
  hasVoted: false,
  hasSupported: false,
  closed: false,
}

const meta = {
  title: 'Organisms/VotingWidget',
  component: VotingWidget,
  tags: ['autodocs'],
  argTypes: {
    isAuthenticated: {
      control: 'boolean',
    },
    loadingVote: {
      control: 'boolean',
    },
    loadingSupport: {
      control: 'boolean',
    },
    showHotness: {
      control: 'boolean',
    },
    compact: {
      control: 'boolean',
    },
    vertical: {
      control: 'boolean',
    },
    disabled: {
      control: 'boolean',
    },
    showLabels: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof VotingWidget>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
  },
}

export const Authenticated: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
  },
}

export const HasVoted: Story = {
  args: {
    voteData: {
      ...mockVoteData,
      hasVoted: true,
      votes: 235,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const HasSupported: Story = {
  args: {
    voteData: {
      ...mockVoteData,
      hasSupported: true,
      supportsCount: 568,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const BothVotedAndSupported: Story = {
  args: {
    voteData: {
      ...mockVoteData,
      hasVoted: true,
      hasSupported: true,
      votes: 235,
      supportsCount: 568,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const LoadingVote: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
    loadingVote: true,
  },
}

export const LoadingSupport: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
    loadingSupport: true,
  },
}

export const CoolHotness: Story = {
  args: {
    voteData: {
      ...mockVoteData,
      hotness: 3000,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const WarmHotness: Story = {
  args: {
    voteData: {
      ...mockVoteData,
      hotness: 6000,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const HotHotness: Story = {
  args: {
    voteData: {
      ...mockVoteData,
      hotness: 12000,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const VeryHotHotness: Story = {
  args: {
    voteData: {
      ...mockVoteData,
      hotness: 20000,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const HighNumbers: Story = {
  args: {
    voteData: {
      votes: 1234,
      supportsCount: 5678,
      hotness: 25000,
      hasVoted: false,
      hasSupported: false,
      closed: false,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const VeryHighNumbers: Story = {
  args: {
    voteData: {
      votes: 123456,
      supportsCount: 567890,
      hotness: 250000,
      hasVoted: false,
      hasSupported: false,
      closed: false,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const MillionNumbers: Story = {
  args: {
    voteData: {
      votes: 1234567,
      supportsCount: 2345678,
      hotness: 5000000,
      hasVoted: false,
      hasSupported: false,
      closed: false,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const Closed: Story = {
  args: {
    voteData: {
      ...mockVoteData,
      closed: true,
      votes: 890,
      supportsCount: 1234,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const ClosedWithVotes: Story = {
  args: {
    voteData: {
      votes: 890,
      supportsCount: 1234,
      hotness: 15000,
      hasVoted: true,
      hasSupported: true,
      closed: true,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const CompactMode: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
    compact: true,
  },
}

export const VerticalLayout: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
    vertical: true,
  },
}

export const CompactVertical: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
    compact: true,
    vertical: true,
  },
}

export const WithoutLabels: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
    showLabels: false,
  },
}

export const WithoutHotness: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
    showHotness: false,
  },
}

export const Disabled: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
    disabled: true,
  },
}

export const LowSupport: Story = {
  args: {
    voteData: {
      votes: 12,
      supportsCount: 28,
      hotness: 450,
      hasVoted: false,
      hasSupported: false,
      closed: false,
    },
    itemId: 1,
    isAuthenticated: true,
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { VotingWidget },
    setup() {
      const voteData = ref<VoteData>({ ...mockVoteData })
      const loadingVote = ref(false)
      const loadingSupport = ref(false)

      const handleVote = async () => {
        if (voteData.value.hasVoted) return

        loadingVote.value = true
        await new Promise((resolve) => setTimeout(resolve, 1000))

        voteData.value = {
          ...voteData.value,
          hasVoted: true,
          votes: voteData.value.votes + 1,
          hotness: voteData.value.hotness + 100,
        }
        loadingVote.value = false
      }

      const handleSupport = async () => {
        if (voteData.value.hasSupported) return

        loadingSupport.value = true
        await new Promise((resolve) => setTimeout(resolve, 1000))

        voteData.value = {
          ...voteData.value,
          hasSupported: true,
          supportsCount: voteData.value.supportsCount + 1,
          hotness: voteData.value.hotness + 50,
        }
        loadingSupport.value = false
      }

      const handleLoginRequired = (action: 'vote' | 'support') => {
        alert(`Necesitas iniciar sesión para ${action === 'vote' ? 'votar' : 'apoyar'}`)
      }

      return {
        voteData,
        loadingVote,
        loadingSupport,
        handleVote,
        handleSupport,
        handleLoginRequired,
      }
    },
    template: `
      <div class="p-6 max-w-md">
        <h2 class="text-2xl font-bold mb-4">Widget de Votación Interactivo</h2>
        <p class="text-sm text-gray-600 mb-6">
          Haz clic en los botones para votar o apoyar. Los contadores se actualizarán en tiempo real.
        </p>
        <VotingWidget
          :vote-data="voteData"
          :item-id="1"
          :is-authenticated="true"
          :loading-vote="loadingVote"
          :loading-support="loadingSupport"
          @vote="handleVote"
          @support="handleSupport"
          @login-required="handleLoginRequired"
        />
      </div>
    `,
  }),
  args: {},
}

export const InteractiveUnauthenticated: Story = {
  render: (args) => ({
    components: { VotingWidget },
    setup() {
      const voteData = ref<VoteData>({ ...mockVoteData })

      const handleLoginRequired = (action: 'vote' | 'support') => {
        alert(`Por favor inicia sesión para ${action === 'vote' ? 'votar' : 'apoyar'}`)
      }

      return {
        voteData,
        handleLoginRequired,
      }
    },
    template: `
      <div class="p-6 max-w-md">
        <h2 class="text-2xl font-bold mb-4">Usuario No Autenticado</h2>
        <p class="text-sm text-gray-600 mb-6">
          Intenta votar o apoyar para ver el mensaje de inicio de sesión requerido.
        </p>
        <VotingWidget
          :vote-data="voteData"
          :item-id="1"
          :is-authenticated="false"
          @login-required="handleLoginRequired"
        />
      </div>
    `,
  }),
  args: {},
}

export const MultipleWidgets: Story = {
  render: (args) => ({
    components: { VotingWidget },
    setup() {
      const proposals = ref([
        {
          id: 1,
          title: 'Propuesta Popular',
          voteData: {
            votes: 1234,
            supportsCount: 2345,
            hotness: 18000,
            hasVoted: false,
            hasSupported: false,
            closed: false,
          },
        },
        {
          id: 2,
          title: 'Propuesta Nueva',
          voteData: {
            votes: 45,
            supportsCount: 89,
            hotness: 2000,
            hasVoted: false,
            hasSupported: false,
            closed: false,
          },
        },
        {
          id: 3,
          title: 'Propuesta Candente',
          voteData: {
            votes: 890,
            supportsCount: 1567,
            hotness: 12000,
            hasVoted: true,
            hasSupported: true,
            closed: false,
          },
        },
        {
          id: 4,
          title: 'Propuesta Finalizada',
          voteData: {
            votes: 567,
            supportsCount: 890,
            hotness: 9000,
            hasVoted: false,
            hasSupported: false,
            closed: true,
          },
        },
      ])

      return { proposals }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Múltiples Widgets de Votación</h2>
        <div class="space-y-6">
          <div v-for="proposal in proposals" :key="proposal.id" class="border-b pb-6 last:border-b-0">
            <h3 class="text-lg font-semibold mb-3">{{ proposal.title }}</h3>
            <VotingWidget
              :vote-data="proposal.voteData"
              :item-id="proposal.id"
              :is-authenticated="true"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const SidebarLayout: Story = {
  render: (args) => ({
    components: { VotingWidget },
    setup() {
      const voteData = ref<VoteData>({
        votes: 456,
        supportsCount: 789,
        hotness: 9500,
        hasVoted: false,
        hasSupported: false,
        closed: false,
      })

      return { voteData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Layout de Sidebar</h2>
        <div class="flex gap-6">
          <div class="flex-1">
            <h3 class="text-xl font-semibold mb-3">Propuesta de Mejora del Transporte</h3>
            <p class="text-gray-600 mb-4">
              Esta propuesta busca mejorar el sistema de transporte público mediante la
              implementación de carriles exclusivos y modernización de la flota.
            </p>
            <p class="text-sm text-gray-500">
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod
              tempor incididunt ut labore et dolore magna aliqua.
            </p>
          </div>
          <div class="w-80">
            <VotingWidget
              :vote-data="voteData"
              :item-id="1"
              :is-authenticated="true"
              vertical
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CompactGrid: Story = {
  render: (args) => ({
    components: { VotingWidget },
    setup() {
      const items = ref([
        { id: 1, votes: 234, supportsCount: 456, hotness: 8000 },
        { id: 2, votes: 567, supportsCount: 890, hotness: 12000 },
        { id: 3, votes: 123, supportsCount: 234, hotness: 4000 },
        { id: 4, votes: 890, supportsCount: 1234, hotness: 15000 },
        { id: 5, votes: 345, supportsCount: 567, hotness: 6500 },
        { id: 6, votes: 678, supportsCount: 901, hotness: 11000 },
      ])

      return { items }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Grid Compacto</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <VotingWidget
            v-for="item in items"
            :key="item.id"
            :vote-data="{
              votes: item.votes,
              supportsCount: item.supportsCount,
              hotness: item.hotness,
              hasVoted: false,
              hasSupported: false,
              closed: false,
            }"
            :item-id="item.id"
            :is-authenticated="true"
            compact
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CustomLabels: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
    voteLabel: 'Vote',
    supportLabel: 'Like',
  },
}

export const MinimalMode: Story = {
  args: {
    voteData: mockVoteData,
    itemId: 1,
    isAuthenticated: true,
    showHotness: false,
    showLabels: false,
    compact: true,
  },
}
