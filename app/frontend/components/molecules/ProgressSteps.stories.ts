import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import ProgressSteps from './ProgressSteps.vue'
import Button from '../atoms/Button.vue'

const meta = {
  title: 'Molecules/ProgressSteps',
  component: ProgressSteps,
  tags: ['autodocs'],
} satisfies Meta<typeof ProgressSteps>

export default meta
type Story = StoryObj<typeof meta>

const basicSteps = [
  { id: 1, label: 'Account', description: 'Create your account' },
  { id: 2, label: 'Profile', description: 'Complete your profile' },
  { id: 3, label: 'Preferences', description: 'Set your preferences' },
  { id: 4, label: 'Complete', description: 'All done!' },
]

export const Default: Story = {
  args: {
    steps: basicSteps,
    currentStep: 1,
  },
}

export const FirstStep: Story = {
  args: {
    steps: basicSteps,
    currentStep: 0,
  },
}

export const LastStep: Story = {
  args: {
    steps: basicSteps,
    currentStep: 3,
  },
}

export const Vertical: Story = {
  args: {
    steps: basicSteps,
    currentStep: 1,
    orientation: 'vertical',
  },
}

export const WithoutLabels: Story = {
  args: {
    steps: basicSteps,
    currentStep: 1,
    showLabels: false,
  },
}

export const Clickable: Story = {
  render: () => ({
    components: { ProgressSteps },
    setup() {
      const currentStep = ref(0)

      const handleStepClick = (step: number) => {
        currentStep.value = step
      }

      return { basicSteps, currentStep, handleStepClick }
    },
    template: `
      <div>
        <ProgressSteps
          :steps="basicSteps"
          :current-step="currentStep"
          clickable
          @step-click="handleStepClick"
        />
        <p class="mt-4 text-sm text-gray-600">
          Current step: {{ currentStep + 1 }} - {{ basicSteps[currentStep].label }}
        </p>
      </div>
    `,
  }),
}

export const SmallSize: Story = {
  args: {
    steps: basicSteps,
    currentStep: 1,
    size: 'sm',
  },
}

export const LargeSize: Story = {
  args: {
    steps: basicSteps,
    currentStep: 1,
    size: 'lg',
  },
}

export const SimpleVariant: Story = {
  args: {
    steps: basicSteps,
    currentStep: 1,
    variant: 'simple',
  },
}

export const CustomIcons: Story = {
  render: () => ({
    components: { ProgressSteps },
    template: `
      <ProgressSteps
        :steps="[
          { id: 1, label: 'Personal Info', icon: 'user' },
          { id: 2, label: 'Payment', icon: 'credit-card' },
          { id: 3, label: 'Confirmation', icon: 'check-circle' },
        ]"
        :current-step="1"
      />
    `,
  }),
}

export const WithDisabledSteps: Story = {
  render: () => ({
    components: { ProgressSteps },
    template: `
      <ProgressSteps
        :steps="[
          { id: 1, label: 'Basic Info' },
          { id: 2, label: 'Verification', disabled: true },
          { id: 3, label: 'Complete', disabled: true },
        ]"
        :current-step="0"
        clickable
      />
    `,
  }),
}

export const Interactive: Story = {
  render: () => ({
    components: { ProgressSteps, Button },
    setup() {
      const currentStep = ref(0)

      const nextStep = () => {
        if (currentStep.value < basicSteps.length - 1) {
          currentStep.value++
        }
      }

      const prevStep = () => {
        if (currentStep.value > 0) {
          currentStep.value--
        }
      }

      return { basicSteps, currentStep, nextStep, prevStep }
    },
    template: `
      <div class="space-y-6">
        <ProgressSteps
          :steps="basicSteps"
          :current-step="currentStep"
        />

        <div class="p-6 bg-gray-50 rounded-lg">
          <h3 class="text-lg font-semibold mb-2">
            {{ basicSteps[currentStep].label }}
          </h3>
          <p class="text-gray-600 mb-4">
            {{ basicSteps[currentStep].description }}
          </p>
        </div>

        <div class="flex justify-between">
          <Button
            @click="prevStep"
            :disabled="currentStep === 0"
            variant="outline"
          >
            Previous
          </Button>
          <Button
            @click="nextStep"
            :disabled="currentStep === basicSteps.length - 1"
          >
            {{ currentStep === basicSteps.length - 1 ? 'Finish' : 'Next' }}
          </Button>
        </div>
      </div>
    `,
  }),
}

