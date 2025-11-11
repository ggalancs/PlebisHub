import type { Meta, StoryObj } from '@storybook/vue3-vite'
import Tooltip from './Tooltip.vue'
import Button from '../atoms/Button.vue'

const meta = {
  title: 'Molecules/Tooltip',
  component: Tooltip,
  tags: ['autodocs'],
} satisfies Meta<typeof Tooltip>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex justify-center">
        <Tooltip content="This is a helpful tooltip">
          <Button>Hover me</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const TopPlacement: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex justify-center">
        <Tooltip content="Tooltip on top" placement="top">
          <Button>Top</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const BottomPlacement: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex justify-center">
        <Tooltip content="Tooltip on bottom" placement="bottom">
          <Button>Bottom</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const LeftPlacement: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex justify-center">
        <Tooltip content="Tooltip on left" placement="left">
          <Button>Left</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const RightPlacement: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex justify-center">
        <Tooltip content="Tooltip on right" placement="right">
          <Button>Right</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const AllPlacements: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20">
        <div class="grid grid-cols-2 gap-4 max-w-md mx-auto">
          <Tooltip content="Top" placement="top">
            <Button class="w-full">Top</Button>
          </Tooltip>
          <Tooltip content="Bottom" placement="bottom">
            <Button class="w-full">Bottom</Button>
          </Tooltip>
          <Tooltip content="Left" placement="left">
            <Button class="w-full">Left</Button>
          </Tooltip>
          <Tooltip content="Right" placement="right">
            <Button class="w-full">Right</Button>
          </Tooltip>
        </div>
      </div>
    `,
  }),
}

export const LightVariant: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex justify-center">
        <Tooltip content="Light variant tooltip" variant="light">
          <Button>Light tooltip</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const DarkVariant: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex justify-center">
        <Tooltip content="Dark variant tooltip" variant="dark">
          <Button>Dark tooltip</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const WithoutArrow: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex justify-center">
        <Tooltip content="Tooltip without arrow" :show-arrow="false">
          <Button>No arrow</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const CustomDelay: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex gap-4 justify-center">
        <Tooltip content="No delay" :delay="0">
          <Button>Instant (0ms)</Button>
        </Tooltip>
        <Tooltip content="Short delay" :delay="100">
          <Button>Short (100ms)</Button>
        </Tooltip>
        <Tooltip content="Long delay" :delay="1000">
          <Button>Long (1000ms)</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const MaxWidths: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex gap-4 justify-center">
        <Tooltip
          content="Small max-width tooltip with a bit more text to show wrapping"
          max-width="sm"
        >
          <Button>Small</Button>
        </Tooltip>
        <Tooltip
          content="Medium max-width tooltip with even more text to demonstrate how the tooltip wraps at medium width"
          max-width="md"
        >
          <Button>Medium</Button>
        </Tooltip>
        <Tooltip
          content="Large max-width tooltip with quite a lot of text to demonstrate how the tooltip can accommodate longer descriptions at large width settings"
          max-width="lg"
        >
          <Button>Large</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const CustomContent: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex justify-center">
        <Tooltip>
          <Button>Custom content</Button>
          <template #content>
            <div class="space-y-1">
              <div class="font-semibold">Custom Tooltip</div>
              <div class="text-xs">You can use any HTML content here</div>
            </div>
          </template>
        </Tooltip>
      </div>
    `,
  }),
}

export const Disabled: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex gap-4 justify-center">
        <Tooltip content="This tooltip is enabled">
          <Button>Enabled</Button>
        </Tooltip>
        <Tooltip content="This tooltip is disabled" disabled>
          <Button variant="secondary">Disabled</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const OnTextElements: Story = {
  render: () => ({
    components: { Tooltip },
    template: `
      <div class="p-20">
        <p class="text-gray-700">
          This is a paragraph with
          <Tooltip content="Helpful information about this term">
            <span class="underline decoration-dotted cursor-help">tooltips</span>
          </Tooltip>
          inline in the text. You can also have
          <Tooltip content="Another helpful tooltip" variant="light">
            <span class="font-semibold cursor-help">multiple tooltips</span>
          </Tooltip>
          throughout your content.
        </p>
      </div>
    `,
  }),
}

