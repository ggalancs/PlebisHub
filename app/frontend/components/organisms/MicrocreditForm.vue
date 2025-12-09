<script setup lang="ts">
import { ref, computed, watch, onUnmounted } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Button from '@/components/atoms/Button.vue'
import Input from '@/components/atoms/Input.vue'
import Textarea from '@/components/atoms/Textarea.vue'
import Select from '@/components/atoms/Select.vue'
import Icon from '@/components/atoms/Icon.vue'
import FileUpload from '@/components/molecules/FileUpload.vue'

export type RiskLevel = 'low' | 'medium' | 'high'

export interface MicrocreditFormData {
  title: string
  description: string
  amountRequested: number
  interestRate: number
  termMonths: number
  riskLevel: RiskLevel
  category?: string
  deadline?: string
  minimumInvestment?: number
  imageFile?: File
  imageUrl?: string
}

interface Props {
  /** Initial form data */
  initialData?: Partial<MicrocreditFormData>
  /** Form mode */
  mode?: 'create' | 'edit'
  /** Loading state */
  loading?: boolean
  /** Disabled state */
  disabled?: boolean
  /** Show cancel button */
  showCancel?: boolean
  /** Compact mode */
  compact?: boolean
}

interface Emits {
  (e: 'submit', data: MicrocreditFormData): void
  (e: 'cancel'): void
}

const props = withDefaults(defineProps<Props>(), {
  mode: 'create',
  loading: false,
  disabled: false,
  showCancel: true,
  compact: false,
})

const emit = defineEmits<Emits>()

// Form data
const formData = ref<MicrocreditFormData>({
  title: '',
  description: '',
  amountRequested: 0,
  interestRate: 0,
  termMonths: 12,
  riskLevel: 'medium',
  category: '',
  deadline: '',
  minimumInvestment: undefined,
  imageFile: undefined,
  imageUrl: '',
})

// Errors
const errors = ref<Record<string, string>>({})

// Keep track of object URL for cleanup
const previousObjectUrl = ref<string | null>(null)

// Risk level options
const riskLevelOptions = [
  { value: 'low', label: 'Riesgo Bajo' },
  { value: 'medium', label: 'Riesgo Medio' },
  { value: 'high', label: 'Riesgo Alto' },
]

// Category options
const categoryOptions = [
  { value: 'Negocio', label: 'Negocio' },
  { value: 'Social', label: 'Social' },
  { value: 'Educación', label: 'Educación' },
  { value: 'Salud', label: 'Salud' },
  { value: 'Ecología', label: 'Ecología' },
  { value: 'Agricultura', label: 'Agricultura' },
  { value: 'Tecnología', label: 'Tecnología' },
  { value: 'Cultura', label: 'Cultura' },
  { value: 'Otro', label: 'Otro' },
]

// Term options (months)
const termOptions = [
  { value: 3, label: '3 meses' },
  { value: 6, label: '6 meses' },
  { value: 12, label: '12 meses' },
  { value: 18, label: '18 meses' },
  { value: 24, label: '24 meses' },
  { value: 36, label: '36 meses' },
]

// Initialize form data
watch(
  () => props.initialData,
  (newData) => {
    if (newData) {
      formData.value = {
        title: newData.title || '',
        description: newData.description || '',
        amountRequested: newData.amountRequested || 0,
        interestRate: newData.interestRate || 0,
        termMonths: newData.termMonths || 12,
        riskLevel: newData.riskLevel || 'medium',
        category: newData.category || '',
        deadline: newData.deadline || '',
        minimumInvestment: newData.minimumInvestment,
        imageFile: newData.imageFile,
        imageUrl: newData.imageUrl || '',
      }
    }
  },
  { immediate: true }
)

