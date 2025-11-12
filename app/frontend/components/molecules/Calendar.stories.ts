import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Calendar, { type CalendarEvent } from './Calendar.vue'

const sampleEvents: CalendarEvent[] = [
  {
    id: '1',
    title: 'Team Meeting',
    date: new Date(new Date().getFullYear(), new Date().getMonth(), 5),
    color: '#3b82f6',
    description: 'Weekly team sync',
  },
  {
    id: '2',
    title: 'Project Deadline',
    date: new Date(new Date().getFullYear(), new Date().getMonth(), 15),
    color: '#ef4444',
    description: 'Q4 Project completion',
  },
  {
    id: '3',
    title: 'Code Review',
    date: new Date(new Date().getFullYear(), new Date().getMonth(), 8),
    color: '#10b981',
  },
  {
    id: '4',
    title: 'Client Call',
    date: new Date(new Date().getFullYear(), new Date().getMonth(), 12),
    color: '#f59e0b',
  },
  {
    id: '5',
    title: 'Workshop',
    date: new Date(new Date().getFullYear(), new Date().getMonth(), 20),
    color: '#8b5cf6',
  },
]

const meta = {
  title: 'Molecules/Calendar',
  component: Calendar,
  tags: ['autodocs'],
  argTypes: {
    mode: {
      control: 'select',
      options: ['single', 'range', 'multiple'],
    },
    disabled: {
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
} satisfies Meta<typeof Calendar>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: (args) => ({
    components: { Calendar },
    setup() {
      return { args }
    },
    template: `
      <div class="p-4">
        <Calendar v-bind="args" />
      </div>
    `,
  }),
  args: {
    events: [],
  },
}

export const WithLabel: Story = {
  render: (args) => ({
    components: { Calendar },
    setup() {
      return { args }
    },
    template: `
      <div class="p-4">
        <Calendar v-bind="args" />
      </div>
    `,
  }),
  args: {
    label: 'Project Calendar',
    description: 'View team events and deadlines',
    events: [],
  },
}

export const WithEvents: Story = {
  render: (args) => ({
    components: { Calendar },
    setup() {
      const handleEventClick = (event: CalendarEvent) => {
        alert(`Event: ${event.title}\n${event.description || 'No description'}`)
      }
      return { args, sampleEvents, handleEventClick }
    },
    template: `
      <div class="p-4">
        <Calendar v-bind="args" :events="sampleEvents" @event-click="handleEventClick" />
        <p class="mt-4 text-sm text-gray-600">Click on events to see details</p>
      </div>
    `,
  }),
  args: {
    label: 'Event Calendar',
  },
}

export const WithDateSelection: Story = {
  render: (args) => ({
    components: { Calendar },
    setup() {
      const selected = ref(null)
      const handleDateClick = (date: Date) => {
        console.log('Date clicked:', date)
      }
      return { args, selected, handleDateClick }
    },
    template: `
      <div class="p-4">
        <Calendar v-bind="args" v-model="selected" @date-click="handleDateClick" />
        <p class="mt-4 text-sm text-gray-600">
          Selected: {{ selected ? selected.toLocaleDateString() : 'None' }}
        </p>
      </div>
    `,
  }),
  args: {
    label: 'Select a Date',
    mode: 'single',
    events: [],
  },
}

export const MultipleSelection: Story = {
  render: (args) => ({
    components: { Calendar },
    setup() {
      const selected = ref([])
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <Calendar v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">
          Selected {{ selected.length }} dates
        </p>
      </div>
    `,
  }),
  args: {
    label: 'Select Multiple Dates',
    mode: 'multiple',
    events: [],
  },
}

export const WithConstraints: Story = {
  render: (args) => ({
    components: { Calendar },
    setup() {
      const today = new Date()
      const minDate = new Date(today.getFullYear(), today.getMonth(), 1)
      const maxDate = new Date(today.getFullYear(), today.getMonth() + 1, 0)
      return { args, minDate, maxDate }
    },
    template: `
      <div class="p-4">
        <Calendar v-bind="args" :minDate="minDate" :maxDate="maxDate" />
        <p class="mt-2 text-xs text-gray-500">Only dates in current month are selectable</p>
      </div>
    `,
  }),
  args: {
    label: 'Limited Date Range',
    events: [],
  },
}

export const MondayFirst: Story = {
  render: (args) => ({
    components: { Calendar },
    setup() {
      return { args, sampleEvents }
    },
    template: `
      <div class="p-4">
        <Calendar v-bind="args" :events="sampleEvents" />
        <p class="mt-2 text-xs text-gray-500">Week starts on Monday</p>
      </div>
    `,
  }),
  args: {
    label: 'Monday Start',
    firstDayOfWeek: 1,
  },
}

export const Disabled: Story = {
  render: (args) => ({
    components: { Calendar },
    setup() {
      return { args, sampleEvents }
    },
    template: `
      <div class="p-4">
        <Calendar v-bind="args" :events="sampleEvents" />
      </div>
    `,
  }),
  args: {
    label: 'Disabled Calendar',
    disabled: true,
  },
}

export const ManyEvents: Story = {
  render: (args) => ({
    components: { Calendar },
    setup() {
      const today = new Date()
      const manyEvents: CalendarEvent[] = [
        { id: '1', title: 'Morning Meeting', date: new Date(today.getFullYear(), today.getMonth(), 10), color: '#3b82f6' },
        { id: '2', title: 'Lunch with Team', date: new Date(today.getFullYear(), today.getMonth(), 10), color: '#10b981' },
        { id: '3', title: 'Code Review', date: new Date(today.getFullYear(), today.getMonth(), 10), color: '#f59e0b' },
        { id: '4', title: 'Project Sync', date: new Date(today.getFullYear(), today.getMonth(), 10), color: '#8b5cf6' },
      ]
      return { args, manyEvents }
    },
    template: `
      <div class="p-4">
        <Calendar v-bind="args" :events="manyEvents" />
        <p class="mt-2 text-xs text-gray-500">Day with multiple events shows "+N more" indicator</p>
      </div>
    `,
  }),
  args: {
    label: 'Busy Day',
  },
}

export const ProjectPlanner: Story = {
  render: (args) => ({
    components: { Calendar },
    setup() {
      const today = new Date()
      const selected = ref([])
      const events: CalendarEvent[] = [
        {
          id: '1',
          title: 'Sprint Planning',
          date: new Date(today.getFullYear(), today.getMonth(), 1),
          color: '#3b82f6',
        },
        {
          id: '2',
          title: 'Sprint Review',
          date: new Date(today.getFullYear(), today.getMonth(), 14),
          color: '#10b981',
        },
        {
          id: '3',
          title: 'Sprint Retrospective',
          date: new Date(today.getFullYear(), today.getMonth(), 15),
          color: '#f59e0b',
        },
        {
          id: '4',
          title: 'Release',
          date: new Date(today.getFullYear(), today.getMonth(), 28),
          color: '#ef4444',
        },
      ]

      const handleEventClick = (event: CalendarEvent) => {
        alert(`${event.title}\n\nClick OK to continue`)
      }

      return { args, events, selected, handleEventClick }
    },
    template: `
      <div class="p-4">
        <div class="mb-4">
          <h3 class="text-lg font-semibold">Project Timeline</h3>
          <p class="text-sm text-gray-600">Sprint cycle events and milestones</p>
        </div>

        <Calendar
          v-bind="args"
          :events="events"
          v-model="selected"
          @event-click="handleEventClick"
        />

        <div class="mt-4 flex gap-4 text-sm">
          <div class="flex items-center gap-2">
            <div class="h-3 w-3 rounded" style="background-color: #3b82f6"></div>
            <span>Planning</span>
          </div>
          <div class="flex items-center gap-2">
            <div class="h-3 w-3 rounded" style="background-color: #10b981"></div>
            <span>Review</span>
          </div>
          <div class="flex items-center gap-2">
            <div class="h-3 w-3 rounded" style="background-color: #f59e0b"></div>
            <span>Retrospective</span>
          </div>
          <div class="flex items-center gap-2">
            <div class="h-3 w-3 rounded" style="background-color: #ef4444"></div>
            <span>Release</span>
          </div>
        </div>
      </div>
    `,
  }),
  args: {
    mode: 'multiple',
  },
}
