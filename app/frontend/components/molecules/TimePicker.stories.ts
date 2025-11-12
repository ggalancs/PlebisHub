import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import TimePicker from './TimePicker.vue'

const meta = {
  title: 'Molecules/TimePicker',
  component: TimePicker,
  tags: ['autodocs'],
  argTypes: {
    format: {
      control: 'select',
      options: ['12h', '24h'],
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
    showSeconds: {
      control: 'boolean',
    },
    minuteStep: {
      control: 'number',
    },
    secondStep: {
      control: 'number',
    },
  },
} satisfies Meta<typeof TimePicker>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    placeholder: 'Select a time',
  },
}

export const WithLabel: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Appointment Time',
    description: 'Select your preferred appointment time',
    placeholder: 'Choose a time',
  },
}

export const Format12Hour: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    format: '12h',
    label: '12-Hour Format',
    placeholder: 'Select time (12h)',
  },
}

export const Format24Hour: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    format: '24h',
    label: '24-Hour Format',
    placeholder: 'Select time (24h)',
  },
}

export const WithSeconds: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    format: '24h',
    showSeconds: true,
    label: 'Time with Seconds',
    placeholder: 'Select time',
  },
}

export const MinuteStep15: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-2 text-xs text-gray-500">Minutes are in 15-minute increments</p>
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    format: '12h',
    minuteStep: 15,
    label: '15-Minute Intervals',
    placeholder: 'Select time',
  },
}

export const MinuteStep30: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-2 text-xs text-gray-500">Minutes are in 30-minute increments</p>
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    format: '24h',
    minuteStep: 30,
    label: '30-Minute Intervals',
    placeholder: 'Select time',
  },
}

export const SecondStep10: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-2 text-xs text-gray-500">Seconds are in 10-second increments</p>
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    format: '24h',
    showSeconds: true,
    secondStep: 10,
    label: '10-Second Intervals',
    placeholder: 'Select time',
  },
}

export const Required: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Required Time',
    placeholder: 'Select a time',
    required: true,
  },
}

export const WithError: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Time',
    placeholder: 'Select a time',
    error: 'This field is required',
  },
}

export const Disabled: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref('14:30')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Disabled Time Picker',
    disabled: true,
    format: '24h',
  },
}

export const SmallSize: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Small Time Picker',
    placeholder: 'Select a time',
    size: 'sm',
  },
}

export const LargeSize: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Large Time Picker',
    placeholder: 'Select a time',
    size: 'lg',
  },
}

export const PreselectedTime12h: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref('02:30 PM')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected }}</p>
      </div>
    `,
  }),
  args: {
    format: '12h',
    label: 'Preselected Time',
    placeholder: 'Select time',
  },
}

export const PreselectedTime24h: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref('14:30')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected }}</p>
      </div>
    `,
  }),
  args: {
    format: '24h',
    label: 'Preselected Time',
    placeholder: 'Select time',
  },
}

export const WithSecondsPreselected: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref('14:30:45')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected }}</p>
      </div>
    `,
  }),
  args: {
    format: '24h',
    showSeconds: true,
    label: 'Preselected Time with Seconds',
  },
}

export const MorningTime: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref('09:00 AM')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected }}</p>
      </div>
    `,
  }),
  args: {
    format: '12h',
    label: 'Morning Meeting',
    description: 'Select your morning meeting time',
  },
}

export const EveningTime: Story = {
  render: (args) => ({
    components: { TimePicker },
    setup() {
      const selected = ref('06:30 PM')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <TimePicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected }}</p>
      </div>
    `,
  }),
  args: {
    format: '12h',
    label: 'Evening Event',
    description: 'Select your evening event time',
  },
}
