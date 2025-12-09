<script setup lang="ts">
import { computed, watch } from 'vue'
import Button from '@/components/atoms/Button.vue'
import Input from '@/components/atoms/Input.vue'
import Textarea from '@/components/atoms/Textarea.vue'
import Alert from '@/components/molecules/Alert.vue'
import FormField from '@/components/molecules/FormField.vue'
import { useForm, validators } from '@/composables'

export interface ProposalFormData {
  title: string
  description: string
}

interface Props {
  /** Initial values for edit mode */
  initialValues?: Partial<ProposalFormData>
  /** Form mode: create or edit */
  mode?: 'create' | 'edit'
  /** Loading state during submission */
  loading?: boolean
  /** Error message from server */
  error?: string | null
  /** Success message */
  success?: string | null
  /** Minimum title length */
  minTitleLength?: number
  /** Maximum title length */
  maxTitleLength?: number
  /** Minimum description length */
  minDescriptionLength?: number
  /** Maximum description length */
  maxDescriptionLength?: number
}

interface Emits {
  (e: 'submit', data: ProposalFormData): void
  (e: 'cancel'): void
}

const props = withDefaults(defineProps<Props>(), {
  mode: 'create',
  loading: false,
  error: null,
  success: null,
  minTitleLength: 10,
  maxTitleLength: 150,
  minDescriptionLength: 50,
  maxDescriptionLength: 2000,
})

const emit = defineEmits<Emits>()

// Form setup with validation
const form = useForm<ProposalFormData>(
  {
    title: props.initialValues?.title || '',
    description: props.initialValues?.description || '',
  },
  {
    title: [
      validators.required('El título es obligatorio'),
      validators.minLength(props.minTitleLength, `El título debe tener al menos ${props.minTitleLength} caracteres`),
      validators.maxLength(props.maxTitleLength, `El título no puede exceder ${props.maxTitleLength} caracteres`),
    ],
    description: [
      validators.required('La descripción es obligatoria'),
      validators.minLength(props.minDescriptionLength, `La descripción debe tener al menos ${props.minDescriptionLength} caracteres`),
      validators.maxLength(props.maxDescriptionLength, `La descripción no puede exceder ${props.maxDescriptionLength} caracteres`),
    ],
  }
)

// Update form when initialValues change
watch(
  () => props.initialValues,
  (newValues) => {
    if (newValues) {
      form.setFieldValue('title', newValues.title || '')
      form.setFieldValue('description', newValues.description || '')
    }
  },
  { deep: true }
)

// Character counters
const titleCharCount = computed(() => form.values.title.length)
const descriptionCharCount = computed(() => form.values.description.length)

const titleCharCountColor = computed(() => {
  const remaining = props.maxTitleLength - titleCharCount.value
  if (remaining < 10) return 'text-error'
  if (remaining < 30) return 'text-warning'
  return 'text-gray-500'
})

const descriptionCharCountColor = computed(() => {
  const remaining = props.maxDescriptionLength - descriptionCharCount.value
  if (remaining < 50) return 'text-error'
  if (remaining < 100) return 'text-warning'
  return 'text-gray-500'
})

// Form labels
const submitButtonText = computed(() => {
  if (props.loading) {
    return props.mode === 'create' ? 'Creando...' : 'Guardando...'
  }
  return props.mode === 'create' ? 'Crear propuesta' : 'Guardar cambios'
})

const titleLabel = computed(() => {
  return props.mode === 'create' ? 'Título de la propuesta' : 'Editar título'
})

const descriptionLabel = computed(() => {
  return props.mode === 'create' ? 'Descripción de la propuesta' : 'Editar descripción'
})

// Handle form submission
const handleSubmit = form.handleSubmit((values) => {
  emit('submit', values)
})

// Handle cancel
const handleCancel = () => {
  emit('cancel')
}

// Reset form
const resetForm = () => {
  form.resetForm()
}

// Expose methods
defineExpose({
  resetForm,
  setFieldValue: form.setFieldValue,
  setFieldError: form.setFieldError,
})
</script>

