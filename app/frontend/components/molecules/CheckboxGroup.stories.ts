import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import CheckboxGroup from './CheckboxGroup.vue'

const meta = {
  title: 'Molecules/CheckboxGroup',
  component: CheckboxGroup,
  tags: ['autodocs'],
} satisfies Meta<typeof CheckboxGroup>

export default meta
type Story = StoryObj<typeof meta>

const options = [
  { label: 'Option 1', value: '1' },
  { label: 'Option 2', value: '2' },
  { label: 'Option 3', value: '3' },
]

export const Default: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const selected = ref([])
      return { selected, options }
    },
    template: '<CheckboxGroup v-model="selected" :options="options" />',
  }),
}

export const WithLabel: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const selected = ref([])
      return { selected, options }
    },
    template: '<CheckboxGroup v-model="selected" :options="options" label="Select options" />',
  }),
}

export const WithDescription: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const selected = ref([])
      return { selected, options }
    },
    template:
      '<CheckboxGroup v-model="selected" :options="options" label="Preferences" description="Choose all that apply" />',
  }),
}

export const Horizontal: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const selected = ref(['1'])
      return { selected, options }
    },
    template: '<CheckboxGroup v-model="selected" :options="options" orientation="horizontal" />',
  }),
}

export const PreSelected: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const selected = ref(['1', '3'])
      return { selected, options }
    },
    template:
      '<CheckboxGroup v-model="selected" :options="options" label="Pre-selected options" />',
  }),
}

export const Disabled: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const selected = ref(['1'])
      return { selected, options }
    },
    template:
      '<CheckboxGroup v-model="selected" :options="options" label="Disabled group" disabled />',
  }),
}

export const WithDisabledOptions: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const selected = ref(['1'])
      const opts = [
        { label: 'Enabled option', value: '1' },
        { label: 'Disabled option', value: '2', disabled: true },
        { label: 'Another enabled', value: '3' },
      ]
      return { selected, opts }
    },
    template: '<CheckboxGroup v-model="selected" :options="opts" label="Mixed state" />',
  }),
}

export const Required: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const selected = ref([])
      return { selected, options }
    },
    template:
      '<CheckboxGroup v-model="selected" :options="options" label="Required field" required />',
  }),
}

export const WithError: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const selected = ref([])
      return { selected, options }
    },
    template:
      '<CheckboxGroup v-model="selected" :options="options" label="Options" error="Please select at least one option" />',
  }),
}

export const InterestsForm: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const interests = ref(['tech', 'design'])
      const interestOptions = [
        { label: 'Technology', value: 'tech' },
        { label: 'Design', value: 'design' },
        { label: 'Business', value: 'business' },
        { label: 'Marketing', value: 'marketing' },
        { label: 'Science', value: 'science' },
      ]
      return { interests, interestOptions }
    },
    template: `
      <div class="max-w-md">
        <CheckboxGroup
          v-model="interests"
          :options="interestOptions"
          label="Interests"
          description="Select all topics you're interested in"
        />
        <div v-if="interests.length" class="mt-4 p-3 bg-gray-50 rounded">
          <p class="text-sm font-medium">Selected: {{ interests.join(', ') }}</p>
        </div>
      </div>
    `,
  }),
}

export const PermissionsForm: Story = {
  render: () => ({
    components: { CheckboxGroup },
    setup() {
      const permissions = ref(['read'])
      const permOptions = [
        { label: 'Read', value: 'read' },
        { label: 'Write', value: 'write' },
        { label: 'Delete', value: 'delete' },
        { label: 'Admin', value: 'admin' },
      ]
      return { permissions, permOptions }
    },
    template: `
      <div class="max-w-md p-6 border rounded-lg">
        <CheckboxGroup
          v-model="permissions"
          :options="permOptions"
          label="User Permissions"
          description="Select the permissions for this user"
          required
        />
      </div>
    `,
  }),
}
