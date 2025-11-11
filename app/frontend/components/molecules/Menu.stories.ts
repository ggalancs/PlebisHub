import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import Menu from './Menu.vue'
import Button from '../atoms/Button.vue'
import type { MenuItem } from './Menu.vue'

const meta = {
  title: 'Molecules/Menu',
  component: Menu,
  tags: ['autodocs'],
} satisfies Meta<typeof Menu>

export default meta
type Story = StoryObj<typeof meta>

const basicItems: MenuItem[] = [
  { id: 1, label: 'Edit', icon: 'edit' },
  { id: 2, label: 'Duplicate', icon: 'copy' },
  { id: 3, label: 'Archive', icon: 'archive' },
  { id: 'sep1', label: '', separator: true },
  { id: 4, label: 'Delete', icon: 'trash', destructive: true },
]

export const Default: Story = {
  args: {
    items: basicItems,
    modelValue: true,
  },
}

export const WithShortcuts: Story = {
  args: {
    items: [
      { id: 1, label: 'New File', icon: 'file-plus', shortcut: '⌘N' },
      { id: 2, label: 'Open File', icon: 'folder-open', shortcut: '⌘O' },
      { id: 3, label: 'Save', icon: 'save', shortcut: '⌘S' },
      { id: 4, label: 'Save As...', icon: 'save', shortcut: '⌘⇧S' },
      { id: 'sep1', label: '', separator: true },
      { id: 5, label: 'Close', shortcut: '⌘W' },
    ],
    modelValue: true,
  },
}

export const WithDisabled: Story = {
  args: {
    items: [
      { id: 1, label: 'Cut', icon: 'scissors', shortcut: '⌘X' },
      { id: 2, label: 'Copy', icon: 'copy', shortcut: '⌘C' },
      { id: 3, label: 'Paste', icon: 'clipboard', shortcut: '⌘V', disabled: true },
      { id: 'sep1', label: '', separator: true },
      { id: 4, label: 'Select All', shortcut: '⌘A' },
    ],
    modelValue: true,
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { Menu, Button },
    setup() {
      const isOpen = ref(false)
      const lastAction = ref('')

      const items: MenuItem[] = [
        { id: 1, label: 'Edit', icon: 'edit' },
        { id: 2, label: 'Duplicate', icon: 'copy' },
        { id: 3, label: 'Share', icon: 'share-2' },
        { id: 'sep1', label: '', separator: true },
        { id: 4, label: 'Delete', icon: 'trash', destructive: true },
      ]

      const handleSelect = (item: MenuItem) => {
        lastAction.value = `Selected: ${item.label}`
      }

      return { isOpen, lastAction, items, handleSelect }
    },
    template: `
      <div class="space-y-4">
        <Button @click="isOpen = !isOpen">
          {{ isOpen ? 'Close Menu' : 'Open Menu' }}
        </Button>

        <div v-if="isOpen" class="relative inline-block">
          <Menu
            v-model="isOpen"
            :items="items"
            @select="handleSelect"
          />
        </div>

        <div v-if="lastAction" class="p-3 bg-gray-100 rounded text-sm">
          {{ lastAction }}
        </div>
      </div>
    `,
  }),
}

export const FileMenu: Story = {
  render: () => ({
    components: { Menu },
    setup() {
      const items: MenuItem[] = [
        { id: 1, label: 'New Tab', icon: 'plus', shortcut: '⌘T' },
        { id: 2, label: 'New Window', icon: 'layout', shortcut: '⌘N' },
        { id: 3, label: 'New Private Window', icon: 'eye-off', shortcut: '⌘⇧N' },
        { id: 'sep1', label: '', separator: true },
        { id: 4, label: 'Open File...', icon: 'folder-open', shortcut: '⌘O' },
        { id: 5, label: 'Open Location...', icon: 'link', shortcut: '⌘L' },
        { id: 'sep2', label: '', separator: true },
        { id: 6, label: 'Close Tab', shortcut: '⌘W' },
        { id: 7, label: 'Close Window', shortcut: '⌘⇧W' },
        { id: 'sep3', label: '', separator: true },
        { id: 8, label: 'Save Page As...', icon: 'download', shortcut: '⌘S' },
        { id: 9, label: 'Print...', icon: 'printer', shortcut: '⌘P' },
      ]
      return { items }
    },
    template: '<Menu :items="items" :model-value="true" />',
  }),
}

export const EditMenu: Story = {
  render: () => ({
    components: { Menu },
    setup() {
      const items: MenuItem[] = [
        { id: 1, label: 'Undo', icon: 'undo', shortcut: '⌘Z' },
        { id: 2, label: 'Redo', icon: 'redo', shortcut: '⌘⇧Z' },
        { id: 'sep1', label: '', separator: true },
        { id: 3, label: 'Cut', icon: 'scissors', shortcut: '⌘X' },
        { id: 4, label: 'Copy', icon: 'copy', shortcut: '⌘C' },
        { id: 5, label: 'Paste', icon: 'clipboard', shortcut: '⌘V' },
        { id: 6, label: 'Paste and Match Style', icon: 'clipboard', shortcut: '⌘⇧V' },
        { id: 'sep2', label: '', separator: true },
        { id: 7, label: 'Select All', shortcut: '⌘A' },
        { id: 8, label: 'Find', icon: 'search', shortcut: '⌘F' },
      ]
      return { items }
    },
    template: '<Menu :items="items" :model-value="true" />',
  }),
}

export const ContextMenu: Story = {
  render: () => ({
    components: { Menu },
    setup() {
      const items: MenuItem[] = [
        { id: 1, label: 'Open', icon: 'external-link' },
        { id: 2, label: 'Open in New Tab', icon: 'plus' },
        { id: 'sep1', label: '', separator: true },
        { id: 3, label: 'Copy Link', icon: 'link' },
        { id: 4, label: 'Copy Image', icon: 'image', disabled: true },
        { id: 'sep2', label: '', separator: true },
        { id: 5, label: 'Save Link As...', icon: 'download' },
        { id: 6, label: 'Save Image As...', icon: 'download', disabled: true },
        { id: 'sep3', label: '', separator: true },
        { id: 7, label: 'Inspect', icon: 'code' },
      ]
      return { items }
    },
    template: '<Menu :items="items" :model-value="true" />',
  }),
}
