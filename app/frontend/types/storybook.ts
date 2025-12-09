import type { Meta, StoryObj } from '@storybook/vue3'
import type { Component } from 'vue'

/**
 * Helper type for creating stories with render functions where args may be optional.
 * Use this when your story uses a custom render function that doesn't rely on Storybook args.
 *
 * @example
 * ```ts
 * import type { RenderStory } from '@/types/storybook'
 *
 * type Story = RenderStory<typeof meta>
 *
 * export const MyStory: Story = {
 *   render: () => ({
 *     // Custom render function
 *   }),
 * }
 * ```
 */
export type RenderStory<TMeta extends Meta<Component>> = Omit<StoryObj<TMeta>, 'args'> & {
  args?: Partial<StoryObj<TMeta>['args']>
}

/**
 * Standard StoryObj type alias for convenience
 */
export type Story<TMeta extends Meta<Component>> = StoryObj<TMeta>
