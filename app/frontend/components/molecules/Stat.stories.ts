import type { Meta, StoryObj } from '@storybook/vue3'
import Stat from './Stat.vue'

const meta = {
  title: 'Molecules/Stat',
  component: Stat,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['default', 'success', 'warning', 'danger', 'info', 'primary'],
    },
    size: { control: 'select', options: ['sm', 'md', 'lg'] },
    loading: { control: 'boolean' },
    showTrend: { control: 'boolean' },
  },
  args: {
    variant: 'default',
    size: 'md',
    loading: false,
    showTrend: true,
  },
} satisfies Meta<typeof Stat>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    label: 'Total Users',
    value: 1234,
    change: 12.5,
    changeLabel: 'vs last month',
    icon: 'users',
  },
}

export const WithPrefix: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Stat
          label="Revenue"
          :value="12500"
          prefix="$"
          :change="15.3"
          icon="dollar-sign"
          variant="success"
        />

        <Stat
          label="Profit"
          :value="8200"
          prefix="€"
          :change="8.7"
          icon="trending-up"
          variant="success"
        />

        <Stat
          label="Budget"
          :value="25000"
          prefix="£"
          :change="-3.2"
          icon="credit-card"
          variant="warning"
        />
      </div>
    `,
  }),
}

export const WithSuffix: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Stat
          label="Completion Rate"
          :value="98.5"
          suffix="%"
          :change="2.3"
          icon="check-circle"
          variant="success"
        />

        <Stat
          label="Load Time"
          :value="1.2"
          suffix="s"
          :change="-15"
          icon="zap"
          variant="info"
        />

        <Stat
          label="Storage Used"
          :value="45.8"
          suffix="GB"
          :change="5.2"
          icon="hard-drive"
          variant="primary"
        />
      </div>
    `,
  }),
}

export const Variants: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Stat
          label="Default"
          :value="1000"
          variant="default"
          icon="activity"
        />

        <Stat
          label="Success"
          :value="1500"
          variant="success"
          icon="trending-up"
          :change="12"
        />

        <Stat
          label="Warning"
          :value="850"
          variant="warning"
          icon="alert-triangle"
          :change="-5"
        />

        <Stat
          label="Danger"
          :value="450"
          variant="danger"
          icon="alert-circle"
          :change="-15"
        />

        <Stat
          label="Info"
          :value="2200"
          variant="info"
          icon="info"
          :change="8"
        />

        <Stat
          label="Primary"
          :value="3000"
          variant="primary"
          icon="star"
          :change="20"
        />
      </div>
    `,
  }),
}

export const Sizes: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 gap-4">
        <Stat
          label="Small Size"
          :value="1000"
          size="sm"
          icon="users"
          :change="5"
        />

        <Stat
          label="Medium Size (Default)"
          :value="2000"
          size="md"
          icon="users"
          :change="10"
        />

        <Stat
          label="Large Size"
          :value="3000"
          size="lg"
          icon="users"
          :change="15"
        />
      </div>
    `,
  }),
}

export const WithChange: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Stat
          label="Positive Change"
          :value="1500"
          :change="25.5"
          change-label="vs last week"
          icon="trending-up"
          variant="success"
        />

        <Stat
          label="Negative Change"
          :value="850"
          :change="-12.3"
          change-label="vs last week"
          icon="trending-down"
          variant="danger"
        />

        <Stat
          label="No Change"
          :value="1000"
          :change="0"
          change-label="vs last week"
          icon="minus"
          variant="default"
        />
      </div>
    `,
  }),
}

export const WithoutTrendIcons: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Stat
          label="Revenue"
          :value="12500"
          prefix="$"
          :change="15"
          :show-trend="false"
          icon="dollar-sign"
        />

        <Stat
          label="Users"
          :value="1234"
          :change="-8"
          :show-trend="false"
          icon="users"
        />
      </div>
    `,
  }),
}

