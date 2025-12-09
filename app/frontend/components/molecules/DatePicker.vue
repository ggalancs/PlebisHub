<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import Icon from '../atoms/Icon.vue'
import Button from '../atoms/Button.vue'

export interface Props {
  modelValue: Date | Date[] | null
  label?: string
  description?: string
  placeholder?: string
  disabled?: boolean
  required?: boolean
  error?: string
  mode?: 'single' | 'range' | 'multiple'
  minDate?: Date
  maxDate?: Date
  disabledDates?: Date[]
  showWeekNumbers?: boolean
  firstDayOfWeek?: 0 | 1 | 2 | 3 | 4 | 5 | 6
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  disabled: false,
  required: false,
  mode: 'single',
  showWeekNumbers: false,
  firstDayOfWeek: 0,
  size: 'md',
  placeholder: 'Select date',
})

const emit = defineEmits<{
  'update:modelValue': [value: Date | Date[] | null]
  change: [value: Date | Date[] | null]
}>()

const isOpen = ref(false)
const currentMonth = ref(new Date().getMonth())
const currentYear = ref(new Date().getFullYear())
const rangeStart = ref<Date | null>(null)

const weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']

// Adjust week days based on firstDayOfWeek
const adjustedWeekDays = computed(() => {
  const days = [...weekDays]
  for (let i = 0; i < props.firstDayOfWeek; i++) {
    days.push(days.shift()!)
  }
  return days
})

// Get days in month
const getDaysInMonth = (year: number, month: number): number => {
  return new Date(year, month + 1, 0).getDate()
}

// Get first day of month (0 = Sunday, 6 = Saturday)
const getFirstDayOfMonth = (year: number, month: number): number => {
  const day = new Date(year, month, 1).getDay()
  return (day - props.firstDayOfWeek + 7) % 7
}

// Generate calendar grid
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

// Format date for display
const formatDate = (date: Date): string => {
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  })
}

// Display value
const displayValue = computed(() => {
  if (!props.modelValue) return ''

  if (props.mode === 'single') {
    return props.modelValue instanceof Date ? formatDate(props.modelValue) : ''
  } else if (props.mode === 'range' && Array.isArray(props.modelValue)) {
    if (props.modelValue.length === 2) {
      return `${formatDate(props.modelValue[0])} - ${formatDate(props.modelValue[1])}`
    } else if (props.modelValue.length === 1) {
      return formatDate(props.modelValue[0])
    }
  } else if (props.mode === 'multiple' && Array.isArray(props.modelValue)) {
    return props.modelValue.map(formatDate).join(', ')
  }

  return ''
})

// Check if date is same day
const isSameDay = (date1: Date, date2: Date): boolean => {
  return (
    date1.getFullYear() === date2.getFullYear() &&
    date1.getMonth() === date2.getMonth() &&
    date1.getDate() === date2.getDate()
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

// Check if date is in range (for range mode)
const isInRange = (day: number): boolean => {
  if (props.mode !== 'range' || !Array.isArray(props.modelValue)) return false
  if (props.modelValue.length !== 2) return false

  const date = new Date(currentYear.value, currentMonth.value, day)
  const [start, end] = props.modelValue

  return date > start && date < end
}

// Check if date is disabled
const isDisabled = (day: number): boolean => {
  const date = new Date(currentYear.value, currentMonth.value, day)

  // Check min date
  if (props.minDate && date < props.minDate) return true

  // Check max date
  if (props.maxDate && date > props.maxDate) return true

  // Check disabled dates
  if (props.disabledDates) {
    return props.disabledDates.some((d) => isSameDay(date, d))
  }

  return false
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

// Select date
const selectDate = (day: number) => {
  if (isDisabled(day)) return

  const date = new Date(currentYear.value, currentMonth.value, day)

  if (props.mode === 'single') {
    emit('update:modelValue', date)
    emit('change', date)
    isOpen.value = false
  } else if (props.mode === 'range') {
    if (!rangeStart.value) {
      rangeStart.value = date
      emit('update:modelValue', [date])
      emit('change', [date])
    } else {
      const start = rangeStart.value
      const end = date

      if (end < start) {
        emit('update:modelValue', [end, start])
        emit('change', [end, start])
      } else {
        emit('update:modelValue', [start, end])
        emit('change', [start, end])
      }

      rangeStart.value = null
      isOpen.value = false
    }
  } else if (props.mode === 'multiple') {
    const dates = Array.isArray(props.modelValue) ? [...props.modelValue] : []
    const index = dates.findIndex((d) => isSameDay(d, date))

    if (index > -1) {
      dates.splice(index, 1)
    } else {
      dates.push(date)
    }

    emit('update:modelValue', dates)
    emit('change', dates)
  }
}

// Toggle calendar
const toggleCalendar = () => {
  if (props.disabled) return
  isOpen.value = !isOpen.value
}

// Close calendar
const closeCalendar = () => {
  isOpen.value = false
  rangeStart.value = null
}

// Clear selection
const clearSelection = () => {
  if (props.disabled) return

  const newValue = props.mode === 'single' ? null : []
  emit('update:modelValue', newValue)
  emit('change', newValue)
  rangeStart.value = null
}

// Get month name
const monthName = computed(() => {
  return new Date(currentYear.value, currentMonth.value).toLocaleString('en-US', {
    month: 'long',
  })
})

// Size classes
const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'text-sm'
    case 'lg':
      return 'text-lg'
    default:
      return 'text-base'
  }
})

