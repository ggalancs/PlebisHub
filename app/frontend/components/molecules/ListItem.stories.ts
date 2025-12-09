import type { Meta, StoryObj } from '@storybook/vue3'
import ListItem from './ListItem.vue'

const meta = {
  title: 'Molecules/ListItem',
  component: ListItem,
  tags: ['autodocs'],
} satisfies Meta<typeof ListItem>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    title: 'List Item',
    subtitle: 'This is a description',
  },
}

export const WithIcon: Story = {
  args: {
    title: 'User Settings',
    subtitle: 'Manage your account preferences',
    icon: 'settings',
  },
}

export const WithAvatar: Story = {
  args: {
    title: 'John Doe',
    subtitle: 'john@example.com',
    avatar: 'https://i.pravatar.cc/150?img=1',
  },
}

export const WithBadge: Story = {
  args: {
    title: 'Notifications',
    subtitle: 'You have unread messages',
    icon: 'bell',
    badge: '5',
  },
}

export const WithChevron: Story = {
  args: {
    title: 'View Details',
    subtitle: 'Click to see more',
    icon: 'file-text',
    chevron: true,
  },
}

export const Clickable: Story = {
  args: {
    title: 'Clickable Item',
    subtitle: 'Click me',
    icon: 'mouse-pointer',
    clickable: true,
  },
}

export const AsLink: Story = {
  args: {
    title: 'External Link',
    subtitle: 'Opens in new window',
    icon: 'external-link',
    href: 'https://example.com',
    chevron: true,
  },
}

export const Active: Story = {
  args: {
    title: 'Active Item',
    subtitle: 'Currently selected',
    icon: 'check-circle',
    active: true,
  },
}

export const Disabled: Story = {
  args: {
    title: 'Disabled Item',
    subtitle: 'Not available',
    icon: 'x-circle',
    disabled: true,
  },
}

export const WithDivider: Story = {
  args: {
    title: 'List Item',
    subtitle: 'With bottom border',
    divider: true,
  },
}

export const SmallSize: Story = {
  args: {
    title: 'Small Item',
    subtitle: 'Compact size',
    icon: 'minimize-2',
    size: 'sm',
  },
}

export const LargeSize: Story = {
  args: {
    title: 'Large Item',
    subtitle: 'Spacious size',
    icon: 'maximize-2',
    size: 'lg',
  },
}

export const CompleteList: Story = {
  render: () => ({
    components: { ListItem },
    template: `
      <div class="border rounded-lg overflow-hidden">
        <ListItem
          title="Inbox"
          subtitle="23 unread messages"
          icon="inbox"
          badge="23"
          chevron
          clickable
          divider
        />
        <ListItem
          title="Sent"
          subtitle="View sent items"
          icon="send"
          chevron
          clickable
          divider
        />
        <ListItem
          title="Drafts"
          subtitle="3 drafts"
          icon="file-text"
          badge="3"
          chevron
          clickable
          divider
        />
        <ListItem
          title="Trash"
          subtitle="Recently deleted"
          icon="trash-2"
          chevron
          clickable
        />
      </div>
    `,
  }),
}

export const UserList: Story = {
  render: () => ({
    components: { ListItem },
    template: `
      <div class="border rounded-lg overflow-hidden">
        <ListItem
          title="Alice Johnson"
          subtitle="alice@example.com"
          avatar="https://i.pravatar.cc/150?img=1"
          clickable
          divider
        />
        <ListItem
          title="Bob Smith"
          subtitle="bob@example.com"
          avatar="https://i.pravatar.cc/150?img=2"
          clickable
          divider
        />
        <ListItem
          title="Carol Williams"
          subtitle="carol@example.com"
          avatar="https://i.pravatar.cc/150?img=3"
          clickable
          active
          divider
        />
        <ListItem
          title="David Brown"
          subtitle="david@example.com"
          avatar="https://i.pravatar.cc/150?img=4"
          clickable
        />
      </div>
    `,
  }),
}

export const SettingsMenu: Story = {
  render: () => ({
    components: { ListItem },
    template: `
      <div class="border rounded-lg overflow-hidden">
        <ListItem
          title="Profile"
          subtitle="Update your profile information"
          icon="user"
          chevron
          clickable
          divider
        />
        <ListItem
          title="Notifications"
          subtitle="Manage notification preferences"
          icon="bell"
          chevron
          clickable
          divider
        />
        <ListItem
          title="Security"
          subtitle="Password and authentication"
          icon="shield"
          chevron
          clickable
          divider
        />
        <ListItem
          title="Privacy"
          subtitle="Control your data"
          icon="lock"
          chevron
          clickable
          divider
        />
        <ListItem
          title="Help & Support"
          subtitle="Get help and contact us"
          icon="help-circle"
          chevron
          clickable
        />
      </div>
    `,
  }),
}

export const WithCustomSlots: Story = {
  render: () => ({
    components: { ListItem },
    template: `
      <div class="border rounded-lg overflow-hidden">
        <ListItem clickable divider>
          <template #leading>
            <div class="w-10 h-10 bg-primary rounded-full flex items-center justify-center text-white font-semibold">
              JD
            </div>
          </template>
          <template #default>
            <div class="font-semibold">John Doe</div>
          </template>
          <template #subtitle>
            <div class="text-sm text-gray-600">
              <span class="font-medium">Product Designer</span> • Acme Inc
            </div>
          </template>
          <template #trailing>
            <button class="px-3 py-1 text-sm bg-primary text-white rounded-md hover:bg-primary/90">
              Follow
            </button>
          </template>
        </ListItem>
      </div>
    `,
  }),
}

export const AllSizes: Story = {
  render: () => ({
    components: { ListItem },
    template: `
      <div class="space-y-4">
        <div class="border rounded-lg overflow-hidden">
          <h3 class="px-4 py-2 bg-gray-50 text-sm font-semibold">Small</h3>
          <ListItem
            title="Small Item"
            subtitle="Compact spacing"
            icon="minimize-2"
            size="sm"
            divider
          />
        </div>
        <div class="border rounded-lg overflow-hidden">
          <h3 class="px-4 py-2 bg-gray-50 text-sm font-semibold">Medium (Default)</h3>
          <ListItem
            title="Medium Item"
            subtitle="Default spacing"
            icon="square"
            size="md"
            divider
          />
        </div>
        <div class="border rounded-lg overflow-hidden">
          <h3 class="px-4 py-2 bg-gray-50 text-sm font-semibold">Large</h3>
          <ListItem
            title="Large Item"
            subtitle="Spacious layout"
            icon="maximize-2"
            size="lg"
          />
        </div>
      </div>
    `,
  }),
}

export const Navigation: Story = {
  render: () => ({
    components: { ListItem },
    template: `
      <div class="border rounded-lg overflow-hidden">
        <ListItem
          title="Dashboard"
          icon="home"
          href="/dashboard"
          active
          divider
        />
        <ListItem
          title="Projects"
          icon="folder"
          href="/projects"
          badge="12"
          divider
        />
        <ListItem
          title="Team"
          icon="users"
          href="/team"
          divider
        />
        <ListItem
          title="Settings"
          icon="settings"
          href="/settings"
        />
      </div>
    `,
  }),
}
