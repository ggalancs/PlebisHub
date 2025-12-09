import type { Meta, StoryObj } from '@storybook/vue3'
import AvatarGroup from './AvatarGroup.vue'
import type { AvatarGroupItem } from './AvatarGroup.vue'

const meta = {
  title: 'Molecules/AvatarGroup',
  component: AvatarGroup,
  tags: ['autodocs'],
} satisfies Meta<typeof AvatarGroup>

export default meta
type Story = StoryObj<typeof meta>

const users: AvatarGroupItem[] = [
  { id: 1, name: 'Alice Johnson', src: 'https://i.pravatar.cc/100?img=1' },
  { id: 2, name: 'Bob Smith', src: 'https://i.pravatar.cc/100?img=2' },
  { id: 3, name: 'Carol White', src: 'https://i.pravatar.cc/100?img=3' },
  { id: 4, name: 'Dave Brown', src: 'https://i.pravatar.cc/100?img=4' },
  { id: 5, name: 'Eve Davis', src: 'https://i.pravatar.cc/100?img=5' },
  { id: 6, name: 'Frank Miller', src: 'https://i.pravatar.cc/100?img=6' },
  { id: 7, name: 'Grace Wilson', src: 'https://i.pravatar.cc/100?img=7' },
]

export const Default: Story = {
  args: {
    items: users.slice(0, 5),
  },
}

export const WithOverflow: Story = {
  args: {
    items: users,
    max: 4,
  },
}

export const WithTooltip: Story = {
  args: {
    items: users.slice(0, 5),
    showTooltip: true,
  },
}

export const SmallSize: Story = {
  args: {
    items: users.slice(0, 6),
    size: 'sm',
    max: 4,
  },
}

export const LargeSize: Story = {
  args: {
    items: users.slice(0, 6),
    size: 'lg',
    max: 4,
  },
}

export const AllSizes: Story = {
  render: () => ({
    components: { AvatarGroup },
    setup() {
      return { users }
    },
    template: `
      <div class="space-y-6">
        <div>
          <p class="text-sm text-gray-600 mb-2">Small</p>
          <AvatarGroup :items="users.slice(0, 6)" size="sm" :max="4" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Medium</p>
          <AvatarGroup :items="users.slice(0, 6)" size="md" :max="4" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Large</p>
          <AvatarGroup :items="users.slice(0, 6)" size="lg" :max="4" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Extra Large</p>
          <AvatarGroup :items="users.slice(0, 6)" size="xl" :max="4" />
        </div>
      </div>
    `,
  }),
}

export const TeamMembers: Story = {
  render: () => ({
    components: { AvatarGroup },
    setup() {
      return { users }
    },
    template: `
      <div class="p-6 bg-white rounded-lg border border-gray-200">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-semibold">Project Team</h3>
          <AvatarGroup :items="users" :max="5" show-tooltip />
        </div>
        <p class="text-sm text-gray-600">
          Collaborative project with {{ users.length }} team members
        </p>
      </div>
    `,
  }),
}
