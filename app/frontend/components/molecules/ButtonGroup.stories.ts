import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ButtonGroup from './ButtonGroup.vue'

const meta = {
  title: 'Molecules/ButtonGroup',
  component: ButtonGroup,
  tags: ['autodocs'],
} satisfies Meta<typeof ButtonGroup>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    buttons: [
      { id: 1, label: 'Left' },
      { id: 2, label: 'Center' },
      { id: 3, label: 'Right' },
    ],
  },
}

export const WithIcons: Story = {
  args: {
    buttons: [
      { id: 1, label: 'Left', icon: 'align-left' },
      { id: 2, label: 'Center', icon: 'align-center' },
      { id: 3, label: 'Right', icon: 'align-right' },
    ],
  },
}

export const IconsOnly: Story = {
  args: {
    buttons: [
      { id: 1, icon: 'bold' },
      { id: 2, icon: 'italic' },
      { id: 3, icon: 'underline' },
    ],
    ariaLabel: 'Text formatting',
  },
}

export const WithActive: Story = {
  render: () => ({
    components: { ButtonGroup },
    setup() {
      const activeIndex = ref(1)

      const buttons = ref([
        { id: 1, label: 'Day', active: false },
        { id: 2, label: 'Week', active: true },
        { id: 3, label: 'Month', active: false },
      ])

      const handleClick = (_button: unknown, index: number) => {
        activeIndex.value = index
        buttons.value = buttons.value.map((btn, i) => ({
          ...btn,
          active: i === index,
        }))
      }

      return { buttons, handleClick }
    },
    template: `
      <ButtonGroup :buttons="buttons" @click="handleClick" />
    `,
  }),
}

export const Outlined: Story = {
  args: {
    buttons: [
      { id: 1, label: 'Option 1' },
      { id: 2, label: 'Option 2', active: true },
      { id: 3, label: 'Option 3' },
    ],
    variant: 'outlined',
  },
}

export const Ghost: Story = {
  args: {
    buttons: [
      { id: 1, label: 'Files', icon: 'file' },
      { id: 2, label: 'Photos', icon: 'image', active: true },
      { id: 3, label: 'Videos', icon: 'video' },
    ],
    variant: 'ghost',
  },
}

export const SmallSize: Story = {
  args: {
    buttons: [
      { id: 1, icon: 'chevron-left' },
      { id: 2, label: '1 / 10' },
      { id: 3, icon: 'chevron-right' },
    ],
    size: 'sm',
  },
}

export const LargeSize: Story = {
  args: {
    buttons: [
      { id: 1, label: 'Previous', icon: 'arrow-left' },
      { id: 2, label: 'Next', icon: 'arrow-right' },
    ],
    size: 'lg',
  },
}

export const Vertical: Story = {
  args: {
    buttons: [
      { id: 1, label: 'Dashboard', icon: 'home' },
      { id: 2, label: 'Profile', icon: 'user', active: true },
      { id: 3, label: 'Settings', icon: 'settings' },
      { id: 4, label: 'Logout', icon: 'log-out' },
    ],
    orientation: 'vertical',
  },
}

export const Disabled: Story = {
  args: {
    buttons: [
      { id: 1, label: 'Save' },
      { id: 2, label: 'Cancel' },
      { id: 3, label: 'Delete' },
    ],
    disabled: true,
  },
}

export const IndividualDisabled: Story = {
  args: {
    buttons: [
      { id: 1, label: 'Edit' },
      { id: 2, label: 'Delete', disabled: true },
      { id: 3, label: 'Share' },
    ],
  },
}

export const AsLinks: Story = {
  args: {
    buttons: [
      { id: 1, label: 'Home', icon: 'home', href: '/' },
      { id: 2, label: 'About', icon: 'info', href: '/about', active: true },
      { id: 3, label: 'Contact', icon: 'mail', href: '/contact' },
    ],
  },
}

export const TextAlignment: Story = {
  render: () => ({
    components: { ButtonGroup },
    setup() {
      const buttons = ref([
        { id: 1, icon: 'align-left', active: false },
        { id: 2, icon: 'align-center', active: true },
        { id: 3, icon: 'align-right', active: false },
        { id: 4, icon: 'align-justify', active: false },
      ])

      const handleClick = (_button: unknown, index: number) => {
        buttons.value = buttons.value.map((btn, i) => ({
          ...btn,
          active: i === index,
        }))
      }

      return { buttons, handleClick }
    },
    template: `
      <div class="space-y-4">
        <ButtonGroup
          :buttons="buttons"
          @click="handleClick"
          aria-label="Text alignment"
        />
      </div>
    `,
  }),
}

export const ZoomControls: Story = {
  render: () => ({
    components: { ButtonGroup },
    template: `
      <ButtonGroup
        :buttons="[
          { id: 1, icon: 'zoom-out' },
          { id: 2, label: '100%' },
          { id: 3, icon: 'zoom-in' },
        ]"
        size="sm"
        variant="outlined"
        aria-label="Zoom controls"
      />
    `,
  }),
}

