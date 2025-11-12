import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import CollaborationForm from './CollaborationForm.vue'
import type { CollaborationFormData } from './CollaborationForm.vue'

const meta = {
  title: 'Organisms/CollaborationForm',
  component: CollaborationForm,
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
} satisfies Meta<typeof CollaborationForm>

export default meta
type Story = StoryObj<typeof meta>

const mockData: Partial<CollaborationFormData> = {
  title: 'Proyecto de Huerto Comunitario',
  description: 'Un proyecto para crear un huerto comunitario donde todos puedan participar y aprender sobre agricultura urbana sostenible',
  type: 'project',
  location: 'Madrid, España',
  startDate: '2025-03-01',
  endDate: '2025-12-31',
  minCollaborators: 3,
  maxCollaborators: 10,
  skills: ['Jardinería', 'Compostaje', 'Diseño de Espacios'],
  imageUrl: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800&h=400&fit=crop',
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
      title: 'Colaboración Parcial',
      description: 'Esta colaboración tiene solo algunos campos completados',
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

export const TypeProject: Story = {
  args: {
    initialData: {
      ...mockData,
      type: 'project',
    },
  },
}

export const TypeInitiative: Story = {
  args: {
    initialData: {
      ...mockData,
      type: 'initiative',
    },
  },
}

export const TypeEvent: Story = {
  args: {
    initialData: {
      ...mockData,
      type: 'event',
    },
  },
}

export const TypeCampaign: Story = {
  args: {
    initialData: {
      ...mockData,
      type: 'campaign',
    },
  },
}

export const TypeWorkshop: Story = {
  args: {
    initialData: {
      ...mockData,
      type: 'workshop',
    },
  },
}

export const WithDateRange: Story = {
  args: {
    initialData: mockData,
  },
}

export const NoDates: Story = {
  args: {
    initialData: {
      ...mockData,
      startDate: undefined,
      endDate: undefined,
    },
  },
}

export const WithCollaboratorLimits: Story = {
  args: {
    initialData: mockData,
  },
}

export const NoCollaboratorLimits: Story = {
  args: {
    initialData: {
      ...mockData,
      minCollaborators: undefined,
      maxCollaborators: undefined,
    },
  },
}

export const WithManySkills: Story = {
  args: {
    initialData: {
      ...mockData,
      skills: [
        'Jardinería',
        'Compostaje',
        'Diseño de Espacios',
        'Carpintería',
        'Fontanería',
        'Electricidad',
        'Albañilería',
      ],
    },
  },
}

export const NoSkills: Story = {
  args: {
    initialData: {
      ...mockData,
      skills: [],
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

export const WithLocation: Story = {
  args: {
    initialData: mockData,
  },
}

export const NoLocation: Story = {
  args: {
    initialData: {
      ...mockData,
      location: undefined,
    },
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { CollaborationForm },
    setup() {
      const loading = ref(false)
      const submittedData = ref<CollaborationFormData | null>(null)

      const handleSubmit = (data: CollaborationFormData) => {
        console.log('Form submitted:', data)
        loading.value = true

        setTimeout(() => {
          loading.value = false
          submittedData.value = data
          alert('¡Colaboración creada exitosamente!')
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
          Completa el formulario y haz clic en "Crear Colaboración"
        </p>
        <div v-if="!submittedData">
          <CollaborationForm
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
                <h3 class="text-lg font-bold text-green-900 dark:text-green-200">¡Colaboración Creada!</h3>
                <p class="text-sm text-green-700 dark:text-green-300">Tu colaboración ha sido creada exitosamente</p>
              </div>
            </div>
            <div class="space-y-2 text-sm">
              <p><strong>Título:</strong> {{ submittedData.title }}</p>
              <p><strong>Tipo:</strong> {{ submittedData.type }}</p>
              <p v-if="submittedData.location"><strong>Ubicación:</strong> {{ submittedData.location }}</p>
              <p v-if="submittedData.startDate"><strong>Inicio:</strong> {{ submittedData.startDate }}</p>
              <p v-if="submittedData.skills.length > 0"><strong>Habilidades:</strong> {{ submittedData.skills.join(', ') }}</p>
            </div>
            <button
              @click="reset"
              class="mt-4 px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 transition-colors"
            >
              Nueva Colaboración
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
    components: { CollaborationForm },
    setup() {
      const mode = ref<'view' | 'edit'>('view')
      const loading = ref(false)
      const collaborationData = ref<Partial<CollaborationFormData>>({ ...mockData })

      const handleEdit = () => {
        mode.value = 'edit'
      }

      const handleSubmit = (data: CollaborationFormData) => {
        console.log('Saving changes:', data)
        loading.value = true

        setTimeout(() => {
          loading.value = false
          collaborationData.value = data
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
        collaborationData,
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
            <h3 class="text-xl font-bold mb-4">{{ collaborationData.title }}</h3>
            <div class="space-y-3 text-sm mb-6">
              <p><strong>Descripción:</strong> {{ collaborationData.description }}</p>
              <p><strong>Tipo:</strong> {{ collaborationData.type }}</p>
              <p v-if="collaborationData.location"><strong>Ubicación:</strong> {{ collaborationData.location }}</p>
              <p v-if="collaborationData.startDate"><strong>Fecha de inicio:</strong> {{ collaborationData.startDate }}</p>
              <p v-if="collaborationData.endDate"><strong>Fecha de fin:</strong> {{ collaborationData.endDate }}</p>
              <p v-if="collaborationData.minCollaborators"><strong>Min. colaboradores:</strong> {{ collaborationData.minCollaborators }}</p>
              <p v-if="collaborationData.maxCollaborators"><strong>Max. colaboradores:</strong> {{ collaborationData.maxCollaborators }}</p>
              <p v-if="collaborationData.skills && collaborationData.skills.length > 0">
                <strong>Habilidades:</strong> {{ collaborationData.skills.join(', ') }}
              </p>
            </div>
            <button
              @click="handleEdit"
              class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
            >
              Editar Colaboración
            </button>
          </div>
        </div>
        <CollaborationForm
          v-else
          mode="edit"
          :initial-data="collaborationData"
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
    components: { CollaborationForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Errores de Validación</h2>
        <p class="text-sm text-gray-600 mb-6">
          Intenta enviar el formulario sin completar los campos requeridos para ver los mensajes de error
        </p>
        <CollaborationForm />
      </div>
    `,
  }),
  args: {},
}

export const AllTypes: Story = {
  render: (args) => ({
    components: { CollaborationForm },
    setup() {
      const types = ['project', 'initiative', 'event', 'campaign', 'workshop', 'other']
      return { types, mockData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Todos los Tipos</h2>
        <div class="space-y-8">
          <div v-for="type in types" :key="type">
            <h3 class="text-lg font-semibold mb-4 capitalize">{{ type }}</h3>
            <CollaborationForm
              compact
              :initial-data="{ ...mockData, type }"
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
    components: { CollaborationForm },
    setup() {
      const nearLimitData: Partial<CollaborationFormData> = {
        title: 'A'.repeat(95),
        description: 'B'.repeat(980),
      }
      return { nearLimitData }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Límites de Caracteres</h2>
        <p class="text-sm text-gray-600 mb-6">
          Los campos están cerca del límite máximo de caracteres
        </p>
        <CollaborationForm :initial-data="nearLimitData" />
      </div>
    `,
  }),
  args: {},
}

export const SkillManagement: Story = {
  render: (args) => ({
    components: { CollaborationForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Gestión de Habilidades</h2>
        <p class="text-sm text-gray-600 mb-6">
          Agrega y elimina habilidades usando el campo de entrada o presionando Enter
        </p>
        <CollaborationForm />
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: (args) => ({
    components: { CollaborationForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <CollaborationForm compact />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const WithRealTimeValidation: Story = {
  render: (args) => ({
    components: { CollaborationForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Validación en Tiempo Real</h2>
        <div class="mb-6 p-4 bg-blue-50 dark:bg-blue-900 border border-blue-200 dark:border-blue-800 rounded">
          <h3 class="font-semibold mb-2 text-blue-900 dark:text-blue-200">Reglas de Validación:</h3>
          <ul class="text-sm text-blue-800 dark:text-blue-300 list-disc list-inside space-y-1">
            <li>Título: 5-100 caracteres (requerido)</li>
            <li>Descripción: 20-1000 caracteres (requerido)</li>
            <li>Tipo: seleccionar uno (requerido)</li>
            <li>Min colaboradores: 1-100 (opcional)</li>
            <li>Max colaboradores: 1-100, no menor que mínimo (opcional)</li>
            <li>Fecha fin: debe ser posterior a fecha inicio (opcional)</li>
            <li>Habilidades: máximo 15</li>
            <li>Ubicación: hasta 200 caracteres (opcional)</li>
          </ul>
        </div>
        <CollaborationForm />
      </div>
    `,
  }),
  args: {},
}

export const MinimalFields: Story = {
  args: {
    initialData: {
      title: 'Colaboración Mínima',
      description: 'Una colaboración con campos mínimos requeridos',
      type: 'project',
    },
  },
}

export const CompleteFields: Story = {
  args: {
    initialData: mockData,
  },
}

export const DateValidation: Story = {
  render: (args) => ({
    components: { CollaborationForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Validación de Fechas</h2>
        <p class="text-sm text-gray-600 mb-6">
          Intenta seleccionar una fecha de fin anterior a la fecha de inicio para ver el error
        </p>
        <CollaborationForm />
      </div>
    `,
  }),
  args: {},
}

export const CollaboratorValidation: Story = {
  render: (args) => ({
    components: { CollaborationForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Validación de Colaboradores</h2>
        <p class="text-sm text-gray-600 mb-6">
          Intenta establecer un máximo menor que el mínimo para ver el error
        </p>
        <CollaborationForm />
      </div>
    `,
  }),
  args: {},
}