export const LoadingState: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Stat
          label="Total Revenue"
          :value="0"
          icon="dollar-sign"
          loading
        />

        <Stat
          label="Active Users"
          :value="0"
          icon="users"
          loading
        />

        <Stat
          label="Conversion Rate"
          :value="0"
          icon="trending-up"
          loading
        />
      </div>
    `,
  }),
}

export const WithFooter: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Stat
          label="Total Sales"
          :value="45280"
          prefix="$"
          :change="18.2"
          icon="shopping-cart"
          variant="success"
        >
          <template #footer>
            <a href="#" class="text-sm text-primary-600 hover:text-primary-700 font-medium">
              View details →
            </a>
          </template>
        </Stat>

        <Stat
          label="New Customers"
          :value="324"
          :change="12.5"
          icon="user-plus"
          variant="info"
        >
          <template #footer>
            <button class="text-sm text-primary-600 hover:text-primary-700 font-medium">
              See all customers →
            </button>
          </template>
        </Stat>
      </div>
    `,
  }),
}

export const DashboardExample: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Stat
          label="Total Revenue"
          :value="45280"
          prefix="$"
          :change="18.2"
          change-label="vs last month"
          icon="dollar-sign"
          variant="success"
        />

        <Stat
          label="Total Orders"
          :value="1234"
          :change="-8.5"
          change-label="vs last month"
          icon="shopping-bag"
          variant="warning"
        />

        <Stat
          label="Active Users"
          :value="8492"
          :change="12.3"
          change-label="vs last month"
          icon="users"
          variant="info"
        />

        <Stat
          label="Conversion Rate"
          :value="3.24"
          suffix="%"
          :change="5.1"
          change-label="vs last month"
          icon="trending-up"
          variant="success"
        />

        <Stat
          label="Avg. Order Value"
          :value="87.50"
          prefix="$"
          :change="2.8"
          change-label="vs last month"
          icon="credit-card"
          variant="primary"
        />

        <Stat
          label="Bounce Rate"
          :value="42.3"
          suffix="%"
          :change="-3.2"
          change-label="vs last month"
          icon="trending-down"
          variant="danger"
        />

        <Stat
          label="Page Views"
          :value="125000"
          :change="15.7"
          change-label="vs last month"
          icon="eye"
          variant="info"
        />

        <Stat
          label="New Subscribers"
          :value="892"
          :change="24.1"
          change-label="vs last month"
          icon="user-plus"
          variant="success"
        />
      </div>
    `,
  }),
}

export const MinimalStats: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Stat
          label="Count"
          :value="42"
        />

        <Stat
          label="Total"
          :value="1337"
        />

        <Stat
          label="Active"
          :value="99"
        />
      </div>
    `,
  }),
}

export const LargeNumbers: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Stat
          label="Total Downloads"
          value="2.5M"
          :change="15"
          icon="download"
          variant="success"
        />

        <Stat
          label="Global Users"
          value="1.2B"
          :change="8"
          icon="globe"
          variant="info"
        />

        <Stat
          label="API Requests"
          value="456K"
          suffix="/day"
          :change="22"
          icon="activity"
          variant="primary"
        />
      </div>
    `,
  }),
}

export const StringValues: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Stat
          label="Server Status"
          value="Online"
          icon="server"
          variant="success"
        />

        <Stat
          label="Build Status"
          value="Passing"
          icon="check-circle"
          variant="success"
        />

        <Stat
          label="Coverage"
          value="High"
          icon="shield"
          variant="info"
        />
      </div>
    `,
  }),
}

export const CompactLayout: Story = {
  render: () => ({
    components: { Stat },
    template: `
      <div class="max-w-sm space-y-2">
        <Stat
          label="Today"
          :value="125"
          size="sm"
          variant="primary"
        />

        <Stat
          label="This Week"
          :value="892"
          size="sm"
          :change="12"
          variant="success"
        />

        <Stat
          label="This Month"
          :value="3450"
          size="sm"
          :change="18"
          variant="success"
        />

        <Stat
          label="All Time"
          :value="125420"
          size="sm"
          variant="info"
        />
      </div>
    `,
  }),
}
