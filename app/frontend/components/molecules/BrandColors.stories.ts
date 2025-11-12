import type { Meta, StoryObj } from '@storybook/vue3'
import BrandColors from './BrandColors.vue'

const meta = {
  title: 'Brand/BrandColors',
  component: BrandColors,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['palette', 'swatches', 'compact'],
      description: 'Display variant',
    },
    showLabels: {
      control: 'boolean',
      description: 'Show color names',
    },
    showHex: {
      control: 'boolean',
      description: 'Show hex codes',
    },
    interactive: {
      control: 'boolean',
      description: 'Enable click to copy',
    },
  },
  parameters: {
    docs: {
      description: {
        component: 'Brand color palette component displaying primary and secondary colors with multiple presentation options.',
      },
    },
  },
} satisfies Meta<typeof BrandColors>

export default meta
type Story = StoryObj<typeof meta>

/**
 * Default palette view
 */
export const Default: Story = {
  args: {
    variant: 'palette',
    showLabels: true,
    showHex: true,
    interactive: false,
  },
}

/**
 * Interactive palette (click to copy hex)
 */
export const Interactive: Story = {
  args: {
    variant: 'palette',
    showLabels: true,
    showHex: true,
    interactive: true,
  },
  parameters: {
    docs: {
      description: {
        story: 'Click on any color swatch to copy its hex code to clipboard.',
      },
    },
  },
}

/**
 * Swatches view (horizontal strips)
 */
export const Swatches: Story = {
  args: {
    variant: 'swatches',
    showLabels: true,
    showHex: true,
    interactive: false,
  },
}

/**
 * Compact view for smaller spaces
 */
export const Compact: Story = {
  args: {
    variant: 'compact',
    showLabels: true,
    showHex: true,
    interactive: false,
  },
}

/**
 * Without labels
 */
export const NoLabels: Story = {
  args: {
    variant: 'palette',
    showLabels: false,
    showHex: true,
    interactive: false,
  },
}

/**
 * Without hex codes
 */
export const NoHex: Story = {
  args: {
    variant: 'palette',
    showLabels: true,
    showHex: false,
    interactive: false,
  },
}

/**
 * Minimal (no labels, no hex)
 */
export const Minimal: Story = {
  args: {
    variant: 'swatches',
    showLabels: false,
    showHex: false,
    interactive: false,
  },
}
