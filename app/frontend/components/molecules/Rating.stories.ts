import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import Rating from './Rating.vue'

const meta = {
  title: 'Molecules/Rating',
  component: Rating,
  tags: ['autodocs'],
} satisfies Meta<typeof Rating>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: () => ({
    components: { Rating },
    setup() {
      const rating = ref(3)
      return { rating }
    },
    template: '<Rating v-model="rating" />',
  }),
}

export const Readonly: Story = {
  args: { modelValue: 4, readonly: true },
}

export const Sizes: Story = {
  render: () => ({
    components: { Rating },
    template: `
      <div class="space-y-4">
        <Rating :model-value="4" size="sm" />
        <Rating :model-value="4" size="md" />
        <Rating :model-value="4" size="lg" />
      </div>
    `,
  }),
}
