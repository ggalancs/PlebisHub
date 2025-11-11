import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import Toast from './Toast.vue'
import Button from '../atoms/Button.vue'

const meta = {
  title: 'Molecules/Toast',
  component: Toast,
  tags: ['autodocs'],
  argTypes: {
    variant: { control: 'select', options: ['success', 'warning', 'danger', 'info'] },
    title: { control: 'text' },
    message: { control: 'text' },
    showIcon: { control: 'boolean' },
    icon: { control: 'text' },
    closable: { control: 'boolean' },
    duration: { control: 'number' },
    showProgress: { control: 'boolean' },
  },
  args: {
    variant: 'info',
    message: 'This is a notification message',
    showIcon: true,
    closable: true,
    duration: 5000,
    showProgress: true,
  },
} satisfies Meta<typeof Toast>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: (args) => ({
    components: { Toast },
    setup() {
      return { args }
    },
    template: '<Toast v-bind="args" />',
  }),
}

export const Variants: Story = {
  render: () => ({
    components: { Toast },
    template: `
      <div class="space-y-4">
        <Toast
          variant="success"
          title="Success"
          message="Your changes have been saved successfully"
          :duration="0"
        />

        <Toast
          variant="warning"
          title="Warning"
          message="This action cannot be undone"
          :duration="0"
        />

        <Toast
          variant="danger"
          title="Error"
          message="Failed to save changes. Please try again"
          :duration="0"
        />

        <Toast
          variant="info"
          title="Information"
          message="New updates are available for your system"
          :duration="0"
        />
      </div>
    `,
  }),
}

export const WithoutTitle: Story = {
  render: () => ({
    components: { Toast },
    template: `
      <div class="space-y-4">
        <Toast
          variant="success"
          message="Operation completed successfully"
          :duration="0"
        />

        <Toast
          variant="info"
          message="Check your email for verification link"
          :duration="0"
        />
      </div>
    `,
  }),
}

export const WithoutIcon: Story = {
  render: () => ({
    components: { Toast },
    template: `
      <div class="space-y-4">
        <Toast
          title="Notification"
          message="This toast has no icon"
          :show-icon="false"
          :duration="0"
        />
      </div>
    `,
  }),
}

export const CustomIcon: Story = {
  render: () => ({
    components: { Toast },
    template: `
      <div class="space-y-4">
        <Toast
          variant="success"
          title="Achievement Unlocked"
          message="You've earned a new badge!"
          icon="award"
          :duration="0"
        />

        <Toast
          variant="info"
          title="New Message"
          message="You have 3 unread messages"
          icon="mail"
          :duration="0"
        />

        <Toast
          variant="warning"
          title="Low Storage"
          message="You're running out of storage space"
          icon="hard-drive"
          :duration="0"
        />
      </div>
    `,
  }),
}

export const NotClosable: Story = {
  render: () => ({
    components: { Toast },
    template: `
      <Toast
        variant="info"
        title="System Update"
        message="A system update is in progress. Please do not close this window."
        :closable="false"
        :duration="0"
      />
    `,
  }),
}

export const WithoutProgress: Story = {
  render: () => ({
    components: { Toast },
    template: `
      <Toast
        variant="success"
        title="Success"
        message="This toast has no progress bar"
        :show-progress="false"
        :duration="3000"
      />
    `,
  }),
}

export const DifferentDurations: Story = {
  render: () => ({
    components: { Toast },
    setup() {
      const showToasts = ref(true)
      const resetToasts = () => {
        showToasts.value = false
        setTimeout(() => {
          showToasts.value = true
        }, 100)
      }
      return { showToasts, resetToasts }
    },
    template: `
      <div>
        <div class="mb-4">
          <button
            @click="resetToasts"
            class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700"
          >
            Reset Toasts
          </button>
        </div>

        <div v-if="showToasts" class="space-y-4">
          <Toast
            variant="success"
            message="2 seconds (fast)"
            :duration="2000"
          />

          <Toast
            variant="info"
            message="5 seconds (default)"
            :duration="5000"
          />

          <Toast
            variant="warning"
            message="10 seconds (slow)"
            :duration="10000"
          />

          <Toast
            variant="danger"
            message="Persistent (no auto-dismiss)"
            :duration="0"
          />
        </div>
      </div>
    `,
  }),
}

export const Interactive: Story = {
  render: () => ({
    components: { Toast, Button },
    setup() {
      const toasts = ref<Array<{ id: number; variant: string; message: string }>>([])
      let nextId = 1

      const addToast = (variant: string, message: string) => {
        toasts.value.push({ id: nextId++, variant, message })
      }

      const removeToast = (id: number) => {
        const index = toasts.value.findIndex((t) => t.id === id)
        if (index > -1) {
          toasts.value.splice(index, 1)
        }
      }

      return { toasts, addToast, removeToast }
    },
    template: `
      <div>
        <div class="flex gap-2 mb-4">
          <Button size="sm" @click="addToast('success', 'Operation successful!')">
            Show Success
          </Button>
          <Button size="sm" variant="secondary" @click="addToast('warning', 'Warning: Check your input')">
            Show Warning
          </Button>
          <Button size="sm" variant="danger" @click="addToast('danger', 'Error: Something went wrong')">
            Show Error
          </Button>
          <Button size="sm" variant="secondary" @click="addToast('info', 'Info: New update available')">
            Show Info
          </Button>
        </div>

        <div class="space-y-2">
          <Toast
            v-for="toast in toasts"
            :key="toast.id"
            :variant="toast.variant"
            :message="toast.message"
            :duration="5000"
            @close="removeToast(toast.id)"
          />
        </div>
      </div>
    `,
  }),
}

