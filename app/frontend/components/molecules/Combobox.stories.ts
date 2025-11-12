import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Combobox, { type ComboboxOption } from './Combobox.vue'

const meta = {
  title: 'Molecules/Combobox',
  component: Combobox,
  tags: ['autodocs'],
  argTypes: {
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
    disabled: {
      control: 'boolean',
    },
    required: {
      control: 'boolean',
    },
    multiple: {
      control: 'boolean',
    },
    searchable: {
      control: 'boolean',
    },
    clearable: {
      control: 'boolean',
    },
    loading: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof Combobox>

export default meta
type Story = StoryObj<typeof meta>

const simpleOptions: ComboboxOption[] = [
  { label: 'Apple', value: 'apple' },
  { label: 'Banana', value: 'banana' },
  { label: 'Cherry', value: 'cherry' },
  { label: 'Date', value: 'date' },
  { label: 'Elderberry', value: 'elderberry' },
  { label: 'Fig', value: 'fig' },
  { label: 'Grape', value: 'grape' },
]

const optionsWithDescriptions: ComboboxOption[] = [
  { label: 'JavaScript', value: 'js', description: 'Dynamic programming language' },
  { label: 'TypeScript', value: 'ts', description: 'Typed superset of JavaScript' },
  { label: 'Python', value: 'py', description: 'High-level programming language' },
  { label: 'Rust', value: 'rust', description: 'Systems programming language' },
  { label: 'Go', value: 'go', description: 'Compiled programming language' },
]

const optionsWithIcons: ComboboxOption[] = [
  { label: 'Home', value: 'home', icon: 'home' },
  { label: 'Settings', value: 'settings', icon: 'settings' },
  { label: 'Profile', value: 'profile', icon: 'user' },
  { label: 'Messages', value: 'messages', icon: 'mail' },
  { label: 'Notifications', value: 'notifications', icon: 'bell' },
]

const optionsWithDisabled: ComboboxOption[] = [
  { label: 'Active Option 1', value: '1' },
  { label: 'Disabled Option', value: '2', disabled: true },
  { label: 'Active Option 2', value: '3' },
  { label: 'Another Disabled', value: '4', disabled: true },
  { label: 'Active Option 3', value: '5' },
]

export const Default: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    placeholder: 'Select a fruit',
  },
}

export const WithLabel: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    label: 'Choose a fruit',
    description: 'Select your favorite fruit from the list',
    placeholder: 'Search fruits...',
  },
}

export const WithDescriptions: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    options: optionsWithDescriptions,
    label: 'Programming Language',
    placeholder: 'Select a language',
  },
}

export const WithIcons: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    options: optionsWithIcons,
    label: 'Navigation',
    placeholder: 'Select a page',
  },
}

export const MultipleSelection: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref([])
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected.length > 0 ? selected.join(', ') : 'None' }}</p>
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    label: 'Choose fruits',
    placeholder: 'Select multiple fruits',
    multiple: true,
  },
}

export const WithDisabledOptions: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    options: optionsWithDisabled,
    label: 'Options with some disabled',
    placeholder: 'Select an option',
  },
}

export const Required: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    label: 'Required field',
    placeholder: 'Select a fruit',
    required: true,
  },
}

export const WithError: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    label: 'Fruit selection',
    placeholder: 'Select a fruit',
    error: 'This field is required',
  },
}

export const Disabled: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref('apple')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    label: 'Disabled combobox',
    disabled: true,
  },
}

export const NotSearchable: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    label: 'Not searchable',
    placeholder: 'Select a fruit',
    searchable: false,
  },
}

export const NotClearable: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref('apple')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    label: 'Not clearable',
    clearable: false,
  },
}

export const LoadingState: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    options: [],
    label: 'Loading options',
    placeholder: 'Select an option',
    loading: true,
    loadingText: 'Fetching options...',
  },
}

export const AsyncSearch: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      const options = ref<ComboboxOption[]>([])
      const loading = ref(false)

      const handleSearch = async (query: string) => {
        loading.value = true
        // Simulate API call
        await new Promise((resolve) => setTimeout(resolve, 500))

        if (query) {
          options.value = simpleOptions.filter((opt) =>
            opt.label.toLowerCase().includes(query.toLowerCase())
          )
        } else {
          options.value = simpleOptions
        }

        loading.value = false
      }

      return { args, selected, options, loading, handleSearch }
    },
    template: `
      <div class="p-4">
        <Combobox
          v-bind="args"
          v-model="selected"
          :options="options"
          :loading="loading"
          @search="handleSearch"
        />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    label: 'Async search',
    placeholder: 'Type to search...',
  },
}

export const SmallSize: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    label: 'Small size',
    placeholder: 'Select a fruit',
    size: 'sm',
  },
}

export const LargeSize: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    label: 'Large size',
    placeholder: 'Select a fruit',
    size: 'lg',
  },
}

export const NoResults: Story = {
  render: (args) => ({
    components: { Combobox },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Combobox v-bind="args" v-model="selected" />
        <p class="mt-2 text-xs text-gray-500">Try typing something that doesn't match any option</p>
      </div>
    `,
  }),
  args: {
    options: simpleOptions,
    label: 'Search fruits',
    placeholder: 'Type to search...',
    noResultsText: 'No fruits found matching your search',
  },
}
