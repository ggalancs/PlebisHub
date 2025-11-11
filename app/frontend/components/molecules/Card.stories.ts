import type { Meta, StoryObj } from '@storybook/vue3-vite'
import Card from './Card.vue'
import Button from '../atoms/Button.vue'
import Badge from '../atoms/Badge.vue'

const meta = {
  title: 'Molecules/Card',
  component: Card,
  tags: ['autodocs'],
  argTypes: {
    variant: { control: 'select', options: ['default', 'bordered', 'elevated', 'flat'] },
    padding: { control: 'select', options: ['none', 'sm', 'md', 'lg'] },
    hoverable: { control: 'boolean' },
    clickable: { control: 'boolean' },
    disabled: { control: 'boolean' },
    title: { control: 'text' },
    subtitle: { control: 'text' },
    imageSrc: { control: 'text' },
    imageAlt: { control: 'text' },
    href: { control: 'text' },
  },
  args: {
    variant: 'default',
    padding: 'md',
    hoverable: false,
    clickable: false,
    disabled: false,
  },
} satisfies Meta<typeof Card>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: () => ({
    components: { Card },
    template: `
      <Card title="Card Title" subtitle="This is a subtitle">
        <p class="text-gray-600">This is the card content. You can put any content here.</p>
      </Card>
    `,
  }),
}

export const Variants: Story = {
  render: () => ({
    components: { Card },
    template: `
      <div class="space-y-4">
        <Card variant="default" title="Default Card">
          <p class="text-gray-600">Default variant with medium shadow</p>
        </Card>

        <Card variant="bordered" title="Bordered Card">
          <p class="text-gray-600">Bordered variant with no shadow</p>
        </Card>

        <Card variant="elevated" title="Elevated Card">
          <p class="text-gray-600">Elevated variant with large shadow</p>
        </Card>

        <Card variant="flat" title="Flat Card">
          <p class="text-gray-600">Flat variant with gray background</p>
        </Card>
      </div>
    `,
  }),
}

export const WithImage: Story = {
  render: () => ({
    components: { Card, Button },
    template: `
      <div class="max-w-sm">
        <Card
          title="Beautiful Landscape"
          subtitle="Nature Photography"
          image-src="https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400"
          image-alt="Mountain landscape"
        >
          <p class="text-gray-600">A stunning view of mountains during sunset.</p>
          <template #footer>
            <div class="flex gap-2">
              <Button size="sm" variant="secondary">Share</Button>
              <Button size="sm">View</Button>
            </div>
          </template>
        </Card>
      </div>
    `,
  }),
}

export const Hoverable: Story = {
  render: () => ({
    components: { Card },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card variant="default" hoverable title="Hoverable Default">
          <p class="text-gray-600">Hover over me to see the shadow increase</p>
        </Card>

        <Card variant="elevated" hoverable title="Hoverable Elevated">
          <p class="text-gray-600">Hover over me to see the shadow increase</p>
        </Card>

        <Card variant="flat" hoverable title="Hoverable Flat">
          <p class="text-gray-600">Hover over me to see the background darken</p>
        </Card>

        <Card variant="bordered" hoverable title="Hoverable Bordered">
          <p class="text-gray-600">Hover over me to see the shadow appear</p>
        </Card>
      </div>
    `,
  }),
}

export const Clickable: Story = {
  render: () => ({
    components: { Card },
    setup() {
      const handleClick = () => alert('Card clicked!')
      return { handleClick }
    },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card
          clickable
          hoverable
          title="Clickable Card"
          @click="handleClick"
        >
          <p class="text-gray-600">Click me to trigger an action</p>
        </Card>

        <Card
          clickable
          hoverable
          variant="elevated"
          title="Interactive Card"
          @click="handleClick"
        >
          <p class="text-gray-600">I'm clickable and hoverable</p>
        </Card>

        <Card
          clickable
          hoverable
          variant="flat"
          title="Action Card"
          @click="handleClick"
        >
          <p class="text-gray-600">Try clicking me</p>
        </Card>
      </div>
    `,
  }),
}

