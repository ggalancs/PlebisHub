import type { Meta, StoryObj } from '@storybook/vue3'
import Breadcrumb, { type BreadcrumbItem } from './Breadcrumb.vue'

const meta = {
  title: 'Molecules/Breadcrumb',
  component: Breadcrumb,
  tags: ['autodocs'],
  argTypes: {
    items: {
      control: 'object',
      description: 'Breadcrumb items array',
    },
    separator: {
      control: 'select',
      options: ['chevron', 'slash', 'arrow', '>', '|', '•'],
      description: 'Separator between items',
    },
    showHome: {
      control: 'boolean',
      description: 'Show home icon for first item',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Size variant',
    },
    maxItems: {
      control: 'number',
      description: 'Maximum items to show (0 = show all)',
    },
  },
  args: {
    separator: 'chevron',
    showHome: false,
    size: 'md',
    maxItems: 0,
  },
} satisfies Meta<typeof Breadcrumb>

export default meta
type Story = StoryObj<typeof meta>

// Default breadcrumb
export const Default: Story = {
  args: {
    items: [
      { label: 'Home', href: '/' },
      { label: 'Products', href: '/products' },
      { label: 'Laptops', href: '/products/laptops' },
      { label: 'MacBook Pro' },
    ],
  },
}

// With home icon
export const WithHomeIcon: Story = {
  args: {
    items: [
      { label: 'Home', href: '/' },
      { label: 'Documentation', href: '/docs' },
      { label: 'Components', href: '/docs/components' },
      { label: 'Breadcrumb' },
    ],
    showHome: true,
  },
}

// Different separators
export const Separators: Story = {
  render: () => ({
    components: { Breadcrumb },
    setup() {
      const items = [
        { label: 'Home', href: '/' },
        { label: 'Products', href: '/products' },
        { label: 'Current' },
      ]

      return { items }
    },
    template: `
      <div class="space-y-6">
        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Chevron (Default)</h3>
          <Breadcrumb :items="items" separator="chevron" />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Slash</h3>
          <Breadcrumb :items="items" separator="slash" />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Arrow</h3>
          <Breadcrumb :items="items" separator="arrow" />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Custom Text (>)</h3>
          <Breadcrumb :items="items" separator=">" />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Custom Text (|)</h3>
          <Breadcrumb :items="items" separator="|" />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Custom Text (•)</h3>
          <Breadcrumb :items="items" separator="•" />
        </div>
      </div>
    `,
  }),
}

// Different sizes
export const Sizes: Story = {
  render: () => ({
    components: { Breadcrumb },
    setup() {
      const items = [
        { label: 'Home', href: '/' },
        { label: 'Products', href: '/products' },
        { label: 'Current' },
      ]

      return { items }
    },
    template: `
      <div class="space-y-6">
        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Small</h3>
          <Breadcrumb :items="items" size="sm" />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Medium (Default)</h3>
          <Breadcrumb :items="items" size="md" />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Large</h3>
          <Breadcrumb :items="items" size="lg" />
        </div>
      </div>
    `,
  }),
}

// With custom icons
export const WithIcons: Story = {
  args: {
    items: [
      { label: 'Dashboard', href: '/', icon: 'layout-dashboard' },
      { label: 'Settings', href: '/settings', icon: 'settings' },
      { label: 'Profile', href: '/settings/profile', icon: 'user' },
      { label: 'Edit' },
    ],
  },
}

// Long path with truncation
export const LongPath: Story = {
  args: {
    items: [
      { label: 'Home', href: '/' },
      { label: 'Category', href: '/category' },
      { label: 'Subcategory', href: '/category/sub' },
      { label: 'Product Type', href: '/category/sub/type' },
      { label: 'Brand', href: '/category/sub/type/brand' },
      { label: 'Product', href: '/category/sub/type/brand/product' },
      { label: 'Details' },
    ],
  },
}

// With max items (truncated)
export const Truncated: Story = {
  render: () => ({
    components: { Breadcrumb },
    setup() {
      const items = [
        { label: 'Home', href: '/' },
        { label: 'Category', href: '/category' },
        { label: 'Subcategory', href: '/category/sub' },
        { label: 'Product Type', href: '/category/sub/type' },
        { label: 'Brand', href: '/category/sub/type/brand' },
        { label: 'Product', href: '/category/sub/type/brand/product' },
        { label: 'Details' },
      ]

      return { items }
    },
    template: `
      <div class="space-y-6">
        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">All Items (7 total)</h3>
          <Breadcrumb :items="items" :max-items="0" />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Max 5 Items</h3>
          <Breadcrumb :items="items" :max-items="5" />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Max 4 Items</h3>
          <Breadcrumb :items="items" :max-items="4" />
        </div>

        <div>
          <h3 class="text-sm font-medium text-gray-700 mb-3">Max 3 Items</h3>
          <Breadcrumb :items="items" :max-items="3" />
        </div>
      </div>
    `,
  }),
}

