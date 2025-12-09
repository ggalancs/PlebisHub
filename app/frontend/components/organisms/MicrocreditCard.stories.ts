import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import MicrocreditCard from './MicrocreditCard.vue'
import type { Microcredit } from './MicrocreditCard.vue'

const meta = {
  title: 'Organisms/MicrocreditCard',
  component: MicrocreditCard,
  tags: ['autodocs'],
  argTypes: {
    microcredit: {
      control: 'object',
      description: 'Microcredit data',
    },
    showInvestButton: {
      control: 'boolean',
      description: 'Show invest button',
    },
    hasInvested: {
      control: 'boolean',
      description: 'User has invested',
    },
    compact: {
      control: 'boolean',
      description: 'Compact mode',
    },
    loading: {
      control: 'boolean',
      description: 'Loading state',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
  },
} satisfies Meta<typeof MicrocreditCard>

export default meta
type Story = StoryObj<typeof meta>

const mockMicrocredit: Microcredit = {
  id: '1',
  title: 'Expansión de Panadería Local',
  description: 'Necesito financiación para comprar un horno industrial y expandir mi panadería artesanal en el barrio',
  borrower: {
    id: 'borrower-1',
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
  deadline: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000).toISOString(),
  investorsCount: 12,
  minimumInvestment: 100,
  imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&h=400&fit=crop',
}

export const Default: Story = {
  args: {
    microcredit: mockMicrocredit,
  },
}

export const HasInvested: Story = {
  args: {
    microcredit: mockMicrocredit,
    hasInvested: true,
  },
}

export const StatusPending: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      status: 'pending',
    },
  },
}

export const StatusFunding: Story = {
  args: {
    microcredit: mockMicrocredit,
  },
}

export const StatusFunded: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      status: 'funded',
      amountFunded: 5000,
    },
  },
}

export const StatusRepaying: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      status: 'repaying',
      amountFunded: 5000,
    },
  },
}

export const StatusCompleted: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      status: 'completed',
      amountFunded: 5000,
    },
  },
}

export const StatusDefaulted: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      status: 'defaulted',
    },
  },
}

export const RiskLow: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      riskLevel: 'low',
    },
  },
}

export const RiskMedium: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      riskLevel: 'medium',
    },
  },
}

export const RiskHigh: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      riskLevel: 'high',
    },
  },
}

export const NoRisk: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      riskLevel: undefined,
    },
  },
}

export const AlmostFunded: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      amountFunded: 4800,
    },
  },
}

export const FullyFunded: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      amountFunded: 5000,
    },
  },
}

export const JustStarted: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      amountFunded: 500,
      investorsCount: 2,
    },
  },
}

export const NoImage: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      imageUrl: undefined,
    },
  },
}

export const NoCategory: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      category: undefined,
    },
  },
}

export const NoMinimumInvestment: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      minimumInvestment: undefined,
    },
  },
}

export const HighInterest: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      interestRate: 12,
      riskLevel: 'high',
    },
  },
}

export const ShortTerm: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      termMonths: 6,
    },
  },
}

export const LongTerm: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      termMonths: 24,
    },
  },
}

export const LowInvestment: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      minimumInvestment: 25,
    },
  },
}

export const HighInvestment: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      minimumInvestment: 500,
    },
  },
}

export const ManyInvestors: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      investorsCount: 50,
      amountFunded: 4500,
    },
  },
}

export const FewInvestors: Story = {
  args: {
    microcredit: {
      ...mockMicrocredit,
      investorsCount: 2,
      amountFunded: 500,
    },
  },
}

export const Compact: Story = {
  args: {
    microcredit: mockMicrocredit,
    compact: true,
  },
}

export const Loading: Story = {
  args: {
    microcredit: mockMicrocredit,
    loading: true,
  },
}

export const Disabled: Story = {
  args: {
    microcredit: mockMicrocredit,
    disabled: true,
  },
}

