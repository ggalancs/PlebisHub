<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '../atoms/Icon.vue'
import Button from '../atoms/Button.vue'

export interface CalendarEvent {
  id: string | number
  title: string
  date: Date
  color?: string
  description?: string
  metadata?: Record<string, unknown>
}

export interface Props {
  events?: CalendarEvent[]
  modelValue?: Date | Date[] | null
  label?: string
  description?: string
  error?: string
  mode?: 'single' | 'range' | 'multiple'
  minDate?: Date
  maxDate?: Date
  showWeekNumbers?: boolean
  firstDayOfWeek?: 0 | 1 | 2 | 3 | 4 | 5 | 6
  disabled?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  events: () => [],
  modelValue: null,
  mode: 'single',
  showWeekNumbers: false,
  firstDayOfWeek: 0,
  disabled: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: Date | Date[] | null]
  'date-click': [date: Date]
  'event-click': [event: CalendarEvent]
}>()

const currentMonth = ref(new Date().getMonth())
const currentYear = ref(new Date().getFullYear())

const weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']

// Adjust week days based on firstDayOfWeek
const adjustedWeekDays = computed(() => {
  const days = [...weekDays]
  for (let i = 0; i < props.firstDayOfWeek; i++) {
    days.push(days.shift()!)
  }
  return days
})

// Generate calendar grid
const getDaysInMonth = (year: number, month: number): number => {
  return new Date(year, month + 1, 0).getDate()
}

const getFirstDayOfMonth = (year: number, month: number): number => {
  const day = new Date(year, month, 1).getDay()
  return (day - props.firstDayOfWeek + 7) % 7
}

const calendarDays = computed(() => {
  const daysInMonth = getDaysInMonth(currentYear.value, currentMonth.value)
  const firstDay = getFirstDayOfMonth(currentYear.value, currentMonth.value)
  const days: (number | null)[] = []

  // Previous month days
  for (let i = 0; i < firstDay; i++) {
    days.push(null)
  }

  // Current month days
  for (let day = 1; day <= daysInMonth; day++) {
    days.push(day)
  }

  return days
})

// Check if two dates are same day
const isSameDay = (date1: Date, date2: Date): boolean => {
  return (
    date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
  )
}

// Check if date is today
const isToday = (day: number): boolean => {
  const today = new Date()
  return (
    day === today.getDate() &&
    currentMonth.value === today.getMonth() &&
    currentYear.value === today.getFullYear()
  )
}

// Check if date is selected
const isSelected = (day: number): boolean => {
  const date = new Date(currentYear.value, currentMonth.value, day)

  if (props.mode === 'single' && props.modelValue instanceof Date) {
    return isSameDay(date, props.modelValue)
  } else if (Array.isArray(props.modelValue)) {
    return props.modelValue.some((d) => isSameDay(date, d))
  }

  return false
}

// Check if date is disabled
const isDisabled = (day: number): boolean => {
  const date = new Date(currentYear.value, currentMonth.value, day)

  if (props.minDate && date < props.minDate) return true
  if (props.maxDate && date > props.maxDate) return true

  return false
}

// Get events for a specific day
const getEventsForDay = (day: number): CalendarEvent[] => {
  const date = new Date(currentYear.value, currentMonth.value, day)

  return props.events.filter((event) => isSameDay(event.date, date))
}

// Navigate to previous month
const previousMonth = () => {
  if (currentMonth.value === 0) {
    currentMonth.value = 11
    currentYear.value--
  } else {
    currentMonth.value--
  }
}

// Navigate to next month
const nextMonth = () => {
  if (currentMonth.value === 11) {
    currentMonth.value = 0
    currentYear.value++
  } else {
    currentMonth.value++
  }
}

// Go to today
const goToToday = () => {
  const today = new Date()
  currentMonth.value = today.getMonth()
  currentYear.value = today.getFullYear()
}