// Disabled items
export const DisabledItems: Story = {
  args: {
    items: [
      { label: 'Home', href: '/' },
      { label: 'Restricted', href: '/restricted', disabled: true },
      { label: 'Allowed', href: '/allowed' },
      { label: 'Current' },
    ],
  },
}

// Simple two-level
export const TwoLevel: Story = {
  args: {
    items: [{ label: 'Home', href: '/' }, { label: 'Current Page' }],
    showHome: true,
  },
}

// Single item
export const SingleItem: Story = {
  args: {
    items: [{ label: 'Home' }],
  },
}

// E-commerce example
export const EcommerceExample: Story = {
  render: () => ({
    components: { Breadcrumb },
    template: `
      <div class="bg-white border border-gray-200 rounded-lg p-6">
        <Breadcrumb
          :items="[
            { label: 'Home', href: '/' },
            { label: 'Electronics', href: '/category/electronics' },
            { label: 'Computers', href: '/category/electronics/computers' },
            { label: 'Laptops', href: '/category/electronics/computers/laptops' },
            { label: 'MacBook Pro 16-inch' }
          ]"
          :show-home="true"
        />

        <div class="mt-8">
          <h1 class="text-3xl font-bold text-gray-900 mb-4">MacBook Pro 16-inch</h1>
          <p class="text-gray-600">
            High-performance laptop with M3 Max chip, stunning Retina display, and all-day battery life.
          </p>
        </div>
      </div>
    `,
  }),
}

// Documentation example
export const DocumentationExample: Story = {
  render: () => ({
    components: { Breadcrumb },
    template: `
      <div class="bg-gray-50 border border-gray-200 rounded-lg p-6">
        <Breadcrumb
          :items="[
            { label: 'Docs', href: '/docs', icon: 'book-open' },
            { label: 'Components', href: '/docs/components', icon: 'package' },
            { label: 'Molecules', href: '/docs/components/molecules', icon: 'layers' },
            { label: 'Breadcrumb' }
          ]"
          separator="arrow"
          size="sm"
        />

        <div class="mt-8">
          <h1 class="text-2xl font-bold text-gray-900 mb-2">Breadcrumb Component</h1>
          <p class="text-sm text-gray-600">
            A navigation aid that shows the current page's location within the site hierarchy.
          </p>
        </div>
      </div>
    `,
  }),
}

// Admin panel example
export const AdminPanelExample: Story = {
  render: () => ({
    components: { Breadcrumb },
    template: `
      <div class="bg-gray-900 border border-gray-700 rounded-lg p-6">
        <div class="[&_a]:text-gray-300 [&_a:hover]:text-white [&_span]:text-white [&_.text-gray-400]:text-gray-500">
          <Breadcrumb
            :items="[
              { label: 'Dashboard', href: '/admin', icon: 'layout-dashboard' },
              { label: 'Users', href: '/admin/users', icon: 'users' },
              { label: 'User Details' }
            ]"
            separator="chevron"
          />
        </div>

        <div class="mt-8">
          <h1 class="text-2xl font-bold text-white mb-2">User Management</h1>
          <p class="text-sm text-gray-400">
            View and manage user accounts and permissions.
          </p>
        </div>
      </div>
    `,
  }),
}

// Blog example
export const BlogExample: Story = {
  render: () => ({
    components: { Breadcrumb },
    template: `
      <article class="max-w-3xl">
        <Breadcrumb
          :items="[
            { label: 'Blog', href: '/blog' },
            { label: 'Technology', href: '/blog/technology' },
            { label: 'Web Development', href: '/blog/technology/web-development' },
            { label: 'Building Modern Web Apps' }
          ]"
          :show-home="true"
          size="sm"
        />

        <div class="mt-6">
          <h1 class="text-4xl font-bold text-gray-900 mb-4">
            Building Modern Web Applications
          </h1>
          <div class="flex items-center gap-4 text-sm text-gray-600 mb-8">
            <span>Published on Jan 15, 2024</span>
            <span>•</span>
            <span>8 min read</span>
          </div>
          <p class="text-lg text-gray-700 leading-relaxed">
            Learn how to build scalable and performant web applications using modern frameworks and best practices.
          </p>
        </div>
      </article>
    `,
  }),
}

