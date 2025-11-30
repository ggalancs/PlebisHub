/**
 * Storybook Stories for VirtualScrollList Component
 */

import type { Meta, StoryObj } from '@storybook/vue3'
import VirtualScrollList from './VirtualScrollList.vue'

const meta = {
  title: 'Molecules/VirtualScrollList',
  component: VirtualScrollList,
  tags: ['autodocs'],
  argTypes: {
    items: {
      control: 'object',
      description: 'Array of items to display',
    },
    itemHeight: {
      control: { type: 'number', min: 20, max: 200 },
      description: 'Height of each item in pixels (fixed) or function for dynamic heights',
    },
    containerHeight: {
      control: { type: 'number', min: 200, max: 800 },
      description: 'Height of the scroll container in pixels',
    },
    buffer: {
      control: { type: 'number', min: 0, max: 10 },
      description: 'Number of items to render outside viewport',
    },
    overscan: {
      control: { type: 'number', min: 0, max: 10 },
      description: 'Additional items to render for smoother scrolling',
    },
    emptyMessage: {
      control: 'text',
      description: 'Message to display when list is empty',
    },
    loading: {
      control: 'boolean',
      description: 'Show loading spinner',
    },
  },
} satisfies Meta<typeof VirtualScrollList>

export default meta
type Story = StoryObj<typeof meta>

// Generate sample data
const generateItems = (count: number) => {
  return Array.from({ length: count }, (_, i) => ({
    id: i + 1,
    title: `Item ${i + 1}`,
    description: `This is the description for item ${i + 1}. Lorem ipsum dolor sit amet, consectetur adipiscing elit.`,
    timestamp: new Date(Date.now() - Math.random() * 10000000000).toISOString(),
  }))
}

/**
 * Default story with 1000 items
 */
export const Default: Story = {
  args: {
    items: generateItems(1000),
    itemHeight: 80,
    containerHeight: 600,
    buffer: 5,
    overscan: 2,
  },
  render: (args) => ({
    components: { VirtualScrollList },
    setup() {
      return { args }
    },
    template: `
      <VirtualScrollList v-bind="args">
        <template #default="{ item, index }">
          <div class="p-4 border-b border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
            <div class="flex justify-between items-start">
              <div class="flex-1">
                <h3 class="font-semibold text-gray-900 dark:text-white">
                  {{ item.title }}
                </h3>
                <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                  {{ item.description }}
                </p>
              </div>
              <span class="text-xs text-gray-500 dark:text-gray-500 ml-4">
                #{{ index + 1 }}
              </span>
            </div>
          </div>
        </template>
      </VirtualScrollList>
    `,
  }),
}

/**
 * Small list (10 items)
 */
export const SmallList: Story = {
  args: {
    items: generateItems(10),
    itemHeight: 80,
    containerHeight: 600,
  },
  render: (args) => ({
    components: { VirtualScrollList },
    setup() {
      return { args }
    },
    template: `
      <VirtualScrollList v-bind="args">
        <template #default="{ item }">
          <div class="p-4 border-b border-gray-200 dark:border-gray-700">
            <h3 class="font-semibold">{{ item.title }}</h3>
            <p class="text-sm text-gray-600 dark:text-gray-400">{{ item.description }}</p>
          </div>
        </template>
      </VirtualScrollList>
    `,
  }),
}

/**
 * Large list (10,000 items) - Performance test
 */
export const LargeList: Story = {
  args: {
    items: generateItems(10000),
    itemHeight: 60,
    containerHeight: 600,
    buffer: 3,
  },
  render: (args) => ({
    components: { VirtualScrollList },
    setup() {
      return { args }
    },
    template: `
      <div>
        <div class="mb-4 p-4 bg-blue-50 dark:bg-blue-900/20 rounded">
          <p class="text-sm text-blue-800 dark:text-blue-200">
            <strong>Performance Test:</strong> Rendering 10,000 items with virtual scrolling.
            Only visible items are rendered in the DOM.
          </p>
        </div>
        <VirtualScrollList v-bind="args">
          <template #default="{ item, index }">
            <div class="p-3 border-b border-gray-200 dark:border-gray-700">
              <div class="flex justify-between">
                <span class="text-sm font-medium">{{ item.title }}</span>
                <span class="text-xs text-gray-500">#{{ index + 1 }}</span>
              </div>
            </div>
          </template>
        </VirtualScrollList>
      </div>
    `,
  }),
}

/**
 * Empty list
 */
export const EmptyList: Story = {
  args: {
    items: [],
    itemHeight: 80,
    containerHeight: 400,
    emptyMessage: 'No hay elementos para mostrar',
  },
  render: (args) => ({
    components: { VirtualScrollList },
    setup() {
      return { args }
    },
    template: `
      <VirtualScrollList v-bind="args">
        <template #default="{ item }">
          <div class="p-4">{{ item.title }}</div>
        </template>
      </VirtualScrollList>
    `,
  }),
}

