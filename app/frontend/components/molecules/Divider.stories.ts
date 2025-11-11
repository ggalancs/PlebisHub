import type { Meta, StoryObj } from '@storybook/vue3-vite'
import Divider from './Divider.vue'

const meta = {
  title: 'Molecules/Divider',
  component: Divider,
  tags: ['autodocs'],
} satisfies Meta<typeof Divider>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {},
}

export const WithLabel: Story = {
  args: {
    label: 'OR',
  },
}

export const LabelLeft: Story = {
  args: {
    label: 'Continue',
    labelPosition: 'left',
  },
}

export const LabelRight: Story = {
  args: {
    label: 'End',
    labelPosition: 'right',
  },
}

export const Dashed: Story = {
  args: {
    variant: 'dashed',
    label: 'Section Break',
  },
}

export const Dotted: Story = {
  args: {
    variant: 'dotted',
  },
}

export const Vertical: Story = {
  render: () => ({
    components: { Divider },
    template: `
      <div class="flex h-32 items-center gap-4">
        <div>Left Content</div>
        <Divider orientation="vertical" />
        <div>Right Content</div>
      </div>
    `,
  }),
}

export const FormSections: Story = {
  render: () => ({
    components: { Divider },
    template: `
      <div class="max-w-md space-y-6">
        <div>
          <h3 class="text-lg font-semibold mb-2">Personal Information</h3>
          <p class="text-sm text-gray-600">Enter your basic details</p>
        </div>

        <Divider />

        <div>
          <h3 class="text-lg font-semibold mb-2">Contact Details</h3>
          <p class="text-sm text-gray-600">How can we reach you?</p>
        </div>

        <Divider label="Optional" />

        <div>
          <h3 class="text-lg font-semibold mb-2">Preferences</h3>
          <p class="text-sm text-gray-600">Customize your experience</p>
        </div>
      </div>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { Divider },
    template: `
      <div class="space-y-8">
        <div>
          <p class="text-sm text-gray-600 mb-4">Solid</p>
          <Divider variant="solid" label="Solid" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-4">Dashed</p>
          <Divider variant="dashed" label="Dashed" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-4">Dotted</p>
          <Divider variant="dotted" label="Dotted" />
        </div>
      </div>
    `,
  }),
}