export const NoInvestButton: Story = {
  args: {
    microcredit: mockMicrocredit,
    showInvestButton: false,
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { MicrocreditCard },
    setup() {
      const microcredit = ref<Microcredit>({ ...mockMicrocredit })
      const hasInvested = ref(false)
      const investmentAmount = ref(100)

      const handleInvest = (microcreditId: string) => {
        console.log('Investing in:', microcreditId)
        hasInvested.value = true
        microcredit.value.amountFunded += investmentAmount.value
        microcredit.value.investorsCount! += 1

        if (microcredit.value.amountFunded >= microcredit.value.amountRequested) {
          microcredit.value.status = 'funded'
        }

        alert(`¡Has invertido ${investmentAmount.value}€ en ${microcredit.value.title}!`)
      }

      const handleViewDetails = (microcreditId: string) => {
        console.log('Viewing details for:', microcreditId)
        alert('Abriendo detalles del microcrédito...')
      }

      const handleContactBorrower = (borrowerId: string) => {
        console.log('Contacting borrower:', borrowerId)
        alert(`Enviando mensaje a ${microcredit.value.borrower.name}...`)
      }

      return {
        microcredit,
        hasInvested,
        investmentAmount,
        handleInvest,
        handleViewDetails,
        handleContactBorrower,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Tarjeta de Microcrédito Interactiva</h2>
        <p class="text-sm text-gray-600 mb-2">
          Estado: {{ hasInvested ? 'Has invertido' : 'No has invertido' }}
        </p>
        <div class="mb-4">
          <label class="text-sm font-medium text-gray-700 mb-2 block">
            Cantidad a invertir: {{ investmentAmount }}€
          </label>
          <input
            v-model.number="investmentAmount"
            type="range"
            min="100"
            max="500"
            step="50"
            class="w-full"
          />
        </div>
        <MicrocreditCard
          :microcredit="microcredit"
          :has-invested="hasInvested"
          @invest="handleInvest"
          @view-details="handleViewDetails"
          @contact-borrower="handleContactBorrower"
        />
      </div>
    `,
  }),
  args: {},
}

export const DifferentMicrocredits: Story = {
  render: () => ({
    components: { MicrocreditCard },
    setup() {
      const microcredits: Microcredit[] = [
        {
          id: '1',
          title: 'Cafetería Comunitaria',
          description: 'Abrir una cafetería que emplee a personas en riesgo de exclusión social',
          borrower: {
            id: 'b1',
            name: 'Carlos Ruiz',
            avatar: 'https://i.pravatar.cc/150?img=12',
            location: 'Barcelona',
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
          id: '2',
          title: 'Taller de Reparación de Bicicletas',
          description: 'Equipamiento para taller de reparación y mantenimiento de bicicletas',
          borrower: {
            id: 'b2',
            name: 'Ana López',
            avatar: 'https://i.pravatar.cc/150?img=5',
            location: 'Valencia',
            rating: 4,
          },
          amountRequested: 3000,
          amountFunded: 2100,
          interestRate: 6,
          termMonths: 12,
          status: 'funding',
          riskLevel: 'medium',
          category: 'Ecología',
          investorsCount: 8,
          minimumInvestment: 100,
          imageUrl: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=800&h=400&fit=crop',
        },
        {
          id: '3',
          title: 'Huerto Urbano Cooperativo',
          description: 'Financiación para materiales y herramientas de huerto urbano compartido',
          borrower: {
            id: 'b3',
            name: 'Pedro Martínez',
            avatar: 'https://i.pravatar.cc/150?img=8',
            location: 'Sevilla',
            rating: 3,
          },
          amountRequested: 2000,
          amountFunded: 2000,
          interestRate: 5,
          termMonths: 10,
          status: 'funded',
          riskLevel: 'medium',
          category: 'Agricultura',
          investorsCount: 15,
          minimumInvestment: 25,
        },
        {
          id: '4',
          title: 'Librería Independiente',
          description: 'Expansión de librería local con enfoque en autores locales',
          borrower: {
            id: 'b4',
            name: 'Laura Sánchez',
            avatar: 'https://i.pravatar.cc/150?img=9',
            location: 'Bilbao',
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
      ]
      return { microcredits }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Diferentes Microcréditos</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <MicrocreditCard
            v-for="microcredit in microcredits"
            :key="microcredit.id"
            :microcredit="microcredit"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const AllStatuses: Story = {
  render: () => ({
    components: { MicrocreditCard },
    setup() {
      const statuses: Array<{ status: 'pending' | 'funding' | 'funded' | 'repaying' | 'completed' | 'defaulted'; amountFunded: number }> = [
        { status: 'pending', amountFunded: 0 },
        { status: 'funding', amountFunded: 3000 },
        { status: 'funded', amountFunded: 5000 },
        { status: 'repaying', amountFunded: 5000 },
        { status: 'completed', amountFunded: 5000 },
        { status: 'defaulted', amountFunded: 3000 },
      ]
      return { statuses, mockMicrocredit }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Todos los Estados</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="({ status, amountFunded }, index) in statuses" :key="index">
            <h3 class="font-semibold mb-3 capitalize">{{ status }}</h3>
            <MicrocreditCard
              :microcredit="{ ...mockMicrocredit, status, amountFunded }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const AllRiskLevels: Story = {
  render: () => ({
    components: { MicrocreditCard },
    setup() {
      const levels: Array<'low' | 'medium' | 'high'> = ['low', 'medium', 'high']
      return { levels, mockMicrocredit }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Todos los Niveles de Riesgo</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div v-for="level in levels" :key="level">
            <h3 class="font-semibold mb-3 capitalize">{{ level }} Risk</h3>
            <MicrocreditCard
              :microcredit="{ ...mockMicrocredit, riskLevel: level }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const FundingProgress: Story = {
  render: () => ({
    components: { MicrocreditCard },
    setup() {
      const progressLevels = [
        { label: '10%', amountFunded: 500 },
        { label: '25%', amountFunded: 1250 },
        { label: '50%', amountFunded: 2500 },
        { label: '75%', amountFunded: 3750 },
        { label: '100%', amountFunded: 5000 },
      ]
      return { progressLevels, mockMicrocredit }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Niveles de Progreso de Financiación</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="progress in progressLevels" :key="progress.label">
            <h3 class="font-semibold mb-3">{{ progress.label }} Financiado</h3>
            <MicrocreditCard
              :microcredit="{ ...mockMicrocredit, amountFunded: progress.amountFunded }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CompactGrid: Story = {
  render: () => ({
    components: { MicrocreditCard },
    setup() {
      const microcredits: Microcredit[] = Array(6).fill(null).map((_, i) => ({
        ...mockMicrocredit,
        id: `mc-${i}`,
        title: `Proyecto ${i + 1}`,
        amountFunded: Math.floor(Math.random() * 5000),
      }))
      return { microcredits }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Grid de Tarjetas Compactas</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <MicrocreditCard
            v-for="microcredit in microcredits"
            :key="microcredit.id"
            :microcredit="microcredit"
            compact
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: () => ({
    components: { MicrocreditCard },
    setup() {
      return { mockMicrocredit }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <MicrocreditCard :microcredit="mockMicrocredit" />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const InvestmentFlow: Story = {
  render: () => ({
    components: { MicrocreditCard },
    setup() {
      const microcredit = ref<Microcredit>({
        ...mockMicrocredit,
        amountFunded: 4500,
      })
      const hasInvested = ref(false)
      const totalInvested = ref(0)

      const handleInvest = () => {
        const amount = 500
        totalInvested.value += amount
        hasInvested.value = true
        microcredit.value.amountFunded += amount
        microcredit.value.investorsCount! += 1

        if (microcredit.value.amountFunded >= microcredit.value.amountRequested) {
          microcredit.value.status = 'funded'
        }
      }

      const reset = () => {
        microcredit.value = { ...mockMicrocredit, amountFunded: 4500 }
        hasInvested.value = false
        totalInvested.value = 0
      }

      return {
        microcredit,
        hasInvested,
        totalInvested,
        handleInvest,
        reset,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Flujo de Inversión</h2>
        <p class="text-sm text-gray-600 mb-2">
          El microcrédito está casi financiado. Invierte para completarlo.
        </p>
        <p class="text-sm text-gray-600 mb-6">
          Total invertido: {{ totalInvested }}€
        </p>
        <MicrocreditCard
          :microcredit="microcredit"
          :has-invested="hasInvested"
          @invest="handleInvest"
        />
        <button
          @click="reset"
          class="mt-4 px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 text-sm"
        >
          Reiniciar
        </button>
      </div>
    `,
  }),
  args: {},
}

export const WithoutOptionalFields: Story = {
  args: {
    microcredit: {
      id: '1',
      title: 'Microcrédito Mínimo',
      description: 'Microcrédito con campos mínimos requeridos para demostrar flexibilidad',
      borrower: {
        id: 'borrower-1',
        name: 'Usuario Simple',
      },
      amountRequested: 1000,
      amountFunded: 500,
      interestRate: 5,
      termMonths: 6,
      status: 'funding',
    },
  },
}
