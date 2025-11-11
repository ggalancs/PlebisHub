<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '../atoms/Icon.vue'
import Button from '../atoms/Button.vue'

export interface FileItem {
  id: string
  file: File
  preview?: string
  progress?: number
  error?: string
}

export interface FileUploadProps {
  /**
   * Accept specific file types (e.g., "image/*", ".pdf,.doc")
   */
  accept?: string
  /**
   * Allow multiple file selection
   * @default false
   */
  multiple?: boolean
  /**
   * Maximum file size in bytes
   */
  maxSize?: number
  /**
   * Maximum number of files
   */
  maxFiles?: number
  /**
   * Whether the component is disabled
   * @default false
   */
  disabled?: boolean
  /**
   * Show file previews
   * @default true
   */
  showPreview?: boolean
  /**
   * Variant style
   * @default 'default'
   */
  variant?: 'default' | 'compact' | 'minimal'
}

const props = withDefaults(defineProps<FileUploadProps>(), {
  accept: undefined,
  multiple: false,
  maxSize: undefined,
  maxFiles: undefined,
  disabled: false,
  showPreview: true,
  variant: 'default',
})

const emit = defineEmits<{
  'update:modelValue': [files: FileItem[]]
  change: [files: FileItem[]]
  error: [error: string]
  remove: [id: string]
}>()

const fileInput = ref<HTMLInputElement | null>(null)
const files = ref<FileItem[]>([])
const isDragging = ref(false)

const hasFiles = computed(() => files.value.length > 0)

const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round((bytes / Math.pow(k, i)) * 100) / 100 + ' ' + sizes[i]
}

const isImageFile = (file: File): boolean => {
  return file.type.startsWith('image/')
}

const validateFile = (file: File): string | null => {
  // Check max size
  if (props.maxSize && file.size > props.maxSize) {
    return `File size exceeds maximum of ${formatFileSize(props.maxSize)}`
  }

  // Check max files
  if (props.maxFiles && files.value.length >= props.maxFiles) {
    return `Maximum number of files (${props.maxFiles}) reached`
  }

  // Check file type if accept is specified
  if (props.accept) {
    const acceptedTypes = props.accept.split(',').map((t) => t.trim())
    const isAccepted = acceptedTypes.some((type) => {
      if (type.startsWith('.')) {
        return file.name.toLowerCase().endsWith(type.toLowerCase())
      }
      if (type.endsWith('/*')) {
        const category = type.split('/')[0]
        return file.type.startsWith(category + '/')
      }
      return file.type === type
    })

    if (!isAccepted) {
      return `File type not accepted. Allowed: ${props.accept}`
    }
  }

  return null
}

