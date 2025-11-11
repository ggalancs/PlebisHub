import type { Meta, StoryObj } from '@storybook/vue3-vite'
import Icon from './Icon.vue'

const meta = {
  title: 'Atoms/Icon',
  component: Icon,
  tags: ['autodocs'],
  argTypes: {
    name: {
      control: 'text',
      description: 'Icon name from Lucide library (kebab-case)',
    },
    size: {
      control: 'select',
      options: ['xs', 'sm', 'md', 'lg', 'xl', '2xl'],
      description: 'Icon size (or custom number)',
    },
    color: {
      control: 'color',
      description: 'Icon color',
    },
    strokeWidth: {
      control: { type: 'number', min: 0.5, max: 4, step: 0.5 },
      description: 'Stroke width',
    },
    ariaLabel: {
      control: 'text',
      description: 'Aria label for accessibility',
    },
  },
  args: {
    name: 'home',
    size: 'md',
    strokeWidth: 2,
  },
} satisfies Meta<typeof Icon>

export default meta
type Story = StoryObj<typeof meta>

// Default icon
export const Default: Story = {
  args: {
    name: 'home',
  },
}

// All sizes
export const AllSizes: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="flex items-center gap-4">
        <div class="text-center">
          <Icon name="star" size="xs" class="text-yellow-500" />
          <p class="text-xs text-gray-600 mt-1">xs (12px)</p>
        </div>
        <div class="text-center">
          <Icon name="star" size="sm" class="text-yellow-500" />
          <p class="text-xs text-gray-600 mt-1">sm (16px)</p>
        </div>
        <div class="text-center">
          <Icon name="star" size="md" class="text-yellow-500" />
          <p class="text-xs text-gray-600 mt-1">md (20px)</p>
        </div>
        <div class="text-center">
          <Icon name="star" size="lg" class="text-yellow-500" />
          <p class="text-xs text-gray-600 mt-1">lg (24px)</p>
        </div>
        <div class="text-center">
          <Icon name="star" size="xl" class="text-yellow-500" />
          <p class="text-xs text-gray-600 mt-1">xl (32px)</p>
        </div>
        <div class="text-center">
          <Icon name="star" size="2xl" class="text-yellow-500" />
          <p class="text-xs text-gray-600 mt-1">2xl (40px)</p>
        </div>
      </div>
    `,
  }),
}

// Custom numeric size
export const CustomSize: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="flex items-center gap-4">
        <Icon name="heart" :size="16" class="text-red-500" />
        <Icon name="heart" :size="24" class="text-red-500" />
        <Icon name="heart" :size="32" class="text-red-500" />
        <Icon name="heart" :size="48" class="text-red-500" />
        <Icon name="heart" :size="64" class="text-red-500" />
      </div>
    `,
  }),
}

// Common icons
export const CommonIcons: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="grid grid-cols-8 gap-4">
        <div class="text-center">
          <Icon name="home" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">home</p>
        </div>
        <div class="text-center">
          <Icon name="user" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">user</p>
        </div>
        <div class="text-center">
          <Icon name="settings" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">settings</p>
        </div>
        <div class="text-center">
          <Icon name="search" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">search</p>
        </div>
        <div class="text-center">
          <Icon name="mail" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">mail</p>
        </div>
        <div class="text-center">
          <Icon name="phone" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">phone</p>
        </div>
        <div class="text-center">
          <Icon name="calendar" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">calendar</p>
        </div>
        <div class="text-center">
          <Icon name="star" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">star</p>
        </div>
        <div class="text-center">
          <Icon name="heart" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">heart</p>
        </div>
        <div class="text-center">
          <Icon name="bell" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">bell</p>
        </div>
        <div class="text-center">
          <Icon name="message-square" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">message-square</p>
        </div>
        <div class="text-center">
          <Icon name="trash-2" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">trash-2</p>
        </div>
        <div class="text-center">
          <Icon name="edit" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">edit</p>
        </div>
        <div class="text-center">
          <Icon name="check" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">check</p>
        </div>
        <div class="text-center">
          <Icon name="x" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">x</p>
        </div>
        <div class="text-center">
          <Icon name="plus" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">plus</p>
        </div>
      </div>
    `,
  }),
}

// Arrow icons
export const ArrowIcons: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="flex items-center gap-6">
        <div class="text-center">
          <Icon name="arrow-up" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">arrow-up</p>
        </div>
        <div class="text-center">
          <Icon name="arrow-down" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">arrow-down</p>
        </div>
        <div class="text-center">
          <Icon name="arrow-left" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">arrow-left</p>
        </div>
        <div class="text-center">
          <Icon name="arrow-right" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">arrow-right</p>
        </div>
        <div class="text-center">
          <Icon name="chevron-up" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">chevron-up</p>
        </div>
        <div class="text-center">
          <Icon name="chevron-down" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">chevron-down</p>
        </div>
        <div class="text-center">
          <Icon name="chevron-left" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">chevron-left</p>
        </div>
        <div class="text-center">
          <Icon name="chevron-right" size="lg" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">chevron-right</p>
        </div>
      </div>
    `,
  }),
}

