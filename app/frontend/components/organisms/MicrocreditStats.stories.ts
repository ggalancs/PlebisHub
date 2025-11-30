import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import MicrocreditStats from './MicrocreditStats.vue'
import type { Microcredit } from './MicrocreditCard.vue'

const meta = {
  title: 'Organisms/MicrocreditStats',
  component: MicrocreditStats,
  tags: ['autodocs'],
  argTypes: {
    microcredits: {
      control: 'object',
      description: 'List of microcredits for stats',
    },
    loading: {
      control: 'boolean',
      description: 'Loading state',
    },
    compact: {
      control: 'boolean',
      description: 'Compact mode',
    },
  },
} satisfies Meta<typeof MicrocreditStats>

export default meta
type Story = StoryObj<typeof meta>

const mockMicrocredits: Microcredit[] = [
  {
    id: '1',
    title: 'Panadería',
    description: 'Test',
    borrower: { id: 'b1', name: 'María' },
    amountRequested: 5000,
    amountFunded: 3000,
    interestRate: 5.5,
    termMonths: 12,
    status: 'funding',
    riskLevel: 'low',
    category: 'Negocio',
    investorsCount: 12,
  },
  {
    id: '2',
    title: 'Taller',
    description: 'Test',
    borrower: { id: 'b2', name: 'Carlos' },
    amountRequested: 3000,
    amountFunded: 3000,
    interestRate: 6,
    termMonths: 12,
    status: 'funded',
    riskLevel: 'medium',
    category: 'Ecología',
    investorsCount: 8,
  },
  {
    id: '3',
    title: 'Huerto',
    description: 'Test',
    borrower: { id: 'b3', name: 'Ana' },
    amountRequested: 2000,
    amountFunded: 2000,
    interestRate: 5,
    termMonths: 10,
    status: 'completed',
    riskLevel: 'low',
    category: 'Agricultura',
    investorsCount: 15,
  },
  {
    id: '4',
    title: 'Cafetería',
    description: 'Test',
    borrower: { id: 'b4', name: 'Pedro' },
    amountRequested: 8000,
    amountFunded: 6000,
    interestRate: 4.5,
    termMonths: 18,
    status: 'repaying',
    riskLevel: 'low',
    category: 'Social',
    investorsCount: 25,
  },
  {
    id: '5',
    title: 'Librería',
    description: 'Test',
    borrower: { id: 'b5', name: 'Laura' },
    amountRequested: 10000,
    amountFunded: 2000,
    interestRate: 7,
    termMonths: 24,
    status: 'defaulted',
    riskLevel: 'high',
    category: 'Cultura',
    investorsCount: 5,
  },
  {
    id: '6',
    title: 'Escuela',
    description: 'Test',
    borrower: { id: 'b6', name: 'Julia' },
    amountRequested: 4000,
    amountFunded: 4000,
    interestRate: 5,
    termMonths: 12,
    status: 'repaying',
    riskLevel: 'medium',
    category: 'Educación',
    investorsCount: 20,
  },
  {
    id: '7',
    title: 'Tienda',
    description: 'Test',
    borrower: { id: 'b7', name: 'Miguel' },
    amountRequested: 6000,
    amountFunded: 1000,
    interestRate: 8,
    termMonths: 15,
    status: 'funding',
    riskLevel: 'high',
    category: 'Negocio',
    investorsCount: 3,
  },
]

export const Default: Story = {
  args: {
    microcredits: mockMicrocredits,
  },
}

export const Empty: Story = {
  args: {
    microcredits: [],
  },
}

export const Loading: Story = {
  args: {
    microcredits: mockMicrocredits,
    loading: true,
  },
}

export const Compact: Story = {
  args: {
    microcredits: mockMicrocredits,
    compact: true,
  },
}

export const FewMicrocredits: Story = {
  args: {
    microcredits: mockMicrocredits.slice(0, 3),
  },
}

