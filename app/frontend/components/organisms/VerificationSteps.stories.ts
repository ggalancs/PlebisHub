import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import VerificationSteps from './VerificationSteps.vue'
import type { VerificationData, VerificationStep } from './VerificationSteps.vue'

const meta = {
  title: 'Organisms/VerificationSteps',
  component: VerificationSteps,
  tags: ['autodocs'],
  argTypes: {
    initialData: {
      control: 'object',
      description: 'Initial verification data',
    },
    currentStep: {
      control: 'select',
      options: ['personal', 'document', 'address', 'phone', 'review'],
      description: 'Current step',
    },
    verificationStatus: {
      control: 'select',
      options: ['not_started', 'in_progress', 'pending_review', 'verified', 'rejected'],
      description: 'Verification status',
    },
    loading: {
      control: 'boolean',
      description: 'Loading state',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    showProgress: {
      control: 'boolean',
      description: 'Show progress bar',
    },
  },
} satisfies Meta<typeof VerificationSteps>

export default meta
type Story = StoryObj<typeof meta>

const mockData: VerificationData = {
  personal: {
    firstName: 'Juan',
    lastName: 'García López',
    dateOfBirth: '1990-01-15',
    nationality: 'Española',
  },
  document: {
    documentType: 'dni',
    documentNumber: '12345678A',
    expirationDate: '2030-12-31',
  },
  address: {
    street: 'Calle Mayor',
    number: '123',
    floor: '3',
    door: 'B',
    postalCode: '28013',
    city: 'Madrid',
    province: 'Madrid',
  },
  phone: {
    countryCode: '+34',
    phoneNumber: '600123456',
    verificationCode: '123456',
  },
}

export const Default: Story = {
  args: {},
}

export const StepPersonal: Story = {
  args: {
    currentStep: 'personal',
  },
}

export const StepDocument: Story = {
  args: {
    currentStep: 'document',
  },
}

export const StepAddress: Story = {
  args: {
    currentStep: 'address',
  },
}

export const StepPhone: Story = {
  args: {
    currentStep: 'phone',
  },
}

export const StepReview: Story = {
  args: {
    currentStep: 'review',
    initialData: mockData,
  },
}

export const WithInitialData: Story = {
  args: {
    initialData: mockData,
  },
}

export const StatusNotStarted: Story = {
  args: {
    verificationStatus: 'not_started',
  },
}

export const StatusInProgress: Story = {
  args: {
    verificationStatus: 'in_progress',
    currentStep: 'document',
    initialData: {
      personal: mockData.personal,
    },
  },
}

export const StatusPendingReview: Story = {
  args: {
    verificationStatus: 'pending_review',
    currentStep: 'review',
    initialData: mockData,
  },
}

export const StatusVerified: Story = {
  args: {
    verificationStatus: 'verified',
    currentStep: 'review',
    initialData: mockData,
  },
}

export const StatusRejected: Story = {
  args: {
    verificationStatus: 'rejected',
    currentStep: 'review',
    initialData: mockData,
  },
}

export const Loading: Story = {
  args: {
    loading: true,
    currentStep: 'review',
    initialData: mockData,
  },
}

export const Disabled: Story = {
  args: {
    disabled: true,
    initialData: mockData,
  },
}

export const NoProgress: Story = {
  args: {
    showProgress: false,
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { VerificationSteps },
    setup() {
      const currentStep = ref<VerificationStep>('personal')
      const data = ref<Partial<VerificationData>>({})
      const loading = ref(false)
      const codeSent = ref(false)
      const verificationStatus = ref<'not_started' | 'in_progress' | 'pending_review' | 'verified' | 'rejected'>('not_started')

      const handleStepChange = (step: VerificationStep) => {
        console.log('Step changed to:', step)
        currentStep.value = step
        if (verificationStatus.value === 'not_started') {
          verificationStatus.value = 'in_progress'
        }
      }

      const handleSubmit = (submitData: VerificationData) => {
        console.log('Verification submitted:', submitData)
        data.value = submitData
        loading.value = true

        setTimeout(() => {
          loading.value = false
          verificationStatus.value = 'pending_review'
          alert('¡Verificación enviada! Recibirás una respuesta en las próximas 24-48 horas.')
        }, 2000)
      }

      const handleSendCode = () => {
        console.log('Sending verification code...')
        codeSent.value = true
        setTimeout(() => {
          alert('Código de verificación enviado a tu teléfono')
        }, 500)
      }

      const handleCancel = () => {
        if (confirm('¿Estás seguro de que quieres cancelar el proceso de verificación?')) {
          currentStep.value = 'personal'
          data.value = {}
          verificationStatus.value = 'not_started'
        }
      }

      return {
        currentStep,
        data,
        loading,
        codeSent,
        verificationStatus,
        handleStepChange,
        handleSubmit,
        handleSendCode,
        handleCancel,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Proceso de Verificación Interactivo</h2>
        <p class="text-sm text-gray-600 mb-6">
          Completa todos los pasos para verificar tu identidad
        </p>
        <div v-if="codeSent && currentStep === 'phone'" class="mb-4 p-4 bg-green-50 border border-green-200 rounded text-green-800">
          ✓ Código de verificación enviado
        </div>
        <VerificationSteps
          :current-step="currentStep"
          :initial-data="data"
          :loading="loading"
          :verification-status="verificationStatus"
          @step-change="handleStepChange"
          @submit="handleSubmit"
          @send-verification-code="handleSendCode"
          @cancel="handleCancel"
        />
      </div>
    `,
  }),
  args: {},
}

export const AllStepsView: Story = {
  render: () => ({
    components: { VerificationSteps },
    setup() {
      const steps: VerificationStep[] = ['personal', 'document', 'address', 'phone', 'review']
      return { steps, mockData }
    },
    template: `
      <div class="p-6 space-y-8">
        <h2 class="text-2xl font-bold mb-6">Todos los Pasos de Verificación</h2>
        <div v-for="step in steps" :key="step" class="border border-gray-200 rounded-lg p-4">
          <h3 class="font-semibold mb-4 capitalize">Paso: {{ step }}</h3>
          <VerificationSteps
            :current-step="step"
            :initial-data="mockData"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const ValidationErrors: Story = {
  render: () => ({
    components: { VerificationSteps },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Verificación con Errores de Validación</h2>
        <p class="text-sm text-gray-600 mb-6">
          Intenta avanzar sin completar los campos para ver los mensajes de error
        </p>
        <VerificationSteps />
      </div>
    `,
  }),
  args: {},
}

export const WithPartialData: Story = {
  args: {
    currentStep: 'document',
    initialData: {
      personal: mockData.personal,
    },
  },
}

export const DifferentDocumentTypes: Story = {
  render: () => ({
    components: { VerificationSteps },
    setup() {
      const documentTypes = ['dni', 'passport', 'nie', 'residence_card']
      return { documentTypes, mockData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Diferentes Tipos de Documento</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div v-for="docType in documentTypes" :key="docType">
            <h3 class="font-semibold mb-3 capitalize">{{ docType }}</h3>
            <VerificationSteps
              current-step="document"
              :initial-data="{
                ...mockData,
                document: {
                  ...mockData.document,
                  documentType: docType,
                }
              }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const ProgressComparison: Story = {
  render: () => ({
    components: { VerificationSteps },
    setup() {
      const steps: VerificationStep[] = ['personal', 'document', 'address', 'phone', 'review']
      return { steps }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Progreso en Diferentes Pasos</h2>
        <div class="space-y-6">
          <div v-for="(step, index) in steps" :key="step" class="border border-gray-200 rounded-lg p-4">
            <p class="text-sm text-gray-600 mb-2">Paso {{ index + 1 }} de {{ steps.length }} - {{ Math.round((index / (steps.length - 1)) * 100) }}% completado</p>
            <VerificationSteps
              :current-step="step"
              :show-progress="true"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const MultipleStatuses: Story = {
  render: () => ({
    components: { VerificationSteps },
    setup() {
      const statuses: Array<'not_started' | 'in_progress' | 'pending_review' | 'verified' | 'rejected'> = [
        'not_started',
        'in_progress',
        'pending_review',
        'verified',
        'rejected',
      ]
      return { statuses, mockData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Diferentes Estados de Verificación</h2>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div v-for="status in statuses" :key="status">
            <h3 class="font-semibold mb-3 capitalize">{{ status.replace('_', ' ') }}</h3>
            <VerificationSteps
              :verification-status="status"
              :current-step="status === 'not_started' ? 'personal' : 'review'"
              :initial-data="status === 'not_started' ? undefined : mockData"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: () => ({
    components: { VerificationSteps },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <VerificationSteps />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CompletionFlow: Story = {
  render: () => ({
    components: { VerificationSteps },
    setup() {
      const currentStep = ref<VerificationStep>('personal')
      const completed = ref(false)

      const handleSubmit = () => {
        completed.value = true
      }

      const restart = () => {
        currentStep.value = 'personal'
        completed.value = false
      }

      return {
        currentStep,
        completed,
        handleSubmit,
        restart,
        mockData,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Flujo Completo de Verificación</h2>
        <div v-if="!completed">
          <VerificationSteps
            :current-step="currentStep"
            :initial-data="mockData"
            @submit="handleSubmit"
          />
        </div>
        <div v-else class="text-center py-12">
          <div class="inline-flex items-center justify-center w-16 h-16 bg-green-100 dark:bg-green-900 rounded-full mb-4">
            <svg class="w-8 h-8 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
          </div>
          <h3 class="text-xl font-bold mb-2">¡Verificación Enviada!</h3>
          <p class="text-gray-600 dark:text-gray-400 mb-6">
            Tu solicitud ha sido enviada correctamente. Te notificaremos cuando haya sido revisada.
          </p>
          <button
            @click="restart"
            class="px-6 py-2 bg-primary text-white rounded hover:bg-primary-dark transition-colors"
          >
            Volver al Inicio
          </button>
        </div>
      </div>
    `,
  }),
  args: {},
}
