import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ImpulsaEditionInfo from './ImpulsaEditionInfo.vue'
import type { ImpulsaEdition } from './ImpulsaEditionInfo.vue'

const meta = {
  title: 'Organisms/ImpulsaEditionInfo',
  component: ImpulsaEditionInfo,
  tags: ['autodocs'],
  argTypes: {
    edition: {
      control: 'object',
      description: 'Edition data',
    },
    showCountdown: {
      control: 'boolean',
      description: 'Show countdown timer',
    },
    showPhase: {
      control: 'boolean',
      description: 'Show phase badge',
    },
    showStats: {
      control: 'boolean',
      description: 'Show statistics',
    },
    compact: {
      control: 'boolean',
      description: 'Compact mode',
    },
    loading: {
      control: 'boolean',
      description: 'Loading state',
    },
  },
} satisfies Meta<typeof ImpulsaEditionInfo>

export default meta
type Story = StoryObj<typeof meta>

const today = new Date()
const futureDate = (days: number) => {
  const date = new Date(today)
  date.setDate(date.getDate() + days)
  return date.toISOString().split('T')[0]
}

const pastDate = (days: number) => {
  const date = new Date(today)
  date.setDate(date.getDate() - days)
  return date.toISOString().split('T')[0]
}

const mockEdition: ImpulsaEdition = {
  id: 1,
  name: 'IMPULSA 2024',
  year: 2024,
  phase: 'voting',
  dates: {
    submissionStart: pastDate(90),
    submissionEnd: pastDate(60),
    evaluationStart: pastDate(60),
    evaluationEnd: pastDate(30),
    votingStart: pastDate(30),
    votingEnd: futureDate(15),
    implementationStart: futureDate(16),
  },
  stats: {
    totalFunding: 500000,
    projectsSubmitted: 45,
    projectsInEvaluation: 30,
    projectsInVoting: 25,
    projectsFunded: 0,
    totalVotes: 1250,
  },
}

export const Default: Story = {
  args: {
    edition: mockEdition,
  },
}

export const SubmissionPhase: Story = {
  args: {
    edition: {
      ...mockEdition,
      phase: 'submission',
      dates: {
        submissionStart: pastDate(15),
        submissionEnd: futureDate(45),
        evaluationStart: futureDate(46),
        evaluationEnd: futureDate(75),
        votingStart: futureDate(76),
        votingEnd: futureDate(105),
        implementationStart: futureDate(106),
      },
      stats: {
        totalFunding: 500000,
        projectsSubmitted: 12,
        projectsInEvaluation: 0,
        projectsInVoting: 0,
      },
    },
  },
}

export const EvaluationPhase: Story = {
  args: {
    edition: {
      ...mockEdition,
      phase: 'evaluation',
      dates: {
        submissionStart: pastDate(90),
        submissionEnd: pastDate(60),
        evaluationStart: pastDate(15),
        evaluationEnd: futureDate(15),
        votingStart: futureDate(16),
        votingEnd: futureDate(45),
        implementationStart: futureDate(46),
      },
      stats: {
        totalFunding: 500000,
        projectsSubmitted: 45,
        projectsInEvaluation: 32,
        projectsInVoting: 0,
      },
    },
  },
}

export const VotingPhase: Story = {
  args: {
    edition: mockEdition,
  },
}

export const ImplementationPhase: Story = {
  args: {
    edition: {
      ...mockEdition,
      phase: 'implementation',
      dates: {
        submissionStart: pastDate(150),
        submissionEnd: pastDate(120),
        evaluationStart: pastDate(120),
        evaluationEnd: pastDate(90),
        votingStart: pastDate(90),
        votingEnd: pastDate(60),
        implementationStart: pastDate(60),
      },
      stats: {
        totalFunding: 500000,
        projectsSubmitted: 45,
        projectsInEvaluation: 0,
        projectsInVoting: 0,
        projectsFunded: 18,
        totalVotes: 3500,
      },
    },
  },
}

