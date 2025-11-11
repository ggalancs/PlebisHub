import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import Tabs from './Tabs.vue'
import TabPanel from './TabPanel.vue'

const meta = {
  title: 'Molecules/Tabs',
  component: Tabs,
  tags: ['autodocs'],
  argTypes: {
    modelValue: {
      control: 'text',
      description: 'Active tab key',
    },
    items: {
      control: 'object',
      description: 'Tab items array',
    },
    variant: {
      control: 'select',
      options: ['underline', 'pills', 'cards'],
      description: 'Tab variant',
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Size variant',
    },
    fullWidth: {
      control: 'boolean',
      description: 'Full width tabs',
    },
    vertical: {
      control: 'boolean',
      description: 'Vertical orientation',
    },
    lazy: {
      control: 'boolean',
      description: 'Lazy load tab panels',
    },
  },
  args: {
    variant: 'underline',
    size: 'md',
    fullWidth: false,
    vertical: false,
    lazy: false,
  },
} satisfies Meta<typeof Tabs>

export default meta
type Story = StoryObj<typeof meta>

// Default tabs
export const Default: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    setup() {
      const activeTab = ref('home')
      const items = [
        { key: 'home', label: 'Home' },
        { key: 'profile', label: 'Profile' },
        { key: 'settings', label: 'Settings' },
      ]
      return { activeTab, items }
    },
    template: `
      <Tabs v-model="activeTab" :items="items">
        <TabPanel tab-key="home">
          <div class="p-4">
            <h3 class="text-lg font-semibold mb-2">Home</h3>
            <p>Welcome to the home page!</p>
          </div>
        </TabPanel>
        <TabPanel tab-key="profile">
          <div class="p-4">
            <h3 class="text-lg font-semibold mb-2">Profile</h3>
            <p>Your profile information.</p>
          </div>
        </TabPanel>
        <TabPanel tab-key="settings">
          <div class="p-4">
            <h3 class="text-lg font-semibold mb-2">Settings</h3>
            <p>Configure your settings.</p>
          </div>
        </TabPanel>
      </Tabs>
    `,
  }),
}

