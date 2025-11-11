import type { Meta, StoryObj } from '@storybook/vue3-vite'
import Tooltip from './Tooltip.vue'

const meta = {
  title: 'Atoms/Tooltip',
  component: Tooltip,
  tags: ['autodocs'],
  argTypes: {
    content: {
      control: 'text',
      description: 'Tooltip content',
    },
    position: {
      control: 'select',
      options: ['top', 'bottom', 'left', 'right'],
      description: 'Tooltip position',
    },
    variant: {
      control: 'select',
      options: ['dark', 'light', 'primary', 'danger', 'success', 'warning'],
      description: 'Tooltip color variant',
    },
    arrow: {
      control: 'boolean',
      description: 'Show arrow',
    },
    delay: {
      control: { type: 'number', min: 0, max: 1000, step: 100 },
      description: 'Delay before showing (ms)',
    },
  },
  args: {
    content: 'Tooltip text',
    position: 'top',
    variant: 'dark',
    arrow: true,
    delay: 200,
  },
} satisfies Meta<typeof Tooltip>

export default meta
type Story = StoryObj<typeof meta>

// Default tooltip
export const Default: Story = {
  render: (args) => ({
    components: { Tooltip },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-12">
        <Tooltip v-bind="args">
          <button class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700">
            Hover me
          </button>
        </Tooltip>
      </div>
    `,
  }),
}

// All positions
export const AllPositions: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="grid grid-cols-2 gap-8 p-12">
        <div class="flex items-center justify-center">
          <Tooltip content="Top tooltip" position="top">
            <button class="px-4 py-2 bg-gray-600 text-white rounded-md">Top</button>
          </Tooltip>
        </div>
        <div class="flex items-center justify-center">
          <Tooltip content="Bottom tooltip" position="bottom">
            <button class="px-4 py-2 bg-gray-600 text-white rounded-md">Bottom</button>
          </Tooltip>
        </div>
        <div class="flex items-center justify-center">
          <Tooltip content="Left tooltip" position="left">
            <button class="px-4 py-2 bg-gray-600 text-white rounded-md">Left</button>
          </Tooltip>
        </div>
        <div class="flex items-center justify-center">
          <Tooltip content="Right tooltip" position="right">
            <button class="px-4 py-2 bg-gray-600 text-white rounded-md">Right</button>
          </Tooltip>
        </div>
      </div>
    `,
  }),
}

// All variants
export const AllVariants: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="flex flex-wrap gap-4 p-12">
        <Tooltip content="Dark tooltip (default)" variant="dark">
          <button class="px-4 py-2 bg-gray-800 text-white rounded-md">Dark</button>
        </Tooltip>
        <Tooltip content="Light tooltip" variant="light">
          <button class="px-4 py-2 bg-gray-200 text-gray-900 rounded-md">Light</button>
        </Tooltip>
        <Tooltip content="Primary tooltip" variant="primary">
          <button class="px-4 py-2 bg-primary-600 text-white rounded-md">Primary</button>
        </Tooltip>
        <Tooltip content="Danger tooltip" variant="danger">
          <button class="px-4 py-2 bg-red-600 text-white rounded-md">Danger</button>
        </Tooltip>
        <Tooltip content="Success tooltip" variant="success">
          <button class="px-4 py-2 bg-green-600 text-white rounded-md">Success</button>
        </Tooltip>
        <Tooltip content="Warning tooltip" variant="warning">
          <button class="px-4 py-2 bg-yellow-500 text-white rounded-md">Warning</button>
        </Tooltip>
      </div>
    `,
  }),
}

// Without arrow
export const WithoutArrow: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="flex items-center justify-center p-12">
        <Tooltip content="Tooltip without arrow" :arrow="false">
          <button class="px-4 py-2 bg-primary-600 text-white rounded-md">
            No arrow
          </button>
        </Tooltip>
      </div>
    `,
  }),
}

// Custom delay
export const CustomDelay: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="flex gap-4 p-12">
        <Tooltip content="Instant (0ms)" :delay="0">
          <button class="px-4 py-2 bg-gray-600 text-white rounded-md">Instant</button>
        </Tooltip>
        <Tooltip content="Fast (100ms)" :delay="100">
          <button class="px-4 py-2 bg-gray-600 text-white rounded-md">Fast</button>
        </Tooltip>
        <Tooltip content="Normal (200ms)" :delay="200">
          <button class="px-4 py-2 bg-gray-600 text-white rounded-md">Normal</button>
        </Tooltip>
        <Tooltip content="Slow (500ms)" :delay="500">
          <button class="px-4 py-2 bg-gray-600 text-white rounded-md">Slow</button>
        </Tooltip>
      </div>
    `,
  }),
}

// With icons
export const WithIcons: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="flex gap-4 p-12">
        <Tooltip content="Edit" position="top">
          <button class="p-2 bg-gray-200 rounded-md hover:bg-gray-300">
            <svg class="h-5 w-5 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
            </svg>
          </button>
        </Tooltip>
        <Tooltip content="Delete" position="top" variant="danger">
          <button class="p-2 bg-gray-200 rounded-md hover:bg-gray-300">
            <svg class="h-5 w-5 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
          </button>
        </Tooltip>
        <Tooltip content="Download" position="top" variant="success">
          <button class="p-2 bg-gray-200 rounded-md hover:bg-gray-300">
            <svg class="h-5 w-5 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
          </button>
        </Tooltip>
        <Tooltip content="Settings" position="top" variant="primary">
          <button class="p-2 bg-gray-200 rounded-md hover:bg-gray-300">
            <svg class="h-5 w-5 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
          </button>
        </Tooltip>
      </div>
    `,
  }),
}

