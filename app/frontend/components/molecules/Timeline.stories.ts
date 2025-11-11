import type { Meta, StoryObj } from '@storybook/vue3-vite'
import Timeline from './Timeline.vue'

const meta = {
  title: 'Molecules/Timeline',
  component: Timeline,
  tags: ['autodocs'],
  argTypes: {
    position: { control: 'select', options: ['left', 'center'] },
  },
  args: {
    position: 'left',
  },
} satisfies Meta<typeof Timeline>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: (args) => ({
    components: { Timeline },
    setup() {
      const items = [
        {
          title: 'Order placed',
          description: 'Your order has been received and is being processed',
          timestamp: '2024-01-01 10:00',
          variant: 'success' as const,
          icon: 'check-circle',
        },
        {
          title: 'Payment confirmed',
          description: 'Payment has been successfully processed',
          timestamp: '2024-01-01 10:15',
          variant: 'success' as const,
          icon: 'credit-card',
        },
        {
          title: 'Processing',
          description: 'Your order is being prepared for shipment',
          timestamp: '2024-01-01 14:30',
          variant: 'info' as const,
          icon: 'package',
          badge: 'Current',
        },
        {
          title: 'Shipped',
          description: 'Your order will be shipped soon',
          timestamp: 'Pending',
          variant: 'default' as const,
          icon: 'truck',
        },
      ]
      return { args: { ...args, items } }
    },
    template: '<Timeline v-bind="args" />',
  }),
}

export const LeftPosition: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = [
        {
          title: 'Project Created',
          description: 'New project initialized with default configuration',
          timestamp: '2 hours ago',
          icon: 'plus-circle',
          variant: 'success' as const,
        },
        {
          title: 'First Commit',
          description: 'Initial codebase committed to repository',
          timestamp: '1 hour ago',
          icon: 'git-commit',
          variant: 'success' as const,
        },
        {
          title: 'Build Running',
          description: 'Continuous integration build in progress',
          timestamp: '30 minutes ago',
          icon: 'loader',
          variant: 'info' as const,
          badge: 'In Progress',
        },
        {
          title: 'Deploy Pending',
          description: 'Awaiting build completion before deployment',
          timestamp: 'Pending',
          icon: 'upload-cloud',
          variant: 'default' as const,
        },
      ]
      return { items }
    },
    template: '<Timeline :items="items" position="left" />',
  }),
}

export const CenterPosition: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = [
        {
          title: 'Account Created',
          description: 'User account successfully created',
          timestamp: 'Jan 1, 2024',
          icon: 'user-plus',
          variant: 'success' as const,
        },
        {
          title: 'Email Verified',
          description: 'Email address has been confirmed',
          timestamp: 'Jan 2, 2024',
          icon: 'mail-check',
          variant: 'success' as const,
        },
        {
          title: 'Profile Completed',
          description: 'All profile information has been filled',
          timestamp: 'Jan 5, 2024',
          icon: 'check-circle',
          variant: 'success' as const,
        },
      ]
      return { items }
    },
    template: '<Timeline :items="items" position="center" />',
  }),
}

export const WithBadges: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = [
        {
          title: 'Task Created',
          description: 'New task added to project',
          timestamp: '2024-01-01',
          variant: 'info' as const,
          badge: 'New',
        },
        {
          title: 'Task In Progress',
          description: 'Work started on the task',
          timestamp: '2024-01-02',
          variant: 'warning' as const,
          badge: 'Active',
        },
        {
          title: 'Task Completed',
          description: 'Task has been finished',
          timestamp: '2024-01-03',
          variant: 'success' as const,
          badge: 'Done',
        },
      ]
      return { items }
    },
    template: '<Timeline :items="items" />',
  }),
}

export const DifferentVariants: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = [
        {
          title: 'Success Event',
          description: 'Everything went well',
          timestamp: '10:00 AM',
          variant: 'success' as const,
          icon: 'check-circle',
        },
        {
          title: 'Info Event',
          description: 'Something to note',
          timestamp: '11:00 AM',
          variant: 'info' as const,
          icon: 'info',
        },
        {
          title: 'Warning Event',
          description: 'Please review this',
          timestamp: '12:00 PM',
          variant: 'warning' as const,
          icon: 'alert-triangle',
        },
        {
          title: 'Danger Event',
          description: 'Something went wrong',
          timestamp: '1:00 PM',
          variant: 'danger' as const,
          icon: 'x-circle',
        },
        {
          title: 'Default Event',
          description: 'Standard event',
          timestamp: '2:00 PM',
          variant: 'default' as const,
          icon: 'circle',
        },
      ]
      return { items }
    },
    template: '<Timeline :items="items" />',
  }),
}

export const WithoutIcons: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = [
        {
          title: 'First Event',
          description: 'Something happened first',
          timestamp: 'Today',
          variant: 'success' as const,
        },
        {
          title: 'Second Event',
          description: 'Then this happened',
          timestamp: 'Yesterday',
          variant: 'info' as const,
        },
        {
          title: 'Third Event',
          description: 'Finally this occurred',
          timestamp: '2 days ago',
          variant: 'default' as const,
        },
      ]
      return { items }
    },
    template: '<Timeline :items="items" />',
  }),
}

