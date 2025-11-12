<script setup lang="ts">
import { ref, computed, watch, onUnmounted } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Button from '@/components/atoms/Button.vue'
import Input from '@/components/atoms/Input.vue'
import Textarea from '@/components/atoms/Textarea.vue'
import Select from '@/components/atoms/Select.vue'
import Icon from '@/components/atoms/Icon.vue'
import FileUpload from '@/components/molecules/FileUpload.vue'

export type CollaborationType = 'project' | 'initiative' | 'event' | 'campaign' | 'workshop' | 'other'

export interface CollaborationFormData {
  title: string
  description: string
  type: CollaborationType
  location?: string
  startDate?: string
  endDate?: string
  minCollaborators?: number
  maxCollaborators?: number
  skills: string[]
  imageFile?: File
  imageUrl?: string
}

interface Props {
  /** Initial form data */
  initialData?: Partial<CollaborationFormData>
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
  (e: 'submit', data: CollaborationFormData): void
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
const formData = ref<CollaborationFormData>({
  title: '',
  description: '',
  type: 'project',
  location: '',
  startDate: '',
  endDate: '',
  minCollaborators: undefined,
  maxCollaborators: undefined,
  skills: [],
  imageFile: undefined,
  imageUrl: '',
})

// Current skill input
const currentSkill = ref('')

// Errors
const errors = ref<Record<string, string>>({})

// Keep track of object URL for cleanup
const previousObjectUrl = ref<string | null>(null)

// Collaboration type options
const typeOptions = [
  { value: 'project', label: 'Proyecto' },
  { value: 'initiative', label: 'Iniciativa' },
  { value: 'event', label: 'Evento' },
  { value: 'campaign', label: 'Campaña' },
  { value: 'workshop', label: 'Taller' },
  { value: 'other', label: 'Otro' },
]

// Initialize form data
watch(
  () => props.initialData,
  (newData) => {
    if (newData) {
      formData.value = {
        title: newData.title || '',
        description: newData.description || '',
        type: newData.type || 'project',
        location: newData.location || '',
        startDate: newData.startDate || '',
        endDate: newData.endDate || '',
        minCollaborators: newData.minCollaborators,
        maxCollaborators: newData.maxCollaborators,
        skills: newData.skills || [],
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
  } else if (formData.value.title.length < 5) {
    errors.value.title = 'El título debe tener al menos 5 caracteres'
    isValid = false
  } else if (formData.value.title.length > 100) {
    errors.value.title = 'El título no puede exceder 100 caracteres'
    isValid = false
  }

  // Description validation
  if (!formData.value.description.trim()) {
    errors.value.description = 'La descripción es requerida'
    isValid = false
  } else if (formData.value.description.length < 20) {
    errors.value.description = 'La descripción debe tener al menos 20 caracteres'
    isValid = false
  } else if (formData.value.description.length > 1000) {
    errors.value.description = 'La descripción no puede exceder 1000 caracteres'
    isValid = false
  }

  // Collaborators validation
  if (formData.value.minCollaborators !== undefined && formData.value.minCollaborators !== null) {
    if (formData.value.minCollaborators < 1) {
      errors.value.minCollaborators = 'El mínimo debe ser al menos 1'
      isValid = false
    } else if (formData.value.minCollaborators > 100) {
      errors.value.minCollaborators = 'El mínimo no puede exceder 100'
      isValid = false
    }
  }

  if (formData.value.maxCollaborators !== undefined && formData.value.maxCollaborators !== null) {
    if (formData.value.maxCollaborators < 1) {
      errors.value.maxCollaborators = 'El máximo debe ser al menos 1'
      isValid = false
    } else if (formData.value.maxCollaborators > 100) {
      errors.value.maxCollaborators = 'El máximo no puede exceder 100'
      isValid = false
    }

    if (formData.value.minCollaborators && formData.value.maxCollaborators < formData.value.minCollaborators) {
      errors.value.maxCollaborators = 'El máximo no puede ser menor que el mínimo'
      isValid = false
    }
  }

  // Date validation
  if (formData.value.startDate && formData.value.endDate) {
    const start = new Date(formData.value.startDate)
    const end = new Date(formData.value.endDate)

    if (end < start) {
      errors.value.endDate = 'La fecha de fin debe ser posterior a la fecha de inicio'
      isValid = false
    }
  }

  // Location validation
  if (formData.value.location && formData.value.location.length > 200) {
    errors.value.location = 'La ubicación no puede exceder 200 caracteres'
    isValid = false
  }

  return isValid
}

// Character counts
const titleCharCount = computed(() => formData.value.title.length)
const descriptionCharCount = computed(() => formData.value.description.length)

// Is form valid
const isFormValid = computed(() => {
  return (
    formData.value.title.trim().length >= 5 &&
    formData.value.description.trim().length >= 20 &&
    (!formData.value.minCollaborators || (formData.value.minCollaborators >= 1 && formData.value.minCollaborators <= 100)) &&
    (!formData.value.maxCollaborators || (formData.value.maxCollaborators >= 1 && formData.value.maxCollaborators <= 100)) &&
    (!formData.value.minCollaborators || !formData.value.maxCollaborators || formData.value.maxCollaborators >= formData.value.minCollaborators)
  )
})

// Has changes
const hasChanges = computed(() => {
  if (!props.initialData) return true

  return (
    formData.value.title !== (props.initialData.title || '') ||
    formData.value.description !== (props.initialData.description || '') ||
    formData.value.type !== (props.initialData.type || 'project') ||
    formData.value.location !== (props.initialData.location || '') ||
    formData.value.startDate !== (props.initialData.startDate || '') ||
    formData.value.endDate !== (props.initialData.endDate || '') ||
    formData.value.minCollaborators !== props.initialData.minCollaborators ||
    formData.value.maxCollaborators !== props.initialData.maxCollaborators ||
    JSON.stringify(formData.value.skills) !== JSON.stringify(props.initialData.skills || []) ||
    formData.value.imageFile !== props.initialData.imageFile ||
    formData.value.imageUrl !== (props.initialData.imageUrl || '')
  )
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

const handleAddSkill = () => {
  const skill = currentSkill.value.trim()
  if (skill && !formData.value.skills.includes(skill)) {
    if (formData.value.skills.length >= 15) {
      errors.value.skills = 'No puedes agregar más de 15 habilidades'
      return
    }
    formData.value.skills.push(skill)
    currentSkill.value = ''
    delete errors.value.skills
  }
}

const handleRemoveSkill = (index: number) => {
  formData.value.skills.splice(index, 1)
}

const handleSkillKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Enter') {
    event.preventDefault()
    handleAddSkill()
  }
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

// Cleanup on unmount to prevent memory leaks
onUnmounted(() => {
  if (previousObjectUrl.value) {
    URL.revokeObjectURL(previousObjectUrl.value)
  }
})
</script>

<template>
  <Card :loading="loading" class="collaboration-form">
    <div class="collaboration-form__header">
      <h2 class="text-2xl font-bold mb-2">
        {{ mode === 'create' ? 'Crear Colaboración' : 'Editar Colaboración' }}
      </h2>
      <p class="text-sm text-gray-600 dark:text-gray-400">
        {{ mode === 'create'
          ? 'Completa la información para crear una nueva colaboración'
          : 'Actualiza la información de la colaboración'
        }}
      </p>
    </div>

    <form @submit.prevent="handleSubmit" class="collaboration-form__body">
      <!-- Title -->
      <div class="collaboration-form__field">
        <label class="collaboration-form__label">
          Título
          <span class="text-red-500">*</span>
        </label>
        <Input
          v-model="formData.title"
          type="text"
          placeholder="Ej: Proyecto de Huerto Comunitario"
          :error="errors.title"
          :disabled="disabled"
          maxlength="100"
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
      <div class="collaboration-form__field">
        <label class="collaboration-form__label">
          Descripción
          <span class="text-red-500">*</span>
        </label>
        <Textarea
          v-model="formData.description"
          placeholder="Describe la colaboración, objetivos y cómo pueden participar..."
          :error="errors.description"
          :disabled="disabled"
          :rows="compact ? 4 : 6"
          maxlength="1000"
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

      <!-- Type and Location Row -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Type -->
        <div class="collaboration-form__field">
          <label class="collaboration-form__label">
            Tipo de Colaboración
            <span class="text-red-500">*</span>
          </label>
          <Select
            v-model="formData.type"
            :options="typeOptions"
            :disabled="disabled"
          />
        </div>

        <!-- Location -->
        <div class="collaboration-form__field">
          <label class="collaboration-form__label">Ubicación</label>
          <Input
            v-model="formData.location"
            type="text"
            placeholder="Ej: Madrid, España"
            :error="errors.location"
            :disabled="disabled"
            maxlength="200"
          />
          <p v-if="errors.location" class="text-xs text-red-600 dark:text-red-400 mt-1">
            {{ errors.location }}
          </p>
          <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Opcional
          </p>
        </div>
      </div>

      <!-- Date Range Row -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Start Date -->
        <div class="collaboration-form__field">
          <label class="collaboration-form__label">Fecha de Inicio</label>
          <Input
            v-model="formData.startDate"
            type="date"
            :error="errors.startDate"
            :disabled="disabled"
          />
          <p v-if="errors.startDate" class="text-xs text-red-600 dark:text-red-400 mt-1">
            {{ errors.startDate }}
          </p>
          <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Opcional
          </p>
        </div>

        <!-- End Date -->
        <div class="collaboration-form__field">
          <label class="collaboration-form__label">Fecha de Fin</label>
          <Input
            v-model="formData.endDate"
            type="date"
            :error="errors.endDate"
            :disabled="disabled"
          />
          <p v-if="errors.endDate" class="text-xs text-red-600 dark:text-red-400 mt-1">
            {{ errors.endDate }}
          </p>
          <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Opcional
          </p>
        </div>
      </div>

      <!-- Collaborators Range Row -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Min Collaborators -->
        <div class="collaboration-form__field">
          <label class="collaboration-form__label">Mínimo de Colaboradores</label>
          <Input
            v-model.number="formData.minCollaborators"
            type="number"
            placeholder="Ej: 3"
            :error="errors.minCollaborators"
            :disabled="disabled"
            min="1"
            max="100"
          />
          <p v-if="errors.minCollaborators" class="text-xs text-red-600 dark:text-red-400 mt-1">
            {{ errors.minCollaborators }}
          </p>
          <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Opcional
          </p>
        </div>

        <!-- Max Collaborators -->
        <div class="collaboration-form__field">
          <label class="collaboration-form__label">Máximo de Colaboradores</label>
          <Input
            v-model.number="formData.maxCollaborators"
            type="number"
            placeholder="Ej: 10"
            :error="errors.maxCollaborators"
            :disabled="disabled"
            min="1"
            max="100"
          />
          <p v-if="errors.maxCollaborators" class="text-xs text-red-600 dark:text-red-400 mt-1">
            {{ errors.maxCollaborators }}
          </p>
          <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Opcional
          </p>
        </div>
      </div>

      <!-- Skills -->
      <div class="collaboration-form__field">
        <label class="collaboration-form__label">Habilidades Necesarias</label>
        <div class="flex gap-2 mb-2">
          <Input
            v-model="currentSkill"
            type="text"
            placeholder="Agregar habilidad..."
            :disabled="disabled || formData.skills.length >= 15"
            @keydown="handleSkillKeydown"
            class="flex-1"
          />
          <Button
            type="button"
            variant="outline"
            size="sm"
            :disabled="!currentSkill.trim() || disabled || formData.skills.length >= 15"
            @click="handleAddSkill"
          >
            <Icon name="plus" class="w-4 h-4" />
          </Button>
        </div>
        <p v-if="errors.skills" class="text-xs text-red-600 dark:text-red-400 mb-2">
          {{ errors.skills }}
        </p>
        <div v-if="formData.skills.length > 0" class="flex flex-wrap gap-2">
          <div
            v-for="(skill, index) in formData.skills"
            :key="index"
            class="inline-flex items-center gap-1 px-3 py-1 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-full text-sm"
          >
            <span>{{ skill }}</span>
            <button
              type="button"
              :disabled="disabled"
              @click="handleRemoveSkill(index)"
              class="hover:text-red-600 dark:hover:text-red-400 transition-colors"
            >
              <Icon name="x" class="w-3 h-3" />
            </button>
          </div>
        </div>
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">
          {{ formData.skills.length }} / 15 habilidades
        </p>
      </div>

      <!-- Image Upload -->
      <div v-if="!compact" class="collaboration-form__field">
        <label class="collaboration-form__label">Imagen de la Colaboración</label>
        <div v-if="formData.imageUrl" class="mb-3">
          <div class="relative inline-block">
            <img
              :src="formData.imageUrl"
              alt="Collaboration preview"
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
      <div class="collaboration-form__actions">
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
          <Icon :name="mode === 'create' ? 'plus' : 'save'" class="w-4 h-4 mr-2" />
          {{ mode === 'create' ? 'Crear Colaboración' : 'Guardar Cambios' }}
        </Button>
      </div>
    </form>
  </Card>
</template>

<style scoped>
.collaboration-form {
  @apply w-full;
}

.collaboration-form__header {
  @apply pb-6 border-b border-gray-200 dark:border-gray-700 mb-6;
}

.collaboration-form__body {
  @apply space-y-6;
}

.collaboration-form__field {
  @apply w-full;
}

.collaboration-form__label {
  @apply block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2;
}

.collaboration-form__actions {
  @apply flex items-center gap-3 pt-6 border-t border-gray-200 dark:border-gray-700;
}
</style>
