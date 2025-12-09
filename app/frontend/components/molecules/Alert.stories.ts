import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Alert from './Alert.vue'

const meta = {
  title: 'Molecules/Alert',
  component: Alert,
  tags: ['autodocs'],
} satisfies Meta<typeof Alert>

export default meta
type Story = StoryObj<typeof meta>

export const Info: Story = {
  args: {
    variant: 'info',
    title: 'Information',
    message: 'This is an informational alert message.',
  },
}

export const Success: Story = {
  args: {
    variant: 'success',
    title: 'Success!',
    message: 'Your changes have been saved successfully.',
  },
}

export const Warning: Story = {
  args: {
    variant: 'warning',
    title: 'Warning',
    message: 'Please review your input before proceeding.',
  },
}

export const Danger: Story = {
  args: {
    variant: 'danger',
    title: 'Error',
    message: 'An error occurred while processing your request.',
  },
}

export const Dismissible: Story = {
  args: {
    variant: 'info',
    title: 'Dismissible Alert',
    message: 'You can dismiss this alert by clicking the X button.',
    dismissible: true,
  },
}

export const CustomIcon: Story = {
  args: {
    variant: 'success',
    title: 'Achievement Unlocked',
    message: 'You completed all tasks!',
    icon: 'trophy',
    dismissible: true,
  },
}

export const MessageOnly: Story = {
  args: {
    variant: 'info',
    message: 'This alert has no title, just a message.',
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { Alert },
    setup() {
      const showAlert = ref(true)

      return { showAlert }
    },
    template: `
      <div class="space-y-4">
        <button
          v-if="!showAlert"
          @click="showAlert = true"
          class="px-4 py-2 bg-primary text-white rounded hover:bg-primary/90"
        >
          Show Alert
        </button>

        <Alert
          v-if="showAlert"
          variant="success"
          title="Success!"
          message="Your action was completed successfully."
          dismissible
          @dismiss="showAlert = false"
        />
      </div>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { Alert },
    template: `
      <div class="space-y-4">
        <Alert
          variant="info"
          title="Information"
          message="This is an informational message."
        />
        <Alert
          variant="success"
          title="Success"
          message="Operation completed successfully."
        />
        <Alert
          variant="warning"
          title="Warning"
          message="Please proceed with caution."
        />
        <Alert
          variant="danger"
          title="Error"
          message="An error has occurred."
        />
      </div>
    `,
  }),
}

export const CustomContent: Story = {
  render: () => ({
    components: { Alert },
    template: `
      <Alert variant="info" dismissible>
        <div class="space-y-2">
          <h4 class="font-semibold">New Features Available</h4>
          <p class="text-sm">We've added some exciting new features:</p>
          <ul class="text-sm list-disc list-inside ml-2">
            <li>Dark mode support</li>
            <li>Improved performance</li>
            <li>New component library</li>
          </ul>
          <button class="mt-2 text-sm font-medium underline">Learn More</button>
        </div>
      </Alert>
    `,
  }),
}
