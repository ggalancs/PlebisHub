import type { Meta, StoryObj } from '@storybook/vue3-vite'
import Kbd from './Kbd.vue'

const meta = {
  title: 'Molecules/Kbd',
  component: Kbd,
  tags: ['autodocs'],
} satisfies Meta<typeof Kbd>

export default meta
type Story = StoryObj<typeof meta>

export const SingleKey: Story = {
  args: {
    keys: 'Enter',
  },
}

export const KeyCombination: Story = {
  args: {
    keys: ['Ctrl', 'C'],
  },
}

export const ComplexCombination: Story = {
  args: {
    keys: ['Cmd', 'Shift', 'P'],
  },
}

export const WithIcon: Story = {
  args: {
    icon: 'command',
    keys: 'K',
  },
}

export const IconOnly: Story = {
  args: {
    icon: 'arrow-up',
  },
}

export const SmallSize: Story = {
  args: {
    keys: ['Ctrl', 'S'],
    size: 'sm',
  },
}

export const LargeSize: Story = {
  args: {
    keys: ['Cmd', 'K'],
    size: 'lg',
  },
}

export const OutlineVariant: Story = {
  args: {
    keys: ['Alt', 'Tab'],
    variant: 'outline',
  },
}

export const SolidVariant: Story = {
  args: {
    keys: ['Ctrl', 'V'],
    variant: 'solid',
  },
}

export const Disabled: Story = {
  args: {
    keys: ['Ctrl', 'Z'],
    disabled: true,
  },
}

export const WithTitle: Story = {
  args: {
    keys: 'Esc',
    title: 'Escape key - Close dialog',
  },
}

export const ArrowKeys: Story = {
  render: () => ({
    components: { Kbd },
    template: `
      <div class="flex gap-2">
        <Kbd icon="arrow-up">↑</Kbd>
        <Kbd icon="arrow-down">↓</Kbd>
        <Kbd icon="arrow-left">←</Kbd>
        <Kbd icon="arrow-right">→</Kbd>
      </div>
    `,
  }),
}

export const CommonShortcuts: Story = {
  render: () => ({
    components: { Kbd },
    template: `
      <div class="space-y-4">
        <div class="flex items-center gap-3">
          <Kbd :keys="['Ctrl', 'C']" />
          <span class="text-sm text-gray-600">Copy</span>
        </div>
        <div class="flex items-center gap-3">
          <Kbd :keys="['Ctrl', 'V']" />
          <span class="text-sm text-gray-600">Paste</span>
        </div>
        <div class="flex items-center gap-3">
          <Kbd :keys="['Ctrl', 'S']" />
          <span class="text-sm text-gray-600">Save</span>
        </div>
        <div class="flex items-center gap-3">
          <Kbd :keys="['Ctrl', 'Z']" />
          <span class="text-sm text-gray-600">Undo</span>
        </div>
        <div class="flex items-center gap-3">
          <Kbd :keys="['Ctrl', 'Y']" />
          <span class="text-sm text-gray-600">Redo</span>
        </div>
      </div>
    `,
  }),
}

export const NavigationKeys: Story = {
  render: () => ({
    components: { Kbd },
    template: `
      <div class="space-y-4">
        <div class="flex items-center gap-3">
          <Kbd keys="Enter" />
          <span class="text-sm text-gray-600">Submit</span>
        </div>
        <div class="flex items-center gap-3">
          <Kbd keys="Esc" />
          <span class="text-sm text-gray-600">Cancel</span>
        </div>
        <div class="flex items-center gap-3">
          <Kbd keys="Tab" />
          <span class="text-sm text-gray-600">Next field</span>
        </div>
        <div class="flex items-center gap-3">
          <Kbd :keys="['Shift', 'Tab']" />
          <span class="text-sm text-gray-600">Previous field</span>
        </div>
      </div>
    `,
  }),
}