// Validation
const validate = (): boolean => {
  errors.value = {}
  let isValid = true

  // Title validation
  if (!formData.value.title.trim()) {
    errors.value.title = 'El título es requerido'
    isValid = false
  } else if (formData.value.title.length < 10) {
    errors.value.title = 'El título debe tener al menos 10 caracteres'
    isValid = false
  } else if (formData.value.title.length > 100) {
    errors.value.title = 'El título no puede exceder 100 caracteres'
    isValid = false
  }

  // Description validation
  if (!formData.value.description.trim()) {
    errors.value.description = 'La descripción es requerida'
    isValid = false
  } else if (formData.value.description.length < 50) {
    errors.value.description = 'La descripción debe tener al menos 50 caracteres'
    isValid = false
  } else if (formData.value.description.length > 1000) {
    errors.value.description = 'La descripción no puede exceder 1000 caracteres'
    isValid = false
  }

  // Amount validation
  if (!formData.value.amountRequested || formData.value.amountRequested <= 0) {
    errors.value.amountRequested = 'La cantidad solicitada debe ser mayor a 0'
    isValid = false
  } else if (formData.value.amountRequested < 100) {
    errors.value.amountRequested = 'La cantidad mínima es 100€'
    isValid = false
  } else if (formData.value.amountRequested > 100000) {
    errors.value.amountRequested = 'La cantidad máxima es 100,000€'
    isValid = false
  }

  // Interest rate validation
  if (!formData.value.interestRate || formData.value.interestRate <= 0) {
    errors.value.interestRate = 'La tasa de interés debe ser mayor a 0'
    isValid = false
  } else if (formData.value.interestRate < 0.1) {
    errors.value.interestRate = 'La tasa de interés mínima es 0.1%'
    isValid = false
  } else if (formData.value.interestRate > 30) {
    errors.value.interestRate = 'La tasa de interés máxima es 30%'
    isValid = false
  }

  // Term validation
  if (!formData.value.termMonths || formData.value.termMonths <= 0) {
    errors.value.termMonths = 'El plazo debe ser mayor a 0'
    isValid = false
  }

  // Minimum investment validation (optional)
  if (formData.value.minimumInvestment !== undefined && formData.value.minimumInvestment !== null) {
    if (formData.value.minimumInvestment < 10) {
      errors.value.minimumInvestment = 'La inversión mínima debe ser al menos 10€'
      isValid = false
    } else if (formData.value.minimumInvestment > formData.value.amountRequested) {
      errors.value.minimumInvestment = 'La inversión mínima no puede ser mayor a la cantidad solicitada'
      isValid = false
    }
  }

  // Deadline validation (optional)
  if (formData.value.deadline) {
    const deadlineDate = new Date(formData.value.deadline)
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    if (deadlineDate < today) {
      errors.value.deadline = 'La fecha límite debe ser en el futuro'
      isValid = false
    }
  }

  return isValid
}

// Character counts
const titleCharCount = computed(() => formData.value.title.length)
const descriptionCharCount = computed(() => formData.value.description.length)

// Is form valid
const isFormValid = computed(() => {
  return (
    formData.value.title.trim().length >= 10 &&
    formData.value.description.trim().length >= 50 &&
    formData.value.amountRequested >= 100 &&
    formData.value.amountRequested <= 100000 &&
    formData.value.interestRate >= 0.1 &&
    formData.value.interestRate <= 30 &&
    formData.value.termMonths > 0 &&
    (!formData.value.minimumInvestment || (formData.value.minimumInvestment >= 10 && formData.value.minimumInvestment <= formData.value.amountRequested))
  )
})

// Has changes
const hasChanges = computed(() => {
  if (!props.initialData) return true

  return (
    formData.value.title !== (props.initialData.title || '') ||
    formData.value.description !== (props.initialData.description || '') ||
    formData.value.amountRequested !== (props.initialData.amountRequested || 0) ||
    formData.value.interestRate !== (props.initialData.interestRate || 0) ||
    formData.value.termMonths !== (props.initialData.termMonths || 12) ||
    formData.value.riskLevel !== (props.initialData.riskLevel || 'medium') ||
    formData.value.category !== (props.initialData.category || '') ||
    formData.value.deadline !== (props.initialData.deadline || '') ||
    formData.value.minimumInvestment !== props.initialData.minimumInvestment ||
    formData.value.imageFile !== props.initialData.imageFile ||
    formData.value.imageUrl !== (props.initialData.imageUrl || '')
  )
})

