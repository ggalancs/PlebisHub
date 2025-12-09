import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Tag from './Tag.vue'

const meta = {
  title: 'Molecules/Tag',
  component: Tag,
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: 'select',
      options: ['default', 'primary', 'success', 'warning', 'danger', 'info'],
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
    removable: {
      control: 'boolean',
    },
    clickable: {
      control: 'boolean',
    },
    disabled: {
      control: 'boolean',
    },
    outlined: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof Tag>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    label: 'Default Tag',
  },
}

export const Primary: Story = {
  args: {
    label: 'Primary Tag',
    variant: 'primary',
  },
}

export const Success: Story = {
  args: {
    label: 'Success Tag',
    variant: 'success',
  },
}

export const Removable: Story = {
  args: {
    label: 'Removable Tag',
    variant: 'primary',
    removable: true,
  },
}

export const Clickable: Story = {
  args: {
    label: 'Clickable Tag',
    variant: 'info',
    clickable: true,
  },
}

export const WithIcon: Story = {
  args: {
    label: 'Star Tag',
    variant: 'warning',
    icon: 'star',
  },
}

export const WithAvatar: Story = {
  args: {
    label: 'John Doe',
    variant: 'default',
    avatar: 'https://i.pravatar.cc/40?img=1',
  },
}

export const Outlined: Story = {
  args: {
    label: 'Outlined Tag',
    variant: 'primary',
    outlined: true,
  },
}

export const Disabled: Story = {
  args: {
    label: 'Disabled Tag',
    variant: 'primary',
    disabled: true,
    removable: true,
  },
}

export const AllVariants: Story = {
  render: () => ({
    components: { Tag },
    template: `
      <div class="space-y-4">
        <div class="flex flex-wrap gap-2">
          <Tag label="Default" variant="default" />
          <Tag label="Primary" variant="primary" />
          <Tag label="Success" variant="success" />
          <Tag label="Warning" variant="warning" />
          <Tag label="Danger" variant="danger" />
          <Tag label="Info" variant="info" />
        </div>

        <div class="flex flex-wrap gap-2">
          <Tag label="Default Outlined" variant="default" outlined />
          <Tag label="Primary Outlined" variant="primary" outlined />
          <Tag label="Success Outlined" variant="success" outlined />
          <Tag label="Warning Outlined" variant="warning" outlined />
          <Tag label="Danger Outlined" variant="danger" outlined />
          <Tag label="Info Outlined" variant="info" outlined />
        </div>
      </div>
    `,
  }),
}

export const AllSizes: Story = {
  render: () => ({
    components: { Tag },
    template: `
      <div class="flex items-center gap-4">
        <Tag label="Small" size="sm" variant="primary" />
        <Tag label="Medium" size="md" variant="primary" />
        <Tag label="Large" size="lg" variant="primary" />
      </div>
    `,
  }),
}

export const WithIcons: Story = {
  render: () => ({
    components: { Tag },
    template: `
      <div class="flex flex-wrap gap-2">
        <Tag label="Home" icon="home" variant="default" />
        <Tag label="Settings" icon="settings" variant="primary" />
        <Tag label="Favorite" icon="heart" variant="danger" />
        <Tag label="Archive" icon="archive" variant="info" />
        <Tag label="Alert" icon="alert-triangle" variant="warning" />
        <Tag label="Check" icon="check" variant="success" />
      </div>
    `,
  }),
}

export const InteractiveRemovable: Story = {
  render: () => ({
    components: { Tag },
    setup() {
      const tags = ref([
        { id: 1, label: 'Vue.js', variant: 'primary' as const },
        { id: 2, label: 'TypeScript', variant: 'info' as const },
        { id: 3, label: 'Tailwind CSS', variant: 'success' as const },
        { id: 4, label: 'Vite', variant: 'warning' as const },
      ])

      const removeTag = (id: number) => {
        tags.value = tags.value.filter((tag) => tag.id !== id)
      }

      return { tags, removeTag }
    },
    template: `
      <div class="space-y-4">
        <div class="flex flex-wrap gap-2">
          <Tag
            v-for="tag in tags"
            :key="tag.id"
            :label="tag.label"
            :variant="tag.variant"
            removable
            @remove="removeTag(tag.id)"
          />
        </div>
        <p class="text-sm text-gray-600">Click the X to remove tags</p>
      </div>
    `,
  }),
}

export const UserTags: Story = {
  render: () => ({
    components: { Tag },
    template: `
      <div class="flex flex-wrap gap-2">
        <Tag
          label="Alice Johnson"
          avatar="https://i.pravatar.cc/40?img=1"
          removable
        />
        <Tag
          label="Bob Smith"
          avatar="https://i.pravatar.cc/40?img=2"
          removable
        />
        <Tag
          label="Carol White"
          avatar="https://i.pravatar.cc/40?img=3"
          removable
        />
        <Tag
          label="David Brown"
          avatar="https://i.pravatar.cc/40?img=4"
          removable
        />
      </div>
    `,
  }),
}

export const CategoryTags: Story = {
  render: () => ({
    components: { Tag },
    setup() {
      const selectedCategories = ref<string[]>([])

      const categories = [
        'Technology',
        'Design',
        'Business',
        'Marketing',
        'Development',
        'AI & ML',
        'Blockchain',
        'Cloud',
      ]

      const toggleCategory = (category: string) => {
        const index = selectedCategories.value.indexOf(category)
        if (index > -1) {
          selectedCategories.value.splice(index, 1)
        } else {
          selectedCategories.value.push(category)
        }
      }

      const isSelected = (category: string) => {
        return selectedCategories.value.includes(category)
      }

      return { categories, toggleCategory, isSelected, selectedCategories }
    },
    template: `
      <div class="space-y-4">
        <div class="flex flex-wrap gap-2">
          <Tag
            v-for="category in categories"
            :key="category"
            :label="category"
            :variant="isSelected(category) ? 'primary' : 'default'"
            :outlined="!isSelected(category)"
            clickable
            @click="toggleCategory(category)"
          />
        </div>
        <div v-if="selectedCategories.length > 0" class="text-sm text-gray-600">
          Selected: {{ selectedCategories.join(', ') }}
        </div>
      </div>
    `,
  }),
}

export const StatusTags: Story = {
  render: () => ({
    components: { Tag },
    template: `
      <div class="space-y-3">
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600 w-24">Draft:</span>
          <Tag label="Draft" variant="default" icon="file-text" />
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600 w-24">In Review:</span>
          <Tag label="In Review" variant="warning" icon="clock" />
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600 w-24">Approved:</span>
          <Tag label="Approved" variant="success" icon="check-circle" />
        </div>
        <div class="flex items-center gap-2">
          <span class="text-sm text-gray-600 w-24">Rejected:</span>
          <Tag label="Rejected" variant="danger" icon="x-circle" />
        </div>
      </div>
    `,
  }),
}
