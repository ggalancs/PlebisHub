import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Checkbox from './Checkbox.vue'

const meta = {
  title: 'Atoms/Checkbox',
  component: Checkbox,
  tags: ['autodocs'],
  argTypes: {
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Checkbox size',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    indeterminate: {
      control: 'boolean',
      description: 'Indeterminate state',
    },
    required: {
      control: 'boolean',
      description: 'Required field',
    },
    modelValue: {
      control: 'boolean',
      description: 'Checked state',
    },
  },
  args: {
    size: 'md',
    disabled: false,
    indeterminate: false,
    required: false,
    modelValue: false,
  },
} satisfies Meta<typeof Checkbox>

export default meta
type Story = StoryObj<typeof meta>

// Default unchecked
export const Default: Story = {
  args: {
    label: 'Accept terms and conditions',
  },
}

// Checked
export const Checked: Story = {
  args: {
    label: 'I agree to the terms',
    modelValue: true,
  },
}

// With helper text
export const WithHelperText: Story = {
  args: {
    label: 'Subscribe to newsletter',
    helperText: 'You can unsubscribe at any time',
  },
}

// With error
export const WithError: Story = {
  args: {
    label: 'Accept terms',
    error: 'You must accept the terms to continue',
  },
}

// Required
export const Required: Story = {
  args: {
    label: 'Required field',
    required: true,
  },
}

// Disabled unchecked
export const DisabledUnchecked: Story = {
  args: {
    label: 'Disabled option',
    disabled: true,
    modelValue: false,
  },
}

// Disabled checked
export const DisabledChecked: Story = {
  args: {
    label: 'Disabled checked',
    disabled: true,
    modelValue: true,
  },
}

// Indeterminate
export const Indeterminate: Story = {
  args: {
    label: 'Partially selected',
    indeterminate: true,
  },
}

// Small size
export const Small: Story = {
  args: {
    label: 'Small checkbox',
    size: 'sm',
  },
}

// Large size
export const Large: Story = {
  args: {
    label: 'Large checkbox',
    size: 'lg',
  },
}

// Without label
export const WithoutLabel: Story = {
  args: {
    modelValue: false,
  },
}

// Interactive with v-model
export const Interactive: Story = {
  render: () => ({
    components: { Checkbox },
    setup() {
      const checked = ref(false)
      return { checked }
    },
    template: `
      <div>
        <Checkbox
          v-model="checked"
          label="Toggle me"
          helperText="Click to toggle"
        />
        <p class="mt-4 text-sm text-gray-600">
          Checked: <strong>{{ checked }}</strong>
        </p>
      </div>
    `,
  }),
}

// Checkbox group
export const CheckboxGroup: Story = {
  render: () => ({
    components: { Checkbox },
    setup() {
      const options = ref({
        option1: false,
        option2: true,
        option3: false,
      })
      return { options }
    },
    template: `
      <div>
        <fieldset>
          <legend class="text-base font-semibold text-gray-900 mb-4">
            Select your preferences
          </legend>
          <div class="space-y-3">
            <Checkbox
              v-model="options.option1"
              label="Email notifications"
              helperText="Receive email updates about your account"
            />
            <Checkbox
              v-model="options.option2"
              label="SMS notifications"
              helperText="Receive text messages for important updates"
            />
            <Checkbox
              v-model="options.option3"
              label="Push notifications"
              helperText="Receive push notifications in your browser"
            />
          </div>
        </fieldset>

        <div class="mt-6 p-4 bg-gray-50 rounded-lg">
          <p class="text-sm font-medium text-gray-700 mb-2">Selected options:</p>
          <pre class="text-xs text-gray-600">{{ JSON.stringify(options, null, 2) }}</pre>
        </div>
      </div>
    `,
  }),
}

