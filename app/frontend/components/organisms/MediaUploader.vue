<script setup lang="ts">
import { ref, computed } from 'vue'
import Button from '@/components/atoms/Button.vue'
import Icon from '@/components/atoms/Icon.vue'
import ProgressBar from '@/components/atoms/ProgressBar.vue'
import Badge from '@/components/atoms/Badge.vue'

export interface UploadFile {
  id: string
  file: File
  preview?: string
  progress: number
  status: 'pending' | 'uploading' | 'success' | 'error'
  error?: string
}

interface Props {
  /** Accept file types (e.g., "image/*", ".pdf,.doc") */
  accept?: string
  /** Maximum file size in bytes */
  maxSize?: number
  /** Maximum number of files */
  maxFiles?: number
  /** Allow multiple files */
  multiple?: boolean
  /** Show preview grid */
  showPreview?: boolean
  /** Disabled state */
  disabled?: boolean
  /** Uploaded files */
  modelValue?: UploadFile[]
}

interface Emits {
  (e: 'update:modelValue', files: UploadFile[]): void
  (e: 'upload', files: File[]): void
  (e: 'remove', fileId: string): void
  (e: 'error', error: string): void
}

const props = withDefaults(defineProps<Props>(), {
  accept: 'image/*',
  maxSize: 5 * 1024 * 1024, // 5MB
  maxFiles: 10,
  multiple: true,
  showPreview: true,
  disabled: false,
  modelValue: () => [],
})

const emit = defineEmits<Emits>()

// State
const isDragging = ref(false)
const fileInput = ref<HTMLInputElement>()
const files = ref<UploadFile[]>(props.modelValue)

// Computed
const hasFiles = computed(() => files.value.length > 0)
const canAddMore = computed(() => files.value.length < props.maxFiles)
const remainingSlots = computed(() => props.maxFiles - files.value.length)

// Format file size
const formatSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

// Validate file
const validateFile = (file: File): string | null => {
  // Check file size
  if (file.size > props.maxSize) {
    return `El archivo "${file.name}" excede el tamaño máximo de ${formatSize(props.maxSize)}`
  }

  // Check file type
  if (props.accept && props.accept !== '*') {
    const acceptedTypes = props.accept.split(',').map((t) => t.trim())
    const isAccepted = acceptedTypes.some((type) => {
      if (type.startsWith('.')) {
        return file.name.toLowerCase().endsWith(type.toLowerCase())
      }
      if (type.includes('/*')) {
        const category = type.split('/')[0]
        return file.type.startsWith(category)
      }
      return file.type === type
    })

    if (!isAccepted) {
      return `El archivo "${file.name}" no es un tipo permitido`
    }
  }

  // Check max files
  if (files.value.length >= props.maxFiles) {
    return `No puedes subir más de ${props.maxFiles} archivos`
  }

  return null
}

// Generate preview for images
const generatePreview = async (file: File): Promise<string | undefined> => {
  if (!file.type.startsWith('image/')) return undefined

  return new Promise((resolve) => {
    const reader = new FileReader()
    reader.onload = (e) => resolve(e.target?.result as string)
    reader.onerror = () => resolve(undefined)
    reader.readAsDataURL(file)
  })
}