// Expected monthly payment
const expectedMonthlyPayment = computed(() => {
  if (!formData.value.amountRequested || !formData.value.interestRate || !formData.value.termMonths) {
    return 0
  }

  const principal = formData.value.amountRequested
  const monthlyRate = formData.value.interestRate / 100 / 12
  const months = formData.value.termMonths

  if (monthlyRate === 0) {
    return principal / months
  }

  // Formula for monthly payment: P * [r(1+r)^n] / [(1+r)^n - 1]
  const payment = principal * (monthlyRate * Math.pow(1 + monthlyRate, months)) / (Math.pow(1 + monthlyRate, months) - 1)
  return payment
})

// Total to repay
const totalToRepay = computed(() => {
  return expectedMonthlyPayment.value * formData.value.termMonths
})

// Handlers
const handleSubmit = () => {
  if (!validate()) {
    return
  }

  emit('submit', { ...formData.value })
}

const handleCancel = () => {
  emit('cancel')
}

const handleImageUpload = (files: File[]) => {
  if (files.length > 0) {
    // Revoke previous URL if exists to prevent memory leak
    if (previousObjectUrl.value) {
      URL.revokeObjectURL(previousObjectUrl.value)
    }

    formData.value.imageFile = files[0]
    // Create preview URL
    const newUrl = URL.createObjectURL(files[0])
    formData.value.imageUrl = newUrl
    previousObjectUrl.value = newUrl
  }
}

const handleRemoveImage = () => {
  // Revoke object URL to prevent memory leak
  if (previousObjectUrl.value) {
    URL.revokeObjectURL(previousObjectUrl.value)
    previousObjectUrl.value = null
  }

  formData.value.imageFile = undefined
  formData.value.imageUrl = ''
}

// Format currency
const formatCurrency = (amount: number): string => {
  return new Intl.NumberFormat('es-ES', {
    style: 'currency',
    currency: 'EUR',
  }).format(amount)
}

// Cleanup on unmount to prevent memory leaks
onUnmounted(() => {
  if (previousObjectUrl.value) {
    URL.revokeObjectURL(previousObjectUrl.value)
  }
})
</script>

