import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Slider from './Slider.vue'

const meta = {
  title: 'Molecules/Slider',
  component: Slider,
  tags: ['autodocs'],
} satisfies Meta<typeof Slider>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    modelValue: 50,
  },
}

export const WithValue: Story = {
  args: {
    modelValue: 75,
    showValue: true,
  },
}

export const CustomRange: Story = {
  args: {
    modelValue: 500,
    min: 0,
    max: 1000,
    step: 10,
    showValue: true,
  },
}

export const SmallSize: Story = {
  args: {
    modelValue: 50,
    size: 'sm',
  },
}

export const LargeSize: Story = {
  args: {
    modelValue: 50,
    size: 'lg',
  },
}

export const Disabled: Story = {
  args: {
    modelValue: 50,
    disabled: true,
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { Slider },
    setup() {
      const value = ref(50)
      return { value }
    },
    template: `
      <div class="space-y-4">
        <Slider v-model="value" show-value />
        <p class="text-sm text-gray-600">Current value: {{ value }}</p>
      </div>
    `,
  }),
}

export const VolumeControl: Story = {
  render: () => ({
    components: { Slider },
    setup() {
      const volume = ref(70)
      return { volume }
    },
    template: `
      <div class="max-w-xs space-y-2">
        <div class="flex items-center justify-between">
          <span class="text-sm font-medium">Volume</span>
          <span class="text-sm text-gray-600">{{ volume }}%</span>
        </div>
        <Slider v-model="volume" :min="0" :max="100" />
      </div>
    `,
  }),
}

export const AllSizes: Story = {
  render: () => ({
    components: { Slider },
    setup() {
      const value = ref(50)
      return { value }
    },
    template: `
      <div class="space-y-6">
        <div>
          <p class="text-sm text-gray-600 mb-2">Small</p>
          <Slider v-model="value" size="sm" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Medium</p>
          <Slider v-model="value" size="md" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Large</p>
          <Slider v-model="value" size="lg" />
        </div>
      </div>
    `,
  }),
}
