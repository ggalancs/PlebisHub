import type { Meta, StoryObj } from '@storybook/vue3'
import Badge from './Badge.vue'

const meta = {
  title: 'Molecules/Badge',
  component: Badge,
  tags: ['autodocs'],
} satisfies Meta<typeof Badge>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    label: 'Badge',
  },
}

export const AllVariants: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex flex-wrap gap-3">
        <Badge label="Default" variant="default" />
        <Badge label="Primary" variant="primary" />
        <Badge label="Secondary" variant="secondary" />
        <Badge label="Success" variant="success" />
        <Badge label="Warning" variant="warning" />
        <Badge label="Danger" variant="danger" />
        <Badge label="Info" variant="info" />
      </div>
    `,
  }),
}

export const Primary: Story = {
  args: {
    label: 'Primary',
    variant: 'primary',
  },
}

export const Secondary: Story = {
  args: {
    label: 'Secondary',
    variant: 'secondary',
  },
}

export const Success: Story = {
  args: {
    label: 'Success',
    variant: 'success',
  },
}

export const Warning: Story = {
  args: {
    label: 'Warning',
    variant: 'warning',
  },
}

export const Danger: Story = {
  args: {
    label: 'Danger',
    variant: 'danger',
  },
}

export const Info: Story = {
  args: {
    label: 'Info',
    variant: 'info',
  },
}

export const AllSizes: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex items-center gap-3">
        <Badge label="Small" size="sm" variant="primary" />
        <Badge label="Medium" size="md" variant="primary" />
        <Badge label="Large" size="lg" variant="primary" />
      </div>
    `,
  }),
}

export const SmallSize: Story = {
  args: {
    label: 'Small',
    size: 'sm',
  },
}

export const LargeSize: Story = {
  args: {
    label: 'Large',
    size: 'lg',
  },
}

export const WithIcon: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex flex-wrap gap-3">
        <Badge label="Star" icon="star" variant="warning" />
        <Badge label="Check" icon="check" variant="success" />
        <Badge label="Alert" icon="alert-circle" variant="danger" />
        <Badge label="Info" icon="info" variant="info" />
      </div>
    `,
  }),
}

export const IconOnly: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex gap-3">
        <Badge icon="star" variant="warning" />
        <Badge icon="check" variant="success" />
        <Badge icon="alert-circle" variant="danger" />
        <Badge icon="heart" variant="primary" />
      </div>
    `,
  }),
}

export const Removable: Story = {
  render: () => ({
    components: { Badge },
    setup() {
      const handleRemove = () => {
        console.log('Badge removed')
      }
      return { handleRemove }
    },
    template: `
      <div class="flex flex-wrap gap-3">
        <Badge label="Removable" removable @remove="handleRemove" />
        <Badge label="Primary" variant="primary" removable @remove="handleRemove" />
        <Badge label="Success" variant="success" removable @remove="handleRemove" />
        <Badge label="With Icon" icon="star" removable @remove="handleRemove" />
      </div>
    `,
  }),
}

export const Disabled: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex flex-wrap gap-3">
        <Badge label="Disabled" disabled />
        <Badge label="Primary" variant="primary" disabled />
        <Badge label="With Icon" icon="star" disabled />
      </div>
    `,
  }),
}

export const AllRounded: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex gap-3">
        <Badge label="Small" rounded="sm" variant="primary" />
        <Badge label="Medium" rounded="md" variant="primary" />
        <Badge label="Large" rounded="lg" variant="primary" />
        <Badge label="Full" rounded="full" variant="primary" />
      </div>
    `,
  }),
}

export const FullRounded: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex flex-wrap gap-3">
        <Badge label="Pill Badge" rounded="full" />
        <Badge label="Primary" variant="primary" rounded="full" />
        <Badge label="Success" variant="success" rounded="full" />
        <Badge label="With Icon" icon="star" rounded="full" variant="warning" />
      </div>
    `,
  }),
}

export const StatusBadges: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="space-y-4">
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600">Active</span>
          <Badge label="Active" variant="success" icon="check-circle" size="sm" />
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600">Pending</span>
          <Badge label="Pending" variant="warning" icon="clock" size="sm" />
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600">Inactive</span>
          <Badge label="Inactive" variant="default" icon="x-circle" size="sm" />
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600">Error</span>
          <Badge label="Error" variant="danger" icon="alert-circle" size="sm" />
        </div>
      </div>
    `,
  }),
}

