import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ParticipationForm from './ParticipationForm.vue'
import type { ParticipationFormData } from './ParticipationForm.vue'

const meta = {
  title: 'Organisms/ParticipationForm',
  component: ParticipationForm,
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
} satisfies Meta<typeof ParticipationForm>

export default meta
type Story = StoryObj<typeof meta>

const mockData: Partial<ParticipationFormData> = {
  name: 'Equipo de Medio Ambiente',
  description: 'Trabajamos en iniciativas para mejorar el medio ambiente local y promover prácticas sostenibles en nuestra comunidad',
  maxMembers: 15,
  status: 'recruiting',
  meetingSchedule: 'Jueves 18:00',
  tags: ['Medio Ambiente', 'Sostenibilidad', 'Comunidad'],
  imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800&h=400&fit=crop',
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
      name: 'Equipo Parcial',
      description: 'Este equipo tiene solo algunos campos completados',
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

export const StatusActive: Story = {
  args: {
    initialData: {
      ...mockData,
      status: 'active',
    },
  },
}

export const StatusRecruiting: Story = {
  args: {
    initialData: {
      ...mockData,
      status: 'recruiting',
    },
  },
}

export const StatusFull: Story = {
  args: {
    initialData: {
      ...mockData,
      status: 'full',
    },
  },
}

export const StatusInactive: Story = {
  args: {
    initialData: {
      ...mockData,
      status: 'inactive',
    },
  },
}

export const WithManyTags: Story = {
  args: {
    initialData: {
      ...mockData,
      tags: [
        'Medio Ambiente',
        'Sostenibilidad',
        'Comunidad',
        'Reciclaje',
        'Biodiversidad',
        'Energías Renovables',
        'Educación Ambiental',
      ],
    },
  },
}

export const MaxTags: Story = {
  args: {
    initialData: {
      ...mockData,
      tags: Array(10).fill(null).map((_, i) => `Etiqueta ${i + 1}`),
    },
  },
}

export const NoTags: Story = {
  args: {
    initialData: {
      ...mockData,
      tags: [],
    },
  },
}

export const SmallTeam: Story = {
  args: {
    initialData: {
      ...mockData,
      maxMembers: 5,
    },
  },
}

export const LargeTeam: Story = {
  args: {
    initialData: {
      ...mockData,
      maxMembers: 50,
    },
  },
}

export const NoMaxMembers: Story = {
  args: {
    initialData: {
      ...mockData,
      maxMembers: undefined,
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

export const Interactive: Story = {
  render: (args) => ({
    components: { ParticipationForm },
    setup() {
      const loading = ref(false)
      const submittedData = ref<ParticipationFormData | null>(null)

      const handleSubmit = (data: ParticipationFormData) => {
        console.log('Form submitted:', data)
        loading.value = true

        setTimeout(() => {
          loading.value = false
          submittedData.value = data
          alert('¡Equipo creado exitosamente!')
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
          Completa el formulario y haz clic en "Crear Equipo"
        </p>
        <div v-if="!submittedData">
          <ParticipationForm
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
                <h3 class="text-lg font-bold text-green-900 dark:text-green-200">¡Equipo Creado!</h3>
                <p class="text-sm text-green-700 dark:text-green-300">Tu equipo ha sido creado exitosamente</p>
              </div>
            </div>
            <div class="space-y-2 text-sm">
              <p><strong>Nombre:</strong> {{ submittedData.name }}</p>
              <p><strong>Descripción:</strong> {{ submittedData.description }}</p>
              <p><strong>Estado:</strong> {{ submittedData.status }}</p>
              <p v-if="submittedData.maxMembers"><strong>Máx. Miembros:</strong> {{ submittedData.maxMembers }}</p>
              <p v-if="submittedData.meetingSchedule"><strong>Horario:</strong> {{ submittedData.meetingSchedule }}</p>
              <p v-if="submittedData.tags.length > 0"><strong>Etiquetas:</strong> {{ submittedData.tags.join(', ') }}</p>
            </div>
            <button
              @click="reset"
              class="mt-4 px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 transition-colors"
            >
              Crear Otro Equipo
            </button>
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const EditWorkflow: Story = {
  render: (args) => ({
    components: { ParticipationForm },
    setup() {
      const mode = ref<'view' | 'edit'>('view')
      const loading = ref(false)
      const teamData = ref<Partial<ParticipationFormData>>({ ...mockData })

      const handleEdit = () => {
        mode.value = 'edit'
      }

      const handleSubmit = (data: ParticipationFormData) => {
        console.log('Saving changes:', data)
        loading.value = true

        setTimeout(() => {
          loading.value = false
          teamData.value = data
          mode.value = 'view'
          alert('¡Cambios guardados exitosamente!')
        }, 2000)
      }

      const handleCancel = () => {
        mode.value = 'view'
      }

      return {
        mode,
        loading,
        teamData,
        handleEdit,
        handleSubmit,
        handleCancel,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Flujo de Edición</h2>
        <div v-if="mode === 'view'" class="max-w-2xl">
          <div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-6">
            <h3 class="text-xl font-bold mb-4">{{ teamData.name }}</h3>
            <div class="space-y-3 text-sm mb-6">
              <p><strong>Descripción:</strong> {{ teamData.description }}</p>
              <p><strong>Estado:</strong> {{ teamData.status }}</p>
              <p v-if="teamData.maxMembers"><strong>Máx. Miembros:</strong> {{ teamData.maxMembers }}</p>
              <p v-if="teamData.meetingSchedule"><strong>Horario:</strong> {{ teamData.meetingSchedule }}</p>
              <p v-if="teamData.tags && teamData.tags.length > 0">
                <strong>Etiquetas:</strong> {{ teamData.tags.join(', ') }}
              </p>
            </div>
            <button
              @click="handleEdit"
              class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
            >
              Editar Equipo
            </button>
          </div>
        </div>
        <ParticipationForm
          v-else
          mode="edit"
          :initial-data="teamData"
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
  render: (args) => ({
    components: { ParticipationForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Errores de Validación</h2>
        <p class="text-sm text-gray-600 mb-6">
          Intenta enviar el formulario sin completar los campos requeridos para ver los mensajes de error
        </p>
        <ParticipationForm />
      </div>
    `,
  }),
  args: {},
}

export const AllModes: Story = {
  render: (args) => ({
    components: { ParticipationForm },
    setup() {
      return { mockData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Todos los Modos</h2>
        <div class="space-y-8">
          <div>
            <h3 class="text-lg font-semibold mb-4">Modo Crear</h3>
            <ParticipationForm mode="create" />
          </div>
          <div class="pt-8 border-t border-gray-200">
            <h3 class="text-lg font-semibold mb-4">Modo Editar</h3>
            <ParticipationForm mode="edit" :initial-data="mockData" />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const DifferentStatuses: Story = {
  render: (args) => ({
    components: { ParticipationForm },
    setup() {
      const statuses: Array<'active' | 'recruiting' | 'full' | 'inactive'> = ['active', 'recruiting', 'full', 'inactive']
      return { statuses, mockData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Diferentes Estados</h2>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div v-for="status in statuses" :key="status">
            <h3 class="font-semibold mb-3 capitalize">{{ status }}</h3>
            <ParticipationForm
              compact
              :initial-data="{ ...mockData, status }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CharacterLimits: Story = {
  render: (args) => ({
    components: { ParticipationForm },
    setup() {
      const nearLimitData: Partial<ParticipationFormData> = {
        name: 'A'.repeat(95),
        description: 'B'.repeat(480),
      }
      return { nearLimitData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Límites de Caracteres</h2>
        <p class="text-sm text-gray-600 mb-6">
          Los campos están cerca del límite máximo de caracteres
        </p>
        <ParticipationForm :initial-data="nearLimitData" />
      </div>
    `,
  }),
  args: {},
}

export const TagManagement: Story = {
  render: (args) => ({
    components: { ParticipationForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Gestión de Etiquetas</h2>
        <p class="text-sm text-gray-600 mb-6">
          Agrega y elimina etiquetas usando el campo de entrada o presionando Enter
        </p>
        <ParticipationForm />
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: (args) => ({
    components: { ParticipationForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <ParticipationForm compact />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const ProgressiveDisclosure: Story = {
  render: (args) => ({
    components: { ParticipationForm },
    setup() {
      const step = ref(1)
      const formData = ref<Partial<ParticipationFormData>>({
        name: '',
        description: '',
        maxMembers: undefined,
        status: 'recruiting',
        meetingSchedule: '',
        tags: [],
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
        <h2 class="text-2xl font-bold mb-4">Revelación Progresiva</h2>
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
          <p class="text-sm text-gray-600 mt-2">Paso {{ step }} de 3</p>
        </div>

        <div v-show="step === 1">
          <h3 class="font-semibold mb-4">Información Básica</h3>
          <ParticipationForm compact :initial-data="formData" :show-cancel="false" />
          <button
            @click="nextStep"
            class="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Siguiente
          </button>
        </div>

        <div v-show="step === 2">
          <h3 class="font-semibold mb-4">Detalles del Equipo</h3>
          <ParticipationForm compact :initial-data="formData" :show-cancel="false" />
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
            <h4 class="font-semibold mb-3">Resumen del Equipo</h4>
            <div class="space-y-2 text-sm">
              <p><strong>Nombre:</strong> {{ formData.name || 'No especificado' }}</p>
              <p><strong>Descripción:</strong> {{ formData.description || 'No especificada' }}</p>
              <p><strong>Estado:</strong> {{ formData.status }}</p>
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
              @click="alert('¡Equipo creado!')"
              class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700"
            >
              Crear Equipo
            </button>
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const WithRealTimeValidation: Story = {
  render: (args) => ({
    components: { ParticipationForm },
    setup() {
      const validationMessages = ref<string[]>([])

      const checkValidation = () => {
        validationMessages.value = [
          'El nombre debe tener entre 3 y 100 caracteres',
          'La descripción debe tener entre 20 y 500 caracteres',
          'El máximo de miembros debe estar entre 2 y 100',
        ]
      }

      return {
        validationMessages,
        checkValidation,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Validación en Tiempo Real</h2>
        <div class="mb-6 p-4 bg-blue-50 dark:bg-blue-900 border border-blue-200 dark:border-blue-800 rounded">
          <h3 class="font-semibold mb-2 text-blue-900 dark:text-blue-200">Reglas de Validación:</h3>
          <ul class="text-sm text-blue-800 dark:text-blue-300 list-disc list-inside space-y-1">
            <li>Nombre: 3-100 caracteres (requerido)</li>
            <li>Descripción: 20-500 caracteres (requerido)</li>
            <li>Máximo de miembros: 2-100 (opcional)</li>
            <li>Horario de reuniones: hasta 100 caracteres (opcional)</li>
            <li>Etiquetas: máximo 10</li>
          </ul>
        </div>
        <ParticipationForm />
      </div>
    `,
  }),
  args: {},
}
