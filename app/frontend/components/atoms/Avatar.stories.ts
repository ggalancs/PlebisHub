import type { Meta, StoryObj } from '@storybook/vue3-vite'
import Avatar from './Avatar.vue'

const meta = {
  title: 'Atoms/Avatar',
  component: Avatar,
  tags: ['autodocs'],
  argTypes: {
    size: {
      control: 'select',
      options: ['xs', 'sm', 'md', 'lg', 'xl', '2xl'],
      description: 'Avatar size',
    },
    src: {
      control: 'text',
      description: 'Image source URL',
    },
    alt: {
      control: 'text',
      description: 'Alt text for image',
    },
    initials: {
      control: 'text',
      description: 'Initials to display (fallback if no image)',
    },
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'success', 'danger', 'warning', 'info', 'neutral'],
      description: 'Variant color (for initials background)',
    },
    shape: {
      control: 'select',
      options: ['circle', 'square'],
      description: 'Avatar shape',
    },
    status: {
      control: 'select',
      options: ['online', 'offline', 'away', 'busy', null],
      description: 'Status indicator',
    },
    statusPosition: {
      control: 'select',
      options: ['top', 'bottom'],
      description: 'Status indicator position',
    },
  },
  args: {
    size: 'md',
    variant: 'primary',
    shape: 'circle',
    status: null,
    statusPosition: 'bottom',
  },
} satisfies Meta<typeof Avatar>

export default meta
type Story = StoryObj<typeof meta>

// Default avatar
export const Default: Story = {
  args: {},
}

// With image
export const WithImage: Story = {
  args: {
    src: 'https://i.pravatar.cc/150?img=1',
    alt: 'User avatar',
  },
}

// With initials
export const WithInitials: Story = {
  args: {
    initials: 'JD',
  },
}

// All sizes
export const AllSizes: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="flex items-end gap-4">
        <Avatar size="xs" initials="XS" />
        <Avatar size="sm" initials="SM" />
        <Avatar size="md" initials="MD" />
        <Avatar size="lg" initials="LG" />
        <Avatar size="xl" initials="XL" />
        <Avatar size="2xl" initials="2XL" />
      </div>
    `,
  }),
}

// All sizes with images
export const AllSizesWithImages: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="flex items-end gap-4">
        <Avatar size="xs" src="https://i.pravatar.cc/150?img=1" alt="User 1" />
        <Avatar size="sm" src="https://i.pravatar.cc/150?img=2" alt="User 2" />
        <Avatar size="md" src="https://i.pravatar.cc/150?img=3" alt="User 3" />
        <Avatar size="lg" src="https://i.pravatar.cc/150?img=4" alt="User 4" />
        <Avatar size="xl" src="https://i.pravatar.cc/150?img=5" alt="User 5" />
        <Avatar size="2xl" src="https://i.pravatar.cc/150?img=6" alt="User 6" />
      </div>
    `,
  }),
}

// All variants
export const AllVariants: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="flex flex-wrap gap-3">
        <Avatar variant="primary" initials="PR" />
        <Avatar variant="secondary" initials="SE" />
        <Avatar variant="success" initials="SU" />
        <Avatar variant="danger" initials="DA" />
        <Avatar variant="warning" initials="WA" />
        <Avatar variant="info" initials="IN" />
        <Avatar variant="neutral" initials="NE" />
      </div>
    `,
  }),
}

// Square shape
export const SquareShape: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="flex gap-3">
        <Avatar shape="square" initials="SQ" size="sm" />
        <Avatar shape="square" initials="SQ" size="md" />
        <Avatar shape="square" initials="SQ" size="lg" />
        <Avatar shape="square" src="https://i.pravatar.cc/150?img=7" size="xl" />
      </div>
    `,
  }),
}