// Status icons
export const StatusIcons: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="flex items-center gap-6">
        <div class="text-center">
          <Icon name="check-circle" size="xl" class="text-green-600" />
          <p class="text-xs text-gray-600 mt-1">Success</p>
        </div>
        <div class="text-center">
          <Icon name="alert-circle" size="xl" class="text-yellow-600" />
          <p class="text-xs text-gray-600 mt-1">Warning</p>
        </div>
        <div class="text-center">
          <Icon name="x-circle" size="xl" class="text-red-600" />
          <p class="text-xs text-gray-600 mt-1">Error</p>
        </div>
        <div class="text-center">
          <Icon name="info" size="xl" class="text-blue-600" />
          <p class="text-xs text-gray-600 mt-1">Info</p>
        </div>
        <div class="text-center">
          <Icon name="help-circle" size="xl" class="text-gray-600" />
          <p class="text-xs text-gray-600 mt-1">Help</p>
        </div>
      </div>
    `,
  }),
}

// With colors
export const WithColors: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="flex items-center gap-4">
        <Icon name="heart" size="xl" color="#ef4444" />
        <Icon name="star" size="xl" color="#f59e0b" />
        <Icon name="check-circle" size="xl" color="#10b981" />
        <Icon name="info" size="xl" color="#3b82f6" />
        <Icon name="alert-circle" size="xl" color="#f59e0b" />
        <Icon name="x-circle" size="xl" color="#ef4444" />
      </div>
    `,
  }),
}

// Different stroke widths
export const StrokeWidths: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="flex items-center gap-6">
        <div class="text-center">
          <Icon name="home" size="xl" :stroke-width="0.5" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">0.5</p>
        </div>
        <div class="text-center">
          <Icon name="home" size="xl" :stroke-width="1" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">1</p>
        </div>
        <div class="text-center">
          <Icon name="home" size="xl" :stroke-width="1.5" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">1.5</p>
        </div>
        <div class="text-center">
          <Icon name="home" size="xl" :stroke-width="2" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">2 (default)</p>
        </div>
        <div class="text-center">
          <Icon name="home" size="xl" :stroke-width="2.5" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">2.5</p>
        </div>
        <div class="text-center">
          <Icon name="home" size="xl" :stroke-width="3" class="text-gray-700" />
          <p class="text-xs text-gray-600 mt-1">3</p>
        </div>
      </div>
    `,
  }),
}

// In buttons
export const InButtons: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="flex flex-wrap gap-3">
        <button class="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 transition-colors">
          <Icon name="plus" size="sm" />
          <span>Add Item</span>
        </button>
        <button class="inline-flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors">
          <Icon name="check" size="sm" />
          <span>Confirm</span>
        </button>
        <button class="inline-flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors">
          <Icon name="trash-2" size="sm" />
          <span>Delete</span>
        </button>
        <button class="inline-flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors">
          <span>Download</span>
          <Icon name="download" size="sm" />
        </button>
        <button class="inline-flex items-center justify-center p-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 transition-colors">
          <Icon name="settings" size="md" aria-label="Settings" />
        </button>
      </div>
    `,
  }),
}

// In inputs
export const InInputs: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="space-y-4 max-w-md">
        <div class="relative">
          <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
            <Icon name="search" size="md" class="text-gray-400" />
          </div>
          <input
            type="text"
            placeholder="Search..."
            class="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>

        <div class="relative">
          <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
            <Icon name="mail" size="md" class="text-gray-400" />
          </div>
          <input
            type="email"
            placeholder="Email address"
            class="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>

        <div class="relative">
          <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
            <Icon name="lock" size="md" class="text-gray-400" />
          </div>
          <input
            type="password"
            placeholder="Password"
            class="w-full pl-10 pr-10 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
          <button class="absolute inset-y-0 right-0 flex items-center pr-3">
            <Icon name="eye" size="md" class="text-gray-400 hover:text-gray-600 transition-colors" />
          </button>
        </div>
      </div>
    `,
  }),
}

// In alerts
export const InAlerts: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="space-y-3">
        <div class="flex gap-3 p-4 bg-green-50 border border-green-200 rounded-md">
          <Icon name="check-circle" size="lg" class="text-green-600 flex-shrink-0" />
          <div>
            <h4 class="text-sm font-medium text-green-900">Success!</h4>
            <p class="text-sm text-green-700 mt-1">Your changes have been saved successfully.</p>
          </div>
        </div>

        <div class="flex gap-3 p-4 bg-yellow-50 border border-yellow-200 rounded-md">
          <Icon name="alert-circle" size="lg" class="text-yellow-600 flex-shrink-0" />
          <div>
            <h4 class="text-sm font-medium text-yellow-900">Warning</h4>
            <p class="text-sm text-yellow-700 mt-1">Please review your information before proceeding.</p>
          </div>
        </div>

        <div class="flex gap-3 p-4 bg-red-50 border border-red-200 rounded-md">
          <Icon name="x-circle" size="lg" class="text-red-600 flex-shrink-0" />
          <div>
            <h4 class="text-sm font-medium text-red-900">Error</h4>
            <p class="text-sm text-red-700 mt-1">Something went wrong. Please try again.</p>
          </div>
        </div>

        <div class="flex gap-3 p-4 bg-blue-50 border border-blue-200 rounded-md">
          <Icon name="info" size="lg" class="text-blue-600 flex-shrink-0" />
          <div>
            <h4 class="text-sm font-medium text-blue-900">Info</h4>
            <p class="text-sm text-blue-700 mt-1">New features are now available. Check them out!</p>
          </div>
        </div>
      </div>
    `,
  }),
}

