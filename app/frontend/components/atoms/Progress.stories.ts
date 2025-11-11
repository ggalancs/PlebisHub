import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref, onMounted, onUnmounted } from 'vue'
import Progress from './Progress.vue'

const meta = {
  title: 'Atoms/Progress',
  component: Progress,
  tags: ['autodocs'],
  argTypes: {
    value: {
      control: { type: 'number', min: 0, max: 100, step: 1 },
      description: 'Progress value (0-100)',
    },
    max: {
      control: { type: 'number', min: 1, max: 200, step: 1 },
      description: 'Maximum value',
    },
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'success', 'danger', 'warning', 'info'],
      description: 'Color variant',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Progress bar size',
    },
    showLabel: {
      control: 'boolean',
      description: 'Show progress label',
    },
    label: {
      control: 'text',
      description: 'Custom label text',
    },
    striped: {
      control: 'boolean',
      description: 'Striped background',
    },
    animated: {
      control: 'boolean',
      description: 'Animated stripes',
    },
    indeterminate: {
      control: 'boolean',
      description: 'Indeterminate state',
    },
  },
  args: {
    value: 0,
    max: 100,
    variant: 'primary',
    size: 'md',
    showLabel: false,
    striped: false,
    animated: false,
    indeterminate: false,
  },
} satisfies Meta<typeof Progress>

export default meta
type Story = StoryObj<typeof meta>

// Default progress
export const Default: Story = {
  args: {
    value: 50,
  },
}

// With label
export const WithLabel: Story = {
  args: {
    value: 65,
    showLabel: true,
  },
}

// All sizes
export const AllSizes: Story = {
  render: () => ({
    components: { Progress },
    template: `
      <div class="space-y-6">
        <div>
          <p class="text-sm text-gray-600 mb-2">Small</p>
          <Progress :value="75" size="sm" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Medium</p>
          <Progress :value="75" size="md" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Large</p>
          <Progress :value="75" size="lg" />
        </div>
      </div>
    `,
  }),
}

// All variants
export const AllVariants: Story = {
  render: () => ({
    components: { Progress },
    template: `
      <div class="space-y-6">
        <div>
          <p class="text-sm text-gray-600 mb-2">Primary</p>
          <Progress :value="80" variant="primary" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Secondary</p>
          <Progress :value="60" variant="secondary" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Success</p>
          <Progress :value="90" variant="success" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Danger</p>
          <Progress :value="30" variant="danger" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Warning</p>
          <Progress :value="50" variant="warning" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Info</p>
          <Progress :value="70" variant="info" />
        </div>
      </div>
    `,
  }),
}

// Striped
export const Striped: Story = {
  args: {
    value: 75,
    striped: true,
  },
}

// Animated stripes
export const AnimatedStripes: Story = {
  args: {
    value: 60,
    animated: true,
  },
}

// Indeterminate
export const Indeterminate: Story = {
  args: {
    indeterminate: true,
    showLabel: true,
  },
}

// Animated progress
export const AnimatedProgress: Story = {
  render: () => ({
    components: { Progress },
    setup() {
      const progress = ref(0)
      let interval: ReturnType<typeof setInterval>

      onMounted(() => {
        interval = setInterval(() => {
          progress.value += 1
          if (progress.value > 100) {
            progress.value = 0
          }
        }, 50)
      })

      onUnmounted(() => {
        clearInterval(interval)
      })

      return { progress }
    },
    template: `
      <Progress :value="progress" show-label />
    `,
  }),
}

// File upload simulation
export const FileUpload: Story = {
  render: () => ({
    components: { Progress },
    setup() {
      const progress = ref(0)
      const uploading = ref(false)

      const startUpload = () => {
        uploading.value = true
        progress.value = 0

        const interval = setInterval(() => {
          progress.value += Math.random() * 10
          if (progress.value >= 100) {
            progress.value = 100
            uploading.value = false
            clearInterval(interval)
          }
        }, 300)
      }

      return { progress, uploading, startUpload }
    },
    template: `
      <div class="space-y-4">
        <button
          @click="startUpload"
          :disabled="uploading"
          class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ uploading ? 'Uploading...' : 'Upload File' }}
        </button>
        <div>
          <Progress
            :value="progress"
            variant="success"
            size="lg"
            show-label
            label="Uploading document.pdf..."
          />
        </div>
      </div>
    `,
  }),
}

