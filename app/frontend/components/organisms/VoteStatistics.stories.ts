import type { Meta, StoryObj } from '@storybook/vue3'
import VoteStatistics from './VoteStatistics.vue'
import type { VoteStats } from './VoteStatistics.vue'

const mockStats: VoteStats = {
  totalVotes: 1000,
  upvotes: 650,
  downvotes: 350,
  abstentions: 0,
  participation: 75,
  trend: 'up',
}

const meta = {
  title: 'Organisms/VoteStatistics',
  component: VoteStatistics,
  tags: ['autodocs'],
  argTypes: {
    showPercentages: {
      control: 'boolean',
    },
    showTrend: {
      control: 'boolean',
    },
    showParticipation: {
      control: 'boolean',
    },
    compact: {
      control: 'boolean',
    },
    loading: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof VoteStatistics>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    stats: mockStats,
  },
}

export const TrendingUp: Story = {
  args: {
    stats: { ...mockStats, trend: 'up' },
  },
}

export const TrendingDown: Story = {
  args: {
    stats: { ...mockStats, trend: 'down', upvotes: 350, downvotes: 650 },
  },
}

export const Stable: Story = {
  args: {
    stats: { ...mockStats, trend: 'stable', upvotes: 500, downvotes: 500 },
  },
}

export const WithAbstentions: Story = {
  args: {
    stats: { ...mockStats, abstentions: 200, totalVotes: 1200 },
  },
}

export const HighParticipation: Story = {
  args: {
    stats: { ...mockStats, participation: 95 },
  },
}

export const LowParticipation: Story = {
  args: {
    stats: { ...mockStats, participation: 25 },
  },
}

export const LargeNumbers: Story = {
  args: {
    stats: {
      totalVotes: 50000,
      upvotes: 35000,
      downvotes: 15000,
      participation: 80,
      trend: 'up',
    },
  },
}

export const VeryLargeNumbers: Story = {
  args: {
    stats: {
      totalVotes: 2500000,
      upvotes: 1800000,
      downvotes: 700000,
      participation: 88,
      trend: 'up',
    },
  },
}

export const CompactMode: Story = {
  args: {
    stats: mockStats,
    compact: true,
  },
}

export const NoPercentages: Story = {
  args: {
    stats: mockStats,
    showPercentages: false,
  },
}

export const NoTrend: Story = {
  args: {
    stats: mockStats,
    showTrend: false,
  },
}

export const NoParticipation: Story = {
  args: {
    stats: mockStats,
    showParticipation: false,
  },
}

export const Loading: Story = {
  args: {
    stats: mockStats,
    loading: true,
  },
}

export const CloseVote: Story = {
  args: {
    stats: {
      totalVotes: 1000,
      upvotes: 510,
      downvotes: 490,
      participation: 82,
      trend: 'stable',
    },
  },
}

export const UnanimousApproval: Story = {
  args: {
    stats: {
      totalVotes: 500,
      upvotes: 500,
      downvotes: 0,
      participation: 90,
      trend: 'up',
    },
  },
}

export const UnanimousRejection: Story = {
  args: {
    stats: {
      totalVotes: 500,
      upvotes: 0,
      downvotes: 500,
      participation: 75,
      trend: 'down',
    },
  },
}

export const ZeroVotes: Story = {
  args: {
    stats: {
      totalVotes: 0,
      upvotes: 0,
      downvotes: 0,
      participation: 0,
    },
  },
}
