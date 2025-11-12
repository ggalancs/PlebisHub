import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ImpulsaProjectSteps from './ImpulsaProjectSteps.vue'
import type { ProjectStep } from './ImpulsaProjectSteps.vue'

const meta = {
  title: 'Organisms/ImpulsaProjectSteps',
  component: ImpulsaProjectSteps,
  tags: ['autodocs'],
  argTypes: {
    steps: {
      control: 'object',
      description: 'Array of project steps',
    },
    currentStep: {
      control: 'text',
      description: 'ID of current step',
    },
    orientation: {
      control: 'select',
      options: ['horizontal', 'vertical'],
      description: 'Layout orientation',
    },
    showDescriptions: {
      control: 'boolean',
      description: 'Show step descriptions',
    },
    showDates: {
      control: 'boolean',
      description: 'Show step dates',
    },
    clickable: {
      control: 'boolean',
      description: 'Enable step clicking',
    },
    compact: {
      control: 'boolean',
      description: 'Compact mode',
    },
  },
} satisfies Meta<typeof ImpulsaProjectSteps>

export default meta
type Story = StoryObj<typeof meta>

const mockSteps: ProjectStep[] = [
  {
    id: '1',
    label: 'Presentación',
    description: 'Envía tu proyecto para evaluación inicial',
    icon: 'file-plus',
    status: 'completed',
    date: '2024-01-15',
  },
  {
    id: '2',
    label: 'Evaluación',
    description: 'El equipo técnico revisa tu proyecto',
    icon: 'clipboard-check',
    status: 'completed',
    date: '2024-02-01',
  },
  {
    id: '3',
    label: 'Votación',
    description: 'Los ciudadanos votan tu proyecto',
    icon: 'check-circle',
    status: 'current',
  },
  {
    id: '4',
    label: 'Financiación',
    description: 'Proyecto financiado y en implementación',
    icon: 'dollar-sign',
    status: 'pending',
  },
]

export const Default: Story = {
  args: {
    steps: mockSteps,
  },
}

export const Horizontal: Story = {
  args: {
    steps: mockSteps,
    orientation: 'horizontal',
  },
}

export const Vertical: Story = {
  args: {
    steps: mockSteps,
    orientation: 'vertical',
  },
}

export const WithDates: Story = {
  args: {
    steps: mockSteps,
    showDates: true,
  },
}

export const WithoutDescriptions: Story = {
  args: {
    steps: mockSteps,
    showDescriptions: false,
  },
}

export const Clickable: Story = {
  args: {
    steps: mockSteps,
    clickable: true,
  },
}

export const Compact: Story = {
  args: {
    steps: mockSteps,
    compact: true,
  },
}

export const CompactVertical: Story = {
  args: {
    steps: mockSteps,
    orientation: 'vertical',
    compact: true,
  },
}

export const AllCompleted: Story = {
  args: {
    steps: mockSteps.map(s => ({ ...s, status: 'completed' as const })),
  },
}

export const AllPending: Story = {
  args: {
    steps: mockSteps.map(s => ({ ...s, status: 'pending' as const })),
  },
}

export const FirstStepCurrent: Story = {
  args: {
    steps: mockSteps.map((s, i) => ({
      ...s,
      status: (i === 0 ? 'current' : 'pending') as const,
    })),
  },
}

export const WithSkippedStep: Story = {
  args: {
    steps: [
      { ...mockSteps[0], status: 'completed' as const },
      { ...mockSteps[1], status: 'skipped' as const, description: 'Esta etapa fue omitida' },
      { ...mockSteps[2], status: 'current' as const },
      mockSteps[3],
    ],
  },
}

export const ManySteps: Story = {
  args: {
    steps: [
      {
        id: '1',
        label: 'Registro',
        description: 'Crea tu cuenta',
        status: 'completed',
      },
      {
        id: '2',
        label: 'Verificación',
        description: 'Verifica tu identidad',
        status: 'completed',
      },
      {
        id: '3',
        label: 'Información Básica',
        description: 'Completa los datos básicos',
        status: 'completed',
      },
      {
        id: '4',
        label: 'Detalles del Proyecto',
        description: 'Describe tu proyecto',
        status: 'current',
      },
      {
        id: '5',
        label: 'Presupuesto',
        description: 'Define el presupuesto',
        status: 'pending',
      },
      {
        id: '6',
        label: 'Equipo',
        description: 'Presenta tu equipo',
        status: 'pending',
      },
      {
        id: '7',
        label: 'Documentación',
        description: 'Adjunta documentos',
        status: 'pending',
      },
      {
        id: '8',
        label: 'Revisión',
        description: 'Revisa y envía',
        status: 'pending',
      },
    ],
    orientation: 'vertical',
  },
}

