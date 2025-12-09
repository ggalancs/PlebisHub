import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import VerificationStatus from './VerificationStatus.vue'
import type { VerificationItem, VerificationLevel } from './VerificationStatus.vue'

const meta = {
  title: 'Organisms/VerificationStatus',
  component: VerificationStatus,
  tags: ['autodocs'],
  argTypes: {
    level: {
      control: 'select',
      options: ['none', 'basic', 'standard', 'advanced', 'complete'],
      description: 'Current verification level',
    },
    items: {
      control: 'object',
      description: 'Verification items',
    },
    showProgress: {
      control: 'boolean',
      description: 'Show progress bar',
    },
    showDetails: {
      control: 'boolean',
      description: 'Show item details',
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
} satisfies Meta<typeof VerificationStatus>

export default meta
type Story = StoryObj<typeof meta>

const mockItems: VerificationItem[] = [
  {
    id: '1',
    label: 'Datos Personales',
    description: 'Verificación de nombre y fecha de nacimiento',
    status: 'completed',
    required: true,
    completedAt: '2024-01-15',
  },
  {
    id: '2',
    label: 'Documento de Identidad',
    description: 'Verificación de DNI o Pasaporte',
    status: 'completed',
    required: true,
    completedAt: '2024-01-20',
    expiresAt: '2029-01-20',
  },
  {
    id: '3',
    label: 'Dirección',
    description: 'Verificación de domicilio',
    status: 'pending',
    required: true,
  },
  {
    id: '4',
    label: 'Teléfono',
    description: 'Verificación de número telefónico',
    status: 'pending',
    required: false,
  },
]

export const Default: Story = {
  args: {
    level: 'standard',
    items: mockItems,
  },
}

export const LevelNone: Story = {
  args: {
    level: 'none',
    items: [],
  },
}

export const LevelBasic: Story = {
  args: {
    level: 'basic',
    items: [mockItems[0]],
  },
}

export const LevelStandard: Story = {
  args: {
    level: 'standard',
    items: mockItems,
  },
}

export const LevelAdvanced: Story = {
  args: {
    level: 'advanced',
    items: mockItems,
  },
}

export const LevelComplete: Story = {
  args: {
    level: 'complete',
    items: mockItems.map(item => ({ ...item, status: 'completed' as const })),
  },
}

export const AllCompleted: Story = {
  args: {
    level: 'complete',
    items: mockItems.map(item => ({
      ...item,
      status: 'completed' as const,
      completedAt: '2024-01-20',
    })),
  },
}

export const AllPending: Story = {
  args: {
    level: 'none',
    items: mockItems.map(item => ({
      ...item,
      status: 'pending' as const,
    })),
  },
}

export const WithRejected: Story = {
  args: {
    level: 'basic',
    items: [
      {
        ...mockItems[0],
        status: 'rejected' as const,
        rejectionReason: 'El documento proporcionado no es legible. Por favor, sube una imagen de mejor calidad.',
      },
      ...mockItems.slice(1),
    ],
  },
}

export const WithExpired: Story = {
  args: {
    level: 'standard',
    items: [
      mockItems[0],
      {
        ...mockItems[1],
        status: 'expired' as const,
        expiresAt: '2020-01-01',
      },
      ...mockItems.slice(2),
    ],
  },
}

export const NoDetails: Story = {
  args: {
    level: 'standard',
    items: mockItems,
    showDetails: false,
  },
}

export const NoProgress: Story = {
  args: {
    level: 'standard',
    items: mockItems,
    showProgress: false,
  },
}

export const Compact: Story = {
  args: {
    level: 'standard',
    items: mockItems,
    compact: true,
  },
}

export const Loading: Story = {
  args: {
    level: 'standard',
    items: mockItems,
    loading: true,
  },
}

export const OnlyRequired: Story = {
  args: {
    level: 'standard',
    items: mockItems.filter(item => item.required),
  },
}

export const OnlyOptional: Story = {
  args: {
    level: 'basic',
    items: mockItems.filter(item => !item.required),
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { VerificationStatus },
    setup() {
      const level = ref<VerificationLevel>('basic')
      const items = ref<VerificationItem[]>([...mockItems])

      const handleVerifyItem = (itemId: string) => {
        console.log('Verifying item:', itemId)
        const item = items.value.find(i => i.id === itemId)
        if (item) {
          item.status = 'completed'
          item.completedAt = new Date().toISOString()
          updateLevel()
        }
      }

      const handleResubmit = (itemId: string) => {
        console.log('Resubmitting item:', itemId)
        const item = items.value.find(i => i.id === itemId)
        if (item) {
          item.status = 'pending'
          item.rejectionReason = undefined
        }
      }

      const handleStartVerification = () => {
        console.log('Starting verification')
        alert('Comenzando proceso de verificación...')
      }

      const updateLevel = () => {
        const completed = items.value.filter(i => i.status === 'completed').length
        const total = items.value.length

        if (completed === 0) level.value = 'none'
        else if (completed === 1) level.value = 'basic'
        else if (completed === 2) level.value = 'standard'
        else if (completed === 3) level.value = 'advanced'
        else level.value = 'complete'
      }

      const simulateRejection = () => {
        const pending = items.value.find(i => i.status === 'pending')
        if (pending) {
          pending.status = 'rejected'
          pending.rejectionReason = 'Documento no válido. Por favor, vuelve a intentarlo.'
        }
      }

      return {
        level,
        items,
        handleVerifyItem,
        handleResubmit,
        handleStartVerification,
        simulateRejection,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Estado de Verificación Interactivo</h2>
        <p class="text-sm text-gray-600 mb-4">
          Haz clic en "Verificar" para completar cada elemento
        </p>
        <button
          @click="simulateRejection"
          class="mb-4 px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 text-sm"
        >
          Simular Rechazo
        </button>
        <VerificationStatus
          :level="level"
          :items="items"
          @verify-item="handleVerifyItem"
          @resubmit="handleResubmit"
          @start-verification="handleStartVerification"
        />
      </div>
    `,
  }),
  args: {},
}

export const AllLevels: Story = {
  render: () => ({
    components: { VerificationStatus },
    setup() {
      const levels: Array<{ level: VerificationLevel; items: VerificationItem[] }> = [
        { level: 'none', items: [] },
        { level: 'basic', items: [mockItems[0]] },
        { level: 'standard', items: mockItems.slice(0, 2) },
        { level: 'advanced', items: mockItems.slice(0, 3) },
        { level: 'complete', items: mockItems.map(i => ({ ...i, status: 'completed' as const })) },
      ]
      return { levels }
    },
    template: `
      <div class="p-6 space-y-8">
        <h2 class="text-2xl font-bold mb-6">Todos los Niveles de Verificación</h2>
        <div v-for="({ level, items }, index) in levels" :key="index">
          <h3 class="text-lg font-semibold mb-4 capitalize">{{ level }}</h3>
          <VerificationStatus :level="level" :items="items" />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const DifferentStatuses: Story = {
  render: () => ({
    components: { VerificationStatus },
    setup() {
      const scenarios = [
        {
          title: 'Todo Completado',
          items: mockItems.map(i => ({ ...i, status: 'completed' as const, completedAt: '2024-01-20' })),
        },
        {
          title: 'Con Rechazos',
          items: [
            { ...mockItems[0], status: 'rejected' as const, rejectionReason: 'Documento ilegible' },
            ...mockItems.slice(1),
          ],
        },
        {
          title: 'Con Expirados',
          items: [
            mockItems[0],
            { ...mockItems[1], status: 'expired' as const, expiresAt: '2020-01-01' },
            ...mockItems.slice(2),
          ],
        },
        {
          title: 'Todo Pendiente',
          items: mockItems.map(i => ({ ...i, status: 'pending' as const })),
        },
      ]
      return { scenarios }
    },
    template: `
      <div class="p-6 space-y-8">
        <h2 class="text-2xl font-bold mb-6">Diferentes Estados</h2>
        <div v-for="scenario in scenarios" :key="scenario.title">
          <h3 class="text-lg font-semibold mb-4">{{ scenario.title }}</h3>
          <VerificationStatus level="standard" :items="scenario.items" />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const ProgressionFlow: Story = {
  render: () => ({
    components: { VerificationStatus },
    setup() {
      const currentStep = ref(0)
      const progressSteps = [
        {
          level: 'none' as VerificationLevel,
          items: mockItems.map(i => ({ ...i, status: 'pending' as const })),
          label: 'Inicio',
        },
        {
          level: 'basic' as VerificationLevel,
          items: [
            { ...mockItems[0], status: 'completed' as const, completedAt: '2024-01-15' },
            ...mockItems.slice(1).map(i => ({ ...i, status: 'pending' as const })),
          ],
          label: 'Primer paso completado',
        },
        {
          level: 'standard' as VerificationLevel,
          items: [
            { ...mockItems[0], status: 'completed' as const, completedAt: '2024-01-15' },
            { ...mockItems[1], status: 'completed' as const, completedAt: '2024-01-16' },
            ...mockItems.slice(2).map(i => ({ ...i, status: 'pending' as const })),
          ],
          label: 'Dos pasos completados',
        },
        {
          level: 'advanced' as VerificationLevel,
          items: [
            { ...mockItems[0], status: 'completed' as const, completedAt: '2024-01-15' },
            { ...mockItems[1], status: 'completed' as const, completedAt: '2024-01-16' },
            { ...mockItems[2], status: 'completed' as const, completedAt: '2024-01-17' },
            { ...mockItems[3], status: 'pending' as const },
          ],
          label: 'Tres pasos completados',
        },
        {
          level: 'complete' as VerificationLevel,
          items: mockItems.map((i, index) => ({
            ...i,
            status: 'completed' as const,
            completedAt: `2024-01-${15 + index}`,
          })),
          label: 'Verificación completa',
        },
      ]

      const next = () => {
        if (currentStep.value < progressSteps.length - 1) {
          currentStep.value++
        }
      }

      const previous = () => {
        if (currentStep.value > 0) {
          currentStep.value--
        }
      }

      const reset = () => {
        currentStep.value = 0
      }

      return {
        currentStep,
        progressSteps,
        next,
        previous,
        reset,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Flujo de Progresión</h2>
        <p class="text-sm text-gray-600 mb-4">
          Paso {{ currentStep + 1 }} de {{ progressSteps.length }}: {{ progressSteps[currentStep].label }}
        </p>
        <div class="mb-6 flex gap-2">
          <button
            @click="previous"
            :disabled="currentStep === 0"
            class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            ← Anterior
          </button>
          <button
            @click="next"
            :disabled="currentStep === progressSteps.length - 1"
            class="px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Siguiente →
          </button>
          <button
            @click="reset"
            class="px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400"
          >
            Reiniciar
          </button>
        </div>
        <VerificationStatus
          :level="progressSteps[currentStep].level"
          :items="progressSteps[currentStep].items"
        />
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: () => ({
    components: { VerificationStatus },
    setup() {
      return { mockItems }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <VerificationStatus level="standard" :items="mockItems" />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CompactGrid: Story = {
  render: () => ({
    components: { VerificationStatus },
    setup() {
      const levels: VerificationLevel[] = ['basic', 'standard', 'advanced', 'complete']
      return { levels, mockItems }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Vista Compacta en Grid</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <VerificationStatus
            v-for="level in levels"
            :key="level"
            :level="level"
            :items="mockItems"
            compact
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const WithExpiringItems: Story = {
  args: {
    level: 'advanced',
    items: [
      mockItems[0],
      {
        ...mockItems[1],
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(), // Expires in 30 days
      },
      ...mockItems.slice(2),
    ],
  },
}