// In navigation
export const InNavigation: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <nav class="bg-white border border-gray-200 rounded-lg p-2 max-w-xs">
        <a href="#" class="flex items-center gap-3 px-3 py-2 text-gray-700 hover:bg-gray-100 rounded-md transition-colors">
          <Icon name="home" size="md" />
          <span class="text-sm font-medium">Home</span>
        </a>
        <a href="#" class="flex items-center gap-3 px-3 py-2 text-gray-700 hover:bg-gray-100 rounded-md transition-colors">
          <Icon name="users" size="md" />
          <span class="text-sm font-medium">Team</span>
        </a>
        <a href="#" class="flex items-center gap-3 px-3 py-2 text-gray-700 hover:bg-gray-100 rounded-md transition-colors">
          <Icon name="folder" size="md" />
          <span class="text-sm font-medium">Projects</span>
        </a>
        <a href="#" class="flex items-center gap-3 px-3 py-2 text-gray-700 hover:bg-gray-100 rounded-md transition-colors">
          <Icon name="calendar" size="md" />
          <span class="text-sm font-medium">Calendar</span>
        </a>
        <a href="#" class="flex items-center gap-3 px-3 py-2 text-gray-700 hover:bg-gray-100 rounded-md transition-colors">
          <Icon name="settings" size="md" />
          <span class="text-sm font-medium">Settings</span>
        </a>
      </nav>
    `,
  }),
}

// File type icons
export const FileTypeIcons: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="grid grid-cols-6 gap-4">
        <div class="text-center">
          <Icon name="file-text" size="xl" class="text-blue-500" />
          <p class="text-xs text-gray-600 mt-1">Document</p>
        </div>
        <div class="text-center">
          <Icon name="file-image" size="xl" class="text-purple-500" />
          <p class="text-xs text-gray-600 mt-1">Image</p>
        </div>
        <div class="text-center">
          <Icon name="file-video" size="xl" class="text-red-500" />
          <p class="text-xs text-gray-600 mt-1">Video</p>
        </div>
        <div class="text-center">
          <Icon name="file-audio" size="xl" class="text-green-500" />
          <p class="text-xs text-gray-600 mt-1">Audio</p>
        </div>
        <div class="text-center">
          <Icon name="file-code" size="xl" class="text-orange-500" />
          <p class="text-xs text-gray-600 mt-1">Code</p>
        </div>
        <div class="text-center">
          <Icon name="file" size="xl" class="text-gray-500" />
          <p class="text-xs text-gray-600 mt-1">Generic</p>
        </div>
      </div>
    `,
  }),
}

// Interactive example
export const Interactive: Story = {
  args: {
    name: 'star',
    size: 'xl',
    color: '#fbbf24',
    strokeWidth: 2,
    ariaLabel: 'Star icon',
  },
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Icon },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="flex items-center gap-4">
            <Icon name="star" size="xs" class="text-yellow-500" />
            <Icon name="star" size="sm" class="text-yellow-500" />
            <Icon name="star" size="md" class="text-yellow-500" />
            <Icon name="star" size="lg" class="text-yellow-500" />
            <Icon name="star" size="xl" class="text-yellow-500" />
            <Icon name="star" size="2xl" class="text-yellow-500" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Colors</h3>
          <div class="flex items-center gap-4">
            <Icon name="heart" size="xl" color="#ef4444" />
            <Icon name="heart" size="xl" color="#f59e0b" />
            <Icon name="heart" size="xl" color="#10b981" />
            <Icon name="heart" size="xl" color="#3b82f6" />
            <Icon name="heart" size="xl" color="#8b5cf6" />
            <Icon name="heart" size="xl" color="#ec4899" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Status Icons</h3>
          <div class="flex items-center gap-4">
            <Icon name="check-circle" size="xl" class="text-green-600" />
            <Icon name="alert-circle" size="xl" class="text-yellow-600" />
            <Icon name="x-circle" size="xl" class="text-red-600" />
            <Icon name="info" size="xl" class="text-blue-600" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">In Context</h3>
          <button class="inline-flex items-center gap-2 px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 transition-colors">
            <Icon name="plus" size="sm" />
            <span>Create New</span>
          </button>
        </div>
      </div>
    `,
  }),
}