// Help text
export const HelpText: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="max-w-md p-12">
        <div class="space-y-4">
          <div class="flex items-center gap-2">
            <label class="text-sm font-medium text-gray-700">Username</label>
            <Tooltip content="Your unique username for login" variant="light">
              <button class="text-gray-400 hover:text-gray-600">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </button>
            </Tooltip>
          </div>
          <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md" />

          <div class="flex items-center gap-2">
            <label class="text-sm font-medium text-gray-700">Email</label>
            <Tooltip content="We'll never share your email" variant="light">
              <button class="text-gray-400 hover:text-gray-600">
                <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </button>
            </Tooltip>
          </div>
          <input type="email" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
        </div>
      </div>
    `,
  }),
}

// Status badges
export const StatusBadges: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="flex flex-wrap gap-4 p-12">
        <Tooltip content="All systems operational" variant="success" position="top">
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800 cursor-default">
            <span class="h-1.5 w-1.5 rounded-full bg-green-600"></span>
            Active
          </span>
        </Tooltip>

        <Tooltip content="System under maintenance" variant="warning" position="top">
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 cursor-default">
            <span class="h-1.5 w-1.5 rounded-full bg-yellow-600"></span>
            Maintenance
          </span>
        </Tooltip>

        <Tooltip content="System is offline" variant="danger" position="top">
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800 cursor-default">
            <span class="h-1.5 w-1.5 rounded-full bg-red-600"></span>
            Offline
          </span>
        </Tooltip>

        <Tooltip content="Checking system status..." variant="primary" position="top">
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 cursor-default">
            <span class="h-1.5 w-1.5 rounded-full bg-blue-600 animate-pulse"></span>
            Checking
          </span>
        </Tooltip>
      </div>
    `,
  }),
}

// Data table
export const DataTable: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="p-12">
        <table class="w-full border-collapse border border-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-4 py-2 text-left text-sm font-medium text-gray-700 border border-gray-200">Name</th>
              <th class="px-4 py-2 text-left text-sm font-medium text-gray-700 border border-gray-200">Status</th>
              <th class="px-4 py-2 text-left text-sm font-medium text-gray-700 border border-gray-200">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td class="px-4 py-2 text-sm text-gray-900 border border-gray-200">John Doe</td>
              <td class="px-4 py-2 text-sm border border-gray-200">
                <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
                  Active
                </span>
              </td>
              <td class="px-4 py-2 border border-gray-200">
                <div class="flex gap-2">
                  <Tooltip content="Edit user" position="top">
                    <button class="text-blue-600 hover:text-blue-800">
                      <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                      </svg>
                    </button>
                  </Tooltip>
                  <Tooltip content="Delete user" position="top" variant="danger">
                    <button class="text-red-600 hover:text-red-800">
                      <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                      </svg>
                    </button>
                  </Tooltip>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    `,
  }),
}

// Rich content
export const RichContent: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="flex items-center justify-center p-12">
        <Tooltip variant="light">
          <template #tooltip>
            <div class="p-2">
              <p class="font-semibold text-sm">John Doe</p>
              <p class="text-xs text-gray-600">Software Engineer</p>
              <p class="text-xs text-gray-500 mt-1">San Francisco, CA</p>
            </div>
          </template>
          <button class="px-4 py-2 bg-primary-600 text-white rounded-md">
            User Info
          </button>
        </Tooltip>
      </div>
    `,
  }),
}

// Interactive
export const Interactive: Story = {
  args: {
    content: 'This is a tooltip',
    position: 'top',
    variant: 'dark',
    arrow: true,
    delay: 200,
  },
  render: (args) => ({
    components: { Tooltip },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-12">
        <Tooltip v-bind="args">
          <button class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700">
            Hover me
          </button>
        </Tooltip>
      </div>
    `,
  }),
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="space-y-12 p-12">
        <div>
          <h3 class="text-lg font-semibold mb-4">Positions</h3>
          <div class="grid grid-cols-4 gap-4">
            <Tooltip content="Top" position="top">
              <button class="px-4 py-2 bg-gray-600 text-white rounded-md w-full">Top</button>
            </Tooltip>
            <Tooltip content="Bottom" position="bottom">
              <button class="px-4 py-2 bg-gray-600 text-white rounded-md w-full">Bottom</button>
            </Tooltip>
            <Tooltip content="Left" position="left">
              <button class="px-4 py-2 bg-gray-600 text-white rounded-md w-full">Left</button>
            </Tooltip>
            <Tooltip content="Right" position="right">
              <button class="px-4 py-2 bg-gray-600 text-white rounded-md w-full">Right</button>
            </Tooltip>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Variants</h3>
          <div class="flex flex-wrap gap-3">
            <Tooltip content="Dark (default)" variant="dark">
              <button class="px-4 py-2 bg-gray-800 text-white rounded-md">Dark</button>
            </Tooltip>
            <Tooltip content="Light" variant="light">
              <button class="px-4 py-2 bg-gray-200 text-gray-900 rounded-md">Light</button>
            </Tooltip>
            <Tooltip content="Primary" variant="primary">
              <button class="px-4 py-2 bg-primary-600 text-white rounded-md">Primary</button>
            </Tooltip>
            <Tooltip content="Success" variant="success">
              <button class="px-4 py-2 bg-green-600 text-white rounded-md">Success</button>
            </Tooltip>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Icon Buttons</h3>
          <div class="flex gap-3">
            <Tooltip content="Edit">
              <button class="p-2 bg-gray-200 rounded-md hover:bg-gray-300">
                <svg class="h-5 w-5 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
              </button>
            </Tooltip>
            <Tooltip content="Delete" variant="danger">
              <button class="p-2 bg-gray-200 rounded-md hover:bg-gray-300">
                <svg class="h-5 w-5 text-gray-700" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </Tooltip>
          </div>
        </div>
      </div>
    `,
  }),
}