// With status indicators
export const WithStatus: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="flex gap-4">
        <div class="text-center">
          <Avatar src="https://i.pravatar.cc/150?img=8" status="online" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Online</p>
        </div>
        <div class="text-center">
          <Avatar src="https://i.pravatar.cc/150?img=9" status="offline" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Offline</p>
        </div>
        <div class="text-center">
          <Avatar src="https://i.pravatar.cc/150?img=10" status="away" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Away</p>
        </div>
        <div class="text-center">
          <Avatar src="https://i.pravatar.cc/150?img=11" status="busy" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Busy</p>
        </div>
      </div>
    `,
  }),
}

// Status with initials
export const StatusWithInitials: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="flex gap-4">
        <Avatar initials="ON" status="online" variant="success" size="lg" />
        <Avatar initials="OF" status="offline" variant="neutral" size="lg" />
        <Avatar initials="AW" status="away" variant="warning" size="lg" />
        <Avatar initials="BY" status="busy" variant="danger" size="lg" />
      </div>
    `,
  }),
}

// Status position
export const StatusPosition: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="flex gap-4">
        <div class="text-center">
          <Avatar src="https://i.pravatar.cc/150?img=12" status="online" statusPosition="bottom" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Bottom (default)</p>
        </div>
        <div class="text-center">
          <Avatar src="https://i.pravatar.cc/150?img=13" status="online" statusPosition="top" size="lg" />
          <p class="text-xs text-gray-600 mt-2">Top</p>
        </div>
      </div>
    `,
  }),
}

// User list example
export const UserList: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="space-y-3">
        <div class="flex items-center gap-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
          <Avatar src="https://i.pravatar.cc/150?img=14" status="online" />
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-900">John Doe</p>
            <p class="text-xs text-gray-500">john@example.com</p>
          </div>
        </div>
        <div class="flex items-center gap-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
          <Avatar initials="JS" variant="success" status="online" />
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-900">Jane Smith</p>
            <p class="text-xs text-gray-500">jane@example.com</p>
          </div>
        </div>
        <div class="flex items-center gap-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
          <Avatar src="https://i.pravatar.cc/150?img=15" status="away" />
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-900">Bob Johnson</p>
            <p class="text-xs text-gray-500">bob@example.com</p>
          </div>
        </div>
        <div class="flex items-center gap-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
          <Avatar initials="AM" variant="info" status="busy" />
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-900">Alice Miller</p>
            <p class="text-xs text-gray-500">alice@example.com</p>
          </div>
        </div>
        <div class="flex items-center gap-3 p-3 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
          <Avatar src="https://i.pravatar.cc/150?img=16" status="offline" />
          <div class="flex-1">
            <p class="text-sm font-medium text-gray-900">Charlie Wilson</p>
            <p class="text-xs text-gray-500">charlie@example.com</p>
          </div>
        </div>
      </div>
    `,
  }),
}

