import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import FormField from './FormField.vue'

const meta = {
  title: 'Molecules/FormField',
  component: FormField,
  tags: ['autodocs'],
  argTypes: {
    label: {
      control: 'text',
      description: 'Field label',
    },
    required: {
      control: 'boolean',
      description: 'Required field indicator',
    },
    type: {
      control: 'select',
      options: ['text', 'email', 'password', 'number', 'tel', 'url', 'search', 'date'],
      description: 'Input type',
    },
    placeholder: {
      control: 'text',
      description: 'Placeholder text',
    },
    helperText: {
      control: 'text',
      description: 'Helper text',
    },
    error: {
      control: 'text',
      description: 'Error message',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    readonly: {
      control: 'boolean',
      description: 'Readonly state',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Field size',
    },
    layout: {
      control: 'select',
      options: ['vertical', 'horizontal'],
      description: 'Field layout',
    },
  },
  args: {
    label: 'Field Label',
    required: false,
    type: 'text',
    disabled: false,
    readonly: false,
    size: 'md',
    layout: 'vertical',
  },
} satisfies Meta<typeof FormField>

export default meta
type Story = StoryObj<typeof meta>

// Default form field
export const Default: Story = {
  args: {
    label: 'Username',
    placeholder: 'Enter your username',
  },
}

// With helper text
export const WithHelperText: Story = {
  args: {
    label: 'Email',
    type: 'email',
    placeholder: 'you@example.com',
    helperText: 'We will never share your email with anyone',
  },
}

// Required field
export const Required: Story = {
  args: {
    label: 'Full Name',
    required: true,
    placeholder: 'John Doe',
  },
}

// With error
export const WithError: Story = {
  args: {
    label: 'Email',
    type: 'email',
    required: true,
    modelValue: 'invalid-email',
    error: 'Please enter a valid email address',
  },
}

// Different sizes
export const AllSizes: Story = {
  render: () => ({
    components: { FormField },
    template: `
      <div class="space-y-6">
        <FormField label="Small" size="sm" placeholder="Small input" />
        <FormField label="Medium (default)" size="md" placeholder="Medium input" />
        <FormField label="Large" size="lg" placeholder="Large input" />
      </div>
    `,
  }),
}

// Different input types
export const InputTypes: Story = {
  render: () => ({
    components: { FormField },
    template: `
      <div class="space-y-6">
        <FormField label="Text" type="text" placeholder="Enter text" />
        <FormField label="Email" type="email" placeholder="you@example.com" />
        <FormField label="Password" type="password" placeholder="Enter password" show-password-toggle />
        <FormField label="Number" type="number" placeholder="Enter number" />
        <FormField label="Telephone" type="tel" placeholder="+1 (555) 000-0000" />
        <FormField label="URL" type="url" placeholder="https://example.com" />
        <FormField label="Date" type="date" />
      </div>
    `,
  }),
}

// Disabled and readonly
export const States: Story = {
  render: () => ({
    components: { FormField },
    template: `
      <div class="space-y-6">
        <FormField label="Normal" placeholder="Normal state" />
        <FormField label="Disabled" disabled placeholder="Disabled state" model-value="Cannot edit" />
        <FormField label="Readonly" readonly model-value="Read only value" />
      </div>
    `,
  }),
}

// Horizontal layout
export const HorizontalLayout: Story = {
  render: () => ({
    components: { FormField },
    template: `
      <div class="space-y-6 max-w-2xl">
        <FormField label="Username" layout="horizontal" placeholder="Enter username" />
        <FormField label="Email" type="email" layout="horizontal" placeholder="you@example.com" />
        <FormField
          label="Password"
          type="password"
          layout="horizontal"
          placeholder="Enter password"
          show-password-toggle
        />
      </div>
    `,
  }),
}

// With prefix and suffix
export const WithPrefixSuffix: Story = {
  render: () => ({
    components: { FormField },
    template: `
      <div class="space-y-6">
        <FormField label="Website" type="url" placeholder="example.com">
          <template #prefix>
            <span class="text-gray-500">https://</span>
          </template>
        </FormField>

        <FormField label="Price" type="number" placeholder="0.00">
          <template #prefix>
            <span class="text-gray-500">$</span>
          </template>
          <template #suffix>
            <span class="text-gray-500">USD</span>
          </template>
        </FormField>

        <FormField label="Search" type="search" placeholder="Search...">
          <template #prefix>
            <svg class="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </template>
        </FormField>
      </div>
    `,
  }),
}

// Login form
export const LoginForm: Story = {
  render: () => ({
    components: { FormField },
    setup() {
      const email = ref('')
      const password = ref('')
      const errors = ref({ email: '', password: '' })

      const handleSubmit = () => {
        errors.value = { email: '', password: '' }

        if (!email.value) {
          errors.value.email = 'Email is required'
        } else if (!email.value.includes('@')) {
          errors.value.email = 'Please enter a valid email'
        }

        if (!password.value) {
          errors.value.password = 'Password is required'
        } else if (password.value.length < 8) {
          errors.value.password = 'Password must be at least 8 characters'
        }

        if (!errors.value.email && !errors.value.password) {
          alert('Login successful!')
        }
      }

      return { email, password, errors, handleSubmit }
    },
    template: `
      <div class="max-w-md border border-gray-200 rounded-lg p-6">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Sign In</h2>
        <div class="space-y-4">
          <FormField
            v-model="email"
            label="Email"
            type="email"
            required
            placeholder="you@example.com"
            :error="errors.email"
          />
          <FormField
            v-model="password"
            label="Password"
            type="password"
            required
            placeholder="Enter your password"
            :error="errors.password"
            show-password-toggle
          />
          <button
            @click="handleSubmit"
            class="w-full px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 transition-colors"
          >
            Sign In
          </button>
        </div>
      </div>
    `,
  }),
}

// Registration form
export const RegistrationForm: Story = {
  render: () => ({
    components: { FormField },
    setup() {
      const form = ref({
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        password: '',
        confirmPassword: '',
      })

      return { form }
    },
    template: `
      <div class="max-w-2xl border border-gray-200 rounded-lg p-6">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Create Account</h2>
        <div class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <FormField
              v-model="form.firstName"
              label="First Name"
              required
              placeholder="John"
            />
            <FormField
              v-model="form.lastName"
              label="Last Name"
              required
              placeholder="Doe"
            />
          </div>

          <FormField
            v-model="form.email"
            label="Email Address"
            type="email"
            required
            placeholder="you@example.com"
            helper-text="We'll never share your email"
          />

          <FormField
            v-model="form.phone"
            label="Phone Number"
            type="tel"
            placeholder="+1 (555) 000-0000"
          />

          <FormField
            v-model="form.password"
            label="Password"
            type="password"
            required
            placeholder="Create a password"
            helper-text="Must be at least 8 characters"
            show-password-toggle
          />

          <FormField
            v-model="form.confirmPassword"
            label="Confirm Password"
            type="password"
            required
            placeholder="Confirm your password"
            show-password-toggle
          />

          <button
            class="w-full px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 transition-colors"
          >
            Create Account
          </button>
        </div>
      </div>
    `,
  }),
}

// Profile settings form
export const ProfileSettings: Story = {
  render: () => ({
    components: { FormField },
    setup() {
      const profile = ref({
        username: 'johndoe',
        email: 'john@example.com',
        bio: 'Software developer',
        website: 'https://johndoe.com',
      })

      return { profile }
    },
    template: `
      <div class="max-w-2xl border border-gray-200 rounded-lg p-6">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">Profile Settings</h2>
        <div class="space-y-6">
          <FormField
            v-model="profile.username"
            label="Username"
            required
            helper-text="This is your public username"
            layout="horizontal"
          />

          <FormField
            v-model="profile.email"
            label="Email"
            type="email"
            required
            helper-text="Your email address"
            layout="horizontal"
          />

          <FormField
            v-model="profile.bio"
            label="Bio"
            placeholder="Tell us about yourself"
            helper-text="Brief description for your profile"
            layout="horizontal"
          />

          <FormField
            v-model="profile.website"
            label="Website"
            type="url"
            placeholder="https://example.com"
            layout="horizontal"
          >
            <template #prefix>
              <svg class="h-5 w-5 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9" />
              </svg>
            </template>
          </FormField>

          <div class="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <button class="px-4 py-2 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50">
              Cancel
            </button>
            <button class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700">
              Save Changes
            </button>
          </div>
        </div>
      </div>
    `,
  }),
}

// Validation example
export const WithValidation: Story = {
  render: () => ({
    components: { FormField },
    setup() {
      const email = ref('')
      const emailError = ref('')

      const validateEmail = () => {
        if (!email.value) {
          emailError.value = 'Email is required'
        } else if (!email.value.includes('@')) {
          emailError.value = 'Please enter a valid email address'
        } else {
          emailError.value = ''
        }
      }

      return { email, emailError, validateEmail }
    },
    template: `
      <div class="max-w-md">
        <FormField
          v-model="email"
          label="Email Address"
          type="email"
          required
          placeholder="you@example.com"
          :error="emailError"
          @blur="validateEmail"
        />
      </div>
    `,
  }),
}

// Interactive
export const Interactive: Story = {
  render: (args) => ({
    components: { FormField },
    setup() {
      const value = ref('')
      return { args, value }
    },
    template: `
      <div class="space-y-4">
        <FormField v-bind="args" v-model="value" />
        <div class="p-4 bg-gray-50 rounded-md">
          <p class="text-sm text-gray-700">Current value: <strong>{{ value || '(empty)' }}</strong></p>
        </div>
      </div>
    `,
  }),
  args: {
    label: 'Username',
    required: true,
    placeholder: 'Enter your username',
    helperText: 'This will be your public username',
  },
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { FormField },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Basic Fields</h3>
          <div class="space-y-4">
            <FormField label="Text Input" placeholder="Enter text" />
            <FormField label="Required Field" required placeholder="This field is required" />
            <FormField label="With Helper Text" placeholder="Enter value" helper-text="This is some helpful text" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Input Types</h3>
          <div class="space-y-4">
            <FormField label="Email" type="email" placeholder="you@example.com" />
            <FormField label="Password" type="password" placeholder="Enter password" show-password-toggle />
            <FormField label="Number" type="number" placeholder="0" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">States</h3>
          <div class="space-y-4">
            <FormField label="Normal" placeholder="Normal state" />
            <FormField label="With Error" error="This field has an error" model-value="Invalid value" />
            <FormField label="Disabled" disabled placeholder="Disabled" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Layouts</h3>
          <div class="space-y-4">
            <FormField label="Vertical Layout" layout="vertical" placeholder="Default layout" />
            <FormField label="Horizontal" layout="horizontal" placeholder="Side by side" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Prefix/Suffix</h3>
          <div class="space-y-4">
            <FormField label="Price" type="number" placeholder="0.00">
              <template #prefix>
                <span class="text-gray-500">$</span>
              </template>
              <template #suffix>
                <span class="text-gray-500">USD</span>
              </template>
            </FormField>
          </div>
        </div>
      </div>
    `,
  }),
}