<template>
  <Card :loading="loading" class="microcredit-form">
    <div class="microcredit-form__header">
      <h2 class="text-2xl font-bold mb-2">
        {{ mode === 'create' ? 'Solicitar Microcrédito' : 'Editar Microcrédito' }}
      </h2>
      <p class="text-sm text-gray-600 dark:text-gray-400">
        {{ mode === 'create'
          ? 'Completa la información para solicitar un microcrédito'
          : 'Actualiza la información del microcrédito'
        }}
      </p>
    </div>

    <form @submit.prevent="handleSubmit" class="microcredit-form__body">
      <!-- Title -->
      <div class="microcredit-form__field">
        <label class="microcredit-form__label">
          Título del Proyecto
          <span class="text-red-500">*</span>
        </label>
        <Input
          v-model="formData.title"
          type="text"
          placeholder="Ej: Expansión de Panadería Local"
          :error="errors.title"
          :disabled="disabled"
          :maxlength="100"
        />
        <div class="flex items-center justify-between mt-1">
          <p v-if="errors.title" class="text-xs text-red-600 dark:text-red-400">
            {{ errors.title }}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400 ml-auto">
            {{ titleCharCount }} / 100
          </p>
        </div>
      </div>

      <!-- Description -->
      <div class="microcredit-form__field">
        <label class="microcredit-form__label">
          Descripción del Proyecto
          <span class="text-red-500">*</span>
        </label>
        <Textarea
          v-model="formData.description"
          placeholder="Describe detalladamente tu proyecto y cómo utilizarás los fondos..."
          :error="!!errors.description"
          :disabled="disabled"
          :rows="compact ? 4 : 6"
          :maxlength="1000"
        />
        <div class="flex items-center justify-between mt-1">
          <p v-if="errors.description" class="text-xs text-red-600 dark:text-red-400">
            {{ errors.description }}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400 ml-auto">
            {{ descriptionCharCount }} / 1000
          </p>
        </div>
      </div>

      <!-- Amount and Interest Row -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Amount Requested -->
        <div class="microcredit-form__field">
          <label class="microcredit-form__label">
            Cantidad Solicitada (€)
            <span class="text-red-500">*</span>
          </label>
          <Input
            v-model.number="formData.amountRequested"
            type="number"
            placeholder="5000"
            :error="errors.amountRequested"
            :disabled="disabled"
            :min="100"
            :max="100000"
            :step="100"
          />
          <p v-if="errors.amountRequested" class="text-xs text-red-600 dark:text-red-400 mt-1">
            {{ errors.amountRequested }}
          </p>
          <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Entre 100€ y 100,000€
          </p>
        </div>

        <!-- Interest Rate -->
        <div class="microcredit-form__field">
          <label class="microcredit-form__label">
            Tasa de Interés (% anual)
            <span class="text-red-500">*</span>
          </label>
          <Input
            v-model.number="formData.interestRate"
            type="number"
            placeholder="5.5"
            :error="errors.interestRate"
            :disabled="disabled"
            :min="0.1"
            :max="30"
            :step="0.1"
          />
          <p v-if="errors.interestRate" class="text-xs text-red-600 dark:text-red-400 mt-1">
            {{ errors.interestRate }}
          </p>
          <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Entre 0.1% y 30%
          </p>
        </div>
      </div>

      <!-- Term and Risk Level Row -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Term -->
        <div class="microcredit-form__field">
          <label class="microcredit-form__label">
            Plazo
            <span class="text-red-500">*</span>
          </label>
          <Select
            v-model.number="formData.termMonths"
            :options="termOptions"
            :disabled="disabled"
          />
          <p v-if="errors.termMonths" class="text-xs text-red-600 dark:text-red-400 mt-1">
            {{ errors.termMonths }}
          </p>
        </div>

        <!-- Risk Level -->
        <div class="microcredit-form__field">
          <label class="microcredit-form__label">
            Nivel de Riesgo
            <span class="text-red-500">*</span>
          </label>
          <Select
            v-model="formData.riskLevel"
            :options="riskLevelOptions"
            :disabled="disabled"
          />
        </div>
      </div>

      <!-- Category and Minimum Investment Row -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Category -->
        <div class="microcredit-form__field">
          <label class="microcredit-form__label">Categoría</label>
          <Select
            v-model="formData.category"
            :options="categoryOptions"
            :disabled="disabled"
          />
          <p class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Opcional: Ayuda a los inversores a encontrar tu proyecto
          </p>
        </div>

        <!-- Minimum Investment -->
        <div class="microcredit-form__field">
          <label class="microcredit-form__label">Inversión Mínima (€)</label>
          <Input
            v-model.number="formData.minimumInvestment"
            type="number"
            placeholder="100"
            :error="errors.minimumInvestment"
            :disabled="disabled"
            :min="10"
            :step="10"
          />
          <p v-if="errors.minimumInvestment" class="text-xs text-red-600 dark:text-red-400 mt-1">
            {{ errors.minimumInvestment }}
          </p>
          <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Opcional: Mínimo 10€
          </p>
        </div>
      </div>

      <!-- Deadline -->
      <div class="microcredit-form__field">
        <label class="microcredit-form__label">Fecha Límite de Financiación</label>
        <Input
          v-model="formData.deadline"
          type="date"
          :error="errors.deadline"
          :disabled="disabled"
        />
        <p v-if="errors.deadline" class="text-xs text-red-600 dark:text-red-400 mt-1">
          {{ errors.deadline }}
        </p>
        <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
          Opcional: Fecha límite para alcanzar la financiación
        </p>
      </div>

      <!-- Payment Summary -->
      <div v-if="isFormValid" class="p-4 bg-blue-50 dark:bg-blue-900 border border-blue-200 dark:border-blue-800 rounded-lg">
        <h3 class="text-sm font-semibold text-blue-900 dark:text-blue-200 mb-3">
          Resumen de Pagos
        </h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
          <div>
            <p class="text-blue-700 dark:text-blue-300 mb-1">Pago Mensual</p>
            <p class="text-lg font-bold text-blue-900 dark:text-blue-200">
              {{ formatCurrency(expectedMonthlyPayment) }}
            </p>
          </div>
          <div>
            <p class="text-blue-700 dark:text-blue-300 mb-1">Total a Devolver</p>
            <p class="text-lg font-bold text-blue-900 dark:text-blue-200">
              {{ formatCurrency(totalToRepay) }}
            </p>
          </div>
          <div>
            <p class="text-blue-700 dark:text-blue-300 mb-1">Intereses Totales</p>
            <p class="text-lg font-bold text-blue-900 dark:text-blue-200">
              {{ formatCurrency(totalToRepay - formData.amountRequested) }}
            </p>
          </div>
        </div>
      </div>

      <!-- Image Upload -->
      <div v-if="!compact" class="microcredit-form__field">
        <label class="microcredit-form__label">Imagen del Proyecto</label>
        <div v-if="formData.imageUrl" class="mb-3">
          <div class="relative inline-block">
            <img
              :src="formData.imageUrl"
              alt="Project preview"
              class="w-full max-w-md h-48 object-cover rounded-lg"
            />
            <button
              type="button"
              :disabled="disabled"
              @click="handleRemoveImage"
              class="absolute top-2 right-2 p-2 bg-red-600 text-white rounded-full hover:bg-red-700 transition-colors"
            >
              <Icon name="trash-2" class="w-4 h-4" />
            </button>
          </div>
        </div>
        <FileUpload
          v-else
          accept="image/*"
          :multiple="false"
          :disabled="disabled"
          @upload="handleImageUpload"
        >
          <div class="text-center py-8">
            <Icon name="image" class="w-12 h-12 mx-auto mb-3 text-gray-400" />
            <p class="text-sm text-gray-600 dark:text-gray-400">
              Arrastra una imagen o haz clic para seleccionar
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-500 mt-1">
              PNG, JPG hasta 5MB
            </p>
          </div>
        </FileUpload>
      </div>

      <!-- Actions -->
      <div class="microcredit-form__actions">
        <Button
          v-if="showCancel"
          type="button"
          variant="outline"
          :disabled="disabled || loading"
          @click="handleCancel"
        >
          Cancelar
        </Button>
        <Button
          type="submit"
          variant="primary"
          :disabled="!isFormValid || disabled || loading || (mode === 'edit' && !hasChanges)"
          :loading="loading"
          class="ml-auto"
        >
          <Icon :name="mode === 'create' ? 'send' : 'save'" class="w-4 h-4 mr-2" />
          {{ mode === 'create' ? 'Enviar Solicitud' : 'Guardar Cambios' }}
        </Button>
      </div>
    </form>
  </Card>
</template>

<style scoped>
.microcredit-form {
  @apply w-full;
}

.microcredit-form__header {
  @apply pb-6 border-b border-gray-200 dark:border-gray-700 mb-6;
}

.microcredit-form__body {
  @apply space-y-6;
}

.microcredit-form__field {
  @apply w-full;
}

.microcredit-form__label {
  @apply block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2;
}

.microcredit-form__actions {
  @apply flex items-center gap-3 pt-6 border-t border-gray-200 dark:border-gray-700;
}
</style>
