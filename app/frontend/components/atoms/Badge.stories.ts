import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Badge from './Badge.vue'

const meta = {
  title: 'Atoms/Badge',
  component: Badge,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'success', 'danger', 'warning', 'info', 'neutral'],
      description: 'Badge color variant',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Badge size',
    },
    dot: {
      control: 'boolean',
      description: 'Show dot indicator',
    },
    pill: {
      control: 'boolean',
      description: 'Rounded pill shape',
    },
    removable: {
      control: 'boolean',
      description: 'Show remove button',
    },
  },
  args: {
    variant: 'primary',
    size: 'md',
    dot: false,
    pill: false,
    removable: false,
  },
} satisfies Meta<typeof Badge>

export default meta
type Story = StoryObj<typeof meta>

// Default badge
export const Default: Story = {
  args: {},
  render: (args) => ({
    components: { Badge },
    setup() {
      return { args }
    },
    template: '<Badge v-bind="args">Badge</Badge>',
  }),
}

// All variants
export const AllVariants: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex flex-wrap gap-2">
        <Badge variant="primary">Primary</Badge>
        <Badge variant="secondary">Secondary</Badge>
        <Badge variant="success">Success</Badge>
        <Badge variant="danger">Danger</Badge>
        <Badge variant="warning">Warning</Badge>
        <Badge variant="info">Info</Badge>
        <Badge variant="neutral">Neutral</Badge>
      </div>
    `,
  }),
}

// All sizes
export const AllSizes: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex items-center gap-3">
        <Badge size="sm">Small</Badge>
        <Badge size="md">Medium</Badge>
        <Badge size="lg">Large</Badge>
      </div>
    `,
  }),
}

// With dot indicator
export const WithDot: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex flex-wrap gap-2">
        <Badge variant="primary" dot>Primary</Badge>
        <Badge variant="secondary" dot>Secondary</Badge>
        <Badge variant="success" dot>Success</Badge>
        <Badge variant="danger" dot>Danger</Badge>
        <Badge variant="warning" dot>Warning</Badge>
        <Badge variant="info" dot>Info</Badge>
        <Badge variant="neutral" dot>Neutral</Badge>
      </div>
    `,
  }),
}

// Pill shape
export const PillShape: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex flex-wrap gap-2">
        <Badge variant="primary" pill>Primary</Badge>
        <Badge variant="secondary" pill>Secondary</Badge>
        <Badge variant="success" pill>Success</Badge>
        <Badge variant="danger" pill>Danger</Badge>
        <Badge variant="warning" pill>Warning</Badge>
        <Badge variant="info" pill>Info</Badge>
        <Badge variant="neutral" pill>Neutral</Badge>
      </div>
    `,
  }),
}

// Removable badges
export const Removable: Story = {
  render: () => ({
    components: { Badge },
    setup() {
      const badges = ref([
        { id: 1, text: 'React', variant: 'primary' as const },
        { id: 2, text: 'Vue', variant: 'success' as const },
        { id: 3, text: 'Angular', variant: 'danger' as const },
        { id: 4, text: 'Svelte', variant: 'warning' as const },
      ])

      const removeBadge = (id: number) => {
        badges.value = badges.value.filter((b) => b.id !== id)
      }

      return { badges, removeBadge }
    },
    template: `
      <div>
        <div class="flex flex-wrap gap-2">
          <Badge
            v-for="badge in badges"
            :key="badge.id"
            :variant="badge.variant"
            removable
            @remove="removeBadge(badge.id)"
          >
            {{ badge.text }}
          </Badge>
        </div>
        <p class="mt-4 text-sm text-gray-600">
          Click the × to remove a badge
        </p>
      </div>
    `,
  }),
}

// Status indicators
export const StatusIndicators: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="space-y-4">
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600">Online:</span>
          <Badge variant="success" dot size="sm">Active</Badge>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600">Processing:</span>
          <Badge variant="warning" dot size="sm">In Progress</Badge>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600">Error:</span>
          <Badge variant="danger" dot size="sm">Failed</Badge>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600">Offline:</span>
          <Badge variant="neutral" dot size="sm">Inactive</Badge>
        </div>
      </div>
    `,
  }),
}

// With numbers
export const WithNumbers: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex flex-wrap gap-4">
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-700">Messages</span>
          <Badge variant="danger" pill>5</Badge>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-700">Notifications</span>
          <Badge variant="primary" pill>12</Badge>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-700">Tasks</span>
          <Badge variant="success" pill>3</Badge>
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-700">Alerts</span>
          <Badge variant="warning" pill>99+</Badge>
        </div>
      </div>
    `,
  }),
}