export const CompletedPhase: Story = {
  args: {
    edition: {
      ...mockEdition,
      phase: 'completed',
      dates: {
        submissionStart: pastDate(365),
        submissionEnd: pastDate(335),
        evaluationStart: pastDate(335),
        evaluationEnd: pastDate(305),
        votingStart: pastDate(305),
        votingEnd: pastDate(275),
        implementationStart: pastDate(275),
      },
      stats: {
        totalFunding: 500000,
        projectsSubmitted: 52,
        projectsInEvaluation: 0,
        projectsInVoting: 0,
        projectsFunded: 20,
        totalVotes: 4200,
      },
    },
  },
}

export const Compact: Story = {
  args: {
    edition: mockEdition,
    compact: true,
  },
}

export const NoCountdown: Story = {
  args: {
    edition: mockEdition,
    showCountdown: false,
  },
}

export const NoPhase: Story = {
  args: {
    edition: mockEdition,
    showPhase: false,
  },
}

export const NoStats: Story = {
  args: {
    edition: mockEdition,
    showStats: false,
  },
}

export const Loading: Story = {
  args: {
    edition: mockEdition,
    loading: true,
  },
}

export const SmallBudget: Story = {
  args: {
    edition: {
      ...mockEdition,
      stats: {
        ...mockEdition.stats,
        totalFunding: 50000,
      },
    },
  },
}

export const LargeBudget: Story = {
  args: {
    edition: {
      ...mockEdition,
      stats: {
        ...mockEdition.stats,
        totalFunding: 5000000,
      },
    },
  },
}

export const ManyProjects: Story = {
  args: {
    edition: {
      ...mockEdition,
      stats: {
        ...mockEdition.stats,
        projectsSubmitted: 150,
        projectsInVoting: 80,
        totalVotes: 8500,
      },
    },
  },
}

export const FewProjects: Story = {
  args: {
    edition: {
      ...mockEdition,
      phase: 'submission',
      stats: {
        totalFunding: 500000,
        projectsSubmitted: 3,
        projectsInEvaluation: 0,
        projectsInVoting: 0,
      },
    },
  },
}

export const WithoutImplementation: Story = {
  args: {
    edition: {
      ...mockEdition,
      dates: {
        ...mockEdition.dates,
        implementationStart: undefined,
      },
    },
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { ImpulsaEditionInfo },
    setup() {
      const edition = ref<ImpulsaEdition>({
        ...mockEdition,
        phase: 'voting',
      })

      const phases: Array<{ value: typeof edition.value.phase; label: string }> = [
        { value: 'submission', label: 'Presentación' },
        { value: 'evaluation', label: 'Evaluación' },
        { value: 'voting', label: 'Votación' },
        { value: 'implementation', label: 'Implementación' },
        { value: 'completed', label: 'Completada' },
      ]

      const changePhase = (newPhase: typeof edition.value.phase) => {
        edition.value = {
          ...edition.value,
          phase: newPhase,
        }
      }

      const addVotes = () => {
        edition.value = {
          ...edition.value,
          stats: {
            ...edition.value.stats,
            totalVotes: (edition.value.stats.totalVotes || 0) + 100,
          },
        }
      }

      const addProject = () => {
        edition.value = {
          ...edition.value,
          stats: {
            ...edition.value.stats,
            projectsSubmitted: edition.value.stats.projectsSubmitted + 1,
            projectsInVoting: (edition.value.stats.projectsInVoting || 0) + 1,
          },
        }
      }

      return {
        edition,
        phases,
        changePhase,
        addVotes,
        addProject,
      }
    },
    template: `
      <div class="p-6">
        <div class="mb-6 flex flex-wrap items-center gap-4">
          <h2 class="text-2xl font-bold">Edición IMPULSA Interactiva</h2>
          <div class="flex gap-2">
            <button
              v-for="phase in phases"
              :key="phase.value"
              @click="changePhase(phase.value)"
              :class="[
                'px-3 py-1 rounded text-sm transition-colors',
                edition.phase === phase.value
                  ? 'bg-primary text-white'
                  : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
              ]"
            >
              {{ phase.label }}
            </button>
          </div>
        </div>
        <div class="mb-4 flex gap-2">
          <button
            @click="addVotes"
            class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm"
          >
            +100 Votos
          </button>
          <button
            @click="addProject"
            class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 text-sm"
          >
            +1 Proyecto
          </button>
        </div>
        <ImpulsaEditionInfo :edition="edition" />
      </div>
    `,
  }),
  args: {},
}