// Select all pattern
export const SelectAllPattern: Story = {
  render: () => ({
    components: { Checkbox },
    setup() {
      const items = ref([
        { id: 1, name: 'Item 1', checked: false },
        { id: 2, name: 'Item 2', checked: true },
        { id: 3, name: 'Item 3', checked: false },
        { id: 4, name: 'Item 4', checked: false },
      ])

      const allChecked = computed(() => items.value.every((item) => item.checked))
      const someChecked = computed(
        () => items.value.some((item) => item.checked) && !allChecked.value
      )

      const toggleAll = () => {
        const newValue = !allChecked.value
        items.value.forEach((item) => {
          item.checked = newValue
        })
      }

      return { items, allChecked, someChecked, toggleAll }
    },
    template: `
      <div>
        <Checkbox
          :modelValue="allChecked"
          :indeterminate="someChecked"
          label="Select all items"
          @update:modelValue="toggleAll"
          class="mb-4 pb-4 border-b"
        />

        <div class="space-y-3 ml-6">
          <Checkbox
            v-for="item in items"
            :key="item.id"
            v-model="item.checked"
            :label="item.name"
          />
        </div>

        <div class="mt-6 p-4 bg-gray-50 rounded-lg">
          <p class="text-sm text-gray-600">
            {{ items.filter(i => i.checked).length }} of {{ items.length }} items selected
          </p>
        </div>
      </div>
    `,
  }),
}

// Form validation example
export const FormValidation: Story = {
  render: () => ({
    components: { Checkbox },
    setup() {
      const formData = ref({
        terms: false,
        privacy: false,
        marketing: false,
      })
      const errors = ref({
        terms: '',
        privacy: '',
      })
      const submitted = ref(false)

      const validateForm = () => {
        errors.value = { terms: '', privacy: '' }

        if (!formData.value.terms) {
          errors.value.terms = 'You must accept the terms and conditions'
        }

        if (!formData.value.privacy) {
          errors.value.privacy = 'You must accept the privacy policy'
        }

        return !Object.values(errors.value).some((error) => error)
      }

      const handleSubmit = () => {
        submitted.value = true
        if (validateForm()) {
          alert('Form submitted successfully!')
        }
      }

      return { formData, errors, submitted, handleSubmit }
    },
    template: `
      <form @submit.prevent="handleSubmit" class="space-y-4 max-w-md">
        <Checkbox
          v-model="formData.terms"
          label="I accept the terms and conditions"
          required
          :error="submitted ? errors.terms : ''"
        />

        <Checkbox
          v-model="formData.privacy"
          label="I accept the privacy policy"
          required
          :error="submitted ? errors.privacy : ''"
        />

        <Checkbox
          v-model="formData.marketing"
          label="I want to receive marketing communications"
          helperText="Optional: You can opt out at any time"
        />

        <button
          type="submit"
          class="px-4 py-2 bg-primary-700 text-white rounded-lg hover:bg-primary-800 transition-colors"
        >
          Submit
        </button>
      </form>
    `,
  }),
}

// All states showcase
export const AllStates: Story = {
  render: () => ({
    components: { Checkbox },
    template: `
      <div class="space-y-8 max-w-md">
        <div>
          <h3 class="text-lg font-semibold mb-4">States</h3>
          <div class="space-y-3">
            <Checkbox label="Unchecked" :modelValue="false" />
            <Checkbox label="Checked" :modelValue="true" />
            <Checkbox label="Indeterminate" :indeterminate="true" />
            <Checkbox label="Disabled unchecked" :disabled="true" :modelValue="false" />
            <Checkbox label="Disabled checked" :disabled="true" :modelValue="true" />
            <Checkbox label="With error" error="This field is required" />
            <Checkbox label="Required field" :required="true" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="space-y-3">
            <Checkbox label="Small checkbox" size="sm" />
            <Checkbox label="Medium checkbox (default)" size="md" />
            <Checkbox label="Large checkbox" size="lg" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With helper text</h3>
          <div class="space-y-3">
            <Checkbox
              label="Subscribe to newsletter"
              helperText="Get weekly updates about new features"
            />
            <Checkbox
              label="Enable notifications"
              helperText="You will receive push notifications"
              :modelValue="true"
            />
          </div>
        </div>
      </div>
    `,
  }),
}