// Download progress
export const DownloadProgress: Story = {
  render: () => ({
    components: { Progress },
    setup() {
      const downloads = ref([
        { id: 1, name: 'Report.pdf', progress: 100, variant: 'success' as const },
        { id: 2, name: 'Presentation.pptx', progress: 65, variant: 'primary' as const },
        { id: 3, name: 'Video.mp4', progress: 23, variant: 'info' as const },
        { id: 4, name: 'Archive.zip', progress: 0, variant: 'neutral' as const },
      ])

      return { downloads }
    },
    template: `
      <div class="space-y-4">
        <div
          v-for="download in downloads"
          :key="download.id"
          class="border border-gray-200 rounded-lg p-4"
        >
          <p class="text-sm font-medium text-gray-900 mb-2">{{ download.name }}</p>
          <Progress
            :value="download.progress"
            :variant="download.variant"
            show-label
          />
        </div>
      </div>
    `,
  }),
}

// Installation steps
export const InstallationSteps: Story = {
  render: () => ({
    components: { Progress },
    template: `
      <div class="max-w-md">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Installation Progress</h3>
        <div class="space-y-4">
          <div>
            <Progress :value="100" variant="success" show-label label="Downloading files..." />
          </div>
          <div>
            <Progress :value="100" variant="success" show-label label="Extracting archive..." />
          </div>
          <div>
            <Progress :value="75" variant="primary" show-label label="Installing dependencies..." animated />
          </div>
          <div>
            <Progress :value="0" variant="neutral" show-label label="Configuring settings..." />
          </div>
        </div>
      </div>
    `,
  }),
}

// Storage usage
export const StorageUsage: Story = {
  render: () => ({
    components: { Progress },
    template: `
      <div class="max-w-md border border-gray-200 rounded-lg p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Storage Usage</h3>
        <div class="space-y-6">
          <div>
            <div class="flex justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Documents</span>
              <span class="text-sm text-gray-500">2.3 GB / 5 GB</span>
            </div>
            <Progress :value="46" variant="info" size="lg" />
          </div>
          <div>
            <div class="flex justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Photos</span>
              <span class="text-sm text-gray-500">12.8 GB / 15 GB</span>
            </div>
            <Progress :value="85" variant="warning" size="lg" />
          </div>
          <div>
            <div class="flex justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Videos</span>
              <span class="text-sm text-gray-500">28.5 GB / 30 GB</span>
            </div>
            <Progress :value="95" variant="danger" size="lg" />
          </div>
          <div>
            <div class="flex justify-between mb-2">
              <span class="text-sm font-medium text-gray-700">Other</span>
              <span class="text-sm text-gray-500">1.2 GB / 10 GB</span>
            </div>
            <Progress :value="12" variant="success" size="lg" />
          </div>
        </div>
      </div>
    `,
  }),
}

// Skill levels
export const SkillLevels: Story = {
  render: () => ({
    components: { Progress },
    template: `
      <div class="max-w-md">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Skills</h3>
        <div class="space-y-4">
          <div>
            <div class="flex justify-between mb-1">
              <span class="text-sm font-medium text-gray-700">JavaScript</span>
              <span class="text-sm text-gray-500">Expert</span>
            </div>
            <Progress :value="95" variant="success" />
          </div>
          <div>
            <div class="flex justify-between mb-1">
              <span class="text-sm font-medium text-gray-700">TypeScript</span>
              <span class="text-sm text-gray-500">Advanced</span>
            </div>
            <Progress :value="85" variant="info" />
          </div>
          <div>
            <div class="flex justify-between mb-1">
              <span class="text-sm font-medium text-gray-700">Vue.js</span>
              <span class="text-sm text-gray-500">Intermediate</span>
            </div>
            <Progress :value="70" variant="primary" />
          </div>
          <div>
            <div class="flex justify-between mb-1">
              <span class="text-sm font-medium text-gray-700">Python</span>
              <span class="text-sm text-gray-500">Beginner</span>
            </div>
            <Progress :value="40" variant="warning" />
          </div>
        </div>
      </div>
    `,
  }),
}

