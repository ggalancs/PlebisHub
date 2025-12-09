import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Stepper from './Stepper.vue'
import Button from '../atoms/Button.vue'

const meta = {
  title: 'Molecules/Stepper',
  component: Stepper,
  tags: ['autodocs'],
  argTypes: {
    currentStep: { control: 'number' },
    orientation: { control: 'select', options: ['horizontal', 'vertical'] },
    clickable: { control: 'boolean' },
  },
  args: {
    orientation: 'horizontal',
    clickable: false,
  },
} satisfies Meta<typeof Stepper>

export default meta
type Story = StoryObj<typeof meta>

const basicSteps = [
  { label: 'Account', description: 'Create your account' },
  { label: 'Profile', description: 'Set up your profile' },
  { label: 'Preferences', description: 'Configure settings' },
  { label: 'Complete', description: 'Review and finish' },
]

export const Default: Story = {
  render: (args) => ({
    components: { Stepper },
    setup() {
      return { args }
    },
    template: '<Stepper v-bind="args" />',
  }),
  args: {
    steps: basicSteps,
    currentStep: 1,
  },
}

export const HorizontalOrientation: Story = {
  render: () => ({
    components: { Stepper },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="mb-4 font-semibold">First Step</h3>
          <Stepper :steps="steps" :current-step="0" orientation="horizontal" />
        </div>

        <div>
          <h3 class="mb-4 font-semibold">Middle Step</h3>
          <Stepper :steps="steps" :current-step="2" orientation="horizontal" />
        </div>

        <div>
          <h3 class="mb-4 font-semibold">Last Step</h3>
          <Stepper :steps="steps" :current-step="3" orientation="horizontal" />
        </div>
      </div>
    `,
    setup() {
      return { steps: basicSteps }
    },
  }),
}

export const VerticalOrientation: Story = {
  render: () => ({
    components: { Stepper },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div>
          <h3 class="mb-4 font-semibold">First Step</h3>
          <Stepper :steps="steps" :current-step="0" orientation="vertical" />
        </div>

        <div>
          <h3 class="mb-4 font-semibold">Middle Step</h3>
          <Stepper :steps="steps" :current-step="2" orientation="vertical" />
        </div>

        <div>
          <h3 class="mb-4 font-semibold">Last Step</h3>
          <Stepper :steps="steps" :current-step="3" orientation="vertical" />
        </div>
      </div>
    `,
    setup() {
      return { steps: basicSteps }
    },
  }),
}

export const WithCustomIcons: Story = {
  render: () => ({
    components: { Stepper },
    template: `
      <Stepper :steps="steps" :current-step="1" />
    `,
    setup() {
      const steps = [
        { label: 'Cart', description: 'Review your items', icon: 'shopping-cart' },
        { label: 'Shipping', description: 'Enter address', icon: 'truck' },
        { label: 'Payment', description: 'Payment details', icon: 'credit-card' },
        { label: 'Confirm', description: 'Review order', icon: 'check-circle' },
      ]
      return { steps }
    },
  }),
}

export const WithoutDescriptions: Story = {
  render: () => ({
    components: { Stepper },
    template: `
      <Stepper :steps="steps" :current-step="1" />
    `,
    setup() {
      const steps = [
        { label: 'Step 1' },
        { label: 'Step 2' },
        { label: 'Step 3' },
        { label: 'Step 4' },
      ]
      return { steps }
    },
  }),
}

