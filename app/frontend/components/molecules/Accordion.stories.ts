import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import Accordion from './Accordion.vue'
import type { AccordionItem } from './Accordion.vue'

const meta = {
  title: 'Molecules/Accordion',
  component: Accordion,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['default', 'bordered', 'separated'],
    },
    multiple: {
      control: 'boolean',
    },
    disabled: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof Accordion>

export default meta
type Story = StoryObj<typeof meta>

const sampleItems: AccordionItem[] = [
  {
    id: 1,
    title: 'What is PlebisHub?',
    content:
      'PlebisHub is a decentralized social platform built on blockchain technology, enabling users to connect, share, and engage in a censorship-resistant environment.',
  },
  {
    id: 2,
    title: 'How do I get started?',
    content:
      'Getting started is easy! Simply create an account, set up your profile, and start exploring the community. You can follow other users, create posts, and participate in discussions.',
  },
  {
    id: 3,
    title: 'Is my data secure?',
    content:
      'Yes, your data is secured using end-to-end encryption and distributed across the blockchain network. You have full control over your information and can choose what to share.',
  },
  {
    id: 4,
    title: 'What are the platform fees?',
    content:
      'Basic features are free to use. Premium features and certain transactions may require minimal fees to cover blockchain gas costs.',
  },
]

export const Default: Story = {
  args: {
    items: sampleItems,
  },
}

export const Bordered: Story = {
  args: {
    items: sampleItems,
    variant: 'bordered',
  },
}

export const Separated: Story = {
  args: {
    items: sampleItems,
    variant: 'separated',
  },
}

export const MultipleOpen: Story = {
  args: {
    items: sampleItems,
    multiple: true,
    modelValue: [1, 2],
  },
}

export const Disabled: Story = {
  args: {
    items: sampleItems,
    disabled: true,
  },
}

export const IndividuallyDisabled: Story = {
  args: {
    items: [
      { id: 1, title: 'Active Item', content: 'This item can be opened.' },
      { id: 2, title: 'Disabled Item', content: 'This item is disabled.', disabled: true },
      { id: 3, title: 'Another Active Item', content: 'This item can also be opened.' },
    ],
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { Accordion },
    setup() {
      const openItems = ref<(string | number)[]>([])
      const items = sampleItems
      return { openItems, items }
    },
    template: `
      <div class="space-y-4">
        <div class="text-sm text-gray-600">
          Open items: {{ openItems.length > 0 ? openItems.join(', ') : 'None' }}
        </div>
        <Accordion
          v-model="openItems"
          :items="items"
          multiple
        />
      </div>
    `,
  }),
}

export const CustomContent: Story = {
  render: () => ({
    components: { Accordion },
    setup() {
      const items: AccordionItem[] = [
        { id: 1, title: 'Features' },
        { id: 2, title: 'Pricing' },
        { id: 3, title: 'Support' },
      ]
      return { items }
    },
    template: `
      <Accordion :items="items">
        <template #content="{ item }">
          <div v-if="item.id === 1">
            <ul class="list-disc list-inside space-y-1">
              <li>Decentralized architecture</li>
              <li>End-to-end encryption</li>
              <li>No censorship</li>
              <li>Community governance</li>
            </ul>
          </div>
          <div v-else-if="item.id === 2">
            <div class="space-y-2">
              <div class="flex justify-between">
                <span class="font-medium">Basic</span>
                <span class="text-primary">Free</span>
              </div>
              <div class="flex justify-between">
                <span class="font-medium">Premium</span>
                <span class="text-primary">$9.99/mo</span>
              </div>
            </div>
          </div>
          <div v-else>
            <p>Contact us at <a href="mailto:support@plebishub.com" class="text-primary hover:underline">support@plebishub.com</a></p>
          </div>
        </template>
      </Accordion>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { Accordion },
    setup() {
      const items: AccordionItem[] = [
        { id: 1, title: 'First Item', content: 'Content for the first item.' },
        { id: 2, title: 'Second Item', content: 'Content for the second item.' },
        { id: 3, title: 'Third Item', content: 'Content for the third item.' },
      ]
      return { items }
    },
    template: `
      <div class="space-y-8">
        <div>
          <h3 class="text-lg font-semibold mb-2">Default</h3>
          <Accordion :items="items" variant="default" />
        </div>
        <div>
          <h3 class="text-lg font-semibold mb-2">Bordered</h3>
          <Accordion :items="items" variant="bordered" />
        </div>
        <div>
          <h3 class="text-lg font-semibold mb-2">Separated</h3>
          <Accordion :items="items" variant="separated" />
        </div>
      </div>
    `,
  }),
}
