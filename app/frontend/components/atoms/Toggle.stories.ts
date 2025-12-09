import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Toggle from './Toggle.vue'

const meta = {
  title: 'Atoms/Toggle',
  component: Toggle,
  tags: ['autodocs'],
  argTypes: {
    modelValue: {
      control: 'boolean',
      description: 'Toggle state (checked/unchecked)',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Toggle size',
    },
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'success', 'danger', 'warning', 'info'],
      description: 'Color variant when enabled',
    },
    label: {
      control: 'text',
      description: 'Label text',
    },
    labelPosition: {
      control: 'select',
      options: ['left', 'right'],
      description: 'Label position',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    error: {
      control: 'text',
      description: 'Error message',
    },
    helperText: {
      control: 'text',
      description: 'Helper text',
    },
  },
  args: {
    modelValue: false,
    size: 'md',
    variant: 'primary',
    labelPosition: 'right',
    disabled: false,
  },
} satisfies Meta<typeof Toggle>

export default meta
type Story = StoryObj<typeof meta>

// Default toggle
export const Default: Story = {
  args: {
    label: 'Enable notifications',
  },
}

// All sizes
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
      <div class="space-y-4">
        <Toggle v-model="small" size="sm" label="Small toggle" />
        <Toggle v-model="medium" size="md" label="Medium toggle" />
        <Toggle v-model="large" size="lg" label="Large toggle" />
      </div>
    `,
  }),
}

// All variants
export const AllVariants: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const primary = ref(true)
      const secondary = ref(true)
      const success = ref(true)
      const danger = ref(true)
      const warning = ref(true)
      const info = ref(true)
      return { primary, secondary, success, danger, warning, info }
    },
    template: `
      <div class="space-y-4">
        <Toggle v-model="primary" variant="primary" label="Primary" />
        <Toggle v-model="secondary" variant="secondary" label="Secondary" />
        <Toggle v-model="success" variant="success" label="Success" />
        <Toggle v-model="danger" variant="danger" label="Danger" />
        <Toggle v-model="warning" variant="warning" label="Warning" />
        <Toggle v-model="info" variant="info" label="Info" />
      </div>
    `,
  }),
}

// Label positions
export const LabelPositions: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const left = ref(true)
      const right = ref(true)
      return { left, right }
    },
    template: `
      <div class="space-y-4">
        <Toggle v-model="left" label="Label on left" label-position="left" />
        <Toggle v-model="right" label="Label on right" label-position="right" />
      </div>
    `,
  }),
}

// With helper text
export const WithHelperText: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const enabled = ref(false)
      return { enabled }
    },
    template: `
      <Toggle
        v-model="enabled"
        label="Enable two-factor authentication"
        helper-text="Add an extra layer of security to your account"
      />
    `,
  }),
}

// With error
export const WithError: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const enabled = ref(false)
      return { enabled }
    },
    template: `
      <Toggle
        v-model="enabled"
        label="Accept terms and conditions"
        error="You must accept the terms to continue"
      />
    `,
  }),
}

// Disabled state
export const Disabled: Story = {
  render: () => ({
    components: { Toggle },
    template: `
      <div class="space-y-4">
        <Toggle :model-value="false" disabled label="Disabled (off)" />
        <Toggle :model-value="true" disabled label="Disabled (on)" />
      </div>
    `,
  }),
}

// Settings panel
export const SettingsPanel: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const notifications = ref(true)
      const emailUpdates = ref(true)
      const smsAlerts = ref(false)
      const darkMode = ref(false)
      const autoSave = ref(true)
      return { notifications, emailUpdates, smsAlerts, darkMode, autoSave }
    },
    template: `
      <div class="max-w-md border border-gray-200 rounded-lg p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Settings</h3>
        <div class="space-y-4">
          <div class="py-3 border-b border-gray-200">
            <Toggle
              v-model="notifications"
              label="Push Notifications"
              helper-text="Receive notifications on your device"
            />
          </div>
          <div class="py-3 border-b border-gray-200">
            <Toggle
              v-model="emailUpdates"
              label="Email Updates"
              helper-text="Get updates via email"
            />
          </div>
          <div class="py-3 border-b border-gray-200">
            <Toggle
              v-model="smsAlerts"
              label="SMS Alerts"
              helper-text="Receive important alerts via SMS"
            />
          </div>
          <div class="py-3 border-b border-gray-200">
            <Toggle
              v-model="darkMode"
              label="Dark Mode"
              helper-text="Switch to dark theme"
            />
          </div>
          <div class="py-3">
            <Toggle
              v-model="autoSave"
              label="Auto-save"
              helper-text="Automatically save your work"
            />
          </div>
        </div>
      </div>
    `,
  }),
}

// Privacy settings
export const PrivacySettings: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const profilePublic = ref(true)
      const showEmail = ref(false)
      const allowMessages = ref(true)
      const twoFactor = ref(false)
      return { profilePublic, showEmail, allowMessages, twoFactor }
    },
    template: `
      <div class="max-w-md border border-gray-200 rounded-lg p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Privacy Settings</h3>
        <div class="space-y-6">
          <Toggle
            v-model="profilePublic"
            label="Public Profile"
            helper-text="Make your profile visible to everyone"
            variant="success"
          />
          <Toggle
            v-model="showEmail"
            label="Show Email Address"
            helper-text="Display your email on your profile"
            variant="info"
          />
          <Toggle
            v-model="allowMessages"
            label="Allow Messages"
            helper-text="Let other users send you messages"
            variant="primary"
          />
          <Toggle
            v-model="twoFactor"
            label="Two-Factor Authentication"
            helper-text="Recommended for enhanced security"
            variant="warning"
          />
        </div>
      </div>
    `,
  }),
}

// Feature toggles
export const FeatureToggles: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const betaFeatures = ref(false)
      const analytics = ref(true)
      const advancedMode = ref(false)
      const debugMode = ref(false)
      return { betaFeatures, analytics, advancedMode, debugMode }
    },
    template: `
      <div class="max-w-md border border-gray-200 rounded-lg p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Feature Toggles</h3>
        <div class="space-y-6">
          <Toggle
            v-model="betaFeatures"
            label="Beta Features"
            helper-text="Enable experimental features (may be unstable)"
            variant="info"
            size="lg"
          />
          <Toggle
            v-model="analytics"
            label="Analytics"
            helper-text="Help us improve by sharing usage data"
            variant="success"
            size="lg"
          />
          <Toggle
            v-model="advancedMode"
            label="Advanced Mode"
            helper-text="Show advanced options and settings"
            variant="warning"
            size="lg"
          />
          <Toggle
            v-model="debugMode"
            label="Debug Mode"
            helper-text="Enable debugging tools (developers only)"
            variant="danger"
            size="lg"
          />
        </div>
      </div>
    `,
  }),
}

// Compact list
export const CompactList: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const items = ref([
        { id: 1, label: 'WiFi', enabled: true },
        { id: 2, label: 'Bluetooth', enabled: true },
        { id: 3, label: 'Location', enabled: false },
        { id: 4, label: 'Airplane Mode', enabled: false },
      ])
      return { items }
    },
    template: `
      <div class="max-w-xs border border-gray-200 rounded-lg divide-y divide-gray-200">
        <div
          v-for="item in items"
          :key="item.id"
          class="px-4 py-3 flex items-center justify-between"
        >
          <span class="text-sm font-medium text-gray-900">{{ item.label }}</span>
          <Toggle v-model="item.enabled" size="sm" />
        </div>
      </div>
    `,
  }),
}

// Form integration
export const FormIntegration: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const form = ref({
        newsletter: false,
        terms: false,
        privacy: false,
        marketing: false,
      })

      const errors = ref({
        terms: '',
        privacy: '',
      })

      const validateAndSubmit = () => {
        errors.value.terms = form.value.terms ? '' : 'You must accept the terms of service'
        errors.value.privacy = form.value.privacy ? '' : 'You must accept the privacy policy'

        if (!errors.value.terms && !errors.value.privacy) {
          alert('Form submitted successfully!')
        }
      }

      return { form, errors, validateAndSubmit }
    },
    template: `
      <div class="max-w-md border border-gray-200 rounded-lg p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Sign Up</h3>
        <div class="space-y-6">
          <Toggle
            v-model="form.newsletter"
            label="Subscribe to newsletter"
            helper-text="Get weekly updates and news"
          />

          <Toggle
            v-model="form.terms"
            label="I accept the Terms of Service"
            :error="errors.terms"
            variant="danger"
          />

          <Toggle
            v-model="form.privacy"
            label="I accept the Privacy Policy"
            :error="errors.privacy"
            variant="danger"
          />

          <Toggle
            v-model="form.marketing"
            label="Send me marketing emails"
            helper-text="We'll send you promotional content"
          />

          <button
            @click="validateAndSubmit"
            class="w-full px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 transition-colors"
          >
            Sign Up
          </button>
        </div>
      </div>
    `,
  }),
}

// Permissions
export const Permissions: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const permissions = ref({
        read: true,
        write: true,
        delete: false,
        admin: false,
      })
      return { permissions }
    },
    template: `
      <div class="max-w-md border border-gray-200 rounded-lg p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">User Permissions</h3>
        <div class="space-y-4">
          <Toggle
            v-model="permissions.read"
            label="Read Access"
            helper-text="View content and files"
            variant="info"
            label-position="left"
          />
          <Toggle
            v-model="permissions.write"
            label="Write Access"
            helper-text="Create and edit content"
            variant="primary"
            label-position="left"
          />
          <Toggle
            v-model="permissions.delete"
            label="Delete Access"
            helper-text="Remove content and files"
            variant="warning"
            label-position="left"
          />
          <Toggle
            v-model="permissions.admin"
            label="Admin Access"
            helper-text="Full system access"
            variant="danger"
            label-position="left"
          />
        </div>
      </div>
    `,
  }),
}

// Without labels
export const WithoutLabels: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const toggle1 = ref(true)
      const toggle2 = ref(false)
      const toggle3 = ref(true)
      return { toggle1, toggle2, toggle3 }
    },
    template: `
      <div class="flex items-center gap-4">
        <Toggle v-model="toggle1" size="sm" />
        <Toggle v-model="toggle2" size="md" />
        <Toggle v-model="toggle3" size="lg" />
      </div>
    `,
  }),
}

// Interactive
export const Interactive: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const enabled = ref(false)
      return { enabled }
    },
    template: `
      <div class="space-y-4">
        <Toggle
          v-model="enabled"
          label="Enable feature"
          helper-text="Toggle to see the state change"
          variant="primary"
          size="lg"
        />
        <div class="p-4 bg-gray-50 rounded-md">
          <p class="text-sm text-gray-700">
            Current state: <strong>{{ enabled ? 'Enabled' : 'Disabled' }}</strong>
          </p>
        </div>
      </div>
    `,
  }),
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Toggle },
    setup() {
      const values = ref({
        size1: true,
        size2: true,
        size3: true,
        variant1: true,
        variant2: true,
        variant3: true,
        variant4: true,
        setting1: true,
        setting2: false,
      })
      return { values }
    },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="space-y-3">
            <Toggle v-model="values.size1" size="sm" label="Small" />
            <Toggle v-model="values.size2" size="md" label="Medium" />
            <Toggle v-model="values.size3" size="lg" label="Large" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Variants</h3>
          <div class="space-y-3">
            <Toggle v-model="values.variant1" variant="primary" label="Primary" />
            <Toggle v-model="values.variant2" variant="success" label="Success" />
            <Toggle v-model="values.variant3" variant="danger" label="Danger" />
            <Toggle v-model="values.variant4" variant="warning" label="Warning" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Helper Text</h3>
          <Toggle
            v-model="values.setting1"
            label="Enable notifications"
            helper-text="Receive push notifications on your device"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Disabled</h3>
          <div class="space-y-3">
            <Toggle :model-value="false" disabled label="Disabled (off)" />
            <Toggle :model-value="true" disabled label="Disabled (on)" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Error</h3>
          <Toggle
            v-model="values.setting2"
            label="Accept terms"
            error="You must accept the terms to continue"
          />
        </div>
      </div>
    `,
  }),
}