export const AsLink: Story = {
  render: () => ({
    components: { Card },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card
          href="https://example.com"
          hoverable
          title="Link Card"
          subtitle="Click to navigate"
        >
          <p class="text-gray-600">This card is a link to example.com</p>
        </Card>

        <Card
          href="https://github.com"
          hoverable
          variant="elevated"
          title="GitHub"
          subtitle="Version Control"
          image-src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png"
        >
          <p class="text-gray-600">Visit GitHub for code hosting</p>
        </Card>
      </div>
    `,
  }),
}

export const WithFooter: Story = {
  render: () => ({
    components: { Card, Button },
    template: `
      <div class="max-w-md">
        <Card title="User Profile" subtitle="John Doe">
          <div class="space-y-2 text-sm text-gray-600">
            <p><strong>Email:</strong> john@example.com</p>
            <p><strong>Role:</strong> Administrator</p>
            <p><strong>Status:</strong> Active</p>
          </div>
          <template #footer>
            <div class="flex justify-end gap-2">
              <Button size="sm" variant="secondary">Edit</Button>
              <Button size="sm" variant="danger">Delete</Button>
            </div>
          </template>
        </Card>
      </div>
    `,
  }),
}

export const CustomHeader: Story = {
  render: () => ({
    components: { Card, Badge, Button },
    template: `
      <div class="max-w-md">
        <Card>
          <template #header>
            <div class="flex items-center justify-between">
              <div>
                <h3 class="text-lg font-semibold">Custom Header</h3>
                <p class="text-sm text-gray-500">With custom layout</p>
              </div>
              <Badge variant="success">Active</Badge>
            </div>
          </template>
          <p class="text-gray-600">You can fully customize the header using the header slot.</p>
          <template #footer>
            <Button size="sm" variant="primary">Action</Button>
          </template>
        </Card>
      </div>
    `,
  }),
}

export const PaddingSizes: Story = {
  render: () => ({
    components: { Card },
    template: `
      <div class="space-y-4">
        <Card padding="none" title="No Padding">
          <p class="text-gray-600">This card has no padding</p>
        </Card>

        <Card padding="sm" title="Small Padding">
          <p class="text-gray-600">This card has small padding (p-3)</p>
        </Card>

        <Card padding="md" title="Medium Padding (Default)">
          <p class="text-gray-600">This card has medium padding (p-4)</p>
        </Card>

        <Card padding="lg" title="Large Padding">
          <p class="text-gray-600">This card has large padding (p-6)</p>
        </Card>
      </div>
    `,
  }),
}

export const ProductCard: Story = {
  render: () => ({
    components: { Card, Button, Badge },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card
          hoverable
          variant="elevated"
          padding="none"
          image-src="https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400"
          image-alt="Product"
        >
          <div class="p-4">
            <div class="flex items-start justify-between mb-2">
              <h3 class="text-lg font-semibold">Premium Watch</h3>
              <Badge variant="success">New</Badge>
            </div>
            <p class="text-gray-600 text-sm mb-2">Elegant timepiece with modern design</p>
            <p class="text-2xl font-bold text-primary-600">$299</p>
          </div>
          <template #footer>
            <Button size="sm" class="w-full">Add to Cart</Button>
          </template>
        </Card>

        <Card
          hoverable
          variant="elevated"
          padding="none"
          image-src="https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400"
          image-alt="Product"
        >
          <div class="p-4">
            <div class="flex items-start justify-between mb-2">
              <h3 class="text-lg font-semibold">Sunglasses</h3>
              <Badge variant="warning">Sale</Badge>
            </div>
            <p class="text-gray-600 text-sm mb-2">Stylish UV protection sunglasses</p>
            <p class="text-2xl font-bold text-primary-600">$89</p>
          </div>
          <template #footer>
            <Button size="sm" class="w-full">Add to Cart</Button>
          </template>
        </Card>

        <Card
          hoverable
          variant="elevated"
          padding="none"
          image-src="https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400"
          image-alt="Product"
        >
          <div class="p-4">
            <div class="flex items-start justify-between mb-2">
              <h3 class="text-lg font-semibold">Camera</h3>
              <Badge variant="primary">Featured</Badge>
            </div>
            <p class="text-gray-600 text-sm mb-2">Professional DSLR camera</p>
            <p class="text-2xl font-bold text-primary-600">$1,299</p>
          </div>
          <template #footer>
            <Button size="sm" class="w-full">Add to Cart</Button>
          </template>
        </Card>
      </div>
    `,
  }),
}

