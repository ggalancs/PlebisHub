import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import DatePicker from './DatePicker.vue'

const meta = {
  title: 'Molecules/DatePicker',
  component: DatePicker,
  tags: ['autodocs'],
  argTypes: {
    mode: {
      control: 'select',
      options: ['single', 'range', 'multiple'],
    },
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
    showWeekNumbers: {
      control: 'boolean',
    },
    firstDayOfWeek: {
      control: 'select',
      options: [0, 1, 2, 3, 4, 5, 6],
    },
  },
} satisfies Meta<typeof DatePicker>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">
          Selected: {{ selected ? selected.toLocaleDateString() : 'None' }}
        </p>
      </div>
    `,
  }),
  args: {
    placeholder: 'Select a date',
  },
}

export const WithLabel: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Birth Date',
    description: 'Select your date of birth',
    placeholder: 'Choose a date',
  },
}

export const RangeMode: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      const formatDate = (date: Date) => date.toLocaleDateString()
      return { args, selected, formatDate }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">
          Selected: {{ selected && Array.isArray(selected) && selected.length === 2
            ? formatDate(selected[0]) + ' - ' + formatDate(selected[1])
            : 'None' }}
        </p>
      </div>
    `,
  }),
  args: {
    mode: 'range',
    label: 'Date Range',
    placeholder: 'Select date range',
  },
}

export const MultipleMode: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref([])
      const formatDates = (dates: Date[]) => {
        return dates.map((d) => d.toLocaleDateString()).join(', ')
      }
      return { args, selected, formatDates }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">
          Selected: {{ selected.length > 0 ? formatDates(selected) : 'None' }}
        </p>
      </div>
    `,
  }),
  args: {
    mode: 'multiple',
    label: 'Multiple Dates',
    placeholder: 'Select multiple dates',
  },
}

export const WithMinDate: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      const minDate = new Date()
      return { args, selected, minDate }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" :minDate="minDate" />
        <p class="mt-2 text-xs text-gray-500">Only future dates can be selected</p>
      </div>
    `,
  }),
  args: {
    label: 'Appointment Date',
    placeholder: 'Select future date',
  },
}

export const WithMaxDate: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      const maxDate = new Date()
      return { args, selected, maxDate }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" :maxDate="maxDate" />
        <p class="mt-2 text-xs text-gray-500">Only past dates can be selected</p>
      </div>
    `,
  }),
  args: {
    label: 'Birth Date',
    placeholder: 'Select past date',
  },
}

export const WithDateRange: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      const today = new Date()
      const minDate = new Date(today.getFullYear(), today.getMonth(), 1)
      const maxDate = new Date(today.getFullYear(), today.getMonth() + 1, 0)
      return { args, selected, minDate, maxDate }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" :minDate="minDate" :maxDate="maxDate" />
        <p class="mt-2 text-xs text-gray-500">Only dates in current month can be selected</p>
      </div>
    `,
  }),
  args: {
    label: 'This Month',
    placeholder: 'Select date in current month',
  },
}

export const WithDisabledDates: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      const today = new Date()
      const disabledDates = [
        new Date(today.getFullYear(), today.getMonth(), 15),
        new Date(today.getFullYear(), today.getMonth(), 20),
        new Date(today.getFullYear(), today.getMonth(), 25),
      ]
      return { args, selected, disabledDates }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" :disabledDates="disabledDates" />
        <p class="mt-2 text-xs text-gray-500">Dates 15th, 20th, and 25th are disabled</p>
      </div>
    `,
  }),
  args: {
    label: 'Available Dates',
    placeholder: 'Select available date',
  },
}

export const Required: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Required Date',
    placeholder: 'Select a date',
    required: true,
  },
}

export const WithError: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Date',
    placeholder: 'Select a date',
    error: 'This field is required',
  },
}

export const Disabled: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(new Date())
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Disabled Date Picker',
    disabled: true,
  },
}

export const SmallSize: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Small Date Picker',
    placeholder: 'Select a date',
    size: 'sm',
  },
}

export const LargeSize: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Large Date Picker',
    placeholder: 'Select a date',
    size: 'lg',
  },
}

export const MondayFirstDay: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
        <p class="mt-2 text-xs text-gray-500">Week starts on Monday</p>
      </div>
    `,
  }),
  args: {
    label: 'Date',
    placeholder: 'Select a date',
    firstDayOfWeek: 1,
  },
}

export const PreselectedDate: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const selected = ref(new Date())
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">
          Selected: {{ selected.toLocaleDateString() }}
        </p>
      </div>
    `,
  }),
  args: {
    label: 'Date',
    placeholder: 'Select a date',
  },
}

export const PreselectedRange: Story = {
  render: (args) => ({
    components: { DatePicker },
    setup() {
      const today = new Date()
      const nextWeek = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)
      const selected = ref([today, nextWeek])
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <DatePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    mode: 'range',
    label: 'Date Range',
    placeholder: 'Select date range',
  },
}
