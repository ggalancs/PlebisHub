import type { Meta, StoryObj } from '@storybook/vue3'
import NotificationBadge from './NotificationBadge.vue'
import Button from '../atoms/Button.vue'
import Icon from '../atoms/Icon.vue'

const meta = {
  title: 'Molecules/NotificationBadge',
  component: NotificationBadge,
  tags: ['autodocs'],
} satisfies Meta<typeof NotificationBadge>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: () => ({
    components: { NotificationBadge, Button },
    template: `
      <NotificationBadge :count="5">
        <Button>Notifications</Button>
      </NotificationBadge>
    `,
  }),
}

export const WithIcon: Story = {
  render: () => ({
    components: { NotificationBadge, Icon },
    template: `
      <NotificationBadge :count="3" variant="danger">
        <Icon name="bell" :size="24" />
      </NotificationBadge>
    `,
  }),
}

export const DotVariant: Story = {
  render: () => ({
    components: { NotificationBadge, Icon },
    template: `
      <NotificationBadge :count="1" dot variant="primary">
        <Icon name="mail" :size="24" />
      </NotificationBadge>
    `,
  }),
}

export const OverMax: Story = {
  render: () => ({
    components: { NotificationBadge, Button },
    template: `
      <NotificationBadge :count="150" :max="99">
        <Button>Messages</Button>
      </NotificationBadge>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { NotificationBadge, Icon },
    template: `
      <div class="flex gap-8">
        <NotificationBadge :count="5" variant="primary">
          <Icon name="bell" :size="32" />
        </NotificationBadge>
        <NotificationBadge :count="3" variant="success">
          <Icon name="check-circle" :size="32" />
        </NotificationBadge>
        <NotificationBadge :count="7" variant="warning">
          <Icon name="alert-triangle" :size="32" />
        </NotificationBadge>
        <NotificationBadge :count="2" variant="danger">
          <Icon name="alert-circle" :size="32" />
        </NotificationBadge>
        <NotificationBadge :count="1" variant="gray">
          <Icon name="info" :size="32" />
        </NotificationBadge>
      </div>
    `,
  }),
}

export const AllPositions: Story = {
  render: () => ({
    components: { NotificationBadge },
    template: `
      <div class="flex gap-8">
        <NotificationBadge :count="1" position="top-right">
          <div class="w-16 h-16 bg-gray-200 rounded"></div>
        </NotificationBadge>
        <NotificationBadge :count="2" position="top-left">
          <div class="w-16 h-16 bg-gray-200 rounded"></div>
        </NotificationBadge>
        <NotificationBadge :count="3" position="bottom-right">
          <div class="w-16 h-16 bg-gray-200 rounded"></div>
        </NotificationBadge>
        <NotificationBadge :count="4" position="bottom-left">
          <div class="w-16 h-16 bg-gray-200 rounded"></div>
        </NotificationBadge>
      </div>
    `,
  }),
}

export const ShowZero: Story = {
  render: () => ({
    components: { NotificationBadge, Icon },
    template: `
      <NotificationBadge :count="0" show-zero>
        <Icon name="inbox" :size="32" />
      </NotificationBadge>
    `,
  }),
}
