import type { Meta, StoryObj } from '@storybook/vue3'
import ProgressBar from './ProgressBar.vue'

const meta = {
  title: 'Molecules/ProgressBar',
  component: ProgressBar,
  tags: ['autodocs'],
} satisfies Meta<typeof ProgressBar>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    value: 60,
    label: 'Progress',
    showPercentage: true,
  },
}

export const Variants: Story = {
  render: () => ({
    components: { ProgressBar },
    template: `
      <div class="space-y-4">
        <ProgressBar :value="100" variant="success" label="Success" show-percentage />
        <ProgressBar :value="75" variant="info" label="Info" show-percentage />
        <ProgressBar :value="50" variant="warning" label="Warning" show-percentage />
        <ProgressBar :value="25" variant="danger" label="Danger" show-percentage />
      </div>
    `,
  }),
}

export const Sizes: Story = {
  render: () => ({
    components: { ProgressBar },
    template: `
      <div class="space-y-4">
        <ProgressBar :value="60" size="sm" label="Small" />
        <ProgressBar :value="60" size="md" label="Medium" />
        <ProgressBar :value="60" size="lg" label="Large" />
      </div>
    `,
  }),
}

export const Striped: Story = {
  args: {
    value: 75,
    striped: true,
    animated: true,
    label: 'Uploading...',
    showPercentage: true,
  },
}
