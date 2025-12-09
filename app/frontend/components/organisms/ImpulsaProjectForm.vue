<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import Button from '@/components/atoms/Button.vue'
import Input from '@/components/atoms/Input.vue'
import Textarea from '@/components/atoms/Textarea.vue'
import Select from '@/components/atoms/Select.vue'
import Card from '@/components/molecules/Card.vue'
import Icon from '@/components/atoms/Icon.vue'
import ProgressBar from '@/components/molecules/ProgressBar.vue'
import MediaUploader from './MediaUploader.vue'
import type { UploadFile } from './MediaUploader.vue'
import type { ProjectCategory } from './ImpulsaProjectCard.vue'

export interface ImpulsaProjectFormData {
  // Step 1: Basic Info
  title: string
  description: string
  category: ProjectCategory | ''
  // Step 2: Funding
  fundingGoal: number | null
  budgetBreakdown: string
  // Step 3: Team
  teamMembers: string
  skillsNeeded: string
  // Step 4: Timeline
  startDate: string
  endDate: string
  milestones: string
  // Additional
  documents: UploadFile[]
}

interface Props {
  /** Initial form data */
  initialData?: Partial<ImpulsaProjectFormData>
  /** Current step (1-4) */
  currentStep?: number
  /** Edition mode (create or edit) */
  mode?: 'create' | 'edit'
  /** Loading state */
  loading?: boolean
  /** Disabled state */
  disabled?: boolean
}

interface Emits {
  (e: 'submit', data: ImpulsaProjectFormData): void
  (e: 'save-draft', data: Partial<ImpulsaProjectFormData>): void
  (e: 'step-change', step: number): void
  (e: 'cancel'): void
}

const props = withDefaults(defineProps<Props>(), {
  currentStep: 1,
  mode: 'create',
  loading: false,
  disabled: false,
})

const emit = defineEmits<Emits>()

// Form data
const formData = ref<ImpulsaProjectFormData>({
  title: '',
  description: '',
  category: '',
  fundingGoal: null,
  budgetBreakdown: '',
  teamMembers: '',
  skillsNeeded: '',
  startDate: '',
  endDate: '',
  milestones: '',
  documents: [],
  ...props.initialData,
})

// Current step
const step = ref(props.currentStep)

// Watch for prop changes
watch(() => props.currentStep, (newStep) => {
  step.value = newStep
})

// Category options
const categoryOptions = [
  { value: 'social', label: 'Social' },
  { value: 'technology', label: 'Tecnología' },
  { value: 'culture', label: 'Cultura' },
  { value: 'education', label: 'Educación' },
  { value: 'environment', label: 'Medio Ambiente' },
  { value: 'health', label: 'Salud' },
  { value: 'other', label: 'Otro' },
]

// Steps configuration
const steps = [
  { number: 1, label: 'Información Básica', icon: 'info' },
  { number: 2, label: 'Financiación', icon: 'dollar-sign' },
  { number: 3, label: 'Equipo', icon: 'users' },
  { number: 4, label: 'Cronograma', icon: 'calendar' },
]

// Progress percentage
const progress = computed(() => {
  return ((step.value - 1) / (steps.length - 1)) * 100
})

// Validation
const errors = ref<Partial<Record<keyof ImpulsaProjectFormData, string>>>({})