export const ManyMicrocredits: Story = {
  args: {
    microcredits: Array(50).fill(null).map((_, i) => ({
      ...mockMicrocredits[i % mockMicrocredits.length],
      id: `mc-${i}`,
    })),
  },
}

export const HighFundingRate: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      amountFunded: mc.amountRequested * 0.9,
    })),
  },
}

export const LowFundingRate: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      amountFunded: mc.amountRequested * 0.2,
    })),
  },
}

export const FullyFunded: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      amountFunded: mc.amountRequested,
      status: 'funded' as const,
    })),
  },
}

export const HighSuccessRate: Story = {
  args: {
    microcredits: mockMicrocredits.map((mc, i) => ({
      ...mc,
      status: i < 5 ? ('completed' as const) : ('defaulted' as const),
    })),
  },
}

export const LowSuccessRate: Story = {
  args: {
    microcredits: mockMicrocredits.map((mc, i) => ({
      ...mc,
      status: i < 2 ? ('completed' as const) : ('defaulted' as const),
    })),
  },
}

export const AllLowRisk: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      riskLevel: 'low' as const,
    })),
  },
}

export const AllHighRisk: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      riskLevel: 'high' as const,
    })),
  },
}

export const MixedStatuses: Story = {
  args: {
    microcredits: [
      { ...mockMicrocredits[0], status: 'pending' as const },
      { ...mockMicrocredits[1], status: 'funding' as const },
      { ...mockMicrocredits[2], status: 'funded' as const },
      { ...mockMicrocredits[3], status: 'repaying' as const },
      { ...mockMicrocredits[4], status: 'completed' as const },
      { ...mockMicrocredits[5], status: 'defaulted' as const },
    ],
  },
}

export const SingleCategory: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      category: 'Negocio',
    })),
  },
}

export const ManyCategories: Story = {
  args: {
    microcredits: Array(10).fill(null).map((_, i) => ({
      ...mockMicrocredits[0],
      id: `mc-${i}`,
      category: `Categoría ${i + 1}`,
    })),
  },
}

export const NoCategories: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      category: undefined,
    })),
  },
}

export const HighInterestRates: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      interestRate: 12,
    })),
  },
}

export const LowInterestRates: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      interestRate: 2,
    })),
  },
}

export const ShortTerms: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      termMonths: 6,
    })),
  },
}

export const LongTerms: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      termMonths: 36,
    })),
  },
}

export const ManyInvestors: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      investorsCount: 100,
    })),
  },
}

