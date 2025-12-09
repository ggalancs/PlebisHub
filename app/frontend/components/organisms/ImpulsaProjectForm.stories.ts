import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ImpulsaProjectForm from './ImpulsaProjectForm.vue'
import type { ImpulsaProjectFormData } from './ImpulsaProjectForm.vue'

const meta = {
  title: 'Organisms/ImpulsaProjectForm',
  component: ImpulsaProjectForm,
  tags: ['autodocs'],
  argTypes: {
    currentStep: {
      control: { type: 'number', min: 1, max: 4 },
      description: 'Current step (1-4)',
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
  },
} satisfies Meta<typeof ImpulsaProjectForm>

export default meta
type Story = StoryObj<typeof meta>

const mockFormData: Partial<ImpulsaProjectFormData> = {
  title: 'Centro Comunitario de Innovación Social',
  description: 'Proyecto para crear un espacio comunitario dedicado a la innovación social, donde los ciudadanos puedan colaborar en iniciativas que mejoren su barrio. Incluye talleres, coworking y actividades educativas para fomentar la participación ciudadana.',
  category: 'social',
  fundingGoal: 50000,
  budgetBreakdown: 'Materiales de construcción: 20.000€\nEquipamiento tecnológico: 15.000€\nPersonal (coordinador + educadores): 10.000€\nActividades y talleres: 3.000€\nGastos operativos (1 año): 2.000€',
  teamMembers: 'María González (Coordinadora) - Experiencia en gestión de proyectos sociales y participación ciudadana.\nJuan Pérez (Desarrollador) - Especialista en tecnología para comunidades.\nAna Martínez (Educadora Social) - 10 años de experiencia en educación comunitaria.',
  skillsNeeded: 'Diseñador gráfico con experiencia en branding y comunicación visual\nEducador social para talleres de fin de semana\nVoluntarios para actividades comunitarias\nContador para gestión financiera',
  startDate: '2024-03-01',
  endDate: '2024-12-31',
  milestones: 'Mes 1-2: Diseño detallado y planificación\nMes 3-4: Construcción y acondicionamiento del espacio\nMes 5-6: Equipamiento e instalación tecnológica\nMes 7: Inauguración y lanzamiento oficial\nMes 8-12: Operación y evaluación continua',
  documents: [],
}

export const Default: Story = {
  args: {},
}

export const Step1: Story = {
  args: {
    currentStep: 1,
  },
}

export const Step2: Story = {
  args: {
    currentStep: 2,
  },
}

export const Step3: Story = {
  args: {
    currentStep: 3,
  },
}

export const Step4: Story = {
  args: {
    currentStep: 4,
  },
}

export const WithInitialData: Story = {
  args: {
    initialData: mockFormData,
  },
}

export const EditMode: Story = {
  args: {
    mode: 'edit',
    currentStep: 4,
    initialData: mockFormData,
  },
}

export const CreateMode: Story = {
  args: {
    mode: 'create',
    currentStep: 4,
  },
}

export const Loading: Story = {
  args: {
    currentStep: 4,
    loading: true,
    initialData: mockFormData,
  },
}

export const Disabled: Story = {
  args: {
    disabled: true,
    initialData: mockFormData,
  },
}

export const PartialData: Story = {
  args: {
    initialData: {
      title: 'Proyecto Parcialmente Completado',
      description: 'Este proyecto tiene solo algunos campos completados para demostrar el estado de borrador.',
      category: 'technology',
    },
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { ImpulsaProjectForm },
    setup() {
      const currentStep = ref(1)
      const formData = ref<Partial<ImpulsaProjectFormData>>({})
      const loading = ref(false)
      const submittedData = ref<ImpulsaProjectFormData | null>(null)
      const draftSaved = ref(false)

      const handleStepChange = (step: number) => {
        console.log('Step changed to:', step)
        currentStep.value = step
      }

      const handleSubmit = (data: ImpulsaProjectFormData) => {
        console.log('Form submitted:', data)
        loading.value = true

        // Simulate API call
        setTimeout(() => {
          submittedData.value = data
          loading.value = false
          alert('¡Proyecto enviado con éxito!')
        }, 2000)
      }

      const handleSaveDraft = (data: Partial<ImpulsaProjectFormData>) => {
        console.log('Draft saved:', data)
        draftSaved.value = true
        setTimeout(() => {
          draftSaved.value = false
        }, 2000)
      }

      const handleCancel = () => {
        console.log('Form cancelled')
        if (confirm('¿Estás seguro de que quieres cancelar? Se perderán los cambios no guardados.')) {
          formData.value = {}
          currentStep.value = 1
        }
      }

      const resetForm = () => {
        formData.value = {}
        submittedData.value = null
        currentStep.value = 1
      }

      return {
        currentStep,
        formData,
        loading,
        submittedData,
        draftSaved,
        handleStepChange,
        handleSubmit,
        handleSaveDraft,
        handleCancel,
        resetForm,
      }
    },
    template: `
      <div class="p-6 max-w-5xl">
        <h2 class="text-2xl font-bold mb-4">Formulario Interactivo de Proyecto IMPULSA</h2>

        <div v-if="draftSaved" class="mb-4 p-4 bg-green-50 border border-green-200 rounded text-green-800">
          ✓ Borrador guardado correctamente
        </div>

        <div v-if="submittedData" class="mb-6 p-4 bg-blue-50 border border-blue-200 rounded">
          <h3 class="font-semibold text-blue-900 mb-2">¡Proyecto Enviado!</h3>
          <p class="text-sm text-blue-700 mb-2">Título: {{ submittedData.title }}</p>
          <button
            @click="resetForm"
            class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm"
          >
            Crear Nuevo Proyecto
          </button>
        </div>

        <ImpulsaProjectForm
          v-if="!submittedData"
          :initial-data="formData"
          :current-step="currentStep"
          :loading="loading"
          @step-change="handleStepChange"
          @submit="handleSubmit"
          @save-draft="handleSaveDraft"
          @cancel="handleCancel"
        />

        <div v-if="!submittedData" class="mt-6 p-4 bg-gray-50 rounded">
          <h3 class="font-semibold mb-2">Estado del Formulario:</h3>
          <p class="text-sm mb-1">Paso actual: <strong>{{ currentStep }}</strong></p>
          <p class="text-sm mb-1">Progreso: <strong>{{ Math.round((currentStep - 1) / 3 * 100) }}%</strong></p>
          <details class="mt-2">
            <summary class="text-sm cursor-pointer text-blue-600 hover:text-blue-800">Ver datos del formulario</summary>
            <pre class="text-xs mt-2 p-2 bg-white rounded border overflow-auto max-h-60">{{ JSON.stringify(formData, null, 2) }}</pre>
          </details>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const MultiStepNavigation: Story = {
  render: () => ({
    components: { ImpulsaProjectForm },
    setup() {
      const currentStep = ref(1)
      const history = ref<number[]>([1])

      const handleStepChange = (step: number) => {
        currentStep.value = step
        history.value.push(step)
      }

      const clearHistory = () => {
        history.value = [currentStep.value]
      }

      return {
        currentStep,
        history,
        handleStepChange,
        clearHistory,
      }
    },
    template: `
      <div class="p-6 max-w-5xl">
        <h2 class="text-2xl font-bold mb-4">Navegación Multi-Paso</h2>

        <div class="mb-4 p-4 bg-blue-50 rounded">
          <h3 class="font-semibold mb-2">Historial de Navegación:</h3>
          <div class="flex items-center gap-2 flex-wrap">
            <span
              v-for="(step, index) in history"
              :key="index"
              class="px-3 py-1 bg-blue-600 text-white rounded text-sm"
            >
              Paso {{ step }}
            </span>
          </div>
          <button
            @click="clearHistory"
            class="mt-2 px-3 py-1 bg-gray-600 text-white rounded text-sm hover:bg-gray-700"
          >
            Limpiar Historial
          </button>
        </div>

        <ImpulsaProjectForm
          :current-step="currentStep"
          :initial-data="{
            title: 'Proyecto de Prueba para Navegación',
            description: 'Este es un proyecto de prueba con datos suficientes para permitir la navegación entre pasos y demostrar cómo funciona el formulario.',
            category: 'social',
            fundingGoal: 25000,
            budgetBreakdown: 'Presupuesto detallado aquí con suficiente información.',
            teamMembers: 'Equipo completo con roles definidos',
            skillsNeeded: 'Habilidades necesarias descritas',
            startDate: '2024-06-01',
            endDate: '2024-12-31',
            milestones: 'Hitos detallados del proyecto',
          }"
          @step-change="handleStepChange"
        />
      </div>
    `,
  }),
  args: {},
}

export const WithValidationErrors: Story = {
  render: () => ({
    components: { ImpulsaProjectForm },
    setup() {
      const currentStep = ref(1)

      return { currentStep }
    },
    template: `
      <div class="p-6 max-w-5xl">
        <h2 class="text-2xl font-bold mb-4">Formulario con Errores de Validación</h2>
        <p class="text-sm text-gray-600 mb-6">
          Intenta navegar al siguiente paso sin completar los campos para ver los mensajes de error.
        </p>
        <ImpulsaProjectForm :current-step="currentStep" />
      </div>
    `,
  }),
  args: {},
}

export const AllStepsView: Story = {
  render: () => ({
    components: { ImpulsaProjectForm },
    setup() {
      return {}
    },
    template: `
      <div class="p-6 max-w-7xl">
        <h2 class="text-2xl font-bold mb-6">Vista de Todos los Pasos</h2>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div>
            <h3 class="font-semibold mb-3">Paso 1: Información Básica</h3>
            <ImpulsaProjectForm :current-step="1" />
          </div>
          <div>
            <h3 class="font-semibold mb-3">Paso 2: Financiación</h3>
            <ImpulsaProjectForm :current-step="2" />
          </div>
          <div>
            <h3 class="font-semibold mb-3">Paso 3: Equipo</h3>
            <ImpulsaProjectForm :current-step="3" />
          </div>
          <div>
            <h3 class="font-semibold mb-3">Paso 4: Cronograma</h3>
            <ImpulsaProjectForm :current-step="4" />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const TechnologyProject: Story = {
  args: {
    initialData: {
      title: 'Plataforma de Datos Abiertos Ciudadanos',
      description: 'Desarrollo de una plataforma tecnológica open source para la publicación y visualización de datos públicos municipales, facilitando el acceso a la información y fomentando la transparencia gubernamental.',
      category: 'technology',
      fundingGoal: 75000,
      budgetBreakdown: 'Desarrollo de software: 35.000€\nInfraestructura y hosting: 15.000€\nDiseño UX/UI: 10.000€\nSeguridad y auditorías: 8.000€\nDocumentación y capacitación: 7.000€',
    },
    currentStep: 1,
  },
}

export const CultureProject: Story = {
  args: {
    initialData: {
      title: 'Festival Anual de Arte Urbano',
      description: 'Organización de un festival de arte urbano que celebre la creatividad local y fomente el uso artístico de espacios públicos, incluyendo murales, performances y talleres comunitarios.',
      category: 'culture',
      fundingGoal: 30000,
      budgetBreakdown: 'Artistas y performers: 12.000€\nMateriales y suministros: 8.000€\nDifusión y marketing: 5.000€\nPermisos y seguros: 3.000€\nLogística y montaje: 2.000€',
    },
    currentStep: 1,
  },
}

export const EducationProject: Story = {
  args: {
    initialData: {
      title: 'Programa de Tutorías Escolares Gratuitas',
      description: 'Iniciativa educativa para proporcionar apoyo escolar gratuito a estudiantes de primaria y secundaria en situación de vulnerabilidad, con tutores voluntarios capacitados.',
      category: 'education',
      fundingGoal: 20000,
      budgetBreakdown: 'Materiales educativos: 8.000€\nCapacitación de tutores: 5.000€\nEspacio y equipamiento: 4.000€\nCoordinación del programa: 3.000€',
    },
    currentStep: 1,
  },
}

export const EnvironmentProject: Story = {
  args: {
    initialData: {
      title: 'Red de Huertos Urbanos Comunitarios',
      description: 'Creación de espacios verdes comunitarios para el cultivo ecológico de alimentos, educación ambiental y fortalecimiento de lazos vecinales a través de la agricultura urbana.',
      category: 'environment',
      fundingGoal: 40000,
      budgetBreakdown: 'Preparación de terrenos: 15.000€\nMateriales de cultivo: 10.000€\nSistemas de riego: 8.000€\nFormación en agricultura: 4.000€\nHerramientas compartidas: 3.000€',
    },
    currentStep: 1,
  },
}

export const HealthProject: Story = {
  args: {
    initialData: {
      title: 'Centro de Salud Mental Comunitario',
      description: 'Establecimiento de un centro de atención psicológica accesible y gratuita para la comunidad, ofreciendo terapias individuales, grupales y actividades de bienestar mental.',
      category: 'health',
      fundingGoal: 60000,
      budgetBreakdown: 'Psicólogos profesionales: 30.000€\nEspacio y equipamiento: 15.000€\nMateriales terapéuticos: 8.000€\nDifusión y sensibilización: 4.000€\nOperación (1 año): 3.000€',
    },
    currentStep: 1,
  },
}

export const SmallBudgetProject: Story = {
  args: {
    initialData: {
      title: 'Biblioteca Comunitaria de Préstamo',
      description: 'Iniciativa para crear una pequeña biblioteca comunitaria donde los vecinos puedan intercambiar y prestar libros, fomentando la lectura y el acceso a la cultura.',
      category: 'culture',
      fundingGoal: 5000,
      budgetBreakdown: 'Estanterías y mobiliario: 2.000€\nLibros iniciales: 1.500€\nSistema de gestión: 800€\nDifusión: 500€\nMantenimiento: 200€',
    },
    currentStep: 2,
  },
}

export const LargeBudgetProject: Story = {
  args: {
    initialData: {
      title: 'Centro Integral de Servicios Comunitarios',
      description: 'Construcción de un gran centro que integre servicios educativos, culturales, deportivos y sociales para toda la comunidad, convirtiéndose en un hub de actividad ciudadana.',
      category: 'social',
      fundingGoal: 500000,
      budgetBreakdown: 'Construcción del edificio: 300.000€\nEquipamiento completo: 100.000€\nSistemas tecnológicos: 50.000€\nPersonal inicial (2 años): 40.000€\nOperación inicial: 10.000€',
    },
    currentStep: 2,
  },
}