const validateStep = (stepNumber: number): boolean => {
  errors.value = {}
  let isValid = true

  if (stepNumber === 1) {
    if (!formData.value.title || formData.value.title.length < 10) {
      errors.value.title = 'El título debe tener al menos 10 caracteres'
      isValid = false
    }
    if (formData.value.title && formData.value.title.length > 100) {
      errors.value.title = 'El título no puede exceder 100 caracteres'
      isValid = false
    }
    if (!formData.value.description || formData.value.description.length < 50) {
      errors.value.description = 'La descripción debe tener al menos 50 caracteres'
      isValid = false
    }
    if (formData.value.description && formData.value.description.length > 2000) {
      errors.value.description = 'La descripción no puede exceder 2000 caracteres'
      isValid = false
    }
    if (!formData.value.category) {
      errors.value.category = 'Debes seleccionar una categoría'
      isValid = false
    }
  }

  if (stepNumber === 2) {
    if (!formData.value.fundingGoal || formData.value.fundingGoal <= 0) {
      errors.value.fundingGoal = 'El objetivo de financiación debe ser mayor a 0'
      isValid = false
    }
    if (formData.value.fundingGoal && formData.value.fundingGoal > 1000000) {
      errors.value.fundingGoal = 'El objetivo no puede exceder 1.000.000 €'
      isValid = false
    }
    if (!formData.value.budgetBreakdown || formData.value.budgetBreakdown.length < 20) {
      errors.value.budgetBreakdown = 'Debes proporcionar un desglose del presupuesto (mínimo 20 caracteres)'
      isValid = false
    }
  }

  if (stepNumber === 3) {
    if (!formData.value.teamMembers || formData.value.teamMembers.length < 10) {
      errors.value.teamMembers = 'Describe los miembros del equipo (mínimo 10 caracteres)'
      isValid = false
    }
    if (!formData.value.skillsNeeded || formData.value.skillsNeeded.length < 10) {
      errors.value.skillsNeeded = 'Describe las habilidades necesarias (mínimo 10 caracteres)'
      isValid = false
    }
  }

  if (stepNumber === 4) {
    if (!formData.value.startDate) {
      errors.value.startDate = 'La fecha de inicio es requerida'
      isValid = false
    }
    if (!formData.value.endDate) {
      errors.value.endDate = 'La fecha de finalización es requerida'
      isValid = false
    }
    if (formData.value.startDate && formData.value.endDate) {
      const start = new Date(formData.value.startDate)
      const end = new Date(formData.value.endDate)
      if (end <= start) {
        errors.value.endDate = 'La fecha de finalización debe ser posterior a la fecha de inicio'
        isValid = false
      }
    }
    if (!formData.value.milestones || formData.value.milestones.length < 20) {
      errors.value.milestones = 'Describe los hitos del proyecto (mínimo 20 caracteres)'
      isValid = false
    }
  }

  return isValid
}

// Navigation
const goToStep = (stepNumber: number) => {
  if (stepNumber < 1 || stepNumber > steps.length) return
  if (stepNumber === step.value) return

  step.value = stepNumber
  emit('step-change', stepNumber)
}

const nextStep = () => {
  if (!validateStep(step.value)) return
  if (step.value < steps.length) {
    goToStep(step.value + 1)
  }
}

const previousStep = () => {
  if (step.value > 1) {
    goToStep(step.value - 1)
  }
}

// Form actions
const handleSubmit = () => {
  if (!validateStep(step.value)) return

  // Validate all steps
  for (let i = 1; i <= steps.length; i++) {
    if (!validateStep(i)) {
      goToStep(i)
      return
    }
  }

  emit('submit', formData.value)
}

const handleSaveDraft = () => {
  emit('save-draft', formData.value)
}

const handleCancel = () => {
  emit('cancel')
}

// Character counters
const titleLength = computed(() => formData.value.title.length)
const descriptionLength = computed(() => formData.value.description.length)
const budgetBreakdownLength = computed(() => formData.value.budgetBreakdown.length)
const teamMembersLength = computed(() => formData.value.teamMembers.length)
const skillsNeededLength = computed(() => formData.value.skillsNeeded.length)
const milestonesLength = computed(() => formData.value.milestones.length)

// Can submit
const canSubmit = computed(() => {
  return step.value === steps.length && !props.loading && !props.disabled
})

// Can save draft
const canSaveDraft = computed(() => {
  return !props.loading && !props.disabled
})
</script>

