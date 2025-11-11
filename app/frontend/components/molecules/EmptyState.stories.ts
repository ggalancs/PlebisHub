import type { Meta, StoryObj } from '@storybook/vue3-vite'
import EmptyState from './EmptyState.vue'
import Button from '../atoms/Button.vue'

const meta = {
  title: 'Molecules/EmptyState',
  component: EmptyState,
  tags: ['autodocs'],
  argTypes: {
    title: { control: 'text' },
    description: { control: 'text' },
    icon: { control: 'text' },
    imageSrc: { control: 'text' },
    imageAlt: { control: 'text' },
    primaryAction: { control: 'text' },
    secondaryAction: { control: 'text' },
    size: { control: 'select', options: ['sm', 'md', 'lg'] },
  },
  args: {
    size: 'md',
  },
} satisfies Meta<typeof EmptyState>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: (args) => ({
    components: { EmptyState },
    setup() {
      return { args }
    },
    template: '<EmptyState v-bind="args" />',
  }),
  args: {
    title: 'No items found',
    description: "You haven't added any items yet. Get started by creating your first item.",
    primaryAction: 'Add Item',
    secondaryAction: 'Learn More',
  },
}

export const WithDefaultIcon: Story = {
  render: () => ({
    components: { EmptyState },
    template: `
      <EmptyState
        title="Your inbox is empty"
        description="Messages you receive will appear here"
      />
    `,
  }),
}

export const WithCustomIcon: Story = {
  render: () => ({
    components: { EmptyState },
    template: `
      <div class="space-y-8">
        <EmptyState
          icon="search"
          title="No search results"
          description="Try adjusting your search terms or filters"
          primary-action="Clear Search"
        />

        <EmptyState
          icon="file"
          title="No documents"
          description="Upload your first document to get started"
          primary-action="Upload Document"
        />

        <EmptyState
          icon="users"
          title="No team members"
          description="Invite your team to collaborate"
          primary-action="Invite Team"
        />
      </div>
    `,
  }),
}

export const WithImage: Story = {
  render: () => ({
    components: { EmptyState },
    template: `
      <EmptyState
        title="No projects yet"
        description="Create your first project to start building amazing things"
        image-src="https://illustrations.popsy.co/amber/web-design.svg"
        image-alt="Empty projects illustration"
        primary-action="Create Project"
        secondary-action="View Examples"
      />
    `,
  }),
}

export const WithSingleAction: Story = {
  render: () => ({
    components: { EmptyState },
    template: `
      <div class="space-y-8">
        <EmptyState
          icon="plus-circle"
          title="No items added"
          description="Start by adding your first item"
          primary-action="Add Item"
        />

        <EmptyState
          icon="mail"
          title="No messages"
          description="You're all caught up!"
        />
      </div>
    `,
  }),
}

export const Sizes: Story = {
  render: () => ({
    components: { EmptyState },
    template: `
      <div class="space-y-8 border-t pt-8">
        <div class="border rounded-lg">
          <EmptyState
            size="sm"
            title="Small Size"
            description="Compact empty state for smaller spaces"
            primary-action="Action"
          />
        </div>

        <div class="border rounded-lg">
          <EmptyState
            size="md"
            title="Medium Size (Default)"
            description="Standard size for most use cases"
            primary-action="Action"
          />
        </div>

        <div class="border rounded-lg">
          <EmptyState
            size="lg"
            title="Large Size"
            description="More prominent empty state with larger spacing and text"
            primary-action="Action"
          />
        </div>
      </div>
    `,
  }),
}

export const CustomSlots: Story = {
  render: () => ({
    components: { EmptyState, Button },
    template: `
      <EmptyState title="Custom Empty State">
        <template #icon>
          <div class="text-6xl mb-4">🎨</div>
        </template>

        <template #description>
          <p class="text-gray-600 mb-2">You haven't created any designs yet.</p>
          <p class="text-sm text-gray-500">Start by choosing a template or creating from scratch</p>
        </template>

        <template #actions>
          <div class="flex flex-col sm:flex-row gap-3">
            <Button>Create from Template</Button>
            <Button variant="secondary">Start from Scratch</Button>
            <Button variant="secondary">Watch Tutorial</Button>
          </div>
        </template>
      </EmptyState>
    `,
  }),
}

