import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Skeleton from './Skeleton.vue'

const meta = {
  title: 'Molecules/Skeleton',
  component: Skeleton,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['rectangle', 'circle', 'text'],
    },
    animation: {
      control: 'select',
      options: ['pulse', 'wave', 'none'],
    },
    loading: {
      control: 'boolean',
    },
    lines: {
      control: 'number',
    },
  },
} satisfies Meta<typeof Skeleton>

export default meta
type Story = StoryObj<typeof meta>

export const Rectangle: Story = {
  args: {
    variant: 'rectangle',
    width: 200,
    height: 100,
  },
}

export const Circle: Story = {
  args: {
    variant: 'circle',
    width: 80,
  },
}

export const Text: Story = {
  args: {
    variant: 'text',
    lines: 3,
  },
}

export const PulseAnimation: Story = {
  args: {
    variant: 'rectangle',
    width: '100%',
    height: 100,
    animation: 'pulse',
  },
}

export const WaveAnimation: Story = {
  args: {
    variant: 'rectangle',
    width: '100%',
    height: 100,
    animation: 'wave',
  },
}

export const NoAnimation: Story = {
  args: {
    variant: 'rectangle',
    width: '100%',
    height: 100,
    animation: 'none',
  },
}

export const UserCard: Story = {
  render: () => ({
    components: { Skeleton },
    template: `
      <div class="border border-gray-200 rounded-lg p-4 max-w-sm">
        <div class="flex items-center gap-4">
          <Skeleton variant="circle" :width="60" />
          <div class="flex-1">
            <Skeleton variant="text" :lines="2" />
          </div>
        </div>
        <div class="mt-4">
          <Skeleton variant="rectangle" width="100%" :height="100" />
        </div>
      </div>
    `,
  }),
}

export const ArticleList: Story = {
  render: () => ({
    components: { Skeleton },
    template: `
      <div class="space-y-4 max-w-2xl">
        <div v-for="i in 3" :key="i" class="border border-gray-200 rounded-lg p-4">
          <div class="flex gap-4">
            <Skeleton variant="rectangle" :width="120" :height="80" />
            <div class="flex-1">
              <Skeleton variant="text" :lines="1" class="mb-2" />
              <Skeleton variant="text" :lines="2" />
            </div>
          </div>
        </div>
      </div>
    `,
  }),
}

export const CommentSkeleton: Story = {
  render: () => ({
    components: { Skeleton },
    template: `
      <div class="space-y-4 max-w-2xl">
        <div v-for="i in 4" :key="i" class="flex gap-3">
          <Skeleton variant="circle" :width="40" />
          <div class="flex-1">
            <Skeleton variant="text" :lines="1" width="30%" class="mb-1" />
            <Skeleton variant="text" :lines="2" />
          </div>
        </div>
      </div>
    `,
  }),
}

export const InteractiveLoading: Story = {
  render: () => ({
    components: { Skeleton },
    setup() {
      const loading = ref(true)

      const toggleLoading = () => {
        loading.value = !loading.value
      }

      return { loading, toggleLoading }
    },
    template: `
      <div class="space-y-4">
        <button
          @click="toggleLoading"
          class="px-4 py-2 bg-primary text-white rounded hover:bg-primary/90"
        >
          {{ loading ? 'Show Content' : 'Show Skeleton' }}
        </button>

        <div class="border border-gray-200 rounded-lg p-6 max-w-md">
          <Skeleton :loading="loading" variant="circle" :width="80" class="mb-4">
            <img
              src="https://via.placeholder.com/80"
              alt="Avatar"
              class="w-20 h-20 rounded-full"
            />
          </Skeleton>

          <Skeleton :loading="loading" variant="text" :lines="3">
            <div>
              <h2 class="text-xl font-bold mb-2">John Doe</h2>
              <p class="text-gray-600">
                Full-stack developer with 10 years of experience building web applications.
                Passionate about creating elegant solutions to complex problems.
              </p>
            </div>
          </Skeleton>
        </div>
      </div>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { Skeleton },
    template: `
      <div class="space-y-8 max-w-2xl">
        <div>
          <h3 class="text-lg font-semibold mb-3">Rectangle</h3>
          <Skeleton variant="rectangle" width="100%" :height="100" />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Circle</h3>
          <div class="flex gap-4">
            <Skeleton variant="circle" :width="40" />
            <Skeleton variant="circle" :width="60" />
            <Skeleton variant="circle" :width="80" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Text Lines</h3>
          <Skeleton variant="text" :lines="4" />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Combined</h3>
          <div class="flex items-start gap-4">
            <Skeleton variant="circle" :width="50" />
            <div class="flex-1">
              <Skeleton variant="text" :lines="1" width="40%" class="mb-2" />
              <Skeleton variant="text" :lines="2" />
              <Skeleton variant="rectangle" width="100%" :height="60" class="mt-3" />
            </div>
          </div>
        </div>
      </div>
    `,
  }),
}
