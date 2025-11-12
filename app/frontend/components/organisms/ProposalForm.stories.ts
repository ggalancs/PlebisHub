import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ProposalForm from './ProposalForm.vue'

const meta = {
  title: 'Organisms/ProposalForm',
  component: ProposalForm,
  tags: ['autodocs'],
  argTypes: {
    mode: {
      control: 'select',
      options: ['create', 'edit'],
    },
    loading: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof ProposalForm>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    mode: 'create',
  },
}

export const CreateMode: Story = {
  args: {
    mode: 'create',
  },
}

export const EditMode: Story = {
  args: {
    mode: 'edit',
    initialValues: {
      title: 'Mejora del Sistema de Transporte Público',
      description:
        'Esta propuesta busca mejorar el sistema de transporte público mediante la implementación de carriles exclusivos para autobuses, ampliación de rutas y modernización de la flota vehicular. Esto reducirá los tiempos de viaje y mejorará la calidad del aire en nuestra ciudad.',
    },
  },
}

export const Loading: Story = {
  args: {
    mode: 'create',
    loading: true,
  },
}

export const LoadingEdit: Story = {
  args: {
    mode: 'edit',
    loading: true,
    initialValues: {
      title: 'Propuesta en edición',
      description: 'Esta propuesta está siendo guardada...',
    },
  },
}

export const WithSuccess: Story = {
  args: {
    mode: 'create',
    success: '¡Propuesta creada exitosamente! Ahora la comunidad podrá votarla.',
  },
}

export const WithError: Story = {
  args: {
    mode: 'create',
    error: 'Error al crear la propuesta. Por favor, inténtalo de nuevo más tarde.',
  },
}

export const CustomLengths: Story = {
  args: {
    mode: 'create',
    minTitleLength: 5,
    maxTitleLength: 50,
    minDescriptionLength: 20,
    maxDescriptionLength: 200,
  },
}

export const StrictValidation: Story = {
  args: {
    mode: 'create',
    minTitleLength: 20,
    maxTitleLength: 100,
    minDescriptionLength: 100,
    maxDescriptionLength: 1000,
  },
}

