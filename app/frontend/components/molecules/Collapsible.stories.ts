import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import Collapsible from './Collapsible.vue'

const meta = {
  title: 'Molecules/Collapsible',
  component: Collapsible,
  tags: ['autodocs'],
} satisfies Meta<typeof Collapsible>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    title: 'Click to expand',
  },
  render: (args) => ({
    components: { Collapsible },
    setup() {
      return { args }
    },
    template: `
      <Collapsible v-bind="args">
        <p>This is the collapsible content. It can contain any HTML elements.</p>
      </Collapsible>
    `,
  }),
}

export const InitiallyOpen: Story = {
  args: {
    title: 'Initially Open',
    modelValue: true,
  },
  render: (args) => ({
    components: { Collapsible },
    setup() {
      return { args }
    },
    template: `
      <Collapsible v-bind="args">
        <p>This collapsible starts in an open state.</p>
      </Collapsible>
    `,
  }),
}

export const Disabled: Story = {
  args: {
    title: 'Disabled Collapsible',
    disabled: true,
  },
  render: (args) => ({
    components: { Collapsible },
    setup() {
      return { args }
    },
    template: `
      <Collapsible v-bind="args">
        <p>This content cannot be toggled because the collapsible is disabled.</p>
      </Collapsible>
    `,
  }),
}

export const CustomIcons: Story = {
  args: {
    title: 'Custom Icons',
    iconCollapsed: 'plus',
    iconExpanded: 'minus',
  },
  render: (args) => ({
    components: { Collapsible },
    setup() {
      return { args }
    },
    template: `
      <Collapsible v-bind="args">
        <p>This uses custom plus/minus icons instead of chevrons.</p>
      </Collapsible>
    `,
  }),
}

export const Interactive: Story = {
  render: () => ({
    components: { Collapsible },
    setup() {
      const isOpen = ref(false)
      return { isOpen }
    },
    template: `
      <div class="space-y-4">
        <Collapsible v-model="isOpen" title="FAQ: What is PlebisHub?">
          <p class="mb-2">
            PlebisHub is a decentralized social platform built on blockchain technology.
            It enables users to connect, share, and engage in a censorship-resistant environment.
          </p>
          <p>
            Our platform prioritizes user privacy, data ownership, and freedom of expression.
          </p>
        </Collapsible>

        <div class="text-sm text-gray-600">
          Status: {{ isOpen ? 'Open' : 'Closed' }}
        </div>
      </div>
    `,
  }),
}

export const MultipleSections: Story = {
  render: () => ({
    components: { Collapsible },
    template: `
      <div class="space-y-3">
        <Collapsible title="Section 1: Getting Started">
          <p>Learn the basics of using our platform.</p>
          <ul class="list-disc list-inside mt-2 space-y-1">
            <li>Create an account</li>
            <li>Set up your profile</li>
            <li>Connect with others</li>
          </ul>
        </Collapsible>

        <Collapsible title="Section 2: Advanced Features">
          <p>Explore our advanced capabilities.</p>
          <ul class="list-disc list-inside mt-2 space-y-1">
            <li>Blockchain integration</li>
            <li>Smart contracts</li>
            <li>Decentralized storage</li>
          </ul>
        </Collapsible>

        <Collapsible title="Section 3: Support">
          <p>Get help when you need it.</p>
          <ul class="list-disc list-inside mt-2 space-y-1">
            <li>Documentation</li>
            <li>Community forums</li>
            <li>Contact support</li>
          </ul>
        </Collapsible>
      </div>
    `,
  }),
}
