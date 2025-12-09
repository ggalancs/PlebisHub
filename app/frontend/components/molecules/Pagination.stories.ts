import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Pagination from './Pagination.vue'

const meta = {
  title: 'Molecules/Pagination',
  component: Pagination,
  tags: ['autodocs'],
  argTypes: {
    currentPage: {
      control: 'number',
      description: 'Current page (1-indexed)',
    },
    totalItems: {
      control: 'number',
      description: 'Total number of items',
    },
    pageSize: {
      control: 'number',
      description: 'Items per page',
    },
    pageSizeOptions: {
      control: 'object',
      description: 'Available page size options',
    },
    showPageSize: {
      control: 'boolean',
      description: 'Show page size selector',
    },
    showTotal: {
      control: 'boolean',
      description: 'Show total count',
    },
    showFirstLast: {
      control: 'boolean',
      description: 'Show first/last buttons',
    },
    maxButtons: {
      control: 'number',
      description: 'Maximum number of page buttons to show',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Size variant',
    },
  },
  args: {
    currentPage: 1,
    totalItems: 100,
    pageSize: 10,
    showPageSize: false,
    showTotal: true,
    showFirstLast: false,
    maxButtons: 7,
    disabled: false,
    size: 'md',
  },
} satisfies Meta<typeof Pagination>

export default meta
type Story = StoryObj<typeof meta>

// Default pagination
export const Default: Story = {
  args: {
    currentPage: 1,
    totalItems: 100,
  },
}

// With page size selector
export const WithPageSize: Story = {
  render: (args) => ({
    components: { Pagination },
    setup() {
      const currentPage = ref(args.currentPage)
      const pageSize = ref(args.pageSize || 10)

      return { args, currentPage, pageSize }
    },
    template: `
      <Pagination
        v-bind="args"
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
      />
    `,
  }),
  args: {
    currentPage: 1,
    totalItems: 100,
    showPageSize: true,
  },
}

// With first/last buttons
export const WithFirstLast: Story = {
  args: {
    currentPage: 5,
    totalItems: 200,
    showFirstLast: true,
  },
}

// Many pages with ellipsis
export const ManyPages: Story = {
  args: {
    currentPage: 10,
    totalItems: 500,
    pageSize: 10,
    maxButtons: 7,
  },
}

// Few items
export const FewItems: Story = {
  args: {
    currentPage: 1,
    totalItems: 25,
    pageSize: 10,
  },
}

// No results
export const NoResults: Story = {
  args: {
    currentPage: 1,
    totalItems: 0,
    showTotal: true,
  },
}

// Single page
export const SinglePage: Story = {
  args: {
    currentPage: 1,
    totalItems: 8,
    pageSize: 10,
  },
}

// Different sizes
export const Sizes: Story = {
  render: () => ({
    components: { Pagination },
    template: `
      <div class="space-y-6">
        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Small</h3>
          <Pagination
            :current-page="1"
            :total-items="100"
            size="sm"
          />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Medium (Default)</h3>
          <Pagination
            :current-page="1"
            :total-items="100"
            size="md"
          />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Large</h3>
          <Pagination
            :current-page="1"
            :total-items="100"
            size="lg"
          />
        </div>
      </div>
    `,
  }),
}

// Disabled state
export const Disabled: Story = {
  args: {
    currentPage: 5,
    totalItems: 100,
    disabled: true,
  },
}

