<script setup lang="ts">
import { ref, computed, watch, onUnmounted } from 'vue'
import Card from '@/components/molecules/Card.vue'
import Button from '@/components/atoms/Button.vue'
import Input from '@/components/atoms/Input.vue'
import Textarea from '@/components/atoms/Textarea.vue'
import Select from '@/components/atoms/Select.vue'
import Icon from '@/components/atoms/Icon.vue'
import FileUpload from '@/components/molecules/FileUpload.vue'

export type TeamStatus = 'active' | 'recruiting' | 'full' | 'inactive'

export interface ParticipationFormData {
  name: string
  description: string
  maxMembers?: number
  status: TeamStatus
  meetingSchedule?: string
  tags: string[]
  imageFile?: File
  imageUrl?: string
}

interface Props {
  /** Initial form data */
  initialData?: Partial<ParticipationFormData>
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
  (e: 'submit', data: ParticipationFormData): void
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
const formData = ref<ParticipationFormData>({
  name: '',
  description: '',
  maxMembers: undefined,
  status: 'recruiting',
  meetingSchedule: '',
  tags: [],
  imageFile: undefined,
  imageUrl: '',
})

// Current tag input
const currentTag = ref('')

// Errors
const errors = ref<Record<string, string>>({})

// Keep track of object URL for cleanup
const previousObjectUrl = ref<string | null>(null)

// Status options
const statusOptions = [
  { value: 'active', label: 'Activo' },
  { value: 'recruiting', label: 'Reclutando' },
  { value: 'full', label: 'Completo' },
  { value: 'inactive', label: 'Inactivo' },
]

// Initialize form data
watch(
  () => props.initialData,
  (newData) => {
    if (newData) {
      formData.value = {
        name: newData.name || '',
        description: newData.description || '',
        maxMembers: newData.maxMembers,
        status: newData.status || 'recruiting',
        meetingSchedule: newData.meetingSchedule || '',
        tags: newData.tags || [],
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

  // Name validation
  if (!formData.value.name.trim()) {
    errors.value.name = 'El nombre del equipo es requerido'
    isValid = false
  } else if (formData.value.name.length < 3) {
    errors.value.name = 'El nombre debe tener al menos 3 caracteres'
    isValid = false
  } else if (formData.value.name.length > 100) {
    errors.value.name = 'El nombre no puede exceder 100 caracteres'
    isValid = false
  }

  // Description validation
  if (!formData.value.description.trim()) {
    errors.value.description = 'La descripción es requerida'
    isValid = false
  } else if (formData.value.description.length < 20) {
    errors.value.description = 'La descripción debe tener al menos 20 caracteres'
    isValid = false
  } else if (formData.value.description.length > 500) {
    errors.value.description = 'La descripción no puede exceder 500 caracteres'
    isValid = false
  }

  // Max members validation
  if (formData.value.maxMembers !== undefined) {
    if (formData.value.maxMembers < 2) {
      errors.value.maxMembers = 'El equipo debe tener al menos 2 miembros'
      isValid = false
    } else if (formData.value.maxMembers > 100) {
      errors.value.maxMembers = 'El equipo no puede tener más de 100 miembros'
      isValid = false
    }
  }

  // Meeting schedule validation (optional)
  if (formData.value.meetingSchedule && formData.value.meetingSchedule.length > 100) {
    errors.value.meetingSchedule = 'El horario no puede exceder 100 caracteres'
    isValid = false
  }

  return isValid
}

// Character counts
const nameCharCount = computed(() => formData.value.name.length)
const descriptionCharCount = computed(() => formData.value.description.length)

// Is form valid
const isFormValid = computed(() => {
  return (
    formData.value.name.trim().length >= 3 &&
    formData.value.description.trim().length >= 20 &&
    (!formData.value.maxMembers || (formData.value.maxMembers >= 2 && formData.value.maxMembers <= 100))
  )
})

// Has changes
const hasChanges = computed(() => {
  if (!props.initialData) return true

  return (
    formData.value.name !== (props.initialData.name || '') ||
    formData.value.description !== (props.initialData.description || '') ||
    formData.value.maxMembers !== props.initialData.maxMembers ||
    formData.value.status !== (props.initialData.status || 'recruiting') ||
    formData.value.meetingSchedule !== (props.initialData.meetingSchedule || '') ||
    JSON.stringify(formData.value.tags) !== JSON.stringify(props.initialData.tags || []) ||
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

const handleAddTag = () => {
  const tag = currentTag.value.trim()
  if (tag && !formData.value.tags.includes(tag)) {
    if (formData.value.tags.length >= 10) {
      errors.value.tags = 'No puedes agregar más de 10 etiquetas'
      return
    }
    formData.value.tags.push(tag)
    currentTag.value = ''
    delete errors.value.tags
  }
}

const handleRemoveTag = (index: number) => {
  formData.value.tags.splice(index, 1)
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

const handleTagKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Enter') {
    event.preventDefault()
    handleAddTag()
  }
}

// Cleanup on unmount to prevent memory leaks
onUnmounted(() => {
  if (previousObjectUrl.value) {
    URL.revokeObjectURL(previousObjectUrl.value)
  }
})
</script>

<template>
  <Card :loading="loading" class="participation-form">
    <div class="participation-form__header">
      <h2 class="text-2xl font-bold mb-2">
        {{ mode === 'create' ? 'Crear Equipo de Participación' : 'Editar Equipo' }}
      </h2>
      <p class="text-sm text-gray-600 dark:text-gray-400">
        {{ mode === 'create'
          ? 'Completa la información para crear un nuevo equipo de participación ciudadana'
          : 'Actualiza la información del equipo'
        }}
      </p>
    </div>

    <form @submit.prevent="handleSubmit" class="participation-form__body">
      <!-- Team Name -->
      <div class="participation-form__field">
        <label class="participation-form__label">
          Nombre del Equipo
          <span class="text-red-500">*</span>
        </label>
        <Input
          v-model="formData.name"
          type="text"
          placeholder="Ej: Equipo de Medio Ambiente"
          :error="errors.name"
          :disabled="disabled"
          maxlength="100"
        />
        <div class="flex items-center justify-between mt-1">
          <p v-if="errors.name" class="text-xs text-red-600 dark:text-red-400">
            {{ errors.name }}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400 ml-auto">
            {{ nameCharCount }} / 100
          </p>
        </div>
      </div>

      <!-- Description -->
      <div class="participation-form__field">
        <label class="participation-form__label">
          Descripción
          <span class="text-red-500">*</span>
        </label>
        <Textarea
          v-model="formData.description"
          placeholder="Describe los objetivos y actividades del equipo..."
          :error="errors.description"
          :disabled="disabled"
          :rows="compact ? 3 : 4"
          maxlength="500"
        />
        <div class="flex items-center justify-between mt-1">
          <p v-if="errors.description" class="text-xs text-red-600 dark:text-red-400">
            {{ errors.description }}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400 ml-auto">
            {{ descriptionCharCount }} / 500
          </p>
        </div>
      </div>

      <!-- Status and Max Members Row -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Status -->
        <div class="participation-form__field">
          <label class="participation-form__label">Estado</label>
          <Select
            v-model="formData.status"
            :options="statusOptions"
            :disabled="disabled"
          />
        </div>

        <!-- Max Members -->
        <div class="participation-form__field">
          <label class="participation-form__label">Máximo de Miembros</label>
          <Input
            v-model.number="formData.maxMembers"
            type="number"
            placeholder="Ej: 15"
            :error="errors.maxMembers"
            :disabled="disabled"
            min="2"
            max="100"
          />
          <p v-if="errors.maxMembers" class="text-xs text-red-600 dark:text-red-400 mt-1">
            {{ errors.maxMembers }}
          </p>
          <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
            Deja vacío para sin límite
          </p>
        </div>
      </div>

      <!-- Meeting Schedule -->
      <div class="participation-form__field">
        <label class="participation-form__label">Horario de Reuniones</label>
        <Input
          v-model="formData.meetingSchedule"
          type="text"
          placeholder="Ej: Jueves 18:00"
          :error="errors.meetingSchedule"
          :disabled="disabled"
          maxlength="100"
        />
        <p v-if="errors.meetingSchedule" class="text-xs text-red-600 dark:text-red-400 mt-1">
          {{ errors.meetingSchedule }}
        </p>
        <p v-else class="text-xs text-gray-500 dark:text-gray-400 mt-1">
          Opcional: Cuándo se reúne el equipo regularmente
        </p>
      </div>

      <!-- Tags -->
      <div class="participation-form__field">
        <label class="participation-form__label">Etiquetas</label>
        <div class="flex gap-2 mb-2">
          <Input
            v-model="currentTag"
            type="text"
            placeholder="Agregar etiqueta..."
            :disabled="disabled || formData.tags.length >= 10"
            @keydown="handleTagKeydown"
            class="flex-1"
          />
          <Button
            type="button"
            variant="outline"
            size="sm"
            :disabled="!currentTag.trim() || disabled || formData.tags.length >= 10"
            @click="handleAddTag"
          >
            <Icon name="plus" class="w-4 h-4" />
          </Button>
        </div>
        <p v-if="errors.tags" class="text-xs text-red-600 dark:text-red-400 mb-2">
          {{ errors.tags }}
        </p>
        <div v-if="formData.tags.length > 0" class="flex flex-wrap gap-2">
          <div
            v-for="(tag, index) in formData.tags"
            :key="index"
            class="inline-flex items-center gap-1 px-3 py-1 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-full text-sm"
          >
            <span>{{ tag }}</span>
            <button
              type="button"
              :disabled="disabled"
              @click="handleRemoveTag(index)"
              class="hover:text-red-600 dark:hover:text-red-400 transition-colors"
            >
              <Icon name="x" class="w-3 h-3" />
            </button>
          </div>
        </div>
        <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">
          {{ formData.tags.length }} / 10 etiquetas
        </p>
      </div>

      <!-- Image Upload -->
      <div v-if="!compact" class="participation-form__field">
        <label class="participation-form__label">Imagen del Equipo</label>
        <div v-if="formData.imageUrl" class="mb-3">
          <div class="relative inline-block">
            <img
              :src="formData.imageUrl"
              alt="Team preview"
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
      <div class="participation-form__actions">
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
          {{ mode === 'create' ? 'Crear Equipo' : 'Guardar Cambios' }}
        </Button>
      </div>
    </form>
  </Card>
</template>

<style scoped>
.participation-form {
  @apply w-full;
}

.participation-form__header {
  @apply pb-6 border-b border-gray-200 dark:border-gray-700 mb-6;
}

.participation-form__body {
  @apply space-y-6;
}

.participation-form__field {
  @apply w-full;
}

.participation-form__label {
  @apply block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2;
}

.participation-form__actions {
  @apply flex items-center gap-3 pt-6 border-t border-gray-200 dark:border-gray-700;
}
</style>