export const WithErrorState: Story = {
  render: () => ({
    components: { Stepper },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="mb-4 font-semibold">Error on Current Step</h3>
          <Stepper :steps="errorSteps1" :current-step="1" />
        </div>

        <div>
          <h3 class="mb-4 font-semibold">Error on Previous Step</h3>
          <Stepper :steps="errorSteps2" :current-step="2" />
        </div>
      </div>
    `,
    setup() {
      const errorSteps1 = [
        { label: 'Account', description: 'Create account', status: 'complete' as const },
        { label: 'Payment', description: 'Payment failed', status: 'error' as const },
        { label: 'Confirm', description: 'Review order', status: 'upcoming' as const },
      ]

      const errorSteps2 = [
        { label: 'Account', description: 'Account created', status: 'complete' as const },
        { label: 'Verification', description: 'Email not verified', status: 'error' as const },
        { label: 'Complete', description: 'Finish setup', status: 'current' as const },
      ]

      return { errorSteps1, errorSteps2 }
    },
  }),
}

export const Interactive: Story = {
  render: () => ({
    components: { Stepper, Button },
    setup() {
      const currentStep = ref(0)
      const steps = [
        { label: 'Personal Info', description: 'Enter your details' },
        { label: 'Address', description: 'Shipping information' },
        { label: 'Payment', description: 'Payment method' },
        { label: 'Review', description: 'Confirm your order' },
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

      return { currentStep, steps, nextStep, prevStep }
    },
    template: `
      <div class="space-y-8">
        <Stepper :steps="steps" :current-step="currentStep" />

        <div class="flex justify-between">
          <Button
            variant="secondary"
            :disabled="currentStep === 0"
            @click="prevStep"
          >
            Previous
          </Button>

          <Button
            :disabled="currentStep === steps.length - 1"
            @click="nextStep"
          >
            {{ currentStep === steps.length - 1 ? 'Complete' : 'Next' }}
          </Button>
        </div>

        <div class="rounded-lg bg-gray-50 p-4">
          <p class="text-sm text-gray-600">Current Step: {{ currentStep + 1 }} / {{ steps.length }}</p>
        </div>
      </div>
    `,
  }),
}

export const ClickableSteps: Story = {
  render: () => ({
    components: { Stepper },
    setup() {
      const currentStep = ref(2)
      const steps = [
        { label: 'Details', description: 'Enter details' },
        { label: 'Review', description: 'Review info' },
        { label: 'Payment', description: 'Make payment' },
        { label: 'Confirm', description: 'Confirmation' },
      ]

      const handleStepClick = (index: number) => {
        currentStep.value = index
        alert(`Jumped to step ${index + 1}`)
      }

      return { currentStep, steps, handleStepClick }
    },
    template: `
      <div class="space-y-4">
        <div class="rounded-lg bg-blue-50 p-4">
          <p class="text-sm text-blue-800">
            💡 Click on completed steps to navigate back
          </p>
        </div>

        <Stepper
          :steps="steps"
          :current-step="currentStep"
          :clickable="true"
          @step-click="handleStepClick"
        />
      </div>
    `,
  }),
}

export const RealWorldCheckout: Story = {
  render: () => ({
    components: { Stepper, Button },
    setup() {
      const currentStep = ref(1)
      const steps = [
        {
          label: 'Shopping Cart',
          description: '3 items',
          icon: 'shopping-cart',
        },
        {
          label: 'Shipping Info',
          description: 'Address details',
          icon: 'truck',
        },
        {
          label: 'Payment',
          description: 'Payment method',
          icon: 'credit-card',
        },
        {
          label: 'Confirmation',
          description: 'Order summary',
          icon: 'check-circle',
        },
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

      const handleStepClick = (index: number) => {
        currentStep.value = index
      }

      return { currentStep, steps, nextStep, prevStep, handleStepClick }
    },
    template: `
      <div class="space-y-8">
        <Stepper
          :steps="steps"
          :current-step="currentStep"
          :clickable="true"
          @step-click="handleStepClick"
        />

        <div class="rounded-lg border bg-white p-6">
          <h3 class="mb-4 text-lg font-semibold">
            {{ steps[currentStep].label }}
          </h3>
          <p class="mb-6 text-gray-600">
            {{ steps[currentStep].description }}
          </p>

          <div class="flex justify-between">
            <Button
              v-if="currentStep > 0"
              variant="secondary"
              @click="prevStep"
            >
              Back
            </Button>
            <div v-else></div>

            <Button @click="nextStep">
              {{ currentStep === steps.length - 1 ? 'Place Order' : 'Continue' }}
            </Button>
          </div>
        </div>
      </div>
    `,
  }),
}

export const VerticalWithContent: Story = {
  render: () => ({
    components: { Stepper, Button },
    setup() {
      const currentStep = ref(1)
      const steps = [
        { label: 'Account Setup', description: 'Create your account' },
        { label: 'Profile Details', description: 'Add your information' },
        { label: 'Preferences', description: 'Set your preferences' },
        { label: 'Complete', description: 'All done!' },
      ]

      const contentMap: Record<number, string> = {
        0: 'Create your account with email and password.',
        1: 'Tell us about yourself and upload a profile picture.',
        2: 'Choose your notification and privacy settings.',
        3: 'Your account is ready! Start exploring.',
      }

      const nextStep = () => {
        if (currentStep.value < steps.length - 1) {
          currentStep.value++
        }
      }

      return { currentStep, steps, contentMap, nextStep }
    },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div>
          <Stepper
            :steps="steps"
            :current-step="currentStep"
            orientation="vertical"
          />
        </div>

        <div class="md:col-span-2">
          <div class="rounded-lg border bg-white p-8">
            <h2 class="mb-2 text-2xl font-bold">
              {{ steps[currentStep].label }}
            </h2>
            <p class="mb-6 text-gray-600">
              {{ contentMap[currentStep] }}
            </p>

            <div class="mb-6 rounded bg-gray-50 p-4">
              <p class="text-sm text-gray-500">
                Step {{ currentStep + 1 }} of {{ steps.length }}
              </p>
            </div>

            <Button
              :disabled="currentStep === steps.length - 1"
              @click="nextStep"
            >
              {{ currentStep === steps.length - 1 ? 'Finish' : 'Continue' }}
            </Button>
          </div>
        </div>
      </div>
    `,
  }),
}