export const WithInitialErrors: Story = {
  render: (args) => ({
    components: { ProposalForm },
    setup() {
      return { args }
    },
    template: `
      <div class="p-6">
        <p class="mb-4 text-sm text-gray-600">
          Este formulario ya tiene un error de servidor mostrado
        </p>
        <ProposalForm v-bind="args" />
      </div>
    `,
  }),
  args: {
    mode: 'create',
    error: 'Ya existe una propuesta con un título similar. Por favor, elige un título diferente.',
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { ProposalForm },
    setup() {
      const loading = ref(false)
      const success = ref<string | null>(null)
      const error = ref<string | null>(null)

      const handleSubmit = async (data: any) => {
        console.log('Submitting proposal:', data)
        loading.value = true
        success.value = null
        error.value = null

        // Simulate API call
        await new Promise((resolve) => setTimeout(resolve, 2000))

        // Simulate random success/error
        if (Math.random() > 0.3) {
          success.value = '¡Propuesta creada exitosamente!'
          loading.value = false
        } else {
          error.value = 'Error al crear la propuesta. Inténtalo de nuevo.'
          loading.value = false
        }
      }

      const handleCancel = () => {
        console.log('Form cancelled')
        alert('Formulario cancelado')
      }

      return {
        loading,
        success,
        error,
        handleSubmit,
        handleCancel,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Crear Nueva Propuesta</h2>
        <p class="text-gray-600 mb-6">
          Completa el formulario para crear una nueva propuesta ciudadana
        </p>
        <ProposalForm
          mode="create"
          :loading="loading"
          :success="success"
          :error="error"
          @submit="handleSubmit"
          @cancel="handleCancel"
        />
      </div>
    `,
  }),
  args: {},
}

export const InteractiveEdit: Story = {
  render: (args) => ({
    components: { ProposalForm },
    setup() {
      const loading = ref(false)
      const success = ref<string | null>(null)
      const error = ref<string | null>(null)
      const initialValues = ref({
        title: 'Propuesta Original',
        description:
          'Esta es la descripción original de la propuesta que puede ser editada por el usuario.',
      })

      const handleSubmit = async (data: any) => {
        console.log('Updating proposal:', data)
        loading.value = true
        success.value = null
        error.value = null

        // Simulate API call
        await new Promise((resolve) => setTimeout(resolve, 2000))

        success.value = '¡Cambios guardados exitosamente!'
        loading.value = false

        // Update initial values
        initialValues.value = { ...data }
      }

      const handleCancel = () => {
        console.log('Edit cancelled')
        alert('Edición cancelada')
      }

      return {
        loading,
        success,
        error,
        initialValues,
        handleSubmit,
        handleCancel,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Editar Propuesta</h2>
        <p class="text-gray-600 mb-6">
          Modifica los campos que desees actualizar
        </p>
        <ProposalForm
          mode="edit"
          :loading="loading"
          :success="success"
          :error="error"
          :initial-values="initialValues"
          @submit="handleSubmit"
          @cancel="handleCancel"
        />
      </div>
    `,
  }),
  args: {},
}

export const ValidationShowcase: Story = {
  render: (args) => ({
    components: { ProposalForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Demo de Validación</h2>
        <div class="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <h3 class="font-semibold text-blue-900 mb-2">Prueba las validaciones:</h3>
          <ul class="text-sm text-blue-800 space-y-1">
            <li>1. Intenta enviar el formulario vacío</li>
            <li>2. Escribe un título muy corto (menos de 10 caracteres)</li>
            <li>3. Escribe un título muy largo (más de 150 caracteres)</li>
            <li>4. Haz lo mismo con la descripción (mínimo 50, máximo 2000)</li>
            <li>5. Observa cómo cambian los contadores de caracteres</li>
            <li>6. El botón de envío se habilitará solo cuando todo sea válido</li>
          </ul>
        </div>
        <ProposalForm mode="create" />
      </div>
    `,
  }),
  args: {},
}

export const CharacterCounters: Story = {
  render: (args) => ({
    components: { ProposalForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Contadores de Caracteres</h2>
        <p class="text-gray-600 mb-6">
          Observa cómo los contadores cambian de color:
          <span class="text-gray-500">Normal</span>,
          <span class="text-yellow-600">Advertencia (cerca del límite)</span>,
          <span class="text-red-600">Error (muy cerca o excedido)</span>
        </p>
        <ProposalForm
          mode="create"
          :max-title-length="50"
          :max-description-length="200"
        />
      </div>
    `,
  }),
  args: {},
}

export const MinimalForm: Story = {
  args: {
    mode: 'create',
    minTitleLength: 3,
    maxTitleLength: 50,
    minDescriptionLength: 10,
    maxDescriptionLength: 200,
  },
}

export const StrictForm: Story = {
  args: {
    mode: 'create',
    minTitleLength: 30,
    maxTitleLength: 100,
    minDescriptionLength: 200,
    maxDescriptionLength: 1000,
  },
}

export const WithLongInitialValues: Story = {
  args: {
    mode: 'edit',
    initialValues: {
      title: 'Implementación de un Sistema Integral de Gestión de Residuos Urbanos Sostenibles',
      description: `Esta propuesta tiene como objetivo establecer un sistema completo de gestión de residuos urbanos que incluya:

1. Separación de residuos en origen con contenedores diferenciados
2. Puntos de recolección estratégicamente ubicados en toda la ciudad
3. Programa de compostaje comunitario para residuos orgánicos
4. Sistema de reciclaje avanzado para plásticos, vidrios y metales
5. Educación ciudadana sobre la importancia del reciclaje
6. Incentivos para hogares y empresas que participen activamente
7. Monitoreo y evaluación continua del programa

Este sistema no solo reducirá la cantidad de residuos en vertederos, sino que también creará empleos verdes, reducirá la contaminación ambiental y promoverá una cultura de sostenibilidad en nuestra comunidad.`,
    },
  },
}

export const MobileView: Story = {
  render: (args) => ({
    components: { ProposalForm },
    setup() {
      return { args }
    },
    template: `
      <div class="max-w-md mx-auto p-4">
        <h2 class="text-xl font-bold mb-4">Vista Móvil</h2>
        <ProposalForm v-bind="args" />
      </div>
    `,
  }),
  args: {
    mode: 'create',
  },
}

export const DesktopView: Story = {
  render: (args) => ({
    components: { ProposalForm },
    setup() {
      return { args }
    },
    template: `
      <div class="max-w-4xl mx-auto p-8">
        <h2 class="text-3xl font-bold mb-6">Vista Desktop</h2>
        <ProposalForm v-bind="args" />
      </div>
    `,
  }),
  args: {
    mode: 'create',
  },
}

export const QuickSuccessDemo: Story = {
  render: (args) => ({
    components: { ProposalForm },
    setup() {
      const loading = ref(false)
      const success = ref<string | null>(null)

      const handleSubmit = async () => {
        loading.value = true
        await new Promise((resolve) => setTimeout(resolve, 1000))
        loading.value = false
        success.value = '¡Propuesta creada exitosamente!'
      }

      return { loading, success, handleSubmit }
    },
    template: `
      <div class="p-6">
        <ProposalForm
          mode="create"
          :loading="loading"
          :success="success"
          @submit="handleSubmit"
        />
      </div>
    `,
  }),
  args: {},
}