<template>
  <form class="proposal-form" @submit="handleSubmit">
    <!-- Success Alert -->
    <Alert
      v-if="success"
      variant="success"
      :dismissible="false"
      class="mb-6"
    >
      {{ success }}
    </Alert>

    <!-- Error Alert -->
    <Alert
      v-if="error"
      variant="danger"
      :dismissible="false"
      class="mb-6"
    >
      {{ error }}
    </Alert>

    <!-- Title Field -->
    <FormField
      :label="titleLabel"
      :error="form.errors.value.title ?? undefined"
      :required="true"
      class="mb-6"
    >
      <Input
        v-model="form.values.title"
        placeholder="Ej: Mejora del sistema de transporte público"
        :disabled="loading"
        :error="form.errors.value.title ?? undefined"
        size="lg"
        @blur="form.setFieldTouched('title')"
      />
      <template #description>
        <div class="flex items-center justify-between text-sm mt-1">
          <span class="text-gray-600 dark:text-gray-400">
            Un título claro y descriptivo ayudará a que más personas apoyen tu propuesta
          </span>
          <span :class="titleCharCountColor">
            {{ titleCharCount }} / {{ maxTitleLength }}
          </span>
        </div>
      </template>
    </FormField>

    <!-- Description Field -->
    <FormField
      :label="descriptionLabel"
      :error="form.errors.value.description ?? undefined"
      :required="true"
      class="mb-6"
    >
      <Textarea
        v-model="form.values.description"
        placeholder="Describe tu propuesta en detalle. ¿Qué problema resuelve? ¿Cómo beneficiará a la comunidad? ¿Qué recursos se necesitan?"
        :rows="10"
        :disabled="loading"
        :error="!!form.errors.value.description"
        @blur="form.setFieldTouched('description')"
      />
      <template #description>
        <div class="flex items-center justify-between text-sm mt-1">
          <span class="text-gray-600 dark:text-gray-400">
            Proporciona todos los detalles relevantes para que la comunidad pueda evaluar tu propuesta
          </span>
          <span :class="descriptionCharCountColor">
            {{ descriptionCharCount }} / {{ maxDescriptionLength }}
          </span>
        </div>
      </template>
    </FormField>

    <!-- Guidelines -->
    <div class="mb-6 p-4 bg-info/10 dark:bg-info/20 border border-info/30 rounded-lg">
      <h4 class="text-sm font-semibold text-info mb-2 flex items-center">
        <svg
          class="w-5 h-5 mr-2"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
        Guía para una buena propuesta
      </h4>
      <ul class="text-sm text-gray-700 dark:text-gray-300 space-y-1">
        <li>✓ Sé específico y claro sobre lo que propones</li>
        <li>✓ Explica cómo beneficiará a la comunidad</li>
        <li>✓ Incluye datos o ejemplos que apoyen tu propuesta</li>
        <li>✓ Considera los recursos y el tiempo necesarios</li>
        <li>✓ Mantén un tono respetuoso y constructivo</li>
      </ul>
    </div>

    <!-- Form Stats -->
    <div class="mb-6 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
      <h4 class="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3">
        Estado del formulario
      </h4>
      <div class="grid grid-cols-2 gap-4 text-sm">
        <div>
          <span class="text-gray-600 dark:text-gray-400">Campos completados:</span>
          <span class="ml-2 font-medium" :class="form.isValid.value ? 'text-success' : 'text-gray-700 dark:text-gray-300'">
            {{ form.isValid.value ? '2/2' : '0/2' }}
          </span>
        </div>
        <div>
          <span class="text-gray-600 dark:text-gray-400">Estado:</span>
          <span class="ml-2 font-medium" :class="form.isValid.value ? 'text-success' : 'text-warning'">
            {{ form.isValid.value ? 'Listo' : 'Incompleto' }}
          </span>
        </div>
      </div>
    </div>

    <!-- Action Buttons -->
    <div class="flex flex-col sm:flex-row gap-3 justify-end">
      <Button
        type="button"
        variant="outline"
        size="lg"
        :disabled="loading"
        @click="handleCancel"
      >
        Cancelar
      </Button>

      <Button
        type="submit"
        variant="primary"
        size="lg"
        :loading="loading"
        :disabled="loading || !form.isValid.value"
      >
        {{ submitButtonText }}
      </Button>
    </div>
  </form>
</template>

<style scoped>
.proposal-form {
  max-width: 800px;
  margin: 0 auto;
}

/* Character count colors */
.text-error {
  color: #ef4444;
}

.text-warning {
  color: #f59e0b;
}

.text-success {
  color: #10b981;
}

.text-info {
  color: #3b82f6;
}
</style>