// Edge cases
export const EdgeCases: Story = {
  render: () => ({
    components: { Pagination },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">First Page</h3>
          <Pagination
            :current-page="1"
            :total-items="100"
            :show-first-last="true"
          />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Last Page</h3>
          <Pagination
            :current-page="10"
            :total-items="100"
            :show-first-last="true"
          />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Odd Number of Items</h3>
          <Pagination
            :current-page="1"
            :total-items="47"
            :page-size="10"
          />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Last Page with Fewer Items</h3>
          <Pagination
            :current-page="5"
            :total-items="47"
            :page-size="10"
          />
        </div>
      </div>
    `,
  }),
}

// Interactive example
export const Interactive: Story = {
  render: () => ({
    components: { Pagination },
    setup() {
      const currentPage = ref(args.currentPage)
      const pageSize = ref(args.pageSize || 10)
      const totalItems = ref(args.totalItems || 100)

      return { currentPage, pageSize, totalItems }
    },
    template: `
      <div class="space-y-6">
        <div class="p-4 bg-gray-50 rounded-lg">
          <div class="grid grid-cols-3 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Total Items</label>
              <input
                v-model.number="totalItems"
                type="number"
                min="0"
                class="w-full px-3 py-2 border border-gray-300 rounded-md"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Current Page</label>
              <input
                v-model.number="currentPage"
                type="number"
                min="1"
                :max="Math.ceil(totalItems / pageSize)"
                class="w-full px-3 py-2 border border-gray-300 rounded-md"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Page Size</label>
              <input
                v-model.number="pageSize"
                type="number"
                min="1"
                class="w-full px-3 py-2 border border-gray-300 rounded-md"
              />
            </div>
          </div>
        </div>

        <Pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :total-items="totalItems"
          :show-page-size="true"
          :show-first-last="true"
          @page-change="(page) => console.log('Page changed to:', page)"
          @page-size-change="(size) => console.log('Page size changed to:', size)"
        />

        <div class="text-sm text-gray-600">
          <p>Current Page: {{ currentPage }}</p>
          <p>Page Size: {{ pageSize }}</p>
          <p>Total Pages: {{ Math.ceil(totalItems / pageSize) }}</p>
        </div>
      </div>
    `,
  }),
  args: {
    currentPage: 5,
    totalItems: 100,
    pageSize: 10,
  },
}

// Data table example
export const DataTableExample: Story = {
  render: () => ({
    components: { Pagination },
    setup() {
      const currentPage = ref(1)
      const pageSize = ref(10)
      const totalItems = ref(156)

      const users = ref([
        { id: 1, name: 'John Doe', email: 'john@example.com', role: 'Admin' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'User' },
        { id: 3, name: 'Bob Johnson', email: 'bob@example.com', role: 'User' },
        { id: 4, name: 'Alice Williams', email: 'alice@example.com', role: 'Editor' },
        { id: 5, name: 'Charlie Brown', email: 'charlie@example.com', role: 'User' },
        { id: 6, name: 'Diana Prince', email: 'diana@example.com', role: 'Admin' },
        { id: 7, name: 'Frank Castle', email: 'frank@example.com', role: 'User' },
        { id: 8, name: 'Grace Hopper', email: 'grace@example.com', role: 'Editor' },
        { id: 9, name: 'Henry Ford', email: 'henry@example.com', role: 'User' },
        { id: 10, name: 'Iris West', email: 'iris@example.com', role: 'User' },
      ])

      return { currentPage, pageSize, totalItems, users }
    },
    template: `
      <div class="space-y-4">
        <div class="border border-gray-200 rounded-lg overflow-hidden">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ user.id }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{{ user.name }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ user.email }}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ user.role }}</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="border-t border-gray-200 pt-4">
          <Pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :total-items="totalItems"
            :show-page-size="true"
            :show-first-last="true"
          />
        </div>
      </div>
    `,
  }),
}

// Compact layout (without total count)
export const CompactLayout: Story = {
  args: {
    currentPage: 5,
    totalItems: 100,
    showTotal: false,
  },
}

// Full featured
export const FullFeatured: Story = {
  render: (args) => ({
    components: { Pagination },
    setup() {
      const currentPage = ref(args.currentPage)
      const pageSize = ref(args.pageSize || 10)

      return { args, currentPage, pageSize }
    },
    template: `
      <Pagination
        v-bind="args"
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
      />
    `,
  }),
  args: {
    currentPage: 7,
    totalItems: 250,
    pageSize: 10,
    showPageSize: true,
    showTotal: true,
    showFirstLast: true,
    maxButtons: 7,
  },
}

// Custom page sizes
export const CustomPageSizes: Story = {
  render: () => ({
    components: { Pagination },
    setup() {
      const currentPage = ref(args.currentPage)
      const pageSize = ref(args.pageSize || 25)

      return { currentPage, pageSize }
    },
    template: `
      <Pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :total-items="500"
        :page-size-options="[25, 50, 75, 100, 200]"
        :show-page-size="true"
        :show-first-last="true"
      />
    `,
  }),
  args: {
    currentPage: 1,
    pageSize: 25,
  },
}

// Fewer max buttons
export const FewerButtons: Story = {
  render: () => ({
    components: { Pagination },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Max 5 Buttons</h3>
          <Pagination
            :current-page="10"
            :total-items="500"
            :max-buttons="5"
          />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Max 7 Buttons (Default)</h3>
          <Pagination
            :current-page="10"
            :total-items="500"
            :max-buttons="7"
          />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Max 9 Buttons</h3>
          <Pagination
            :current-page="10"
            :total-items="500"
            :max-buttons="9"
          />
        </div>
      </div>
    `,
  }),
}