// All variants
export const Variants: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    setup() {
      const items = [
        { key: 'tab1', label: 'Tab 1' },
        { key: 'tab2', label: 'Tab 2' },
        { key: 'tab3', label: 'Tab 3' },
      ]
      return { items }
    },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-sm font-medium mb-3">Underline (Default)</h3>
          <Tabs :items="items" variant="underline">
            <TabPanel tab-key="tab1"><div class="p-4">Content 1</div></TabPanel>
            <TabPanel tab-key="tab2"><div class="p-4">Content 2</div></TabPanel>
            <TabPanel tab-key="tab3"><div class="p-4">Content 3</div></TabPanel>
          </Tabs>
        </div>

        <div>
          <h3 class="text-sm font-medium mb-3">Pills</h3>
          <Tabs :items="items" variant="pills">
            <TabPanel tab-key="tab1"><div class="p-4">Content 1</div></TabPanel>
            <TabPanel tab-key="tab2"><div class="p-4">Content 2</div></TabPanel>
            <TabPanel tab-key="tab3"><div class="p-4">Content 3</div></TabPanel>
          </Tabs>
        </div>

        <div>
          <h3 class="text-sm font-medium mb-3">Cards</h3>
          <Tabs :items="items" variant="cards">
            <TabPanel tab-key="tab1"><div class="p-4 border border-t-0 rounded-b">Content 1</div></TabPanel>
            <TabPanel tab-key="tab2"><div class="p-4 border border-t-0 rounded-b">Content 2</div></TabPanel>
            <TabPanel tab-key="tab3"><div class="p-4 border border-t-0 rounded-b">Content 3</div></TabPanel>
          </Tabs>
        </div>
      </div>
    `,
  }),
}

// With icons
export const WithIcons: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    setup() {
      const activeTab = ref('home')
      const items = [
        { key: 'home', label: 'Home', icon: 'home' },
        { key: 'user', label: 'Profile', icon: 'user' },
        { key: 'settings', label: 'Settings', icon: 'settings' },
      ]
      return { activeTab, items }
    },
    template: `
      <Tabs v-model="activeTab" :items="items" variant="pills">
        <TabPanel tab-key="home"><div class="p-4">Home content</div></TabPanel>
        <TabPanel tab-key="user"><div class="p-4">Profile content</div></TabPanel>
        <TabPanel tab-key="settings"><div class="p-4">Settings content</div></TabPanel>
      </Tabs>
    `,
  }),
}

// With badges
export const WithBadges: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    setup() {
      const activeTab = ref('inbox')
      const items = [
        {
          key: 'inbox',
          label: 'Inbox',
          icon: 'inbox',
          badge: 12,
          badgeVariant: 'primary' as const,
        },
        {
          key: 'spam',
          label: 'Spam',
          icon: 'alert-triangle',
          badge: 3,
          badgeVariant: 'warning' as const,
        },
        {
          key: 'trash',
          label: 'Trash',
          icon: 'trash',
          badge: '100+',
          badgeVariant: 'danger' as const,
        },
      ]
      return { activeTab, items }
    },
    template: `
      <Tabs v-model="activeTab" :items="items">
        <TabPanel tab-key="inbox"><div class="p-4">12 unread messages</div></TabPanel>
        <TabPanel tab-key="spam"><div class="p-4">3 spam messages</div></TabPanel>
        <TabPanel tab-key="trash"><div class="p-4">100+ trashed messages</div></TabPanel>
      </Tabs>
    `,
  }),
}

// Different sizes
export const Sizes: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    setup() {
      const items = [
        { key: 'tab1', label: 'Tab 1' },
        { key: 'tab2', label: 'Tab 2' },
        { key: 'tab3', label: 'Tab 3' },
      ]
      return { items }
    },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-sm font-medium mb-3">Small</h3>
          <Tabs :items="items" size="sm">
            <TabPanel tab-key="tab1"><div class="p-3 text-sm">Content 1</div></TabPanel>
            <TabPanel tab-key="tab2"><div class="p-3 text-sm">Content 2</div></TabPanel>
            <TabPanel tab-key="tab3"><div class="p-3 text-sm">Content 3</div></TabPanel>
          </Tabs>
        </div>

        <div>
          <h3 class="text-sm font-medium mb-3">Medium (Default)</h3>
          <Tabs :items="items" size="md">
            <TabPanel tab-key="tab1"><div class="p-4">Content 1</div></TabPanel>
            <TabPanel tab-key="tab2"><div class="p-4">Content 2</div></TabPanel>
            <TabPanel tab-key="tab3"><div class="p-4">Content 3</div></TabPanel>
          </Tabs>
        </div>

        <div>
          <h3 class="text-sm font-medium mb-3">Large</h3>
          <Tabs :items="items" size="lg">
            <TabPanel tab-key="tab1"><div class="p-5 text-lg">Content 1</div></TabPanel>
            <TabPanel tab-key="tab2"><div class="p-5 text-lg">Content 2</div></TabPanel>
            <TabPanel tab-key="tab3"><div class="p-5 text-lg">Content 3</div></TabPanel>
          </Tabs>
        </div>
      </div>
    `,
  }),
}

// Full width
export const FullWidth: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    setup() {
      const activeTab = ref('overview')
      const items = [
        { key: 'overview', label: 'Overview' },
        { key: 'analytics', label: 'Analytics' },
        { key: 'reports', label: 'Reports' },
        { key: 'notifications', label: 'Notifications' },
      ]
      return { activeTab, items }
    },
    template: `
      <Tabs v-model="activeTab" :items="items" :full-width="true">
        <TabPanel tab-key="overview"><div class="p-4">Overview content</div></TabPanel>
        <TabPanel tab-key="analytics"><div class="p-4">Analytics content</div></TabPanel>
        <TabPanel tab-key="reports"><div class="p-4">Reports content</div></TabPanel>
        <TabPanel tab-key="notifications"><div class="p-4">Notifications content</div></TabPanel>
      </Tabs>
    `,
  }),
}

// Vertical orientation
export const Vertical: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    setup() {
      const activeTab = ref('general')
      const items = [
        { key: 'general', label: 'General', icon: 'settings' },
        { key: 'security', label: 'Security', icon: 'shield' },
        { key: 'notifications', label: 'Notifications', icon: 'bell' },
        { key: 'billing', label: 'Billing', icon: 'credit-card' },
      ]
      return { activeTab, items }
    },
    template: `
      <Tabs v-model="activeTab" :items="items" :vertical="true" variant="pills">
        <TabPanel tab-key="general">
          <div class="p-6 border rounded-lg">
            <h3 class="text-lg font-semibold mb-4">General Settings</h3>
            <p>Configure general application settings.</p>
          </div>
        </TabPanel>
        <TabPanel tab-key="security">
          <div class="p-6 border rounded-lg">
            <h3 class="text-lg font-semibold mb-4">Security Settings</h3>
            <p>Manage your security preferences.</p>
          </div>
        </TabPanel>
        <TabPanel tab-key="notifications">
          <div class="p-6 border rounded-lg">
            <h3 class="text-lg font-semibold mb-4">Notification Settings</h3>
            <p>Control notification preferences.</p>
          </div>
        </TabPanel>
        <TabPanel tab-key="billing">
          <div class="p-6 border rounded-lg">
            <h3 class="text-lg font-semibold mb-4">Billing Settings</h3>
            <p>Manage billing and subscriptions.</p>
          </div>
        </TabPanel>
      </Tabs>
    `,
  }),
}