<template>
  <Card class="impulsa-project-form">
    <!-- Progress Stepper -->
    <div class="impulsa-project-form__stepper">
      <div class="flex items-center justify-between mb-4">
        <div
          v-for="(stepItem, index) in steps"
          :key="stepItem.number"
          class="flex items-center"
          :class="{ 'flex-1': index < steps.length - 1 }"
        >
          <!-- Step Circle -->
          <button
            :class="[
              'impulsa-project-form__step-button',
              step >= stepItem.number
                ? 'bg-primary text-white'
                : 'bg-gray-200 dark:bg-gray-700 text-gray-500 dark:text-gray-400',
              step === stepItem.number && 'ring-4 ring-primary ring-opacity-20',
            ]"
            @click="goToStep(stepItem.number)"
            :disabled="disabled"
          >
            <Icon :name="stepItem.icon" class="w-5 h-5" />
          </button>

          <!-- Step Label (Hidden on mobile) -->
          <span
            :class="[
              'hidden sm:inline ml-2 text-sm font-medium',
              step >= stepItem.number
                ? 'text-gray-900 dark:text-white'
                : 'text-gray-500 dark:text-gray-400',
            ]"
          >
            {{ stepItem.label }}
          </span>

          <!-- Connector Line -->
          <div
            v-if="index < steps.length - 1"
            :class="[
              'flex-1 h-0.5 mx-4',
              step > stepItem.number
                ? 'bg-primary'
                : 'bg-gray-200 dark:bg-gray-700',
            ]"
          />
        </div>
      </div>

      <!-- Progress Bar -->
      <ProgressBar :value="progress" class="mb-6" />
    </div>

    <!-- Form Steps -->
    <form @submit.prevent="handleSubmit" class="impulsa-project-form__form">
      <!-- Step 1: Basic Info -->
      <div v-if="step === 1" class="impulsa-project-form__step">
        <h3 class="text-xl font-bold mb-4">Información Básica</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-6">
          Proporciona los detalles principales de tu proyecto.
        </p>

        <div class="space-y-4">
          <div>
            <Input
              v-model="formData.title"
              label="Título del Proyecto"
              placeholder="Ej: Centro Comunitario de Innovación Social"
              :error="errors.title"
              :disabled="disabled || loading"
              required
            />
            <p class="text-xs text-gray-500 mt-1">
              {{ titleLength }}/100 caracteres
            </p>
          </div>

          <div>
            <Textarea
              v-model="formData.description"
              label="Descripción"
              placeholder="Describe tu proyecto en detalle: objetivos, impacto esperado, beneficiarios..."
              :rows="8"
              :error="!!errors.description"
              :disabled="disabled || loading"
              required
            />
            <p class="text-xs text-gray-500 mt-1">
              {{ descriptionLength }}/2000 caracteres
            </p>
          </div>

          <div>
            <Select
              v-model="formData.category"
              label="Categoría"
              :options="categoryOptions"
              :error="!!errors.category"
              :disabled="disabled || loading"
              required
            />
          </div>
        </div>
      </div>

      <!-- Step 2: Funding -->
      <div v-if="step === 2" class="impulsa-project-form__step">
        <h3 class="text-xl font-bold mb-4">Financiación</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-6">
          Define el presupuesto necesario para tu proyecto.
        </p>

        <div class="space-y-4">
          <div>
            <Input
              :model-value="formData.fundingGoal ?? undefined"
              @update:model-value="formData.fundingGoal = $event ? Number($event) : null"
              type="number"
              label="Objetivo de Financiación (€)"
              placeholder="50000"
              :error="errors.fundingGoal"
              :disabled="disabled || loading"
              required
            />
            <p class="text-xs text-gray-500 mt-1">
              Cantidad total necesaria para realizar el proyecto
            </p>
          </div>

          <div>
            <Textarea
              v-model="formData.budgetBreakdown"
              label="Desglose del Presupuesto"
              placeholder="Detalla cómo se distribuirá el presupuesto:&#10;- Materiales: 15.000€&#10;- Personal: 25.000€&#10;- Gastos operativos: 10.000€"
              :rows="10"
              :error="!!errors.budgetBreakdown"
              :disabled="disabled || loading"
              required
            />
            <p class="text-xs text-gray-500 mt-1">
              {{ budgetBreakdownLength }} caracteres
            </p>
          </div>
        </div>
      </div>

      <!-- Step 3: Team -->
      <div v-if="step === 3" class="impulsa-project-form__step">
        <h3 class="text-xl font-bold mb-4">Equipo</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-6">
          Describe el equipo que llevará a cabo el proyecto.
        </p>

        <div class="space-y-4">
          <div>
            <Textarea
              v-model="formData.teamMembers"
              label="Miembros del Equipo"
              placeholder="Describe los miembros actuales del equipo y sus roles:&#10;- María González (Coordinadora): Experiencia en gestión de proyectos sociales&#10;- Juan Pérez (Desarrollador): Especialista en tecnología..."
              :rows="8"
              :error="!!errors.teamMembers"
              :disabled="disabled || loading"
              required
            />
            <p class="text-xs text-gray-500 mt-1">
              {{ teamMembersLength }} caracteres
            </p>
          </div>

          <div>
            <Textarea
              v-model="formData.skillsNeeded"
              label="Habilidades Necesarias"
              placeholder="Describe las habilidades o perfiles que necesitas para completar el equipo:&#10;- Diseñador gráfico con experiencia en branding&#10;- Educador social para talleres..."
              :rows="8"
              :error="!!errors.skillsNeeded"
              :disabled="disabled || loading"
              required
            />
            <p class="text-xs text-gray-500 mt-1">
              {{ skillsNeededLength }} caracteres
            </p>
          </div>
        </div>
      </div>

      <!-- Step 4: Timeline -->
      <div v-if="step === 4" class="impulsa-project-form__step">
        <h3 class="text-xl font-bold mb-4">Cronograma</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-6">
          Establece el calendario de ejecución del proyecto.
        </p>

        <div class="space-y-4">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <Input
              v-model="formData.startDate"
              type="date"
              label="Fecha de Inicio"
              :error="errors.startDate"
              :disabled="disabled || loading"
              required
            />
            <Input
              v-model="formData.endDate"
              type="date"
              label="Fecha de Finalización"
              :error="errors.endDate"
              :disabled="disabled || loading"
              required
            />
          </div>

          <div>
            <Textarea
              v-model="formData.milestones"
              label="Hitos del Proyecto"
              placeholder="Define los principales hitos y entregas:&#10;- Mes 1: Diseño y planificación detallada&#10;- Mes 3: Implementación fase 1&#10;- Mes 6: Evaluación intermedia&#10;- Mes 12: Finalización y evaluación final"
              :rows="10"
              :error="!!errors.milestones"
              :disabled="disabled || loading"
              required
            />
            <p class="text-xs text-gray-500 mt-1">
              {{ milestonesLength }} caracteres
            </p>
          </div>

          <!-- Documents Upload -->
          <div>
            <label class="block text-sm font-medium mb-2">
              Documentos de Apoyo (Opcional)
            </label>
            <MediaUploader
              v-model="formData.documents"
              accept=".pdf,.doc,.docx,.xls,.xlsx"
              :max-files="5"
              :max-size="10 * 1024 * 1024"
              :disabled="disabled || loading"
            />
            <p class="text-xs text-gray-500 mt-1">
              Puedes adjuntar documentos que apoyen tu propuesta (presupuestos, cartas de apoyo, etc.)
            </p>
          </div>
        </div>
      </div>

      <!-- Form Actions -->
      <div class="impulsa-project-form__actions">
        <div class="flex flex-col sm:flex-row gap-3 justify-between">
          <div class="flex gap-3">
            <Button
              v-if="step > 1"
              variant="outline"
              @click="previousStep"
              :disabled="disabled || loading"
            >
              <Icon name="chevron-left" class="w-4 h-4 mr-1" />
              Anterior
            </Button>
            <Button
              variant="ghost"
              @click="handleCancel"
              :disabled="loading"
            >
              Cancelar
            </Button>
          </div>

          <div class="flex gap-3">
            <Button
              v-if="canSaveDraft"
              variant="outline"
              @click="handleSaveDraft"
              :disabled="loading"
            >
              <Icon name="save" class="w-4 h-4 mr-1" />
              Guardar Borrador
            </Button>

            <Button
              v-if="step < steps.length"
              variant="primary"
              @click="nextStep"
              :disabled="disabled || loading"
            >
              Siguiente
              <Icon name="chevron-right" class="w-4 h-4 ml-1" />
            </Button>

            <Button
              v-if="canSubmit"
              variant="primary"
              type="submit"
              :loading="loading"
              :disabled="disabled"
            >
              <Icon name="send" class="w-4 h-4 mr-1" />
              {{ mode === 'edit' ? 'Actualizar Proyecto' : 'Enviar Proyecto' }}
            </Button>
          </div>
        </div>
      </div>
    </form>
  </Card>
</template>

<style scoped>
.impulsa-project-form {
  @apply w-full;
}

.impulsa-project-form__stepper {
  @apply mb-8;
}

.impulsa-project-form__step-button {
  @apply w-10 h-10 rounded-full flex items-center justify-center transition-all duration-200 flex-shrink-0;
}

.impulsa-project-form__step-button:hover:not(:disabled) {
  @apply scale-110;
}

.impulsa-project-form__step-button:disabled {
  @apply cursor-not-allowed opacity-50;
}

.impulsa-project-form__step {
  @apply min-h-[400px];
}

.impulsa-project-form__actions {
  @apply mt-8 pt-6 border-t border-gray-200 dark:border-gray-700;
}
</style>