// Ellipsis patterns
export const EllipsisPatterns: Story = {
  render: () => ({
    components: { Pagination },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Near Start (Page 3)</h3>
          <Pagination
            :current-page="3"
            :total-items="200"
            :max-buttons="7"
          />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">In Middle (Page 10)</h3>
          <Pagination
            :current-page="10"
            :total-items="200"
            :max-buttons="7"
          />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Near End (Page 18)</h3>
          <Pagination
            :current-page="18"
            :total-items="200"
            :max-buttons="7"
          />
        </div>
      </div>
    `,
  }),
}

// Real-world scenarios
export const RealWorldScenarios: Story = {
  render: () => ({
    components: { Pagination },
    setup() {
      const searchResults = ref({ currentPage: 1, pageSize: 20, totalItems: 487 })
      const blogPosts = ref({ currentPage: 1, pageSize: 10, totalItems: 156 })
      const products = ref({ currentPage: 1, pageSize: 24, totalItems: 1243 })

      return { searchResults, blogPosts, products }
    },
    template: `
      <div class="space-y-12">
        <div class="border border-gray-200 rounded-lg p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Search Results</h3>
          <p class="text-sm text-gray-600 mb-6">
            Large dataset with page size selector
          </p>
          <Pagination
            v-model:current-page="searchResults.currentPage"
            v-model:page-size="searchResults.pageSize"
            :total-items="searchResults.totalItems"
            :show-page-size="true"
            :page-size-options="[10, 20, 50]"
          />
        </div>

        <div class="border border-gray-200 rounded-lg p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Blog Posts</h3>
          <p class="text-sm text-gray-600 mb-6">
            Standard pagination with first/last buttons
          </p>
          <Pagination
            v-model:current-page="blogPosts.currentPage"
            :total-items="blogPosts.totalItems"
            :page-size="blogPosts.pageSize"
            :show-first-last="true"
          />
        </div>

        <div class="border border-gray-200 rounded-lg p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Product Catalog</h3>
          <p class="text-sm text-gray-600 mb-6">
            Large dataset with grid display (24 items per page)
          </p>
          <Pagination
            v-model:current-page="products.currentPage"
            v-model:page-size="products.pageSize"
            :total-items="products.totalItems"
            :show-page-size="true"
            :show-first-last="true"
            :page-size-options="[12, 24, 48, 96]"
          />
        </div>
      </div>
    `,
  }),
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Pagination },
    setup() {
      const currentPage = ref(5)
      const pageSize = ref(10)

      return { currentPage, pageSize }
    },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="space-y-4">
            <Pagination :current-page="1" :total-items="50" size="sm" />
            <Pagination :current-page="1" :total-items="50" size="md" />
            <Pagination :current-page="1" :total-items="50" size="lg" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With All Features</h3>
          <Pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :total-items="250"
            :show-page-size="true"
            :show-first-last="true"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Disabled</h3>
          <Pagination
            :current-page="5"
            :total-items="100"
            :show-first-last="true"
            disabled
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Compact (No Total)</h3>
          <Pagination
            :current-page="5"
            :total-items="100"
            :show-total="false"
          />
        </div>
      </div>
    `,
  }),
}
