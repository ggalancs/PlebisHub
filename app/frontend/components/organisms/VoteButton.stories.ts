import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import VoteButton from './VoteButton.vue'
import type { VoteType } from './VoteButton.vue'

const meta = {
  title: 'Organisms/VoteButton',
  component: VoteButton,
  tags: ['autodocs'],
  argTypes: {
    count: {
      control: 'number',
    },
    userVote: {
      control: 'select',
      options: [null, 'up', 'down', 'neutral'],
    },
    variant: {
      control: 'select',
      options: ['default', 'reddit', 'simple', 'compact'],
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
    orientation: {
      control: 'select',
      options: ['horizontal', 'vertical'],
    },
    allowDownvote: {
      control: 'boolean',
    },
    showCount: {
      control: 'boolean',
    },
    disabled: {
      control: 'boolean',
    },
    loading: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof VoteButton>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    count: 42,
  },
}

export const DefaultUpvoted: Story = {
  args: {
    count: 43,
    userVote: 'up',
  },
}

export const DefaultDownvoted: Story = {
  args: {
    count: 41,
    userVote: 'down',
  },
}

export const DefaultVertical: Story = {
  args: {
    count: 42,
    orientation: 'vertical',
  },
}

export const Reddit: Story = {
  args: {
    count: 42,
    variant: 'reddit',
  },
}

export const RedditUpvoted: Story = {
  args: {
    count: 43,
    variant: 'reddit',
    userVote: 'up',
  },
}

export const RedditDownvoted: Story = {
  args: {
    count: 41,
    variant: 'reddit',
    userVote: 'down',
  },
}

export const RedditVertical: Story = {
  args: {
    count: 42,
    variant: 'reddit',
    orientation: 'vertical',
  },
}

export const Simple: Story = {
  args: {
    count: 42,
    variant: 'simple',
  },
}

export const SimpleUpvoted: Story = {
  args: {
    count: 43,
    variant: 'simple',
    userVote: 'up',
  },
}

export const SimpleDownvoted: Story = {
  args: {
    count: 41,
    variant: 'simple',
    userVote: 'down',
  },
}

export const Compact: Story = {
  args: {
    count: 42,
    variant: 'compact',
  },
}

export const CompactUpvoted: Story = {
  args: {
    count: 43,
    variant: 'compact',
    userVote: 'up',
  },
}

export const NoDownvote: Story = {
  args: {
    count: 42,
    allowDownvote: false,
  },
}

export const NoCount: Story = {
  args: {
    count: 42,
    showCount: false,
  },
}

export const SmallSize: Story = {
  args: {
    count: 42,
    size: 'sm',
  },
}

export const LargeSize: Story = {
  args: {
    count: 42,
    size: 'lg',
  },
}

export const Disabled: Story = {
  args: {
    count: 42,
    disabled: true,
  },
}

export const Loading: Story = {
  args: {
    count: 42,
    loading: true,
  },
}

export const HighNumbers: Story = {
  args: {
    count: 1234,
  },
}

export const VeryHighNumbers: Story = {
  args: {
    count: 123456,
  },
}

export const MillionNumbers: Story = {
  args: {
    count: 1234567,
  },
}

export const NegativeNumbers: Story = {
  args: {
    count: -42,
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { VoteButton },
    setup() {
      const count = ref(42)
      const userVote = ref<VoteType | null>(null)

      const handleVote = (type: VoteType) => {
        console.log('Vote:', type)

        if (type === 'neutral') {
          // Remove vote
          if (userVote.value === 'up') {
            count.value--
          } else if (userVote.value === 'down') {
            count.value++
          }
          userVote.value = null
        } else if (type === 'up') {
          // Upvote
          if (userVote.value === 'down') {
            count.value += 2 // Remove downvote and add upvote
          } else {
            count.value++
          }
          userVote.value = 'up'
        } else if (type === 'down') {
          // Downvote
          if (userVote.value === 'up') {
            count.value -= 2 // Remove upvote and add downvote
          } else {
            count.value--
          }
          userVote.value = 'down'
        }
      }

      return { count, userVote, handleVote }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Interactive Vote Button</h2>
        <p class="text-sm text-gray-600 mb-6">
          Click the arrows to vote. The count will update in real-time.
        </p>
        <VoteButton
          :count="count"
          :user-vote="userVote"
          @vote="handleVote"
        />
        <div class="mt-4 text-sm text-gray-600">
          <p>Current count: {{ count }}</p>
          <p>Your vote: {{ userVote || 'none' }}</p>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const AllVariants: Story = {
  render: () => ({
    components: { VoteButton },
    setup() {
      return {}
    },
    template: `
      <div class="p-6 space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-3">Default Variant</h3>
          <div class="flex gap-4">
            <VoteButton :count="42" />
            <VoteButton :count="43" user-vote="up" />
            <VoteButton :count="41" user-vote="down" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Reddit Variant</h3>
          <div class="flex gap-4">
            <VoteButton :count="42" variant="reddit" />
            <VoteButton :count="43" variant="reddit" user-vote="up" />
            <VoteButton :count="41" variant="reddit" user-vote="down" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Simple Variant</h3>
          <div class="flex gap-4">
            <VoteButton :count="42" variant="simple" />
            <VoteButton :count="43" variant="simple" user-vote="up" />
            <VoteButton :count="41" variant="simple" user-vote="down" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Compact Variant</h3>
          <div class="flex gap-4">
            <VoteButton :count="42" variant="compact" />
            <VoteButton :count="43" variant="compact" user-vote="up" />
            <VoteButton :count="41" variant="compact" user-vote="down" />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const AllSizes: Story = {
  render: () => ({
    components: { VoteButton },
    setup() {
      return {}
    },
    template: `
      <div class="p-6 space-y-6">
        <div>
          <h3 class="text-lg font-semibold mb-3">Small Size</h3>
          <div class="flex gap-4">
            <VoteButton :count="42" size="sm" />
            <VoteButton :count="42" variant="reddit" size="sm" />
            <VoteButton :count="42" variant="simple" size="sm" />
            <VoteButton :count="42" variant="compact" size="sm" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Medium Size (Default)</h3>
          <div class="flex gap-4">
            <VoteButton :count="42" />
            <VoteButton :count="42" variant="reddit" />
            <VoteButton :count="42" variant="simple" />
            <VoteButton :count="42" variant="compact" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Large Size</h3>
          <div class="flex gap-4">
            <VoteButton :count="42" size="lg" />
            <VoteButton :count="42" variant="reddit" size="lg" />
            <VoteButton :count="42" variant="simple" size="lg" />
            <VoteButton :count="42" variant="compact" size="lg" />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const Orientations: Story = {
  render: () => ({
    components: { VoteButton },
    setup() {
      return {}
    },
    template: `
      <div class="p-6 space-y-6">
        <div>
          <h3 class="text-lg font-semibold mb-3">Horizontal (Default)</h3>
          <div class="flex gap-4">
            <VoteButton :count="42" />
            <VoteButton :count="42" variant="reddit" />
            <VoteButton :count="42" variant="simple" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-3">Vertical</h3>
          <div class="flex gap-4">
            <VoteButton :count="42" orientation="vertical" />
            <VoteButton :count="42" variant="reddit" orientation="vertical" />
            <VoteButton :count="42" variant="simple" orientation="vertical" />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const InContext: Story = {
  render: () => ({
    components: { VoteButton },
    setup() {
      const items = ref([
        { id: 1, title: 'Great post about Vue 3', count: 156, userVote: null },
        { id: 2, title: 'How to use TypeScript', count: 89, userVote: 'up' },
        { id: 3, title: 'CSS Tips and Tricks', count: 234, userVote: null },
        { id: 4, title: 'JavaScript Best Practices', count: 312, userVote: 'down' },
      ])

      return { items }
    },
    template: `
      <div class="p-6 max-w-2xl">
        <h2 class="text-2xl font-bold mb-6">Posts Feed</h2>
        <div class="space-y-4">
          <div
            v-for="item in items"
            :key="item.id"
            class="flex gap-4 p-4 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700"
          >
            <VoteButton
              :count="item.count"
              :user-vote="item.userVote"
              variant="reddit"
              orientation="vertical"
            />
            <div class="flex-1">
              <h3 class="font-semibold text-lg mb-1">{{ item.title }}</h3>
              <p class="text-sm text-gray-600 dark:text-gray-400">
                Posted 2 hours ago by user123
              </p>
            </div>
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CommentVoting: Story = {
  render: () => ({
    components: { VoteButton },
    setup() {
      return {}
    },
    template: `
      <div class="p-6 max-w-2xl">
        <h2 class="text-2xl font-bold mb-6">Comments</h2>
        <div class="space-y-4">
          <div class="flex gap-3 p-4 bg-white dark:bg-gray-800 rounded-lg">
            <VoteButton
              :count="15"
              variant="simple"
              size="sm"
            />
            <div>
              <p class="text-sm font-semibold mb-1">user123</p>
              <p class="text-sm">This is a great comment with useful information.</p>
            </div>
          </div>

          <div class="flex gap-3 p-4 bg-white dark:bg-gray-800 rounded-lg">
            <VoteButton
              :count="8"
              variant="simple"
              size="sm"
              user-vote="up"
            />
            <div>
              <p class="text-sm font-semibold mb-1">user456</p>
              <p class="text-sm">I agree with this comment. Here's why...</p>
            </div>
          </div>

          <div class="flex gap-3 p-4 bg-white dark:bg-gray-800 rounded-lg">
            <VoteButton
              :count="3"
              variant="simple"
              size="sm"
            />
            <div>
              <p class="text-sm font-semibold mb-1">user789</p>
              <p class="text-sm">Another perspective on this topic.</p>
            </div>
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}