export const CheckoutFlow: Story = {
  render: () => ({
    components: { ProgressSteps, Button },
    setup() {
      const currentStep = ref(0)

      const steps = [
        { id: 1, label: 'Cart', description: 'Review your items', icon: 'shopping-cart' },
        { id: 2, label: 'Shipping', description: 'Enter shipping details', icon: 'truck' },
        { id: 3, label: 'Payment', description: 'Payment information', icon: 'credit-card' },
        { id: 4, label: 'Confirm', description: 'Review and confirm', icon: 'check-circle' },
      ]

      const nextStep = () => {
        if (currentStep.value < steps.length - 1) {
          currentStep.value++
        }
      }

      const prevStep = () => {
        if (currentStep.value > 0) {
          currentStep.value--
        }
      }

      return { steps, currentStep, nextStep, prevStep }
    },
    template: `
      <div class="space-y-6 max-w-3xl">
        <ProgressSteps
          :steps="steps"
          :current-step="currentStep"
        />

        <div class="p-8 bg-white border rounded-lg shadow-sm">
          <h2 class="text-2xl font-bold mb-2">
            {{ steps[currentStep].label }}
          </h2>
          <p class="text-gray-600 mb-6">
            {{ steps[currentStep].description }}
          </p>

          <div class="h-32 bg-gray-50 rounded flex items-center justify-center text-gray-400">
            Step {{ currentStep + 1 }} Content
          </div>
        </div>

        <div class="flex justify-between">
          <Button
            @click="prevStep"
            :disabled="currentStep === 0"
            variant="outline"
          >
            Back
          </Button>
          <Button
            @click="nextStep"
            :disabled="currentStep === steps.length - 1"
          >
            {{ currentStep === steps.length - 1 ? 'Place Order' : 'Continue' }}
          </Button>
        </div>
      </div>
    `,
  }),
}

export const VerticalWithProgress: Story = {
  render: () => ({
    components: { ProgressSteps, Button },
    setup() {
      const currentStep = ref(1)

      const steps = [
        { id: 1, label: 'Order Placed', description: 'Your order has been received' },
        { id: 2, label: 'Processing', description: 'We are preparing your items' },
        { id: 3, label: 'Shipped', description: 'Your order is on its way' },
        { id: 4, label: 'Delivered', description: 'Order has been delivered' },
      ]

      return { steps, currentStep }
    },
    template: `
      <div class="max-w-md">
        <h3 class="text-lg font-semibold mb-4">Order Status</h3>
        <ProgressSteps
          :steps="steps"
          :current-step="currentStep"
          orientation="vertical"
          variant="simple"
        />
      </div>
    `,
  }),
}

export const AllSizes: Story = {
  render: () => ({
    components: { ProgressSteps },
    setup() {
      const steps = [
        { id: 1, label: 'Step 1' },
        { id: 2, label: 'Step 2' },
        { id: 3, label: 'Step 3' },
      ]

      return { steps }
    },
    template: `
      <div class="space-y-8">
        <div>
          <p class="text-sm text-gray-600 mb-4">Small</p>
          <ProgressSteps :steps="steps" :current-step="1" size="sm" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-4">Medium</p>
          <ProgressSteps :steps="steps" :current-step="1" size="md" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-4">Large</p>
          <ProgressSteps :steps="steps" :current-step="1" size="lg" />
        </div>
      </div>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { ProgressSteps },
    setup() {
      const steps = [
        { id: 1, label: 'Step 1' },
        { id: 2, label: 'Step 2' },
        { id: 3, label: 'Step 3' },
      ]

      return { steps }
    },
    template: `
      <div class="space-y-8">
        <div>
          <p class="text-sm text-gray-600 mb-4">Default</p>
          <ProgressSteps :steps="steps" :current-step="1" variant="default" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-4">Simple</p>
          <ProgressSteps :steps="steps" :current-step="1" variant="simple" />
        </div>
      </div>
    `,
  }),
}
