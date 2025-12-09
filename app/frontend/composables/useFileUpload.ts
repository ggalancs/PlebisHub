/**
 * File Upload Composable
 * Replaces jQuery File Upload plugin with Vue reactive system
 */

import { ref, computed, type Ref } from 'vue'

export interface UploadedFile {
  id: string
  name: string
  size: number
  type: string
  url?: string
  progress: number
  status: 'pending' | 'uploading' | 'success' | 'error'
  error?: string
  response?: unknown
}

export interface UseFileUploadOptions {
  /** Upload URL */
  url: string
  /** HTTP method */
  method?: 'POST' | 'PUT' | 'PATCH'
  /** Form field name */
  fieldName?: string
  /** Maximum file size in bytes */
  maxSize?: number
  /** Accepted file types (MIME or extension) */
  accept?: string[]
  /** Allow multiple files */
  multiple?: boolean
  /** Maximum number of files */
  maxFiles?: number
  /** Auto upload on file selection */
  autoUpload?: boolean
  /** Additional form data */
  data?: Record<string, string>
  /** Request headers */
  headers?: Record<string, string>
  /** With credentials */
  withCredentials?: boolean
  /** CSRF token */
  csrfToken?: string
  /** Callbacks */
  onProgress?: (file: UploadedFile, progress: number) => void
  onSuccess?: (file: UploadedFile, response: unknown) => void
  onError?: (file: UploadedFile, error: string) => void
  onComplete?: (files: UploadedFile[]) => void
}