export const RealWorldExamples: Story = {
  render: () => ({
    components: { Toast },
    template: `
      <div class="space-y-4">
        <Toast
          variant="success"
          title="Profile Updated"
          message="Your profile information has been saved successfully"
          :duration="0"
        />

        <Toast
          variant="info"
          title="New Feature Available"
          message="We've added dark mode support. Try it now in settings!"
          icon="moon"
          :duration="0"
        />

        <Toast
          variant="warning"
          title="Password Expiring Soon"
          message="Your password will expire in 3 days. Please update it"
          :duration="0"
        />

        <Toast
          variant="danger"
          title="Payment Failed"
          message="Unable to process payment. Please check your card details"
          :duration="0"
        />

        <Toast
          variant="success"
          title="File Uploaded"
          message="document.pdf (2.4 MB) uploaded successfully"
          icon="upload"
          :duration="0"
        />

        <Toast
          variant="info"
          title="Background Sync"
          message="Your files are being synced in the background"
          icon="refresh-cw"
          :closable="false"
          :show-progress="false"
          :duration="0"
        />
      </div>
    `,
  }),
}

export const LongMessage: Story = {
  render: () => ({
    components: { Toast },
    template: `
      <Toast
        variant="info"
        title="Terms and Conditions Updated"
        message="We've updated our terms and conditions to provide better clarity on data usage, privacy policies, and user rights. Please review the changes in your account settings."
        :duration="0"
      />
    `,
  }),
}

export const MinimalToast: Story = {
  render: () => ({
    components: { Toast },
    template: `
      <Toast
        message="Quick notification"
        :show-icon="false"
        :closable="false"
        :show-progress="false"
        :duration="0"
      />
    `,
  }),
}

export const PositionedToasts: Story = {
  render: () => ({
    components: { Toast, Button },
    setup() {
      const positions = ref({
        'top-left': false,
        'top-center': false,
        'top-right': false,
        'bottom-left': false,
        'bottom-center': false,
        'bottom-right': false,
      })

      const showToast = (position: string) => {
        positions.value[position as keyof typeof positions.value] = true
      }

      return { positions, showToast }
    },
    template: `
      <div>
        <div class="mb-8 space-y-2">
          <div class="flex gap-2 justify-center">
            <Button size="sm" @click="showToast('top-left')">Top Left</Button>
            <Button size="sm" @click="showToast('top-center')">Top Center</Button>
            <Button size="sm" @click="showToast('top-right')">Top Right</Button>
          </div>
          <div class="flex gap-2 justify-center">
            <Button size="sm" @click="showToast('bottom-left')">Bottom Left</Button>
            <Button size="sm" @click="showToast('bottom-center')">Bottom Center</Button>
            <Button size="sm" @click="showToast('bottom-right')">Bottom Right</Button>
          </div>
        </div>

        <!-- Top Left -->
        <div v-if="positions['top-left']" class="fixed top-4 left-4 z-50">
          <Toast
            variant="success"
            message="Toast positioned at top left"
            @close="positions['top-left'] = false"
          />
        </div>

        <!-- Top Center -->
        <div v-if="positions['top-center']" class="fixed top-4 left-1/2 -translate-x-1/2 z-50">
          <Toast
            variant="info"
            message="Toast positioned at top center"
            @close="positions['top-center'] = false"
          />
        </div>

        <!-- Top Right -->
        <div v-if="positions['top-right']" class="fixed top-4 right-4 z-50">
          <Toast
            variant="warning"
            message="Toast positioned at top right"
            @close="positions['top-right'] = false"
          />
        </div>

        <!-- Bottom Left -->
        <div v-if="positions['bottom-left']" class="fixed bottom-4 left-4 z-50">
          <Toast
            variant="danger"
            message="Toast positioned at bottom left"
            @close="positions['bottom-left'] = false"
          />
        </div>

        <!-- Bottom Center -->
        <div v-if="positions['bottom-center']" class="fixed bottom-4 left-1/2 -translate-x-1/2 z-50">
          <Toast
            variant="success"
            message="Toast positioned at bottom center"
            @close="positions['bottom-center'] = false"
          />
        </div>

        <!-- Bottom Right -->
        <div v-if="positions['bottom-right']" class="fixed bottom-4 right-4 z-50">
          <Toast
            variant="info"
            message="Toast positioned at bottom right"
            @close="positions['bottom-right'] = false"
          />
        </div>
      </div>
    `,
  }),
}
