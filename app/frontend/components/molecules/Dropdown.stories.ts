import type { Meta, StoryObj } from '@storybook/vue3-vite'
import Dropdown, { type DropdownItem } from './Dropdown.vue'

const meta = {
  title: 'Molecules/Dropdown',
  component: Dropdown,
  tags: ['autodocs'],
  argTypes: {
    items: {
      control: 'object',
      description: 'Dropdown items array',
    },
    label: {
      control: 'text',
      description: 'Trigger button label',
    },
    icon: {
      control: 'text',
      description: 'Trigger button icon',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Size variant',
    },
    placement: {
      control: 'select',
      options: ['bottom-start', 'bottom-end', 'top-start', 'top-end'],
      description: 'Dropdown placement',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    fullWidth: {
      control: 'boolean',
      description: 'Full width',
    },
  },
  args: {
    label: 'Options',
    size: 'md',
    placement: 'bottom-start',
    disabled: false,
    fullWidth: false,
  },
} satisfies Meta<typeof Dropdown>

export default meta
type Story = StoryObj<typeof meta>

// Default dropdown
export const Default: Story = {
  args: {
    items: [
      { key: 'edit', label: 'Edit' },
      { key: 'duplicate', label: 'Duplicate' },
      { key: 'archive', label: 'Archive' },
      { key: 'delete', label: 'Delete' },
    ],
  },
}

// With icons
export const WithIcons: Story = {
  args: {
    label: 'Actions',
    items: [
      { key: 'edit', label: 'Edit', icon: 'edit' },
      { key: 'copy', label: 'Duplicate', icon: 'copy' },
      { key: 'archive', label: 'Archive', icon: 'archive' },
      { key: 'delete', label: 'Delete', icon: 'trash' },
    ],
  },
}

// With badges
export const WithBadges: Story = {
  args: {
    label: 'Messages',
    icon: 'inbox',
    items: [
      { key: 'inbox', label: 'Inbox', icon: 'inbox', badge: 12, badgeVariant: 'primary' },
      { key: 'sent', label: 'Sent', icon: 'send', badge: 0 },
      { key: 'drafts', label: 'Drafts', icon: 'file-text', badge: 3, badgeVariant: 'warning' },
      { key: 'spam', label: 'Spam', icon: 'alert-triangle', badge: '99+', badgeVariant: 'danger' },
    ],
  },
}

// With dividers
export const WithDividers: Story = {
  args: {
    label: 'Actions',
    items: [
      { key: 'edit', label: 'Edit', icon: 'edit' },
      { key: 'duplicate', label: 'Duplicate', icon: 'copy', divider: true },
      { key: 'archive', label: 'Archive', icon: 'archive', divider: true },
      { key: 'delete', label: 'Delete', icon: 'trash', danger: true },
    ],
  },
}

// Danger items
export const DangerItems: Story = {
  args: {
    label: 'Actions',
    items: [
      { key: 'edit', label: 'Edit', icon: 'edit' },
      { key: 'duplicate', label: 'Duplicate', icon: 'copy' },
      { key: 'archive', label: 'Archive', icon: 'archive', divider: true },
      { key: 'delete', label: 'Delete', icon: 'trash', danger: true },
      { key: 'destroy', label: 'Permanent Delete', icon: 'x-circle', danger: true },
    ],
  },
}

// Disabled items
export const DisabledItems: Story = {
  args: {
    label: 'Actions',
    items: [
      { key: 'edit', label: 'Edit', icon: 'edit' },
      { key: 'duplicate', label: 'Duplicate', icon: 'copy', disabled: true },
      { key: 'archive', label: 'Archive', icon: 'archive' },
      { key: 'delete', label: 'Delete', icon: 'trash', danger: true, disabled: true },
    ],
  },
}

// Different sizes
export const Sizes: Story = {
  render: () => ({
    components: { Dropdown },
    setup() {
      const items = [
        { key: 'edit', label: 'Edit', icon: 'edit' },
        { key: 'duplicate', label: 'Duplicate', icon: 'copy' },
        { key: 'delete', label: 'Delete', icon: 'trash' },
      ]
      return { items }
    },
    template: `
      <div class="space-y-4">
        <div>
          <p class="text-sm text-gray-600 mb-2">Small</p>
          <Dropdown :items="items" label="Actions" size="sm" />
        </div>

        <div>
          <p class="text-sm text-gray-600 mb-2">Medium (Default)</p>
          <Dropdown :items="items" label="Actions" size="md" />
        </div>

        <div>
          <p class="text-sm text-gray-600 mb-2">Large</p>
          <Dropdown :items="items" label="Actions" size="lg" />
        </div>
      </div>
    `,
  }),
}

// Different placements
export const Placements: Story = {
  render: () => ({
    components: { Dropdown },
    setup() {
      const items = [
        { key: 'edit', label: 'Edit' },
        { key: 'duplicate', label: 'Duplicate' },
        { key: 'delete', label: 'Delete' },
      ]
      return { items }
    },
    template: `
      <div class="grid grid-cols-2 gap-8 p-8">
        <div>
          <p class="text-sm text-gray-600 mb-2">Bottom Start (Default)</p>
          <Dropdown :items="items" label="Bottom Start" placement="bottom-start" />
        </div>

        <div class="flex justify-end">
          <div>
            <p class="text-sm text-gray-600 mb-2">Bottom End</p>
            <Dropdown :items="items" label="Bottom End" placement="bottom-end" />
          </div>
        </div>

        <div class="mt-32">
          <p class="text-sm text-gray-600 mb-2">Top Start</p>
          <Dropdown :items="items" label="Top Start" placement="top-start" />
        </div>

        <div class="mt-32 flex justify-end">
          <div>
            <p class="text-sm text-gray-600 mb-2">Top End</p>
            <Dropdown :items="items" label="Top End" placement="top-end" />
          </div>
        </div>
      </div>
    `,
  }),
}

// Full width
export const FullWidth: Story = {
  args: {
    label: 'Select Action',
    fullWidth: true,
    items: [
      { key: 'export', label: 'Export Data', icon: 'download' },
      { key: 'import', label: 'Import Data', icon: 'upload' },
      { key: 'settings', label: 'Settings', icon: 'settings' },
    ],
  },
}

// Disabled
export const Disabled: Story = {
  args: {
    label: 'Actions',
    disabled: true,
    items: [
      { key: 'edit', label: 'Edit' },
      { key: 'delete', label: 'Delete' },
    ],
  },
}

// User menu
export const UserMenu: Story = {
  render: () => ({
    components: { Dropdown },
    setup() {
      const handleSelect = (item: DropdownItem) => {
        console.log('Selected:', item.label)
        alert(`Selected: ${item.label}`)
      }

      const items = [
        { key: 'profile', label: 'Your Profile', icon: 'user' },
        { key: 'settings', label: 'Settings', icon: 'settings', divider: true },
        { key: 'team', label: 'Team', icon: 'users' },
        {
          key: 'billing',
          label: 'Billing',
          icon: 'credit-card',
          badge: 'Pro',
          badgeVariant: 'success' as const,
          divider: true,
        },
        { key: 'logout', label: 'Sign out', icon: 'log-out' },
      ]

      return { items, handleSelect }
    },
    template: `
      <div class="flex justify-end">
        <Dropdown
          :items="items"
          label="John Doe"
          icon="user"
          placement="bottom-end"
          @select="handleSelect"
        />
      </div>
    `,
  }),
}

// Actions menu
export const ActionsMenu: Story = {
  render: () => ({
    components: { Dropdown },
    setup() {
      const handleSelect = (item: DropdownItem) => {
        console.log('Action:', item.label)
      }

      const items = [
        { key: 'view', label: 'View Details', icon: 'eye' },
        { key: 'edit', label: 'Edit', icon: 'edit' },
        { key: 'duplicate', label: 'Duplicate', icon: 'copy', divider: true },
        { key: 'download', label: 'Download', icon: 'download' },
        { key: 'share', label: 'Share', icon: 'share', divider: true },
        { key: 'archive', label: 'Archive', icon: 'archive' },
        { key: 'delete', label: 'Delete', icon: 'trash', danger: true },
      ]

      return { items, handleSelect }
    },
    template: `
      <Dropdown
        :items="items"
        icon="more-vertical"
        label=""
        @select="handleSelect"
      />
    `,
  }),
}

// Status selector
export const StatusSelector: Story = {
  render: () => ({
    components: { Dropdown },
    setup() {
      const items = [
        { key: 'active', label: 'Active', icon: 'check-circle', badgeVariant: 'success' as const },
        { key: 'pending', label: 'Pending', icon: 'clock', badgeVariant: 'warning' as const },
        { key: 'inactive', label: 'Inactive', icon: 'x-circle', badgeVariant: 'danger' as const },
      ]

      return { items }
    },
    template: `
      <Dropdown
        :items="items"
        label="Change Status"
        icon="refresh-cw"
      />
    `,
  }),
}

// Export options
export const ExportOptions: Story = {
  render: () => ({
    components: { Dropdown },
    setup() {
      const items = [
        { key: 'csv', label: 'Export as CSV', icon: 'file-text' },
        { key: 'excel', label: 'Export as Excel', icon: 'file-spreadsheet' },
        { key: 'pdf', label: 'Export as PDF', icon: 'file' },
        { key: 'json', label: 'Export as JSON', icon: 'code', divider: true },
        { key: 'print', label: 'Print', icon: 'printer' },
      ]

      return { items }
    },
    template: `
      <Dropdown
        :items="items"
        label="Export"
        icon="download"
      />
    `,
  }),
}

// Interactive example
export const Interactive: Story = {
  render: (args) => ({
    components: { Dropdown },
    setup() {
      const lastSelected = ref('')

      const handleSelect = (item: DropdownItem) => {
        lastSelected.value = item.label
        console.log('Selected:', item)
      }

      const items = [
        { key: 'edit', label: 'Edit', icon: 'edit' },
        { key: 'duplicate', label: 'Duplicate', icon: 'copy' },
        { key: 'archive', label: 'Archive', icon: 'archive', divider: true },
        { key: 'delete', label: 'Delete', icon: 'trash', danger: true },
      ]

      return { args, items, handleSelect, lastSelected }
    },
    template: `
      <div class="space-y-4">
        <Dropdown
          v-bind="args"
          :items="items"
          @select="handleSelect"
        />

        <div v-if="lastSelected" class="p-3 bg-gray-50 border rounded">
          <p class="text-sm"><strong>Last selected:</strong> {{ lastSelected }}</p>
        </div>
      </div>
    `,
  }),
  args: {
    label: 'Actions',
    icon: 'more-horizontal',
  },
}

// Table row actions
export const TableRowActions: Story = {
  render: () => ({
    components: { Dropdown },
    setup() {
      const users = [
        { id: 1, name: 'John Doe', email: 'john@example.com', role: 'Admin' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'User' },
        { id: 3, name: 'Bob Johnson', email: 'bob@example.com', role: 'User' },
      ]

      const items = [
        { key: 'view', label: 'View', icon: 'eye' },
        { key: 'edit', label: 'Edit', icon: 'edit' },
        { key: 'permissions', label: 'Permissions', icon: 'shield', divider: true },
        { key: 'delete', label: 'Delete', icon: 'trash', danger: true },
      ]

      const handleSelect = (user: (typeof users)[0], item: DropdownItem) => {
        console.log(`Action "${item.label}" on user:`, user.name)
      }

      return { users, items, handleSelect }
    },
    template: `
      <div class="border rounded-lg overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
              <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Actions</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{{ user.name }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ user.email }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ user.role }}</td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm">
                <div class="flex justify-end">
                  <Dropdown
                    :items="items"
                    label=""
                    icon="more-vertical"
                    size="sm"
                    placement="bottom-end"
                    @select="(item) => handleSelect(user, item)"
                  />
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    `,
  }),
}

// Showcase all
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Dropdown },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="flex items-center gap-4">
            <Dropdown
              :items="[{key: '1', label: 'Edit'}, {key: '2', label: 'Delete'}]"
              label="Small"
              size="sm"
            />
            <Dropdown
              :items="[{key: '1', label: 'Edit'}, {key: '2', label: 'Delete'}]"
              label="Medium"
              size="md"
            />
            <Dropdown
              :items="[{key: '1', label: 'Edit'}, {key: '2', label: 'Delete'}]"
              label="Large"
              size="lg"
            />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Icons and Badges</h3>
          <Dropdown
            :items="[
              {key: 'inbox', label: 'Inbox', icon: 'inbox', badge: 12},
              {key: 'sent', label: 'Sent', icon: 'send'},
              {key: 'drafts', label: 'Drafts', icon: 'file-text', badge: 3}
            ]"
            label="Messages"
            icon="mail"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Dividers</h3>
          <Dropdown
            :items="[
              {key: 'edit', label: 'Edit', icon: 'edit'},
              {key: 'copy', label: 'Copy', icon: 'copy', divider: true},
              {key: 'delete', label: 'Delete', icon: 'trash', danger: true}
            ]"
            label="Actions"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Disabled</h3>
          <Dropdown
            :items="[{key: '1', label: 'Action 1'}, {key: '2', label: 'Action 2'}]"
            label="Actions"
            :disabled="true"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Full Width</h3>
          <Dropdown
            :items="[{key: '1', label: 'Option 1'}, {key: '2', label: 'Option 2'}]"
            label="Select Option"
            :full-width="true"
          />
        </div>
      </div>
    `,
  }),
}