// Handle date click
const handleDateClick = (day: number) => {
  if (isDisabled(day) || props.disabled) return

  const date = new Date(currentYear.value, currentMonth.value, day)

  if (props.mode === 'single') {
    emit('update:modelValue', date)
  } else if (props.mode === 'multiple') {
    const dates = Array.isArray(props.modelValue) ? [...props.modelValue] : []
    const index = dates.findIndex((d) => isSameDay(d, date))

    if (index > -1) {
      dates.splice(index, 1)
    } else {
      dates.push(date)
    }

    emit('update:modelValue', dates)
  }

  emit('date-click', date)
}

// Handle event click
const handleEventClick = (event: CalendarEvent, e: MouseEvent) => {
  e.stopPropagation()
  emit('event-click', event)
}

// Month name
const monthName = computed(() => {
  return new Date(currentYear.value, currentMonth.value).toLocaleString('en-US', {
    month: 'long',
  })
})
</script>

<template>
  <div class="calendar-container">
    <!-- Label -->
    <label v-if="label" class="mb-2 block text-sm font-medium text-gray-700">
      {{ label }}
    </label>

    <!-- Description -->
    <p v-if="description" class="mb-2 text-sm text-gray-500">
      {{ description }}
    </p>

    <!-- Calendar -->
    <div class="rounded-lg border border-gray-200 bg-white">
      <!-- Header -->
      <div class="flex items-center justify-between border-b border-gray-200 p-4">
        <Button
          variant="ghost"
          size="sm"
          @click="previousMonth"
          :disabled="disabled"
          aria-label="Previous month"
        >
          <Icon name="chevron-left" :size="20" />
        </Button>

        <div class="flex items-center gap-4">
          <h2 class="text-lg font-semibold text-gray-900">
            {{ monthName }} {{ currentYear }}
          </h2>

          <Button variant="outline" size="sm" @click="goToToday" :disabled="disabled">
            Today
          </Button>
        </div>

        <Button
          variant="ghost"
          size="sm"
          @click="nextMonth"
          :disabled="disabled"
          aria-label="Next month"
        >
          <Icon name="chevron-right" :size="20" />
        </Button>
      </div>

      <!-- Calendar Grid -->
      <div class="p-4">
        <!-- Week days header -->
        <div class="mb-2 grid grid-cols-7 gap-1">
          <div
            v-for="day in adjustedWeekDays"
            :key="day"
            class="text-center text-xs font-medium text-gray-500 py-2"
          >
            {{ day }}
          </div>
        </div>

        <!-- Days grid -->
        <div class="grid grid-cols-7 gap-1">
          <div
            v-for="(day, index) in calendarDays"
            :key="index"
            class="relative aspect-square min-h-[80px]"
          >
            <div
              v-if="day"
              class="h-full rounded-lg border transition-colors"
              :class="[
                isSelected(day)
                  ? 'border-primary-600 bg-primary-50'
                  : 'border-gray-200 hover:border-gray-300',
                isToday(day) ? 'border-primary-600 border-2' : '',
                isDisabled(day) || disabled
                  ? 'cursor-not-allowed bg-gray-50 text-gray-400'
                  : 'cursor-pointer bg-white',
              ]"
              @click="handleDateClick(day)"
            >
              <!-- Day number -->
              <div
                class="flex h-6 w-6 items-center justify-center rounded-full text-sm font-medium m-1"
                :class="[
                  isToday(day) ? 'bg-primary-600 text-white' : '',
                  isSelected(day) && !isToday(day) ? 'bg-primary-600 text-white' : '',
                ]"
              >
                {{ day }}
              </div>

              <!-- Events -->
              <div class="mt-1 space-y-0.5 px-1">
                <div
                  v-for="event in getEventsForDay(day).slice(0, 2)"
                  :key="event.id"
                  class="truncate rounded px-1 py-0.5 text-xs font-medium text-white"
                  :style="{ backgroundColor: event.color || '#3b82f6' }"
                  @click="handleEventClick(event, $event)"
                  :title="event.title"
                >
                  {{ event.title }}
                </div>

                <div
                  v-if="getEventsForDay(day).length > 2"
                  class="text-xs text-gray-500 px-1"
                >
                  +{{ getEventsForDay(day).length - 2 }} more
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Error Message -->
    <p v-if="error" class="mt-2 text-sm text-red-600">
      {{ error }}
    </p>
  </div>
</template>