// Click outside handler
const handleClickOutside = (e: MouseEvent) => {
  if (!isOpen.value) return

  const target = e.target as Node
  const container = document.querySelector('.datepicker-container')

  if (container && !container.contains(target)) {
    closeCalendar()
  }
}

watch(isOpen, (value) => {
  if (value) {
    document.addEventListener('click', handleClickOutside)
  } else {
    document.removeEventListener('click', handleClickOutside)
  }
})
</script>

<template>
  <div class="datepicker-container" :class="sizeClasses">
    <!-- Label -->
    <label v-if="label" class="mb-2 block text-sm font-medium text-gray-700">
      {{ label }}
      <span v-if="required" class="ml-1 text-red-500" aria-label="required">*</span>
    </label>

    <!-- Description -->
    <p v-if="description" class="mb-2 text-sm text-gray-500">
      {{ description }}
    </p>

    <!-- Input -->
    <div class="relative">
      <div
        class="flex w-full cursor-pointer items-center rounded-md border bg-white"
        :class="[
          error ? 'border-red-500' : 'border-gray-300',
          disabled ? 'cursor-not-allowed bg-gray-100' : 'hover:border-gray-400',
        ]"
        @click="toggleCalendar"
      >
        <div class="flex-1 px-3 py-2 text-gray-700" :class="{ 'text-gray-400': !displayValue }">
          {{ displayValue || placeholder }}
        </div>

        <div class="flex items-center gap-1 pr-2">
          <button
            v-if="displayValue && !disabled"
            type="button"
            class="rounded p-1 hover:bg-gray-100"
            @click.stop="clearSelection"
            aria-label="Clear selection"
          >
            <Icon name="x" :size="16" />
          </button>

          <Icon name="calendar" :size="20" class="text-gray-400" />
        </div>
      </div>

      <!-- Calendar -->
      <Transition
        enter-active-class="transition-opacity duration-100"
        leave-active-class="transition-opacity duration-100"
        enter-from-class="opacity-0"
        leave-to-class="opacity-0"
      >
        <div
          v-if="isOpen"
          class="absolute z-50 mt-1 rounded-lg border border-gray-200 bg-white p-4 shadow-lg"
          @click.stop
        >
          <!-- Header -->
          <div class="mb-4 flex items-center justify-between">
            <Button variant="ghost" size="sm" @click="previousMonth" aria-label="Previous month">
              <Icon name="chevron-left" :size="20" />
            </Button>

            <div class="text-center font-semibold">
              {{ monthName }} {{ currentYear }}
            </div>

            <Button variant="ghost" size="sm" @click="nextMonth" aria-label="Next month">
              <Icon name="chevron-right" :size="20" />
            </Button>
          </div>

          <!-- Week days -->
          <div class="mb-2 grid grid-cols-7 gap-1 text-center text-sm font-medium text-gray-500">
            <div v-for="day in adjustedWeekDays" :key="day" class="p-2">
              {{ day }}
            </div>
          </div>

          <!-- Calendar days -->
          <div class="grid grid-cols-7 gap-1">
            <div
              v-for="(day, index) in calendarDays"
              :key="index"
              class="aspect-square"
            >
              <button
                v-if="day"
                type="button"
                class="flex h-full w-full items-center justify-center rounded-md text-sm transition-colors"
                :class="[
                  isSelected(day)
                    ? 'bg-primary-600 text-white hover:bg-primary-700'
                    : isInRange(day)
                      ? 'bg-primary-100 text-primary-900'
                      : isToday(day)
                        ? 'border-2 border-primary-600 text-primary-600'
                        : 'text-gray-700 hover:bg-gray-100',
                  isDisabled(day)
                    ? 'cursor-not-allowed text-gray-300 hover:bg-transparent'
                    : '',
                ]"
                :disabled="isDisabled(day)"
                @click="selectDate(day)"
              >
                {{ day }}
              </button>
            </div>
          </div>
        </div>
      </Transition>
    </div>

    <!-- Error Message -->
    <p v-if="error" class="mt-2 text-sm text-red-600">
      {{ error }}
    </p>
  </div>
</template>
