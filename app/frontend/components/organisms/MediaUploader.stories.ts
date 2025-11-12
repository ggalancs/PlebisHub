import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import MediaUploader from './MediaUploader.vue'
import type { UploadFile } from './MediaUploader.vue'

const meta = {
  title: 'Organisms/MediaUploader',
  component: MediaUploader,
  tags: ['autodocs'],
  argTypes: {
    accept: {
      control: 'text',
    },
    maxSize: {
      control: 'number',
    },
    maxFiles: {
      control: 'number',
    },
    multiple: {
      control: 'boolean',
    },
    showPreview: {
      control: 'boolean',
    },
    disabled: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof MediaUploader>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {},
}

export const ImagesOnly: Story = {
  args: {
    accept: 'image/*',
  },
}

export const PDFOnly: Story = {
  args: {
    accept: '.pdf',
  },
}

export const DocumentsOnly: Story = {
  args: {
    accept: '.pdf,.doc,.docx,.txt',
  },
}

export const SingleFile: Story = {
  args: {
    multiple: false,
    maxFiles: 1,
  },
}

export const LimitedFiles: Story = {
  args: {
    maxFiles: 3,
  },
}

export const SmallMaxSize: Story = {
  args: {
    maxSize: 1 * 1024 * 1024, // 1MB
  },
}

export const LargeMaxSize: Story = {
  args: {
    maxSize: 50 * 1024 * 1024, // 50MB
  },
}

export const NoPreview: Story = {
  args: {
    showPreview: false,
  },
}

export const Disabled: Story = {
  args: {
    disabled: true,
  },
}

export const WithFiles: Story = {
  args: {
    modelValue: [
      {
        id: '1',
        file: new File(['content'], 'document.pdf', { type: 'application/pdf' }),
        progress: 100,
        status: 'success',
      },
      {
        id: '2',
        file: new File(['content'], 'image.jpg', { type: 'image/jpeg' }),
        preview: 'https://via.placeholder.com/300',
        progress: 100,
        status: 'success',
      },
    ],
  },
}

export const WithUploading: Story = {
  args: {
    modelValue: [
      {
        id: '1',
        file: new File(['content'], 'uploading.jpg', { type: 'image/jpeg' }),
        preview: 'https://via.placeholder.com/300',
        progress: 45,
        status: 'uploading',
      },
      {
        id: '2',
        file: new File(['content'], 'complete.jpg', { type: 'image/jpeg' }),
        preview: 'https://via.placeholder.com/300',
        progress: 100,
        status: 'success',
      },
    ],
  },
}

export const WithErrors: Story = {
  args: {
    modelValue: [
      {
        id: '1',
        file: new File(['content'], 'failed.jpg', { type: 'image/jpeg' }),
        preview: 'https://via.placeholder.com/300',
        progress: 0,
        status: 'error',
        error: 'Upload failed',
      },
      {
        id: '2',
        file: new File(['content'], 'success.jpg', { type: 'image/jpeg' }),
        preview: 'https://via.placeholder.com/300',
        progress: 100,
        status: 'success',
      },
    ],
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { MediaUploader },
    setup() {
      const files = ref<UploadFile[]>([])

      const handleUpload = (uploadedFiles: File[]) => {
        console.log('Files to upload:', uploadedFiles)

        // Simulate upload for each file
        uploadedFiles.forEach((file) => {
          const uploadFile = files.value.find((f) => f.file === file)
          if (uploadFile) {
            // Simulate progress
            let progress = 0
            const interval = setInterval(() => {
              progress += 10
              if (progress <= 100) {
                uploadFile.progress = progress
                uploadFile.status = progress < 100 ? 'uploading' : 'success'
              } else {
                clearInterval(interval)
              }
            }, 200)
          }
        })
      }

      const handleRemove = (fileId: string) => {
        console.log('Remove file:', fileId)
      }

      const handleError = (error: string) => {
        console.error('Upload error:', error)
        alert(error)
      }

      return {
        files,
        handleUpload,
        handleRemove,
        handleError,
      }
    },
    template: `
      <div class="p-6 max-w-4xl">
        <h2 class="text-2xl font-bold mb-4">Upload de Archivos Interactivo</h2>
        <p class="text-sm text-gray-600 mb-6">
          Arrastra archivos o haz clic para seleccionarlos. El progreso se simulará automáticamente.
        </p>
        <MediaUploader
          v-model="files"
          :max-size="5 * 1024 * 1024"
          :max-files="5"
          @upload="handleUpload"
          @remove="handleRemove"
          @error="handleError"
        />
        <div class="mt-6 p-4 bg-gray-50 rounded">
          <h3 class="font-semibold mb-2">Archivos ({{ files.length }}):</h3>
          <pre class="text-xs">{{ JSON.stringify(files.map(f => ({ name: f.file.name, status: f.status, progress: f.progress })), null, 2) }}</pre>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const ImageGallery: Story = {
  render: (args) => ({
    components: { MediaUploader },
    setup() {
      const images = ref<UploadFile[]>([
        {
          id: '1',
          file: new File([''], 'sunset.jpg', { type: 'image/jpeg' }),
          preview: 'https://via.placeholder.com/300/FF6B6B/FFFFFF?text=Sunset',
          progress: 100,
          status: 'success',
        },
        {
          id: '2',
          file: new File([''], 'mountains.jpg', { type: 'image/jpeg' }),
          preview: 'https://via.placeholder.com/300/4ECDC4/FFFFFF?text=Mountains',
          progress: 100,
          status: 'success',
        },
        {
          id: '3',
          file: new File([''], 'ocean.jpg', { type: 'image/jpeg' }),
          preview: 'https://via.placeholder.com/300/45B7D1/FFFFFF?text=Ocean',
          progress: 100,
          status: 'success',
        },
        {
          id: '4',
          file: new File([''], 'forest.jpg', { type: 'image/jpeg' }),
          preview: 'https://via.placeholder.com/300/96CEB4/FFFFFF?text=Forest',
          progress: 100,
          status: 'success',
        },
      ])

      return { images }
    },
    template: `
      <div class="p-6 max-w-5xl">
        <h2 class="text-2xl font-bold mb-4">Galería de Imágenes</h2>
        <MediaUploader
          v-model="images"
          accept="image/*"
          :max-files="20"
        />
      </div>
    `,
  }),
  args: {},
}

export const DocumentUpload: Story = {
  render: (args) => ({
    components: { MediaUploader },
    setup() {
      const documents = ref<UploadFile[]>([])

      return { documents }
    },
    template: `
      <div class="p-6 max-w-4xl">
        <h2 class="text-2xl font-bold mb-4">Upload de Documentos</h2>
        <MediaUploader
          v-model="documents"
          accept=".pdf,.doc,.docx,.txt,.xlsx,.xls"
          :show-preview="false"
          :max-size="10 * 1024 * 1024"
        />
      </div>
    `,
  }),
  args: {},
}

export const AvatarUpload: Story = {
  render: (args) => ({
    components: { MediaUploader },
    setup() {
      const avatar = ref<UploadFile[]>([])

      return { avatar }
    },
    template: `
      <div class="p-6 max-w-md">
        <h2 class="text-2xl font-bold mb-4">Subir Avatar</h2>
        <p class="text-sm text-gray-600 mb-4">
          Selecciona una imagen para tu perfil (máximo 2MB)
        </p>
        <MediaUploader
          v-model="avatar"
          accept="image/*"
          :multiple="false"
          :max-files="1"
          :max-size="2 * 1024 * 1024"
        />
      </div>
    `,
  }),
  args: {},
}

export const MixedFiles: Story = {
  args: {
    modelValue: [
      {
        id: '1',
        file: new File([''], 'photo.jpg', { type: 'image/jpeg' }),
        preview: 'https://via.placeholder.com/300',
        progress: 100,
        status: 'success',
      },
      {
        id: '2',
        file: new File([''], 'document.pdf', { type: 'application/pdf' }),
        progress: 100,
        status: 'success',
      },
      {
        id: '3',
        file: new File([''], 'spreadsheet.xlsx', { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' }),
        progress: 75,
        status: 'uploading',
      },
      {
        id: '4',
        file: new File([''], 'video.mp4', { type: 'video/mp4' }),
        progress: 0,
        status: 'error',
        error: 'File too large',
      },
    ],
  },
}
