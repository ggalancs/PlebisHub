import type { Meta, StoryObj } from '@storybook/vue3-vite'
import UserCard from './UserCard.vue'
import Icon from '../atoms/Icon.vue'

const meta = {
  title: 'Molecules/UserCard',
  component: UserCard,
  tags: ['autodocs'],
  argTypes: {
    variant: { control: 'select', options: ['default', 'compact', 'detailed'] },
    statusVariant: {
      control: 'select',
      options: ['default', 'success', 'warning', 'danger', 'info'],
    },
    verified: { control: 'boolean' },
    showStats: { control: 'boolean' },
  },
  args: {
    variant: 'default',
    statusVariant: 'default',
    verified: false,
    showStats: false,
  },
} satisfies Meta<typeof UserCard>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    name: 'John Doe',
    title: 'Software Engineer',
    avatarSrc: 'https://i.pravatar.cc/150?img=12',
    primaryAction: 'Follow',
    secondaryAction: 'Message',
  },
}

export const CompactVariant: Story = {
  render: () => ({
    components: { UserCard },
    template: `
      <div class="space-y-4 max-w-md">
        <UserCard
          name="Alice Johnson"
          title="UX Designer"
          avatar-src="https://i.pravatar.cc/150?img=1"
          variant="compact"
        />

        <UserCard
          name="Bob Smith"
          title="Product Manager"
          avatar-src="https://i.pravatar.cc/150?img=2"
          variant="compact"
          status-badge="Online"
          status-variant="success"
        />

        <UserCard
          name="Carol White"
          title="Marketing Director"
          avatar-src="https://i.pravatar.cc/150?img=3"
          variant="compact"
          verified
        />
      </div>
    `,
  }),
}

export const DetailedVariant: Story = {
  render: () => ({
    components: { UserCard },
    template: `
      <div class="max-w-md">
        <UserCard
          name="Emma Wilson"
          title="Senior Software Engineer"
          description="Passionate about building scalable web applications and mentoring junior developers. Open source enthusiast."
          avatar-src="https://i.pravatar.cc/150?img=5"
          variant="detailed"
          verified
          :show-stats="true"
          :followers-count="1250"
          :following-count="423"
          :posts-count="89"
          primary-action="Follow"
          secondary-action="Message"
        />
      </div>
    `,
  }),
}

export const WithStats: Story = {
  render: () => ({
    components: { UserCard },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <UserCard
          name="David Lee"
          title="Content Creator"
          avatar-src="https://i.pravatar.cc/150?img=7"
          :show-stats="true"
          :followers-count="12500"
          :following-count="234"
          :posts-count="456"
          primary-action="Follow"
        />

        <UserCard
          name="Sophie Turner"
          title="Influencer"
          avatar-src="https://i.pravatar.cc/150?img=9"
          :show-stats="true"
          :followers-count="2500000"
          :following-count="1200"
          :posts-count="1840"
          primary-action="Follow"
          verified
        />
      </div>
    `,
  }),
}

export const WithStatusBadges: Story = {
  render: () => ({
    components: { UserCard },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <UserCard
          name="Michael Brown"
          title="Available for hire"
          avatar-src="https://i.pravatar.cc/150?img=8"
          status-badge="Available"
          status-variant="success"
          primary-action="Contact"
        />

        <UserCard
          name="Lisa Anderson"
          title="Busy with project"
          avatar-src="https://i.pravatar.cc/150?img=10"
          status-badge="Busy"
          status-variant="warning"
        />

        <UserCard
          name="Tom Harris"
          title="Out of office"
          avatar-src="https://i.pravatar.cc/150?img=11"
          status-badge="Away"
          status-variant="danger"
        />

        <UserCard
          name="Sarah Miller"
          title="Freelance Designer"
          avatar-src="https://i.pravatar.cc/150?img=13"
          status-badge="Pro"
          status-variant="info"
          verified
        />
      </div>
    `,
  }),
}

