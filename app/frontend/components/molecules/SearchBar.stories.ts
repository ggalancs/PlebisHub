import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import SearchBar from './SearchBar.vue'

const meta = {
  title: 'Molecules/SearchBar',
  component: SearchBar,
  tags: ['autodocs'],
  argTypes: {
    modelValue: {
      control: 'text',
      description: 'Search query value',
    },
    placeholder: {
      control: 'text',
      description: 'Placeholder text',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'SearchBar size',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
    showButton: {
      control: 'boolean',
      description: 'Show search button',
    },
    buttonText: {
      control: 'text',
      description: 'Button text',
    },
    loading: {
      control: 'boolean',
      description: 'Loading state',
    },
    showClear: {
      control: 'boolean',
      description: 'Show clear button',
    },
    debounce: {
      control: { type: 'number', min: 0, max: 1000, step: 100 },
      description: 'Debounce delay (ms)',
    },
  },
  args: {
    placeholder: 'Search...',
    size: 'md',
    disabled: false,
    showButton: false,
    buttonText: 'Search',
    loading: false,
    showClear: true,
    debounce: 0,
  },
} satisfies Meta<typeof SearchBar>

export default meta
type Story = StoryObj<typeof meta>

// Default search bar
export const Default: Story = {
  args: {
    placeholder: 'Search...',
  },
}

// All sizes
export const AllSizes: Story = {
  render: () => ({
    components: { SearchBar },
    template: `
      <div class="space-y-4">
        <SearchBar size="sm" placeholder="Small search" />
        <SearchBar size="md" placeholder="Medium search (default)" />
        <SearchBar size="lg" placeholder="Large search" />
      </div>
    `,
  }),
}

// With search button
export const WithButton: Story = {
  args: {
    showButton: true,
    placeholder: 'Search products...',
  },
}

// With custom button text
export const CustomButtonText: Story = {
  args: {
    showButton: true,
    buttonText: 'Find',
    placeholder: 'Search...',
  },
}

// Loading state
export const Loading: Story = {
  args: {
    showButton: true,
    loading: true,
    modelValue: 'searching...',
  },
}

// Disabled
export const Disabled: Story = {
  args: {
    disabled: true,
    modelValue: 'Cannot search',
  },
}

// Without clear button
export const WithoutClear: Story = {
  args: {
    showClear: false,
    modelValue: 'No clear button',
  },
}

// Interactive with live results
export const LiveSearch: Story = {
  render: () => ({
    components: { SearchBar },
    setup() {
      const query = ref('')
      const items = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry', 'Fig', 'Grape']
      const filteredItems = ref<string[]>([])

      const handleSearch = (value: string) => {
        if (value) {
          filteredItems.value = items.filter((item) =>
            item.toLowerCase().includes(value.toLowerCase())
          )
        } else {
          filteredItems.value = []
        }
      }

      return { query, filteredItems, handleSearch }
    },
    template: `
      <div>
        <SearchBar
          v-model="query"
          placeholder="Search fruits..."
          @search="handleSearch"
        />
        <div v-if="filteredItems.length > 0" class="mt-4 border border-gray-200 rounded-lg divide-y divide-gray-200">
          <div
            v-for="item in filteredItems"
            :key="item"
            class="px-4 py-2 hover:bg-gray-50 cursor-pointer"
          >
            {{ item }}
          </div>
        </div>
        <p v-else-if="query" class="mt-4 text-sm text-gray-500">No results found</p>
      </div>
    `,
  }),
}

// With debounce
export const WithDebounce: Story = {
  render: () => ({
    components: { SearchBar },
    setup() {
      const query = ref('')
      const searchCount = ref(0)

      const handleSearch = () => {
        searchCount.value++
      }

      return { query, searchCount, handleSearch }
    },
    template: `
      <div>
        <SearchBar
          v-model="query"
          placeholder="Type to search (300ms debounce)..."
          :debounce="300"
          @search="handleSearch"
        />
        <div class="mt-4 p-4 bg-gray-50 rounded-md">
          <p class="text-sm text-gray-700">Query: <strong>{{ query || '(empty)' }}</strong></p>
          <p class="text-sm text-gray-700 mt-1">Search triggered: <strong>{{ searchCount }} times</strong></p>
        </div>
      </div>
    `,
  }),
}

// Page header search
export const PageHeader: Story = {
  render: () => ({
    components: { SearchBar },
    setup() {
      const query = ref('')
      return { query }
    },
    template: `
      <div class="border-b border-gray-200 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div class="flex items-center justify-between">
            <h1 class="text-2xl font-bold text-gray-900">Products</h1>
            <div class="flex-1 max-w-lg mx-8">
              <SearchBar
                v-model="query"
                placeholder="Search products..."
              />
            </div>
            <button class="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700">
              Add Product
            </button>
          </div>
        </div>
      </div>
    `,
  }),
}

// Data table search
export const DataTableSearch: Story = {
  render: () => ({
    components: { SearchBar },
    setup() {
      const query = ref('')
      const users = [
        { id: 1, name: 'John Doe', email: 'john@example.com', role: 'Admin' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'User' },
        { id: 3, name: 'Bob Johnson', email: 'bob@example.com', role: 'User' },
        { id: 4, name: 'Alice Williams', email: 'alice@example.com', role: 'Editor' },
      ]
      const filteredUsers = ref(users)

      const handleSearch = (value: string) => {
        if (value) {
          filteredUsers.value = users.filter(
            (user) =>
              user.name.toLowerCase().includes(value.toLowerCase()) ||
              user.email.toLowerCase().includes(value.toLowerCase())
          )
        } else {
          filteredUsers.value = users
        }
      }

      return { query, filteredUsers, handleSearch }
    },
    template: `
      <div>
        <div class="mb-4">
          <SearchBar
            v-model="query"
            placeholder="Search users by name or email..."
            show-button
            button-text="Search"
            @search="handleSearch"
          />
        </div>

        <div class="border border-gray-200 rounded-lg overflow-hidden">
          <table class="w-full">
            <thead class="bg-gray-50 border-b border-gray-200">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="user in filteredUsers" :key="user.id" class="hover:bg-gray-50">
                <td class="px-6 py-4 text-sm text-gray-900">{{ user.name }}</td>
                <td class="px-6 py-4 text-sm text-gray-500">{{ user.email }}</td>
                <td class="px-6 py-4 text-sm text-gray-500">{{ user.role }}</td>
              </tr>
              <tr v-if="filteredUsers.length === 0">
                <td colspan="3" class="px-6 py-8 text-center text-sm text-gray-500">
                  No users found matching your search
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    `,
  }),
}

// Search with filters
export const WithFilters: Story = {
  render: () => ({
    components: { SearchBar },
    setup() {
      const query = ref('')
      const filter = ref('all')

      return { query, filter }
    },
    template: `
      <div>
        <div class="flex gap-4 mb-4">
          <div class="flex-1">
            <SearchBar
              v-model="query"
              placeholder="Search..."
              show-button
            />
          </div>
          <select
            v-model="filter"
            class="px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="all">All Categories</option>
            <option value="electronics">Electronics</option>
            <option value="clothing">Clothing</option>
            <option value="books">Books</option>
          </select>
        </div>
        <div class="p-4 bg-gray-50 rounded-md">
          <p class="text-sm text-gray-700">Search: <strong>{{ query || '(none)' }}</strong></p>
          <p class="text-sm text-gray-700 mt-1">Filter: <strong>{{ filter }}</strong></p>
        </div>
      </div>
    `,
  }),
}

// Async search with loading
export const AsyncSearch: Story = {
  render: () => ({
    components: { SearchBar },
    setup() {
      const query = ref('')
      const loading = ref(false)
      const results = ref<string[]>([])

      const handleSearch = async (value: string) => {
        if (!value) {
          results.value = []
          return
        }

        loading.value = true

        // Simulate API call
        await new Promise((resolve) => setTimeout(resolve, 1000))

        // Mock results
        results.value = [
          `${value} - Result 1`,
          `${value} - Result 2`,
          `${value} - Result 3`,
          `${value} - Result 4`,
        ]

        loading.value = false
      }

      return { query, loading, results, handleSearch }
    },
    template: `
      <div>
        <SearchBar
          v-model="query"
          placeholder="Search (async with loading)..."
          show-button
          :loading="loading"
          :debounce="500"
          @search="handleSearch"
        />
        <div v-if="loading" class="mt-4 text-center py-8">
          <div class="inline-block animate-spin h-8 w-8 border-4 border-primary-600 border-t-transparent rounded-full"></div>
          <p class="mt-2 text-sm text-gray-600">Searching...</p>
        </div>
        <div v-else-if="results.length > 0" class="mt-4 border border-gray-200 rounded-lg divide-y divide-gray-200">
          <div
            v-for="(result, index) in results"
            :key="index"
            class="px-4 py-3 hover:bg-gray-50 cursor-pointer"
          >
            {{ result }}
          </div>
        </div>
        <p v-else-if="query" class="mt-4 text-center text-sm text-gray-500 py-8">
          No results found
        </p>
      </div>
    `,
  }),
}

// Mobile responsive
export const MobileResponsive: Story = {
  render: () => ({
    components: { SearchBar },
    template: `
      <div class="space-y-4">
        <div class="md:hidden">
          <SearchBar size="sm" placeholder="Mobile search" />
        </div>
        <div class="hidden md:block">
          <SearchBar size="md" placeholder="Desktop search" show-button />
        </div>
      </div>
    `,
  }),
}

// Interactive
export const Interactive: Story = {
  render: (args) => ({
    components: { SearchBar },
    setup() {
      const value = ref('')
      const lastSearch = ref('')

      const handleSearch = (query: string) => {
        lastSearch.value = query
      }

      return { args, value, lastSearch, handleSearch }
    },
    template: `
      <div class="space-y-4">
        <SearchBar v-bind="args" v-model="value" @search="handleSearch" />
        <div class="p-4 bg-gray-50 rounded-md">
          <p class="text-sm text-gray-700">Current value: <strong>{{ value || '(empty)' }}</strong></p>
          <p class="text-sm text-gray-700 mt-1">Last search: <strong>{{ lastSearch || '(none)' }}</strong></p>
        </div>
      </div>
    `,
  }),
  args: {
    placeholder: 'Try typing here...',
    showButton: true,
  },
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { SearchBar },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="space-y-3">
            <SearchBar size="sm" placeholder="Small search" />
            <SearchBar size="md" placeholder="Medium search (default)" />
            <SearchBar size="lg" placeholder="Large search" />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Button</h3>
          <SearchBar show-button placeholder="Search with button..." />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Loading State</h3>
          <SearchBar show-button loading model-value="Searching..." />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Disabled</h3>
          <SearchBar disabled model-value="Disabled search" />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Without Clear Button</h3>
          <SearchBar :show-clear="false" model-value="No clear button" />
        </div>
      </div>
    `,
  }),
}