export const Pagination: Story = {
  render: () => ({
    components: { ButtonGroup },
    setup() {
      const currentPage = ref(1)

      const buttons = ref([
        { id: 1, icon: 'chevron-left' },
        { id: 2, label: '1', active: true },
        { id: 3, label: '2', active: false },
        { id: 4, label: '3', active: false },
        { id: 5, label: '4', active: false },
        { id: 6, label: '5', active: false },
        { id: 7, icon: 'chevron-right' },
      ])

      const handleClick = (_button: unknown, index: number) => {
        if (index === 0) {
          // Previous
          if (currentPage.value > 1) currentPage.value--
        } else if (index === buttons.value.length - 1) {
          // Next
          if (currentPage.value < 5) currentPage.value++
        } else {
          currentPage.value = index
        }

        buttons.value = buttons.value.map((btn, i) => ({
          ...btn,
          active: i === currentPage.value,
        }))
      }

      return { buttons, handleClick }
    },
    template: `
      <ButtonGroup :buttons="buttons" @click="handleClick" size="sm" />
    `,
  }),
}

export const MediaControls: Story = {
  render: () => ({
    components: { ButtonGroup },
    template: `
      <div class="space-y-4">
        <ButtonGroup
          :buttons="[
            { id: 1, icon: 'skip-back' },
            { id: 2, icon: 'play' },
            { id: 3, icon: 'pause' },
            { id: 4, icon: 'skip-forward' },
          ]"
          variant="outlined"
          aria-label="Media controls"
        />
      </div>
    `,
  }),
}

export const ViewToggle: Story = {
  render: () => ({
    components: { ButtonGroup },
    setup() {
      const buttons = ref([
        { id: 1, icon: 'list', active: true },
        { id: 2, icon: 'grid', active: false },
      ])

      const handleClick = (_button: unknown, index: number) => {
        buttons.value = buttons.value.map((btn, i) => ({
          ...btn,
          active: i === index,
        }))
      }

      return { buttons, handleClick }
    },
    template: `
      <ButtonGroup
        :buttons="buttons"
        @click="handleClick"
        variant="outlined"
        aria-label="View mode"
      />
    `,
  }),
}

export const FilterGroup: Story = {
  render: () => ({
    components: { ButtonGroup },
    setup() {
      const buttons = ref([
        { id: 1, label: 'All', active: true },
        { id: 2, label: 'Active', active: false },
        { id: 3, label: 'Completed', active: false },
      ])

      const handleClick = (_button: unknown, index: number) => {
        buttons.value = buttons.value.map((btn, i) => ({
          ...btn,
          active: i === index,
        }))
      }

      return { buttons, handleClick }
    },
    template: `
      <div class="space-y-4">
        <h3 class="text-sm font-semibold">Filter by status:</h3>
        <ButtonGroup
          :buttons="buttons"
          @click="handleClick"
          variant="ghost"
        />
      </div>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { ButtonGroup },
    template: `
      <div class="space-y-6">
        <div>
          <p class="text-sm text-gray-600 mb-2">Default</p>
          <ButtonGroup
            :buttons="[
              { id: 1, label: 'One' },
              { id: 2, label: 'Two', active: true },
              { id: 3, label: 'Three' },
            ]"
          />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Outlined</p>
          <ButtonGroup
            :buttons="[
              { id: 1, label: 'One' },
              { id: 2, label: 'Two', active: true },
              { id: 3, label: 'Three' },
            ]"
            variant="outlined"
          />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Ghost</p>
          <ButtonGroup
            :buttons="[
              { id: 1, label: 'One' },
              { id: 2, label: 'Two', active: true },
              { id: 3, label: 'Three' },
            ]"
            variant="ghost"
          />
        </div>
      </div>
    `,
  }),
}

export const AllSizes: Story = {
  render: () => ({
    components: { ButtonGroup },
    template: `
      <div class="space-y-6">
        <div>
          <p class="text-sm text-gray-600 mb-2">Small</p>
          <ButtonGroup
            :buttons="[
              { id: 1, label: 'One' },
              { id: 2, label: 'Two' },
              { id: 3, label: 'Three' },
            ]"
            size="sm"
          />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Medium</p>
          <ButtonGroup
            :buttons="[
              { id: 1, label: 'One' },
              { id: 2, label: 'Two' },
              { id: 3, label: 'Three' },
            ]"
            size="md"
          />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Large</p>
          <ButtonGroup
            :buttons="[
              { id: 1, label: 'One' },
              { id: 2, label: 'Two' },
              { id: 3, label: 'Three' },
            ]"
            size="lg"
          />
        </div>
      </div>
    `,
  }),
}