// Add files
const addFiles = async (newFiles: File[]) => {
  const validFiles: UploadFile[] = []

  for (const file of newFiles) {
    // Validate
    const error = validateFile(file)
    if (error) {
      emit('error', error)
      continue
    }

    // Generate preview
    const preview = await generatePreview(file)

    // Create upload file object
    const uploadFile: UploadFile = {
      id: `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      file,
      preview,
      progress: 0,
      status: 'pending',
    }

    validFiles.push(uploadFile)
  }

  // Add to files array
  files.value = [...files.value, ...validFiles]
  emit('update:modelValue', files.value)

  // Emit upload event
  if (validFiles.length > 0) {
    emit('upload', validFiles.map((f) => f.file))
  }
}

// Handle file input change
const handleFileChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files) {
    addFiles(Array.from(target.files))
    // Reset input
    target.value = ''
  }
}

// Handle drop
const handleDrop = (event: DragEvent) => {
  isDragging.value = false
  event.preventDefault()
  event.stopPropagation()

  if (props.disabled) return

  const droppedFiles = event.dataTransfer?.files
  if (droppedFiles) {
    addFiles(Array.from(droppedFiles))
  }
}

// Handle drag events
const handleDragOver = (event: DragEvent) => {
  event.preventDefault()
  event.stopPropagation()
  if (!props.disabled) {
    isDragging.value = true
  }
}

const handleDragLeave = (event: DragEvent) => {
  event.preventDefault()
  event.stopPropagation()
  isDragging.value = false
}

// Remove file
const removeFile = (fileId: string) => {
  files.value = files.value.filter((f) => f.id !== fileId)
  emit('update:modelValue', files.value)
  emit('remove', fileId)
}

// Open file picker
const openFilePicker = () => {
  if (!props.disabled && canAddMore.value) {
    fileInput.value?.click()
  }
}

// Update file progress (exposed for parent component)
const updateFileProgress = (fileId: string, progress: number) => {
  const file = files.value.find((f) => f.id === fileId)
  if (file) {
    file.progress = progress
    if (progress >= 100) {
      file.status = 'success'
    } else {
      file.status = 'uploading'
    }
  }
}

// Update file status (exposed for parent component)
const updateFileStatus = (fileId: string, status: UploadFile['status'], error?: string) => {
  const file = files.value.find((f) => f.id === fileId)
  if (file) {
    file.status = status
    file.error = error
  }
}

// Get file type icon
const getFileIcon = (file: File): string => {
  if (file.type.startsWith('image/')) return 'image'
  if (file.type.startsWith('video/')) return 'video'
  if (file.type.startsWith('audio/')) return 'music'
  if (file.type.includes('pdf')) return 'file-text'
  if (file.type.includes('word')) return 'file-text'
  if (file.type.includes('excel') || file.type.includes('spreadsheet')) return 'table'
  return 'file'
}

// Expose methods
defineExpose({
  updateFileProgress,
  updateFileStatus,
  clearFiles: () => {
    files.value = []
    emit('update:modelValue', [])
  },
})
</script>

<template>
  <div class="media-uploader">
    <!-- Hidden file input -->
    <input
      ref="fileInput"
      type="file"
      :accept="accept"
      :multiple="multiple"
      class="hidden"
      @change="handleFileChange"
    />

    <!-- Drop Zone -->
    <div
      v-if="!hasFiles || canAddMore"
      class="media-uploader__dropzone"
      :class="{
        'media-uploader__dropzone--dragging': isDragging,
        'media-uploader__dropzone--disabled': disabled || !canAddMore,
      }"
      @click="openFilePicker"
      @drop="handleDrop"
      @dragover="handleDragOver"
      @dragleave="handleDragLeave"
    >
      <Icon name="upload-cloud" class="w-12 h-12 text-gray-400 mb-3" />
      <p class="text-lg font-medium text-gray-700 dark:text-gray-300 mb-1">
        Arrastra archivos aquí o haz clic para seleccionar
      </p>
      <p class="text-sm text-gray-500 dark:text-gray-400">
        Máximo {{ formatSize(maxSize) }} por archivo
        <span v-if="multiple"> • Hasta {{ maxFiles }} archivos</span>
      </p>
      <p v-if="!canAddMore" class="text-sm text-warning mt-2">
        Límite alcanzado ({{ maxFiles }} archivos)
      </p>
    </div>

    <!-- File Preview Grid -->
    <div v-if="hasFiles && showPreview" class="media-uploader__grid">
      <div
        v-for="uploadFile in files"
        :key="uploadFile.id"
        class="media-uploader__item"
      >
        <!-- Preview -->
        <div class="media-uploader__preview">
          <!-- Image Preview -->
          <img
            v-if="uploadFile.preview"
            :src="uploadFile.preview"
            :alt="uploadFile.file.name"
            class="w-full h-full object-cover"
          />
          <!-- File Icon -->
          <div v-else class="media-uploader__icon">
            <Icon :name="getFileIcon(uploadFile.file)" class="w-8 h-8 text-gray-400" />
          </div>

          <!-- Status Overlay -->
          <div
            v-if="uploadFile.status !== 'success'"
            class="media-uploader__overlay"
          >
            <!-- Uploading -->
            <div v-if="uploadFile.status === 'uploading'" class="text-center">
              <Icon name="loader" class="w-6 h-6 text-white animate-spin mb-2" />
              <p class="text-xs text-white">{{ uploadFile.progress }}%</p>
            </div>
            <!-- Error -->
            <div v-else-if="uploadFile.status === 'error'" class="text-center">
              <Icon name="alert-circle" class="w-6 h-6 text-error mb-2" />
              <p class="text-xs text-white">Error</p>
            </div>
          </div>

          <!-- Remove Button -->
          <button
            class="media-uploader__remove"
            @click.stop="removeFile(uploadFile.id)"
          >
            <Icon name="x" class="w-4 h-4" />
          </button>

          <!-- Status Badge -->
          <div class="media-uploader__status">
            <Badge
              v-if="uploadFile.status === 'success'"
              variant="success"
              size="sm"
            >
              <Icon name="check" class="w-3 h-3" />
            </Badge>
            <Badge
              v-else-if="uploadFile.status === 'error'"
              variant="error"
              size="sm"
            >
              <Icon name="x" class="w-3 h-3" />
            </Badge>
          </div>
        </div>

        <!-- File Info -->
        <div class="media-uploader__info">
          <p class="text-xs font-medium text-gray-900 dark:text-white truncate">
            {{ uploadFile.file.name }}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400">
            {{ formatSize(uploadFile.file.size) }}
          </p>

          <!-- Progress Bar -->
          <ProgressBar
            v-if="uploadFile.status === 'uploading'"
            :value="uploadFile.progress"
            variant="primary"
            size="sm"
            class="mt-1"
          />

          <!-- Error Message -->
          <p v-if="uploadFile.error" class="text-xs text-error mt-1">
            {{ uploadFile.error }}
          </p>
        </div>
      </div>

      <!-- Add More Slot -->
      <div
        v-if="canAddMore"
        class="media-uploader__add-more"
        @click="openFilePicker"
      >
        <Icon name="plus" class="w-8 h-8 text-gray-400" />
        <p class="text-xs text-gray-500 mt-2">Añadir más</p>
        <p class="text-xs text-gray-400">({{ remainingSlots }} restantes)</p>
      </div>
    </div>

    <!-- File List (Alternative to Grid) -->
    <div v-if="hasFiles && !showPreview" class="media-uploader__list">
      <div
        v-for="uploadFile in files"
        :key="uploadFile.id"
        class="media-uploader__list-item"
      >
        <Icon :name="getFileIcon(uploadFile.file)" class="w-5 h-5 text-gray-400" />
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
            {{ uploadFile.file.name }}
          </p>
          <p class="text-xs text-gray-500">{{ formatSize(uploadFile.file.size) }}</p>
          <ProgressBar
            v-if="uploadFile.status === 'uploading'"
            :value="uploadFile.progress"
            size="sm"
            class="mt-1"
          />
        </div>
        <button
          class="p-1 rounded hover:bg-gray-100 dark:hover:bg-gray-800"
          @click="removeFile(uploadFile.id)"
        >
          <Icon name="trash" class="w-4 h-4 text-gray-500" />
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.media-uploader {
  @apply w-full;
}

.media-uploader__dropzone {
  @apply relative border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg p-12 text-center cursor-pointer transition-colors;
  @apply hover:border-primary hover:bg-primary/5;
}

.media-uploader__dropzone--dragging {
  @apply border-primary bg-primary/10;
}

.media-uploader__dropzone--disabled {
  @apply opacity-50 cursor-not-allowed;
  @apply hover:border-gray-300 hover:bg-transparent;
}

.media-uploader__grid {
  @apply grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 mt-4;
}

.media-uploader__item {
  @apply relative;
}

.media-uploader__preview {
  @apply relative aspect-square bg-gray-100 dark:bg-gray-800 rounded-lg overflow-hidden border border-gray-200 dark:border-gray-700;
}

.media-uploader__icon {
  @apply w-full h-full flex items-center justify-center;
}

.media-uploader__overlay {
  @apply absolute inset-0 bg-black/50 flex items-center justify-center;
}

.media-uploader__remove {
  @apply absolute top-2 right-2 p-1 bg-black/50 rounded-full text-white hover:bg-black/70 transition-colors;
}

.media-uploader__status {
  @apply absolute bottom-2 right-2;
}

.media-uploader__info {
  @apply mt-2;
}

.media-uploader__add-more {
  @apply aspect-square border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg flex flex-col items-center justify-center cursor-pointer hover:border-primary hover:bg-primary/5 transition-colors;
}

.media-uploader__list {
  @apply space-y-2 mt-4;
}

.media-uploader__list-item {
  @apply flex items-center gap-3 p-3 border border-gray-200 dark:border-gray-700 rounded-lg;
}
</style>
