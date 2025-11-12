import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Drawer from './Drawer.vue'
import Button from '../atoms/Button.vue'

const meta = {
  title: 'Molecules/Drawer',
  component: Drawer,
  tags: ['autodocs'],
  argTypes: {
    position: {
      control: 'select',
      options: ['left', 'right', 'top', 'bottom'],
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg', 'full'],
    },
    closeOnOutsideClick: {
      control: 'boolean',
    },
    closeOnEscape: {
      control: 'boolean',
    },
    showCloseButton: {
      control: 'boolean',
    },
    backdrop: {
      control: 'boolean',
    },
    backdropBlur: {
      control: 'boolean',
    },
    lockScroll: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof Drawer>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This is the drawer content. You can put any content here.</p>
          <p class="mt-4">Click outside, press Escape, or click the close button to close.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'right',
    size: 'md',
  },
}

export const WithTitle: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This drawer has a title and description in the header.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'right',
    size: 'md',
    title: 'Drawer Title',
    description: 'This is a description of the drawer content',
  },
}

export const WithFooter: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      const handleSave = () => {
        alert('Saved!')
        isOpen.value = false
      }
      const handleCancel = () => {
        isOpen.value = false
      }
      return { args, isOpen, handleSave, handleCancel }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <template #default>
            <p>This drawer has action buttons in the footer.</p>
            <div class="mt-4 space-y-4">
              <div>
                <label class="block text-sm font-medium mb-1">Name</label>
                <input type="text" class="w-full border rounded px-3 py-2" />
              </div>
              <div>
                <label class="block text-sm font-medium mb-1">Email</label>
                <input type="email" class="w-full border rounded px-3 py-2" />
              </div>
            </div>
          </template>
          <template #footer>
            <div class="flex justify-end gap-2">
              <Button variant="outline" @click="handleCancel">Cancel</Button>
              <Button @click="handleSave">Save</Button>
            </div>
          </template>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'right',
    size: 'md',
    title: 'Edit Profile',
  },
}

export const LeftPosition: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Left Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This drawer slides in from the left.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'left',
    size: 'md',
    title: 'Left Drawer',
  },
}

export const TopPosition: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Top Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This drawer slides in from the top.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'top',
    size: 'md',
    title: 'Top Drawer',
  },
}

export const BottomPosition: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Bottom Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This drawer slides in from the bottom.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'bottom',
    size: 'md',
    title: 'Bottom Drawer',
  },
}

export const SmallSize: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Small Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This is a small drawer.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'right',
    size: 'sm',
    title: 'Small Drawer',
  },
}

export const LargeSize: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Large Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This is a large drawer.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'right',
    size: 'lg',
    title: 'Large Drawer',
  },
}

export const FullSize: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Full Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This drawer takes up the full width/height.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'right',
    size: 'full',
    title: 'Full Size Drawer',
  },
}

export const NoBackdrop: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This drawer has no backdrop.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'right',
    size: 'md',
    title: 'No Backdrop',
    backdrop: false,
  },
}

export const NoCloseButton: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This drawer has no close button. You can only close it by clicking outside or pressing Escape.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'right',
    size: 'md',
    title: 'No Close Button',
    showCloseButton: false,
  },
}

export const PersistentDrawer: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Drawer</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <p>This drawer cannot be closed by clicking outside or pressing Escape.</p>
          <p class="mt-4">You must use the close button.</p>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'right',
    size: 'md',
    title: 'Persistent Drawer',
    closeOnOutsideClick: false,
    closeOnEscape: false,
  },
}

export const NavigationMenu: Story = {
  render: (args) => ({
    components: { Drawer, Button },
    setup() {
      const isOpen = ref(false)
      return { args, isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Menu</Button>
        <Drawer v-bind="args" v-model="isOpen">
          <nav class="space-y-1">
            <a href="#" class="block px-4 py-2 rounded hover:bg-gray-100">Dashboard</a>
            <a href="#" class="block px-4 py-2 rounded hover:bg-gray-100">Projects</a>
            <a href="#" class="block px-4 py-2 rounded hover:bg-gray-100">Team</a>
            <a href="#" class="block px-4 py-2 rounded hover:bg-gray-100">Settings</a>
            <hr class="my-4" />
            <a href="#" class="block px-4 py-2 rounded hover:bg-gray-100 text-red-600">Logout</a>
          </nav>
        </Drawer>
      </div>
    `,
  }),
  args: {
    position: 'left',
    size: 'sm',
    title: 'Navigation',
  },
}