export const ArticleCard: Story = {
  render: () => ({
    components: { Card, Badge },
    template: `
      <div class="max-w-2xl">
        <Card
          hoverable
          clickable
          padding="none"
          image-src="https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=800"
          image-alt="Article"
        >
          <div class="p-6">
            <div class="flex items-center gap-2 mb-3">
              <Badge variant="primary" size="sm">Technology</Badge>
              <Badge variant="secondary" size="sm">AI</Badge>
            </div>
            <h2 class="text-2xl font-bold mb-2">The Future of Artificial Intelligence</h2>
            <p class="text-gray-500 text-sm mb-4">Published on January 15, 2024 • 5 min read</p>
            <p class="text-gray-600">
              Explore how artificial intelligence is transforming industries and shaping the future
              of technology. From machine learning to neural networks, discover the latest trends...
            </p>
          </div>
          <template #footer>
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <img
                  src="https://i.pravatar.cc/40?img=1"
                  alt="Author"
                  class="w-8 h-8 rounded-full"
                />
                <span class="text-sm font-medium">John Smith</span>
              </div>
              <Button size="sm" variant="secondary">Read More</Button>
            </div>
          </template>
        </Card>
      </div>
    `,
  }),
}

export const StatsCard: Story = {
  render: () => ({
    components: { Card, Badge },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card variant="flat" hoverable>
          <div class="text-center">
            <p class="text-gray-500 text-sm mb-1">Total Users</p>
            <p class="text-3xl font-bold text-gray-900">1,234</p>
            <Badge variant="success" size="sm" class="mt-2">+12%</Badge>
          </div>
        </Card>

        <Card variant="flat" hoverable>
          <div class="text-center">
            <p class="text-gray-500 text-sm mb-1">Revenue</p>
            <p class="text-3xl font-bold text-gray-900">$45.2K</p>
            <Badge variant="success" size="sm" class="mt-2">+8%</Badge>
          </div>
        </Card>

        <Card variant="flat" hoverable>
          <div class="text-center">
            <p class="text-gray-500 text-sm mb-1">Active Sessions</p>
            <p class="text-3xl font-bold text-gray-900">892</p>
            <Badge variant="warning" size="sm" class="mt-2">-3%</Badge>
          </div>
        </Card>

        <Card variant="flat" hoverable>
          <div class="text-center">
            <p class="text-gray-500 text-sm mb-1">Conversion</p>
            <p class="text-3xl font-bold text-gray-900">3.2%</p>
            <Badge variant="success" size="sm" class="mt-2">+0.5%</Badge>
          </div>
        </Card>
      </div>
    `,
  }),
}

export const Disabled: Story = {
  render: () => ({
    components: { Card, Button },
    template: `
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card
          disabled
          clickable
          hoverable
          title="Disabled Card"
        >
          <p class="text-gray-600">This card is disabled and cannot be interacted with</p>
          <template #footer>
            <Button size="sm" disabled>Action</Button>
          </template>
        </Card>

        <Card
          disabled
          href="https://example.com"
          hoverable
          title="Disabled Link Card"
        >
          <p class="text-gray-600">This card is disabled even though it has an href</p>
        </Card>
      </div>
    `,
  }),
}

export const ComplexLayout: Story = {
  render: () => ({
    components: { Card, Button, Badge },
    template: `
      <div class="max-w-3xl">
        <Card variant="elevated" padding="none">
          <div class="relative">
            <img
              src="https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800"
              alt="Event"
              class="w-full h-48 object-cover rounded-t-lg"
            />
            <Badge variant="danger" class="absolute top-4 right-4">Live</Badge>
          </div>

          <div class="p-6">
            <div class="flex items-start justify-between mb-3">
              <div>
                <h2 class="text-2xl font-bold mb-1">Tech Conference 2024</h2>
                <p class="text-gray-500">March 15-17, 2024 • San Francisco, CA</p>
              </div>
              <Badge variant="primary">Featured</Badge>
            </div>

            <p class="text-gray-600 mb-4">
              Join industry leaders and innovators for three days of inspiring talks,
              hands-on workshops, and networking opportunities.
            </p>

            <div class="grid grid-cols-3 gap-4 mb-4">
              <div class="text-center">
                <p class="text-2xl font-bold text-primary-600">50+</p>
                <p class="text-sm text-gray-500">Speakers</p>
              </div>
              <div class="text-center">
                <p class="text-2xl font-bold text-primary-600">100+</p>
                <p class="text-sm text-gray-500">Sessions</p>
              </div>
              <div class="text-center">
                <p class="text-2xl font-bold text-primary-600">2K+</p>
                <p class="text-sm text-gray-500">Attendees</p>
              </div>
            </div>
          </div>

          <template #footer>
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm text-gray-500">Starting at</p>
                <p class="text-2xl font-bold text-gray-900">$299</p>
              </div>
              <div class="flex gap-2">
                <Button variant="secondary">Learn More</Button>
                <Button>Register Now</Button>
              </div>
            </div>
          </template>
        </Card>
      </div>
    `,
  }),
}
