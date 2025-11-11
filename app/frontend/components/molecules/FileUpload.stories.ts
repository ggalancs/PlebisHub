import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import FileUpload from './FileUpload.vue'
import type { FileItem } from './FileUpload.vue'

const meta = {
  title: 'Molecules/FileUpload',
  component: FileUpload,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['default', 'compact', 'minimal'],
    },
    multiple: {
      control: 'boolean',
    },
    disabled: {
      control: 'boolean',
    },
    showPreview: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof FileUpload>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {},
}

export const WithAcceptTypes: Story = {
  args: {
    accept: 'image/*',
    maxSize: 5 * 1024 * 1024, // 5MB
  },
}

export const Multiple: Story = {
  args: {
    multiple: true,
    maxFiles: 5,
  },
}

export const Compact: Story = {
  args: {
    variant: 'compact',
    accept: '.pdf,.doc,.docx',
  },
}

export const Minimal: Story = {
  args: {
    variant: 'minimal',
    multiple: true,
  },
}

export const Disabled: Story = {
  args: {
    disabled: true,
  },
}

export const WithMaxSize: Story = {
  args: {
    maxSize: 1024 * 1024, // 1MB
    accept: 'image/*',
  },
}

export const WithoutPreview: Story = {
  args: {
    showPreview: false,
    multiple: true,
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { FileUpload },
    setup() {
      const files = ref<FileItem[]>([])
      const lastError = ref<string>('')

      const handleChange = (newFiles: FileItem[]) => {
        files.value = newFiles
      }

      const handleError = (error: string) => {
        lastError.value = error
        setTimeout(() => {
          lastError.value = ''
        }, 3000)
      }

      return { files, lastError, handleChange, handleError }
    },
    template: `
      <div class="space-y-4">
        <FileUpload
          v-model="files"
          multiple
          :max-size="2 * 1024 * 1024"
          :max-files="3"
          accept="image/*,.pdf"
          @change="handleChange"
          @error="handleError"
        />

        <div v-if="lastError" class="p-3 bg-red-50 border border-red-200 rounded-md text-red-700 text-sm">
          {{ lastError }}
        </div>

        <div v-if="files.length > 0" class="p-3 bg-gray-50 rounded-md">
          <p class="text-sm font-medium text-gray-700 mb-2">Selected Files ({{ files.length }}):</p>
          <ul class="text-sm text-gray-600 space-y-1">
            <li v-for="file in files" :key="file.id">
              {{ file.file.name }} ({{ Math.round(file.file.size / 1024) }} KB)
            </li>
          </ul>
        </div>
      </div>
    `,
  }),
}

export const CustomLabels: Story = {
  render: () => ({
    components: { FileUpload },
    template: `
      <FileUpload accept="image/*">
        <template #label>
          <span class="text-primary font-semibold">Upload your profile photo</span>
        </template>
        <template #hint>
          <span>PNG, JPG up to 2MB</span>
        </template>
      </FileUpload>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { FileUpload },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-3">Default</h3>
          <FileUpload />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Compact</h3>
          <FileUpload variant="compact" />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Minimal</h3>
          <FileUpload variant="minimal" />
        </div>
      </div>
    `,
  }),
}