// Tags example
export const TagsExample: Story = {
  render: () => ({
    components: { Badge },
    setup() {
      const tags = ref([
        { id: 1, text: 'JavaScript', color: 'warning' as const },
        { id: 2, text: 'TypeScript', color: 'info' as const },
        { id: 3, text: 'React', color: 'primary' as const },
        { id: 4, text: 'Vue.js', color: 'success' as const },
        { id: 5, text: 'Node.js', color: 'secondary' as const },
      ])

      const removeTag = (id: number) => {
        tags.value = tags.value.filter((t) => t.id !== id)
      }

      return { tags, removeTag }
    },
    template: `
      <div>
        <h3 class="text-sm font-medium text-gray-700 mb-3">Skills</h3>
        <div class="flex flex-wrap gap-2">
          <Badge
            v-for="tag in tags"
            :key="tag.id"
            :variant="tag.color"
            pill
            removable
            @remove="removeTag(tag.id)"
          >
            {{ tag.text }}
          </Badge>
        </div>
        <p class="mt-4 text-sm text-gray-600">
          Click × to remove a skill
        </p>
      </div>
    `,
  }),
}

// Category labels
export const CategoryLabels: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="space-y-4">
        <div>
          <h3 class="text-sm font-medium text-gray-900 mb-2">New Feature Release</h3>
          <div class="flex gap-2">
            <Badge variant="success">New</Badge>
            <Badge variant="info">Feature</Badge>
            <Badge variant="neutral">v2.0</Badge>
          </div>
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-900 mb-2">Bug Report</h3>
          <div class="flex gap-2">
            <Badge variant="danger">Critical</Badge>
            <Badge variant="warning">High Priority</Badge>
          </div>
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-900 mb-2">Documentation Update</h3>
          <div class="flex gap-2">
            <Badge variant="info">Docs</Badge>
            <Badge variant="secondary">In Review</Badge>
          </div>
        </div>
      </div>
    `,
  }),
}

// User roles
export const UserRoles: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="space-y-3">
        <div class="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
          <span class="text-sm text-gray-900">John Doe</span>
          <Badge variant="primary" size="sm">Admin</Badge>
        </div>
        <div class="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
          <span class="text-sm text-gray-900">Jane Smith</span>
          <Badge variant="info" size="sm">Editor</Badge>
        </div>
        <div class="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
          <span class="text-sm text-gray-900">Bob Johnson</span>
          <Badge variant="neutral" size="sm">Viewer</Badge>
        </div>
      </div>
    `,
  }),
}

// Showcase all combinations
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="space-y-6">
        <div>
          <h3 class="text-lg font-semibold mb-3">Variants</h3>
          <div class="flex flex-wrap gap-2">
            <Badge variant="primary">Primary</Badge>
            <Badge variant="secondary">Secondary</Badge>
            <Badge variant="success">Success</Badge>
            <Badge variant="danger">Danger</Badge>
            <Badge variant="warning">Warning</Badge>
            <Badge variant="info">Info</Badge>
            <Badge variant="neutral">Neutral</Badge>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Sizes</h3>
          <div class="flex items-center gap-3">
            <Badge size="sm" variant="primary">Small</Badge>
            <Badge size="md" variant="primary">Medium</Badge>
            <Badge size="lg" variant="primary">Large</Badge>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">With Dots</h3>
          <div class="flex flex-wrap gap-2">
            <Badge variant="success" dot>Active</Badge>
            <Badge variant="warning" dot>Pending</Badge>
            <Badge variant="danger" dot>Error</Badge>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Pill Shape</h3>
          <div class="flex flex-wrap gap-2">
            <Badge variant="primary" pill>24</Badge>
            <Badge variant="danger" pill>99+</Badge>
            <Badge variant="success" pill>New</Badge>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Removable</h3>
          <div class="flex flex-wrap gap-2">
            <Badge variant="primary" removable>React</Badge>
            <Badge variant="success" removable>Vue</Badge>
            <Badge variant="info" removable>Angular</Badge>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">All Features Combined</h3>
          <div class="flex flex-wrap gap-2">
            <Badge variant="success" size="lg" dot pill removable>Complete</Badge>
            <Badge variant="warning" size="md" dot removable>In Progress</Badge>
            <Badge variant="danger" size="sm" dot>Failed</Badge>
          </div>
        </div>
      </div>
    `,
  }),
}