// Loading states
export const LoadingStates: Story = {
  render: () => ({
    components: { Progress },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-sm font-semibold text-gray-700 mb-3">Determinate (known progress)</h3>
          <Progress :value="60" variant="primary" show-label animated />
        </div>
        <div>
          <h3 class="text-sm font-semibold text-gray-700 mb-3">Indeterminate (unknown progress)</h3>
          <Progress indeterminate variant="info" show-label />
        </div>
      </div>
    `,
  }),
}

// With custom labels
export const CustomLabels: Story = {
  render: () => ({
    components: { Progress },
    template: `
      <div class="space-y-6">
        <Progress :value="25" variant="warning" show-label label="Initializing..." />
        <Progress :value="50" variant="info" show-label label="Processing data..." />
        <Progress :value="75" variant="primary" show-label label="Almost done..." />
        <Progress :value="100" variant="success" show-label label="Complete!" />
      </div>
    `,
  }),
}

// Task completion
export const TaskCompletion: Story = {
  render: () => ({
    components: { Progress },
    setup() {
      const tasks = ref([
        { id: 1, name: 'Research', completed: true },
        { id: 2, name: 'Design', completed: true },
        { id: 3, name: 'Development', completed: true },
        { id: 4, name: 'Testing', completed: false },
        { id: 5, name: 'Deployment', completed: false },
      ])

      const completedCount = ref(tasks.value.filter((t) => t.completed).length)
      const totalCount = ref(tasks.value.length)
      const percentage = ref((completedCount.value / totalCount.value) * 100)

      return { tasks, completedCount, totalCount, percentage }
    },
    template: `
      <div class="max-w-md">
        <div class="mb-4">
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Project Tasks</h3>
          <Progress
            :value="percentage"
            variant="success"
            size="lg"
            show-label
            :label="completedCount + ' of ' + totalCount + ' tasks completed'"
          />
        </div>
        <ul class="space-y-2">
          <li
            v-for="task in tasks"
            :key="task.id"
            class="flex items-center gap-2"
          >
            <input
              type="checkbox"
              :checked="task.completed"
              class="h-4 w-4 rounded border-gray-300"
              disabled
            />
            <span :class="task.completed ? 'line-through text-gray-500' : 'text-gray-900'">
              {{ task.name }}
            </span>
          </li>
        </ul>
      </div>
    `,
  }),
}

// Interactive
export const Interactive: Story = {
  args: {
    value: 50,
    variant: 'primary',
    size: 'md',
    showLabel: true,
    striped: false,
    animated: false,
    indeterminate: false,
  },
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Progress },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="space-y-3">
            <Progress :value="75" size="sm" />
            <Progress :value="75" size="md" />
            <Progress :value="75" size="lg" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Variants</h3>
          <div class="space-y-3">
            <Progress :value="80" variant="primary" />
            <Progress :value="60" variant="secondary" />
            <Progress :value="90" variant="success" />
            <Progress :value="30" variant="danger" />
            <Progress :value="50" variant="warning" />
            <Progress :value="70" variant="info" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Labels</h3>
          <div class="space-y-3">
            <Progress :value="65" show-label />
            <Progress :value="45" show-label label="Custom label" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Striped & Animated</h3>
          <div class="space-y-3">
            <Progress :value="70" striped />
            <Progress :value="60" animated />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Indeterminate</h3>
          <Progress indeterminate show-label />
        </div>
      </div>
    `,
  }),
}