const createFileItem = (file: File): FileItem => {
  const id = `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
  const item: FileItem = { id, file }

  // Create preview for images
  if (isImageFile(file) && props.showPreview) {
    const reader = new FileReader()
    reader.onload = (e) => {
      const fileItem = files.value.find((f) => f.id === id)
      if (fileItem && e.target?.result) {
        fileItem.preview = e.target.result as string
      }
    }
    reader.readAsDataURL(file)
  }

  return item
}

const addFiles = (newFiles: File[]) => {
  if (props.disabled) return

  const filesToAdd: FileItem[] = []

  for (const file of newFiles) {
    // Validate file
    const error = validateFile(file)
    if (error) {
      emit('error', error)
      continue
    }

    // Check if already added
    const isDuplicate = files.value.some(
      (f) => f.file.name === file.name && f.file.size === file.size
    )
    if (isDuplicate) {
      emit('error', `File "${file.name}" is already added`)
      continue
    }

    filesToAdd.push(createFileItem(file))

    // Stop if we've reached max files
    if (props.maxFiles && files.value.length + filesToAdd.length >= props.maxFiles) {
      break
    }
  }

  if (filesToAdd.length > 0) {
    if (props.multiple) {
      files.value = [...files.value, ...filesToAdd]
    } else {
      files.value = [filesToAdd[0]]
    }

    emit('update:modelValue', files.value)
    emit('change', files.value)
  }
}

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    addFiles(Array.from(target.files))
    // Reset input so the same file can be selected again
    target.value = ''
  }
}

const handleDrop = (event: DragEvent) => {
  isDragging.value = false
  if (props.disabled) return

  const droppedFiles = event.dataTransfer?.files
  if (droppedFiles && droppedFiles.length > 0) {
    addFiles(Array.from(droppedFiles))
  }
}

const handleDragOver = (event: DragEvent) => {
  event.preventDefault()
  if (!props.disabled) {
    isDragging.value = true
  }
}

const handleDragLeave = () => {
  isDragging.value = false
}

const removeFile = (id: string) => {
  if (props.disabled) return

  files.value = files.value.filter((f) => f.id !== id)
  emit('update:modelValue', files.value)
  emit('change', files.value)
  emit('remove', id)
}

const openFilePicker = () => {
  if (!props.disabled) {
    fileInput.value?.click()
  }
}

const dropzoneClasses = computed(() => {
  const base =
    'border-2 border-dashed rounded-lg transition-colors cursor-pointer flex flex-col items-center justify-center gap-3'
  const state = props.disabled
    ? 'border-gray-200 bg-gray-50 cursor-not-allowed opacity-50'
    : isDragging.value
      ? 'border-primary bg-primary/5'
      : 'border-gray-300 hover:border-primary hover:bg-gray-50'

  const sizes = {
    default: 'p-8 min-h-[200px]',
    compact: 'p-6 min-h-[150px]',
    minimal: 'p-4 min-h-[100px]',
  }

  return [base, state, sizes[props.variant]]
})

const fileListItemClasses = computed(() => {
  return 'flex items-center gap-3 p-3 border border-gray-200 rounded-lg bg-white hover:bg-gray-50 transition-colors'
})
</script>

<template>
  <div class="file-upload">
    <!-- Hidden file input -->
    <input
      ref="fileInput"
      type="file"
      :accept="accept"
      :multiple="multiple"
      :disabled="disabled"
      class="hidden"
      @change="handleFileSelect"
    />

    <!-- Dropzone -->
    <div
      v-if="!hasFiles || multiple"
      :class="dropzoneClasses"
      @click="openFilePicker"
      @drop.prevent="handleDrop"
      @dragover.prevent="handleDragOver"
      @dragleave="handleDragLeave"
    >
      <Icon
        :name="isDragging ? 'upload-cloud' : 'upload'"
        :size="variant === 'minimal' ? 32 : variant === 'compact' ? 40 : 48"
        :class="isDragging ? 'text-primary' : 'text-gray-400'"
      />

      <div class="text-center">
        <p
          class="font-medium"
          :class="{
            'text-sm': variant === 'minimal',
            'text-base': variant === 'compact',
            'text-lg': variant === 'default',
          }"
        >
          <span v-if="isDragging" class="text-primary">Drop files here</span>
          <span v-else class="text-gray-700">
            <slot name="label">
              <span class="text-primary">Click to upload</span>
              or drag and drop
            </slot>
          </span>
        </p>

        <p
          v-if="variant !== 'minimal'"
          class="mt-1 text-gray-500"
          :class="{
            'text-xs': variant === 'compact',
            'text-sm': variant === 'default',
          }"
        >
          <slot name="hint">
            <span v-if="accept">{{ accept }}</span>
            <span v-if="accept && maxSize"> • </span>
            <span v-if="maxSize">Max {{ formatFileSize(maxSize) }}</span>
          </slot>
        </p>
      </div>
    </div>

    <!-- File list -->
    <div v-if="hasFiles && showPreview" class="file-list mt-4 space-y-2">
      <div v-for="fileItem in files" :key="fileItem.id" :class="fileListItemClasses">
        <!-- Preview or icon -->
        <div class="flex-shrink-0">
          <img
            v-if="fileItem.preview"
            :src="fileItem.preview"
            :alt="fileItem.file.name"
            class="h-12 w-12 rounded object-cover"
          />
          <div v-else class="flex h-12 w-12 items-center justify-center rounded bg-gray-100">
            <Icon name="file" :size="24" class="text-gray-400" />
          </div>
        </div>

        <!-- File info -->
        <div class="min-w-0 flex-1">
          <p class="truncate text-sm font-medium text-gray-900">
            {{ fileItem.file.name }}
          </p>
          <p class="text-xs text-gray-500">
            {{ formatFileSize(fileItem.file.size) }}
          </p>
          <p v-if="fileItem.error" class="mt-1 text-xs text-red-600">
            {{ fileItem.error }}
          </p>
        </div>

        <!-- Progress bar -->
        <div v-if="fileItem.progress !== undefined" class="w-20 flex-shrink-0">
          <div class="h-1.5 w-full rounded-full bg-gray-200">
            <div
              class="bg-primary h-1.5 rounded-full transition-all"
              :style="{ width: `${fileItem.progress}%` }"
            />
          </div>
          <p class="mt-1 text-center text-xs text-gray-500">{{ fileItem.progress }}%</p>
        </div>

        <!-- Remove button -->
        <Button
          size="sm"
          variant="ghost"
          :disabled="disabled"
          :aria-label="`Remove ${fileItem.file.name}`"
          @click.stop="removeFile(fileItem.id)"
        >
          <Icon name="x" :size="16" />
        </Button>
      </div>
    </div>
  </div>
</template>