export const MacOSStyle: Story = {
  render: () => ({
    components: { Kbd },
    template: `
      <div class="space-y-4">
        <div class="flex items-center gap-3">
          <Kbd icon="command" keys="C" />
          <span class="text-sm text-gray-600">Copy</span>
        </div>
        <div class="flex items-center gap-3">
          <Kbd icon="command" keys="V" />
          <span class="text-sm text-gray-600">Paste</span>
        </div>
        <div class="flex items-center gap-3">
          <Kbd icon="command" keys="K" variant="solid" />
          <span class="text-sm text-gray-600">Command palette</span>
        </div>
        <div class="flex items-center gap-3">
          <Kbd :keys="['⌘', 'Shift', 'P']" />
          <span class="text-sm text-gray-600">Open command</span>
        </div>
      </div>
    `,
  }),
}

export const AllSizes: Story = {
  render: () => ({
    components: { Kbd },
    template: `
      <div class="flex items-center gap-4">
        <div class="space-y-2">
          <p class="text-xs text-gray-600">Small</p>
          <Kbd :keys="['Ctrl', 'C']" size="sm" />
        </div>
        <div class="space-y-2">
          <p class="text-xs text-gray-600">Medium</p>
          <Kbd :keys="['Ctrl', 'C']" size="md" />
        </div>
        <div class="space-y-2">
          <p class="text-xs text-gray-600">Large</p>
          <Kbd :keys="['Ctrl', 'C']" size="lg" />
        </div>
      </div>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { Kbd },
    template: `
      <div class="flex items-center gap-4">
        <div class="space-y-2">
          <p class="text-xs text-gray-600">Default</p>
          <Kbd :keys="['Ctrl', 'C']" variant="default" />
        </div>
        <div class="space-y-2">
          <p class="text-xs text-gray-600">Outline</p>
          <Kbd :keys="['Ctrl', 'C']" variant="outline" />
        </div>
        <div class="space-y-2">
          <p class="text-xs text-gray-600">Solid</p>
          <Kbd :keys="['Ctrl', 'C']" variant="solid" />
        </div>
      </div>
    `,
  }),
}

export const ShortcutTable: Story = {
  render: () => ({
    components: { Kbd },
    template: `
      <div class="max-w-md">
        <h3 class="text-lg font-semibold mb-4">Keyboard Shortcuts</h3>
        <div class="border rounded-lg divide-y">
          <div class="flex items-center justify-between p-3">
            <span class="text-sm">Copy</span>
            <Kbd :keys="['Ctrl', 'C']" size="sm" />
          </div>
          <div class="flex items-center justify-between p-3">
            <span class="text-sm">Paste</span>
            <Kbd :keys="['Ctrl', 'V']" size="sm" />
          </div>
          <div class="flex items-center justify-between p-3">
            <span class="text-sm">Cut</span>
            <Kbd :keys="['Ctrl', 'X']" size="sm" />
          </div>
          <div class="flex items-center justify-between p-3">
            <span class="text-sm">Undo</span>
            <Kbd :keys="['Ctrl', 'Z']" size="sm" />
          </div>
          <div class="flex items-center justify-between p-3">
            <span class="text-sm">Redo</span>
            <Kbd :keys="['Ctrl', 'Y']" size="sm" />
          </div>
          <div class="flex items-center justify-between p-3">
            <span class="text-sm">Save</span>
            <Kbd :keys="['Ctrl', 'S']" size="sm" />
          </div>
          <div class="flex items-center justify-between p-3">
            <span class="text-sm">Open</span>
            <Kbd :keys="['Ctrl', 'O']" size="sm" />
          </div>
          <div class="flex items-center justify-between p-3">
            <span class="text-sm">Find</span>
            <Kbd :keys="['Ctrl', 'F']" size="sm" />
          </div>
        </div>
      </div>
    `,
  }),
}

export const InSentence: Story = {
  render: () => ({
    components: { Kbd },
    template: `
      <p class="text-gray-700">
        Press <Kbd keys="Enter" size="sm" /> to submit or <Kbd keys="Esc" size="sm" /> to cancel.
      </p>
    `,
  }),
}

export const CustomContent: Story = {
  render: () => ({
    components: { Kbd },
    template: `
      <div class="space-y-4">
        <Kbd>Custom</Kbd>
        <Kbd>⌘K</Kbd>
        <Kbd icon="command">K</Kbd>
        <Kbd size="lg" variant="solid">Space</Kbd>
      </div>
    `,
  }),
}