// Avatar group
export const AvatarGroup: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="space-y-6">
        <div>
          <p class="text-sm font-medium text-gray-700 mb-3">Team Members (4 users)</p>
          <div class="flex -space-x-2">
            <Avatar src="https://i.pravatar.cc/150?img=17" size="md" class="ring-2 ring-white" />
            <Avatar src="https://i.pravatar.cc/150?img=18" size="md" class="ring-2 ring-white" />
            <Avatar src="https://i.pravatar.cc/150?img=19" size="md" class="ring-2 ring-white" />
            <Avatar initials="JD" variant="primary" size="md" class="ring-2 ring-white" />
          </div>
        </div>

        <div>
          <p class="text-sm font-medium text-gray-700 mb-3">Project Contributors (6+ users)</p>
          <div class="flex -space-x-3">
            <Avatar src="https://i.pravatar.cc/150?img=20" size="lg" class="ring-2 ring-white" />
            <Avatar src="https://i.pravatar.cc/150?img=21" size="lg" class="ring-2 ring-white" />
            <Avatar src="https://i.pravatar.cc/150?img=22" size="lg" class="ring-2 ring-white" />
            <Avatar initials="AB" variant="success" size="lg" class="ring-2 ring-white" />
            <Avatar initials="CD" variant="warning" size="lg" class="ring-2 ring-white" />
            <div class="relative inline-flex items-center justify-center h-12 w-12 rounded-full bg-gray-100 text-gray-600 font-medium text-sm ring-2 ring-white">
              +3
            </div>
          </div>
        </div>
      </div>
    `,
  }),
}

// Comment thread example
export const CommentThread: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="space-y-4">
        <div class="flex gap-3">
          <Avatar src="https://i.pravatar.cc/150?img=23" status="online" size="md" />
          <div class="flex-1">
            <div class="bg-gray-50 rounded-lg p-3">
              <p class="text-sm font-medium text-gray-900">Sarah Connor</p>
              <p class="text-sm text-gray-600 mt-1">
                This looks great! I really like the new design approach.
              </p>
            </div>
            <p class="text-xs text-gray-500 mt-1 ml-3">2 hours ago</p>
          </div>
        </div>

        <div class="flex gap-3">
          <Avatar initials="JR" variant="info" status="online" size="md" />
          <div class="flex-1">
            <div class="bg-gray-50 rounded-lg p-3">
              <p class="text-sm font-medium text-gray-900">John Reese</p>
              <p class="text-sm text-gray-600 mt-1">
                Thanks! Should we proceed with the implementation?
              </p>
            </div>
            <p class="text-xs text-gray-500 mt-1 ml-3">1 hour ago</p>
          </div>
        </div>

        <div class="flex gap-3">
          <Avatar src="https://i.pravatar.cc/150?img=24" status="away" size="md" />
          <div class="flex-1">
            <div class="bg-gray-50 rounded-lg p-3">
              <p class="text-sm font-medium text-gray-900">Michael Scott</p>
              <p class="text-sm text-gray-600 mt-1">
                Yes, let's do it! I'll create the tasks.
              </p>
            </div>
            <p class="text-xs text-gray-500 mt-1 ml-3">30 minutes ago</p>
          </div>
        </div>
      </div>
    `,
  }),
}

