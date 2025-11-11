import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import Input from './Input.vue'

const meta = {
  title: 'Atoms/Input',
  component: Input,
  tags: ['autodocs'],
  argTypes: {
    type: {
      control: 'select',
      options: ['text', 'email', 'password', 'number', 'tel', 'url', 'search', 'date'],
      description: 'Input type',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Input size',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    readonly: {
      control: 'boolean',
      description: 'Read-only state',
    },
    required: {
      control: 'boolean',
      description: 'Required field',
    },
    fullWidth: {
      control: 'boolean',
      description: 'Full width',
    },
    showPasswordToggle: {
      control: 'boolean',
      description: 'Show password toggle (for password type)',
    },
  },
  args: {
    type: 'text',
    size: 'md',
    disabled: false,
    readonly: false,
    required: false,
    fullWidth: false,
    showPasswordToggle: true,
  },
} satisfies Meta<typeof Input>

export default meta
type Story = StoryObj<typeof meta>

// Basic text input
export const Default: Story = {
  args: {
    placeholder: 'Enter text...',
  },
}

// With label
export const WithLabel: Story = {
  args: {
    label: 'Email Address',
    type: 'email',
    placeholder: 'you@example.com',
  },
}

// With helper text
export const WithHelperText: Story = {
  args: {
    label: 'Username',
    placeholder: 'johndoe',
    helperText: 'Choose a unique username',
  },
}

