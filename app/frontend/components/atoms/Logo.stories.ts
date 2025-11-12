import type { Meta, StoryObj } from '@storybook/vue3'
import Logo from './Logo.vue'

const meta = {
  title: 'Brand/Logo',
  component: Logo,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['horizontal', 'vertical', 'mark', 'type'],
      description: 'Logo layout variant',
    },
    theme: {
      control: 'select',
      options: ['color', 'monochrome', 'inverted'],
      description: 'Color theme',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg', 'xl'],
      description: 'Logo size',
    },
    customColors: {
      control: 'object',
      description: 'Custom brand colors',
    },
  },
  parameters: {
    docs: {
      description: {
        component: 'Modular logo component with multiple variants, themes, and customizable colors.',
      },
    },
  },
} satisfies Meta<typeof Logo>

export default meta
type Story = StoryObj<typeof meta>

/**
 * Default horizontal logo with full colors
 */
export const Horizontal: Story = {
  args: {
    variant: 'horizontal',
    theme: 'color',
    size: 'lg',
  },
}

/**
 * Vertical layout for narrow spaces
 */
export const Vertical: Story = {
  args: {
    variant: 'vertical',
    theme: 'color',
    size: 'md',
  },
}

/**
 * Mark only (icon without text)
 */
export const MarkOnly: Story = {
  args: {
    variant: 'mark',
    theme: 'color',
    size: 'md',
  },
}

/**
 * Type only (text without icon)
 */
export const TypeOnly: Story = {
  args: {
    variant: 'type',
    theme: 'color',
    size: 'md',
  },
}

/**
 * Monochrome theme for print
 */
export const Monochrome: Story = {
  args: {
    variant: 'horizontal',
    theme: 'monochrome',
    size: 'lg',
  },
}

/**
 * Inverted colors for dark backgrounds
 */
export const Inverted: Story = {
  args: {
    variant: 'horizontal',
    theme: 'inverted',
    size: 'lg',
  },
  parameters: {
    backgrounds: {
      default: 'dark',
    },
  },
}

/**
 * Small size
 */
export const Small: Story = {
  args: {
    variant: 'horizontal',
    theme: 'color',
    size: 'sm',
  },
}

/**
 * Extra large size
 */
export const ExtraLarge: Story = {
  args: {
    variant: 'horizontal',
    theme: 'color',
    size: 'xl',
  },
}

/**
 * Custom brand colors
 */
export const CustomColors: Story = {
  args: {
    variant: 'horizontal',
    theme: 'color',
    size: 'lg',
    customColors: {
      primary: '#1e40af',
      secondary: '#0891b2',
    },
  },
}

/**
 * All variants showcase
 */
export const AllVariants: Story = {
  render: () => ({
    components: { Logo },
    template: `
      <div style="display: flex; flex-direction: column; gap: 3rem; padding: 2rem;">
        <div>
          <h3 style="margin-bottom: 1rem; font-family: Montserrat, sans-serif;">Horizontal</h3>
          <Logo variant="horizontal" theme="color" size="lg" />
        </div>

        <div>
          <h3 style="margin-bottom: 1rem; font-family: Montserrat, sans-serif;">Vertical</h3>
          <Logo variant="vertical" theme="color" size="md" />
        </div>

        <div style="display: flex; gap: 2rem; align-items: center;">
          <div>
            <h3 style="margin-bottom: 1rem; font-family: Montserrat, sans-serif;">Mark Only</h3>
            <Logo variant="mark" theme="color" size="md" />
          </div>

          <div>
            <h3 style="margin-bottom: 1rem; font-family: Montserrat, sans-serif;">Type Only</h3>
            <Logo variant="type" theme="color" size="md" />
          </div>
        </div>
      </div>
    `,
  }),
}

/**
 * All themes showcase
 */
export const AllThemes: Story = {
  render: () => ({
    components: { Logo },
    template: `
      <div style="display: flex; flex-direction: column; gap: 3rem; padding: 2rem;">
        <div>
          <h3 style="margin-bottom: 1rem; font-family: Montserrat, sans-serif;">Color (Default)</h3>
          <Logo variant="horizontal" theme="color" size="lg" />
        </div>

        <div>
          <h3 style="margin-bottom: 1rem; font-family: Montserrat, sans-serif;">Monochrome</h3>
          <Logo variant="horizontal" theme="monochrome" size="lg" />
        </div>

        <div style="background-color: #1a1a1a; padding: 2rem; border-radius: 8px;">
          <h3 style="margin-bottom: 1rem; font-family: Montserrat, sans-serif; color: white;">Inverted (Dark Background)</h3>
          <Logo variant="horizontal" theme="inverted" size="lg" />
        </div>
      </div>
    `,
  }),
}

/**
 * Responsive sizes
 */
export const AllSizes: Story = {
  render: () => ({
    components: { Logo },
    template: `
      <div style="display: flex; flex-direction: column; gap: 2rem; padding: 2rem; align-items: flex-start;">
        <div>
          <p style="margin-bottom: 0.5rem; font-size: 0.875rem; color: #666;">Small (sm)</p>
          <Logo variant="horizontal" theme="color" size="sm" />
        </div>

        <div>
          <p style="margin-bottom: 0.5rem; font-size: 0.875rem; color: #666;">Medium (md)</p>
          <Logo variant="horizontal" theme="color" size="md" />
        </div>

        <div>
          <p style="margin-bottom: 0.5rem; font-size: 0.875rem; color: #666;">Large (lg)</p>
          <Logo variant="horizontal" theme="color" size="lg" />
        </div>

        <div>
          <p style="margin-bottom: 0.5rem; font-size: 0.875rem; color: #666;">Extra Large (xl)</p>
          <Logo variant="horizontal" theme="color" size="xl" />
        </div>
      </div>
    `,
  }),
}