export const RealWorldExamples: Story = {
  render: () => ({
    components: { EmptyState },
    setup() {
      const handleAction = (action: string) => alert(`${action} clicked`)
      return { handleAction }
    },
    template: `
      <div class="space-y-12">
        <!-- Empty Table -->
        <div class="border rounded-lg">
          <EmptyState
            icon="database"
            title="No data available"
            description="There are no records to display. Add your first entry to see it here."
            primary-action="Add Entry"
            @primary-action="handleAction('Add Entry')"
          />
        </div>

        <!-- Empty Search -->
        <div class="border rounded-lg">
          <EmptyState
            icon="search"
            title="No results found for 'query'"
            description="We couldn't find any matches. Try different keywords or check your spelling."
            primary-action="Clear Search"
            secondary-action="Browse All"
            @primary-action="handleAction('Clear Search')"
            @secondary-action="handleAction('Browse All')"
          />
        </div>

        <!-- Empty Favorites -->
        <div class="border rounded-lg">
          <EmptyState
            icon="star"
            title="No favorites yet"
            description="Save your favorite items here for quick access later."
          />
        </div>

        <!-- Empty Cart -->
        <div class="border rounded-lg">
          <EmptyState
            icon="shopping-cart"
            title="Your cart is empty"
            description="Looks like you haven't added anything to your cart yet."
            primary-action="Start Shopping"
            @primary-action="handleAction('Start Shopping')"
          />
        </div>

        <!-- Empty Notifications -->
        <div class="border rounded-lg">
          <EmptyState
            size="sm"
            icon="bell"
            title="No notifications"
            description="You're all caught up!"
          />
        </div>

        <!-- Empty Trash -->
        <div class="border rounded-lg">
          <EmptyState
            icon="trash-2"
            title="Trash is empty"
            description="Items you delete will appear here for 30 days before being permanently removed."
          />
        </div>

        <!-- Error State -->
        <div class="border rounded-lg border-red-200 bg-red-50">
          <EmptyState
            icon="alert-circle"
            title="Failed to load data"
            description="We couldn't load your data. Please check your connection and try again."
            primary-action="Retry"
            @primary-action="handleAction('Retry')"
          />
        </div>

        <!-- Offline State -->
        <div class="border rounded-lg border-gray-300">
          <EmptyState
            icon="wifi-off"
            title="You're offline"
            description="Please check your internet connection to continue."
          />
        </div>
      </div>
    `,
  }),
}

export const MinimalState: Story = {
  render: () => ({
    components: { EmptyState },
    template: `
      <div class="border rounded-lg">
        <EmptyState title="Nothing here yet" />
      </div>
    `,
  }),
}

export const WithImageIllustration: Story = {
  render: () => ({
    components: { EmptyState },
    template: `
      <div class="space-y-8">
        <div class="border rounded-lg">
          <EmptyState
            title="No files uploaded"
            description="Drag and drop files here or click the button below to upload"
            image-src="https://illustrations.popsy.co/amber/uploading.svg"
            image-alt="Upload illustration"
            primary-action="Choose Files"
            size="lg"
          />
        </div>

        <div class="border rounded-lg">
          <EmptyState
            title="Build something amazing"
            description="Get started with our templates or create your own design from scratch"
            image-src="https://illustrations.popsy.co/amber/idea.svg"
            image-alt="Ideas illustration"
            primary-action="Get Started"
            secondary-action="View Templates"
          />
        </div>
      </div>
    `,
  }),
}

export const DescriptionOnly: Story = {
  render: () => ({
    components: { EmptyState },
    template: `
      <div class="border rounded-lg">
        <EmptyState
          title="Maintenance Mode"
          description="We're currently performing scheduled maintenance. We'll be back shortly!"
          icon="tool"
        />
      </div>
    `,
  }),
}

export const LongContent: Story = {
  render: () => ({
    components: { EmptyState },
    template: `
      <div class="border rounded-lg">
        <EmptyState
          icon="info"
          title="Important Information"
          description="This is a longer description that provides more context about why this state exists and what the user should do next. It can span multiple lines and provide detailed guidance to help users understand the situation and take appropriate action."
          primary-action="Take Action"
          secondary-action="Learn More"
        />
      </div>
    `,
  }),
}

export const Interactive: Story = {
  render: () => ({
    components: { EmptyState },
    setup() {
      const handlePrimary = () => alert('Primary action triggered!')
      const handleSecondary = () => alert('Secondary action triggered!')
      return { handlePrimary, handleSecondary }
    },
    template: `
      <div class="border rounded-lg">
        <EmptyState
          icon="inbox"
          title="Try the actions"
          description="Click the buttons below to see the events being emitted"
          primary-action="Primary Action"
          secondary-action="Secondary Action"
          @primary-action="handlePrimary"
          @secondary-action="handleSecondary"
        />
      </div>
    `,
  }),
}