/**
 * Loading state
 */
export const Loading: Story = {
  args: {
    items: generateItems(100),
    itemHeight: 80,
    containerHeight: 400,
    loading: true,
  },
  render: (args) => ({
    components: { VirtualScrollList },
    setup() {
      return { args }
    },
    template: `
      <VirtualScrollList v-bind="args">
        <template #default="{ item }">
          <div class="p-4">{{ item.title }}</div>
        </template>
      </VirtualScrollList>
    `,
  }),
}

/**
 * Dynamic item heights
 */
export const DynamicHeights: Story = {
  args: {
    items: generateItems(500),
    containerHeight: 600,
    buffer: 5,
  },
  render: (args) => ({
    components: { VirtualScrollList },
    setup() {
      // Dynamic height function
      const getItemHeight = (item: { id: number; title: string; description: string; timestamp: string }) => {
        // Vary height based on item ID
        const heights = [60, 80, 100, 120, 150]
        return heights[item.id % heights.length]
      }

      return { args, getItemHeight }
    },
    template: `
      <div>
        <div class="mb-4 p-4 bg-purple-50 dark:bg-purple-900/20 rounded">
          <p class="text-sm text-purple-800 dark:text-purple-200">
            Items have varying heights (60px, 80px, 100px, 120px, 150px)
          </p>
        </div>
        <VirtualScrollList
          v-bind="args"
          :item-height="getItemHeight"
        >
          <template #default="{ item, index }">
            <div
              class="p-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between"
              :style="{ height: getItemHeight(item) + 'px' }"
            >
              <div>
                <h3 class="font-semibold">{{ item.title }}</h3>
                <p class="text-xs text-gray-500">Height: {{ getItemHeight(item) }}px</p>
              </div>
              <span class="text-xs text-gray-400">#{{ index + 1 }}</span>
            </div>
          </template>
        </VirtualScrollList>
      </div>
    `,
  }),
}

/**
 * Custom styled items
 */
export const CustomStyling: Story = {
  args: {
    items: generateItems(200),
    itemHeight: 120,
    containerHeight: 600,
  },
  render: (args) => ({
    components: { VirtualScrollList },
    setup() {
      return { args }
    },
    template: `
      <VirtualScrollList v-bind="args">
        <template #default="{ item, index }">
          <div
            class="m-2 p-4 rounded-lg shadow-sm"
            :class="index % 2 === 0 ? 'bg-blue-50 dark:bg-blue-900/20' : 'bg-green-50 dark:bg-green-900/20'"
          >
            <div class="flex items-start gap-4">
              <div
                class="w-12 h-12 rounded-full flex items-center justify-center text-white font-bold"
                :class="index % 2 === 0 ? 'bg-blue-500' : 'bg-green-500'"
              >
                {{ index + 1 }}
              </div>
              <div class="flex-1">
                <h3 class="font-semibold text-gray-900 dark:text-white">
                  {{ item.title }}
                </h3>
                <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                  {{ item.description }}
                </p>
              </div>
            </div>
          </div>
        </template>
      </VirtualScrollList>
    `,
  }),
}

/**
 * Card layout
 */
export const CardLayout: Story = {
  args: {
    items: generateItems(300),
    itemHeight: 200,
    containerHeight: 600,
  },
  render: (args) => ({
    components: { VirtualScrollList },
    setup() {
      return { args }
    },
    template: `
      <VirtualScrollList v-bind="args">
        <template #default="{ item, index }">
          <div class="p-3">
            <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 hover:shadow-md transition-shadow bg-white dark:bg-gray-800">
              <div class="flex justify-between items-start mb-3">
                <span class="px-2 py-1 bg-primary/10 text-primary text-xs font-semibold rounded">
                  Item #{{ index + 1 }}
                </span>
                <span class="text-xs text-gray-500">
                  {{ new Date(item.timestamp).toLocaleDateString() }}
                </span>
              </div>
              <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2">
                {{ item.title }}
              </h3>
              <p class="text-sm text-gray-600 dark:text-gray-400">
                {{ item.description }}
              </p>
              <div class="mt-4 flex gap-2">
                <button class="px-3 py-1 bg-primary text-white text-xs rounded hover:bg-primary/90">
                  Ver más
                </button>
                <button class="px-3 py-1 bg-gray-200 dark:bg-gray-700 text-xs rounded hover:bg-gray-300 dark:hover:bg-gray-600">
                  Compartir
                </button>
              </div>
            </div>
          </div>
        </template>
      </VirtualScrollList>
    `,
  }),
}
