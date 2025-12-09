import type { Meta, StoryObj } from '@storybook/vue3'
import Spinner from './Spinner.vue'

const meta = {
  title: 'Atoms/Spinner',
  component: Spinner,
  tags: ['autodocs'],
  argTypes: {
    size: {
      control: 'select',
      options: ['xs', 'sm', 'md', 'lg', 'xl', '2xl'],
      description: 'Spinner size',
    },
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'success', 'danger', 'warning', 'info', 'neutral', 'white'],
      description: 'Spinner color variant',
    },
    text: {
      control: 'text',
      description: 'Loading text to display',
    },
    overlay: {
      control: 'boolean',
      description: 'Show as overlay',
    },
    overlayType: {
      control: 'select',
      options: ['container', 'fullscreen'],
      description: 'Overlay type',
    },
  },
  args: {
    size: 'md',
    variant: 'primary',
    overlay: false,
    overlayType: 'container',
  },
} satisfies Meta<typeof Spinner>

export default meta
type Story = StoryObj<typeof meta>

// Default spinner
export const Default: Story = {
  args: {},
}

// With text
export const WithText: Story = {
  args: {
    text: 'Loading...',
  },
}

// All sizes
export const AllSizes: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="flex items-center gap-8">
        <div class="text-center">
          <Spinner size="xs" />
          <p class="text-xs text-gray-600 mt-2">xs</p>
        </div>
        <div class="text-center">
          <Spinner size="sm" />
          <p class="text-xs text-gray-600 mt-2">sm</p>
        </div>
        <div class="text-center">
          <Spinner size="md" />
          <p class="text-xs text-gray-600 mt-2">md</p>
        </div>
        <div class="text-center">
          <Spinner size="lg" />
          <p class="text-xs text-gray-600 mt-2">lg</p>
        </div>
        <div class="text-center">
          <Spinner size="xl" />
          <p class="text-xs text-gray-600 mt-2">xl</p>
        </div>
        <div class="text-center">
          <Spinner size="2xl" />
          <p class="text-xs text-gray-600 mt-2">2xl</p>
        </div>
      </div>
    `,
  }),
}

// All variants
export const AllVariants: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="flex flex-wrap gap-6">
        <div class="text-center">
          <Spinner variant="primary" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Primary</p>
        </div>
        <div class="text-center">
          <Spinner variant="secondary" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Secondary</p>
        </div>
        <div class="text-center">
          <Spinner variant="success" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Success</p>
        </div>
        <div class="text-center">
          <Spinner variant="danger" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Danger</p>
        </div>
        <div class="text-center">
          <Spinner variant="warning" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Warning</p>
        </div>
        <div class="text-center">
          <Spinner variant="info" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Info</p>
        </div>
        <div class="text-center">
          <Spinner variant="neutral" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Neutral</p>
        </div>
        <div class="text-center bg-gray-800 p-4 rounded">
          <Spinner variant="white" size="lg" />
          <p class="text-xs text-white mt-2">White</p>
        </div>
      </div>
    `,
  }),
}

// With different text sizes
export const WithTextSizes: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="flex flex-wrap gap-8">
        <Spinner size="xs" text="Loading..." />
        <Spinner size="sm" text="Loading..." />
        <Spinner size="md" text="Loading..." />
        <Spinner size="lg" text="Loading..." />
        <Spinner size="xl" text="Loading..." />
      </div>
    `,
  }),
}

// In buttons
export const InButtons: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="flex flex-wrap gap-3">
        <button class="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-md" disabled>
          <Spinner size="sm" variant="white" />
          <span>Loading...</span>
        </button>
        <button class="inline-flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-md" disabled>
          <Spinner size="sm" variant="white" />
          <span>Processing...</span>
        </button>
        <button class="inline-flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-md" disabled>
          <Spinner size="sm" variant="white" />
          <span>Deleting...</span>
        </button>
        <button class="inline-flex items-center justify-center p-2 bg-gray-200 text-gray-700 rounded-md" disabled>
          <Spinner size="sm" variant="neutral" />
        </button>
      </div>
    `,
  }),
}

// Container overlay
export const ContainerOverlay: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="relative border-2 border-gray-200 rounded-lg p-8 min-h-[300px]">
        <h3 class="text-lg font-semibold mb-4">Card Content</h3>
        <p class="text-gray-600">
          This is some content that is being loaded. The spinner overlay
          covers just this container.
        </p>
        <Spinner overlay overlay-type="container" size="lg" text="Loading data..." />
      </div>
    `,
  }),
}

// Fullscreen overlay
export const FullscreenOverlay: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div>
        <p class="text-gray-600 mb-4">
          Click the button below to simulate a fullscreen loading state.
        </p>
        <button
          class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
          @click="showSpinner = !showSpinner"
        >
          Toggle Fullscreen Spinner
        </button>
        <Spinner
          v-if="showSpinner"
          overlay
          overlay-type="fullscreen"
          size="xl"
          text="Loading application..."
        />
      </div>
    `,
    data() {
      return {
        showSpinner: false,
      }
    },
  }),
}