export const ThreeSteps: Story = {
  args: {
    steps: [
      {
        id: '1',
        label: 'Inicio',
        description: 'Comienza tu proyecto',
        status: 'completed',
      },
      {
        id: '2',
        label: 'Desarrollo',
        description: 'Trabaja en tu proyecto',
        status: 'current',
      },
      {
        id: '3',
        label: 'Finalización',
        description: 'Completa tu proyecto',
        status: 'pending',
      },
    ],
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { ImpulsaProjectSteps },
    setup() {
      const steps = ref<ProjectStep[]>([...mockSteps])
      const currentStepId = ref('3')

      const handleStepClick = (step: ProjectStep) => {
        console.log('Step clicked:', step.label)
        currentStepId.value = step.id

        // Update step statuses
        const currentIndex = steps.value.findIndex(s => s.id === step.id)
        steps.value = steps.value.map((s, index) => ({
          ...s,
          status:
            index < currentIndex
              ? 'completed'
              : index === currentIndex
              ? 'current'
              : 'pending',
        })) as ProjectStep[]
      }

      const nextStep = () => {
        const currentIndex = steps.value.findIndex(s => s.id === currentStepId.value)
        if (currentIndex < steps.value.length - 1) {
          const nextStep = steps.value[currentIndex + 1]
          handleStepClick(nextStep)
        }
      }

      const prevStep = () => {
        const currentIndex = steps.value.findIndex(s => s.id === currentStepId.value)
        if (currentIndex > 0) {
          const prevStep = steps.value[currentIndex - 1]
          handleStepClick(prevStep)
        }
      }

      const reset = () => {
        steps.value = [
          { ...mockSteps[0], status: 'current' },
          ...mockSteps.slice(1).map(s => ({ ...s, status: 'pending' as const })),
        ]
        currentStepId.value = '1'
      }

      return {
        steps,
        currentStepId,
        handleStepClick,
        nextStep,
        prevStep,
        reset,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Stepper Interactivo</h2>
        <p class="text-sm text-gray-600 mb-6">
          Haz clic en los pasos o usa los botones para navegar
        </p>
        <div class="mb-6 flex gap-3">
          <button
            @click="prevStep"
            class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed"
            :disabled="currentStepId === '1'"
          >
            ← Anterior
          </button>
          <button
            @click="nextStep"
            class="px-4 py-2 bg-primary text-white rounded hover:bg-primary-dark disabled:opacity-50 disabled:cursor-not-allowed"
            :disabled="currentStepId === '4'"
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
        <ImpulsaProjectSteps
          :steps="steps"
          :current-step="currentStepId"
          :clickable="true"
          @step-click="handleStepClick"
        />
      </div>
    `,
  }),
  args: {},
}

export const OrientationComparison: Story = {
  render: (args) => ({
    components: { ImpulsaProjectSteps },
    setup() {
      return { mockSteps }
    },
    template: `
      <div class="p-6 space-y-12">
        <div>
          <h3 class="text-xl font-bold mb-4">Horizontal</h3>
          <ImpulsaProjectSteps :steps="mockSteps" orientation="horizontal" />
        </div>
        <div>
          <h3 class="text-xl font-bold mb-4">Vertical</h3>
          <ImpulsaProjectSteps :steps="mockSteps" orientation="vertical" />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const WithAndWithoutDescriptions: Story = {
  render: (args) => ({
    components: { ImpulsaProjectSteps },
    setup() {
      return { mockSteps }
    },
    template: `
      <div class="p-6 space-y-12">
        <div>
          <h3 class="text-xl font-bold mb-4">Con Descripciones</h3>
          <ImpulsaProjectSteps :steps="mockSteps" :show-descriptions="true" />
        </div>
        <div>
          <h3 class="text-xl font-bold mb-4">Sin Descripciones</h3>
          <ImpulsaProjectSteps :steps="mockSteps" :show-descriptions="false" />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const ProjectSubmissionFlow: Story = {
  render: (args) => ({
    components: { ImpulsaProjectSteps },
    setup() {
      const submissionSteps: ProjectStep[] = [
        {
          id: 'draft',
          label: 'Borrador',
          description: 'Guarda tu proyecto como borrador',
          icon: 'edit',
          status: 'completed',
          date: '2024-01-10',
        },
        {
          id: 'submit',
          label: 'Presentado',
          description: 'Proyecto enviado para revisión',
          icon: 'send',
          status: 'completed',
          date: '2024-01-15',
        },
        {
          id: 'review',
          label: 'En Revisión',
          description: 'El equipo está revisando tu proyecto',
          icon: 'search',
          status: 'current',
        },
        {
          id: 'approved',
          label: 'Aprobado',
          description: 'Proyecto aprobado para votación',
          icon: 'check',
          status: 'pending',
        },
        {
          id: 'voting',
          label: 'Votación',
          description: 'Proyecto disponible para votación ciudadana',
          icon: 'users',
          status: 'pending',
        },
        {
          id: 'funded',
          label: 'Financiado',
          description: 'Proyecto recibe financiación',
          icon: 'award',
          status: 'pending',
        },
      ]

      return { submissionSteps }
    },
    template: `
      <div class="p-6 bg-gradient-to-br from-blue-50 to-purple-50 dark:from-gray-900 dark:to-gray-800 rounded-lg">
        <h2 class="text-2xl font-bold mb-2">Flujo de Presentación de Proyecto</h2>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-8">
          Sigue estos pasos para completar la presentación de tu proyecto IMPULSA
        </p>
        <div class="bg-white dark:bg-gray-800 p-6 rounded-lg shadow">
          <ImpulsaProjectSteps
            :steps="submissionSteps"
            orientation="vertical"
            :show-dates="true"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const MobilePreview: Story = {
  render: (args) => ({
    components: { ImpulsaProjectSteps },
    setup() {
      return { mockSteps }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <ImpulsaProjectSteps :steps="mockSteps" />
        </div>
      </div>
    `,
  }),
  args: {},
}
