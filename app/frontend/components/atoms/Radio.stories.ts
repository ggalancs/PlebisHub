import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Radio from './Radio.vue'

const meta = {
  title: 'Atoms/Radio',
  component: Radio,
  tags: ['autodocs'],
  argTypes: {
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Radio button size',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    required: {
      control: 'boolean',
      description: 'Required field',
    },
    value: {
      control: 'text',
      description: 'Radio value',
    },
    modelValue: {
      control: 'text',
      description: 'Selected value (v-model)',
    },
  },
  args: {
    size: 'md',
    disabled: false,
    required: false,
  },
} satisfies Meta<typeof Radio>

export default meta
type Story = StoryObj<typeof meta>

// Default unselected
export const Default: Story = {
  args: {
    value: 'option1',
    label: 'Option 1',
    modelValue: '',
  },
}

// Selected
export const Selected: Story = {
  args: {
    value: 'option1',
    label: 'Selected option',
    modelValue: 'option1',
  },
}

// With helper text
export const WithHelperText: Story = {
  args: {
    value: 'option1',
    label: 'Premium plan',
    helperText: 'Best for large teams',
    modelValue: '',
  },
}

// With error
export const WithError: Story = {
  args: {
    value: 'option1',
    label: 'Option with error',
    error: 'You must select an option',
    modelValue: '',
  },
}

// Required
export const Required: Story = {
  args: {
    value: 'option1',
    label: 'Required field',
    required: true,
    modelValue: '',
  },
}

// Disabled unselected
export const DisabledUnselected: Story = {
  args: {
    value: 'option1',
    label: 'Disabled option',
    disabled: true,
    modelValue: '',
  },
}

// Disabled selected
export const DisabledSelected: Story = {
  args: {
    value: 'option1',
    label: 'Disabled selected',
    disabled: true,
    modelValue: 'option1',
  },
}

// Small size
export const Small: Story = {
  args: {
    value: 'option1',
    label: 'Small radio',
    size: 'sm',
    modelValue: '',
  },
}

// Large size
export const Large: Story = {
  args: {
    value: 'option1',
    label: 'Large radio',
    size: 'lg',
    modelValue: '',
  },
}

// Without label
export const WithoutLabel: Story = {
  args: {
    value: 'option1',
    modelValue: '',
  },
}

// Interactive radio group
export const RadioGroup: Story = {
  render: () => ({
    components: { Radio },
    setup() {
      const selected = ref('option2')
      return { selected }
    },
    template: `
      <div>
        <fieldset>
          <legend class="text-base font-semibold text-gray-900 mb-4">
            Choose a plan
          </legend>
          <div class="space-y-3">
            <Radio
              v-model="selected"
              value="option1"
              name="plan"
              label="Basic"
              helperText="Free for up to 5 users"
            />
            <Radio
              v-model="selected"
              value="option2"
              name="plan"
              label="Pro"
              helperText="$10/month for up to 50 users"
            />
            <Radio
              v-model="selected"
              value="option3"
              name="plan"
              label="Enterprise"
              helperText="Custom pricing for unlimited users"
            />
          </div>
        </fieldset>

        <div class="mt-6 p-4 bg-gray-50 rounded-lg">
          <p class="text-sm font-medium text-gray-700 mb-2">Selected value:</p>
          <pre class="text-xs text-gray-600">{{ selected }}</pre>
        </div>
      </div>
    `,
  }),
}

// Payment method example
export const PaymentMethodExample: Story = {
  render: () => ({
    components: { Radio },
    setup() {
      const paymentMethod = ref('card')
      return { paymentMethod }
    },
    template: `
      <div>
        <fieldset>
          <legend class="text-base font-semibold text-gray-900 mb-4">
            Payment method
          </legend>
          <div class="space-y-4">
            <div class="border border-gray-200 rounded-lg p-4 hover:border-primary-600 transition-colors">
              <Radio
                v-model="paymentMethod"
                value="card"
                name="payment"
                label="Credit or debit card"
                helperText="Pay with Visa, Mastercard, Amex, or Discover"
              />
            </div>

            <div class="border border-gray-200 rounded-lg p-4 hover:border-primary-600 transition-colors">
              <Radio
                v-model="paymentMethod"
                value="paypal"
                name="payment"
                label="PayPal"
                helperText="Pay securely with your PayPal account"
              />
            </div>

            <div class="border border-gray-200 rounded-lg p-4 hover:border-primary-600 transition-colors">
              <Radio
                v-model="paymentMethod"
                value="bank"
                name="payment"
                label="Bank transfer"
                helperText="Direct bank transfer (3-5 business days)"
              />
            </div>
          </div>
        </fieldset>

        <div class="mt-6 p-4 bg-gray-50 rounded-lg">
          <p class="text-sm text-gray-600">
            Selected payment method: <strong>{{ paymentMethod }}</strong>
          </p>
        </div>
      </div>
    `,
  }),
}

