import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import AlertBanner from './AlertBanner.vue'

const meta = {
  title: 'Molecules/AlertBanner',
  component: AlertBanner,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['success', 'warning', 'danger', 'info'],
      description: 'Alert variant/color',
    },
    title: {
      control: 'text',
      description: 'Alert title',
    },
    message: {
      control: 'text',
      description: 'Alert message/description',
    },
    showIcon: {
      control: 'boolean',
      description: 'Show icon',
    },
    icon: {
      control: 'text',
      description: 'Custom icon name',
    },
    closable: {
      control: 'boolean',
      description: 'Show close button',
    },
    style: {
      control: 'select',
      options: ['filled', 'outlined'],
      description: 'Banner style',
    },
  },
  args: {
    variant: 'info',
    showIcon: true,
    closable: false,
    style: 'filled',
  },
} satisfies Meta<typeof AlertBanner>

export default meta
type Story = StoryObj<typeof meta>

// Default alert
export const Default: Story = {
  args: {
    message: 'This is an informational alert message.',
  },
}

// All variants
export const AllVariants: Story = {
  render: () => ({
    components: { AlertBanner },
    template: `
      <div class="space-y-4">
        <AlertBanner
          variant="success"
          title="Success!"
          message="Your changes have been saved successfully."
        />
        <AlertBanner
          variant="warning"
          title="Warning"
          message="Please review your changes before continuing."
        />
        <AlertBanner
          variant="danger"
          title="Error"
          message="Something went wrong. Please try again."
        />
        <AlertBanner
          variant="info"
          title="Information"
          message="Here's some important information for you."
        />
      </div>
    `,
  }),
}

// With title
export const WithTitle: Story = {
  args: {
    variant: 'success',
    title: 'Success!',
    message: 'Your operation completed successfully.',
  },
}

// Without title
export const WithoutTitle: Story = {
  args: {
    variant: 'info',
    message: 'This is a simple alert message without a title.',
  },
}

// Without icon
export const WithoutIcon: Story = {
  args: {
    variant: 'warning',
    title: 'Notice',
    message: 'This alert has no icon.',
    showIcon: false,
  },
}

// Closable
export const Closable: Story = {
  render: () => ({
    components: { AlertBanner },
    setup() {
      const showAlert = ref(true)
      return { showAlert }
    },
    template: `
      <div>
        <AlertBanner
          v-if="showAlert"
          variant="info"
          title="Dismissible Alert"
          message="Click the close button to dismiss this alert."
          closable
          @close="showAlert = false"
        />
        <button
          v-if="!showAlert"
          @click="showAlert = true"
          class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
        >
          Show Alert Again
        </button>
      </div>
    `,
  }),
}

// Outlined style
export const OutlinedStyle: Story = {
  render: () => ({
    components: { AlertBanner },
    template: `
      <div class="space-y-4">
        <AlertBanner
          variant="success"
          title="Success"
          message="Outlined success alert"
          style="outlined"
        />
        <AlertBanner
          variant="warning"
          title="Warning"
          message="Outlined warning alert"
          style="outlined"
        />
        <AlertBanner
          variant="danger"
          title="Error"
          message="Outlined error alert"
          style="outlined"
        />
        <AlertBanner
          variant="info"
          title="Info"
          message="Outlined info alert"
          style="outlined"
        />
      </div>
    `,
  }),
}

// Custom icon
export const CustomIcon: Story = {
  render: () => ({
    components: { AlertBanner },
    template: `
      <div class="space-y-4">
        <AlertBanner
          variant="success"
          title="Achievement Unlocked!"
          message="You've completed all tasks."
          icon="trophy"
        />
        <AlertBanner
          variant="warning"
          title="Low Battery"
          message="Your device battery is running low."
          icon="battery-low"
        />
        <AlertBanner
          variant="info"
          title="New Message"
          message="You have 3 unread messages."
          icon="mail"
        />
      </div>
    `,
  }),
}

// With actions
export const WithActions: Story = {
  render: () => ({
    components: { AlertBanner },
    template: `
      <div class="space-y-4">
        <AlertBanner
          variant="success"
          title="Update Available"
          message="A new version is available. Would you like to update now?"
        >
          <template #actions>
            <div class="flex gap-3">
              <button class="px-3 py-1.5 text-sm font-medium text-green-700 bg-green-100 rounded-md hover:bg-green-200">
                Update Now
              </button>
              <button class="px-3 py-1.5 text-sm font-medium text-green-700 hover:text-green-800">
                Later
              </button>
            </div>
          </template>
        </AlertBanner>

        <AlertBanner
          variant="warning"
          title="Confirm Action"
          message="Are you sure you want to delete this item?"
        >
          <template #actions>
            <div class="flex gap-3">
              <button class="px-3 py-1.5 text-sm font-medium text-white bg-red-600 rounded-md hover:bg-red-700">
                Delete
              </button>
              <button class="px-3 py-1.5 text-sm font-medium text-yellow-700 hover:text-yellow-800">
                Cancel
              </button>
            </div>
          </template>
        </AlertBanner>
      </div>
    `,
  }),
}

// Form validation
export const FormValidation: Story = {
  render: () => ({
    components: { AlertBanner },
    template: `
      <div class="max-w-md">
        <AlertBanner
          variant="danger"
          title="Form Validation Failed"
          message="Please fix the following errors:"
          closable
        >
          <template #default>
            <ul class="list-disc list-inside mt-2 space-y-1">
              <li>Email is required</li>
              <li>Password must be at least 8 characters</li>
              <li>Terms and conditions must be accepted</li>
            </ul>
          </template>
        </AlertBanner>
      </div>
    `,
  }),
}