// In cards
export const InCards: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="border border-gray-200 rounded-lg p-6">
          <div class="flex items-center justify-center h-32">
            <Spinner size="lg" text="Loading user data..." />
          </div>
        </div>

        <div class="border border-gray-200 rounded-lg p-6">
          <div class="flex items-center justify-center h-32">
            <Spinner size="lg" variant="success" text="Syncing..." />
          </div>
        </div>

        <div class="border border-gray-200 rounded-lg p-6">
          <div class="flex items-center justify-center h-32">
            <Spinner size="lg" variant="info" text="Processing..." />
          </div>
        </div>
      </div>
    `,
  }),
}

// Loading states
export const LoadingStates: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="space-y-6">
        <div class="border border-gray-200 rounded-lg p-6">
          <h3 class="text-lg font-semibold mb-4">Loading List Items</h3>
          <div class="space-y-3">
            <div class="flex items-center gap-3">
              <Spinner size="sm" />
              <div class="flex-1 h-4 bg-gray-200 rounded animate-pulse"></div>
            </div>
            <div class="flex items-center gap-3">
              <Spinner size="sm" />
              <div class="flex-1 h-4 bg-gray-200 rounded animate-pulse"></div>
            </div>
            <div class="flex items-center gap-3">
              <Spinner size="sm" />
              <div class="flex-1 h-4 bg-gray-200 rounded animate-pulse"></div>
            </div>
          </div>
        </div>

        <div class="border border-gray-200 rounded-lg p-6">
          <h3 class="text-lg font-semibold mb-4">Upload Progress</h3>
          <div class="flex flex-col items-center gap-3">
            <Spinner size="xl" variant="success" />
            <p class="text-sm text-gray-600">Uploading file... 45%</p>
            <div class="w-full bg-gray-200 rounded-full h-2">
              <div class="bg-green-600 h-2 rounded-full" style="width: 45%"></div>
            </div>
          </div>
        </div>

        <div class="border border-gray-200 rounded-lg p-6">
          <h3 class="text-lg font-semibold mb-4">Form Submission</h3>
          <div class="space-y-4">
            <input
              type="text"
              placeholder="Name"
              disabled
              class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-50"
            />
            <input
              type="email"
              placeholder="Email"
              disabled
              class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-50"
            />
            <button
              class="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-md w-full justify-center"
              disabled
            >
              <Spinner size="sm" variant="white" />
              <span>Submitting...</span>
            </button>
          </div>
        </div>
      </div>
    `,
  }),
}

// Custom loading messages
export const CustomMessages: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="space-y-6">
        <Spinner size="lg" variant="primary" text="Fetching data from server..." />
        <Spinner size="lg" variant="success" text="Processing your request..." />
        <Spinner size="lg" variant="info" text="Analyzing results..." />
        <Spinner size="lg" variant="warning" text="Waiting for response..." />
        <Spinner size="lg" variant="danger" text="Retrying connection..." />
      </div>
    `,
  }),
}

// Table loading
export const TableLoading: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="border border-gray-200 rounded-lg overflow-hidden">
        <table class="w-full">
          <thead class="bg-gray-50 border-b border-gray-200">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
            </tr>
          </thead>
          <tbody class="bg-white">
            <tr>
              <td colspan="3" class="px-6 py-12">
                <div class="flex justify-center">
                  <Spinner size="lg" text="Loading table data..." />
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    `,
  }),
}

// Inline with text
export const InlineWithText: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="space-y-4">
        <div class="flex items-center gap-3">
          <Spinner size="sm" />
          <span class="text-gray-700">Loading user profile...</span>
        </div>
        <div class="flex items-center gap-3">
          <Spinner size="sm" variant="success" />
          <span class="text-gray-700">Syncing with server...</span>
        </div>
        <div class="flex items-center gap-3">
          <Spinner size="sm" variant="danger" />
          <span class="text-gray-700">Attempting to reconnect...</span>
        </div>
      </div>
    `,
  }),
}

// Page loading
export const PageLoading: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="min-h-[500px] flex items-center justify-center bg-gray-50">
        <Spinner size="2xl" variant="primary" text="Loading page content..." />
      </div>
    `,
  }),
}

// With custom slot
export const WithCustomSlot: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="space-y-6">
        <Spinner size="lg" variant="primary">
          <div class="text-center">
            <p class="font-semibold text-primary-600">Loading</p>
            <p class="text-sm text-gray-500">Please wait a moment...</p>
          </div>
        </Spinner>

        <Spinner size="lg" variant="success">
          <div class="text-center">
            <p class="font-semibold text-green-600">Processing</p>
            <p class="text-sm text-gray-500">Step 2 of 5</p>
          </div>
        </Spinner>
      </div>
    `,
  }),
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Spinner },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="flex items-center gap-8">
            <Spinner size="xs" />
            <Spinner size="sm" />
            <Spinner size="md" />
            <Spinner size="lg" />
            <Spinner size="xl" />
            <Spinner size="2xl" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Variants</h3>
          <div class="flex flex-wrap gap-6">
            <Spinner variant="primary" size="lg" />
            <Spinner variant="secondary" size="lg" />
            <Spinner variant="success" size="lg" />
            <Spinner variant="danger" size="lg" />
            <Spinner variant="warning" size="lg" />
            <Spinner variant="info" size="lg" />
            <Spinner variant="neutral" size="lg" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Text</h3>
          <div class="flex flex-wrap gap-6">
            <Spinner size="lg" text="Loading..." />
            <Spinner size="lg" variant="success" text="Processing..." />
            <Spinner size="lg" variant="danger" text="Retrying..." />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">In Buttons</h3>
          <div class="flex flex-wrap gap-3">
            <button class="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-md" disabled>
              <Spinner size="sm" variant="white" />
              <span>Loading...</span>
            </button>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Container Overlay</h3>
          <div class="relative border-2 border-gray-200 rounded-lg p-8 min-h-[200px]">
            <p class="text-gray-600">Content being loaded...</p>
            <Spinner overlay overlay-type="container" size="lg" text="Loading..." />
          </div>
        </div>
      </div>
    `,
  }),
}

// Interactive
export const Interactive: Story = {
  args: {
    size: 'lg',
    variant: 'primary',
    text: 'Loading...',
  },
}