export const RealTimeCountdown: Story = {
  render: (args) => ({
    components: { ImpulsaEditionInfo },
    setup() {
      const edition = ref<ImpulsaEdition>({
        ...mockEdition,
        phase: 'voting',
        dates: {
          ...mockEdition.dates,
          votingStart: pastDate(1),
          votingEnd: futureDate(0.5), // Ends in 12 hours
        },
      })

      return { edition }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Countdown en Tiempo Real (12 horas restantes)</h2>
        <ImpulsaEditionInfo :edition="edition" />
      </div>
    `,
  }),
  args: {},
}

export const MultipleEditions: Story = {
  render: (args) => ({
    components: { ImpulsaEditionInfo },
    setup() {
      const editions: ImpulsaEdition[] = [
        {
          ...mockEdition,
          id: 1,
          name: 'IMPULSA 2024',
          year: 2024,
          phase: 'voting',
        },
        {
          ...mockEdition,
          id: 2,
          name: 'IMPULSA 2023',
          year: 2023,
          phase: 'completed',
          stats: {
            totalFunding: 450000,
            projectsSubmitted: 52,
            projectsInEvaluation: 0,
            projectsInVoting: 0,
            projectsFunded: 20,
            totalVotes: 4200,
          },
        },
        {
          ...mockEdition,
          id: 3,
          name: 'IMPULSA 2022',
          year: 2022,
          phase: 'completed',
          stats: {
            totalFunding: 400000,
            projectsSubmitted: 48,
            projectsInEvaluation: 0,
            projectsInVoting: 0,
            projectsFunded: 18,
            totalVotes: 3800,
          },
        },
      ]

      return { editions }
    },
    template: `
      <div class="p-6 space-y-6">
        <h2 class="text-2xl font-bold mb-6">Ediciones IMPULSA</h2>
        <ImpulsaEditionInfo
          v-for="edition in editions"
          :key="edition.id"
          :edition="edition"
        />
      </div>
    `,
  }),
  args: {},
}

export const CompactGrid: Story = {
  render: (args) => ({
    components: { ImpulsaEditionInfo },
    setup() {
      const editions: ImpulsaEdition[] = [
        { ...mockEdition, id: 1, name: 'IMPULSA 2024', year: 2024, phase: 'voting' },
        { ...mockEdition, id: 2, name: 'IMPULSA 2023', year: 2023, phase: 'completed' },
        { ...mockEdition, id: 3, name: 'IMPULSA 2022', year: 2022, phase: 'completed' },
        { ...mockEdition, id: 4, name: 'IMPULSA 2021', year: 2021, phase: 'completed' },
      ]

      return { editions }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Vista Compacta de Ediciones</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <ImpulsaEditionInfo
            v-for="edition in editions"
            :key="edition.id"
            :edition="edition"
            compact
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const DashboardView: Story = {
  render: (args) => ({
    components: { ImpulsaEditionInfo },
    setup() {
      const currentEdition: ImpulsaEdition = {
        ...mockEdition,
        phase: 'voting',
      }

      return { currentEdition }
    },
    template: `
      <div class="p-6 bg-gray-50 dark:bg-gray-900 min-h-screen">
        <div class="max-w-6xl mx-auto">
          <h1 class="text-3xl font-bold mb-2">Panel de Control IMPULSA</h1>
          <p class="text-gray-600 dark:text-gray-400 mb-8">
            Monitorea el progreso de la edición actual y las estadísticas en tiempo real
          </p>
          <ImpulsaEditionInfo :edition="currentEdition" />
        </div>
      </div>
    `,
  }),
  args: {},
}