// Page notifications
export const PageNotifications: Story = {
  render: () => ({
    components: { AlertBanner },
    setup() {
      const alerts = ref([
        {
          id: 1,
          variant: 'success',
          title: 'Profile Updated',
          message: 'Your profile has been updated successfully.',
          show: true,
        },
        {
          id: 2,
          variant: 'warning',
          title: 'Session Expiring',
          message: 'Your session will expire in 5 minutes.',
          show: true,
        },
        {
          id: 3,
          variant: 'info',
          title: 'New Features',
          message: 'Check out our latest features and improvements.',
          show: true,
        },
      ])

      const closeAlert = (id: number) => {
        const alert = alerts.value.find((a) => a.id === id)
        if (alert) alert.show = false
      }

      return { alerts, closeAlert }
    },
    template: `
      <div class="space-y-3">
        <AlertBanner
          v-for="alert in alerts.filter(a => a.show)"
          :key="alert.id"
          :variant="alert.variant"
          :title="alert.title"
          :message="alert.message"
          closable
          @close="closeAlert(alert.id)"
        />
      </div>
    `,
  }),
}

// System status
export const SystemStatus: Story = {
  render: () => ({
    components: { AlertBanner },
    template: `
      <div class="space-y-4">
        <AlertBanner
          variant="success"
          icon="check-circle-2"
          message="All systems operational"
          :show-icon="true"
        />
        <AlertBanner
          variant="warning"
          icon="alert-triangle"
          message="Scheduled maintenance in 2 hours"
          :show-icon="true"
        />
        <AlertBanner
          variant="danger"
          icon="alert-circle"
          message="Service temporarily unavailable"
          :show-icon="true"
        />
      </div>
    `,
  }),
}

// Inline alerts
export const InlineAlerts: Story = {
  render: () => ({
    components: { AlertBanner },
    template: `
      <div class="max-w-2xl">
        <div class="border border-gray-200 rounded-lg p-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">Account Settings</h2>

          <div class="space-y-6">
            <AlertBanner
              variant="info"
              message="Two-factor authentication is disabled. Enable it for better security."
              :show-icon="true"
            >
              <template #actions>
                <button class="text-sm font-medium text-blue-700 hover:text-blue-800">
                  Enable Now →
                </button>
              </template>
            </AlertBanner>

            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input type="email" class="w-full px-3 py-2 border border-gray-300 rounded-md" value="user@example.com" />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                <input type="password" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
              </div>
            </div>

            <AlertBanner
              variant="warning"
              message="Your password was last changed 6 months ago. Consider updating it."
              :show-icon="true"
            />
          </div>
        </div>
      </div>
    `,
  }),
}

// Rich content
export const RichContent: Story = {
  render: () => ({
    components: { AlertBanner },
    template: `
      <AlertBanner variant="success" :show-icon="true">
        <template #title>
          <span class="flex items-center gap-2">
            Deployment Successful
            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
              v2.5.0
            </span>
          </span>
        </template>
        <template #default>
          <div>
            <p>Your application has been successfully deployed to production.</p>
            <div class="mt-2 space-y-1 text-sm">
              <p>• Build time: 2m 34s</p>
              <p>• Deploy time: 45s</p>
              <p>• Status: Active</p>
            </div>
          </div>
        </template>
        <template #actions>
          <div class="flex gap-3">
            <button class="text-sm font-medium text-green-700 hover:text-green-800">
              View Deployment →
            </button>
            <button class="text-sm font-medium text-green-700 hover:text-green-800">
              Release Notes →
            </button>
          </div>
        </template>
      </AlertBanner>
    `,
  }),
}

// Interactive
export const Interactive: Story = {
  render: (args) => ({
    components: { AlertBanner },
    setup() {
      const showAlert = ref(true)
      return { args, showAlert }
    },
    template: `
      <div>
        <AlertBanner
          v-if="showAlert"
          v-bind="args"
          @close="showAlert = false"
        />
        <button
          v-if="!showAlert"
          @click="showAlert = true"
          class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
        >
          Show Alert
        </button>
      </div>
    `,
  }),
  args: {
    variant: 'success',
    title: 'Success!',
    message: 'Your operation completed successfully.',
    closable: true,
  },
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { AlertBanner },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Variants (Filled)</h3>
          <div class="space-y-3">
            <AlertBanner variant="success" title="Success" message="Operation completed successfully" />
            <AlertBanner variant="warning" title="Warning" message="Please review before proceeding" />
            <AlertBanner variant="danger" title="Error" message="Something went wrong" />
            <AlertBanner variant="info" title="Info" message="Here's some information" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Variants (Outlined)</h3>
          <div class="space-y-3">
            <AlertBanner variant="success" title="Success" message="Outlined style" style="outlined" />
            <AlertBanner variant="warning" title="Warning" message="Outlined style" style="outlined" />
            <AlertBanner variant="danger" title="Error" message="Outlined style" style="outlined" />
            <AlertBanner variant="info" title="Info" message="Outlined style" style="outlined" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Close Button</h3>
          <AlertBanner
            variant="info"
            title="Dismissible"
            message="Click the X to close this alert"
            closable
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Without Icon</h3>
          <AlertBanner
            variant="warning"
            title="No Icon"
            message="This alert doesn't have an icon"
            :show-icon="false"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Actions</h3>
          <AlertBanner
            variant="success"
            title="Action Required"
            message="Please confirm your email address"
          >
            <template #actions>
              <button class="px-3 py-1.5 text-sm font-medium text-green-700 bg-green-100 rounded-md hover:bg-green-200">
                Confirm Email
              </button>
            </template>
          </AlertBanner>
        </div>
      </div>
    `,
  }),
}
