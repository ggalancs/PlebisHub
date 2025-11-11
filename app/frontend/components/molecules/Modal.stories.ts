import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import Modal from './Modal.vue'
import Button from '../atoms/Button.vue'

const meta = {
  title: 'Molecules/Modal',
  component: Modal,
  tags: ['autodocs'],
  argTypes: {
    modelValue: { control: 'boolean' },
    title: { control: 'text' },
    size: { control: 'select', options: ['sm', 'md', 'lg', 'xl', 'full'] },
    showClose: { control: 'boolean' },
    closeOnOverlay: { control: 'boolean' },
    closeOnEscape: { control: 'boolean' },
  },
  args: {
    modelValue: false,
    size: 'md',
    showClose: true,
    closeOnOverlay: true,
    closeOnEscape: true,
  },
} satisfies Meta<typeof Modal>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: () => ({
    components: { Modal, Button },
    setup() {
      const isOpen = ref(false)
      return { isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Modal</Button>
        <Modal v-model="isOpen" title="Modal Title">
          <p>This is the modal content. You can put anything here.</p>
        </Modal>
      </div>
    `,
  }),
}

export const Sizes: Story = {
  render: () => ({
    components: { Modal, Button },
    setup() {
      const modals = ref({ sm: false, md: false, lg: false, xl: false, full: false })
      return { modals }
    },
    template: `
      <div class="space-x-2">
        <Button @click="modals.sm = true" size="sm">Small</Button>
        <Button @click="modals.md = true">Medium</Button>
        <Button @click="modals.lg = true">Large</Button>
        <Button @click="modals.xl = true">XL</Button>
        <Button @click="modals.full = true">Full</Button>

        <Modal v-model="modals.sm" title="Small Modal" size="sm"><p>Small modal content</p></Modal>
        <Modal v-model="modals.md" title="Medium Modal" size="md"><p>Medium modal content</p></Modal>
        <Modal v-model="modals.lg" title="Large Modal" size="lg"><p>Large modal content</p></Modal>
        <Modal v-model="modals.xl" title="XL Modal" size="xl"><p>XL modal content</p></Modal>
        <Modal v-model="modals.full" title="Full Modal" size="full"><p>Full modal content</p></Modal>
      </div>
    `,
  }),
}

export const WithFooter: Story = {
  render: () => ({
    components: { Modal, Button },
    setup() {
      const isOpen = ref(false)
      const handleSave = () => {
        alert('Saved!')
        isOpen.value = false
      }
      return { isOpen, handleSave }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Modal</Button>
        <Modal v-model="isOpen" title="Edit Profile">
          <p>Edit your profile information here.</p>
          <template #footer="{ close }">
            <Button variant="secondary" @click="close">Cancel</Button>
            <Button @click="handleSave">Save</Button>
          </template>
        </Modal>
      </div>
    `,
  }),
}

export const ConfirmationDialog: Story = {
  render: () => ({
    components: { Modal, Button },
    setup() {
      const isOpen = ref(false)
      const handleDelete = () => {
        alert('Deleted!')
        isOpen.value = false
      }
      return { isOpen, handleDelete }
    },
    template: `
      <div>
        <Button variant="danger" @click="isOpen = true">Delete Item</Button>
        <Modal v-model="isOpen" title="Confirm Deletion" size="sm">
          <p class="text-gray-600">Are you sure you want to delete this item? This action cannot be undone.</p>
          <template #footer="{ close }">
            <Button variant="secondary" @click="close">Cancel</Button>
            <Button variant="danger" @click="handleDelete">Delete</Button>
          </template>
        </Modal>
      </div>
    `,
  }),
}

export const Form: Story = {
  render: () => ({
    components: { Modal, Button },
    setup() {
      const isOpen = ref(false)
      return { isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Create User</Button>
        <Modal v-model="isOpen" title="Create New User" size="lg">
          <form class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Name</label>
              <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
              <input type="email" class="w-full px-3 py-2 border border-gray-300 rounded-md" />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Role</label>
              <select class="w-full px-3 py-2 border border-gray-300 rounded-md">
                <option>User</option>
                <option>Admin</option>
              </select>
            </div>
          </form>
          <template #footer="{ close }">
            <Button variant="secondary" @click="close">Cancel</Button>
            <Button @click="close">Create</Button>
          </template>
        </Modal>
      </div>
    `,
  }),
}

export const LongContent: Story = {
  render: () => ({
    components: { Modal, Button },
    setup() {
      const isOpen = ref(false)
      return { isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Long Modal</Button>
        <Modal v-model="isOpen" title="Terms and Conditions">
          <div class="space-y-4 text-gray-600">
            <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
            <p>Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
            <p>Ut enim ad minim veniam, quis nostrud exercitation ullamco.</p>
            <p>Duis aute irure dolor in reprehenderit in voluptate velit esse.</p>
            <p>Excepteur sint occaecat cupidatat non proident, sunt in culpa.</p>
            <p>Sed ut perspiciatis unde omnis iste natus error sit voluptatem.</p>
            <p>Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit.</p>
            <p>Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet.</p>
          </div>
          <template #footer="{ close }">
            <Button @click="close">I Agree</Button>
          </template>
        </Modal>
      </div>
    `,
  }),
}

export const NoCloseButton: Story = {
  render: () => ({
    components: { Modal, Button },
    setup() {
      const isOpen = ref(false)
      return { isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Modal</Button>
        <Modal v-model="isOpen" title="Important Message" :show-close="false">
          <p>You must acknowledge this message to continue.</p>
          <template #footer="{ close }">
            <Button @click="close">I Understand</Button>
          </template>
        </Modal>
      </div>
    `,
  }),
}

export const CustomHeader: Story = {
  render: () => ({
    components: { Modal, Button },
    setup() {
      const isOpen = ref(false)
      return { isOpen }
    },
    template: `
      <div>
        <Button @click="isOpen = true">Open Modal</Button>
        <Modal v-model="isOpen">
          <template #header>
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                <svg class="w-6 h-6 text-primary-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div>
                <h3 class="text-lg font-semibold">Success!</h3>
                <p class="text-sm text-gray-500">Your changes have been saved</p>
              </div>
            </div>
          </template>
          <p>Your profile has been successfully updated.</p>
          <template #footer="{ close }">
            <Button @click="close">Close</Button>
          </template>
        </Modal>
      </div>
    `,
  }),
}