export function useFileUpload(options: UseFileUploadOptions) {
  // State
  const files: Ref<UploadedFile[]> = ref([])
  const isUploading = ref(false)
  const isDragging = ref(false)

  // Computed
  const pendingFiles = computed(() => files.value.filter((f) => f.status === 'pending'))
  const uploadingFiles = computed(() => files.value.filter((f) => f.status === 'uploading'))
  const completedFiles = computed(() =>
    files.value.filter((f) => f.status === 'success' || f.status === 'error')
  )
  const successFiles = computed(() => files.value.filter((f) => f.status === 'success'))
  const errorFiles = computed(() => files.value.filter((f) => f.status === 'error'))

  const totalProgress = computed(() => {
    if (files.value.length === 0) return 0
    const total = files.value.reduce((sum, f) => sum + f.progress, 0)
    return Math.round(total / files.value.length)
  })

  // Generate unique ID
  function generateId(): string {
    return `file-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`
  }

  // Validate file
  function validateFile(file: File): string | null {
    // Check size
    if (options.maxSize && file.size > options.maxSize) {
      const maxMB = (options.maxSize / 1024 / 1024).toFixed(1)
      return `El archivo es demasiado grande. Máximo: ${maxMB}MB`
    }

    // Check type
    if (options.accept && options.accept.length > 0) {
      const isAccepted = options.accept.some((accept) => {
        if (accept.startsWith('.')) {
          return file.name.toLowerCase().endsWith(accept.toLowerCase())
        }
        if (accept.endsWith('/*')) {
          return file.type.startsWith(accept.replace('/*', '/'))
        }
        return file.type === accept
      })

      if (!isAccepted) {
        return `Tipo de archivo no permitido: ${file.type}`
      }
    }

    return null
  }

  // Add files
  function addFiles(fileList: FileList | File[]): UploadedFile[] {
    const newFiles: UploadedFile[] = []
    const maxFiles = options.maxFiles ?? Infinity

    for (const file of Array.from(fileList)) {
      // Check max files
      if (files.value.length + newFiles.length >= maxFiles) {
        break
      }

      const error = validateFile(file)
      const uploadedFile: UploadedFile = {
        id: generateId(),
        name: file.name,
        size: file.size,
        type: file.type,
        progress: 0,
        status: error ? 'error' : 'pending',
        error: error ?? undefined,
      }

      // Store native file reference
      ;(uploadedFile as UploadedFile & { _file: File })._file = file

      newFiles.push(uploadedFile)
    }

    files.value = [...files.value, ...newFiles]

    // Auto upload if enabled
    if (options.autoUpload) {
      uploadAll()
    }

    return newFiles
  }

  // Remove file
  function removeFile(id: string): void {
    files.value = files.value.filter((f) => f.id !== id)
  }

  // Clear all files
  function clearFiles(): void {
    files.value = []
  }

  // Upload single file
  async function uploadFile(uploadedFile: UploadedFile): Promise<void> {
    const file = (uploadedFile as UploadedFile & { _file?: File })._file
    if (!file) {
      uploadedFile.status = 'error'
      uploadedFile.error = 'Archivo no encontrado'
      return
    }

    uploadedFile.status = 'uploading'
    uploadedFile.progress = 0

    const formData = new FormData()
    formData.append(options.fieldName ?? 'file', file)

    // Add additional data
    if (options.data) {
      Object.entries(options.data).forEach(([key, value]) => {
        formData.append(key, value)
      })
    }

    // Build headers
    const headers: Record<string, string> = {
      ...options.headers,
    }

    // Add CSRF token
    const csrfToken =
      options.csrfToken ||
      document.querySelector<HTMLMetaElement>('meta[name="csrf-token"]')?.content
    if (csrfToken) {
      headers['X-CSRF-Token'] = csrfToken
    }

    try {
      const response = await new Promise<unknown>((resolve, reject) => {
        const xhr = new XMLHttpRequest()

        xhr.upload.addEventListener('progress', (e) => {
          if (e.lengthComputable) {
            uploadedFile.progress = Math.round((e.loaded / e.total) * 100)
            options.onProgress?.(uploadedFile, uploadedFile.progress)
          }
        })

        xhr.addEventListener('load', () => {
          if (xhr.status >= 200 && xhr.status < 300) {
            try {
              resolve(JSON.parse(xhr.responseText))
            } catch {
              resolve(xhr.responseText)
            }
          } else {
            let errorMessage = `Error ${xhr.status}`
            try {
              const errorResponse = JSON.parse(xhr.responseText)
              errorMessage = errorResponse.error || errorResponse.message || errorMessage
            } catch {
              // Use default error message
            }
            reject(new Error(errorMessage))
          }
        })

        xhr.addEventListener('error', () => {
          reject(new Error('Error de red'))
        })

        xhr.addEventListener('abort', () => {
          reject(new Error('Subida cancelada'))
        })

        xhr.open(options.method ?? 'POST', options.url)

        // Set headers
        Object.entries(headers).forEach(([key, value]) => {
          xhr.setRequestHeader(key, value)
        })

        if (options.withCredentials) {
          xhr.withCredentials = true
        }

        xhr.send(formData)
      })

      uploadedFile.status = 'success'
      uploadedFile.progress = 100
      uploadedFile.response = response

      // Extract URL from response if available
      if (typeof response === 'object' && response !== null) {
        const resp = response as Record<string, unknown>
        uploadedFile.url = (resp.url || resp.path || resp.file_url) as string | undefined
      }

      options.onSuccess?.(uploadedFile, response)
    } catch (error) {
      uploadedFile.status = 'error'
      uploadedFile.error = error instanceof Error ? error.message : 'Error desconocido'
      options.onError?.(uploadedFile, uploadedFile.error)
    }
  }

  // Upload all pending files
  async function uploadAll(): Promise<void> {
    const pending = pendingFiles.value
    if (pending.length === 0) return

    isUploading.value = true

    try {
      await Promise.all(pending.map((file) => uploadFile(file)))
    } finally {
      isUploading.value = false
      options.onComplete?.(files.value)
    }
  }

  // Retry failed uploads
  async function retryFailed(): Promise<void> {
    const failed = errorFiles.value
    failed.forEach((f) => {
      f.status = 'pending'
      f.error = undefined
      f.progress = 0
    })
    await uploadAll()
  }

  // Handle file input change
  function handleInputChange(event: Event): void {
    const input = event.target as HTMLInputElement
    if (input.files) {
      addFiles(input.files)
    }
    // Reset input so same file can be selected again
    input.value = ''
  }

  // Handle drag events
  function handleDragEnter(event: DragEvent): void {
    event.preventDefault()
    isDragging.value = true
  }

  function handleDragLeave(event: DragEvent): void {
    event.preventDefault()
    isDragging.value = false
  }

  function handleDragOver(event: DragEvent): void {
    event.preventDefault()
  }

  function handleDrop(event: DragEvent): void {
    event.preventDefault()
    isDragging.value = false

    if (event.dataTransfer?.files) {
      addFiles(event.dataTransfer.files)
    }
  }

  return {
    // State
    files,
    isUploading,
    isDragging,

    // Computed
    pendingFiles,
    uploadingFiles,
    completedFiles,
    successFiles,
    errorFiles,
    totalProgress,

    // Methods
    addFiles,
    removeFile,
    clearFiles,
    uploadFile,
    uploadAll,
    retryFailed,

    // Event handlers
    handleInputChange,
    handleDragEnter,
    handleDragLeave,
    handleDragOver,
    handleDrop,
  }
}