export const CategoryTags: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="space-y-4">
        <div>
          <h3 class="text-sm font-semibold mb-2">Article Categories</h3>
          <div class="flex flex-wrap gap-2">
            <Badge label="Technology" variant="info" rounded="full" removable />
            <Badge label="Design" variant="primary" rounded="full" removable />
            <Badge label="Business" variant="secondary" rounded="full" removable />
            <Badge label="Marketing" variant="success" rounded="full" removable />
          </div>
        </div>
      </div>
    `,
  }),
}

export const UserProfile: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="max-w-md p-6 bg-white border rounded-lg">
        <div class="flex items-start gap-4">
          <div class="w-12 h-12 bg-primary rounded-full flex items-center justify-center text-white font-semibold">
            JD
          </div>
          <div class="flex-1">
            <div class="flex items-center gap-2 mb-2">
              <h3 class="font-semibold">John Doe</h3>
              <Badge label="Pro" variant="primary" size="sm" />
              <Badge label="Verified" icon="check-circle" variant="success" size="sm" />
            </div>
            <p class="text-sm text-gray-600 mb-3">Product Designer at Acme Inc</p>
            <div class="flex flex-wrap gap-2">
              <Badge label="Vue.js" size="sm" />
              <Badge label="TypeScript" size="sm" />
              <Badge label="Design Systems" size="sm" />
            </div>
          </div>
        </div>
      </div>
    `,
  }),
}

export const NotificationCounts: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex gap-4">
        <div class="relative">
          <button class="p-2 hover:bg-gray-100 rounded-lg transition-colors">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
          </button>
          <div class="absolute -top-1 -right-1">
            <Badge label="3" variant="danger" size="sm" rounded="full" />
          </div>
        </div>
        <div class="relative">
          <button class="p-2 hover:bg-gray-100 rounded-lg transition-colors">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
          </button>
          <div class="absolute -top-1 -right-1">
            <Badge label="12" variant="danger" size="sm" rounded="full" />
          </div>
        </div>
      </div>
    `,
  }),
}

export const ProductFeatures: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="max-w-md p-6 bg-white border rounded-lg">
        <div class="flex items-start justify-between mb-4">
          <div>
            <h3 class="text-lg font-semibold mb-1">Premium Plan</h3>
            <p class="text-2xl font-bold">$29<span class="text-sm text-gray-600">/month</span></p>
          </div>
          <Badge label="Popular" variant="primary" />
        </div>
        <ul class="space-y-3">
          <li class="flex items-center gap-2">
            <Badge icon="check" variant="success" size="sm" rounded="full" />
            <span class="text-sm">Unlimited projects</span>
          </li>
          <li class="flex items-center gap-2">
            <Badge icon="check" variant="success" size="sm" rounded="full" />
            <span class="text-sm">Priority support</span>
          </li>
          <li class="flex items-center gap-2">
            <Badge icon="check" variant="success" size="sm" rounded="full" />
            <span class="text-sm">Advanced analytics</span>
          </li>
        </ul>
      </div>
    `,
  }),
}

export const InText: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="max-w-md">
        <p class="text-gray-700">
          This feature is currently <Badge label="Beta" variant="info" size="sm" /> and may have some limitations.
          For production use, please upgrade to <Badge label="Pro" variant="primary" size="sm" />.
        </p>
      </div>
    `,
  }),
}

export const CustomContent: Story = {
  render: () => ({
    components: { Badge },
    template: `
      <div class="flex flex-wrap gap-3">
        <Badge variant="primary">
          <span class="flex items-center gap-1">
            <svg class="w-3 h-3" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
            4.5
          </span>
        </Badge>
        <Badge variant="success">
          <span class="flex items-center gap-1">
            <span class="text-xs">✓</span>
            Verified
          </span>
        </Badge>
        <Badge variant="warning">
          <span class="flex items-center gap-1">
            <span>⚡</span>
            Fast
          </span>
        </Badge>
      </div>
    `,
  }),
}
