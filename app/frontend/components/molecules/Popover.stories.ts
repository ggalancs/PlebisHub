import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Popover from './Popover.vue'
import Button from '../atoms/Button.vue'

const meta = {
  title: 'Molecules/Popover',
  component: Popover,
  tags: ['autodocs'],
  argTypes: {
    trigger: {
      control: 'select',
      options: ['click', 'hover', 'focus'],
    },
    placement: {
      control: 'select',
      options: [
        'top',
        'bottom',
        'left',
        'right',
        'top-start',
        'top-end',
        'bottom-start',
        'bottom-end',
        'left-start',
        'left-end',
        'right-start',
        'right-end',
      ],
    },
    showArrow: {
      control: 'boolean',
    },
    showCloseButton: {
      control: 'boolean',
    },
    disabled: {
      control: 'boolean',
    },
    offset: {
      control: 'number',
    },
  },
} satisfies Meta<typeof Popover>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Click me</Button>
          </template>
          <p>This is a simple popover with default settings.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'bottom',
  },
}

export const WithTitle: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Show Info</Button>
          </template>
          <p>Additional information about this feature can be found here.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'bottom',
    title: 'Information',
  },
}

export const WithCloseButton: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Open Popover</Button>
          </template>
          <p>This popover has a close button in the header.</p>
          <p class="mt-2">You can click the X button to close it.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'bottom',
    title: 'Closeable Popover',
    showCloseButton: true,
  },
}

export const HoverTrigger: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Hover me</Button>
          </template>
          <p>This popover appears on hover and disappears when you move away.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'hover',
    placement: 'top',
    title: 'Hover Popover',
  },
}

export const FocusTrigger: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Focus me</Button>
          </template>
          <p>This popover appears when the button is focused.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'focus',
    placement: 'bottom',
    title: 'Focus Popover',
  },
}

export const TopPlacement: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Top</Button>
          </template>
          <p>This popover appears above the trigger.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'top',
  },
}

export const LeftPlacement: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Left</Button>
          </template>
          <p>This popover appears to the left of the trigger.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'left',
  },
}

export const RightPlacement: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Right</Button>
          </template>
          <p>This popover appears to the right of the trigger.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'right',
  },
}

export const NoArrow: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>No Arrow</Button>
          </template>
          <p>This popover has no arrow indicator.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'bottom',
    showArrow: false,
  },
}

export const Controlled: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      const isOpen = ref(false)
      const toggle = () => {
        isOpen.value = !isOpen.value
      }
      return { args, isOpen, toggle }
    },
    template: `
      <div class="flex flex-col items-center justify-center gap-4 p-8">
        <Button @click="toggle">
          {{ isOpen ? 'Close' : 'Open' }} Popover
        </Button>
        <Popover v-bind="args" v-model="isOpen">
          <template #trigger>
            <Button variant="outline">Controlled Trigger</Button>
          </template>
          <p>This is a controlled popover. Its state is managed externally.</p>
          <Button class="mt-4" size="sm" @click="toggle">Close from inside</Button>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'bottom',
    title: 'Controlled Popover',
  },
}

export const WithActions: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      const handleSave = () => {
        alert('Saved!')
      }
      const handleCancel = () => {
        alert('Cancelled!')
      }
      return { args, handleSave, handleCancel }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Delete Item</Button>
          </template>
          <p class="mb-4">Are you sure you want to delete this item? This action cannot be undone.</p>
          <div class="flex justify-end gap-2">
            <Button size="sm" variant="outline" @click="handleCancel">Cancel</Button>
            <Button size="sm" variant="primary" @click="handleSave">Delete</Button>
          </div>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'bottom',
    title: 'Confirm Deletion',
    width: '300px',
  },
}

export const CustomWidth: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Wide Popover</Button>
          </template>
          <p>This popover has a custom width of 400px.</p>
          <p class="mt-2">It can accommodate more content horizontally.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'bottom',
    title: 'Custom Width',
    width: '400px',
  },
}

export const Disabled: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="flex items-center justify-center p-8">
        <Popover v-bind="args">
          <template #trigger>
            <Button>Disabled Popover</Button>
          </template>
          <p>This popover is disabled and won't open.</p>
        </Popover>
      </div>
    `,
  }),
  args: {
    trigger: 'click',
    placement: 'bottom',
    disabled: true,
  },
}

export const AllPlacements: Story = {
  render: (args) => ({
    components: { Popover, Button },
    setup() {
      return { args }
    },
    template: `
      <div class="grid grid-cols-3 gap-8 p-8">
        <Popover placement="top-start">
          <template #trigger><Button>Top Start</Button></template>
          <p>Top Start</p>
        </Popover>
        <Popover placement="top">
          <template #trigger><Button>Top</Button></template>
          <p>Top</p>
        </Popover>
        <Popover placement="top-end">
          <template #trigger><Button>Top End</Button></template>
          <p>Top End</p>
        </Popover>

        <Popover placement="left-start">
          <template #trigger><Button>Left Start</Button></template>
          <p>Left Start</p>
        </Popover>
        <div class="flex items-center justify-center">
          <span class="text-gray-500">Center Reference</span>
        </div>
        <Popover placement="right-start">
          <template #trigger><Button>Right Start</Button></template>
          <p>Right Start</p>
        </Popover>

        <Popover placement="left">
          <template #trigger><Button>Left</Button></template>
          <p>Left</p>
        </Popover>
        <div></div>
        <Popover placement="right">
          <template #trigger><Button>Right</Button></template>
          <p>Right</p>
        </Popover>

        <Popover placement="left-end">
          <template #trigger><Button>Left End</Button></template>
          <p>Left End</p>
        </Popover>
        <div></div>
        <Popover placement="right-end">
          <template #trigger><Button>Right End</Button></template>
          <p>Right End</p>
        </Popover>

        <Popover placement="bottom-start">
          <template #trigger><Button>Bottom Start</Button></template>
          <p>Bottom Start</p>
        </Popover>
        <Popover placement="bottom">
          <template #trigger><Button>Bottom</Button></template>
          <p>Bottom</p>
        </Popover>
        <Popover placement="bottom-end">
          <template #trigger><Button>Bottom End</Button></template>
          <p>Bottom End</p>
        </Popover>
      </div>
    `,
  }),
}