// Disabled tabs
export const DisabledTabs: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    setup() {
      const activeTab = ref('free')
      const items = [
        { key: 'free', label: 'Free Plan' },
        { key: 'pro', label: 'Pro Plan', disabled: true },
        { key: 'enterprise', label: 'Enterprise', disabled: true },
      ]
      return { activeTab, items }
    },
    template: `
      <Tabs v-model="activeTab" :items="items">
        <TabPanel tab-key="free">
          <div class="p-4">
            <p>Free plan features available</p>
          </div>
        </TabPanel>
        <TabPanel tab-key="pro">
          <div class="p-4">
            <p>Upgrade to Pro to access these features</p>
          </div>
        </TabPanel>
        <TabPanel tab-key="enterprise">
          <div class="p-4">
            <p>Contact sales for Enterprise features</p>
          </div>
        </TabPanel>
      </Tabs>
    `,
  }),
}

// Lazy loading
export const LazyLoading: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    setup() {
      const activeTab = ref('tab1')
      const items = [
        { key: 'tab1', label: 'Tab 1' },
        { key: 'tab2', label: 'Tab 2 (Lazy)' },
        { key: 'tab3', label: 'Tab 3 (Lazy)' },
      ]
      return { activeTab, items }
    },
    template: `
      <div>
        <div class="mb-4 p-3 bg-blue-50 border border-blue-200 rounded">
          <p class="text-sm text-blue-800">
            With lazy loading, tab panels are only rendered when first visited.
            Open DevTools and inspect the DOM to see panels load on demand.
          </p>
        </div>

        <Tabs v-model="activeTab" :items="items" :lazy="true">
          <TabPanel tab-key="tab1">
            <div class="p-4 border rounded">
              <h4 class="font-medium mb-2">Tab 1 Content</h4>
              <p>This content loads immediately</p>
            </div>
          </TabPanel>
          <TabPanel tab-key="tab2">
            <div class="p-4 border rounded">
              <h4 class="font-medium mb-2">Tab 2 Content</h4>
              <p>This content loads when you first click Tab 2</p>
            </div>
          </TabPanel>
          <TabPanel tab-key="tab3">
            <div class="p-4 border rounded">
              <h4 class="font-medium mb-2">Tab 3 Content</h4>
              <p>This content loads when you first click Tab 3</p>
            </div>
          </TabPanel>
        </Tabs>
      </div>
    `,
  }),
}

// Interactive example
export const Interactive: Story = {
  render: (args) => ({
    components: { Tabs, TabPanel },
    setup() {
      const activeTab = ref(args.modelValue || 'home')
      const items = [
        { key: 'home', label: 'Home', icon: 'home' },
        { key: 'profile', label: 'Profile', icon: 'user', badge: 3 },
        { key: 'settings', label: 'Settings', icon: 'settings' },
      ]

      const handleTabChange = (key: string) => {
        console.log('Tab changed to:', key)
      }

      return { activeTab, items, handleTabChange, args }
    },
    template: `
      <div>
        <Tabs
          v-model="activeTab"
          :items="items"
          v-bind="args"
          @tab-change="handleTabChange"
        >
          <TabPanel tab-key="home">
            <div class="p-4 border rounded">Home content</div>
          </TabPanel>
          <TabPanel tab-key="profile">
            <div class="p-4 border rounded">Profile content</div>
          </TabPanel>
          <TabPanel tab-key="settings">
            <div class="p-4 border rounded">Settings content</div>
          </TabPanel>
        </Tabs>

        <div class="mt-4 p-3 bg-gray-50 border rounded">
          <p class="text-sm"><strong>Active Tab:</strong> {{ activeTab }}</p>
        </div>
      </div>
    `,
  }),
  args: {
    variant: 'pills',
    size: 'md',
  },
}