// Form validation example
export const FormValidation: Story = {
  render: () => ({
    components: { Radio },
    setup() {
      const formData = ref({
        size: '',
      })
      const error = ref('')
      const submitted = ref(false)

      const validateForm = () => {
        error.value = ''

        if (!formData.value.size) {
          error.value = 'Please select a size'
        }

        return !error.value
      }

      const handleSubmit = () => {
        submitted.value = true
        if (validateForm()) {
          alert('Form submitted successfully!')
        }
      }

      return { formData, error, submitted, handleSubmit }
    },
    template: `
      <form @submit.prevent="handleSubmit" class="space-y-4 max-w-md">
        <fieldset>
          <legend class="text-base font-semibold text-gray-900 mb-4">
            Select your size *
          </legend>
          <div class="space-y-3">
            <Radio
              v-model="formData.size"
              value="small"
              name="size"
              label="Small"
              required
              :error="submitted && !formData.size ? error : ''"
            />
            <Radio
              v-model="formData.size"
              value="medium"
              name="size"
              label="Medium"
              required
            />
            <Radio
              v-model="formData.size"
              value="large"
              name="size"
              label="Large"
              required
            />
          </div>
          <p v-if="submitted && error" class="mt-2 text-sm text-red-600" role="alert">
            {{ error }}
          </p>
        </fieldset>

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

// With numeric values
export const NumericValues: Story = {
  render: () => ({
    components: { Radio },
    setup() {
      const rating = ref<number>(3)
      return { rating }
    },
    template: `
      <div>
        <fieldset>
          <legend class="text-base font-semibold text-gray-900 mb-4">
            How would you rate our service?
          </legend>
          <div class="space-y-3">
            <Radio
              v-model="rating"
              :value="5"
              name="rating"
              label="Excellent (5 stars)"
            />
            <Radio
              v-model="rating"
              :value="4"
              name="rating"
              label="Good (4 stars)"
            />
            <Radio
              v-model="rating"
              :value="3"
              name="rating"
              label="Average (3 stars)"
            />
            <Radio
              v-model="rating"
              :value="2"
              name="rating"
              label="Below average (2 stars)"
            />
            <Radio
              v-model="rating"
              :value="1"
              name="rating"
              label="Poor (1 star)"
            />
          </div>
        </fieldset>

        <div class="mt-6 p-4 bg-gray-50 rounded-lg">
          <p class="text-sm text-gray-600">
            Your rating: <strong>{{ rating }} stars</strong>
          </p>
        </div>
      </div>
    `,
  }),
}

// All states showcase
export const AllStates: Story = {
  render: () => ({
    components: { Radio },
    template: `
      <div class="space-y-8 max-w-md">
        <div>
          <h3 class="text-lg font-semibold mb-4">States</h3>
          <div class="space-y-3">
            <Radio value="1" :modelValue="''" label="Unselected" name="states1" />
            <Radio value="2" :modelValue="'2'" label="Selected" name="states2" />
            <Radio value="3" :modelValue="''" label="Disabled unselected" :disabled="true" name="states3" />
            <Radio value="4" :modelValue="'4'" label="Disabled selected" :disabled="true" name="states4" />
            <Radio value="5" :modelValue="''" label="With error" error="This field is required" name="states5" />
            <Radio value="6" :modelValue="''" label="Required field" :required="true" name="states6" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="space-y-3">
            <Radio value="7" :modelValue="''" label="Small radio" size="sm" name="sizes1" />
            <Radio value="8" :modelValue="''" label="Medium radio (default)" size="md" name="sizes2" />
            <Radio value="9" :modelValue="''" label="Large radio" size="lg" name="sizes3" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With helper text</h3>
          <div class="space-y-3">
            <Radio
              value="10"
              :modelValue="''"
              name="helper1"
              label="Free shipping"
              helperText="Delivery in 5-7 business days"
            />
            <Radio
              value="11"
              :modelValue="'11'"
              name="helper2"
              label="Express shipping"
              helperText="Delivery in 1-2 business days"
            />
          </div>
        </div>
      </div>
    `,
  }),
}