export const Verified: Story = {
  render: () => ({
    components: { UserCard },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <UserCard
          name="Elon Musk"
          title="CEO at SpaceX"
          avatar-src="https://i.pravatar.cc/150?img=14"
          verified
          :show-stats="true"
          :followers-count="150000000"
          primary-action="Follow"
        />

        <UserCard
          name="Taylor Swift"
          title="Singer & Songwriter"
          avatar-src="https://i.pravatar.cc/150?img=15"
          verified
          variant="compact"
          status-badge="Online"
          status-variant="success"
        />
      </div>
    `,
  }),
}

export const AsLinkCards: Story = {
  render: () => ({
    components: { UserCard },
    setup() {
      const handleClick = (name: string) => alert(`Navigating to ${name}'s profile`)
      return { handleClick }
    },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <UserCard
          name="James Wilson"
          title="Frontend Developer"
          avatar-src="https://i.pravatar.cc/150?img=16"
          href="/users/james"
          variant="compact"
        />

        <UserCard
          name="Emily Davis"
          title="Backend Developer"
          avatar-src="https://i.pravatar.cc/150?img=17"
          href="/users/emily"
          variant="compact"
        />

        <UserCard
          name="Chris Martin"
          title="Full Stack Developer"
          avatar-src="https://i.pravatar.cc/150?img=18"
          href="/users/chris"
          variant="compact"
          verified
        />
      </div>
    `,
  }),
}

export const WithCustomActions: Story = {
  render: () => ({
    components: { UserCard, Icon },
    setup() {
      const handleAction = (action: string) => alert(`${action} clicked`)
      return { handleAction }
    },
    template: `
      <div class="max-w-md">
        <UserCard
          name="Jessica Thompson"
          title="UI/UX Designer"
          avatar-src="https://i.pravatar.cc/150?img=19"
        >
          <template #actions>
            <button
              @click="handleAction('Email')"
              class="flex-1 flex items-center justify-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
            >
              <Icon name="mail" size="sm" />
              Email
            </button>
            <button
              @click="handleAction('Call')"
              class="flex-1 flex items-center justify-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
            >
              <Icon name="phone" size="sm" />
              Call
            </button>
            <button
              @click="handleAction('More')"
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
            >
              <Icon name="more-horizontal" size="sm" />
            </button>
          </template>
        </UserCard>
      </div>
    `,
  }),
}

export const WithFooter: Story = {
  render: () => ({
    components: { UserCard, Icon },
    template: `
      <div class="max-w-md">
        <UserCard
          name="Robert Garcia"
          title="DevOps Engineer"
          avatar-src="https://i.pravatar.cc/150?img=20"
          primary-action="Connect"
        >
          <template #footer>
            <div class="flex items-center gap-4 text-sm text-gray-500">
              <div class="flex items-center gap-1">
                <Icon name="map-pin" size="sm" />
                San Francisco, CA
              </div>
              <div class="flex items-center gap-1">
                <Icon name="briefcase" size="sm" />
                5 years exp
              </div>
            </div>
          </template>
        </UserCard>
      </div>
    `,
  }),
}

export const TeamMembers: Story = {
  render: () => ({
    components: { UserCard },
    setup() {
      const handleFollow = (name: string) => alert(`Following ${name}`)
      const handleMessage = (name: string) => alert(`Messaging ${name}`)
      return { handleFollow, handleMessage }
    },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <UserCard
          name="Alex Rivera"
          title="Team Lead"
          avatar-src="https://i.pravatar.cc/150?img=21"
          status-badge="Lead"
          status-variant="info"
          primary-action="Follow"
          secondary-action="Message"
          @primary-action="handleFollow('Alex Rivera')"
          @secondary-action="handleMessage('Alex Rivera')"
        />

        <UserCard
          name="Maria Santos"
          title="Senior Developer"
          avatar-src="https://i.pravatar.cc/150?img=22"
          status-badge="Available"
          status-variant="success"
          primary-action="Follow"
          secondary-action="Message"
          @primary-action="handleFollow('Maria Santos')"
          @secondary-action="handleMessage('Maria Santos')"
        />

        <UserCard
          name="Kevin Chen"
          title="Junior Developer"
          avatar-src="https://i.pravatar.cc/150?img=23"
          primary-action="Follow"
          secondary-action="Message"
          @primary-action="handleFollow('Kevin Chen')"
          @secondary-action="handleMessage('Kevin Chen')"
        />
      </div>
    `,
  }),
}

export const WithInitials: Story = {
  render: () => ({
    components: { UserCard },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <UserCard
          name="John Smith"
          title="Developer"
          avatar-initials="JS"
          variant="compact"
        />

        <UserCard
          name="Jane Doe"
          title="Designer"
          avatar-initials="JD"
          primary-action="Follow"
        />

        <UserCard
          name="Mike Johnson"
          title="Manager"
          avatar-initials="MJ"
          variant="detailed"
          :show-stats="true"
          :followers-count="523"
          primary-action="Connect"
        />
      </div>
    `,
  }),
}

export const MinimalCard: Story = {
  render: () => ({
    components: { UserCard },
    template: `
      <div class="max-w-md">
        <UserCard
          name="Sam Wilson"
          variant="compact"
        />
      </div>
    `,
  }),
}

export const InteractiveDemo: Story = {
  render: () => ({
    components: { UserCard },
    setup() {
      const handlePrimary = () => alert('Primary action clicked!')
      const handleSecondary = () => alert('Secondary action clicked!')
      const handleCardClick = () => alert('Card clicked!')

      return { handlePrimary, handleSecondary, handleCardClick }
    },
    template: `
      <div class="space-y-6">
        <div class="rounded-lg bg-blue-50 p-4">
          <p class="text-sm text-blue-800">
            💡 Click the buttons or card to see events
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <UserCard
            name="Interactive User"
            title="Test Events"
            avatar-src="https://i.pravatar.cc/150?img=25"
            primary-action="Follow"
            secondary-action="Message"
            @primary-action="handlePrimary"
            @secondary-action="handleSecondary"
          />

          <UserCard
            name="Clickable Card"
            title="Click me!"
            avatar-src="https://i.pravatar.cc/150?img=26"
            variant="compact"
            @click="handleCardClick"
          />
        </div>
      </div>
    `,
  }),
}