// Profile header example
export const ProfileHeader: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="border border-gray-200 rounded-lg overflow-hidden">
        <div class="h-32 bg-gradient-to-r from-primary-500 to-secondary-500"></div>
        <div class="px-6 pb-6">
          <div class="flex items-end gap-4 -mt-16">
            <Avatar
              src="https://i.pravatar.cc/150?img=25"
              status="online"
              size="2xl"
              class="ring-4 ring-white"
            />
            <div class="flex-1 pb-2">
              <h2 class="text-2xl font-bold text-gray-900">Emma Thompson</h2>
              <p class="text-sm text-gray-600">Product Designer</p>
            </div>
            <div class="pb-2">
              <button class="px-4 py-2 bg-primary-600 text-white text-sm font-medium rounded-md hover:bg-primary-700 transition-colors">
                Follow
              </button>
            </div>
          </div>
          <div class="mt-4">
            <p class="text-sm text-gray-700">
              Passionate about creating beautiful and functional user interfaces.
              Coffee enthusiast ☕
            </p>
          </div>
          <div class="flex gap-6 mt-4">
            <div class="text-center">
              <p class="text-xl font-bold text-gray-900">1,234</p>
              <p class="text-xs text-gray-600">Followers</p>
            </div>
            <div class="text-center">
              <p class="text-xl font-bold text-gray-900">567</p>
              <p class="text-xs text-gray-600">Following</p>
            </div>
            <div class="text-center">
              <p class="text-xl font-bold text-gray-900">89</p>
              <p class="text-xs text-gray-600">Posts</p>
            </div>
          </div>
        </div>
      </div>
    `,
  }),
}

// Settings/Account example
export const AccountSettings: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="border border-gray-200 rounded-lg p-6">
        <h3 class="text-lg font-semibold text-gray-900 mb-4">Account Settings</h3>

        <div class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Profile Photo</label>
            <div class="flex items-center gap-4">
              <Avatar src="https://i.pravatar.cc/150?img=26" size="xl" />
              <div class="space-y-2">
                <button class="px-3 py-1.5 text-sm font-medium text-primary-600 border border-primary-600 rounded-md hover:bg-primary-50 transition-colors">
                  Change Photo
                </button>
                <button class="block px-3 py-1.5 text-sm font-medium text-red-600 border border-red-600 rounded-md hover:bg-red-50 transition-colors">
                  Remove
                </button>
              </div>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Display Name</label>
            <input
              type="text"
              value="Alex Morgan"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Email</label>
            <input
              type="email"
              value="alex@example.com"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
        </div>

        <div class="flex justify-end gap-3 mt-6 pt-6 border-t border-gray-200">
          <button class="px-4 py-2 text-sm font-medium text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50 transition-colors">
            Cancel
          </button>
          <button class="px-4 py-2 text-sm font-medium text-white bg-primary-600 rounded-md hover:bg-primary-700 transition-colors">
            Save Changes
          </button>
        </div>
      </div>
    `,
  }),
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Avatar },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="flex items-end gap-4">
            <Avatar size="xs" src="https://i.pravatar.cc/150?img=27" />
            <Avatar size="sm" src="https://i.pravatar.cc/150?img=28" />
            <Avatar size="md" src="https://i.pravatar.cc/150?img=29" />
            <Avatar size="lg" src="https://i.pravatar.cc/150?img=30" />
            <Avatar size="xl" src="https://i.pravatar.cc/150?img=31" />
            <Avatar size="2xl" src="https://i.pravatar.cc/150?img=32" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Variants (with initials)</h3>
          <div class="flex flex-wrap gap-3">
            <Avatar variant="primary" initials="PR" />
            <Avatar variant="secondary" initials="SE" />
            <Avatar variant="success" initials="SU" />
            <Avatar variant="danger" initials="DA" />
            <Avatar variant="warning" initials="WA" />
            <Avatar variant="info" initials="IN" />
            <Avatar variant="neutral" initials="NE" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Shapes</h3>
          <div class="flex gap-4">
            <div class="text-center">
              <Avatar shape="circle" src="https://i.pravatar.cc/150?img=33" size="lg" />
              <p class="text-xs text-gray-600 mt-2">Circle</p>
            </div>
            <div class="text-center">
              <Avatar shape="square" src="https://i.pravatar.cc/150?img=34" size="lg" />
              <p class="text-xs text-gray-600 mt-2">Square</p>
            </div>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Status Indicators</h3>
          <div class="flex gap-4">
            <Avatar src="https://i.pravatar.cc/150?img=35" status="online" size="lg" />
            <Avatar src="https://i.pravatar.cc/150?img=36" status="offline" size="lg" />
            <Avatar src="https://i.pravatar.cc/150?img=37" status="away" size="lg" />
            <Avatar src="https://i.pravatar.cc/150?img=38" status="busy" size="lg" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Fallbacks</h3>
          <div class="flex gap-4">
            <div class="text-center">
              <Avatar src="https://i.pravatar.cc/150?img=39" size="lg" />
              <p class="text-xs text-gray-600 mt-2">Image</p>
            </div>
            <div class="text-center">
              <Avatar initials="JD" size="lg" />
              <p class="text-xs text-gray-600 mt-2">Initials</p>
            </div>
            <div class="text-center">
              <Avatar size="lg" />
              <p class="text-xs text-gray-600 mt-2">Default Icon</p>
            </div>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Combined Features</h3>
          <div class="flex gap-4">
            <Avatar
              src="https://i.pravatar.cc/150?img=40"
              status="online"
              shape="square"
              size="xl"
            />
            <Avatar
              initials="AB"
              variant="success"
              status="away"
              statusPosition="top"
              size="xl"
            />
            <Avatar
              initials="CD"
              variant="danger"
              status="busy"
              shape="square"
              size="xl"
            />
          </div>
        </div>
      </div>
    `,
  }),
}