// Real-world: Dashboard
export const Dashboard: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    setup() {
      const activeTab = ref('overview')
      const items = [
        { key: 'overview', label: 'Overview', icon: 'layout-dashboard' },
        {
          key: 'analytics',
          label: 'Analytics',
          icon: 'bar-chart',
          badge: 'New',
          badgeVariant: 'success' as const,
        },
        { key: 'reports', label: 'Reports', icon: 'file-text' },
        { key: 'settings', label: 'Settings', icon: 'settings' },
      ]
      return { activeTab, items }
    },
    template: `
      <div class="max-w-6xl">
        <h2 class="text-2xl font-bold mb-4">Dashboard</h2>

        <Tabs v-model="activeTab" :items="items" variant="underline">
          <TabPanel tab-key="overview">
            <div class="p-6 space-y-4">
              <div class="grid grid-cols-3 gap-4">
                <div class="p-4 bg-gray-50 rounded-lg">
                  <p class="text-sm text-gray-600">Total Users</p>
                  <p class="text-2xl font-bold">1,234</p>
                </div>
                <div class="p-4 bg-gray-50 rounded-lg">
                  <p class="text-sm text-gray-600">Revenue</p>
                  <p class="text-2xl font-bold">$45,678</p>
                </div>
                <div class="p-4 bg-gray-50 rounded-lg">
                  <p class="text-sm text-gray-600">Growth</p>
                  <p class="text-2xl font-bold">+23%</p>
                </div>
              </div>
            </div>
          </TabPanel>

          <TabPanel tab-key="analytics">
            <div class="p-6">
              <p>Advanced analytics and insights...</p>
            </div>
          </TabPanel>

          <TabPanel tab-key="reports">
            <div class="p-6">
              <p>Generated reports and exports...</p>
            </div>
          </TabPanel>

          <TabPanel tab-key="settings">
            <div class="p-6">
              <p>Dashboard configuration...</p>
            </div>
          </TabPanel>
        </Tabs>
      </div>
    `,
  }),
}

// Showcase all features
export const ShowcaseAll: Story = {
  render: () => ({
    components: { Tabs, TabPanel },
    template: `
      <div class="space-y-12">
        <div>
          <h3 class="text-lg font-semibold mb-4">Variants</h3>
          <div class="space-y-6">
            <Tabs :items="[{key: '1', label: 'Tab 1'}, {key: '2', label: 'Tab 2'}]" variant="underline">
              <TabPanel tab-key="1"><div class="p-4">Underline variant</div></TabPanel>
              <TabPanel tab-key="2"><div class="p-4">Content 2</div></TabPanel>
            </Tabs>

            <Tabs :items="[{key: '1', label: 'Tab 1'}, {key: '2', label: 'Tab 2'}]" variant="pills">
              <TabPanel tab-key="1"><div class="p-4">Pills variant</div></TabPanel>
              <TabPanel tab-key="2"><div class="p-4">Content 2</div></TabPanel>
            </Tabs>

            <Tabs :items="[{key: '1', label: 'Tab 1'}, {key: '2', label: 'Tab 2'}]" variant="cards">
              <TabPanel tab-key="1"><div class="p-4 border border-t-0 rounded-b">Cards variant</div></TabPanel>
              <TabPanel tab-key="2"><div class="p-4 border border-t-0 rounded-b">Content 2</div></TabPanel>
            </Tabs>
          </div>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">With Icons and Badges</h3>
          <Tabs :items="[
            {key: 'inbox', label: 'Inbox', icon: 'inbox', badge: 5},
            {key: 'sent', label: 'Sent', icon: 'send'},
            {key: 'trash', label: 'Trash', icon: 'trash', badge: '10+', badgeVariant: 'danger'}
          ]" variant="pills">
            <TabPanel tab-key="inbox"><div class="p-4">Inbox messages</div></TabPanel>
            <TabPanel tab-key="sent"><div class="p-4">Sent messages</div></TabPanel>
            <TabPanel tab-key="trash"><div class="p-4">Trash</div></TabPanel>
          </Tabs>
        </div>

        <div>
          <h3 class="text-lg font-semibold mb-4">Full Width</h3>
          <Tabs :items="[{key: '1', label: 'Tab 1'}, {key: '2', label: 'Tab 2'}, {key: '3', label: 'Tab 3'}]" :full-width="true">
            <TabPanel tab-key="1"><div class="p-4">Content 1</div></TabPanel>
            <TabPanel tab-key="2"><div class="p-4">Content 2</div></TabPanel>
            <TabPanel tab-key="3"><div class="p-4">Content 3</div></TabPanel>
          </Tabs>
        </div>
      </div>
    `,
  }),
}