// Interactive example
export const Interactive: Story = {
  render: (args) => ({
    components: { Breadcrumb },
    setup() {
      const handleClick = (item: BreadcrumbItem, index: number) => {
        console.log('Breadcrumb item clicked:', item, 'at index:', index)
        alert(`Clicked: ${item.label} (Index: ${index})`)
      }

      return { args, handleClick }
    },
    template: `
      <div class="space-y-4">
        <div class="p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <p class="text-sm text-blue-800">
            Click on any breadcrumb item to see the event
          </p>
        </div>

        <Breadcrumb
          v-bind="args"
          @click="handleClick"
        />
      </div>
    `,
  }),
  args: {
    items: [
      { label: 'Home', href: '/' },
      { label: 'Products', href: '/products' },
      { label: 'Laptops', href: '/products/laptops' },
      { label: 'Current Page' },
    ],
  },
}

// Real-world scenarios
export const RealWorldScenarios: Story = {
  render: () => ({
    components: { Breadcrumb },
    template: `
      <div class="space-y-12">
        <div class="border border-gray-200 rounded-lg p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">E-commerce Product Page</h3>
          <Breadcrumb
            :items="[
              { label: 'Home', href: '/' },
              { label: 'Men', href: '/men' },
              { label: 'Clothing', href: '/men/clothing' },
              { label: 'T-Shirts', href: '/men/clothing/tshirts' },
              { label: 'Classic Cotton Tee' }
            ]"
            :show-home="true"
          />
        </div>

        <div class="border border-gray-200 rounded-lg p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Support Portal</h3>
          <Breadcrumb
            :items="[
              { label: 'Support', href: '/support', icon: 'life-buoy' },
              { label: 'Knowledge Base', href: '/support/kb', icon: 'book' },
              { label: 'Getting Started', href: '/support/kb/getting-started', icon: 'rocket' },
              { label: 'Installation Guide' }
            ]"
            separator="arrow"
            size="sm"
          />
        </div>

        <div class="border border-gray-200 rounded-lg p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">File System Navigation</h3>
          <Breadcrumb
            :items="[
              { label: 'Root', href: '/', icon: 'hard-drive' },
              { label: 'Projects', href: '/projects', icon: 'folder' },
              { label: 'Website', href: '/projects/website', icon: 'folder' },
              { label: 'src', href: '/projects/website/src', icon: 'folder' },
              { label: 'components', icon: 'folder-open' }
            ]"
            separator="slash"
          />
        </div>

        <div class="border border-gray-200 rounded-lg p-6">
          <h3 class="text-lg font-semibold text-gray-900 mb-4">Settings Navigation (Truncated)</h3>
          <Breadcrumb
            :items="[
              { label: 'Settings', href: '/settings' },
              { label: 'Account', href: '/settings/account' },
              { label: 'Security', href: '/settings/account/security' },
              { label: 'Two-Factor Auth', href: '/settings/account/security/2fa' },
              { label: 'Backup Codes', href: '/settings/account/security/2fa/backup' },
              { label: 'Generate New Codes' }
            ]"
            :max-items="4"
          />
        </div>
      </div>
    `,
  }),
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Breadcrumb },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-4">Sizes</h3>
          <div class="space-y-4">
            <Breadcrumb
              :items="[
                { label: 'Home', href: '/' },
                { label: 'Products', href: '/products' },
                { label: 'Current' }
              ]"
              size="sm"
            />
            <Breadcrumb
              :items="[
                { label: 'Home', href: '/' },
                { label: 'Products', href: '/products' },
                { label: 'Current' }
              ]"
              size="md"
            />
            <Breadcrumb
              :items="[
                { label: 'Home', href: '/' },
                { label: 'Products', href: '/products' },
                { label: 'Current' }
              ]"
              size="lg"
            />
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Icons</h3>
          <Breadcrumb
            :items="[
              { label: 'Dashboard', href: '/', icon: 'layout-dashboard' },
              { label: 'Analytics', href: '/analytics', icon: 'bar-chart' },
              { label: 'Reports' }
            ]"
            :show-home="true"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Truncated Long Path</h3>
          <Breadcrumb
            :items="[
              { label: 'Home', href: '/' },
              { label: 'Level 1', href: '/1' },
              { label: 'Level 2', href: '/1/2' },
              { label: 'Level 3', href: '/1/2/3' },
              { label: 'Level 4', href: '/1/2/3/4' },
              { label: 'Current' }
            ]"
            :max-items="4"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Custom Separator</h3>
          <Breadcrumb
            :items="[
              { label: 'Home', href: '/' },
              { label: 'Products', href: '/products' },
              { label: 'Current' }
            ]"
            separator="•"
          />
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Disabled Items</h3>
          <Breadcrumb
            :items="[
              { label: 'Home', href: '/' },
              { label: 'Restricted', href: '/restricted', disabled: true },
              { label: 'Current' }
            ]"
          />
        </div>
      </div>
    `,
  }),
}