export const OnIcons: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex gap-4 justify-center items-center">
        <Tooltip content="Information">
          <button class="p-2 rounded-full hover:bg-gray-100 transition-colors">
            <svg class="w-5 h-5 text-blue-500" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
            </svg>
          </button>
        </Tooltip>

        <Tooltip content="Warning">
          <button class="p-2 rounded-full hover:bg-gray-100 transition-colors">
            <svg class="w-5 h-5 text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
          </button>
        </Tooltip>

        <Tooltip content="Settings">
          <button class="p-2 rounded-full hover:bg-gray-100 transition-colors">
            <svg class="w-5 h-5 text-gray-500" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M11.49 3.17c-.38-1.56-2.6-1.56-2.98 0a1.532 1.532 0 01-2.286.948c-1.372-.836-2.942.734-2.106 2.106.54.886.061 2.042-.947 2.287-1.561.379-1.561 2.6 0 2.978a1.532 1.532 0 01.947 2.287c-.836 1.372.734 2.942 2.106 2.106a1.532 1.532 0 012.287.947c.379 1.561 2.6 1.561 2.978 0a1.533 1.533 0 012.287-.947c1.372.836 2.942-.734 2.106-2.106a1.533 1.533 0 01.947-2.287c1.561-.379 1.561-2.6 0-2.978a1.532 1.532 0 01-.947-2.287c.836-1.372-.734-2.942-2.106-2.106a1.532 1.532 0 01-2.287-.947zM10 13a3 3 0 100-6 3 3 0 000 6z" clip-rule="evenodd" />
            </svg>
          </button>
        </Tooltip>
      </div>
    `,
  }),
}

export const MultipleTooltips: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20">
        <div class="grid grid-cols-3 gap-4 max-w-2xl mx-auto">
          <Tooltip content="Save your work" placement="top">
            <Button class="w-full">Save</Button>
          </Tooltip>
          <Tooltip content="Cancel changes" placement="top">
            <Button variant="secondary" class="w-full">Cancel</Button>
          </Tooltip>
          <Tooltip content="Delete permanently" placement="top" variant="light">
            <Button variant="outline" class="w-full">Delete</Button>
          </Tooltip>
          <Tooltip content="Export data" placement="bottom">
            <Button class="w-full">Export</Button>
          </Tooltip>
          <Tooltip content="Import data" placement="bottom">
            <Button class="w-full">Import</Button>
          </Tooltip>
          <Tooltip content="More options" placement="bottom">
            <Button class="w-full">More</Button>
          </Tooltip>
        </div>
      </div>
    `,
  }),
}

export const LongText: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20 flex justify-center">
        <Tooltip
          content="This is a very long tooltip text that demonstrates how the tooltip handles longer content. It should wrap properly and remain readable even with multiple lines of text."
          max-width="md"
        >
          <Button>Long text tooltip</Button>
        </Tooltip>
      </div>
    `,
  }),
}

export const WithKeyboardFocus: Story = {
  render: () => ({
    components: { Tooltip, Button },
    template: `
      <div class="p-20">
        <p class="text-sm text-gray-600 mb-4 text-center">
          Use Tab key to navigate and see tooltips appear on focus
        </p>
        <div class="flex gap-4 justify-center">
          <Tooltip content="First button">
            <Button>Button 1</Button>
          </Tooltip>
          <Tooltip content="Second button">
            <Button>Button 2</Button>
          </Tooltip>
          <Tooltip content="Third button">
            <Button>Button 3</Button>
          </Tooltip>
        </div>
      </div>
    `,
  }),
}
