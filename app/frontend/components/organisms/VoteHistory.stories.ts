import type { Meta, StoryObj } from '@storybook/vue3'
import VoteHistory from './VoteHistory.vue'
import type { VoteHistoryItem } from './VoteHistory.vue'

const generateHistoryItem = (id: number, overrides: Partial<VoteHistoryItem> = {}): VoteHistoryItem => ({
  id,
  itemTitle: `Elemento ${id}`,
  itemType: ['proposal', 'comment', 'post'][id % 3] as any,
  voteType: id % 2 === 0 ? 'up' : 'down',
  votedAt: new Date(Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000),
  itemUrl: `/items/${id}`,
  ...overrides,
})

const mockHistory: VoteHistoryItem[] = [
  generateHistoryItem(1, {
    itemTitle: 'Propuesta de mejora del transporte público',
    itemType: 'proposal',
    voteType: 'up',
    votedAt: new Date(Date.now() - 3600000),
  }),
  generateHistoryItem(2, {
    itemTitle: 'Comentario sobre espacios verdes urbanos',
    itemType: 'comment',
    voteType: 'down',
    votedAt: new Date(Date.now() - 7200000),
  }),
  generateHistoryItem(3, {
    itemTitle: 'Publicación sobre programa de reciclaje',
    itemType: 'post',
    voteType: 'up',
    votedAt: new Date(Date.now() - 86400000),
  }),
  generateHistoryItem(4, {
    itemTitle: 'Propuesta de iluminación LED en barrios',
    itemType: 'proposal',
    voteType: 'up',
    votedAt: new Date(Date.now() - 172800000),
  }),
]

const meta = {
  title: 'Organisms/VoteHistory',
  component: VoteHistory,
  tags: ['autodocs'],
  argTypes: {
    loading: {
      control: 'boolean',
    },
    showPagination: {
      control: 'boolean',
    },
    pageSize: {
      control: 'number',
    },
  },
} satisfies Meta<typeof VoteHistory>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    history: mockHistory,
  },
}

export const Empty: Story = {
  args: {
    history: [],
  },
}

export const Loading: Story = {
  args: {
    history: mockHistory,
    loading: true,
  },
}

export const OnlyUpvotes: Story = {
  args: {
    history: mockHistory.map((item) => ({ ...item, voteType: 'up' })),
  },
}

export const OnlyDownvotes: Story = {
  args: {
    history: mockHistory.map((item) => ({ ...item, voteType: 'down' })),
  },
}

export const LargeHistory: Story = {
  args: {
    history: Array.from({ length: 25 }, (_, i) => generateHistoryItem(i + 1)),
    showPagination: true,
    pageSize: 10,
  },
}

export const NoPagination: Story = {
  args: {
    history: Array.from({ length: 15 }, (_, i) => generateHistoryItem(i + 1)),
    showPagination: false,
  },
}

export const SmallPageSize: Story = {
  args: {
    history: Array.from({ length: 20 }, (_, i) => generateHistoryItem(i + 1)),
    pageSize: 5,
  },
}

export const Interactive: Story = {
  render: (args) => ({
    components: { VoteHistory },
    setup() {
      const handleItemClick = (item: VoteHistoryItem) => {
        alert(`Clicked: ${item.itemTitle}`)
      }

      return { mockHistory, handleItemClick }
    },
    template: `
      <div class="p-6 max-w-2xl">
        <VoteHistory
          :history="mockHistory"
          @item-click="handleItemClick"
        />
      </div>
    `,
  }),
  args: {},
}