export const ManySteps: Story = {
  render: () => ({
    components: { Stepper },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="mb-4 font-semibold">Horizontal (Many Steps)</h3>
          <div class="overflow-x-auto">
            <Stepper :steps="steps" :current-step="3" orientation="horizontal" />
          </div>
        </div>

        <div>
          <h3 class="mb-4 font-semibold">Vertical (Many Steps)</h3>
          <Stepper :steps="steps" :current-step="3" orientation="vertical" />
        </div>
      </div>
    `,
    setup() {
      const steps = Array.from({ length: 8 }, (_, i) => ({
        label: `Step ${i + 1}`,
        description: `Description for step ${i + 1}`,
      }))
      return { steps }
    },
  }),
}

export const MinimalSteps: Story = {
  render: () => ({
    components: { Stepper },
    template: `
      <Stepper :steps="steps" :current-step="0" />
    `,
    setup() {
      const steps = [{ label: 'Start' }, { label: 'Finish' }]
      return { steps }
    },
  }),
}

export const CustomStatusCombinations: Story = {
  render: () => ({
    components: { Stepper },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="mb-4 font-semibold">Mixed Statuses</h3>
          <Stepper :steps="mixedSteps" :current-step="2" />
        </div>

        <div>
          <h3 class="mb-4 font-semibold">All Complete</h3>
          <Stepper :steps="allCompleteSteps" :current-step="3" />
        </div>

        <div>
          <h3 class="mb-4 font-semibold">With Skip</h3>
          <Stepper :steps="skippedSteps" :current-step="2" />
        </div>
      </div>
    `,
    setup() {
      const mixedSteps = [
        { label: 'Login', status: 'complete' as const },
        { label: 'Verify', status: 'error' as const },
        { label: 'Setup', status: 'current' as const },
        { label: 'Done', status: 'upcoming' as const },
      ]

      const allCompleteSteps = [
        { label: 'Step 1', status: 'complete' as const },
        { label: 'Step 2', status: 'complete' as const },
        { label: 'Step 3', status: 'complete' as const },
        { label: 'Step 4', status: 'complete' as const },
      ]

      const skippedSteps = [
        { label: 'Step 1', description: 'Completed', status: 'complete' as const },
        { label: 'Step 2', description: 'Skipped', status: 'upcoming' as const },
        { label: 'Step 3', description: 'Current', status: 'current' as const },
        { label: 'Step 4', description: 'Pending', status: 'upcoming' as const },
      ]

      return { mixedSteps, allCompleteSteps, skippedSteps }
    },
  }),
}
