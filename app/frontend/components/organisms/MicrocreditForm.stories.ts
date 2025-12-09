import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import MicrocreditForm from './MicrocreditForm.vue'
import type { MicrocreditFormData } from './MicrocreditForm.vue'

const meta = {
  title: 'Organisms/MicrocreditForm',
  component: MicrocreditForm,
  tags: ['autodocs'],
  argTypes: {
    initialData: {
      control: 'object',
      description: 'Initial form data',
    },
    mode: {
      control: 'select',
      options: ['create', 'edit'],
      description: 'Form mode',
    },
    loading: {
      control: 'boolean',
      description: 'Loading state',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    showCancel: {
      control: 'boolean',
      description: 'Show cancel button',
    },
    compact: {
      control: 'boolean',
      description: 'Compact mode',
    },
  },
} satisfies Meta<typeof MicrocreditForm>

export default meta
type Story = StoryObj<typeof meta>

const mockData: Partial<MicrocreditFormData> = {
  title: 'Expansión de Panadería Local',
  description: 'Necesito financiación para comprar un horno industrial y expandir mi panadería artesanal en el barrio. Los fondos se utilizarán para equipamiento y materia prima de calidad.',
  amountRequested: 5000,
  interestRate: 5.5,
  termMonths: 12,
  riskLevel: 'low',
  category: 'Negocio',
  deadline: '2025-12-31',
  minimumInvestment: 100,
  imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&h=400&fit=crop',
}

export const Default: Story = {
  args: {},
}

export const CreateMode: Story = {
  args: {
    mode: 'create',
  },
}

export const EditMode: Story = {
  args: {
    mode: 'edit',
    initialData: mockData,
  },
}

export const WithInitialData: Story = {
  args: {
    mode: 'create',
    initialData: mockData,
  },
}

export const PartialData: Story = {
  args: {
    mode: 'create',
    initialData: {
      title: 'Proyecto Parcial',
      description: 'Este proyecto tiene solo algunos campos completados para demostrar flexibilidad del formulario',
      amountRequested: 3000,
    },
  },
}

export const NoCancel: Story = {
  args: {
    showCancel: false,
  },
}

export const Compact: Story = {
  args: {
    compact: true,
  },
}

export const Loading: Story = {
  args: {
    loading: true,
    initialData: mockData,
  },
}

export const Disabled: Story = {
  args: {
    disabled: true,
    initialData: mockData,
  },
}

export const RiskLow: Story = {
  args: {
    initialData: {
      ...mockData,
      riskLevel: 'low',
    },
  },
}

export const RiskMedium: Story = {
  args: {
    initialData: {
      ...mockData,
      riskLevel: 'medium',
    },
  },
}

export const RiskHigh: Story = {
  args: {
    initialData: {
      ...mockData,
      riskLevel: 'high',
    },
  },
}

export const SmallAmount: Story = {
  args: {
    initialData: {
      ...mockData,
      amountRequested: 1000,
      minimumInvestment: 25,
    },
  },
}

export const LargeAmount: Story = {
  args: {
    initialData: {
      ...mockData,
      amountRequested: 50000,
      minimumInvestment: 500,
    },
  },
}

export const ShortTerm: Story = {
  args: {
    initialData: {
      ...mockData,
      termMonths: 6,
    },
  },
}

export const LongTerm: Story = {
  args: {
    initialData: {
      ...mockData,
      termMonths: 36,
    },
  },
}

export const LowInterest: Story = {
  args: {
    initialData: {
      ...mockData,
      interestRate: 2.5,
    },
  },
}

export const HighInterest: Story = {
  args: {
    initialData: {
      ...mockData,
      interestRate: 12,
      riskLevel: 'high',
    },
  },
}

export const CategoryBusiness: Story = {
  args: {
    initialData: {
      ...mockData,
      category: 'Negocio',
    },
  },
}

export const CategorySocial: Story = {
  args: {
    initialData: {
      ...mockData,
      category: 'Social',
    },
  },
}

export const CategoryEcology: Story = {
  args: {
    initialData: {
      ...mockData,
      category: 'Ecología',
    },
  },
}

export const WithImage: Story = {
  args: {
    initialData: mockData,
  },
}

export const NoImage: Story = {
  args: {
    initialData: {
      ...mockData,
      imageUrl: undefined,
    },
  },
}

export const WithDeadline: Story = {
  args: {
    initialData: mockData,
  },
}

export const NoDeadline: Story = {
  args: {
    initialData: {
      ...mockData,
      deadline: undefined,
    },
  },
}

export const WithMinimumInvestment: Story = {
  args: {
    initialData: mockData,
  },
}

export const NoMinimumInvestment: Story = {
  args: {
    initialData: {
      ...mockData,
      minimumInvestment: undefined,
    },
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      const loading = ref(false)
      const submittedData = ref<MicrocreditFormData | null>(null)

      const handleSubmit = (data: MicrocreditFormData) => {
        console.log('Form submitted:', data)
        loading.value = true

        setTimeout(() => {
          loading.value = false
          submittedData.value = data
          alert('¡Solicitud de microcrédito enviada exitosamente!')
        }, 2000)
      }

      const handleCancel = () => {
        if (confirm('¿Estás seguro de que quieres cancelar?')) {
          console.log('Form cancelled')
          submittedData.value = null
        }
      }

      const reset = () => {
        submittedData.value = null
      }

      return {
        loading,
        submittedData,
        handleSubmit,
        handleCancel,
        reset,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Formulario Interactivo</h2>
        <p class="text-sm text-gray-600 mb-6">
          Completa el formulario y haz clic en "Enviar Solicitud"
        </p>
        <div v-if="!submittedData">
          <MicrocreditForm
            :loading="loading"
            @submit="handleSubmit"
            @cancel="handleCancel"
          />
        </div>
        <div v-else class="max-w-2xl mx-auto">
          <div class="bg-green-50 dark:bg-green-900 border border-green-200 dark:border-green-800 rounded-lg p-6">
            <div class="flex items-center gap-3 mb-4">
              <div class="w-12 h-12 bg-green-100 dark:bg-green-800 rounded-full flex items-center justify-center">
                <svg class="w-6 h-6 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                </svg>
              </div>
              <div>
                <h3 class="text-lg font-bold text-green-900 dark:text-green-200">¡Solicitud Enviada!</h3>
                <p class="text-sm text-green-700 dark:text-green-300">Tu solicitud de microcrédito ha sido enviada</p>
              </div>
            </div>
            <div class="space-y-2 text-sm">
              <p><strong>Título:</strong> {{ submittedData.title }}</p>
              <p><strong>Cantidad:</strong> {{ submittedData.amountRequested }}€</p>
              <p><strong>Interés:</strong> {{ submittedData.interestRate }}%</p>
              <p><strong>Plazo:</strong> {{ submittedData.termMonths }} meses</p>
              <p><strong>Riesgo:</strong> {{ submittedData.riskLevel }}</p>
            </div>
            <button
              @click="reset"
              class="mt-4 px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 transition-colors"
            >
              Nueva Solicitud
            </button>
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const EditWorkflow: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      const mode = ref<'view' | 'edit'>('view')
      const loading = ref(false)
      const microcreditData = ref<Partial<MicrocreditFormData>>({ ...mockData })

      const handleEdit = () => {
        mode.value = 'edit'
      }

      const handleSubmit = (data: MicrocreditFormData) => {
        console.log('Saving changes:', data)
        loading.value = true

        setTimeout(() => {
          loading.value = false
          microcreditData.value = data
          mode.value = 'view'
          alert('¡Cambios guardados exitosamente!')
        }, 2000)
      }

      const handleCancel = () => {
        mode.value = 'view'
      }

      const formatCurrency = (amount: number) => {
        return new Intl.NumberFormat('es-ES', {
          style: 'currency',
          currency: 'EUR',
        }).format(amount)
      }

      return {
        mode,
        loading,
        microcreditData,
        handleEdit,
        handleSubmit,
        handleCancel,
        formatCurrency,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Flujo de Edición</h2>
        <div v-if="mode === 'view'" class="max-w-2xl">
          <div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-6">
            <h3 class="text-xl font-bold mb-4">{{ microcreditData.title }}</h3>
            <div class="space-y-3 text-sm mb-6">
              <p><strong>Descripción:</strong> {{ microcreditData.description }}</p>
              <p><strong>Cantidad:</strong> {{ formatCurrency(microcreditData.amountRequested || 0) }}</p>
              <p><strong>Interés:</strong> {{ microcreditData.interestRate }}% anual</p>
              <p><strong>Plazo:</strong> {{ microcreditData.termMonths }} meses</p>
              <p><strong>Riesgo:</strong> {{ microcreditData.riskLevel }}</p>
              <p v-if="microcreditData.category"><strong>Categoría:</strong> {{ microcreditData.category }}</p>
              <p v-if="microcreditData.minimumInvestment">
                <strong>Inversión Mínima:</strong> {{ formatCurrency(microcreditData.minimumInvestment) }}
              </p>
            </div>
            <button
              @click="handleEdit"
              class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
            >
              Editar Microcrédito
            </button>
          </div>
        </div>
        <MicrocreditForm
          v-else
          mode="edit"
          :initial-data="microcreditData"
          :loading="loading"
          @submit="handleSubmit"
          @cancel="handleCancel"
        />
      </div>
    `,
  }),
  args: {},
}

export const ValidationErrors: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Errores de Validación</h2>
        <p class="text-sm text-gray-600 mb-6">
          Intenta enviar el formulario sin completar los campos requeridos para ver los mensajes de error
        </p>
        <MicrocreditForm />
      </div>
    `,
  }),
  args: {},
}

export const AllRiskLevels: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      const riskLevels: Array<'low' | 'medium' | 'high'> = ['low', 'medium', 'high']
      return { riskLevels, mockData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Todos los Niveles de Riesgo</h2>
        <div class="space-y-8">
          <div v-for="riskLevel in riskLevels" :key="riskLevel">
            <h3 class="font-semibold mb-3 capitalize">{{ riskLevel }} Risk</h3>
            <MicrocreditForm
              compact
              :initial-data="{ ...mockData, riskLevel }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const DifferentCategories: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      const categories = ['Negocio', 'Social', 'Educación', 'Ecología']
      return { categories, mockData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Diferentes Categorías</h2>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div v-for="category in categories" :key="category">
            <h3 class="font-semibold mb-3">{{ category }}</h3>
            <MicrocreditForm
              compact
              :initial-data="{ ...mockData, category }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CharacterLimits: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      const nearLimitData: Partial<MicrocreditFormData> = {
        title: 'A'.repeat(95),
        description: 'B'.repeat(950),
      }
      return { nearLimitData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Límites de Caracteres</h2>
        <p class="text-sm text-gray-600 mb-6">
          Los campos están cerca del límite máximo de caracteres
        </p>
        <MicrocreditForm :initial-data="nearLimitData" />
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <MicrocreditForm compact />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const PaymentCalculator: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      return { mockData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Calculadora de Pagos</h2>
        <p class="text-sm text-gray-600 mb-6">
          Cambia los valores para ver cómo cambian los pagos mensuales y el total a devolver
        </p>
        <MicrocreditForm :initial-data="mockData" />
      </div>
    `,
  }),
  args: {},
}

export const WithRealTimeValidation: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Validación en Tiempo Real</h2>
        <div class="mb-6 p-4 bg-blue-50 dark:bg-blue-900 border border-blue-200 dark:border-blue-800 rounded">
          <h3 class="font-semibold mb-2 text-blue-900 dark:text-blue-200">Reglas de Validación:</h3>
          <ul class="text-sm text-blue-800 dark:text-blue-300 list-disc list-inside space-y-1">
            <li>Título: 10-100 caracteres (requerido)</li>
            <li>Descripción: 50-1000 caracteres (requerido)</li>
            <li>Cantidad: 100€ - 100,000€ (requerido)</li>
            <li>Interés: 0.1% - 30% (requerido)</li>
            <li>Plazo: 3-36 meses (requerido)</li>
            <li>Inversión mínima: 10€ mínimo y no mayor que la cantidad (opcional)</li>
            <li>Fecha límite: debe ser en el futuro (opcional)</li>
          </ul>
        </div>
        <MicrocreditForm />
      </div>
    `,
  }),
  args: {},
}

export const StepByStep: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      const step = ref(1)
      const formData = ref<Partial<MicrocreditFormData>>({
        title: '',
        description: '',
        amountRequested: 0,
        interestRate: 0,
        termMonths: 12,
        riskLevel: 'medium',
      })

      const nextStep = () => {
        step.value++
      }

      const prevStep = () => {
        step.value--
      }

      return {
        step,
        formData,
        nextStep,
        prevStep,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Proceso Paso a Paso</h2>
        <div class="mb-6">
          <div class="flex items-center gap-2">
            <div
              v-for="i in 3"
              :key="i"
              :class="[
                'w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold',
                i === step ? 'bg-blue-600 text-white' : i < step ? 'bg-green-600 text-white' : 'bg-gray-200 text-gray-600'
              ]"
            >
              {{ i }}
            </div>
          </div>
          <p class="text-sm text-gray-600 mt-2">
            Paso {{ step }} de 3: {{ step === 1 ? 'Información Básica' : step === 2 ? 'Detalles Financieros' : 'Revisión' }}
          </p>
        </div>

        <div v-show="step === 1">
          <h3 class="font-semibold mb-4">Información Básica del Proyecto</h3>
          <p class="text-sm text-gray-600 mb-4">Cuéntanos sobre tu proyecto</p>
          <button
            @click="nextStep"
            class="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Siguiente
          </button>
        </div>

        <div v-show="step === 2">
          <h3 class="font-semibold mb-4">Detalles Financieros</h3>
          <MicrocreditForm compact :initial-data="formData" :show-cancel="false" />
          <div class="flex gap-2 mt-4">
            <button
              @click="prevStep"
              class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700"
            >
              Anterior
            </button>
            <button
              @click="nextStep"
              class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            >
              Siguiente
            </button>
          </div>
        </div>

        <div v-show="step === 3">
          <h3 class="font-semibold mb-4">Revisión y Confirmación</h3>
          <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-6 mb-4">
            <h4 class="font-semibold mb-3">Resumen de la Solicitud</h4>
            <div class="space-y-2 text-sm">
              <p><strong>Título:</strong> {{ formData.title || 'No especificado' }}</p>
              <p><strong>Cantidad:</strong> {{ formData.amountRequested || 0 }}€</p>
              <p><strong>Interés:</strong> {{ formData.interestRate || 0 }}%</p>
              <p><strong>Plazo:</strong> {{ formData.termMonths }} meses</p>
            </div>
          </div>
          <div class="flex gap-2">
            <button
              @click="prevStep"
              class="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700"
            >
              Anterior
            </button>
            <button
              @click="alert('¡Solicitud enviada!')"
              class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
            >
              Enviar Solicitud
            </button>
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const DifferentAmounts: Story = {
  render: () => ({
    components: { MicrocreditForm },
    setup() {
      const amounts = [1000, 5000, 10000, 25000]
      return { amounts, mockData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Diferentes Cantidades</h2>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div v-for="amount in amounts" :key="amount">
            <h3 class="font-semibold mb-3">{{ amount }}€</h3>
            <MicrocreditForm
              compact
              :initial-data="{ ...mockData, amountRequested: amount }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}