// With error
export const WithError: Story = {
  args: {
    label: 'Email',
    type: 'email',
    placeholder: 'you@example.com',
    modelValue: 'invalid-email',
    error: 'Please enter a valid email address',
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

// Disabled
export const Disabled: Story = {
  args: {
    label: 'Disabled Input',
    placeholder: 'Cannot edit',
    disabled: true,
    modelValue: 'Disabled value',
  },
}

// Read-only
export const ReadOnly: Story = {
  args: {
    label: 'Read-only Input',
    readonly: true,
    modelValue: 'Read-only value',
  },
}

// Small size
export const Small: Story = {
  args: {
    label: 'Small Input',
    size: 'sm',
    placeholder: 'Small size...',
  },
}

// Large size
export const Large: Story = {
  args: {
    label: 'Large Input',
    size: 'lg',
    placeholder: 'Large size...',
  },
}

// Full width
export const FullWidth: Story = {
  args: {
    label: 'Full Width Input',
    fullWidth: true,
    placeholder: 'Spans full width...',
  },
}

// Email type
export const Email: Story = {
  args: {
    label: 'Email',
    type: 'email',
    placeholder: 'you@example.com',
    autocomplete: 'email',
  },
}

// Password type
export const Password: Story = {
  args: {
    label: 'Password',
    type: 'password',
    placeholder: 'Enter your password',
    autocomplete: 'current-password',
  },
}

// Password without toggle
export const PasswordWithoutToggle: Story = {
  args: {
    label: 'Password',
    type: 'password',
    placeholder: 'Enter your password',
    showPasswordToggle: false,
  },
}

// Number type
export const Number: Story = {
  args: {
    label: 'Quantity',
    type: 'number',
    placeholder: '0',
    min: 0,
    max: 100,
    step: 1,
  },
}

// Tel type
export const Telephone: Story = {
  args: {
    label: 'Phone Number',
    type: 'tel',
    placeholder: '+1 (555) 123-4567',
    autocomplete: 'tel',
  },
}

// URL type
export const URL: Story = {
  args: {
    label: 'Website',
    type: 'url',
    placeholder: 'https://example.com',
  },
}

// Search type
export const Search: Story = {
  args: {
    type: 'search',
    placeholder: 'Search...',
    fullWidth: true,
  },
}

// Date type
export const Date: Story = {
  args: {
    label: 'Date of Birth',
    type: 'date',
  },
}

// With v-model (interactive)
export const VModel: Story = {
  render: () => ({
    components: { Input },
    setup() {
      const value = ref('')
      return { value }
    },
    template: `
      <div>
        <Input
          v-model="value"
          label="Enter text"
          placeholder="Type something..."
          helperText="The value will be displayed below"
        />
        <p class="mt-4 text-sm text-gray-600">
          Current value: <strong>{{ value || '(empty)' }}</strong>
        </p>
      </div>
    `,
  }),
}

// Form example
export const FormExample: Story = {
  render: () => ({
    components: { Input },
    setup() {
      const formData = ref({
        name: '',
        email: '',
        password: '',
        age: '',
        phone: '',
      })
      const errors = ref({
        name: '',
        email: '',
        password: '',
      })

      const validateForm = () => {
        errors.value = { name: '', email: '', password: '' }

        if (!formData.value.name) {
          errors.value.name = 'Name is required'
        }

        if (!formData.value.email) {
          errors.value.email = 'Email is required'
        } else if (!/\S+@\S+\.\S+/.test(formData.value.email)) {
          errors.value.email = 'Email is invalid'
        }

        if (!formData.value.password) {
          errors.value.password = 'Password is required'
        } else if (formData.value.password.length < 8) {
          errors.value.password = 'Password must be at least 8 characters'
        }

        return !Object.values(errors.value).some((error) => error)
      }

      const handleSubmit = () => {
        if (validateForm()) {
          alert('Form is valid!')
        }
      }

      return { formData, errors, handleSubmit }
    },
    template: `
      <form @submit.prevent="handleSubmit" class="space-y-4 max-w-md">
        <Input
          v-model="formData.name"
          label="Full Name"
          placeholder="John Doe"
          required
          :error="errors.name"
        />

        <Input
          v-model="formData.email"
          type="email"
          label="Email"
          placeholder="you@example.com"
          required
          :error="errors.email"
          autocomplete="email"
        />

        <Input
          v-model="formData.password"
          type="password"
          label="Password"
          placeholder="••••••••"
          required
          :error="errors.password"
          helperText="Must be at least 8 characters"
          autocomplete="new-password"
        />

        <Input
          v-model="formData.age"
          type="number"
          label="Age"
          placeholder="18"
          :min="18"
          :max="120"
        />

        <Input
          v-model="formData.phone"
          type="tel"
          label="Phone (optional)"
          placeholder="+1 (555) 123-4567"
          autocomplete="tel"
        />

        <button
          type="submit"
          class="px-4 py-2 bg-primary-700 text-white rounded-lg hover:bg-primary-800 transition-colors"
        >
          Submit Form
        </button>
      </form>
    `,
  }),
}

// All states showcase
export const AllStates: Story = {
  render: () => ({
    components: { Input },
    template: `
      <div class="space-y-6 max-w-md">
        <div>
          <h3 class="text-lg font-semibold mb-2">States</h3>
          <div class="space-y-4">
            <Input label="Normal" placeholder="Normal input" />
            <Input label="With value" modelValue="Some text" />
            <Input label="Disabled" disabled modelValue="Disabled value" />
            <Input label="Read-only" readonly modelValue="Read-only value" />
            <Input label="With error" error="This field has an error" />
            <Input label="Required" required placeholder="Required field" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-2">Sizes</h3>
          <div class="space-y-4">
            <Input label="Small" size="sm" placeholder="Small input" />
            <Input label="Medium (default)" size="md" placeholder="Medium input" />
            <Input label="Large" size="lg" placeholder="Large input" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-2">Types</h3>
          <div class="space-y-4">
            <Input label="Text" type="text" placeholder="Text input" />
            <Input label="Email" type="email" placeholder="email@example.com" />
            <Input label="Password" type="password" placeholder="••••••••" />
            <Input label="Number" type="number" placeholder="0" />
            <Input label="Tel" type="tel" placeholder="+1 (555) 123-4567" />
            <Input label="URL" type="url" placeholder="https://example.com" />
          </div>
        </div>
      </div>
    `,
  }),
}