export const FewInvestors: Story = {
  args: {
    microcredits: mockMicrocredits.map(mc => ({
      ...mc,
      investorsCount: 1,
    })),
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { MicrocreditStats },
    setup() {
      const microcredits = ref<Microcredit[]>([...mockMicrocredits])

      const addMicrocredit = () => {
        microcredits.value.push({
          ...mockMicrocredits[0],
          id: `mc-${microcredits.value.length}`,
          amountRequested: Math.floor(Math.random() * 10000) + 1000,
          amountFunded: Math.floor(Math.random() * 5000),
        })
      }

      const fundRandom = () => {
        const index = Math.floor(Math.random() * microcredits.value.length)
        const mc = microcredits.value[index]
        mc.amountFunded = Math.min(mc.amountFunded + 500, mc.amountRequested)
        if (mc.amountFunded >= mc.amountRequested) {
          mc.status = 'funded'
        }
      }

      const reset = () => {
        microcredits.value = [...mockMicrocredits]
      }

      return {
        microcredits,
        addMicrocredit,
        fundRandom,
        reset,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Estadísticas Interactivas</h2>
        <div class="flex gap-2 mb-6">
          <button
            @click="addMicrocredit"
            class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Agregar Microcrédito
          </button>
          <button
            @click="fundRandom"
            class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
          >
            Financiar Aleatorio
          </button>
          <button
            @click="reset"
            class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700"
          >
            Reiniciar
          </button>
        </div>
        <MicrocreditStats :microcredits="microcredits" />
      </div>
    `,
  }),
  args: {},
}

export const RealTimeDashboard: Story = {
  render: (args) => ({
    components: { MicrocreditStats },
    setup() {
      const microcredits = ref<Microcredit[]>([...mockMicrocredits])
      const loading = ref(false)

      const simulate = () => {
        loading.value = true
        setTimeout(() => {
          microcredits.value.forEach(mc => {
            if (mc.status === 'funding' && Math.random() > 0.5) {
              mc.amountFunded = Math.min(mc.amountFunded + Math.random() * 1000, mc.amountRequested)
              mc.investorsCount = (mc.investorsCount || 0) + Math.floor(Math.random() * 3)

              if (mc.amountFunded >= mc.amountRequested) {
                mc.status = 'funded'
              }
            }
          })
          loading.value = false
        }, 1000)
      }

      // Simulate every 3 seconds
      const interval = setInterval(simulate, 3000)

      return {
        microcredits,
        loading,
        simulate,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Panel en Tiempo Real</h2>
        <p class="text-sm text-gray-600 mb-6">
          Las estadísticas se actualizan automáticamente cada 3 segundos
        </p>
        <MicrocreditStats :microcredits="microcredits" :loading="loading" />
      </div>
    `,
  }),
  args: {},
}

export const ComparisonView: Story = {
  render: (args) => ({
    components: { MicrocreditStats },
    setup() {
      const thisMonth = ref<Microcredit[]>([...mockMicrocredits])
      const lastMonth = ref<Microcredit[]>(mockMicrocredits.map(mc => ({
        ...mc,
        amountFunded: mc.amountFunded * 0.7,
        investorsCount: Math.floor((mc.investorsCount || 0) * 0.8),
      })))

      return {
        thisMonth,
        lastMonth,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Comparación de Períodos</h2>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div>
            <h3 class="text-lg font-semibold mb-4">Este Mes</h3>
            <MicrocreditStats :microcredits="thisMonth" />
          </div>
          <div>
            <h3 class="text-lg font-semibold mb-4">Mes Anterior</h3>
            <MicrocreditStats :microcredits="lastMonth" />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const ProgressOverTime: Story = {
  render: (args) => ({
    components: { MicrocreditStats },
    setup() {
      const microcredits = ref<Microcredit[]>([mockMicrocredits[0]])
      const week = ref(1)

      const nextWeek = () => {
        week.value++
        microcredits.value = mockMicrocredits.slice(0, Math.min(week.value, mockMicrocredits.length))
      }

      const prevWeek = () => {
        if (week.value > 1) {
          week.value--
          microcredits.value = mockMicrocredits.slice(0, week.value)
        }
      }

      const reset = () => {
        week.value = 1
        microcredits.value = [mockMicrocredits[0]]
      }

      return {
        microcredits,
        week,
        nextWeek,
        prevWeek,
        reset,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Progreso a lo Largo del Tiempo</h2>
        <div class="flex items-center gap-4 mb-6">
          <button
            @click="prevWeek"
            :disabled="week === 1"
            class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 disabled:opacity-50"
          >
            ← Semana Anterior
          </button>
          <span class="font-semibold">Semana {{ week }}</span>
          <button
            @click="nextWeek"
            :disabled="week === ${mockMicrocredits.length}"
            class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 disabled:opacity-50"
          >
            Semana Siguiente →
          </button>
          <button
            @click="reset"
            class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Reiniciar
          </button>
        </div>
        <MicrocreditStats :microcredits="microcredits" />
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: (args) => ({
    components: { MicrocreditStats },
    setup() {
      return { mockMicrocredits }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <MicrocreditStats :microcredits="mockMicrocredits" compact />
        </div>
      </div>
    `,
  }),
  args: {},
}