export const MinimalTimeline: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = [{ title: 'Event 1' }, { title: 'Event 2' }, { title: 'Event 3' }]
      return { items }
    },
    template: '<Timeline :items="items" />',
  }),
}

export const RealWorldActivity: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = [
        {
          title: 'John Doe commented',
          description: 'Great work on this feature! Looking forward to the release.',
          timestamp: '5 minutes ago',
          icon: 'message-circle',
          variant: 'info' as const,
        },
        {
          title: 'Jane Smith pushed commits',
          description: 'Added authentication middleware and updated tests',
          timestamp: '1 hour ago',
          icon: 'git-commit',
          variant: 'success' as const,
        },
        {
          title: 'Build failed',
          description: 'ESLint errors found in components/Header.tsx',
          timestamp: '2 hours ago',
          icon: 'x-circle',
          variant: 'danger' as const,
          badge: 'Failed',
        },
        {
          title: 'Pull request opened',
          description: 'Feature: Add dark mode support #123',
          timestamp: '3 hours ago',
          icon: 'git-pull-request',
          variant: 'info' as const,
        },
        {
          title: 'Issue closed',
          description: 'Bug: Navigation menu not responsive',
          timestamp: '1 day ago',
          icon: 'check-circle',
          variant: 'success' as const,
          badge: 'Closed',
        },
      ]
      return { items }
    },
    template: '<Timeline :items="items" />',
  }),
}

export const OrderTracking: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = [
        {
          title: 'Order Placed',
          description: 'Order #12345 has been received',
          timestamp: 'Mon, Jan 1 at 10:00 AM',
          icon: 'shopping-bag',
          variant: 'success' as const,
        },
        {
          title: 'Payment Confirmed',
          description: 'Payment processed successfully',
          timestamp: 'Mon, Jan 1 at 10:05 AM',
          icon: 'credit-card',
          variant: 'success' as const,
        },
        {
          title: 'Order Packed',
          description: 'Your items have been packed',
          timestamp: 'Mon, Jan 1 at 2:30 PM',
          icon: 'package',
          variant: 'success' as const,
        },
        {
          title: 'Out for Delivery',
          description: 'Package is on its way',
          timestamp: 'Tue, Jan 2 at 8:00 AM',
          icon: 'truck',
          variant: 'info' as const,
          badge: 'Current',
        },
        {
          title: 'Delivered',
          description: 'Estimated delivery by 5:00 PM',
          timestamp: 'Pending',
          icon: 'check-circle',
          variant: 'default' as const,
        },
      ]
      return { items }
    },
    template: '<Timeline :items="items" position="left" />',
  }),
}

export const UserActivity: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = [
        {
          title: 'Logged In',
          description: 'User logged in from Chrome on Windows',
          timestamp: 'Today at 9:00 AM',
          icon: 'log-in',
          variant: 'success' as const,
        },
        {
          title: 'Profile Updated',
          description: 'Changed profile picture and bio',
          timestamp: 'Today at 9:15 AM',
          icon: 'user',
          variant: 'info' as const,
        },
        {
          title: 'Posted Comment',
          description: 'Commented on "Vue 3 Best Practices"',
          timestamp: 'Today at 10:30 AM',
          icon: 'message-square',
          variant: 'info' as const,
        },
        {
          title: 'Security Alert',
          description: 'Login attempt from unknown location',
          timestamp: 'Today at 11:00 AM',
          icon: 'shield-alert',
          variant: 'warning' as const,
          badge: 'Alert',
        },
      ]
      return { items }
    },
    template: '<Timeline :items="items" />',
  }),
}

export const WithCustomContent: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = [
        {
          title: 'File Uploaded',
          description: 'document.pdf has been uploaded',
          timestamp: '10 minutes ago',
          icon: 'file',
          variant: 'success' as const,
        },
        {
          title: 'Review Requested',
          description: 'John requested your review',
          timestamp: '1 hour ago',
          icon: 'eye',
          variant: 'info' as const,
        },
      ]
      return { items }
    },
    template: `
      <Timeline :items="items">
        <template #item-0>
          <div class="mt-2 flex gap-2">
            <button class="rounded bg-primary-600 px-3 py-1 text-sm text-white hover:bg-primary-700">
              View File
            </button>
            <button class="rounded border border-gray-300 px-3 py-1 text-sm hover:bg-gray-50">
              Download
            </button>
          </div>
        </template>
        <template #item-1>
          <div class="mt-2 flex gap-2">
            <button class="rounded bg-primary-600 px-3 py-1 text-sm text-white hover:bg-primary-700">
              Review Now
            </button>
          </div>
        </template>
      </Timeline>
    `,
  }),
}

export const LongTimeline: Story = {
  render: () => ({
    components: { Timeline },
    setup() {
      const items = Array.from({ length: 10 }, (_, i) => ({
        title: `Event ${i + 1}`,
        description: `Description for event ${i + 1}`,
        timestamp: `${10 - i} days ago`,
        icon: i % 2 === 0 ? 'circle' : 'check-circle',
        variant: (i < 3 ? 'success' : i < 7 ? 'info' : 'default') as 'success' | 'info' | 'default',
      }))
      return { items }
    },
    template: '<Timeline :items="items" />',
  }),
}
