import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import Toggle from './Toggle.vue'

const meta = {
  title: 'Molecules/Toggle',
  component: Toggle,
  tags: ['autodocs'],
} satisfies Meta<typeof Toggle>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const enabled = ref(false)
      return { enabled }
    },
    template: '<Toggle v-model="enabled" label="Toggle" />',
  }),
}

export const Enabled: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const enabled = ref(true)
      return { enabled }
    },
    template: '<Toggle v-model="enabled" label="Enabled" />',
  }),
}

export const WithLabel: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const enabled = ref(false)
      return { enabled }
    },
    template: `
      <div class="flex items-center gap-3">
        <Toggle v-model="enabled" label="Enable notifications" />
        <span class="text-sm text-gray-700">Enable notifications</span>
      </div>
    `,
  }),
}

export const AllSizes: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const small = ref(true)
      const medium = ref(true)
      const large = ref(true)
      return { small, medium, large }
    },
    template: `
      <div class="flex items-center gap-6">
        <Toggle v-model="small" size="sm" label="Small" />
        <Toggle v-model="medium" size="md" label="Medium" />
        <Toggle v-model="large" size="lg" label="Large" />
      </div>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const primary = ref(true)
      const success = ref(true)
      const warning = ref(true)
      const danger = ref(true)
      return { primary, success, warning, danger }
    },
    template: `
      <div class="space-y-4">
        <div class="flex items-center gap-3">
          <Toggle v-model="primary" variant="primary" label="Primary" />
          <span class="text-sm">Primary</span>
        </div>
        <div class="flex items-center gap-3">
          <Toggle v-model="success" variant="success" label="Success" />
          <span class="text-sm">Success</span>
        </div>
        <div class="flex items-center gap-3">
          <Toggle v-model="warning" variant="warning" label="Warning" />
          <span class="text-sm">Warning</span>
        </div>
        <div class="flex items-center gap-3">
          <Toggle v-model="danger" variant="danger" label="Danger" />
          <span class="text-sm">Danger</span>
        </div>
      </div>
    `,
  }),
}

export const WithIcons: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const enabled = ref(true)
      return { enabled }
    },
    template: '<Toggle v-model="enabled" show-icon label="With icons" />',
  }),
}

export const Disabled: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const off = ref(false)
      const on = ref(true)
      return { off, on }
    },
    template: `
      <div class="flex items-center gap-6">
        <Toggle v-model="off" disabled label="Disabled off" />
        <Toggle v-model="on" disabled label="Disabled on" />
      </div>
    `,
  }),
}

export const SettingsForm: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const notifications = ref(true)
      const marketing = ref(false)
      const updates = ref(true)
      return { notifications, marketing, updates }
    },
    template: `
      <div class="space-y-4 max-w-md">
        <div class="flex items-center justify-between py-3 border-b">
          <div>
            <div class="font-medium">Email Notifications</div>
            <div class="text-sm text-gray-600">Receive email about your account activity</div>
          </div>
          <Toggle v-model="notifications" label="Email notifications" />
        </div>
        <div class="flex items-center justify-between py-3 border-b">
          <div>
            <div class="font-medium">Marketing Emails</div>
            <div class="text-sm text-gray-600">Receive emails about new products and features</div>
          </div>
          <Toggle v-model="marketing" label="Marketing emails" />
        </div>
        <div class="flex items-center justify-between py-3">
          <div>
            <div class="font-medium">Product Updates</div>
            <div class="text-sm text-gray-600">Get notified when we ship new features</div>
          </div>
          <Toggle v-model="updates" label="Product updates" />
        </div>
      </div>
    `,
  }),
}
